
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
	
