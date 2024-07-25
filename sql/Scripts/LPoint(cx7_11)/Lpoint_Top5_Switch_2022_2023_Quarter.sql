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
-- 대상 제품군 개수 참고
--ESSE 총 25종 제품
select  ProductFamilyCode , ProductSubFamilyCode ,count(*)
from bpda.cx.product_master_temp
where ProductFamilyCode in ('ESSE', 'DUNHILL', 'MEVIUS', 'MLB' , 'RAISON')
group by ProductFamilyCode, ProductSubFamilyCode;


-- 2023 4분기, 2024 1분기
select distinct left(YYYYMM, 4), datepart(QUARTER,  CAST(YYYYMM+'01' AS DATE))
from cx.fct_K7_Monthly
where (left(YYYYMM, 4) = '2023' and datepart(QUARTER,  CAST(YYYYMM+'01' AS DATE)) = 4 ) or ( left(YYYYMM, 4) = '2024' and datepart(QUARTER,  CAST(YYYYMM+'01' AS DATE)) =1 )
;


-- CC 시장내 Top5 대상 : 391,076 rows
--insert into cx.agg_top5_Switch_2022_2023
SELECT 
    a.product_code,
	a.id,
	b.ProductFamilyCode, 
	b.tarinfo,
	b.New_TARSEGMENTAT,
	sum(case when left(a.YYYYMM, 4) = '2022' then a.buy_ct * a.pack_qty else 0 end) as [Out],
	sum(case when left(a.YYYYMM, 4) = '2023' then a.buy_ct * a.pack_qty else 0 end) as [In]
--into cx.agg_top5_Switch_2022_2023_temp
FROM 
    cx.fct_K7_Monthly a
     	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id) 
     	-- Top 5 제품군 대상
		-- in ('ESSE', 'DUNHILL', 'MEVIUS', 'MLB' , 'RAISON')
    	and b.ProductFamilyCode = 'ESSE'
