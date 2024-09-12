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
	select t.YYYYMM, t.id
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE != 'CSV'
	where t.YYYYMM >= '202201'
	group by t.YYYYMM, t.id
	having sum(a.Pack_qty ) > 1
)
select yyyymm, count(distinct id) 'Tobacco Purchasers'
from temp 
group by yyyymm
;


-- monthly cc purchaser 수
with temp as ( 
	select t.YYYYMM, t.id
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC'
	where t.YYYYMM >= '202201'
	group by t.YYYYMM, t.id
	having sum(a.Pack_qty ) > 1
)
select yyyymm, count(distinct id) 'CC Purchasers'
from temp 
group by yyyymm
;



-- monthly NTD cc purchaser 수 (3-TYPE Flavour seg 기준 NTD입니다)
with temp as ( 
	select t.YYYYMM, t.id
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC' and FLAVORSEG_type3 ='New Taste'
	where t.YYYYMM >= '202201'
	group by t.YYYYMM, t.id
	having sum(a.Pack_qty ) > 1
)
select yyyymm, count(distinct id) 'NTD CC Purchasers'
from temp 
group by yyyymm
;


--NTD (Regular to NTD) Purchaser
with temp as ( 
	select t.YYYYMM, t.id
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC' and FLAVORSEG_type6 ='Regular to New Taste'
	where t.YYYYMM >= '202201'
	group by t.YYYYMM, t.id
	having sum(a.Pack_qty ) > 1
)
select yyyymm, count(distinct id) 'Regular NTD Purchasers'
from temp 
group by yyyymm
;



--NTD (Fresh to NTD) Purchaser
with temp as ( 
	select t.YYYYMM, t.id
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC' and FLAVORSEG_type6 ='Fresh to New Taste'
	where t.YYYYMM >= '202201'
	group by t.YYYYMM, t.id
	having sum(a.Pack_qty ) > 1
)
select yyyymm, count(distinct id) Purchasers
from temp 
group by yyyymm
;


--NTD NPL Product Purchaser (리스트 내 제품) NPL_YN ='Y'
with temp as ( 
	select t.YYYYMM, engname,  t.id
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC' and NPL_YN ='Y'
	where t.YYYYMM >= '202201'
	group by t.YYYYMM, engname, t.id
	having sum(a.Pack_qty ) > 1 -- 어느 한 팩이상 구매
)
select yyyymm, count(distinct id) 'NTD NPL Purchasers'
from temp 
group by yyyymm
;



-- Regular to NTD NPL Product Purchaser (리스트 내 제품)
with temp as ( 
	select t.YYYYMM, t.id
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC' and NPL_YN ='Y' and  FLAVORSEG_type6 ='Regular to New Taste'
	where t.YYYYMM >= '202201'
	group by t.YYYYMM,  t.id
	having sum(a.Pack_qty ) > 1
)
select yyyymm, count(distinct id) 'Regular to NTD NPL Purchasers'
from temp 
group by yyyymm
;



-- Fresh to NTD NPL Product Purchaser (리스트 내 제품)
with temp as ( 
	select t.YYYYMM,  t.id
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE ='CIGARETTES' and CIGATYPE ='CC' and NPL_YN ='Y' and  FLAVORSEG_type6 ='Fresh to New Taste'
	where t.YYYYMM >= '202201'
	group by t.YYYYMM,  t.id
	having sum(a.Pack_qty ) > 1
)
select yyyymm, count(distinct id) 'FTN NPL Purchasers'
from temp 
group by yyyymm
;

	


-- NPL Purchaser Pivot 작업 필요
-- 첨부파일의 제품들의 출시 첫 달부터 purchaser 수
with temp as ( 
	-- 매월 2팩이상 구매자
	select
		t.YYYYMM, 
		t.id
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC'
	where t.YYYYMM >= '202201'
	group by t.YYYYMM, t.id
	having sum(a.Pack_qty ) > 1
)
select engname,
	FLAVORSEG_type6,
	NPL_YN ,
	t.YYYYMM,
	count(distinct t.id) 'NTD Purchasers'
