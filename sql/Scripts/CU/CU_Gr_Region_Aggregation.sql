/* 2024.08.21 작업 시작
 * 
*/
---	Gr. 지역 별 전체 hnb 제품 구매자 (terea/heets/miix/fiit/neo/neositck/aiim/)
---	Gr. 지역 별 terea 구매자
---	Gr. 지역 별 miix 구매자
---	Gr. 지역 별 miix 신규 구매자

-- 1팩 구매 이상 , 월별 마지막 지역에서 구매
--select * 
--from ( 
--	select t.YYYYMM, t.id, a.SIDO_NM , gr_cd, 
--	row_number() over(partition by t.YYYYMM, t.id  order by a.row_id desc) rn,
--	sum(pack_qty) over(partition by t.YYYYMM, t.id) qty 
--	from cu.cu_user_3month_list_incl_csv t
--		join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
--		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE = 'CIGARETTES' and cigatype !='CSV'
--		join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
--	where  t.YYYYMM >= '202401'
--) as t
--where rn = 1 -- gr_cd 마지막 구매지역
--and qty > 1
--;

-- Old 
with temp as (
	select * 
	from ( 
		select t.YYYYMM, t.id, SIDO_NM ,
	--		row_number() over (partition by t.id order by t.YYYYMM) rn 
			row_number() over(partition by t.YYYYMM, t.id  order by a.row_id desc) rn 
		from  cu.v_user_3month_list  t 
		   join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM
		   join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype = 'HnB'
		where 
			not exists (
				select 1
			      from cu.Fct_BGFR_PMI_Monthly x
			   		join cu.dim_product_master y on x.ITEM_CD = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' and y.cigatype != 'CSV'
				where
			       x.YYYYMM < t.YYYYMM			-- 이전에 구매이력이 있으면 안됨. 최초 구매 월만
				and t.id = x.id
				and y.ProductSubFamilyCode = b.ProductSubFamilyCode   
			)
	--	and b.ProductSubFamilyCode in ('NEO', 'NEOSTICKS')
	) as t
	where rn = 1
)
select t.YYYYMM,  COALESCE(gr_cd, '합계') 'Gr Region',
	count(distinct t.id) 'HnB Total',
	sum(PACK_QTY) 'HnB Total Pack'
from temp t
	join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE = 'CIGARETTES' and cigatype ='HnB'
group by 
	grouping sets (
	(t.YYYYMM, gr_cd), 
	(t.YYYYMM) 
	)
order by YYYYMM, 'Gr Region'
;


-- cu.cu_user_3month_list_incl_csv
-- cu.user_3month_list

-- Gr 지역별 전체 HnB 구매 : HnB Total, HnB Total Pack
with temp as (
	select * 
	from ( 
		select t.YYYYMM, t.id, a.SIDO_NM , gr_cd, 
		row_number() over(partition by t.YYYYMM, t.id  order by a.row_id desc) rn,
		sum(pack_qty) over(partition by t.YYYYMM, t.id) qty 
		from cu.v_user_3month_list t
			join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
			join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE = 'CIGARETTES' and cigatype !='CSV'
			join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
		where  t.YYYYMM >= '202401'
	) as t
	where rn = 1 -- gr_cd 마지막 구매지역
	and qty > 1
)
select t.YYYYMM,  COALESCE(gr_cd, '합계') 'Gr Region',
	count(distinct t.id) 'HnB Total',
	sum(PACK_QTY) 'HnB Total Pack'
from temp t
	join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE = 'CIGARETTES' and cigatype ='HnB'
group by 
	grouping sets (
	(t.YYYYMM, gr_cd), 
	(t.YYYYMM) 
	)
order by YYYYMM, 'Gr Region'
;



-- Gr지역별 전체 HnB 구매 :  HnB_New_Purchasers, HnB_New_Purchasers_pack
with temp as (
	select * 
	from ( 
		select t.YYYYMM, t.id, SIDO_NM ,
			row_number() over(partition by t.YYYYMM, t.id  order by a.row_id desc) rn 
		from  cu.user_3month_list  t 
		   join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM
		   join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype = 'HnB'
		where 
			not exists (
				select 1
			      from cu.Fct_BGFR_PMI_Monthly x
			   		join cu.dim_product_master y on x.ITEM_CD = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' and y.cigatype != 'CSV'
				where
			       x.YYYYMM < t.YYYYMM			-- 이전에 구매이력이 있으면 안됨. 최초 구매 월만
				and t.id = x.id
				and y.ProductSubFamilyCode = b.ProductSubFamilyCode   
			)
	--	and b.ProductSubFamilyCode in ('NEO', 'NEOSTICKS')
	) as t
	where rn = 1
)
select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct t.id) HnB_New_Purchasers,
	sum(a.PACK_QTY) HnB_New_Purchasers_pack