where 1=1
   	and left(a.YYYYMM, 4) in ('2022', '2023')
    --2022, 2023년 모두 구매한 사람은 제외
    and a.id not in (
	    SELECT 
			x.id
        FROM cx.fct_K7_Monthly x
        	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id) 
	       	-- Top 5 제품군 대상
			-- in ('ESSE', 'DUNHILL', 'MEVIUS', 'MLB' , 'RAISON')
        	and y.ProductFamilyCode = 'ESSE' 
		where 1=1
		   	and left(x.YYYYMM, 4) in ('2022', '2023')
		GROUP BY 
		    y.cigatype, y.ProductFamilyCode, x.id
		HAVING 
		    -- 2023년, 2022년에 모두 구매함	
		    (SUM(CASE WHEN left(x.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) > 0
		    AND SUM(CASE WHEN left(x.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0)
	)
GROUP BY 
    a.product_code, a.id ,b.ProductFamilyCode, b.tarinfo , b.New_TARSEGMENTAT
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

select productFamilyCode, count(*)
--from cx.agg_top5_Switch_2022_2023
from cx.agg_top5_Switch_23Q4_24Q1 
group by productFamilyCode;
-- IN/Out 대상자 수
--ESSE	116,315
--MLB	76,066
--MEVIUS	73,861
--RAISON	68,468
--DUNHILL	56,366

-- 분기별 구매 건 수
--ESSE	39717
--MLB	24700
--MEVIUS	24382
--RAISON	22774
--DUNHILL	16586

select ProductFamilyCode , count(distinct id), sum([out]), sum([In])
from cx.agg_top5_Switch_23Q4_24Q1 
group by ProductFamilyCode
;
-- 구매자 수
--DUNHILL	14894
--ESSE		33778
--MEVIUS	21032
--MLB		21921
--RAISON	20098

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
	cx.agg_top5_Switch_2022_2023 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') 
			and a.product_code not in( t.product_code)		-- 다른 제품만 추출
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
WHERE t.ProductFamilyCode = 'RAISON'
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
from cx.agg_top5_Switch_2022_2023  t
	join cx.fct_K7_Monthly a on t.id = a.id and 4 < len(a.id) and left(a.YYYYMM, 4) in ('2022', '2023')  
	join cx.product_master_temp b on a.Product_code = b.prod_id and b.CIGADEVICE ='CIGARETTES' and b.CIGATYPE != 'CSV' and b.prod_id not in(t.product_code)
WHERE t.ProductFamilyCode = 'RAISON'
group by grouping sets ((b.cigatype, b.Engname, b.New_Flavorseg, b.New_Tarsegmentat, b.THICKSEG), (b.cigatype), ())
;

-- 구매자, 구매팩수 총 카운트
select 
	ProductFamilyCode,
	left(a.yyyymm,4) year,
	COUNT(distinct id ) Purchaser_Cnt,
	sum(a.buy_ct * a.pack_qty) as Total_Pack_Cnt
FROM 
	cx.fct_K7_Monthly a
    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
where 1=1
   	and left(a.YYYYMM, 4) in ('2022', '2023')
    AND b.ProductFamilyCode = 'RAISON'
GROUP BY 
	ProductFamilyCode, left(a.YYYYMM, 4)
;

    
-- In/Out별 구매자수, 총 구매 팩수 
select  
	t.ProductFamilyCode, 
	left(a.yyyymm,4) year,
	count(DISTINCT case when t.[Out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(DISTINCT case when t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	sum(case when t.[Out] > 0 then a.buy_ct * a.pack_qty end ) as Out_Quantity,
	sum(case when t.[In] > 0 then a.buy_ct * a.pack_qty end ) as In_Quantity
from 
	cx.agg_top5_Switch_2022_2023 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') and a.product_code = t.product_code
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV'
where t.ProductFamilyCode = 'RAISON'		
group by
     t.ProductFamilyCode, left(a.YYYYMM, 4)
;

-- 데이터 검증
select product_code , sum([Out]) sum_out, sum([In]) sum_in
from cx.agg_top5_Switch_2022_2023
group by product_code ;


---------------------------------------------------------------------- 2023 4분기 vs 2024 1분기  --------------------------------------------------------------------------------------------

-- 2023 4분기, 2024 1분기
select distinct left(YYYYMM, 4), datepart(QUARTER,  CAST(YYYYMM+'01' AS DATE))
from cx.fct_K7_Monthly
where 1=1 
group by left(YYYYMM, 4), datepart(QUARTER,  CAST(YYYYMM+'01' AS DATE))
having (left(YYYYMM, 4) = '2023' and datepart(QUARTER,  CAST(YYYYMM+'01' AS DATE)) = 4 ) or ( left(YYYYMM, 4) = '2024' and datepart(QUARTER,  CAST(YYYYMM+'01' AS DATE)) =1 )
;

-- CC 시장내 Top5 대상 : 38,386 rows
--insert into cx.agg_top5_Switch_23Q4_24Q1
SELECT 
    a.product_code,
	a.id,
	b.ProductFamilyCode, 
	b.tarinfo,
	b.New_TARSEGMENTAT,
	sum(case when a.YYYYMM between '202310' and '202312' then a.buy_ct * a.pack_qty else 0 end) as [Out],
	sum(case when a.YYYYMM between '202401' and '202403' then a.buy_ct * a.pack_qty else 0 end) as [In]
--into cx.agg_top5_Switch_23Q4_24Q1
FROM 
    cx.fct_K7_Monthly a
    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
where 1=1
   	and a.YYYYMM in ('202310', '202311', '202312', '202401', '202402', '202403')
   	-- Top 5 제품군 대상
	and ProductFamilyCode = 'RAISON'-- in ('ESSE', 'DUNHILL', 'MEVIUS', 'MLB' , 'RAISON')
    --2023 Q4, 2024 Q1년 모두 구매한 사람은 제외
    and a.id not in (
	    SELECT 
			x.id
        FROM cx.fct_K7_Monthly x
        	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
		where 1=1
		   	and x.YYYYMM in ('202310', '202311', '202312', '202401', '202402', '202403')
			and y.ProductFamilyCode = 'RAISON' -- in ('ESSE', 'DUNHILL', 'MEVIUS', 'MLB' , 'RAISON')
		GROUP BY 
		    y.cigatype, y.ProductFamilyCode, x.id
		HAVING 
		    -- 2023 Q4, 2024 Q1 모두 구매한 사람
		    (SUM(CASE WHEN x.YYYYMM between '202310' and '202312' THEN 1 ELSE 0 END) > 0
		    AND SUM(CASE WHEN x.YYYYMM between '202401' and '202403' THEN 1 ELSE 0 END) > 0)
	)
GROUP BY 
    a.product_code, a.id ,b.ProductFamilyCode, b.tarinfo , b.New_TARSEGMENTAT
HAVING
    -- Out :  2023 Q4 에 구매했지만, 2024 Q1도에는 해당 제품을 구매하지 않아 Out
	(SUM(CASE WHEN  a.YYYYMM between '202310' and '202312' THEN 1 ELSE 0 END) > 0
	and SUM(CASE WHEN  a.YYYYMM between '202401' and '202403' THEN 1 ELSE 0 END) = 0
    AND EXISTS (
		-- 2024 Q1에는 다른 제품을 구매한 사람
	    SELECT 1
	    FROM cx.fct_K7_Monthly x
	    	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
	    where a.id = x.id and x.YYYYMM between '202401' and '202403'
		and x.product_code != a.product_code 
    	)
	)
	OR
    -- In :  2023 Q4 구매하지 않고, 2024 Q1도에는 해당 제품을 구매하여 IN
    (SUM(CASE WHEN  a.YYYYMM between '202401' and '202403' THEN 1 ELSE 0 END) > 0
    AND SUM(CASE WHEN a.YYYYMM between '202310' and '202312' THEN 1 ELSE 0 END) = 0 
    AND EXISTS (
    	-- 2023 Q4에 다른 제품을 구매한 사람
	    SELECT 1
	    FROM cx.fct_K7_Monthly x
	    	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
	    where a.id = x.id and x.YYYYMM between '202310' and '202312'
	    and x.product_code != a.product_code 
    	)
    )
;


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
		when a.YYYYMM between '202401' and '202403' and t.[Out] > 0 then a.buy_ct * a.pack_qty end )as Out_quantity,
	sum(case 
		when  a.YYYYMM between '202310' and '202312' and t.[In] > 0 then a.buy_ct * a.pack_qty end) as In_quantity
from 
	cx.agg_top5_Switch_23Q4_24Q1 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) 
			and a.YYYYMM in ('202310', '202311', '202312', '202401', '202402', '202403')
			and a.product_code not in( t.product_code)		-- 다른 제품만 추출
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
WHERE t.ProductFamilyCode = 'RAISON'
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
	sum(case when a.YYYYMM between '202401' and '202403' and t.[Out] > 0 then a.buy_ct * a.Pack_qty end ) as Out_Quantity,
	sum(case when a.YYYYMM between '202310' and '202312' and t.[In] > 0 then a.buy_ct * a.Pack_qty end ) as In_Quantity
from cx.agg_top5_Switch_23Q4_24Q1  t
	join cx.fct_K7_Monthly a on t.id = a.id and 4 < len(a.id) 
		and a.YYYYMM in ('202310', '202311', '202312', '202401', '202402', '202403')
		and a.product_code not in(t.product_code) 
	join cx.product_master_temp b on a.Product_code = b.prod_id and b.CIGADEVICE ='CIGARETTES' and b.CIGATYPE != 'CSV'  
	AND b.ProductFamilyCode != t.ProductFamilyCode
WHERE t.ProductFamilyCode = 'RAISON'
group by grouping sets ((b.cigatype, b.Engname, b.New_Flavorseg, b.New_Tarsegmentat, b.THICKSEG), (b.cigatype), ())
;
	   



-- ('ESSE', 'DUNHILL', 'MEVIUS', 'MLB' , 'RAISON')
-- 구매자, 구매팩수 총 카운트
select 
	ProductFamilyCode,
	left(a.yyyymm,4) year,
	datepart(QUARTER,  CAST(a.YYYYMM+'01' AS DATE)) quarter,
	COUNT(distinct id ) Purchaser_Cnt,
	sum(a.buy_ct * a.pack_qty) as Total_Pack_Cnt
FROM 
	cx.fct_K7_Monthly a
    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)   
    	AND b.ProductFamilyCode = 'ESSE'
where 1=1
   	and a.YYYYMM in ('202310', '202311', '202312', '202401', '202402', '202403')
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
	sum(case when t.[Out] > 0 then a.buy_ct * a.pack_qty end ) as Out_Quantity,
	sum(case when t.[In] > 0 then a.buy_ct * a.pack_qty end ) as In_Quantity
from 
	cx.agg_top5_Switch_23Q4_24Q1 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) 
			and a.YYYYMM in ('202310', '202311', '202312', '202401', '202402', '202403')
			and a.product_code = t.product_code
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
where t.ProductFamilyCode = 'ESSE'		
group by
     t.ProductFamilyCode, left(a.YYYYMM, 4), datepart(QUARTER,  CAST(YYYYMM+'01' AS DATE))
;