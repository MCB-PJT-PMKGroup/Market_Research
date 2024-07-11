-- Pack 구매수량 공식 : a.SALE_QTY * b.sal_qnt
-- Number of total tobacco purchaser
-- Number of total tobacco packs
select 'Number of total tobacco purchaser',
	count(distinct a.cust_id) as "Total Tobacco",
	count(distinct case when b.CIGATYPE='CC' then a.cust_id else null end) AS "Total CC",
	count(distinct case when b.CIGATYPE='HnB' then a.cust_id else null end) AS "Total HnB"
FROM 
    cu.BGFR_PMI_202403 a
    	JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
WHERE 
    b.CIGADEVICE =  'CIGARETTES' AND b.cigatype != 'CSV'
union
select 'Number of total tobacco packs',
	round(sum(a.SALE_QTY * b.sal_qnt), 2) as "Total Tobacco",
	round(sum(case when b.CIGATYPE='CC' then a.SALE_QTY * b.sal_qnt else null end), 2) AS "Total CC",
	round(sum(case when b.CIGATYPE='HnB' then a.SALE_QTY * b.sal_qnt else null end), 2) AS "Total HnB"
FROM 
    cu.BGFR_PMI_202403 a
    	JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
WHERE 
    b.CIGADEVICE =  'CIGARETTES' AND b.cigatype != 'CSV'
;



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
	    b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
	group by a.cust_id 
)as t
;

-- Average number of packs purchased per purchaser 
select 
	avg("Total Tabcco" * 1.0) 									as avg_tabcco,
	avg(case when "Total CC" != 0 then "Total CC" * 1.0 end)  	as avg_CC,
	avg(case when "Total HnB" != 0 then "Total HnB"  * 1.0 end) as avg_HnB
from ( 
	select a.cust_id,
		sum(a.SALE_QTY * b.sal_qnt) as "Total Tabcco",
		sum(case when b.CIGATYPE='CC' then a.SALE_QTY * b.sal_qnt else null end) AS "Total CC",
		sum(case when b.CIGATYPE='HnB' then a.SALE_QTY * b.sal_qnt else null end) AS "Total HnB"
	FROM 
	    cu.BGFR_PMI_202403 a
	    	JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
	WHERE 
	    b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
	group by a.cust_id 
)as t
;


-- Gender
select 
	case 
		when a.GENDER_CD = 1 then 'Male'
		else 'Female'
	end as 'Gender',
	count(distinct a.cust_id) as "Total Tabcco",
	count(distinct case when b.CIGATYPE='CC' then a.cust_id else null end) AS "Total CC",
	count(distinct case when b.CIGATYPE='HnB' then a.cust_id else null end) AS "Total HnB"
FROM 
    cu.BGFR_PMI_202403 a
    	JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
WHERE 
    b.CIGADEVICE =  'CIGARETTES' AND b.cigatype != 'CSV' 
group by a.GENDER_CD ;


-- Age
select 
	case 
		when a.AGE_CD = 1 then 'Age - Under LA29 (10 ~ 14세)'
		when a.AGE_CD = 2 then 'Age - LA29'
		when a.AGE_CD = 3 then 'Age - 3039'
		when a.AGE_CD = 4 then 'Age - 4049'
		when a.AGE_CD in (5, 6) then 'Age - 50+'
	end as 'Age',
	count(distinct a.cust_id) as "Total Tabcco",
	count(distinct case when b.CIGATYPE='CC' then a.cust_id else null end) AS "Total CC",
	count(distinct case when b.CIGATYPE='HnB' then a.cust_id else null end) AS "Total HnB"
FROM 
    cu.BGFR_PMI_202403 a
    	JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
WHERE 
     b.CIGADEVICE =  'CIGARETTES' AND b.cigatype != 'CSV' 
group by 	
	case 
		when a.AGE_CD = 1 then 'Age - Under LA29 (10 ~ 14세)'
		when a.AGE_CD = 2 then 'Age - LA29'
		when a.AGE_CD = 3 then 'Age - 3039'
		when a.AGE_CD = 4 then 'Age - 4049'
		when a.AGE_CD in (5, 6) then 'Age - 50+'
	end
;


