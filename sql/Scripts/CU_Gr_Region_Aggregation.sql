/* 2024.08.21 작업 시작
 * 
*/
---	Gr. 지역 별 전체 hnb 제품 구매자 (terea/heets/miix/fiit/neo/neositck/aiim/)
---	Gr. 지역 별 terea 구매자
---	Gr. 지역 별 miix 구매자
---	Gr. 지역 별 miix 신규 구매자


-- HnB New Purchasers 모수 73,207 건
with temp as( 
select * 
from ( 
	-- (1) 최초 구매이력이 있는지 확인
   select  YYYYMM  , id, max(seq) seq, row_number() over (partition by id order by YYYYMM) rn  
   from
       cu.Fct_BGFR_PMI_Monthly a
       join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype = 'HnB'
   where 1=1 
   group by YYYYMM , a.id
) as t
where rn = 1
),
HnB_NewPurchaser as (
select t.YYYYMM, max(case when t.seq = a.seq then a.SIDO_NM end) SIDO_NM, t.id
from temp t
	join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id  and  a.YYYYMM = t.YYYYMM
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
where t.YYYYMM >= '202401'
and
   exists (
       -- (2) 직전 3개월 동안 구매이력이 있는지 확인
       select 1
       from cu.Fct_BGFR_PMI_Monthly x
       		join cu.dim_product_master y on x.ITEM_CD = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' and y.cigatype != 'CSV'
       where
           x.YYYYMM between convert(nvarchar(6), dateadd(month, -3, a.YYYYMM + '01'), 112)
           				and convert(nvarchar(6), dateadd(month, -1, a.YYYYMM + '01'), 112)
       and a.id = x.id
       group by x.YYYYMM, x.id
	   having count(distinct y.engname) < 11 and sum(x.Pack_qty) < 61.0 -- (3) 구매 SKU 11종 미만 & 팩 수량 61개 미만
   )
group by t.YYYYMM, t.id 
having
       count(distinct b.engname) < 11 -- (3) SKU 11종 미만
   and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만
)
select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct t.id) HnB_New_Purchasers
from HnB_NewPurchaser  t
	join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
where t.YYYYMM >= '202401'
group by 
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM)
	)
;



-- 지역별 구매자 상세이력 뽑기
select * 
from cu.agg_CU_TEREA_Total_Sourcing t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
		and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
				 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
	join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
where t.YYYYMM >= '202401'
and gr_cd ='광주'
and b.cigatype='HnB' and b.company != 'PMK'
--and t.id ='4138b4bee8c0745ffab1f5c39ea113336d607303831d9fbc5473509cb914e426'
;



-- 지역별 전체 HnB 구매
with temp as (
	-- (1) 23년 9월 부터 구매자가 월별 구매이력
	select a.YYYYMM, a.id,  max(seq) seq
	from  cu.Fct_BGFR_PMI_Monthly a 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.cigatype = 'HnB'
	where a.YYYYMM >= '202401'
	and
	   exists (
	       -- (2) 직전 3개월 동안 구매이력이 있는지 확인
	       select 1
	       from cu.Fct_BGFR_PMI_Monthly x
	       		join cu.dim_product_master y on x.ITEM_CD = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' and y.cigatype != 'CSV'
	       where
	           x.YYYYMM between convert(nvarchar(6), dateadd(month, -3, a.YYYYMM + '01'), 112)
	           				and convert(nvarchar(6), dateadd(month, -1, a.YYYYMM + '01'), 112)
	       and a.id = x.id
	       group by x.YYYYMM, x.id
		   having count(distinct y.engname) < 11 and sum(x.Pack_qty) < 61.0 -- (3) 구매 SKU 11종 미만 & 팩 수량 61개 미만
	   )
	group by a.YYYYMM, a.id 
	having
	       count(distinct b.engname) < 11 -- (3) SKU 11종 미만
	   and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만
)
select t.YYYYMM,  COALESCE(gr_cd, '합계') 'Gr Region',
	count(distinct t.id) 'HnB Total',
	count(distinct case when ProductSubFamilyCode ='TEREA' then t.id end) 'TEREA',
	count(distinct case when ProductSubFamilyCode ='MIIX' then t.id end) 'MIIX'
from temp t
  	join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id and t.seq = a.seq
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE = 'CIGARETTES' and cigatype = 'HnB'
	join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