from temp t
	join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype = 'HnB'
--		and b.ProductSubFamilyCode in ('NEO', 'NEOSTICKS')
	join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
where t.YYYYMM >='202401'
group by
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM)
	)
order by YYYYMM, 'Gr Region'
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



-- MIIX / TEREA Total Purchasers 각각 조건 넣어야 함.
with temp as (
	select * 
	from ( 
		select t.YYYYMM, t.id, a.SIDO_NM , gr_cd, 
		row_number() over(partition by t.YYYYMM, t.id , ProductSubFamilyCode order by a.row_id desc) rn
		from cu.cu_user_3month_list_incl_csv t
			join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
			join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype ='HnB'
				and ProductSubFamilyCode = 'MIIX'		-- 조건 1
			join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
		where  t.YYYYMM >= '202401'
	) as t
	where rn = 1
)
select t.YYYYMM,  COALESCE(gr_cd, '합계') 'Gr Region',
	count(distinct case when ProductSubFamilyCode ='TEREA' then t.id end) 'TEREA',
	sum(case when ProductSubFamilyCode ='TEREA' then PACK_QTY else 0 end) 'TEREA Pack',
	count(distinct case when ProductSubFamilyCode ='MIIX' then t.id end) 'MIIX',
	sum( case when ProductSubFamilyCode ='MIIX' then PACK_QTY else 0 end) 'MIIX Pack'
from temp t
	join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE = 'CIGARETTES' and cigatype ='HnB'
		and ProductSubFamilyCode = 'MIIX'			-- 조건 2
group by 
	grouping sets (
	(t.YYYYMM, gr_cd), 
	(t.YYYYMM) 
	)
;




---	Gr. 지역 별 MIIX 신규 구매자
select t.YYYYMM,  COALESCE(gr_cd, '합계')  'Gr Region' ,
	count(distinct t.id) SKU_New_Purchaser_cnt,
	sum(a.PACK_QTY) SKU_New_Purchased_Pack
from cu.agg_CU_MIIX_Total_Sourcing  t
	join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE = 'CIGARETTES' and b.cigatype = 'HnB'
		and productSubFamilyCode ='MIIX'			-- 조건 
	join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
where t.YYYYMM >= '202401'
group by 
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM)
	)
order by YYYYMM, 'Gr Region'
;

-- Gr. 지역 별 TEREA  신규 구매자
select t.YYYYMM,  COALESCE(gr_cd, '합계')  'Gr Region' ,
	count(distinct t.id) SKU_New_Purchaser_cnt,
	sum(a.PACK_QTY) SKU_New_Purchased_Pack
from cu.agg_CU_TEREA_Total_Sourcing t
	join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE = 'CIGARETTES' and b.cigatype = 'HnB'
		and productSubFamilyCode ='TEREA'			-- 조건 
	join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
where t.YYYYMM >= '202401'
group by 
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM)
	)
order by YYYYMM, 'Gr Region'
;



