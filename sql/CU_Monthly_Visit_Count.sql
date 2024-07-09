select min(YM_CD), max(YM_CD) 
from cu.Fct_BGFR_PMI_Monthly;

-- 통계: 총 개별 구매자수 : 3,214,905
select sum(cust_cnt)
from (
	select count(distinct CUST_ID) cust_cnt
	from cu.Fct_BGFR_PMI_Monthly
	group by CUST_ID
)as t;

-- 기간별 구매 여부
select CUST_ID,
		MAX(CASE WHEN YM_CD = '202301' THEN count(cust_id) ELSE 0 END) AS '202301',
		MAX(CASE WHEN YM_CD = '202302' THEN SALE_QTY ELSE 0 END) AS '202302',
		MAX(CASE WHEN YM_CD = '202303' THEN SALE_QTY ELSE 0 END) AS '202303',
		MAX(CASE WHEN YM_CD = '202304' THEN SALE_QTY ELSE 0 END) AS '202304',
		MAX(CASE WHEN YM_CD = '202305' THEN SALE_QTY ELSE 0 END) AS '202305',
		MAX(CASE WHEN YM_CD = '202306' THEN SALE_QTY ELSE 0 END) AS '202306',
		MAX(CASE WHEN YM_CD = '202307' THEN SALE_QTY ELSE 0 END) AS '202307',
		MAX(CASE WHEN YM_CD = '202308' THEN SALE_QTY ELSE 0 END) AS '202308',
		MAX(CASE WHEN YM_CD = '202309' THEN SALE_QTY ELSE 0 END) AS '202309',
		MAX(CASE WHEN YM_CD = '202310' THEN SALE_QTY ELSE 0 END) AS '202310',
		MAX(CASE WHEN YM_CD = '202311' THEN SALE_QTY ELSE 0 END) AS '202311',
		MAX(CASE WHEN YM_CD = '202312' THEN SALE_QTY ELSE 0 END) AS '202312',
		MAX(CASE WHEN YM_CD = '202401' THEN SALE_QTY ELSE 0 END) AS '202401',
		MAX(CASE WHEN YM_CD = '202402' THEN SALE_QTY ELSE 0 END) AS '202402',
		MAX(CASE WHEN YM_CD = '202403' THEN SALE_QTY ELSE 0 END) AS '202403',
		MAX(CASE WHEN YM_CD = '202404' THEN SALE_QTY ELSE 0 END) AS '202404',
		MAX(CASE WHEN YM_CD = '202405' THEN SALE_QTY ELSE 0 END) AS '202405'
from cu.Fct_BGFR_PMI_Monthly
group by CUST_ID;

select * 
from cu.Fct_BGFR_PMI_Monthly
where cust_id ='0fb299313c85a09c94134afb9b634ec8baf878af3c1beb1c9a3561921a42840d'
and YM_CD = '202301';

-- 구매자별 최초 구매월, 마지막 구매월 및 기간동안 방문 횟수
SELECT 
	CUST_ID,
	sum(count(cust_id)) over(PARTITION by cust_id) as visit_cnt,
	sum(purchase_cnt) as monthly_buy_CC_cnt,
	min(YM_CD) 'first_visit', 
	max(YM_CD) 'last_vist'
FROM  (
	select 
		CUST_ID, YM_CD, count(*) as purchase_cnt
	FROM  cu.Fct_BGFR_PMI_Monthly
	GROUP BY CUST_ID, YM_CD
) as a
GROUP BY CUST_ID
;


-- 2023.01 ~ 2024.05 기간동안 방문횟수 별 구매자 수 집계
with MonthlyPurchases as(
	SELECT 
		CUST_ID,
		sum(count(cust_id)) over(PARTITION by cust_id) as monthly_visit_cnt, 
		min(YM_CD) 'first_visit', 
		max(YM_CD) 'last_vist'
	FROM  (
		select 
			CUST_ID, YM_CD, count(*) as purchase_cnt
		FROM  cu.Fct_BGFR_PMI_Monthly
		GROUP BY CUST_ID, YM_CD
	) as a
	GROUP BY CUST_ID
)
select 
	monthly_visit_cnt, 
	count(monthly_visit_cnt) as total_Purchaser_cnt, 
from MonthlyPurchases
group by monthly_visit_cnt
;

-- 데이터 검증
select * 
from cu.Fct_BGFR_PMI_Monthly
where cust_id ='b283e27edf50a7c1f1e0e88ffdb6159d8f9da52bcfbf3c525a63707ebe7515b3';



select * 
from cu.dim_CU_master dcm ;
where PROD_ID ='0000088022994';


alter table cx.fct_K7_Monthly add pack_qty float null;

update cx.fct_K7_Monthly 
SET 
from cx.fct_K7_Monthly