where t.YYYYMM >= '202401'
--and t.id ='003e54a35c1ffbc50c2bce638da7fc74f1aed60b44e6385b9b88427ca7fcdea5'
group by 
	grouping sets (
	(t.YYYYMM, c.gr_cd), 
	(t.YYYYMM) 
	)
order by YYYYMM, 'Gr Region'
;

-- 1764603ba07a8ec520734469d8190f850a25f61a5d6f9e2a66be9bfc96c5416c Gr Region 광주, 대전 두 곳에서 구매함.



select a.YYYYMM,  COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct a.id) 'HnB Total',
	count(distinct case when ProductSubFamilyCode ='TEREA' then a.id end) 'TEREA',
	count(distinct case when ProductSubFamilyCode ='MIIX' then a.id end) 'MIIX'
from cu.Fct_BGFR_PMI_Monthly a 
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE = 'CIGARETTES' and cigatype = 'HnB'
	join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
where a.YYYYMM >= '202401'
--and t.id ='003e54a35c1ffbc50c2bce638da7fc74f1aed60b44e6385b9b88427ca7fcdea5'
group by grouping sets ((a.YYYYMM, c.gr_cd), (a.YYYYMM) )


---	Gr. 지역 별 miix 신규 구매자
select t.YYYYMM,  COALESCE(gr_cd, '합계')  'Gr Region' ,
	count(distinct t.id) total_Purchaser_cnt
from cu.agg_CU_MIIX_Total_Sourcing  t
	join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
where t.YYYYMM >= '202401'
group by 
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM)
	)
order by YYYYMM, 'Gr Region'
;

---	Gr. 지역 별 Total HnB 신규 구매자
select t.YYYYMM,  COALESCE(gr_cd, '합계')  'Gr Region' ,
	count(distinct t.id) total_Purchaser_cnt
from cu.agg_CU_TEREA_Total_Sourcing  t
	join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
where t.YYYYMM >= '202401'
group by 
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM)
	)
order by YYYYMM, 'Gr Region';



-- 검증 작업
-- Gr Region 두 곳 이상에서 구매한 사람들 추출 
select YYYYMM, id , count(*)
from ( 
	select t.YYYYMM, c.gr_cd, t.id
	from cu.v_user_3month_list t
	  	join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id and t.YYYYMM = a.YYYYMM
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE = 'CIGARETTES' and cigatype = 'HnB'
		join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
	where t.YYYYMM >= '202401'
	group by t.YYYYMM, c.gr_cd ,t.id
) as t
group by YYYYMM, id 
having count(*) > 1
;








--	Gr.지역 별 sourcing 작업해주신 내용에서 comp hnb에서 유입인 경우 miix/fiit/aiim/(neo or neostick) 구매자
-- 케이스를 위해 f32e0f276a6666cc7a831cbe8b36bddee3953c020eb8752026d91602e4aed3aa 구매자는 상세 이력 확인용(지역별).
-- Past 3 Month Comp. HnB 구매자수
select  
	t.YYYYMM,  COALESCE(gr_cd, '합계') 'Gr Region',
	count(distinct case when b.ProductSubFamilyCode='MIIX' then t.id end) 'MIIX',
	count(distinct case when b.ProductSubFamilyCode='FIIT' then t.id end) 'FIIT',
	count(distinct case when b.ProductSubFamilyCode='AIIM' then t.id end) 'AIIM',
	count(distinct case when b.ProductSubFamilyCode in ('NEO', 'NEOSTICKS') then t.id end) 'NEO',
	count(distinct case when b.FLAVORSEG_type3 = 'Fresh' then t.id end) 'Fresh',
	count(distinct case when b.FLAVORSEG_type3 = 'New Taste' then t.id end) 'New Taste',
	count(distinct case when b.FLAVORSEG_type3 = 'Regular' then t.id end) 'Regular',
	count(distinct t.id) 'Comp HnB Purchasers'
from cu.agg_CU_TEREA_Total_Sourcing t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
			and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
					 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' and b.cigatype='HnB'
	join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
where 1=1
and t.YYYYMM >= '202401'
--and t.id ='f32e0f276a6666cc7a831cbe8b36bddee3953c020eb8752026d91602e4aed3aa'
and b.company != 'PMK'
group by 
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM)
	)
;

select * 
from cu.agg_CU_TEREA_Total_Sourcing t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
		and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
				 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' and b.cigatype='HnB'
	join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
