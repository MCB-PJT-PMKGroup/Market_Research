/* 작업 시작일 2024.08.02
 * 
CC Switching 2023 vs. 2022 Regular Taste CC
CC Switching 2023 vs. 2022 NTD Taste CC
CC Switching 2023 vs. 2022 Fresh Taste CC
*/

-- CC 대상 Taste 별 제품 개수 참고
select  FLAVORSEG_type3  ,count(*)
from bpda.cx.product_master
where  CIGADEVICE =  'CIGARETTES' AND  cigatype = 'HnB'
group by FLAVORSEG_type3;
-- 대상 개수
--NULL	6
--Fresh	40
--New Taste	113
--Regular	140

-- 모수 테이블 생성
insert into cx.agg_CC_Taste_Switch_2022_2023
SELECT 
    a.id,
	b.FLAVORSEG_type3, b.cigatype,
	sum(case when left(a.YYYYMM, 4) = '2022' then a.pack_qty else 0 end) as [Out],
	sum(case when left(a.YYYYMM, 4) = '2023' then a.pack_qty else 0 end) as [In]
--into cx.agg_CC_Taste_Switch_2022_2023
FROM 
    cx.fct_K7_Monthly a
     	join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype = 'HnB'			-- Taste 별 제품군 대상
		--  ('Regular', 'New Taste', 'Fresh') in FLAVORSEG_type3
    	and b.FLAVORSEG_type3 = 'Regular' 
where 1=1
   	and left(a.YYYYMM, 4) in ('2022', '2023')
    --2022, 2023년 모두 구매한 사람은 제외
    and a.id not in (
	    SELECT 
			x.id
        FROM cx.fct_K7_Monthly x
        	join cx.product_master y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' 
        	and y.FLAVORSEG_type3 = b.FLAVORSEG_type3 and y.cigatype = b.cigatype
		where 1=1
		   	and left(x.YYYYMM, 4) in ('2022', '2023')
		GROUP BY 
		    y.FLAVORSEG_type3, y.cigatype, x.id
		HAVING 
		    -- 2023년, 2022년에 모두 구매함	
		    (SUM(CASE WHEN left(x.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) > 0
		    AND SUM(CASE WHEN left(x.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0)
	)
GROUP BY 
     a.id ,b.FLAVORSEG_type3, b.cigatype
HAVING
    -- Out : 2022년도에는 구매했지만 2023년도에는 해당 제품을 구매하지 않아 Out
	(SUM(CASE WHEN  left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0
	and SUM(CASE WHEN  left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) = 0
    AND EXISTS (
		-- 2023년에는 다른 제품을 구매한 사람
	    SELECT 1
	    FROM cx.fct_K7_Monthly x
	    	join cx.product_master y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' 
	    where a.id = x.id and left(x.YYYYMM, 4) = '2023'
	    and not (y.FLAVORSEG_type3 = b.FLAVORSEG_type3 and y.cigatype = b.cigatype)
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
	    	join cx.product_master y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' 
	    where a.id = x.id and left(x.YYYYMM, 4) = '2022'
	    and not (y.FLAVORSEG_type3 = b.FLAVORSEG_type3 and y.cigatype = b.cigatype)
    	)
    )
;


-- 데이터 검증
select FLAVORSEG_type3, count(*)
from cx.agg_CC_Taste_Switch_2022_2023 
group by FLAVORSEG_type3;
--New Taste	93904
--Regular	87373
--Fresh		46140

select FLAVORSEG_type3 , count(distinct id), sum([out]), sum([In])
from cx.agg_CC_Taste_Switch_2022_2023 
group by FLAVORSEG_type3
;
--Fresh		46140	77996.0		63172.0
--New Taste	93904	165817.0	217345.0
--Regular	87373	180396.0	142163.0




-- cigatype, Taste, Tar CC Switching 작업
select  
	b.cigatype,	
	b.FLAVORSEG_type3,
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
	cx.agg_CC_Taste_Switch_2022_2023 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') 
		join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
			and not (t.FLAVORSEG_type3 = b.FLAVORSEG_type3 and t.cigatype = b.cigatype)
WHERE t.cigatype ='HnB' and t.FLAVORSEG_type3 = 'Fresh' 
group by grouping sets ((b.cigatype, b.FLAVORSEG_type3, b.New_TARSEGMENTAT),  (b.cigatype, b.FLAVORSEG_type3),  (b.cigatype), ())
;

-- SKU 별 Switching In/Out
select
	b.cigatype,
	b.Engname,
	b.FLAVORSEG_type3,
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
	cx.agg_CC_Taste_Switch_2022_2023  t
		join cx.fct_K7_Monthly a on t.id = a.id and 4 < len(a.id) and left(a.YYYYMM, 4) in ('2022', '2023')  
		join cx.product_master b on a.Product_code = b.prod_id and b.CIGADEVICE ='CIGARETTES' and b.CIGATYPE != 'CSV' 
			and not (t.FLAVORSEG_type3 = b.FLAVORSEG_type3 and t.cigatype = b.cigatype)
WHERE  t.cigatype ='HnB' and t.FLAVORSEG_type3 = 'Fresh' 
group by grouping sets ((b.cigatype, b.Engname, b.FLAVORSEG_type3, b.New_Tarsegmentat, b.THICKSEG), (b.cigatype), ())
;


-- 구매자, 구매팩수 총 카운트
select 
	b.FLAVORSEG_type3,
	b.cigatype,
	left(a.yyyymm,4) year,
	COUNT(distinct id ) Purchaser_Cnt,
	sum(  a.pack_qty) as Total_Pack_Cnt
FROM 
	cx.fct_K7_Monthly a
    	join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV'
where 1=1
   	and left(a.YYYYMM, 4) in ('2022', '2023')
GROUP BY 
	b.FLAVORSEG_type3, b.cigatype, left(a.YYYYMM, 4)
;

    
-- In/Out별 구매자수, 총 구매 팩수 
select  
	t.FLAVORSEG_type3, 
	t.cigatype,
	left(a.yyyymm,4) year,
	count(DISTINCT case when t.[Out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(DISTINCT case when t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	sum(case when t.[Out] > 0 then  a.pack_qty else 0 end ) as Out_Quantity,
	sum(case when t.[In] > 0 then  a.pack_qty else 0 end ) as In_Quantity
from 
	cx.agg_CC_Taste_Switch_2022_2023 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') 
		join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV'
			and (t.FLAVORSEG_type3 = b.FLAVORSEG_type3 and t.cigatype = b.cigatype)
where 1=1 --t.cigatype ='HnB'		
group by
     t.FLAVORSEG_type3, t.cigatype, left(a.YYYYMM, 4)
order by cigatype, FLAVORSEG_type3 , year
;