from temp t
	join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
	join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC'
group by engname, FLAVORSEG_type6, NPL_YN , t.YYYYMM
;



--	첨부파일의 제품들의 출시 첫 달부터 재구매 purchaser 수 (해당 제품 2팩이상 구매자)
with temp as ( 
	-- 매월 2팩이상 구매자
	select
		t.YYYYMM, 
		t.id
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC'
	where t.YYYYMM >= '202201'
	group by t.YYYYMM, t.id
	having sum(a.Pack_qty ) > 1
)
select engname,
	FLAVORSEG_type6,
	NPL_YN ,
	t.YYYYMM,
	count(distinct t.id) 'NTD Re-Purchasers'
from temp t
	join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
	join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC'
group by engname, FLAVORSEG_type6, NPL_YN , t.YYYYMM
having sum(a.Pack_qty ) > 1
;


-- Old 
with temp as (
	-- (1) 최초 구매월 추출 
	select engname, min(a.YYYYMM) first_purchase 
	from cx.fct_K7_Monthly a
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE != 'CSV' 
	where YYYYMM >= '202201'
	group by engname
),
purchaser as (
	select x.engname, b.FLAVORSEG_type6, t.YYYYMM, t.id
	from temp x
		join cx.seven11_user_3month_list t 
			on t.YYYYMM between convert(nvarchar(6), dateadd(month, 0, x.first_purchase + '01'), 112)
	           				and convert(nvarchar(6), dateadd(month, 3, x.first_purchase + '01'), 112)
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC'  and NPL_YN ='Y' and  FLAVORSEG_type6 ='Regular to New Taste'
	where x.engname = b.engname
	and 1=1 
	group by x.engname, b.FLAVORSEG_type6, t.YYYYMM, t.id
	having sum(a.Pack_qty ) > 1
), 
first_purchased as (
	select  engname, FLAVORSEG_type6 ,id, min(YYYYMM) first_purchased
	from purchaser
	group by engname, FLAVORSEG_type6, id
)
select 
	engname, FLAVORSEG_type6 ,t.id, first_purchased,
	count(case when YYYYMM = first_purchased then t.id end) m1,
	count(case when YYYYMM = first_purchased + 1 then t.id end) m2,
	count(case when YYYYMM = first_purchased + 2 then t.id end) m3,
	count(case when YYYYMM = first_purchased + 3 then t.id end) m4
from first_purchased t
	join cx.seven11_user_3month_list a on a.id = t.id 
group by engname, FLAVORSEG_type6 , t.id, first_purchased
;


 
-- Pivot 및 m1, m2, m3, m4 하나씩 작업 필요 
-- 모수 기본조건!! 시간이 오래 걸리니.. 필요한 데이터만 테이블로 생성해불자
with Total_purchaser as(
	-- (1) 전체 구매이력 있는지 구매자 추출
	select
 		engname, t.YYYYMM, t.id --sum(a.pack_qty) pack_qty2
	from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly x on x.id = t.id and x.YYYYMM = t.YYYYMM 
		join cx.product_master y on x.product_code = y.PROD_ID and CIGADEVICE ='CIGARETTES' and CIGATYPE != 'CSV' 
	where 1=1 
	and t.id in ( 
		select a.id
		from cx.fct_K7_Monthly a  
			join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE ='CIGARETTES' and CIGATYPE != 'CSV'
		where a.YYYYMM between convert(nvarchar(6), dateadd(month, 0, t.YYYYMM + '01'), 112)
		   				   and convert(nvarchar(6), dateadd(month, 3, t.YYYYMM + '01'), 112)
		group by a.id
		having count(distinct a.yyyymm) = 1			-- 조건1 M1/M2/M3/M4 .. 첫 구매부터 몇 개월까지 구매를 지속했는지 파악(조건은 4개월치 구매지속함)
	)
	and t.YYYYMM >= '202407'				 		-- 조건2 구매 시작월
	group by engname, t.YYYYMM, t.id
),
First_purchase as(
	-- (2) 구매자별 생애 첫 제품구매월 
      SELECT
           b.engname,
			a.id,
           MIN(a.YYYYMM) AS start_purchase
       FROM cx.fct_K7_Monthly a  
       JOIN cx.product_master b ON a.product_code = b.PROD_ID AND b.CIGADEVICE = 'CIGARETTES' AND b.CIGATYPE != 'CSV'
       GROUP BY b.engname, a.id
)
--insert into cx.first_purchaser
SELECT engname, id,  min(YYYYMM) first_purchase
--into cx.first_purchaser
FROM Total_purchaser t
where not exists (
	-- (3) 과거 구매이력이 있으면 제외
	select 1
	from First_purchase fp
	where t.id = fp.id and t.engname = fp.engname
	group by fp.engname, fp.id, fp.start_purchase
	having t.YYYYMM > fp.start_purchase		-- 중요 제외 조건: (11종 이상,61갑 이상) 조건 구매 월 VS 생애 첫 구매월 
)
group by engname, id
;


	
	
