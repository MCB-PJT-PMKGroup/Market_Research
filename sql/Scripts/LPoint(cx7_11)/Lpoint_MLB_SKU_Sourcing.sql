/*
 * 20241017 작업 시작
 * 
 *  April 님 Total CC Purchasers 요청건
 *  engname ='Marlboro Vista Garden Splash'
 *  engname = 'Marlboro Vista Blossom Mist'
 */

-- # Temp table로 만들어서 사용?
	select
		t.YYYYMM, 
		t.id, 
		max(a.gender) gender,
		max(a.age) age,
	    CASE 
	        WHEN SUM(CASE WHEN b.cigatype = 'CC' and a.YYYYMM = t.YYYYMM THEN 1 ELSE 0 END) > 0 
	         AND SUM(CASE WHEN b.cigatype = 'HnB' and a.YYYYMM = t.YYYYMM THEN 1 ELSE 0 END) > 0 
	        THEN 'Mixed' 
	        ELSE MAX(b.cigatype)  -- CC 또는 HnB가 없을 경우 가장 큰 값을 사용
	    END AS cigatype
	--INTO #Temp_CC_Purchasers
    from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM
		join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND b.cigatype != 'CSV'
	where t.YYYYMM >= '202408'
	group BY t.YYYYMM, t.id
	having sum(pack_qty) > 1;



-- Total CC Demo
with CC_Purchaser as ( 
	select
		t.YYYYMM, 
		t.id, 
		max(a.gender) gender,
		max(a.age) age,
	    CASE 
	        WHEN SUM(CASE WHEN b.cigatype = 'CC' and a.YYYYMM = t.YYYYMM THEN 1 ELSE 0 END) > 0 
	         AND SUM(CASE WHEN b.cigatype = 'HnB' and a.YYYYMM = t.YYYYMM THEN 1 ELSE 0 END) > 0 
	        THEN 'Mixed' 
	        ELSE MAX(b.cigatype)  -- CC 또는 HnB가 없을 경우 가장 큰 값을 사용
	    END AS cigatype
    from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM
		join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND b.cigatype != 'CSV'
	where t.YYYYMM >= '202408'
	group BY t.YYYYMM, t.id
	having sum(pack_qty) > 1
)
select t.YYYYMM, 'Total CC Purchasers', 
	count(*) total_Purchaser_cnt, 
	count(case when t.gender ='남' then 1 end ) 'Male',
	count(case when t.gender ='여' then 1 end ) 'Female',
	count(case when t.age in ( '10대','20대') then 1 end) '20s',
	count(case when t.age = '30대' then 1 end) '30s',
	count(case when t.age = '40대' then 1 end) '40s',
	count(case when t.age = '50대' then 1 end) '50s',
	count(case when t.age = '60대' then 1 end) '60s',
	count(case when t.age = '70대' then 1 end) '70s'
from CC_Purchaser  t
where 1=1 	
group by t.YYYYMM
order by t.YYYYMM;



-- Total CC Tar
with CC_Purchaser as ( 
	select
		t.YYYYMM, 
		t.id, 
		max(a.gender) gender,
		max(a.age) age,
	    CASE 
	        WHEN SUM(CASE WHEN b.cigatype = 'CC' and a.YYYYMM = t.YYYYMM THEN 1 ELSE 0 END) > 0 
	         AND SUM(CASE WHEN b.cigatype = 'HnB' and a.YYYYMM = t.YYYYMM THEN 1 ELSE 0 END) > 0 
	        THEN 'Mixed' 
	        ELSE MAX(b.cigatype)  -- CC 또는 HnB가 없을 경우 가장 큰 값을 사용
	    END AS cigatype
    from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM
		join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV'
	where t.YYYYMM >= '202408'
	group BY t.YYYYMM, t.id
	having sum(pack_qty) > 1
)
select  
	t.YYYYMM,
	New_TARSEGMENTAT tar,
	count(distinct case when b.cigatype ='CC' then t.id end) CC
	--count(distinct case when b.cigatype ='HnB' then t.id end) HnB