-- Number of packs purchased - N pack purchaser
select 
	case	
		when a.SALE_QTY = 1 then 'Number of packs purchased - 1 pack purchaser'
		when a.SALE_QTY = 2 then 'Number of packs purchased - 2 pack purchaser'
		when a.SALE_QTY = 3 then 'Number of packs purchased - 3 pack purchaser'
		when a.SALE_QTY = 4 then 'Number of packs purchased - 4 pack purchaser'
		when a.SALE_QTY = 5 then 'Number of packs purchased - 5 pack purchaser'
		when a.SALE_QTY = 6 then 'Number of packs purchased - 6 pack purchaser'
		when a.SALE_QTY = 7 then 'Number of packs purchased - 7 pack purchaser'
		when a.SALE_QTY = 8 then 'Number of packs purchased - 8 pack purchaser'
		when a.SALE_QTY = 9 then 'Number of packs purchased - 9 pack purchaser'
		when a.SALE_QTY = 10 then 'Number of packs purchased - 10 pack purchaser'
		when a.SALE_QTY between 11 and 20 then 'Number of packs purchased - 11~20 pack purchaser'
		when a.SALE_QTY > 20 then 'Number of packs purchased - 21 + pack purchaser'
	end as "Pack Qty",
	count(distinct a.cust_id) 												AS "Total Tabcco",
	count(distinct case when b.CIGATYPE='CC' then a.cust_id else null end) 	AS "Total CC",
	count(distinct case when b.CIGATYPE='HnB' then a.cust_id else null end) AS "Total HnB"
FROM 
    cu.BGFR_PMI_202403 a
    	JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
WHERE 
    b.CIGADEVICE =  'CIGARETTES' AND b.cigatype != 'CSV' 
group by 	
	case	
		when a.SALE_QTY = 1 then 'Number of packs purchased - 1 pack purchaser'
		when a.SALE_QTY = 2 then 'Number of packs purchased - 2 pack purchaser'
		when a.SALE_QTY = 3 then 'Number of packs purchased - 3 pack purchaser'
		when a.SALE_QTY = 4 then 'Number of packs purchased - 4 pack purchaser'
		when a.SALE_QTY = 5 then 'Number of packs purchased - 5 pack purchaser'
		when a.SALE_QTY = 6 then 'Number of packs purchased - 6 pack purchaser'
		when a.SALE_QTY = 7 then 'Number of packs purchased - 7 pack purchaser'
		when a.SALE_QTY = 8 then 'Number of packs purchased - 8 pack purchaser'
		when a.SALE_QTY = 9 then 'Number of packs purchased - 9 pack purchaser'
		when a.SALE_QTY = 10 then 'Number of packs purchased - 10 pack purchaser'
		when a.SALE_QTY between 11 and 20 then 'Number of packs purchased - 11~20 pack purchaser'
		when a.SALE_QTY > 20 then 'Number of packs purchased - 21 + pack purchaser'
	end 
;


-- Number of SKU purchased - N SKU purchaser
with temp as (
	select 	
		case 
			when count(distinct b.PROD_ID ) = 1 then 'Number of SKU purchased - 1 SKU purchaser'
			when count(distinct b.PROD_ID ) = 2 then 'Number of SKU purchased - 2 SKU purchaser'
			when count(distinct b.PROD_ID ) = 3 then 'Number of SKU purchased - 3 SKU purchaser'
			when count(distinct b.PROD_ID ) = 4 then 'Number of SKU purchased - 4 SKU purchaser'
			when count(distinct b.PROD_ID ) > 4 then 'Number of SKU purchased - 5 SKU + purchaser'
		end as "SKU" ,
		count(distinct a.cust_id) as "Total Tabcco",
		count(distinct case when b.CIGATYPE='CC' then a.cust_id else null end) AS "Total CC",
		count(distinct case when b.CIGATYPE='HnB' then a.cust_id else null end) AS "Total HnB"
	FROM 
	    cu.BGFR_PMI_202403 a
	    	JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
	WHERE 
	     b.CIGADEVICE =  'CIGARETTES' AND b.cigatype != 'CSV' 
	group by a.cust_id 
)
select 
	 "SKU",
	sum("Total Tabcco") as "Total Tabcco",
	sum("Total CC") 	as "Total CC",
	sum("Total HnB") 	as "Total HnB"
from temp
group by SKU
;


-- Category



--  TMO Total
select 
	'TMO Total' as Category,
	b.Company, 
	round(sum(a.SALE_QTY * b.sal_qnt), 2) as 'Number of Pack',
	count(distinct a.CUST_ID) as 'Number of Purchaser' 
FROM 
    cu.BGFR_PMI_202403 a
    	JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
WHERE 
     b.CIGADEVICE =  'CIGARETTES' AND b.cigatype != 'CSV' 
