/*
 * 	Top 6 스위칭 작업
 *  20241024 작업 시작
 * 	24Q2 vs 24Q3 분기 별 스위칭 작업 
 * 
 *  ('202404', '202405', '202406', '202407', '202408', '202409')
 */
---------------------------------------------------------------------- 2023 4분기 vs 2024 1분기  --------------------------------------------------------------------------------------------

-- 2023 4분기, 2024 1분기
select distinct left(YYYYMM, 4), datepart(QUARTER,  CAST(YYYYMM+'01' AS DATE))
from cx.fct_K7_Monthly
where 1=1 
group by left(YYYYMM, 4), datepart(QUARTER,  CAST(YYYYMM+'01' AS DATE))
having (left(YYYYMM, 4) = '2023' and datepart(QUARTER,  CAST(YYYYMM+'01' AS DATE)) = 4 ) or ( left(YYYYMM, 4) = '2024' and datepart(QUARTER,  CAST(YYYYMM+'01' AS DATE)) =1 )
;

-- 스위칭 모수
--insert into cx.agg_top6_Switch_23Q4_24Q1
--insert into cx.agg_top6_Switch_24Q2_24Q3
SELECT 
	a.id,
	b.ProductFamilyCode, 
	sum(case when a.YYYYMM between '202404' and '202406' then  a.pack_qty else 0 end) as [Out],
	sum(case when a.YYYYMM between '202407' and '202409' then  a.pack_qty else 0 end) as [In]
--into cx.agg_top6_Switch_23Q4_24Q1
FROM 
    cx.fct_K7_Monthly a
    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
where 1=1
   	and a.YYYYMM in ('202404', '202405', '202406', '202407', '202408', '202409')
   	-- Top 5 제품군 대상
	and ProductFamilyCode = 'RAISON'-- in ('ESSE', 'DUNHILL', 'MEVIUS', 'MLB' , 'RAISON') PLT 추가
    --2023 Q4, 2024 Q1년 모두 구매한 사람은 제외
    and a.id not in (
	    SELECT 
			x.id
        FROM cx.fct_K7_Monthly x
        	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
		where 1=1
		   	and x.YYYYMM in  ('202404', '202405', '202406', '202407', '202408', '202409')
			and y.ProductFamilyCode = b.ProductFamilyCode
		GROUP BY 
		    y.ProductFamilyCode, x.id
		HAVING 
		    -- 2023 Q4, 2024 Q1 모두 구매한 사람
		    (SUM(CASE WHEN x.YYYYMM between '202404' and '202406' THEN 1 ELSE 0 END) > 0
		    AND SUM(CASE WHEN x.YYYYMM between '202407' and '202409' THEN 1 ELSE 0 END) > 0)
	)
GROUP BY 
     a.id ,b.ProductFamilyCode
HAVING
    -- Out :  2023 Q4 에 구매했지만, 2024 Q1도에는 해당 제품을 구매하지 않아 Out
	(SUM(CASE WHEN  a.YYYYMM between '202404' and '202406' THEN 1 ELSE 0 END) > 0
	and SUM(CASE WHEN  a.YYYYMM between '202407' and '202409' THEN 1 ELSE 0 END) = 0
    AND EXISTS (
		-- 2024 Q1에는 다른 제품을 구매한 사람
	    SELECT 1
	    FROM cx.fct_K7_Monthly x
	    	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
	    where a.id = x.id and x.YYYYMM between '202407' and '202409'
		and y.ProductFamilyCode != b.ProductFamilyCode
    	)
	)
	OR
    -- In :  2023 Q4 구매하지 않고, 2024 Q1도에는 해당 제품을 구매하여 IN
    (SUM(CASE WHEN  a.YYYYMM between '202407' and '202409' THEN 1 ELSE 0 END) > 0
    AND SUM(CASE WHEN a.YYYYMM between '202404' and '202406' THEN 1 ELSE 0 END) = 0 
    AND EXISTS (
    	-- 2023 Q4에 다른 제품을 구매한 사람
	    SELECT 1
	    FROM cx.fct_K7_Monthly x
	    	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
	    where a.id = x.id and x.YYYYMM between '202404' and '202406'
	    and y.ProductFamilyCode != b.ProductFamilyCode 
    	)
    )
;


-- 데이터 검증
select productFamilyCode, count(*)
--from cx.agg_top5_Switch_2022_2023
from cx.agg_top6_Switch_23Q4_24Q1 
group by productFamilyCode;


