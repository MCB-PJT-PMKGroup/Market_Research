/* -- 2024.09.03 작업 시작
 * -	monthly tobacco purchaser 수 (2022년 1월~)
-	monthly cc purchaser 수
-	monthly NTD cc purchaser 수 (3-TYPE Flavour seg 기준 NTD입니다)
-	첨부파일의 제품들의 출시 첫 달부터 purchaser 수
-	첨부파일의 제품들의 출시 첫 달부터 재구매 purchaser 수 (해당 제품 2팩이상 구매자)

-	monthly tobacco pack 수
-	monthly cc pack 수
-	monthly NTD cc pack 수
-	첨부파일의 제품들의 출시 첫 달부터 pack 수
-	첨부파일의 제품들의 출시 첫 달부터 재구매 pack 수 (해당 제품 2팩이상 구매자)

 */


-- monthly tobacco purchaser 수 (2022년 1월~)
select t.YYYYMM, count(distinct t.id) Purchasers
from cx.v_user_3month_list t
	join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
	join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE != 'CSV'
where t.YYYYMM >= '202201'
group by t.YYYYMM;


-- monthly cc purchaser 수
select t.YYYYMM, count(distinct t.id) Purchasers
from cx.v_user_3month_list t
	join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
	join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC'
where t.YYYYMM >= '202201'
group by t.YYYYMM;


-- monthly NTD cc purchaser 수 (3-TYPE Flavour seg 기준 NTD입니다)
select t.YYYYMM, count(distinct t.id) Purchasers
from cx.v_user_3month_list t
	join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
	join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC' and FLAVORSEG_type3 ='New Taste'
where t.YYYYMM >= '202201'
group by t.YYYYMM;


--	첨부파일의 제품들의 출시 첫 달부터 purchaser 수
select engname, t.YYYYMM, count(distinct t.id) Purchasers
from cx.v_user_3month_list t
	join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
	join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC' and FLAVORSEG_type3 ='New Taste'
group by engname, t.YYYYMM;


select engname, min(t.YYYYMM) ,
	t.YYYYMM, 
	count(distinct t.id) Purchasers
from cx.v_user_3month_list t
	join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
	join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC' and FLAVORSEG_type3 ='New Taste'
group by engname, t.YYYYMM
having sum(a.Pack_qty ) > 1;
