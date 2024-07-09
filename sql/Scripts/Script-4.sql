
-- distinct 구매자 추출 연습
select 'Number of total tobacco purchaser',
	count(distinct a.cust_id) as "Total Tobacco",
	count(distinct case when b.CIGATYPE='CC' then a.cust_id else null end) AS "Total CC",
	count(distinct case when b.CIGATYPE='HnB' then a.cust_id else null end) AS "Total HnB"
FROM 
    cu.BGFR_PMI_202303 a
    	JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
WHERE 
    b.ENGNAME != 'Cleaning Stick' AND b.cigatype != 'CSV'
union
select 'Number of total tobacco packs',
	round(sum(a.SALE_QTY * b.sal_qnt), 2) as "Total Tobacco",
	round(sum(case when b.CIGATYPE='CC' then a.SALE_QTY * b.sal_qnt else null end), 2) AS "Total CC",
	round(sum(case when b.CIGATYPE='HnB' then a.SALE_QTY * b.sal_qnt else null end), 2) AS "Total HnB"
FROM 
    cu.BGFR_PMI_202303 a
    	JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
WHERE 
    b.ENGNAME != 'Cleaning Stick' AND b.cigatype != 'CSV'
;


    
    
    
    
-- 855,123 구매자 수     "Number of total tobacco purchasers"  "Number of total tobacco packs"
SELECT 
    'Total Tobacco' AS Category,
    count(distinct a.cust_id) AS "Number of total tobacco purchasers",
    ROUND(SUM(CASE WHEN b.CIGATYPE IS NOT NULL THEN a.SALE_QTY * b.sal_qnt ELSE 0 END), 2) AS "Number of total tobacco packs"
FROM 
    cu.BGFR_PMI_202303 a
    JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
WHERE 
    b.ENGNAME != 'Cleaning Stick' AND b.cigatype != 'CSV'
UNION ALL
SELECT 
    'Total CC' AS Category,
    count(distinct case when b.CIGATYPE='CC' then a.cust_id else null end) AS "Number of total tobacco purchasers",
    ROUND(SUM(CASE WHEN b.CIGATYPE = 'CC' THEN a.SALE_QTY * b.sal_qnt ELSE 0 END), 2) AS "Number of total tobacco packs"
FROM 
    cu.BGFR_PMI_202303 a
    JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
WHERE 
    b.ENGNAME != 'Cleaning Stick' AND b.cigatype != 'CSV'
UNION ALL
SELECT 
    'Total HnB' AS Category,
    count(distinct case when b.CIGATYPE='HnB' then a.cust_id else null end) AS "Number of total tobacco purchasers",
    ROUND(SUM(CASE WHEN b.CIGATYPE = 'HnB' THEN a.SALE_QTY * b.sal_qnt ELSE 0 END), 2) AS "Number of total tobacco packs"
FROM 
    cu.BGFR_PMI_202303 a
    JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
WHERE 
    b.ENGNAME != 'Cleaning Stick' AND b.cigatype != 'CSV';

   
-- Average number of visit per purchaser
with temp as (
select a.cust_id
	, count(*) as visit_cnt
FROM 
    cu.BGFR_PMI_202303 a
    	JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
WHERE 
    b.ENGNAME != 'Cleaning Stick' AND b.cigatype != 'CSV' 
group by a.cust_id 
)
select visit_cnt, count(*) as count, visit_cnt * count(*) as total
	--cast(avg(visit_cnt) as numeric(10,2)), max(visit_cnt), min(visit_cnt)
from temp 
group by visit_cnt;