select ProductFamilyCode , count(distinct id), sum([out]), sum([In])
from cx.agg_top6_Switch_23Q4_24Q1 
group by ProductFamilyCode


-- cigatype, Taste, Tar CC Switching 작업
select  
	b.cigatype,	
	b.New_FLAVORSEG,
	b.New_TARSEGMENTAT,
	count(distinct case when a.YYYYMM between '202401' and '202403' and t.[out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(distinct case when a.YYYYMM between '202310' and '202312' and t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	'',
	'',
	'',
	sum(case 
		when a.YYYYMM between '202401' and '202403' and t.[Out] > 0 then a.pack_qty else 0 end )as Out_quantity,
	sum(case 
		when  a.YYYYMM between '202310' and '202312' and t.[In] > 0 then a.pack_qty else 0 end) as In_quantity
from 
	cx.agg_top6_Switch_23Q4_24Q1 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) 
			and a.YYYYMM in ('202404', '202405', '202406', '202407', '202408', '202409')
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
			and t.ProductFamilyCode != b.ProductFamilyCode
WHERE t.ProductFamilyCode = 'PLT'
group by grouping sets ((b.cigatype, b.New_FLAVORSEG, b.New_TARSEGMENTAT),  (b.cigatype, b.New_FLAVORSEG),  (b.cigatype), ())
;

-- SKU 별 Switching In/Out
select
	b.cigatype,
	b.Engname,
	b.New_Flavorseg,
	b.New_Tarsegmentat,
	b.THICKSEG,
	count(DISTINCT case when a.YYYYMM between '202401' and '202403' and t.[Out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(DISTINCT case when a.YYYYMM between '202310' and '202312' and t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	'',
	'',
	'',
	sum(case when a.YYYYMM between '202401' and '202403' and t.[Out] > 0 then a.Pack_qty else 0 end ) as Out_Quantity,
	sum(case when a.YYYYMM between '202310' and '202312' and t.[In] > 0 then a.Pack_qty else 0 end ) as In_Quantity
from cx.agg_top6_Switch_23Q4_24Q1  t
	join cx.fct_K7_Monthly a on t.id = a.id and 4 < len(a.id) 
		and a.YYYYMM in  ('202404', '202405', '202406', '202407', '202408', '202409')
	join cx.product_master_temp b on a.Product_code = b.prod_id and b.CIGADEVICE ='CIGARETTES' and b.CIGATYPE != 'CSV' 	
		AND b.ProductFamilyCode != t.ProductFamilyCode
WHERE t.ProductFamilyCode = 'PLT'
group by grouping sets ((b.cigatype, b.Engname, b.New_Flavorseg, b.New_Tarsegmentat, b.THICKSEG), (b.cigatype), ())
;
	   



-- ('ESSE', 'DUNHILL', 'MEVIUS', 'MLB' , 'RAISON')
-- 구매자, 구매팩수 총 카운트
select 
	ProductFamilyCode,
	left(a.yyyymm,4) year,
	datepart(QUARTER,  CAST(a.YYYYMM+'01' AS DATE)) quarter,
	COUNT(distinct id ) Purchaser_Cnt,
	sum( a.pack_qty) as Total_Pack_Cnt
FROM 
	cx.fct_K7_Monthly a
    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)   
    	AND b.ProductFamilyCode = 'PLT'
where 1=1
   	and a.YYYYMM in ('202404', '202405', '202406', '202407', '202408', '202409')
GROUP BY 
	ProductFamilyCode, left(a.YYYYMM, 4), datepart(QUARTER,  CAST(YYYYMM+'01' AS DATE))
;

    
-- In/Out별 구매자수, 총 구매 팩수 
select  
	t.ProductFamilyCode, 
	left(a.yyyymm,4) year,
	datepart(QUARTER,  CAST(a.YYYYMM+'01' AS DATE)) quarter,
	count(DISTINCT case when t.[Out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(DISTINCT case when t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	sum(case when t.[Out] > 0 then a.pack_qty end ) as Out_Quantity,
	sum(case when t.[In] > 0 then a.pack_qty end ) as In_Quantity
from 
	cx.agg_top6_Switch_23Q4_24Q1 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) 
			and a.YYYYMM in ('202404', '202405', '202406', '202407', '202408', '202409')
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
			and t.ProductFamilyCode = b.ProductFamilyCode
where t.ProductFamilyCode = 'PLT'		
group by
     t.ProductFamilyCode, left(a.YYYYMM, 4), datepart(QUARTER,  CAST(YYYYMM+'01' AS DATE))
;