select min(YYYYMM), max(YYYYMM) 
from cx.fct_K7_Monthly ;

-- 통계: 총 개별 구매자수 : 1,651,533
select sum(cust_cnt)
from (
	select count(distinct id) cust_cnt
	from cx.fct_K7_Monthly
	group by id
)as t;

-- 기간별 구매 여부
--select CUST_ID,
--		MAX(CASE WHEN YM_CD = '202301' THEN count(cust_id) ELSE 0 END) AS '202301',
--		MAX(CASE WHEN YM_CD = '202302' THEN SALE_QTY ELSE 0 END) AS '202302',
--		MAX(CASE WHEN YM_CD = '202303' THEN SALE_QTY ELSE 0 END) AS '202303',
--		MAX(CASE WHEN YM_CD = '202304' THEN SALE_QTY ELSE 0 END) AS '202304',
--		MAX(CASE WHEN YM_CD = '202305' THEN SALE_QTY ELSE 0 END) AS '202305',
--		MAX(CASE WHEN YM_CD = '202306' THEN SALE_QTY ELSE 0 END) AS '202306',
--		MAX(CASE WHEN YM_CD = '202307' THEN SALE_QTY ELSE 0 END) AS '202307',
--		MAX(CASE WHEN YM_CD = '202308' THEN SALE_QTY ELSE 0 END) AS '202308',
--		MAX(CASE WHEN YM_CD = '202309' THEN SALE_QTY ELSE 0 END) AS '202309',
--		MAX(CASE WHEN YM_CD = '202310' THEN SALE_QTY ELSE 0 END) AS '202310',
--		MAX(CASE WHEN YM_CD = '202311' THEN SALE_QTY ELSE 0 END) AS '202311',
--		MAX(CASE WHEN YM_CD = '202312' THEN SALE_QTY ELSE 0 END) AS '202312',
--		MAX(CASE WHEN YM_CD = '202401' THEN SALE_QTY ELSE 0 END) AS '202401',
--		MAX(CASE WHEN YM_CD = '202402' THEN SALE_QTY ELSE 0 END) AS '202402',
--		MAX(CASE WHEN YM_CD = '202403' THEN SALE_QTY ELSE 0 END) AS '202403',
--		MAX(CASE WHEN YM_CD = '202404' THEN SALE_QTY ELSE 0 END) AS '202404',
--		MAX(CASE WHEN YM_CD = '202405' THEN SALE_QTY ELSE 0 END) AS '202405'
--from cu.Fct_BGFR_PMI_Monthly
--group by CUST_ID;
--
--select * 
--from cu.Fct_BGFR_PMI_Monthly
--where cust_id ='0fb299313c85a09c94134afb9b634ec8baf878af3c1beb1c9a3561921a42840d'
--and YM_CD = '202301';

-- 구매자별 최초 구매월, 마지막 구매월 및 기간동안 방문 횟수
SELECT 
	id,
	sum(count(id)) over(PARTITION by cust_id) as visit_cnt,
	sum(purchase_cnt) as monthly_buy_CC_cnt,
	min(YYYYMM) 'first_visit', 
	max(YYYYMM) 'last_vist'
FROM  (
	select 
		 id, YYYYMM, count(*) as purchase_cnt
	FROM cx.fct_K7_Monthly
	GROUP BY id, YYYYMM
) as a
GROUP BY id
;


-- 2023.01 ~ 2024.05 기간동안 방문횟수 별 구매자 수 집계
WITH MonthlyPurchases AS (
    SELECT
        id,
        COUNT(DISTINCT YYYYMM) AS visit_cnt,
        MIN(YYYYMM) AS first_visit,
        MAX(YYYYMM) AS last_visit
    FROM  cx.fct_K7_Monthly a
    	join cx.product_master_temp b on a.Product_code = b.prod_id and b.CIGADEVICE ='CIGARETTES' and b.CIGATYPE != 'CSV' and 4 < len(a.id)
    where left(YYYYMM, 4) in ('2023', '2024')
    GROUP BY id
    HAVING MIN(YYYYMM) != MAX(YYYYMM) -- 최소 2번 이상, 다른 월에 구매해야 함.
)
SELECT
    first_visit,
    last_visit,
    visit_cnt,
    COUNT(*) AS total_Purchaser_cnt
FROM MonthlyPurchases
GROUP BY first_visit, last_visit, visit_cnt
;



WITH MonthlyPurchases AS (
    SELECT
        id,
        COUNT(DISTINCT YYYYMM) AS visit_cnt,
        MIN(YYYYMM) AS first_visit,
        MAX(YYYYMM) AS last_visit
    FROM cx.fct_K7_Monthly a
    	join cx.product_master_temp b on a.Product_code = b.prod_id and b.CIGADEVICE ='CIGARETTES' and b.CIGATYPE != 'CSV' and 4 < len(a.id)
    where left(YYYYMM, 4) in ('2023', '2024')
    GROUP BY id
    HAVING MIN(YYYYMM) != MAX(YYYYMM) -- 최소 2번 이상, 다른 월에 구매해야 함.
),
PivotData AS (
    SELECT
        first_visit,
        last_visit,
        COUNT(*) AS total_Purchaser_cnt
    FROM MonthlyPurchases
    GROUP BY first_visit, last_visit
)
SELECT
    first_visit,
    SUM(CASE WHEN last_visit = '202301' THEN total_Purchaser_cnt ELSE 0 END) AS "202301",
    SUM(CASE WHEN last_visit = '202302' THEN total_Purchaser_cnt ELSE 0 END) AS "202302",
	SUM(CASE WHEN last_visit = '202303' THEN total_Purchaser_cnt ELSE 0 END) AS "202303",
    SUM(CASE WHEN last_visit = '202304' THEN total_Purchaser_cnt ELSE 0 END) AS "202304",
	SUM(CASE WHEN last_visit = '202305' THEN total_Purchaser_cnt ELSE 0 END) AS "202305",
    SUM(CASE WHEN last_visit = '202306' THEN total_Purchaser_cnt ELSE 0 END) AS "202306",
	SUM(CASE WHEN last_visit = '202307' THEN total_Purchaser_cnt ELSE 0 END) AS "202307",
    SUM(CASE WHEN last_visit = '202308' THEN total_Purchaser_cnt ELSE 0 END) AS "202308",
	SUM(CASE WHEN last_visit = '202309' THEN total_Purchaser_cnt ELSE 0 END) AS "202309",
    SUM(CASE WHEN last_visit = '202310' THEN total_Purchaser_cnt ELSE 0 END) AS "202310",
	SUM(CASE WHEN last_visit = '202311' THEN total_Purchaser_cnt ELSE 0 END) AS "202311",
    SUM(CASE WHEN last_visit = '202312' THEN total_Purchaser_cnt ELSE 0 END) AS "202312",
	SUM(CASE WHEN last_visit = '202401' THEN total_Purchaser_cnt ELSE 0 END) AS "202401",
    SUM(CASE WHEN last_visit = '202402' THEN total_Purchaser_cnt ELSE 0 END) AS "202402",
	SUM(CASE WHEN last_visit = '202403' THEN total_Purchaser_cnt ELSE 0 END) AS "202403",
    SUM(CASE WHEN last_visit = '202404' THEN total_Purchaser_cnt ELSE 0 END) AS "202404",
    SUM(CASE WHEN last_visit = '202405' THEN total_Purchaser_cnt ELSE 0 END) AS "202405"
FROM PivotData
GROUP BY first_visit
ORDER BY first_visit;