group by company
union 
select 
	'CC - TMO',
	b.Company, 
	round( sum(case when b.CIGATYPE ='CC' then a.SALE_QTY * b.sal_qnt end), 2) as 'Number of Pack',
	count(distinct case when b.CIGATYPE ='CC' then a.CUST_ID end)  as 'Number of Purchaser' 
FROM 
    cu.BGFR_PMI_202403 a
    	JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
WHERE 
     b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype = 'CC'
group by company
union
select 
	'CC - Flavour',
	b.New_FLAVORSEG , 
	round( sum(case when b.CIGATYPE ='CC' then a.SALE_QTY * b.sal_qnt end), 2) as 'Number of Pack',
	count(distinct case when b.CIGATYPE ='CC' then a.CUST_ID end)  as 'Number of Purchaser' 
FROM 
    cu.BGFR_PMI_202403 a
    	JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
WHERE 
     b.CIGADEVICE =  'CIGARETTES' AND b.cigatype = 'CC'
group by b.New_FLAVORSEG 
union
select 
	'CC - Tar',
	b.New_TARSEGMENTAT , 
	round( sum(case when b.CIGATYPE ='CC' then a.SALE_QTY * b.sal_qnt end), 2) as 'Number of Pack',
	count(distinct case when b.CIGATYPE ='CC' then a.CUST_ID end)  as 'Number of Purchaser' 
FROM 
    cu.BGFR_PMI_202403 a
    	JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
WHERE 
     b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype = 'CC' 
     and New_TARSEGMENTAT is not null
group by b.New_TARSEGMENTAT 
union
select 
	'CC - Product Family',
	b.ProductFamilyCode , 
	round( sum(case when b.CIGATYPE ='CC' then a.SALE_QTY * b.sal_qnt end), 2) as 'Number of Pack',
	count(distinct case when b.CIGATYPE ='CC' then a.CUST_ID end)  as 'Number of Purchaser' 
FROM 
    cu.BGFR_PMI_202403 a
    	JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
WHERE 
     b.CIGADEVICE =  'CIGARETTES' AND b.cigatype = 'CC'
group by b.ProductFamilyCode 
;



select 
	'HnB - TMO',
	b.Company, 
	round( sum(case when b.CIGATYPE ='HnB' then a.SALE_QTY * b.sal_qnt end), 2) as 'Number of Pack',
	count(distinct case when b.CIGATYPE ='HnB' then a.CUST_ID end)  as 'Number of Purchaser' 
FROM 
    cu.BGFR_PMI_202403 a
    	JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
WHERE 
     b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype = 'HnB'
group by company
union
select 
	'HnB - Flavour',
	b.New_FLAVORSEG , 
	round( sum(case when b.CIGATYPE ='HnB' then a.SALE_QTY * b.sal_qnt end), 2) as 'Number of Pack',
	count(distinct case when b.CIGATYPE ='HnB' then a.CUST_ID end)  as 'Number of Purchaser' 
FROM 
    cu.BGFR_PMI_202403 a
    	JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
WHERE 
     b.CIGADEVICE =  'CIGARETTES' AND b.cigatype = 'HnB'
group by b.New_FLAVORSEG 
union
select 
	'HnB - Product Sub Family',
	b.ProductSubFamilyCode , 
	round( sum(case when b.CIGATYPE ='HnB' then a.SALE_QTY * b.sal_qnt end), 2) as 'Number of Pack',
	count(distinct case when b.CIGATYPE ='HnB' then a.CUST_ID end)  as 'Number of Purchaser' 
FROM 
    cu.BGFR_PMI_202403 a
    	JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
WHERE 
     b.CIGADEVICE =  'CIGARETTES' AND b.cigatype = 'HnB'
group by b.ProductSubFamilyCode 
;


select 
	'HnB - NPL',
	b.ENGNAME , 
	round( sum(case when b.cigatype != 'CSV' then a.SALE_QTY * b.sal_qnt end), 2) as 'Number of Pack',
	count(distinct case when b.cigatype != 'CSV' then a.CUST_ID end)  as 'Number of Purchaser' 
FROM 
    cu.BGFR_PMI_202403 a
    	JOIN cu.dim_cu_master b ON a.ITEM_CD = b.PROD_ID 
WHERE 
     b.CIGADEVICE =  'CIGARETTES' AND b.cigatype != 'CSV' and b.ProductFamilyCode in ('IQOS', 'MLB')
group by b.ENGNAME ;

