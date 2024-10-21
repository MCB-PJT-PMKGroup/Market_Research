/*
 * 20241017 작업 시작
 * 
 *  April 님 Total CC Purchasers 요청건
 * 
 */



------------------------------------------------------------ 20241017 작업


-- user_past_type_M1 CC MLB 용
with temp as (
select  
	t.YYYYMM, 
	t.id,
	b.engname,
	max(cast( case when b.cigatype='HnB' and b.company = 'PMK' then 'PMK HnB'   else '' end as varchar(50) )) A,
	max(cast( case when b.cigatype='CC'  and b.company = 'PMK' then 'PMK CC'    else '' end as varchar(50) )) B,
	max(cast( case when b.cigatype='CC'  and b.company != 'PMK' then 'Comp CC'  else '' end as varchar(50) )) C,
	max(cast( case when b.cigatype='HnB' and b.company != 'PMK' then 'Comp HnB' else '' end as varchar(50) )) D
from cx.agg_LPoint_MLB_SKU_Sourcing t
	join cx.fct_K7_Monthly a on t.id = a.id 
		and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
				 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
	join cx.product_master b on a.Product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
where 1=1 
group BY 	    
	t.YYYYMM, 
	t.id,
	b.engname
)
select 
	YYYYMM,  
	id,
	engname, 
	usage_type
from temp
unpivot (usage_type for company in (A, B, C, D) ) as unpivo
where usage_type != ''
;
;




-- user_current_type_M1 CC MLB 용
with temp as (
select  
	t.YYYYMM,  
	t.id,
	t.engname,
	max(cast( case when b.cigatype='HnB' and b.company = 'PMK' then 'PMK HnB'  else '' end  as varchar(50) )) A,
	max(cast( case when b.cigatype='CC'  and b.company = 'PMK' then 'PMK CC' else '' end as varchar(50) )) B,
	max(cast( case when b.cigatype='CC'  and b.company != 'PMK' then 'Comp CC'  else '' end as varchar(50) )) C,
	max(cast( case when b.cigatype='HnB' and b.company != 'PMK' then 'Comp HnB'  else '' end as varchar(50) )) D
from  cx.agg_LPoint_MLB_SKU_Sourcing t
	join cx.fct_K7_Monthly a on t.id = a.id 
		and a.YYYYMM = t.YYYYMM
	join cx.product_master b on a.Product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
where 1=1 	
group BY 	    	
	t.YYYYMM, 
	t.id,
	t.engname
)
select 
	YYYYMM,  
	id,
	engname, 
	usage_type
from temp
unpivot (usage_type for company in (A, B, C, D) ) as unpivo
where usage_type != ''
;


-- Past Purchase PMK CC , Non-PMK CC
with temp as ( 
	select  
		t.YYYYMM, 
		t.id,
		b.cigatype,
		case when b.company = 'PMK' 
			then 'PMK' 
			else 'Non-PMK'
		END	company,	
		sum(a.pack_qty) pack_qty
	from cx.agg_LPoint_MLB_SKU_Sourcing t
		join cx.fct_K7_Monthly a on t.id = a.id 
			and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
					 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
		join cx.product_master b on a.Product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
	where 1=1 
	group BY 	    
		t.YYYYMM, 
		t.id,
		b.cigatype,
		case when b.company = 'PMK' 
			then 'PMK' 
			else 'Non-PMK'
		END		
)
select t.YYYYMM, company, cigatype,count(distinct t.id) CC_purchasers, sum(Pack_qty) pack 
from temp t
where 1=1  
group by 
	grouping sets ( (t.YYYYMM, company), (t.YYYYMM, company, cigatype ) , (t.YYYYMM) ) 
order by YYYYMM, company;



-- Taste 추가 
with temp as (
	select  
		t.YYYYMM, 
		t.id,
		b.engname,
		b.FLAVORSEG_type3,
		sum(a.pack_qty) pack_qty,
		max(cast( case when b.cigatype='CC'  and b.company = 'PMK' then 'PMK CC'    else '' end as varchar(50) )) 'PMK CC',
		max(cast( case when b.cigatype='CC'  and b.company != 'PMK' then 'Comp CC'  else '' end as varchar(50) )) 'Comp CC',
		max(cast( case when b.cigatype='HnB' then 'HnB' else '' end as varchar(50) )) 'HnB'
	from cx.agg_LPoint_MLB_SKU_Sourcing t
		join cx.fct_K7_Monthly a on t.id = a.id 
			and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
					 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
		join cx.product_master b on a.Product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
	where 1=1 
	group BY 	    
		t.YYYYMM, 
		t.id,
		b.engname,
		b.FLAVORSEG_type3
)
select 
	YYYYMM,  
	id,
	engname, 
	FLAVORSEG_type3,
	pack_qty,
	usage_type
from temp
unpivot (usage_type for company in ([PMK CC], [Comp CC], [HnB]) ) as unpivo
where usage_type != ''
;
;
		



-- monthly CC purchaser 수 
with temp as ( 
	select t.YYYYMM, t.id
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC'
	where t.YYYYMM >= '202408'
	group by t.YYYYMM, t.id
)
select yyyymm, count(distinct id) 'CC Purchasers'
from temp 
group by yyyymm
;


-- monthly HnB purchaser 수 
with temp as ( 
	select t.YYYYMM, t.id
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'HnB'
	where t.YYYYMM >= '202408'
	group by t.YYYYMM, t.id
)
select yyyymm, count(distinct id) 'HnB Purchasers'
from temp 
group by yyyymm
;



