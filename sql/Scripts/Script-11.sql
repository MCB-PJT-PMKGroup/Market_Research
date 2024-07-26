
select * 
from cx.fct_K7_Monthly a
	join cx.product_master_temp b on a.product_code = b.PROD_ID 
where a.id ='02FD41C35BE3C4B2429822E810D9B345DDA1923ABAE29D9692C4CE3617A21605'
 ;
 

select * from cx.agg_top5_Switch_2022_2023 
where id ='B12FC43F4D92EBC1B16FD26C88559A23B27C1E36223BB4AF6AF113DD260755AF';

select * from cx.agg_top5_Switch_2022_2023 
where ProductFamilyCode = 'ESSE';

select * from cx.product_master_temp
where New_FLAVORSEG ='New Taste' and New_TARSEGMENTAT ='Below 1MG';

TRUNCATE table cx.agg_top5_Switch_23Q4_24Q1 ;

select id, product_code ,  left(yyyymm, 4)
from cx.fct_K7_Monthly 
where product_code in ('8801116036028',
'8801116036066')
and  left(yyyymm, 4) in ('2022', '2023')
group by id ,product_code, left(yyyymm, 4)
;

-- Taste 방식 나눌 방법..
select * from cx.product_master_temp 
where New_FLAVORSEG = 'New Taste'
and ProductFamilyCode  in ('ESSE', 'DUNHILL', 'MEVIUS', 'MLB' , 'RAISON') ;

select 	 
	left(YYYYMM, 4), 
	datepart(QUARTER,  CAST(YYYYMM+'01' AS DATE)) , 
	COUNT(distinct id ) Purchaser_Cnt,
	sum(a.buy_ct * a.pack_qty) as Total_Pack_Cnt 
from 
	cx.fct_K7_Monthly a 
	join cx.product_master_temp b on a.Product_code = b.prod_id and b.CIGADEVICE ='CIGARETTES' and b.CIGATYPE != 'CSV'  AND b.ProductFamilyCode = 'ESSE'
where 4 < len(a.id) 
	and (left(YYYYMM, 4) = '2023' and datepart(QUARTER,  CAST(YYYYMM+'01' AS DATE)) = 4 )
group by left(YYYYMM, 4), datepart(QUARTER,  CAST(YYYYMM+'01' AS DATE)) ;

-- 구매자수 맞추기
select  THICKSEG , FLAVORSEG_type6 , count(distinct id) purchaser, count(*) cnt
FROM cx.agg_CC_SSL_Switch_2022_2023
where id = 'FFB2F9C2B43CA42F790C8F08ED5C8A1EFB83F8103EC8A389315B67E5DE98F28F'
group by  THICKSEG , FLAVORSEG_type6 ;






select * from cx.agg_CC_SSL_Switch_2022_2023 
where id ='06440923F0D2849349FFDC2B19748FEAED7AABE11CBFC63B9E3933C3E150FA33'



-- 이렇게 되면 안되는데.. 
--F2361A0FA156E99A5B51703D06279EC52EBE62159A67E6FB2EC4E0AEBDDD0325	202303	NEOSTIKS BRIGHT TOBACCO	SSL	Regular
--F2361A0FA156E99A5B51703D06279EC52EBE62159A67E6FB2EC4E0AEBDDD0325	202210	NEOSTIKS BRIGHT TOBACCO	SSL	Regular
select a.id, YYYYMM, b.engname ,THICKSEG, FLAVORSEG_type6
from cx.fct_K7_Monthly a
	join cx.product_master_temp b on a.Product_code = b.prod_id and b.CIGADEVICE ='CIGARETTES' and b.CIGATYPE != 'CSV'  
where id in ('014A68DB2DADF339E14D236BDD30D0F76AE12BED50C381625CC331462E7A764E')
and left(a.YYYYMM, 4) in ('2022', '2023')
order by YYYYMM desc;

select * from cx.agg_CC_SSL_Switch_2022_2023 
where THICKSEG is null;
-- F798FAB927F1D3FD4DA33666A340769E43118DC71644522340EE554AEE441824 얘는 포함되야 하는데...

