/* -- 2024.09.03 작업 시작
 * 
-	monthly tobacco purchaser 수 (2022년 1월~)
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


-- v_user_3month_list
--count(distinct t.id) Purchasers

-- monthly tobacco purchaser 수 (2022년 1월~)
with temp as ( 
	select t.YYYYMM, engname, t.id
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE != 'CSV'
	where t.YYYYMM >= '202201'
	group by t.YYYYMM, engname, t.id
	having sum(a.Pack_qty ) > 1
)
select yyyymm, count(distinct id) 'Tobacco Purchasers'
from temp 
group by yyyymm
;


-- monthly cc purchaser 수
with temp as ( 
	select t.YYYYMM, engname, t.id
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC'
	where t.YYYYMM >= '202201'
	group by t.YYYYMM, engname, t.id
	having sum(a.Pack_qty ) > 1
)
select yyyymm, count(distinct id) 'CC Purchasers'
from temp 
group by yyyymm
;



-- monthly NTD cc purchaser 수 (3-TYPE Flavour seg 기준 NTD입니다)
with temp as ( 
	select t.YYYYMM, engname, t.id
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC' and FLAVORSEG_type3 ='New Taste'
	where t.YYYYMM >= '202201'
	group by t.YYYYMM, engname, t.id
	having sum(a.Pack_qty ) > 1
)
select yyyymm, count(distinct id) 'NTD Purchasers'
from temp 
group by yyyymm
;


select *
from cx.product_master
where FLAVORSEG_type6 ='New Taste';
--Fresh to New Taste
--Regular to New Taste


--NTD (Regular to NTD) Purchaser
with temp as ( 
	select t.YYYYMM, engname, t.id
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC' and FLAVORSEG_type6 ='Regular to New Taste'
	where t.YYYYMM >= '202201'
	group by t.YYYYMM, engname, t.id
	having sum(a.Pack_qty ) > 1
)
select yyyymm, count(distinct id) 'Regular NTD Purchasers'
from temp 
group by yyyymm
;



--NTD (Fresh to NTD) Purchaser
with temp as ( 
	select t.YYYYMM, engname, t.id
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC' and FLAVORSEG_type6 ='Fresh to New Taste'
	where t.YYYYMM >= '202201'
	group by t.YYYYMM, engname, t.id
	having sum(a.Pack_qty ) > 1
)
select yyyymm, count(distinct id) Purchasers
from temp 
group by yyyymm
;


--NTD NPL Product Purchaser (리스트 내 제품) NPL_YN ='Y'
with temp as ( 
	select t.YYYYMM, engname, t.id
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC' and NPL_YN ='Y'
	where t.YYYYMM >= '202201'
	group by t.YYYYMM, engname, t.id
	having sum(a.Pack_qty ) > 1
)
select yyyymm, count(distinct id) Purchasers
from temp 
group by yyyymm
;

-- Regular to NTD NPL Product Purchaser (리스트 내 제품)
with temp as ( 
	select t.YYYYMM, engname, t.id
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC' and NPL_YN ='Y' and  FLAVORSEG_type6 ='Regular to New Taste'
	where t.YYYYMM >= '202201'
	group by t.YYYYMM, engname, t.id
	having sum(a.Pack_qty ) > 1
)
select yyyymm, count(distinct id) Purchasers
from temp 
group by yyyymm
;


	select t.YYYYMM, engname, t.id
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC' and NPL_YN ='Y' and  FLAVORSEG_type6 ='Regular to New Taste'
	where t.YYYYMM = '202203'
	group by t.YYYYMM, engname, t.id
	having sum(a.Pack_qty ) > 1


-- Fresh to NTD NPL Product Purchaser (리스트 내 제품)
with temp as ( 
	select t.YYYYMM, engname, t.id
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC' and NPL_YN ='Y' and  FLAVORSEG_type6 ='Fresh to New Taste'
	where t.YYYYMM >= '202201'
	group by t.YYYYMM, engname, t.id
	having sum(a.Pack_qty ) > 1
)
select yyyymm, count(distinct id) Purchasers
from temp 
group by yyyymm
;

	select t.YYYYMM, t.id
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC' and NPL_YN ='Y' and  FLAVORSEG_type6 ='Regular to New Taste'
	where t.YYYYMM = '202203'
	and engname = 'BOHEM CIGAR ICE FIT'
	group by t.YYYYMM, t.id
	having sum(a.Pack_qty ) > 1

	
select * 
from  cx.fct_K7_Monthly a  
	join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC' 
where id ='0630F2A73FDD71E5AC6A44B8A6CE9D3A461FAF658C77C5439058F0D1F350FFFD'
and YYYYMM ='202201'
 and npl_yn ='Y'
 
 


-- 첨부파일의 제품들의 출시 첫 달부터 재구매 purchaser 수 (해당 제품 2팩이상 구매자)
with temp as ( 
	-- 해당 제품 2팩이상 구매자
	select engname,
		b.FLAVORSEG_type6,
		t.YYYYMM, 
		t.id,
		NPL_YN,
		sum(a.Pack_qty) pack
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC'
	where t.YYYYMM >= '202201'
	group by engname, b.FLAVORSEG_type6, t.YYYYMM, NPL_YN, t.id
	having sum(a.Pack_qty ) > 1
)
select engname,
	FLAVORSEG_type6,
	NPL_YN,
	YYYYMM,
	count(distinct id) Purchasers
from temp
group by engname, FLAVORSEG_type6, NPL_YN, YYYYMM
;


-- Pivot 및 m1, m2, m3, m4 작업 필요
-- 제품 최초 구매일 작업 
with temp as (
	-- (1) 최초 구매월 추출 
	select engname, min(a.YYYYMM) first_purchase 
	from cx.fct_K7_Monthly a
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE != 'CSV' 
	where YYYYMM >= '202201'
	group by engname
),
purchaser as (
	select x.engname, b.FLAVORSEG_type6, t.YYYYMM, t.id, min(first_purchase) first_purchase
	from temp x
		join cx.seven11_user_3month_list t 
			on t.YYYYMM between convert(nvarchar(6), dateadd(month, 0, x.first_purchase + '01'), 112)
	           				and convert(nvarchar(6), dateadd(month, 3, x.first_purchase + '01'), 112)
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC'  and NPL_YN ='Y' and  FLAVORSEG_type6 ='Fresh to New Taste'
	where x.engname = b.engname
	and 1=1 
	group by x.engname, b.FLAVORSEG_type6, t.YYYYMM, t.id
	having sum(a.Pack_qty ) > 1
)
select  engname, FLAVORSEG_type6 , min(YYYYMM) YYYYMM,
	count(case when YYYYMM = first_purchase then id end) m1,
	count(case when YYYYMM = first_purchase + 1 then id end) m2,
	count(case when YYYYMM = first_purchase + 2 then id end) m3,
	count(case when YYYYMM = first_purchase + 3 then id end) m4
from purchaser
group by engname, FLAVORSEG_type6, id
;



with temp as (
	-- (1) 최초 구매월 추출 
	select engname, min(a.YYYYMM) first_purchase 
	from cx.fct_K7_Monthly a
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE != 'CSV' 
	where YYYYMM >= '202201'
	group by engname
)
select x.engname, b.FLAVORSEG_type6, t.YYYYMM, t.id, min(first_purchase) first_purchase
from temp x
	join cx.seven11_user_3month_list t 
		on t.YYYYMM between convert(nvarchar(6), dateadd(month, 0, x.first_purchase + '01'), 112)
           				and convert(nvarchar(6), dateadd(month, 3, x.first_purchase + '01'), 112)
	join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
	join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC'  and NPL_YN ='Y' and  FLAVORSEG_type6 ='Fresh to New Taste'
where x.engname = b.engname
and t.id ='0630F2A73FDD71E5AC6A44B8A6CE9D3A461FAF658C77C5439058F0D1F350FFFD'
group by x.engname, b.FLAVORSEG_type6, t.YYYYMM, t.id
having sum(a.Pack_qty ) > 1



select engname, b.FLAVORSEG_type6, t.YYYYMM, t.id
from 
	cx.seven11_user_3month_list t 
	join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
	join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC'  and NPL_YN ='Y' and  FLAVORSEG_type6 ='Fresh to New Taste'
where 1=1
and t.id ='0630F2A73FDD71E5AC6A44B8A6CE9D3A461FAF658C77C5439058F0D1F350FFFD'
group by engname, b.FLAVORSEG_type6, t.YYYYMM, t.id

with temp as (
	-- (1) 최초 구매월 추출 
	select engname, min(a.YYYYMM) first_purchase 
	from cx.fct_K7_Monthly a
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE != 'CSV' 
	where YYYYMM >= '202201'
	group by engname
)
select x.engname, b.FLAVORSEG_type6, t.YYYYMM, t.id, min(first_purchase) first_purchase
from temp x
	join cx.seven11_user_3month_list t 
		on t.YYYYMM between convert(nvarchar(6), dateadd(month, 0, x.first_purchase + '01'), 112)
           				and convert(nvarchar(6), dateadd(month, 3, x.first_purchase + '01'), 112)
	join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
	join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC'  and NPL_YN ='Y' and  FLAVORSEG_type6 ='Fresh to New Taste'
where x.engname = b.engname
and t.YYYYMM ='202201'
group by x.engname, b.FLAVORSEG_type6, t.YYYYMM, t.id
having sum(a.Pack_qty ) > 1
;


-- DUNHILL GREEN BOOST MNT 100 BOX 20 SSL제품코드를 알고 싶다... 22년 10월 20일 출시 >> L.point에는 던힐 그린 부스트 제품 구매건 없다...
select distinct product_mnft , product_name 
from cx.K7_230718 a 
where 
	not exists (select 1 
				from cx.product_master b
				where a.product_code  = b.prod_id
	)
and left(de_dt, 6) >= '202210'
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

