-- Family 별 제품 구매량 집계
-- (2022 vs. 2023) Family name: 말보로 / Tar: LTS 제품 구매자가 다른 Family 제품 구매자 파악

-- 40,123 rows
-- 2022, 2023년에 (2022 vs. 2023) Family name: 말보로 / Tar: LTS 제품 >> In/Out 모수
SELECT 
    a.product_code,
	a.id,
	b.ProductFamilyCode , b.New_TARSEGMENTAT,
	sum(case when left(a.YYYYMM, 4) = '2022' then a.buy_ct * a.pack_qty else 0 end) as [Out],
	sum(case when left(a.YYYYMM, 4) = '2023' then a.buy_ct * a.pack_qty else 0 end) as [In]
--into cx.agg_MLB_LTS_Switch4
FROM 
    cx.fct_K7_Monthly a
    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
where 1=1
   	and left(a.YYYYMM, 4) in ('2022', '2023')
    -- 말보로 LTS 제품군
  	AND b.ProductFamilyCode = 'MLB' and b.New_TARSEGMENTAT = 'LTS'
    --2022, 2023년 모두 구매한 사람은 제외
    and a.id not in (	
	    SELECT 
			x.id
        FROM cx.fct_K7_Monthly x
        	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
		where 1=1
		   	and left(x.YYYYMM, 4) in ('2022', '2023')
			AND y.ProductFamilyCode = 'MLB' and y.New_TARSEGMENTAT = 'LTS'
		GROUP BY 
		    y.cigatype, y.ProductFamilyCode, y.New_TARSEGMENTAT, x.id
		HAVING 
		    -- 2023년, 2022년에 모두 구매함	
		    (SUM(CASE WHEN left(x.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) > 0
		    AND SUM(CASE WHEN left(x.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0)
	)
GROUP BY 
    a.product_code, a.id ,b.ProductFamilyCode , b.New_TARSEGMENTAT
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
		and x.product_code not in ( a.product_code )
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
	    and x.product_code not in (a.product_code )
    	)
    )
;



select *
 FROM cx.fct_K7_Monthly x
	    	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
where x.product_code  ='88019963'
and left(x.YYYYMM ,4) ='2022';


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
	cx.agg_MLB_LTS_Switch t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') and a.product_code not in( t.product_code)
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
group by rollup(b.cigatype, b.New_FLAVORSEG, b.New_TARSEGMENTAT)
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
from cx.agg_MLB_LTS_Switch  t
	join cx.fct_K7_Monthly a on t.id = a.id and 4 < len(a.id) and left(a.YYYYMM, 4) in ('2022', '2023')  and a.product_code not in( t.product_code)
	join cx.product_master_temp b on a.Product_code = b.prod_id and b.CIGADEVICE ='CIGARETTES' and b.CIGATYPE != 'CSV'
where (b.ProductFamilyCode != 'MLB' or b.New_TARSEGMENTAT != 'LTS')
group by grouping sets (( b.cigatype, b.Engname, b.New_Flavorseg, b.New_Tarsegmentat, b.THICKSEG), (b.cigatype), ())
;



--  2022년 ~ 2023년동안 지속적으로 동일한 제품을 이용한 고객 Continuous Purchaser Count,	Pack Count
WITH temp AS(
	SELECT 
		b.cigatype,
	    b.ProductFamilyCode,
	    b.New_TARSEGMENTAT,
		a.id,
		sum(a.buy_ct * a.pack_qty) as sale_pack_cnt,
	    SUM(CASE WHEN left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) AS [Out],
	    SUM(CASE WHEN left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) AS [In]
	FROM 
	    cx.fct_K7_Monthly a
	    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
	where 1=1
	   	and left(a.YYYYMM, 4) in ('2022', '2023')
	    AND b.ProductFamilyCode = 'MLB' and b.New_TARSEGMENTAT = 'LTS'
	GROUP BY 
	    b.cigatype, b.ProductFamilyCode, b.New_TARSEGMENTAT, a.id
	HAVING 
	    -- "in/Out" 상태: 2023년에는 구매하고 2022년에도 구매함	
	    (SUM(CASE WHEN left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) > 0
	    AND SUM(CASE WHEN left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0)
)
select 
	ProductFamilyCode, New_TARSEGMENTAT,
	count(distinct id) as Purchaser_cnt,
	sum(sale_pack_cnt) as pack_cnt
from temp
group by ProductFamilyCode, New_TARSEGMENTAT
;


-- 구매자 총 카운트
select 
	b.engname,
	left(a.yyyymm,4) year,
	COUNT(distinct id ) Purchaser_Cnt,
	sum(a.buy_ct * a.pack_qty) as Total_Pack_Cnt
FROM 
    cx.fct_K7_Monthly a
    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
where 1=1
   	and left(a.YYYYMM, 4) in ('2022', '2023')
    AND b.ProductFamilyCode = 'MLB' and b.New_TARSEGMENTAT = 'LTS'
GROUP BY 
      b.engname, left(a.YYYYMM, 4)
;
	   
-- In/Out별 구매자수, 총 구매 팩수 
select  
	t.ProductFamilyCode, t.New_TARSEGMENTAT,
	case 
		when t.[Out] > 0 then '2022'
		when t.[In] > 0 then '2023'		
	end year,
	count(DISTINCT case when t.[Out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(DISTINCT case when t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	sum(case when  t.[Out] > 0 then t.[Out] end ) as Out_Quantity,
	sum(case when t.[In] > 0 then t.[In] end ) as In_Quantity
from 
	cx.agg_MLB_LTS_Switch t
group by 	
	t.ProductFamilyCode, t.New_TARSEGMENTAT, 
	case 
		when t.[Out] > 0 then '2022'
		when t.[In] > 0 then '2023'		
	end
;