-- 검증 작업
-- Gr Region 두 곳 이상에서 구매한 사람들 추출 
select YYYYMM, id , count(*)
from ( 
	select t.YYYYMM, c.gr_cd, t.id
	from cu.cu_user_3month_list_incl_csv t
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
order by YYYYMM, 'Gr Region';


--
--select * 
--from cu.agg_CU_TEREA_Total_Sourcing t
--		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
--		and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
--				 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
--	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' and b.cigatype='HnB'
--	join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
--where t.YYYYMM >= '202401'
--and gr_cd ='광주'
--and b.company != 'PMK'
--and t.id ='4138b4bee8c0745ffab1f5c39ea113336d607303831d9fbc5473509cb914e426'
;

---	Gr.지역 별 sourcing 작업해주신 내용에서 cc 에서 유입인 경우 cc family / subfamily / taste segment
--		(t.YYYYMM, gr_cd, ProductFamilyCode, ProductSubFamilyCode, FLAVORSEG_type3)

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
order by YYYYMM, 'Gr Region'
;

-- Exclusive Taste ( 3개월 기간 / 현재 기간)
with temp as (
	select t.YYYYMM, 
		gr_cd, 
		t.id, 
		min(b.FLAVORSEG_type3 ) + ' Only' FLAVORSEG_type3 
	from cu.agg_CU_TEREA_Total_Sourcing t
			join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
--			and a.YYYYMM = t.YYYYMM
			and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
					 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
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






--	Gr.지역 별 sourcing 작업해주신 내용에서 current usage에서 iqos only 인 경우의 terea taste segment, terea sku usage
-- PiVot 진행 필요
-- Taste Segment
with temp as (
	select  
		t.YYYYMM, 
		gr_cd,
		t.id,
		max(case when b.cigatype='HnB' and b.company = 'PMK' then 1 else 0 end) IQOS_Purchased,
		max(case when b.cigatype='CC' then 1 else 0 end) CC_Purchased,
		max(case when b.cigatype='HnB' and b.company != 'PMK' then 1 else 0 end) CompHnB_Purchased
	from  cu.agg_CU_TEREA_Total_Sourcing t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
			and a.YYYYMM = t.YYYYMM
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
		join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
	where 1=1
	and t.YYYYMM >= '202401'
	group BY 	    	
		t.YYYYMM, 
		gr_cd,
		t.id
	having 
	--	IQOS Only 조건만
		 max(case when b.cigatype='HnB' and b.company = 'PMK' then 1 else 0 end)  > 0 
		 and max(case when b.cigatype='CC' then 1 else 0 end) = 0 
		 and max(case when b.cigatype='HnB' and b.company != 'PMK' then 1 else 0 end) = 0
)
select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	FLAVORSEG_type3,
	count(distinct t.id) n
from temp t
	join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
		and a.YYYYMM = t.YYYYMM
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
		and ProductSubFamilyCode = 'TEREA'
where 1=1 
group by 
	grouping sets ( 
		(t.YYYYMM, gr_cd, FLAVORSEG_type3 ),
		(t.YYYYMM, FLAVORSEG_type3 )
	)
;

-- terea sku usage
with temp as (
	select  
		t.YYYYMM, 
		gr_cd,
		t.id,
		max(case when b.cigatype='HnB' and b.company = 'PMK' then 1 else 0 end) IQOS_Purchased,
		max(case when b.cigatype='CC' then 1 else 0 end) CC_Purchased,
		max(case when b.cigatype='HnB' and b.company != 'PMK' then 1 else 0 end) CompHnB_Purchased
	from  cu.agg_CU_TEREA_Total_Sourcing t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
			and a.YYYYMM = t.YYYYMM
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
		join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
	where 1=1
	and t.YYYYMM >= '202401'
	group BY 	    	
		t.YYYYMM, 
		gr_cd,
		t.id
	having 
	--	IQOS Only 조건만
		 max(case when b.cigatype='HnB' and b.company = 'PMK' then 1 else 0 end)  > 0 
		 and max(case when b.cigatype='CC' then 1 else 0 end) = 0 
		 and max(case when b.cigatype='HnB' and b.company != 'PMK' then 1 else 0 end) = 0
)
select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	engname,
	count(distinct t.id) n
from temp t
	join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
		and a.YYYYMM = t.YYYYMM
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
		and ProductSubFamilyCode = 'TEREA'
where 1=1 
group by 
	grouping sets ( 
		(t.YYYYMM, gr_cd, engname ),
		(t.YYYYMM, engname )
	)
;

-- IQOS Only Total
with temp as (
	select  
		t.YYYYMM, 
		gr_cd,
		t.id,
		max(case when b.cigatype='HnB' and b.company = 'PMK' then 1 else 0 end) IQOS_Purchased,
		max(case when b.cigatype='CC' then 1 else 0 end) CC_Purchased,
		max(case when b.cigatype='HnB' and b.company != 'PMK' then 1 else 0 end) CompHnB_Purchased
	from  cu.agg_CU_TEREA_Total_Sourcing t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
			and a.YYYYMM = t.YYYYMM
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
		join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
	where 1=1
	and t.YYYYMM >= '202401'
	group BY 	    	
		t.YYYYMM, 
		gr_cd,
		t.id
	having 
	--	IQOS Only 조건만
		 max(case when b.cigatype='HnB' and b.company = 'PMK' then 1 else 0 end) > 0 
		 and max(case when b.cigatype='CC' then 1 else 0 end) = 0 
		 and max(case when b.cigatype='HnB' and b.company != 'PMK' then 1 else 0 end) = 0
)
select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct t.id) n
from temp t
	join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
		and a.YYYYMM = t.YYYYMM
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
		and ProductSubFamilyCode = 'TEREA'
where 1=1 
group by 
	grouping sets ( 
		(t.YYYYMM, gr_cd ),
		(t.YYYYMM )
	)


select * from cu.dim_product_master 
where 1=1 --ProductSubFamilyCode = 'TEREA'
and FLAVORSEG is not null and FLAVORSEG_type3 is null;



--	# Gr.지역 별 sourcing 작업해주신 내용에서 current usage에서 iqos+cc인 경우의 terea taste segment, terea sku usage

-- PiVot 진행 필요
-- Terea Current Taste Segment
with temp as (
	select  
		t.YYYYMM, 
		gr_cd,
		t.id,
		max(case when b.cigatype='HnB' and b.company = 'PMK' then 1 else 0 end) IQOS_Purchased,
		max(case when b.cigatype='CC' then 1 else 0 end) CC_Purchased,
		max(case when b.cigatype='HnB' and b.company != 'PMK' then 1 else 0 end) CompHnB_Purchased
	from  cu.agg_CU_TEREA_Total_Sourcing t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
			and a.YYYYMM = t.YYYYMM
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
		join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
	where 1=1
	and t.YYYYMM >= '202401'
	group BY 	    	
		t.YYYYMM, 
		gr_cd,
		t.id
	having 
	--	IQOS + CC 조건만
		 max(case when b.cigatype='HnB' and b.company = 'PMK' then 1 else 0 end)  > 0 
		 and max(case when b.cigatype='CC' then 1 else 0 end) > 0 
		 --and max(case when b.cigatype='HnB' and b.company != 'PMK' then 1 else 0 end) = 0
)
select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	FLAVORSEG_type3,
	count(distinct t.id) n
from temp t
	join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
		and a.YYYYMM = t.YYYYMM
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
		and ProductSubFamilyCode = 'TEREA'
where 1=1 
group by 
	grouping sets ( 
		(t.YYYYMM, gr_cd, FLAVORSEG_type3 ),
		(t.YYYYMM, FLAVORSEG_type3 )
	)
;

-- terea Current sku usage
with temp as (
	select  
		t.YYYYMM, 
		gr_cd,
		t.id,
		max(case when b.cigatype='HnB' and b.company = 'PMK' then 1 else 0 end) IQOS_Purchased,
		max(case when b.cigatype='CC' then 1 else 0 end) CC_Purchased,
		max(case when b.cigatype='HnB' and b.company != 'PMK' then 1 else 0 end) CompHnB_Purchased
	from  cu.agg_CU_TEREA_Total_Sourcing t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
			and a.YYYYMM = t.YYYYMM
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
		join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
	where 1=1
	and t.YYYYMM >= '202401'
	group BY 	    	
		t.YYYYMM, 
		gr_cd,
		t.id
	having 
	--	IQOS + CC 조건만
		 max(case when b.cigatype='HnB' and b.company = 'PMK' then 1 else 0 end)  > 0 
		 and max(case when b.cigatype='CC' then 1 else 0 end) > 0 
		 --and max(case when b.cigatype='HnB' and b.company != 'PMK' then 1 else 0 end) = 0
)
select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	engname,
	count(distinct t.id) n
from temp t
	join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
		and a.YYYYMM = t.YYYYMM
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
		and ProductSubFamilyCode = 'TEREA'
where 1=1 
group by 
	grouping sets ( 
		(t.YYYYMM, gr_cd, engname ),
		(t.YYYYMM, engname )
	)
;

-- IQOS + CC Total
with temp as (
	select  
		t.YYYYMM, 
		gr_cd,
		t.id,
		max(case when b.cigatype='HnB' and b.company = 'PMK' then 1 else 0 end) IQOS_Purchased,
		max(case when b.cigatype='CC' then 1 else 0 end) CC_Purchased,
		max(case when b.cigatype='HnB' and b.company != 'PMK' then 1 else 0 end) CompHnB_Purchased
	from  cu.agg_CU_TEREA_Total_Sourcing t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
			and a.YYYYMM = t.YYYYMM
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
		join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
	where 1=1
	and t.YYYYMM >= '202401'
	group BY 	    	
		t.YYYYMM, 
		gr_cd,
		t.id
	having 
	--	IQOS + CC 조건만
		 max(case when b.cigatype='HnB' and b.company = 'PMK' then 1 else 0 end) > 0 
		 and max(case when b.cigatype='CC' then 1 else 0 end) > 0 
		 --and max(case when b.cigatype='HnB' and b.company != 'PMK' then 1 else 0 end) = 0
)
select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct t.id) n
from temp t
	join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
		and a.YYYYMM = t.YYYYMM
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
		and ProductSubFamilyCode = 'TEREA'
where 1=1 
group by 
	grouping sets ( 
		(t.YYYYMM, gr_cd ),
		(t.YYYYMM )
	)
