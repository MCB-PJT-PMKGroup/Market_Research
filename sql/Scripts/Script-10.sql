/* 작업 시작일 2024.07.19
 * 
CC Switching 2023 vs. 2022 ESSE
CC Switching 2023 vs. 2022 DUNHILL
CC Switching 2023 vs. 2022 MEVIUS
CC Switching 2023 vs. 2022 MARLBORO
CC Switching 2023 vs. 2022 RAISON
CC Switching 24Q1 vs. 23Q4 ESSE
CC Switching 24Q1 vs. 23Q4 DUNHILL
CC Switching 24Q1 vs. 23Q4 MEVIUS
CC Switching 24Q1 vs. 23Q4 MARLBORO
CC Switching 24Q1 vs. 23Q4 RAISON
*/
-- 대상 참고
select * from cx.product_master_temp
where ProductSubFamilyCode = 'DUNHILLKS' and New_FLAVORSEG='Regular' and TARINFO in ('1', '3', '6') and prod_id != '88011639';

select * 
from cx.product_master_temp
where ProductFamilyCode = 'DUNHILL' and New_FLAVORSEG='Regular' and thickseg ='SSL'  and TARINFO in ('1', '3', '0.1') ;

-- DUNHILL KS 대상 : 38,386 rows
SELECT 
    a.product_code,
	a.id,
	b.tarinfo , b.New_TARSEGMENTAT,
	sum(case when left(a.YYYYMM, 4) = '2022' then a.buy_ct * a.pack_qty else 0 end) as [Out],
	sum(case when left(a.YYYYMM, 4) = '2023' then a.buy_ct * a.pack_qty else 0 end) as [In]
into cx.agg_DUNHILL_KS_Switch_2022_2023
FROM 
    cx.fct_K7_Monthly a
    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