from CC_Purchaser t
	join cx.fct_K7_Monthly a on t.id = a.id and a.YYYYMM = t.YYYYMM
	join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV'  
group BY 
	t.YYYYMM,
	New_TARSEGMENTAT
having New_TARSEGMENTAT != '';




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
	join cx.product_master b on a.Product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype = 'CC' 
where t.engname ='Marlboro Vista Blossom Mist'
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
where t.engname = 'Marlboro Vista Blossom Mist'	
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
	where t.engname = 'Marlboro Vista Blossom Mist'
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



-- Taste Seg 추가 
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
	where  t.engname = 'Marlboro Vista Blossom Mist'
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
	count(case when t.New_TARSEGMENTAT = 'ULT'then 1 end ) 'ULT'
from CC_Purchaser  t
where 1=1 	
group by t.YYYYMM
order by t.YYYYMM;



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
		max(cast( case when b.cigatype='CC'  and b.company = 'PMK'  then 'PMK CC'   else '' end as varchar(50) )) 'PMK CC',
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
where usage_type = 'Comp CC' and ProductFamilyCode = 'ESSE' -- and engname like '%CHANGE%'
group by YYYYMM, ProductFamilyCode
;



-- PMK CC 과거 구매내역 
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
select YYYYMM, engname, count(distinct id) n, sum(pack_qty) pack
from temp 
unpivot (usage_type for company in ([PMK CC], [Comp CC]) ) as unpivo
where usage_type = 'Comp CC' and ProductFamilyCode = 'ESSE'  --and engname like '%Vista%'
and YYYYMM = '202401'
group by YYYYMM, engname
;



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




--- 20241022 작업 
--total_Purchaser_cnt	HNB Only	CC & HNB	CC Only	CC Regular	CC Fresh	CC NTD
with CC_Purchaser as ( 
	select
		t.YYYYMM, 
		t.id, 
	    CASE 
	        WHEN SUM(CASE WHEN b.cigatype = 'CC' and a.YYYYMM = t.YYYYMM THEN 1 ELSE 0 END) > 0 
	         AND SUM(CASE WHEN b.cigatype = 'HnB' and a.YYYYMM = t.YYYYMM THEN 1 ELSE 0 END) > 0 
	        THEN 'Mixed' 
	        ELSE MAX(b.cigatype)  -- CC 또는 HnB가 없을 경우 가장 큰 값을 사용
	    END AS cigatype
    from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM
		join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND b.cigatype != 'CSV'
	where t.YYYYMM >= '202408'
	group BY t.YYYYMM, t.id
	having sum(pack_qty) > 1
)
select 	t.YYYYMM,
	count(distinct t.id) total_Purchaser_Cnt,
	count(distinct case when t.cigatype ='CC' then t.id end ) 'CC Only',
	count(distinct case when t.cigatype ='HnB' then t.id end ) 'HnB Only',
	count(distinct case when t.cigatype ='Mixed' then t.id end ) 'Mixed',
	count(distinct case when b.cigatype = 'CC' and FLAVORSEG_type3 ='Fresh' then t.id end ) 'CC Fresh',
	count(distinct case when b.cigatype = 'CC' and FLAVORSEG_type3 ='New Taste' then t.id end ) 'CC New Taste',
	count(distinct case when b.cigatype = 'CC' and FLAVORSEG_type3 ='Regular' then t.id end ) 'CC Regular'
from CC_Purchaser  t
	join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM
	join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND b.cigatype != 'CSV'
where 1=1
group by t.YYYYMM
order by t.YYYYMM;