-- Total CC gender, age  by purchasers
with CC_Purchaser as ( 
	select t.YYYYMM, t.id, gender, age
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC'
	where t.YYYYMM >= '202408'
	group by t.YYYYMM, t.id, gender, age
)
select t.YYYYMM, 'Total CC Purchasers' ,
	count(distinct t.id) total_Purchaser_cnt, 
	count(case when t.gender ='남' then 1 end ) 'Male',
	count(case when t.gender ='여' then 1 end ) 'Female',
	count(case when t.age in ( '10대','20대') then 1 end) '20s',
	count(case when t.age = '30대' then 1 end) '30s',
	count(case when t.age = '40대' then 1 end) '40s',
	count(case when t.age = '50대' then 1 end) '50s',
	count(case when t.age = '60대' then 1 end) '60s',
	count(case when t.age = '70대' then 1 end) '70s'
--from cx.agg_LPoint_TEREA_SKU_Sourcing  t
from CC_Purchaser  t
where 1=1 	
group by t.YYYYMM
order by  t.YYYYMM;



-- 20241021 작업 Total MLB tar Seg from 202408
with CC_Purchaser as ( 
	select t.YYYYMM, t.id, b.New_TARSEGMENTAT
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC'
	where t.YYYYMM >= '202408'
	group by t.YYYYMM, t.id, b.New_TARSEGMENTAT
)
select t.YYYYMM, 'Total CC Purchasers' ,
	count(distinct t.id) total_Purchaser_cnt, 
	count(case when t.New_TARSEGMENTAT = '1MG'then 1 end ) '1MG',
	count(case when t.New_TARSEGMENTAT = 'Below 1MG' then 1 end) 'Below 1MG',
	count(case when t.New_TARSEGMENTAT = 'FF'then 1 end ) 'FF',
	count(case when t.New_TARSEGMENTAT = 'LTS'then 1 end ) 'LTS',
	count(case when t.New_TARSEGMENTAT = 'ULT'then 1 end ) 'ULT',
	count(case when t.New_TARSEGMENTAT = NULL then 1 end ) 'NULL'
from CC_Purchaser  t
where 1=1 	
group by t.YYYYMM
order by  t.YYYYMM;


-- 과거 구매내역 중 Tar format 
with temp as (
	select  
		t.YYYYMM, 
		t.id,
		b.engname,
		b.ProductFamilyCode,
		b.New_TARSEGMENTAT,
		b.THICKSEG,
		sum(a.pack_qty) pack_qty,
		max(cast( case when b.cigatype='CC'  and b.company = 'PMK' then 'PMK CC'    else '' end as varchar(50) )) 'PMK CC',
		max(cast( case when b.cigatype='CC'  and b.company != 'PMK' then 'Comp CC'  else '' end as varchar(50) )) 'Comp CC',
		max(cast( case when b.cigatype='HnB' then 'HnB' else '' end as varchar(50) )) 'HnB'
	from cx.agg_LPoint_MLB_SKU_Sourcing t
		join cx.fct_K7_Monthly a on t.id = a.id 
			and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
					 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
		join cx.product_master b on a.Product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
	where 1=1 
	group BY 	    
		t.YYYYMM, 
		t.id,
		b.engname,
		b.ProductFamilyCode,
		b.New_TARSEGMENTAT,
		b.THICKSEG
)
select 
	YYYYMM,  
	id,
	engname, 
	New_TARSEGMENTAT,
	THICKSEG,
	pack_qty,
	usage_type
from temp
unpivot (usage_type for company in ([PMK CC], [Comp CC], [HnB]) ) as unpivo
where usage_type != ''
;

-- MLB 제품 구매이력 확인
with temp as (
	select  
		t.YYYYMM, 
		t.id,
		b.engname,
		b.ProductFamilyCode,
		b.New_TARSEGMENTAT,
		b.THICKSEG,
		sum(a.pack_qty) pack_qty,
		max(cast( case when b.cigatype='CC'  and b.company = 'PMK' then 'PMK CC'    else '' end as varchar(50) )) 'PMK CC',
		max(cast( case when b.cigatype='CC'  and b.company != 'PMK' then 'Comp CC'  else '' end as varchar(50) )) 'Comp CC'
	from cx.agg_LPoint_MLB_SKU_Sourcing t
		join cx.fct_K7_Monthly a on t.id = a.id 
			and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
					 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
		join cx.product_master b on a.Product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
	where 1=1 
	group BY 	    
		t.YYYYMM, 
		t.id,
		b.engname,
		b.ProductFamilyCode,
		b.New_TARSEGMENTAT,
		b.THICKSEG
)
select YYYYMM, ProductFamilyCode, count(distinct id) n, sum(pack_qty) pack
from temp 
unpivot (usage_type for company in ([PMK CC], [Comp CC]) ) as unpivo
where usage_type = 'PMK CC' and ProductFamilyCode = 'MLB' and engname like '%Vista%'
group by YYYYMM, ProductFamilyCode


-- MLB tar Seg from 202408
select  
	t.YYYYMM,
	t.engname,
	New_TARSEGMENTAT tar,
	count(distinct case when b.cigatype ='CC' then t.id end) CC,
	count(distinct case when b.cigatype ='HnB' then t.id end) HnB
from  cx.agg_LPoint_MLB_SKU_Sourcing t
	join cx.fct_K7_Monthly a on t.id = a.id 
		and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
				 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
	join cx.product_master b on a.Product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND b.cigatype != 'CSV'  
where 1=1 
group BY 
	t.YYYYMM,
	t.engname,
	concat(FLAVORSEG_type3,' X ', New_TARSEGMENTAT) 
;

select * 
from cx.product_master 
where  ProductFamilyCode = 'MLB'
-- ENGNAME like '%Vista%';


