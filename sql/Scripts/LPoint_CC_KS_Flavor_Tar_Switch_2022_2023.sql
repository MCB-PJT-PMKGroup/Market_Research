-- 2024.07.23 대상 작업
--CC Switching 2023 vs. 2022 KS Regular
--CC Switching 2023 vs. 2022 KS NTD
--CC Switching 2023 vs. 2022 KS Regular to NTD
--CC Switching 2023 vs. 2022 KS Fresh to NTD

-- 전체 CC KS 대상 탐색
select 'KS',CIGATYPE , ProductFamilyCode ,FLAVORSEG_type6, count(*) "KS SEG"
FROM cx.product_master_temp
where THICKSEG = 'STD'
--and ProductFamilyCode in ('ESSE', 'DUNHILL', 'MEVIUS', 'MLB' , 'RAISON')  -- Top5 대상
group by CIGATYPE , ProductFamilyCode, FLAVORSEG_type6;

-- 140188
--truncate table cx.agg_CC_KS_SSL_Switch_2022_2023 ;
select * from cx.agg_CC_KS_SSL_Switch_2022_2023 
where THICKSEG = 'SSL'
and ProductFamilyCode  = 'All'
;

-- 전체 CC KS 대상 모수 테이블 생성
--insert into cx.agg_CC_KS_SSL_Switch_2022_2023
SELECT 
    a.product_code,
	a.id,
	'All' familycode,
	b.THICKSEG ,
	b.FLAVORSEG_type6,
	sum(case when left(a.YYYYMM, 4) = '2022' then a.buy_ct * a.pack_qty else 0 end) as [Out],
	sum(case when left(a.YYYYMM, 4) = '2023' then a.buy_ct * a.pack_qty else 0 end) as [In]
--into cx.agg_CC_KS_SSL_Switch_2022_2023
FROM 
    cx.fct_K7_Monthly a
     	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id) 
    	and b.THICKSEG ='STD' and b.FLAVORSEG_type6 = 'New Taste'