where t.YYYYMM >= '202401'
and gr_cd ='광주'
and b.company != 'PMK'
and t.id ='4138b4bee8c0745ffab1f5c39ea113336d607303831d9fbc5473509cb914e426'
;

---	Gr.지역 별 sourcing 작업해주신 내용에서 cc 에서 유입인 경우 cc family / subfamily / taste segment
--		(t.YYYYMM, gr_cd, ProductFamilyCode, ProductSubFamilyCode, FLAVORSEG_type3),
-- Total Purchasers
select  
	t.YYYYMM, COALESCE(gr_cd, '합계') 'Gr Region',
--	ProductFamilyCode,
--	ProductSubFamilyCode,
--	FLAVORSEG_type3,
	count(distinct t.id) purchasers
from cu.agg_CU_TEREA_Total_Sourcing t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
			and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
					 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' and b.cigatype='CC'
	join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
where 1=1
and t.YYYYMM >= '202401'
group BY
	grouping sets (
		(t.YYYYMM, gr_cd),
		(t.YYYYMM)
	)
order by t.YYYYMM, 'Gr Region' 
;


-- 피벗 작업 필요  FLAVORSEG_type3,	ProductFamilyCode, ProductSubFamilyCode
select  
	t.YYYYMM, COALESCE(gr_cd, '합계') 'Gr Region',
	ProductFamilyCode,
--	ProductSubFamilyCode,
--	FLAVORSEG_type3,
	count(distinct t.id) purchasers
from cu.agg_CU_TEREA_Total_Sourcing t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
			and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
					 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' and b.cigatype='CC'
	join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
where 1=1
and t.YYYYMM >= '202401'
group BY
	grouping sets (
		(t.YYYYMM, gr_cd, ProductFamilyCode),
		(t.YYYYMM, ProductFamilyCode)
	)
;




---	Gr.지역 별 sourcing 작업해주신 내용에서 current usage에서 com hnb인 경우 같이 사용하고 있는 miix/fiit/aiim/(neo or neostick) 구매자
-- Current Comp. HnB 구매자 수
select  
	t.YYYYMM, COALESCE(gr_cd, '합계') 'Gr Region',
	count(distinct case when b.ProductSubFamilyCode='MIIX' then t.id end) 'MIIX',
	count(distinct case when b.ProductSubFamilyCode='FIIT' then t.id end) 'FIIT',
	count(distinct case when b.ProductSubFamilyCode='AIIM' then t.id end) 'AIIM',
	count(distinct case when b.ProductSubFamilyCode in ('NEO', 'NEOSTICKS') then t.id end) 'NEO',
	count(distinct case when b.FLAVORSEG_type3 = 'Fresh' then t.id end) 'Fresh',
	count(distinct case when b.FLAVORSEG_type3 = 'New Taste' then t.id end) 'New Taste',
	count(distinct case when b.FLAVORSEG_type3 = 'Regular' then t.id end) 'Regular',
	count(distinct t.id) 'Comp HnB Purchasers'
from  cu.agg_CU_TEREA_Total_Sourcing t
	join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
		and a.YYYYMM = t.YYYYMM
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND b.cigatype = 'HnB' 
	join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
where t.YYYYMM >= '202401'
and b.company != 'PMK'
group by 
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM)
	)
;

-- Exclusive Taste ( 3개월 기간 / 현재 기간)
with temp as (
	select t.YYYYMM, 
		gr_cd, 
		t.id, 
		min(b.FLAVORSEG_type3 ) + ' Only' FLAVORSEG_type3 
	from cu.agg_CU_TEREA_Total_Sourcing t
			join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
			and a.YYYYMM = t.YYYYMM
--			and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
--					 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' and b.cigatype='HnB'
		join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
	where t.YYYYMM >= '202401'
	and b.company != 'PMK'
	group by t.YYYYMM, gr_cd, t.id
	having count(distinct b.FLAVORSEG_type3) = 1 
)
select  
	YYYYMM, COALESCE(gr_cd, '합계') 'Gr Region',
	count(distinct case when FLAVORSEG_type3 = 'Fresh Only' then id end) 'Fresh Only',
	count(distinct case when FLAVORSEG_type3 = 'New Taste Only' then id end) 'New Taste Only',
	count(distinct case when FLAVORSEG_type3 = 'Regular Only' then id end) 'Regular Only'
from temp
group by 
	grouping sets ( 
		(YYYYMM, gr_cd),
		(YYYYMM)
	)