where 1=1
   	and left(a.YYYYMM, 4) in ('2022', '2023')
   	-- Dunhill KS 대상 
	and ProductSubFamilyCode = 'DUNHILLKS' and New_FLAVORSEG='Regular' and TARINFO in ('1', '3', '6') and prod_id != '88011639'
    --2022, 2023년 모두 구매한 사람은 제외
    and a.id not in (	
	    SELECT 
			x.id
        FROM cx.fct_K7_Monthly x
        	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
		where 1=1
		   	and left(x.YYYYMM, 4) in ('2022', '2023')
		   	-- DUNHILL KS , SSL
			and ProductSubFamilyCode = 'DUNHILLKS' and New_FLAVORSEG='Regular' and TARINFO in ('1', '3', '6') and prod_id != '88011639'
		GROUP BY 
		    y.cigatype, y.ProductFamilyCode, y.PROD_ID, x.id
		HAVING 
		    -- 2023년, 2022년에 모두 구매함	
		    (SUM(CASE WHEN left(x.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) > 0
		    AND SUM(CASE WHEN left(x.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0)
	)
GROUP BY 
    a.product_code, a.id ,b.tarinfo , b.New_TARSEGMENTAT
HAVING
    -- Out : 2022년도에는 구매했지만 2023년도에는 해당 제품을 구매하지 않아 Out
	(SUM(CASE WHEN  left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0
	and SUM(CASE WHEN  left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) = 0
    AND EXISTS (
		-- 2023년에는 다른 제품을 구매한 사람
	    SELECT 1
	    FROM cx.fct_K7_Monthly x
	    	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
	    where a.id = x.id and left(x.YYYYMM, 4) = '2023'
		and x.product_code != a.product_code 
    	)
	)
	OR
    -- In : 2022년도에는 구매하지 않고 2023년도에는 해당 제품을 구매하여 IN
    (SUM(CASE WHEN left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) > 0
    AND SUM(CASE WHEN left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) = 0 
    AND EXISTS (
    	-- 2022년에 다른 제품을 구매한 사람
	    SELECT 1
	    FROM cx.fct_K7_Monthly x
	    	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
	    where a.id = x.id and left(x.YYYYMM, 4) = '2022'
	    and x.product_code != a.product_code 
    	)
    )
;


-- DUNHILL SSL 대상 : 11,066 rows
SELECT 
    a.product_code,
	a.id,
	b.tarinfo, b.New_TARSEGMENTAT,
	sum(case when left(a.YYYYMM, 4) = '2022' then a.buy_ct * a.pack_qty else 0 end) as [Out],
	sum(case when left(a.YYYYMM, 4) = '2023' then a.buy_ct * a.pack_qty else 0 end) as [In]
--into cx.agg_DUNHILL_SSL_Switch_2022_2023
FROM 
    cx.fct_K7_Monthly a
    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
where 1=1
   	and left(a.YYYYMM, 4) in ('2022', '2023')
   	-- Dunhill SSL 대상 
	and ProductFamilyCode = 'DUNHILL' and New_FLAVORSEG='Regular' and thickseg ='SSL'  and TARINFO in ('1', '3', '0.1') 
    --2022, 2023년 모두 구매한 사람은 제외
    and a.id not in (	
	    SELECT 
			x.id
        FROM cx.fct_K7_Monthly x
        	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
		where 1=1
		   	and left(x.YYYYMM, 4) in ('2022', '2023')
		   	-- DUNHILL KS , SSL
			and ProductFamilyCode = 'DUNHILL' and New_FLAVORSEG='Regular' and thickseg ='SSL'  and TARINFO in ('1', '3', '0.1') 
		GROUP BY 
		    y.cigatype, y.ProductFamilyCode, y.PROD_ID, x.id
		HAVING 
		    -- 2023년, 2022년에 모두 구매함	
		    (SUM(CASE WHEN left(x.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) > 0
		    AND SUM(CASE WHEN left(x.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0)
	)
GROUP BY 
    a.product_code, a.id ,b.tarinfo , b.New_TARSEGMENTAT
HAVING
    -- Out : 2022년도에는 구매했지만 2023년도에는 해당 제품을 구매하지 않아 Out
	(SUM(CASE WHEN  left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0
	and SUM(CASE WHEN  left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) = 0
    AND EXISTS (
		-- 2023년에는 다른 제품을 구매한 사람
	    SELECT 1
	    FROM cx.fct_K7_Monthly x
	    	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
	    where a.id = x.id and left(x.YYYYMM, 4) = '2023'
		and x.product_code != a.product_code 
    	)
	)
	OR
    -- In : 2022년도에는 구매하지 않고 2023년도에는 해당 제품을 구매하여 IN
    (SUM(CASE WHEN left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) > 0
    AND SUM(CASE WHEN left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) = 0 
    AND EXISTS (
    	-- 2022년에 다른 제품을 구매한 사람
	    SELECT 1
	    FROM cx.fct_K7_Monthly x
	    	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
	    where a.id = x.id and left(x.YYYYMM, 4) = '2022'
	    and x.product_code != a.product_code 
    	)
    )
;



--------------------------------------------------------------------------------DUNHILL KS -----------------------------------------------------------------
-- cigatype, Taste, Tar CC Switching 작업
select  
	b.cigatype,	
	b.New_FLAVORSEG,
	b.New_TARSEGMENTAT,
	count(distinct case when left(a.YYYYMM, 4) = '2023' and t.[out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(distinct case when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	'',
	'',
	'',
	sum(case 
		when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then a.buy_ct * a.pack_qty 
	end )as Out_quantity,
	sum(case 
		when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then a.buy_ct * a.pack_qty 
	end) as In_quantity
from 
	cx.agg_DUNHILL_KS_Switch_2022_2023 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') 
			and a.product_code not in( t.product_code)		-- 다른 제품만 추출
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
WHERE t.tarinfo = '1'
group by grouping sets ((b.cigatype, b.New_FLAVORSEG, b.New_TARSEGMENTAT),  (b.cigatype, b.New_FLAVORSEG),  (b.cigatype), ())
;

-- SKU 별 Switching In/Out
select
	b.cigatype,
	b.Engname,
	b.New_Flavorseg,
	b.New_Tarsegmentat,
	b.THICKSEG,
	count(DISTINCT case when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(DISTINCT case when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	'',
	'',
	'',
	sum(case when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then a.buy_ct * a.Pack_qty end ) as Out_Quantity,
	sum(case when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then a.buy_ct * a.Pack_qty end ) as In_Quantity
from cx.agg_DUNHILL_KS_Switch_2022_2023  t
	join cx.fct_K7_Monthly a on t.id = a.id and 4 < len(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') and a.product_code not in(t.product_code) 
	join cx.product_master_temp b on a.Product_code = b.prod_id and b.CIGADEVICE ='CIGARETTES' and b.CIGATYPE != 'CSV' 
WHERE t.tarinfo = '1'
group by grouping sets ((b.cigatype, b.Engname, b.New_Flavorseg, b.New_Tarsegmentat, b.THICKSEG), (b.cigatype), ())
;

-- 구매자, 구매팩수 총 카운트
select 
	case 
		when  b.ProductSubFamilyCode = 'DUNHILLKS' and b.New_FLAVORSEG='Regular' and b.TARINFO ='6' 
	    then 'DUNHILL KS 6mg'	
  	    when  b.ProductSubFamilyCode = 'DUNHILLKS' and b.New_FLAVORSEG='Regular' and b.TARINFO ='3' 
	    then 'DUNHILL KS 3mg'	
  	    when  b.ProductSubFamilyCode = 'DUNHILLKS' and b.New_FLAVORSEG='Regular' and b.TARINFO ='1' 
	    then 'DUNHILL KS 1mg'	
    end as engname,
	left(a.yyyymm,4) year,
	COUNT(distinct id ) Purchaser_Cnt,
	sum(a.buy_ct * a.pack_qty) as Total_Pack_Cnt
FROM 
	cx.fct_K7_Monthly a
    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
where 1=1
   	and left(a.YYYYMM, 4) in ('2022', '2023')
    AND b.ProductSubFamilyCode = 'DUNHILLKS' and b.New_FLAVORSEG='Regular' and b.TARINFO in ('1', '3', '6')
GROUP BY 
      case 
	      when  b.ProductSubFamilyCode = 'DUNHILLKS' and b.New_FLAVORSEG='Regular' and b.TARINFO ='6' 
	      then 'DUNHILL KS 6mg'	
  	      when  b.ProductSubFamilyCode = 'DUNHILLKS' and b.New_FLAVORSEG='Regular' and b.TARINFO ='3' 
	      then 'DUNHILL KS 3mg'	
  	      when  b.ProductSubFamilyCode = 'DUNHILLKS' and b.New_FLAVORSEG='Regular' and b.TARINFO ='1' 
	      then 'DUNHILL KS 1mg'	
      end, left(a.YYYYMM, 4)
;

-- KS	    
-- In/Out별 구매자수, 총 구매 팩수 
select  
	 case 
	      when  b.ProductSubFamilyCode = 'DUNHILLKS' and b.New_FLAVORSEG='Regular' and b.TARINFO ='6' 
	      then 'DUNHILL KS 6mg'	
  	      when  b.ProductSubFamilyCode = 'DUNHILLKS' and b.New_FLAVORSEG='Regular' and b.TARINFO ='3' 
	      then 'DUNHILL KS 3mg'	
  	      when  b.ProductSubFamilyCode = 'DUNHILLKS' and b.New_FLAVORSEG='Regular' and b.TARINFO ='1' 
	      then 'DUNHILL KS 1mg'	
      end engname, 
	left(a.yyyymm,4) year,
	count(DISTINCT case when t.[Out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(DISTINCT case when t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	sum(case when t.[Out] > 0 then a.buy_ct * a.Pack_qty end ) as Out_Quantity,
	sum(case when t.[In] > 0 then a.buy_ct * a.Pack_qty end ) as In_Quantity
from 
	cx.agg_DUNHILL_KS_Switch_2022_2023 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') and a.product_code = t.product_code
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV'
group by
      case 
	      when  b.ProductSubFamilyCode = 'DUNHILLKS' and b.New_FLAVORSEG='Regular' and b.TARINFO ='6' 
	      then 'DUNHILL KS 6mg'	
  	      when  b.ProductSubFamilyCode = 'DUNHILLKS' and b.New_FLAVORSEG='Regular' and b.TARINFO ='3' 
	      then 'DUNHILL KS 3mg'	
  	      when  b.ProductSubFamilyCode = 'DUNHILLKS' and b.New_FLAVORSEG='Regular' and b.TARINFO ='1' 
	      then 'DUNHILL KS 1mg'	
      end, left(a.YYYYMM, 4)
;
	   
----------------------------------------------------------------------DUNHILL SSL --------------------------------------------------------------------------------------------
-- cigatype, Taste, Tar CC Switching 작업

select  
	b.cigatype,	
	b.New_FLAVORSEG,
	b.New_TARSEGMENTAT,
	count(distinct case when left(a.YYYYMM, 4) = '2023' and t.[out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(distinct case when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	'',
	'',
	'',
	sum(case 
		when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then a.buy_ct * a.pack_qty 
	end )as Out_quantity,
	sum(case 
		when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then a.buy_ct * a.pack_qty 
	end) as In_quantity
from 
	cx.agg_DUNHILL_SSL_Switch_2022_2023 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') 
			and a.product_code not in( t.product_code)		-- 다른 제품만 추출
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
WHERE t.tarinfo = '0.1'
group by grouping sets ((b.cigatype, b.New_FLAVORSEG, b.New_TARSEGMENTAT),  (b.cigatype, b.New_FLAVORSEG),  (b.cigatype), ())
;

-- SKU 별 Switching In/Out
select
	b.cigatype,
	b.Engname,
	b.New_Flavorseg,
	b.New_Tarsegmentat,
	b.THICKSEG,
	count(DISTINCT case when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(DISTINCT case when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	'',
	'',
	'',
	sum(case when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then a.buy_ct * a.Pack_qty end ) as Out_Quantity,
	sum(case when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then a.buy_ct * a.Pack_qty end ) as In_Quantity
from cx.agg_DUNHILL_SSL_Switch_2022_2023  t
	join cx.fct_K7_Monthly a on t.id = a.id and 4 < len(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') and a.product_code not in(t.product_code) 
	join cx.product_master_temp b on a.Product_code = b.prod_id and b.CIGADEVICE ='CIGARETTES' and b.CIGATYPE != 'CSV' 
WHERE t.tarinfo = '0.1'
group by grouping sets ((b.cigatype, b.Engname, b.New_Flavorseg, b.New_Tarsegmentat, b.THICKSEG), (b.cigatype), ())
;
	   



-- 2022년 ~ 2023년동안 지속적으로 동일한 제품을 이용한 고객, Continuous Purchaser Count,	Pack Count
-- 25,404
--with temp as (
--	SELECT 
--		b.cigatype,
--	    b.ProductFamilyCode,
--	    b.engname,
--		a.id,
--		sum(a.buy_ct * a.pack_qty) as sale_pack_cnt,
--	    SUM(CASE WHEN left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) AS [Out],
--	    SUM(CASE WHEN left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) AS [In]
--	FROM 
--	    cx.fct_K7_Monthly a
--	    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
--	where 1=1
--	   	and left(a.YYYYMM, 4) in ('2022', '2023')
--	    AND b.ProductFamilyCode ='PLT' and b.Productcode in  ('PLTSSRD', 'PLTSSON', 'PLTSSCF')
--	GROUP BY 
--	    b.cigatype, b.ProductFamilyCode, b.engname,  a.id
--	HAVING    
--	 	 2022년에 구매하고 2023년에도 구매한 사람들
--	    (SUM(CASE WHEN  left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0
--	    AND SUM(CASE WHEN left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) > 0)
--)
--select 
--	engname, 
--	count(distinct id) as Purchaser_cnt,
--	sum(sale_pack_cnt) as pack_cnt
--from temp
--group by engname
--;




-- 구매자, 구매팩수 총 카운트
select 
	case 
	      when ProductFamilyCode = 'DUNHILL' and New_FLAVORSEG='Regular' and thickseg ='SSL' and b.TARINFO ='3' 
	      then 'DUNHILL SSL 3mg'	
  	      when ProductFamilyCode = 'DUNHILL' and New_FLAVORSEG='Regular' and thickseg ='SSL' and b.TARINFO ='1' 
	      then 'DUNHILL SSL 1mg'	
  	      when ProductFamilyCode = 'DUNHILL' and New_FLAVORSEG='Regular' and thickseg ='SSL' and b.TARINFO ='0.1' 
	      then 'DUNHILL SSL 0.1mg'	
    end as engname,
	left(a.yyyymm,4) year,
	COUNT(distinct id ) Purchaser_Cnt,
	sum(a.buy_ct * a.pack_qty) as Total_Pack_Cnt
FROM 
	cx.fct_K7_Monthly a
    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
where 1=1
   	and left(a.YYYYMM, 4) in ('2022', '2023')
    AND ProductFamilyCode = 'DUNHILL' and New_FLAVORSEG='Regular' and thickseg ='SSL'  and TARINFO in ('1', '3', '0.1') 
GROUP BY 
      case 
	      when ProductFamilyCode = 'DUNHILL' and New_FLAVORSEG='Regular' and thickseg ='SSL' and b.TARINFO ='3' 
	      then 'DUNHILL SSL 3mg'	
  	      when ProductFamilyCode = 'DUNHILL' and New_FLAVORSEG='Regular' and thickseg ='SSL' and b.TARINFO ='1' 
	      then 'DUNHILL SSL 1mg'	
  	      when ProductFamilyCode = 'DUNHILL' and New_FLAVORSEG='Regular' and thickseg ='SSL' and b.TARINFO ='0.1' 
	      then 'DUNHILL SSL 0.1mg'
      end, left(a.YYYYMM, 4)
;
 
-- In/Out별 구매자수, 총 구매 팩수 
select  
	 case 
	      when ProductFamilyCode = 'DUNHILL' and New_FLAVORSEG='Regular' and thickseg ='SSL' and b.TARINFO ='3' 
	      then 'DUNHILL SSL 3mg'	
  	      when ProductFamilyCode = 'DUNHILL' and New_FLAVORSEG='Regular' and thickseg ='SSL' and b.TARINFO ='1' 
	      then 'DUNHILL SSL 1mg'	
  	      when ProductFamilyCode = 'DUNHILL' and New_FLAVORSEG='Regular' and thickseg ='SSL' and b.TARINFO ='0.1' 
	      then 'DUNHILL SSL 0.1mg'
      end engname, 
	left(a.yyyymm,4) year,
	count(DISTINCT case when t.[Out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(DISTINCT case when t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	sum(case when t.[Out] > 0 then a.buy_ct * a.Pack_qty end ) as Out_Quantity,
	sum(case when t.[In] > 0 then a.buy_ct * a.Pack_qty end ) as In_Quantity
from 
	cx.agg_DUNHILL_SSL_Switch_2022_2023 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') and a.product_code = t.product_code
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV'
group by
      case 
	      when ProductFamilyCode = 'DUNHILL' and New_FLAVORSEG='Regular' and thickseg ='SSL' and b.TARINFO ='3' 
	      then 'DUNHILL SSL 3mg'	
  	      when ProductFamilyCode = 'DUNHILL' and New_FLAVORSEG='Regular' and thickseg ='SSL' and b.TARINFO ='1' 
	      then 'DUNHILL SSL 1mg'	
  	      when ProductFamilyCode = 'DUNHILL' and New_FLAVORSEG='Regular' and thickseg ='SSL' and b.TARINFO ='0.1' 
	      then 'DUNHILL SSL 0.1mg'	
      end, left(a.YYYYMM, 4)
;