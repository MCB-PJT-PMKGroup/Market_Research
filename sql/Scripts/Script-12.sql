
-- distinct 구매자 추출 연습 .. pack 구매수량 공식? a.SALE_QTY * b.sal_qnt
select 'Number of total tobacco purchaser',
	count(distinct a.id) as "Total Tobacco",
	count(distinct case when b.CIGATYPE='CC' then a.id else null end) AS "Total CC",
	count(distinct case when b.CIGATYPE='HnB' then a.id else null end) AS "Total HnB"
from  bpda.cx.fct_K7_Monthly a
JOIN bpda.cx.product_master_temp b ON a.product_code = b.PROD_ID
WHERE 1=1
    and b.ENGNAME != 'Cleaning Stick'
    AND b.cigatype != 'CSV'
    AND 4 < LEN(a.id)
    AND a.YYYYMM ='202403'
;


select 'Number of total tobacco packs',
	round(sum(a.buy_ct * b.sal_qnt), 2) as "Total Tobacco",
	round(sum(case when b.CIGATYPE='CC' then a.buy_ct * b.sal_qnt else null end), 2) AS "Total CC",
	round(sum(case when b.CIGATYPE='HnB' then a.buy_ct * b.sal_qnt else null end), 2) AS "Total HnB"
from  bpda.cx.fct_K7_Monthly a
JOIN bpda.cx.product_master_temp b ON a.product_code = b.PROD_ID
WHERE 1=1
    and b.ENGNAME != 'Cleaning Stick'
    AND b.cigatype != 'CSV'
    AND 4 < LEN(a.id)
    AND a.YYYYMM ='202403'
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
select 
	avg("Total Tabcco"*1.0) 									as avg_tabcco,
	avg(case when "Total CC" != 0 then "Total CC"*1.0 end)  	as avg_CC,
	avg(case when "Total HnB" != 0 then "Total HnB" *1.0 end) 	as avg_HnB
from ( 
	select a.cust_id,
		count(a.cust_id) as "Total Tabcco",
		count(case when b.CIGATYPE='CC' then a.cust_id else null end) AS "Total CC",
		count(case when b.CIGATYPE='HnB' then a.cust_id else null end) AS "Total HnB"
	FROM 
	    cu.BGFR_PMI_202403 a
	    	JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
	WHERE 
	    b.ENGNAME != 'Cleaning Stick' AND b.cigatype != 'CSV' 
	group by a.cust_id 
)as t
;

-- Average number of packs purchased per purchaser 
select 
	avg("Total Tabcco"*1.0) 									as avg_tabcco,
	avg(case when "Total CC" != 0 then "Total CC"*1.0 end)  	as avg_CC,
	avg(case when "Total HnB" != 0 then "Total HnB" *1.0 end) 	as avg_HnB
from ( 
	select a.cust_id,
		sum(a.SALE_QTY * b.sal_qnt) as "Total Tabcco",
		sum(case when b.CIGATYPE='CC' then a.SALE_QTY * b.sal_qnt else null end) AS "Total CC",
		sum(case when b.CIGATYPE='HnB' then a.SALE_QTY * b.sal_qnt else null end) AS "Total HnB"
	FROM 
	    cu.BGFR_PMI_202403 a
	    	JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
	WHERE 
	    b.ENGNAME != 'Cleaning Stick' AND b.cigatype != 'CSV' 
	group by a.cust_id 
)as t
;

-- Gender
select 
	case 
		when a.GENDER_CD = 1 then 'Male'
		else  'Female'
	end as 'Gender',
	count(distinct a.cust_id) as "Total Tabcco",
	count(distinct case when b.CIGATYPE='CC' then a.cust_id else null end) AS "Total CC",
	count(distinct case when b.CIGATYPE='HnB' then a.cust_id else null end) AS "Total HnB"
from  
	bpda.cx.fct_K7_Monthly a
		JOIN bpda.cx.product_master_temp b ON a.product_code = b.PROD_ID
	WHERE 1=1
	    and b.CIGADEVICE = 'CIGARETTES'
	    AND b.cigatype != 'CSV'
	    AND 4 < LEN(a.id)
	    AND a.YYYYMM ='202403'