order by YYYYMM, 'Gr Region'
;

	
---	Gr.지역 별 sourcing 작업해주신 내용에서 current usage에서 cc인 경우 같이 사용하고 있는 cc family / subfamily / taste segment
select  
	t.YYYYMM,  COALESCE(gr_cd, '합계') 'Gr Region',
--	ProductFamilyCode,
--	ProductSubFamilyCode,
--	FLAVORSEG_type3,
	count(distinct t.id) purchasers
from cu.agg_CU_TEREA_Total_Sourcing t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
			and a.YYYYMM = t.YYYYMM	
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' and b.cigatype='CC'
	join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
where 1=1
and t.YYYYMM >= '202401'
group BY
	grouping sets (
		(t.YYYYMM, gr_cd),
		(t.YYYYMM)
	)
order by t.YYYYMM, 'Gr Region'
;


-- 피벗 작업 필요  FLAVORSEG_type3,	ProductFamilyCode, ProductSubFamilyCode
select  
	t.YYYYMM, COALESCE(gr_cd, '합계') 'Gr Region',
	ProductFamilyCode,
--	ProductSubFamilyCode,
--	FLAVORSEG_type3,
	count(distinct t.id) purchasers
from cu.agg_CU_TEREA_Total_Sourcing t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
			and a.YYYYMM = t.YYYYMM	
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' and b.cigatype='CC'
	join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
where 1=1
and t.YYYYMM >= '202401'
group BY
	grouping sets (
		(t.YYYYMM, gr_cd, ProductFamilyCode),
		(t.YYYYMM, ProductFamilyCode)
	)
;


-- exclusive NTD taste purchaser / exclusive Regular taste purchaser / exclusive Fresh taste purchaser
with temp as (
	select t.YYYYMM, 
		gr_cd, 
		t.id, 
		min(b.FLAVORSEG_type3 ) + ' Only' FLAVORSEG_type3 
	from cu.agg_CU_TEREA_Total_Sourcing t
			join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
			and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
					 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' and b.cigatype='CC'
		join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
	where t.YYYYMM >= '202401'
	group by t.YYYYMM, gr_cd, t.id
	having count(distinct b.FLAVORSEG_type3) = 1 
)
select YYYYMM, COALESCE(gr_cd, '합계') 'Gr Region',
	FLAVORSEG_type3 , 
	count(id) n
from temp
group by 	
	grouping sets (
		(YYYYMM, gr_cd, FLAVORSEG_type3),
		(YYYYMM, FLAVORSEG_type3)
	)  
order by YYYYMM, 'Gr Region'
;

-- 8,736
	select t.YYYYMM, gr_cd, t.id, min(b.FLAVORSEG_type3 ) FLAVORSEG_type3 ,max(b.FLAVORSEG_type3 )
	from cu.agg_CU_TEREA_Total_Sourcing t
			join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
			and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
					 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' and b.cigatype='CC'
		join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
	where t.YYYYMM >= '202401'
	group by t.YYYYMM, gr_cd, t.id
	having count(distinct b.FLAVORSEG_type3) = 1
	;

select *
from cu.agg_CU_TEREA_Total_Sourcing t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
		and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
				 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' and b.cigatype='CC'
	join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
where t.id ='a9abf56b955b9581d08d4e180f34e9ef175d744e039bf2a18c93d515676a20c4'
;

select *
from  cu.Fct_BGFR_PMI_Monthly  a
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' and b.cigatype='CC'
where id ='3384ed735cd3f0aac8602cbb85bc7bb4dab707711018d13876d7cf71fe42c6d2'
and YYYYMM >= '202310';



with temp as (
	select t.YYYYMM, 
	gr_cd, 
	t.id, 
	max(b.FLAVORSEG_type3 ) + ' Only' FLAVORSEG_type3 
	from cu.agg_CU_TEREA_Total_Sourcing t
			join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
			and a.YYYYMM = t.YYYYMM	
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' and b.cigatype='CC'
		join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
	where t.YYYYMM >= '202401'
	group by t.YYYYMM, gr_cd, t.id
	having count(distinct b.FLAVORSEG_type3) = 1 
)
select YYYYMM, COALESCE(gr_cd, '합계') 'Gr Region',
	FLAVORSEG_type3 , 
	count(id) n
from temp
group by 	
	grouping sets (
		(YYYYMM, gr_cd, FLAVORSEG_type3),
		(YYYYMM, FLAVORSEG_type3)
	)  
order by YYYYMM, 'Gr Region'
;