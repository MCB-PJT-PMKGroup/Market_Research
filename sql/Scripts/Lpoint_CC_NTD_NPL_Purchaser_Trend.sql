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

with temp as( 
select * 
from ( 
   select  YYYYMM  , id, row_number() over (partition by id order by YYYYMM) rn  
   from
       cx.fct_K7_Monthly a
       join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype = 'CC'
   where 1=1
   group by YYYYMM , a.id
) as t
where rn = 1
)
select a.YYYYMM, count(a.id), count(distinct a.id)
from temp t
	join cx.v_user_3month_list a on a.id = t.id  and  a.YYYYMM = t.YYYYMM
group by a.YYYYMM;


select YYYYMM, count(id), count(distinct id)
from (
select t.YYYYMM, t.id --, row_number() over (partition by t.id order by t.YYYYMM) rn  
from  cx.seven11_user_3month_list t 
   join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM
   join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype = 'CC'
where 
	not exists (
		select 1
	      from cx.fct_K7_Monthly x
	   		join cx.product_master y on x.product_code = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' and y.cigatype != 'CSV'
		where
	       x.YYYYMM < t.YYYYMM			-- 이전에 구매이력이 있으면 안됨. 최초 구매 월만
		and t.id = x.id  
		and b.ENGNAME = y.engname
	) 
and t.YYYYMM = '202406'
group by t.YYYYMM, t.id
) as t
group by YYYYMM;



-- monthly tobacco purchaser 수 (2022년 1월~)
select t.YYYYMM, count(distinct t.id) Purchasers
from cx.v_user_3month_list t
	join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
	join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE != 'CSV'
where t.YYYYMM >= '202201'
group by t.YYYYMM;


-- monthly cc purchaser 수
select t.YYYYMM, count(distinct t.id) Purchasers
from cx.seven11_user_3month_list t
	join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
	join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC'
where t.YYYYMM >= '202201'
group by t.YYYYMM;


-- monthly NTD cc purchaser 수 (3-TYPE Flavour seg 기준 NTD입니다)
select t.YYYYMM, count(distinct t.id) Purchasers
from cx.seven11_user_3month_list t
	join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
	join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC' and FLAVORSEG_type3 ='New Taste'
where t.YYYYMM >= '202201'
group by t.YYYYMM;


update statistics cx.fct_K7_Monthly;
--	첨부파일의 제품들의 출시 첫 달부터 purchaser 수
select engname, 
	b.FLAVORSEG_type3,
	t.YYYYMM, 
	count(distinct t.id) Purchasers
from cx.v_user_3month_list t
	join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
	join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC'
where t.YYYYMM >= '202201'	
group by  engname, b.FLAVORSEG_type3, t.YYYYMM;


-- 첨부파일의 제품들의 출시 첫 달부터 재구매 purchaser 수 (해당 제품 2팩이상 구매자)
with temp as ( 
	-- 해당 제품 2팩이상 구매자
	select engname,
		b.FLAVORSEG_type3,
		t.YYYYMM, 
		t.id,
		sum(a.Pack_qty) pack
	from cx.v_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC'
	where t.YYYYMM >= '202201'
	group by engname, b.FLAVORSEG_type3,t.YYYYMM, t.id
	having sum(a.Pack_qty ) > 1
)
select engname,
	FLAVORSEG_type3,
	YYYYMM,
	count(distinct id) Purchasers
from temp
group by engname, FLAVORSEG_type3, YYYYMM
;





-- monthly tobacco Pack  수 (2022년 1월~)
select t.YYYYMM, sum(a.Pack_qty) Pack_Qty
from cx.v_user_3month_list t
	join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
	join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE != 'CSV'
where t.YYYYMM >= '202201'
group by t.YYYYMM;


-- monthly cc Pack 수
select t.YYYYMM,  sum(a.Pack_qty) Pack_Qty
from cx.v_user_3month_list t
	join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
	join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC'
where t.YYYYMM >= '202201'
group by t.YYYYMM;


-- monthly NTD cc Pack 수 (3-TYPE Flavour seg 기준 NTD입니다)
select t.YYYYMM, sum(a.Pack_qty) Pack_Qty
from cx.v_user_3month_list t
	join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
	join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC' and FLAVORSEG_type3 ='New Taste'
where t.YYYYMM >= '202201'
group by t.YYYYMM;


-- Pivot 작업 필요
--	첨부파일의 제품들의 출시 첫 달부터 Pack 수
select engname, 
	b.FLAVORSEG_type3,
	t.YYYYMM, 
	 sum(a.Pack_qty) Pack_Qty
from cx.v_user_3month_list t
	join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
	join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC'
where t.YYYYMM >= '202201'	
group by engname, b.FLAVORSEG_type3, t.YYYYMM;


-- Pivot 작업 필요
-- 첨부파일의 제품들의 출시 첫 달부터 재구매 Pack 수 (해당 제품 2팩이상 구매자)
with temp as ( 
	-- 해당 제품 2팩이상 구매자
	select engname,
		b.FLAVORSEG_type3,
		t.YYYYMM, 
		t.id,
		sum(a.Pack_qty) pack
	from cx.v_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC'
	where t.YYYYMM >= '202201'
	group by engname, b.FLAVORSEG_type3, t.YYYYMM, t.id
	having sum(a.Pack_qty ) > 1
)
select engname,
	FLAVORSEG_type3,
	YYYYMM,
	 sum(pack) Pack_Qty
from temp
group by engname, FLAVORSEG_type3, YYYYMM
;



-- 매월 같은 제품을 구매횟수 2번이상?
with temp as ( 
	-- 해당 제품 2팩이상 구매자
	select engname,
		b.FLAVORSEG_type3,
		t.YYYYMM, 
		t.id,
		count(*) Purchaser_cnt
	from cx.v_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC'
	where t.YYYYMM >= '202201'
	group by engname, b.FLAVORSEG_type3, t.YYYYMM, t.id
	having count(*) > 1
)
select engname,
	b.FLAVORSEG_type3,
	YYYYMM,
	count(Purchaser_cnt) n
from temp
group by engname, YYYYMM;


	select engname,
		t.YYYYMM, 
		t.id,
		count(*) Purchaser_cnt
	from cx.v_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC'
	where t.YYYYMM >= '202201'
	group by engname, b.FLAVORSEG_type3, t.YYYYMM, t.id
	having count(*) > 1;
	
select * 
	from cx.v_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC'
where t.YYYYMM='202407'