-- 최종
with purchase as (
	select b.engname, 
		b.FLAVORSEG_type6, 
		t.YYYYMM, 
		t.id,
		first_purchase ,
		DATEDIFF(MONTH, CAST(first_purchase +'01' as date), CAST(t.YYYYMM +'01' as date) ) cohort,
		dense_rank() over(partition by b.engname, b.FLAVORSEG_type6 order by  first_purchase ) rn
	from  cx.seven11_user_3month_list t 
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC' and NPL_YN ='Y' and  FLAVORSEG_type6 ='Regular to New Taste'
		left join cx.first_purchaser x on t.id = x.id and x.engname = b.engname
	where  1=1 --b.engname= 'BOHEM CIGAR ICE FIT'
	group by b.engname, b.FLAVORSEG_type6, t.YYYYMM, t.id, first_purchase
)
select * -- distinct first_purchase, rn 
from purchase 
where cohort between 0 and 3
and rn between 1 and 4
--and first_purchase = '202302'
;



-- NTD NPL Purchaser M1 구매자수
with purchase as (
	select b.engname, 
		b.FLAVORSEG_type6, 
		t.YYYYMM, 
		t.id,
		first_purchase ,
		DATEDIFF(MONTH, CAST(first_purchase +'01' as date), CAST(t.YYYYMM +'01' as date) ) cohort,
		dense_rank() over(partition by b.engname, b.FLAVORSEG_type6 order by  first_purchase ) rn
	from  cx.seven11_user_3month_list t 
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM 
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE = 'CC' and NPL_YN ='Y' and  FLAVORSEG_type6 ='Fresh to New Taste'
		left join cx.first_purchaser x on t.id = x.id and x.engname = b.engname 
	-- 기준월(202201) 이전 출시 제품 제외
	where b.engname not in ('BOHEM CIGAR CARIBE',
							'Dunhill Electric Crush',
							'DUNHILL EXOTIC CRUSH',
							'DUNHILL LIT ZEPHYR MNT KS OCT 20',
							'Dunhill Smooth Crush',
							'ESSE CHANGE DOUBLE',
							'ESSE CHANGE GRAM 100 DHX 20 SSL',
							'Marlboro Vista Tropical Splash',
							'MEVIUS LBS BANA SSL',
							'MEVIUS LBS TROPICAL MIX 3mg',
							'Parliament Double Wave',
							'RAISON FRENCH ICE BLAN' ) 
	group by b.engname, b.FLAVORSEG_type6, t.YYYYMM, t.id, first_purchase
),
launch_product as(
	-- (2) 제품 출시월 
      SELECT
           b.engname,
           MIN(a.YYYYMM) AS start_prodcut
       FROM cx.fct_K7_Monthly a  
       JOIN cx.product_master b ON a.product_code = b.PROD_ID AND b.CIGADEVICE = 'CIGARETTES' AND b.CIGATYPE != 'CSV'
       GROUP BY b.engname
)
select YYYYMM, count(distinct id)
from purchase a
	join launch_product b on a.engname = b.engname and a.first_purchase = b.start_prodcut
where cohort = 0
group by YYYYMM
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