where 1=1
   	and left(a.YYYYMM, 4) in ('2022', '2023')
    --2022, 2023년 모두 구매한 사람은 제외
    and a.id not in (
	    SELECT 
			x.id
        FROM cx.fct_K7_Monthly x
        	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id) 
        	and y.THICKSEG  = 'STD' and y.FLAVORSEG_type6 = 'New Taste'
		where 1=1
		   	and left(x.YYYYMM, 4) in ('2022', '2023')
		GROUP BY 
		    y.cigatype,   
			y.THICKSEG ,
	    	y.FLAVORSEG_type6, x.id
		HAVING
		    -- 2023년, 2022년에 모두 구매함	
		    (SUM(CASE WHEN left(x.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) > 0
		    AND SUM(CASE WHEN left(x.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0)
	)
GROUP BY 
    a.product_code, a.id,  
	b.THICKSEG,
    b.FLAVORSEG_type6
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


-- KS Regular 84,374
-- KS New Taste 0
-- KS Regular to New Taste 64,743
-- KS Fresh to New Taste 39,462

with temp as ( 
	SELECT 
		a.id,
		b.THICKSEG , 
		b.FLAVORSEG_type6,
		sum(case when left(a.YYYYMM, 4) = '2022' then a.buy_ct * a.pack_qty else 0 end) as [Out],
		sum(case when left(a.YYYYMM, 4) = '2023' then a.buy_ct * a.pack_qty else 0 end) as [In]
	FROM 
	    cx.fct_K7_Monthly a
	     	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id) 
	    	and b.THICKSEG ='STD' and b.FLAVORSEG_type6 = 'Fresh to New Taste'
	where 1=1
	   	and left(a.YYYYMM, 4) in ('2022', '2023')
	    --2022, 2023년 모두 구매한 사람은 제외
	    and a.id not in (
			SELECT 
				x.id
			FROM cx.fct_K7_Monthly x
				join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype = 'CC' AND 4 < LEN(x.id) 
				and y.THICKSEG ='STD' and y.FLAVORSEG_type6 = 'Fresh to New Taste'
			where 1=1
			   	and left(x.YYYYMM, 4) in ('2022', '2023')
			GROUP BY          
			    y.THICKSEG, 
				y.FLAVORSEG_type6, x.id
			HAVING 
			    -- 2023년, 2022년에 모두 구매함	
			    (SUM(CASE WHEN left(x.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) > 0
			    AND SUM(CASE WHEN left(x.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0)
		)
	GROUP BY 
	       a.id,    b.THICKSEG,     b.FLAVORSEG_type6
)
--insert into cx.agg_CC_SSL_Switch_2022_2023
select count(*)
from temp a
where     -- Out : 2022년도에는 구매했지만 2023년도에는 해당 제품을 구매하지 않아 Out
	( [out] > 0
	and [In] = 0
    AND EXISTS (
		-- 2023년에는 다른 제품을 구매한 사람
	    SELECT 1
	    FROM cx.fct_K7_Monthly x
	    	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' AND y.cigatype != 'CSV' AND 4 < LEN(x.id)
	    where a.id = x.id and left(x.YYYYMM, 4) = '2023'
		and (y.THICKSEG != a.THICKSEG or y.FLAVORSEG_type6 != a.FLAVORSEG_type6 or y.THICKSEG is null) 	
    	)
	)
	OR
    -- In : 2022년도에는 구매하지 않고 2023년도에는 해당 제품을 구매하여 IN
    ( [In] > 0
    AND [out] = 0 
    AND EXISTS (
    	-- 2022년에 다른 제품을 구매한 사람
	    SELECT 1
	    FROM cx.fct_K7_Monthly x
	    	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' AND y.cigatype != 'CSV' AND 4 < LEN(x.id)
	    where a.id = x.id and left(x.YYYYMM, 4) = '2022'
	    and (y.THICKSEG != a.THICKSEG or y.FLAVORSEG_type6 != a.FLAVORSEG_type6 or y.THICKSEG is null) 	
    	)
    )
;
-- 데이터 차이 비교 
select id from cx.agg_CC_KS_SSL_Switch_2022_2023 where THICKSEG ='SSL' and FLAVORSEG_type6 ='Regular to New Taste'
except 
select id from cx.agg_CC_SSL_Switch_2022_2023 where THICKSEG in ('SSL', 'SLI', 'MSL') and FLAVORSEG_type6 ='Regular to New Taste'
;


-- cigatype, Taste, Tar CC Switching 작업
select  
	b.cigatype,	
	b.FLAVORSEG_type6,
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
	cx.agg_CC_KS_SSL_Switch_2022_2023 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') 
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV'
			and (b.THICKSEG != t.THICKSEG or b.FLAVORSEG_type6 != t.FLAVORSEG_type6 or b.THICKSEG is null) 	
WHERE  t.THICKSEG ='STD' and t.FLAVORSEG_type6 = 'Regular'
group by grouping sets ((b.cigatype, b.FLAVORSEG_type6, b.New_TARSEGMENTAT),  (b.cigatype, b.FLAVORSEG_type6),  (b.cigatype), ())
;



-- SKU 별 Switching In/Out
select
	b.cigatype,
	b.Engname,
	b.FLAVORSEG_type6,
	b.New_Tarsegmentat,
	b.THICKSEG,
	count(DISTINCT case when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(DISTINCT case when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	'',
	'',
	'',
	sum(case when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then a.buy_ct * a.Pack_qty end ) as Out_Quantity,
	sum(case when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then a.buy_ct * a.Pack_qty end ) as In_Quantity
from cx.agg_CC_KS_SSL_Switch_2022_2023  t
	join cx.fct_K7_Monthly a on t.id = a.id and 4 < len(a.id) and left(a.YYYYMM, 4) in ('2022', '2023')   
	join cx.product_master_temp b on a.Product_code = b.prod_id and b.CIGADEVICE ='CIGARETTES' and b.CIGATYPE != 'CSV' 
		and (b.THICKSEG != t.THICKSEG or b.FLAVORSEG_type6 != t.FLAVORSEG_type6 or b.THICKSEG is null) 	
WHERE  t.THICKSEG ='STD' and t.FLAVORSEG_type6 = 'Regular to New Taste'
group by grouping sets ((b.cigatype, b.Engname, b.FLAVORSEG_type6, b.New_Tarsegmentat, b.THICKSEG), (b.cigatype), ())
;

-- 구매자, 구매팩수 총 카운트
select 
	 b.THICKSEG, b.FLAVORSEG_type6,
	left(a.yyyymm,4) year,
	COUNT(distinct id ) Purchaser_Cnt,
	sum(a.buy_ct * a.pack_qty) as Total_Pack_Cnt
FROM 
	cx.fct_K7_Monthly a
    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
    	AND b.THICKSEG = 'STD' and b.FLAVORSEG_type6 = 'Fresh to New Taste'
where 1=1
   	and left(a.YYYYMM, 4) in ('2022', '2023')
GROUP BY 
	 b.THICKSEG, b.FLAVORSEG_type6, left(a.YYYYMM, 4)
;

    
-- In/Out별 구매자수, 총 구매 팩수 
select  
	t.THICKSEG, t.FLAVORSEG_type6,
	left(a.yyyymm,4) year,
	count(DISTINCT case when t.[Out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(DISTINCT case when t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	sum(case when t.[Out] > 0 then a.buy_ct * a.pack_qty end ) as Out_Quantity,
	sum(case when t.[In] > 0 then a.buy_ct * a.pack_qty end ) as In_Quantity
from 
	cx.agg_CC_KS_SSL_Switch_2022_2023 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') and a.product_code = t.product_code
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV'
where  t.ProductFamilyCode ='All' and t.THICKSEG ='STD' and t.FLAVORSEG_type6 = 'Fresh to New Taste'	
group by
     t.THICKSEG, t.FLAVORSEG_type6, left(a.YYYYMM, 4)
;

-- 데이터 검증
select product_code , sum([Out]) sum_out, sum([In]) sum_in
from cx.agg_CC_KS_SSL_Switch_2022_2023
group by product_code ;