group by a.GENDER_CD ;


-- Age
select 
	case 
		when a.age = '10대' then 'Age - Under LA29 (10 ~ 14세)'
		when a.age = '20대' then 'Age - LA29'
		when a.age = '30대' then 'Age - 3039'
		when a.age = '40대' then 'Age - 4049'
		when a.age in ('50대', '60대','70대')  then 'Age - 50+'
		else a.age
	end as 'Age',
	count(distinct a.id) as "Total Tabcco",
	count(distinct case when b.CIGATYPE='CC' then a.id else null end) AS "Total CC",
	count(distinct case when b.CIGATYPE='HnB' then a.id else null end) AS "Total HnB"
from  
	cx.K7_202403 a
		JOIN bpda.cx.product_master_temp b ON a.product_code = b.PROD_ID
	WHERE 1=1
	    and b.CIGADEVICE = 'CIGARETTES'
	    AND b.cigatype != 'CSV'
group by 	
	case 
		when a.age = '10대' then 'Age - Under LA29 (10 ~ 14세)'
		when a.age = '20대' then 'Age - LA29'
		when a.age = '30대' then 'Age - 3039'
		when a.age = '40대' then 'Age - 4049'
		when a.age in ('50대', '60대','70대')  then 'Age - 50+'
		else a.age
	end  ;


-- Number of packs purchased - N pack purchaser
select a.buy_ct,
	count(distinct a.id) as "Total Tabcco",
	count(distinct case when b.CIGATYPE='CC' then a.id else null end) AS "Total CC",
	count(distinct case when b.CIGATYPE='HnB' then a.id else null end) AS "Total HnB"
	from  bpda.cx.fct_K7_Monthly a
	JOIN bpda.cx.product_master_temp b ON a.product_code = b.PROD_ID
	WHERE 1=1
	    and b.CIGADEVICE = 'CIGARETTES'
	    AND b.cigatype != 'CSV'
	    AND 4 < LEN(a.id)
	    AND a.YYYYMM ='202403'
group by a.buy_ct ;


-- Number of SKU purchased - N SKU purchaser
with temp as (
	select 	
		case 
			when count(distinct b.PROD_ID ) = 1 then 'Number of SKU purchased - 1 SKU purchaser'
			when count(distinct b.PROD_ID ) = 2 then 'Number of SKU purchased - 2 SKU purchaser'
			when count(distinct b.PROD_ID ) = 3 then 'Number of SKU purchased - 3 SKU purchaser'
			when count(distinct b.PROD_ID ) = 4 then 'Number of SKU purchased - 4 SKU purchaser'
			when count(distinct b.PROD_ID ) > 4  then 'Number of SKU purchased - 5 SKU + purchaser'
		end as "SKU" ,
		count(distinct a.id) as "Total Tabcco",
		count(distinct case when b.CIGATYPE='CC' then a.id else null end) AS "Total CC",
		count(distinct case when b.CIGATYPE='HnB' then a.id else null end) AS "Total HnB"
	from  bpda.cx.fct_K7_Monthly a
	JOIN bpda.cx.product_master_temp b ON a.product_code = b.PROD_ID
	WHERE 1=1
	    and b.CIGADEVICE = 'CIGARETTES'
	    AND b.cigatype != 'CSV'
	    AND 4 < LEN(a.id)
	    AND a.YYYYMM ='202403'
	group by a.id ,
		case 
			when count(distinct b.PROD_ID ) = 1 then 'Number of SKU purchased - 1 SKU purchaser'
			when count(distinct b.PROD_ID ) = 2 then 'Number of SKU purchased - 2 SKU purchaser'
			when count(distinct b.PROD_ID ) = 3 then 'Number of SKU purchased - 3 SKU purchaser'
			when count(distinct b.PROD_ID ) = 4 then 'Number of SKU purchased - 4 SKU purchaser'
			when count(distinct b.PROD_ID ) > 4  then 'Number of SKU purchased - 5 SKU + purchaser'
		end
)
select 
	 "SKU",
	sum("Total Tabcco") as "Total Tabcco",
	sum("Total CC") as "Total CC",
	sum("Total HnB") as "Total HnB"
from temp
group by SKU
;