-- Total CC Pack Volume	HNB Only	CC & HNB	CC Only	CC Regular	CC Fresh	CC NTD
with CC_Purchaser as ( 
	select
		t.YYYYMM, 
		t.id, 
	    CASE 
	        WHEN SUM(CASE WHEN b.cigatype = 'CC' and a.YYYYMM = t.YYYYMM THEN 1 ELSE 0 END) > 0 
	         AND SUM(CASE WHEN b.cigatype = 'HnB' and a.YYYYMM = t.YYYYMM THEN 1 ELSE 0 END) > 0 
	        THEN 'Mixed' 
	        ELSE MAX(b.cigatype)  -- CC 또는 HnB가 없을 경우 가장 큰 값을 사용
	    END AS cigatype
    from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM
		join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND b.cigatype != 'CSV'
	where t.engname = ''
	group BY t.YYYYMM, t.id
	having sum(pack_qty) > 1
)
select 	t.YYYYMM,
	sum(a.Pack_qty) [total # of pack_cnt],
	sum( case when t.cigatype ='CC' then a.Pack_qty else 0 end ) 'CC Only',
	sum( case when t.cigatype ='HnB' then a.Pack_qty else 0 end ) 'HnB Only',
	sum( case when t.cigatype ='Mixed' then a.Pack_qty else 0 end ) 'Mixed',
	sum( case when b.cigatype = 'CC' and FLAVORSEG_type3 ='Fresh' then a.Pack_qty else 0 end ) 'CC Fresh',
	sum( case when b.cigatype = 'CC' and FLAVORSEG_type3 ='New Taste' then a.Pack_qty else 0 end ) 'CC New Taste',
	sum( case when b.cigatype = 'CC' and FLAVORSEG_type3 ='Regular' then a.Pack_qty else 0 end ) 'CC Regular'
from CC_Purchaser  t
	join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM
	join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND b.cigatype != 'CSV'
where 1=1
group by t.YYYYMM
order by t.YYYYMM;



-- Taste YYYYMM	Type	total # of pack_cnt	PMK CC	PMK CC-Regular	PMK CC-Fresh	PMK CC-NTD	Comp. CC- Regular	Comp. CC- Fresh	Comp. CC-NTD	HNB Total
with CC_Purchaser as ( 
	select
		t.YYYYMM, 
		t.id, 
	    CASE 
	        WHEN SUM(CASE WHEN b.cigatype = 'CC' and a.YYYYMM = t.YYYYMM THEN 1 ELSE 0 END) > 0 
	         AND SUM(CASE WHEN b.cigatype = 'HnB' and a.YYYYMM = t.YYYYMM THEN 1 ELSE 0 END) > 0 
	        THEN 'Mixed' 
	        ELSE MAX(b.cigatype)  -- CC 또는 HnB가 없을 경우 가장 큰 값을 사용
	    END AS cigatype
    from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM
		join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND b.cigatype != 'CSV'
	where t.YYYYMM >= '202408'
	group BY t.YYYYMM, t.id
	having sum(pack_qty) > 1
)
, temp as (
	select  
		t.YYYYMM, 
		t.id,
		b.engname,
		b.ProductFamilyCode,
        b.FLAVORSEG_type3,
		b.New_TARSEGMENTAT,
		b.THICKSEG,
		sum(a.pack_qty) pack_qty,
		max(cast( case when b.cigatype='CC'  and b.company = 'PMK' then 'PMK CC'    else '' end as varchar(50) )) 'PMK CC',
		max(cast( case when b.cigatype='CC'  and b.company != 'PMK' then 'Comp CC'  else '' end as varchar(50) )) 'Comp CC',
		max(cast( case when b.cigatype='HnB' then 'HnB' else '' end as varchar(50) )) 'HnB'
	from CC_Purchaser t
		join cx.fct_K7_Monthly a on t.id = a.id and a.YYYYMM = t.YYYYMM	
		join cx.product_master b on a.Product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
	where 1=1 
	group BY 	    
		t.YYYYMM, 
		t.id,
		b.engname,
		b.ProductFamilyCode,
        b.FLAVORSEG_type3,
		b.New_TARSEGMENTAT,
		b.THICKSEG
)
select 
	YYYYMM,  
	id,
	engname, 
	New_TARSEGMENTAT,
    FLAVORSEG_type3,
	THICKSEG,
	pack_qty,
	usage_type
from temp
unpivot (usage_type for company in ([PMK CC], [Comp CC], [HnB]) ) as unpivo
where usage_type != ''
;


-- Tar YYYYMM	Type	total # of pack_cnt	1MG	Below 1MG	FF	LTS	ULT



-- Thickness YYYYMM	Type	total # of pack_cnt	SSL 	STD








-- Cigatype, Taste Total (Taste는 구매자 수가 다를 수 있음. 한 사람이 여러 Taste를 구매)
select 
	t.YYYYMM, t.engname  ,
	count(distinct t.id) total_Purchaser_Cnt,
	count(distinct case when t.cigatype ='CC' then t.id end ) 'CC',
	count(distinct case when t.cigatype ='HnB' then t.id end ) 'HnB',
	count(distinct case when t.cigatype ='Mixed' then t.id end ) 'Mixed',
	count(distinct case when FLAVORSEG_type3 ='Fresh' then t.id end ) 'Fresh Total',
	count(distinct case when FLAVORSEG_type3 ='New Taste' then t.id end ) 'New Taste Total',
	count(distinct case when FLAVORSEG_type3 ='Regular' then t.id end ) 'Regular Total',
	count(distinct case when b.cigatype = 'CC' and FLAVORSEG_type3 ='Fresh' then t.id end ) 'CC Fresh',
	count(distinct case when b.cigatype = 'CC' and FLAVORSEG_type3 ='New Taste' then t.id end ) 'CC New Taste',
	count(distinct case when b.cigatype = 'CC' and FLAVORSEG_type3 ='Regular' then t.id end ) 'CC Regular',
	count(distinct case when b.cigatype = 'HnB' and FLAVORSEG_type3 ='Fresh' then t.id end ) 'HnB Fresh',
	count(distinct case when b.cigatype = 'HnB' and FLAVORSEG_type3 ='New Taste' then t.id end ) 'HnB New Taste',
	count(distinct case when b.cigatype = 'HnB' and FLAVORSEG_type3 ='Regular' then t.id end ) 'HnB Regular'
from  cx.agg_LPoint_MLB_SKU_Sourcing t
	join cx.fct_K7_Monthly a on a.id = t.id 
		and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
				 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
	join cx.product_master b on a.Product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND b.cigatype != 'CSV'
where 1=1 
group BY  t.engname, t.YYYYMM
order by  t.engname, t.YYYYMM
;



-- PMO Qty, CC Taste, HnB Taste, IQOS Qty
SELECT YYYYMM, t.engname ,
    SUM([BAT]) AS BAT,
    SUM([JTI]) AS JTI,
    SUM([KTG]) AS KTG,
    SUM([PMK]) AS PMK,
    SUM([CC Fresh]) AS "CC Fresh",
    SUM([CC New Taste]) AS "CC New Taste",
    SUM([CC Regular]) AS "CC Regular",
    SUM([HnB Fresh]) AS "HnB Fresh",
    SUM([HnB New Taste]) AS "HnB New Taste",
    SUM([HnB Regular]) AS "HnB Regular",
    SUM([AIIM Fresh]) AS "AIIM Fresh",
    SUM([AIIM New Taste]) AS "AIIM New Taste",
    SUM([AIIM Regular]) AS "AIIM Regular",
    SUM([FIIT Fresh]) AS "FIIT Fresh",
    SUM([FIIT New Taste]) AS "FIIT New Taste",
    SUM([HEETS Fresh]) AS "HEETS Fresh",
    SUM([HEETS New Taste]) AS "HEETS New Taste",
    SUM([HEETS Regular]) AS "HEETS Regular",
    SUM([MIIX Fresh]) AS "MIIX Fresh",
    SUM([MIIX New Taste]) AS "MIIX New Taste",
    SUM([MIIX Regular]) AS "MIIX Regular",
    SUM([NEO Fresh]) AS "NEO Fresh",
    SUM([NEO New Taste]) AS "NEO New Taste",
    SUM([NEO Regular]) AS "NEO Regular",
    SUM([NEOSTICKS Fresh]) AS "NEOSTICKS Fresh",
    SUM([NEOSTICKS New Taste]) AS "NEOSTICKS New Taste",
    SUM([NEOSTICKS Regular]) AS "NEOSTICKS Regular",
    SUM([TEREA Fresh]) AS "TEREA Fresh",
    SUM([TEREA New Taste]) AS "TEREA New Taste",
    SUM([TEREA Regular]) AS "TEREA Regular",
    SUM([HEETS AMBER LABEL]) AS "HEETS AMBER LABEL",
    SUM([HEETS BLACK GREEN SELECTION]) AS "HEETS BLACK GREEN SELECTION",
    SUM([HEETS BLACK PURPLE SELECTION]) AS "HEETS BLACK PURPLE SELECTION",
    SUM([HEETS BLUE LABEL]) AS "HEETS BLUE LABEL",
    SUM([HEETS BRONZE LABEL]) AS "HEETS BRONZE LABEL",
    SUM([HEETS GOLD SELECTION]) AS "HEETS GOLD SELECTION",
    SUM([HEETS GREEN LABEL]) AS "HEETS GREEN LABEL",
    SUM([HEETS GREEN ZING]) AS "HEETS GREEN ZING",
    SUM([HEETS PURPLE LABEL]) AS "HEETS PURPLE LABEL",
    SUM([HEETS SATIN WAVE]) AS "HEETS SATIN WAVE",
    SUM([HEETS SILVER LABEL]) AS "HEETS SILVER LABEL",
    SUM([HEETS SUMMER BREEZE]) AS "HEETS SUMMER BREEZE",
    SUM([HEETS TURQUOISE LABEL]) AS "HEETS TURQUOISE LABEL",
    SUM([HEETS YUGEN]) AS "HEETS YUGEN",
    SUM([TEREA AMBER]) AS "TEREA AMBER",
    SUM([TEREA ARBOR PEARL]) AS "TEREA ARBOR PEARL",
    SUM([TEREA BLACK GREEN]) AS "TEREA BLACK GREEN",
    SUM([TEREA BLACK PURPLE]) AS "TEREA BLACK PURPLE",
    SUM([TEREA BLACK YELLOW]) AS "TEREA BLACK YELLOW",
    SUM([TEREA BLUE]) AS "TEREA BLUE",
    SUM([TEREA GREEN]) AS "TEREA GREEN",
    SUM([TEREA GREEN ZING]) AS "TEREA GREEN ZING",
    SUM([TEREA OASIS PEARL]) AS "TEREA OASIS PEARL",
    SUM([TEREA PURPLE WAVE]) AS "TEREA PURPLE WAVE",
    SUM([TEREA RUSSET]) AS "TEREA RUSSET",
    SUM([TEREA SILVER]) AS "TEREA SILVER",
    SUM([TEREA SUMMER WAVE]) AS "TEREA SUMMER WAVE",
    SUM([TEREA SUN PEARL]) AS "TEREA SUN PEARL",
    SUM([TEREA TEAK]) AS "TEREA TEAK",
    SUM([TEREA YUGEN]) AS "TEREA YUGEN"
FROM cx.agg_LPoint_MLB_SKU_Sourcing t
where 1=1 	
GROUP BY t.engname, t.YYYYMM
ORDER BY t.engname, t.YYYYMM
;


-- TEREA flavorXtar from 202211
select  
	t.YYYYMM,
	t.engname,
	concat(FLAVORSEG_type3,' X ', New_TARSEGMENTAT) flavorXtar,
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