-- 9AC3EA3C276E5E3B726AA0D2DB55BCA42E55D20044C1057FCC302C7EE5836E71
--100,044
SELECT 
	b.THICKSEG,
	FLAVORSEG_type6, id
FROM cx.fct_K7_Monthly a
	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype = 'CC' AND 4 < LEN(a.id) 
	and b.THICKSEG in ('SSL', 'SLI', 'MSL') and b.FLAVORSEG_type6 = 'Regular'
where 1=1
   	and left(a.YYYYMM, 4) in ('2022', '2023')
GROUP BY          
	b.THICKSEG,
	FLAVORSEG_type6, id
HAVING 
	(SUM(CASE WHEN  left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0
	and SUM(CASE WHEN  left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) = 0
    AND EXISTS (
		-- 2023년에는 다른 제품을 구매한 사람
	    SELECT 1
	    FROM cx.fct_K7_Monthly x
	    	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' AND y.cigatype != 'CSV' AND 4 < LEN(x.id)
	    where a.id = x.id and left(x.YYYYMM, 4) = '2023'
		and (y.THICKSEG != b.THICKSEG or y.FLAVORSEG_type6 != b.FLAVORSEG_type6) 		-- 이게 맞아?
    	)
	)
;
select * from cx.fct_K7_Monthly a
	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id) 
where a.id ='E7CCC6D905BE1F82DF41D89A608FAA332CA2C0DA871857DF44D8B6FD4CC0E289';

create index ix_fct_K7_Monthly_product_code on cx.fct_K7_Monthly  (product_code) include(id, YYYYMM);

-- 구매자, 구매팩수 총 카운트
select 
    case when b.THICKSEG = 'SLI' then 'SSL'
		when b.THICKSEG = 'MSL' then 'SSL'
		else b.THICKSEG
	end THICKSEG, 
	b.FLAVORSEG_type6,
	left(a.yyyymm,4) year,
	COUNT(distinct id ) Purchaser_Cnt,
	sum(a.buy_ct * a.pack_qty) as Total_Pack_Cnt
FROM 
	cx.fct_K7_Monthly a
    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
    	AND b.THICKSEG in ('SSL', 'SLI','MSL') and b.FLAVORSEG_type6 = 'Fresh to New Taste'
where 1=1
   	and left(a.YYYYMM, 4) in ('2022', '2023')
GROUP BY 
    case when b.THICKSEG = 'SLI' then 'SSL'
		when b.THICKSEG = 'MSL' then 'SSL'
		else b.THICKSEG
	end, b.FLAVORSEG_type6, left(a.YYYYMM, 4)
;

    
-- In/Out별 구매자수, 총 구매 팩수 
select  
	 case when b.THICKSEG = 'SLI' then 'SSL'
		when b.THICKSEG = 'MSL' then 'SSL'
		else b.THICKSEG
	end THICKSEG, 
	b.FLAVORSEG_type6,
	left(a.yyyymm,4) year,
	count(DISTINCT case when t.[Out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(DISTINCT case when t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	sum(case when t.[Out] > 0 then a.buy_ct * a.pack_qty end ) as Out_Quantity,
	sum(case when t.[In] > 0 then a.buy_ct * a.pack_qty end ) as In_Quantity
from 
	cx.agg_CC_SSL_Switch_2022_2023 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') 
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV'
			and b.THICKSEG = t.THICKSEG  and t.FLAVORSEG_type6 = b.FLAVORSEG_type6 
where t.THICKSEG in ('SSL', 'MSL' ,'SLI') and t.FLAVORSEG_type6 = 'Regular'	
group by
    case when b.THICKSEG = 'SLI' then 'SSL'
		when b.THICKSEG = 'MSL' then 'SSL'
		else b.THICKSEG
	end, b.FLAVORSEG_type6, left(a.YYYYMM, 4)
;

delete 
from cx.agg_CC_KS_SSL_Switch_2022_2023
where THICKSEG = 'SSL';


insert into  cx.agg_CC_KS_SSL_Switch_2022_2023
select 
product_code,
id,
'All' ProductFamilyCode,
THICKSEG,
FLAVORSEG_type6,
[Out],
[In]
from cx.agg_CC_SSL_Switch_2022_2023 