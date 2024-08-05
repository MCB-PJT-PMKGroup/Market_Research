/* 작업 시작일 2024.08.02
 * 
CC Switching 2023 vs. 2022 Regular Taste CC
CC Switching 2023 vs. 2022 NTD Taste CC
CC Switching 2023 vs. 2022 Fresh Taste CC
*/

-- 대상 제품군 개수 참고
select  New_FLAVORSEG  ,count(*)
from bpda.cx.product_master_temp
where  CIGADEVICE =  'CIGARETTES' AND  cigatype != 'CSV'
group by New_FLAVORSEG;
-- 대상 개수
--[null]	6
--Fresh	66
--New Taste	210
--Regular	157


--insert into cx.agg_Taste_Switch_2022_2023
SELECT 
    a.id,
	b.New_FLAVORSEG, 
	sum(case when left(a.YYYYMM, 4) = '2022' then a.pack_qty else 0 end) as [Out],
	sum(case when left(a.YYYYMM, 4) = '2023' then a.pack_qty else 0 end) as [In]
--into cx.agg_Taste_Switch_2022_2023
FROM 
    cx.fct_K7_Monthly a
     	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id) 
     	-- Taste 별 제품군 대상
		-- in ('Regular', 'New Taste', 'Fresh')	
    	and b.New_FLAVORSEG = 'Fresh'
where 1=1
   	and left(a.YYYYMM, 4) in ('2022', '2023')
    --2022, 2023년 모두 구매한 사람은 제외
    and a.id not in (
	    SELECT 
			x.id
        FROM cx.fct_K7_Monthly x
        	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id) 
        	and y.New_FLAVORSEG = b.New_FLAVORSEG 
		where 1=1
		   	and left(x.YYYYMM, 4) in ('2022', '2023')
		GROUP BY 
		    y.New_FLAVORSEG, x.id
		HAVING 
		    -- 2023년, 2022년에 모두 구매함	
		    (SUM(CASE WHEN left(x.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) > 0
		    AND SUM(CASE WHEN left(x.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0)
	)
GROUP BY 
     a.id ,b.New_FLAVORSEG
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
	    and y.New_FLAVORSEG != b.New_FLAVORSEG
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
	    and y.New_FLAVORSEG != b.New_FLAVORSEG
    	)
    )
;

-- 데이터 검증
select New_FLAVORSEG, count(*)
--from cx.agg_top5_Switch_2022_2023
from cx.agg_Taste_Switch_2022_2023 
group by New_FLAVORSEG;


select New_FLAVORSEG , count(distinct id), sum([out]), sum([In])
from cx.agg_Taste_Switch_2022_2023 
group by New_FLAVORSEG
;
--Fresh		80189	134015.0	190548.0
--New Taste	86806	149538.0	272043.0
--Regular	88467	181273.0	152501.0



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
		when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then a.pack_qty else 0
	end )as Out_quantity,
	sum(case 
		when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then a.pack_qty else 0
	end) as In_quantity
from 
	cx.agg_Taste_Switch_2022_2023 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') 
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
			and b.New_FLAVORSEG != t.New_FLAVORSEG
WHERE t.New_FLAVORSEG = 'Fresh'
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
	sum(case when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then a.Pack_qty else 0 end ) as Out_Quantity,
	sum(case when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then a.Pack_qty else 0 end ) as In_Quantity
from 
	cx.agg_Taste_Switch_2022_2023  t
		join cx.fct_K7_Monthly a on t.id = a.id and 4 < len(a.id) and left(a.YYYYMM, 4) in ('2022', '2023')  
		join cx.product_master_temp b on a.Product_code = b.prod_id and b.CIGADEVICE ='CIGARETTES' and b.CIGATYPE != 'CSV' 
			and b.New_FLAVORSEG != t.New_FLAVORSEG
WHERE t.New_FLAVORSEG = 'Fresh'
group by grouping sets ((b.cigatype, b.Engname, b.New_Flavorseg, b.New_Tarsegmentat, b.THICKSEG), (b.cigatype), ())
;

-- 구매자, 구매팩수 총 카운트
select 
	b.New_FLAVORSEG,
	left(a.yyyymm,4) year,
	COUNT(distinct id ) Purchaser_Cnt,
	sum(  a.pack_qty) as Total_Pack_Cnt
FROM 
	cx.fct_K7_Monthly a
    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
where 1=1
   	and left(a.YYYYMM, 4) in ('2022', '2023')
GROUP BY 
	b.New_FLAVORSEG, left(a.YYYYMM, 4)
;

    
-- In/Out별 구매자수, 총 구매 팩수 
select  
	t.New_FLAVORSEG, 
	left(a.yyyymm,4) year,
	count(DISTINCT case when t.[Out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(DISTINCT case when t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	sum(case when t.[Out] > 0 then  a.pack_qty else 0 end ) as Out_Quantity,
	sum(case when t.[In] > 0 then  a.pack_qty else 0 end ) as In_Quantity
from 
	cx.agg_Taste_Switch_2022_2023 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') 
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV'
			and b.New_FLAVORSEG = t.New_FLAVORSEG
where 1=1 -- t.New_FLAVORSEG = 'PLT'		
group by
     t.New_FLAVORSEG, left(a.YYYYMM, 4)
;