/*
 * 2024.08.28 작업 시작
 * 
 * CU 대상 HnB / CC  Brand Family 집계
 * 
 * 
 */

select distinct ProductFamilyCode , CIGATYPE 
from cu.dim_product_master 
where CIGATYPE != 'CSV'; 


--	(월 별) 전체/ Gr. 지역별 total tobacco purchaser
select  t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct t.id) Tobacco_Purchaser 
from ( 
	select t.YYYYMM, t.id, a.SIDO_NM , gr_cd, row_number() over(partition by t.YYYYMM, t.id order by a.seq desc) rn
	from cu.v_user_3month_list t
		join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype != 'CSV'
		join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
	where  t.YYYYMM >= '202401'
) as t
where rn = 1
group by 
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM)
	)
;


--  (월 별) 전체/ Gr. 지역별 total cc purchaser
select  t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct t.id) Tobacco_Purchaser 
from ( 
	select t.YYYYMM, t.id, a.SIDO_NM , gr_cd, row_number() over(partition by t.YYYYMM, t.id order by a.seq desc) rn
	from cu.v_user_3month_list t
		join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype = 'CC'
		join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
	where  t.YYYYMM >= '202401'
) as t
where rn = 1
group by 
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM)
	)
;





---	(6월) 전체/Gr.지역별 CC purchaser brand family
select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region', ProductFamilyCode,
	count(distinct t.id) CC_Purchaser 
from ( 
	select t.YYYYMM, t.id, a.SIDO_NM , gr_cd, b.ProductFamilyCode, row_number() over(partition by t.YYYYMM, t.id order by a.seq desc) rn
	from cu.v_user_3month_list t
		join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype = 'CC'
		join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
	where  t.YYYYMM = '202406'
) as t
where rn = 1
group by 
	grouping sets ( 
		(t.YYYYMM, gr_cd, ProductFamilyCode),
		(t.YYYYMM, ProductFamilyCode)
	)
;
	

---	(6월) 전체/Gr.지역별 HNB purchaser brand family
select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region', ProductSubFamilyCode,
	count(distinct t.id) HnB_Purchaser 
from ( 
	select t.YYYYMM, t.id, a.SIDO_NM , gr_cd, case when ProductSubFamilyCode in ('NEO', 'NEOSTICKS') then 'NEO' else ProductSubFamilyCode end ProductSubFamilyCode,
		row_number() over(partition by t.YYYYMM, t.id , (case when ProductSubFamilyCode in ('NEO', 'NEOSTICKS') then 'NEO' else ProductSubFamilyCode end ) order by a.seq desc) rn
	from cu.v_user_3month_list t
		join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype = 'HnB'
			and ProductSubFamilyCode in ('NEO', 'NEOSTICKS')
		join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
	where  t.YYYYMM = '202406'
) as t
where rn = 1
group by 
	grouping sets ( 
		(t.YYYYMM, gr_cd, ProductSubFamilyCode),
		(t.YYYYMM, ProductSubFamilyCode)
	)
;


--	Gr.지역 별 sourcing 작업해주신 내용에서 cc 에서 유입인 경우 Price분포를 볼 수 있을까요? 4500원 미만 / 4500원 / 4500원 초과 
-- Past 3 month CC price distribution
select  
	t.YYYYMM, COALESCE(gr_cd, '합계') 'Gr Region',
	count(distinct x.id) purchasers,
	count(distinct case when price < 4500 then t.id end) 'less than 4500',
	count(distinct case when price = 4500 then t.id end) '4500',
	count(distinct case when price > 4500 then t.id end) 'greater than 4500'
from cu.agg_CU_TEREA_Total_Sourcing t	
	join cu.Fct_BGFR_PMI_Monthly x on t.id = x.id 
		and x.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
		 	     		 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)
	join cu.dim_product_master b on x.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' and b.cigatype='CC'
	join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
where 1=1
and t.YYYYMM >= '202406'
group BY
	grouping sets (
		(t.YYYYMM, gr_cd),
		(t.YYYYMM)
	)
;

--update a 
--set price = NOW_SLPR
--from cu.Fct_BGFR_PMI_Monthly a
--	join cu.BGFR_PMI_202403 b on a.id = b.CUST_ID and a.SIDO_NM = b.SIDO_NM and a.YYYYMM = b.YM_CD and a.ITEM_CD = b.ITEM_CD 
--where a.YYYYMM = '202403';




---	Gr.지역 별 sourcing 작업해주신 내용에서 current usage에서 cc인 경우 같이 사용하고 있는 경우 price 분포 - 4500원 미만 / 4500원 / 4500원 초과
-- Current CC price distribution
select  
	t.YYYYMM, COALESCE(gr_cd, '합계') 'Gr Region',
	count(distinct t.id) purchasers,
	count(distinct case when price < 4500 then t.id end) 'less than 4500',
	count(distinct case when price = 4500 then t.id end) '4500',
	count(distinct case when price > 4500 then t.id end) 'greater than 4500'
from cu.agg_CU_TEREA_Total_Sourcing t	
	join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
		and a.YYYYMM  = t.YYYYMM 
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE = 'CIGARETTES' and b.cigatype='CC'
	join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
where 1=1
and t.YYYYMM >= '202406'
group BY
	grouping sets (
		(t.YYYYMM, gr_cd),
		(t.YYYYMM)
	)
;


-- 202406 강원도 CC ITEM_CD
-- 202406 경기도 HnB 

--- (6월) Gr.지역 별 sourcing 작업해주신 내용에서 current usage에서 cc+iqos 현재도 같이 사용하고 있는 경우 평균 cc:iqos 비율을 볼 수 있을까요?
with temp as(   
	select
		t.YYYYMM, 
		gr_cd,
		t.id,
		sum(case when b.cigatype='HnB' and b.company = 'PMK' then a.SALE_QTY end) IQOS_Purchased,
		sum(case when b.cigatype='CC' then a.SALE_QTY end) CC_Purchased,
		sum(case when b.cigatype='HnB' and b.company = 'PMK' then a.SALE_QTY end) + sum(case when b.cigatype='CC' then a.SALE_QTY end) CompHnB_Purchased,
		sum(case when b.cigatype='HnB' and b.company = 'PMK' then a.SALE_QTY end) / (sum(case when b.cigatype='HnB' and b.company = 'PMK' then a.SALE_QTY end) + sum(case when b.cigatype='CC' then a.SALE_QTY end)) *100 iqos_per,
		sum(case when b.cigatype='CC' then a.SALE_QTY end) / (sum(case when b.cigatype='HnB' and b.company = 'PMK' then a.SALE_QTY end) + sum(case when b.cigatype='CC' then a.SALE_QTY end)) * 100 cc_per
	from  cu.agg_CU_TEREA_Total_Sourcing t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
			and a.YYYYMM = t.YYYYMM						-- current usage
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE = 'CIGARETTES' AND  b.cigatype != 'CSV' 
		join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
	where t.YYYYMM >= '202406'
	group BY 	    	
		t.YYYYMM, 
		gr_cd,
		t.id
	having  sum(case when b.cigatype='HnB' and b.company = 'PMK' then a.SALE_QTY end) > 0
		and sum(case when b.cigatype='CC' then a.SALE_QTY end)  > 0
)
select YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	avg(iqos_per) iqos_per,
	avg(cc_per) cc_per, 
	avg(IQOS_Purchased) IQOS_Purchased_ratio, 
	avg(CC_Purchased) CC_Purchased_ratio
from temp 
group by 
	grouping sets ( 
		(YYYYMM, gr_cd),
		(YYYYMM )
	)
;



	
---	(6월) 전체/Gr.지역별 total tobacco purchaser 연령/성별/Previous Category Usage (Past 3M – CC, HNB, DUAL)
select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct t.id) total_Purchaser_cnt, 
	count(case when gender ='1' then 1 end ) 'Male',
	count(case when gender ='2' then 1 end ) 'Female',
	count(case when age in ( '1','2') then 1 end) '20s',
	count(case when age = '3' then 1 end) '30s',
	count(case when age = '4' then 1 end) '40s',
	count(case when age = '5' then 1 end) '50s',
	count(case when age = '6' then 1 end) '60s'
from ( 
		select t.YYYYMM, t.id, a.SIDO_NM , gr_cd, 	
		a.gender,
		a.age,
		row_number() over(partition by t.YYYYMM, t.id order by a.seq desc) rn
		from cu.v_user_3month_list t
			join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
			join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype != 'CSV'
			join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
		where  t.YYYYMM = '202406'
	) as t
where rn = 1
group by
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM )
	)
;


-- Old
with temp as (
select
	t.YYYYMM, 
	a.SIDO_NM,
	t.id,
	a.gender,
	a.age
from cu.v_user_3month_list t
	join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id and t.YYYYMM = a.YYYYMM and  t.seq = a.seq
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
where t.YYYYMM = '202406'
)
select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct t.id) total_Purchaser_cnt, 
	count(case when gender ='1' then 1 end ) 'Male',
	count(case when gender ='2' then 1 end ) 'Female',
	count(case when age in ( '1','2') then 1 end) '20s',
	count(case when age = '3' then 1 end) '30s',
	count(case when age = '4' then 1 end) '40s',
	count(case when age = '5' then 1 end) '50s',
	count(case when age = '6' then 1 end) '60s'
from temp t
	join cu.dim_Regional_area c on t.SIDO_NM = c.sido_nm
where 1=1
group by
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM )
	)
;


--			 구매자가 이전 3개월 동안 무엇을 구매했는지
--			and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
--							 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	


-- Current Category Usage 

with temp as (
	select
		YYYYMM, 
		gr_cd,
		id
	from ( 
		select t.YYYYMM, t.id, a.SIDO_NM , gr_cd,
		row_number() over(partition by t.YYYYMM, t.id order by a.seq desc) rn
		from cu.v_user_3month_list t
			join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
			join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype != 'CSV'
			join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
		where  t.YYYYMM = '202406'
	) as t
	where rn = 1
)
select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct case when cigatype ='CC' then t.id end ) 'CC',
	count(distinct case when cigatype ='HnB' then t.id end ) 'HnB',
	count(distinct case when cigatype ='Mixed' then t.id end ) 'Mixed'
from 	
	(select t.YYYYMM, t.gr_cd, t.id,
		    CASE 
		        WHEN SUM(CASE WHEN b.cigatype = 'CC' THEN 1 ELSE 0 END) > 0 
		         AND SUM(CASE WHEN b.cigatype = 'HnB' THEN 1 ELSE 0 END) > 0 
		        THEN 'Mixed' 
		        ELSE MAX(b.cigatype)  -- CC 또는 HnB가 없을 경우 가장 큰 값을 사용
	    	END AS cigatype
	 from temp t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id and t.YYYYMM = a.YYYYMM 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
	group by t.YYYYMM, t.gr_cd, t.id
) as t
group by
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM )
	)
;

-- Old
with temp as (
	select
		t.YYYYMM, 
		a.SIDO_NM,
		t.id
	from cu.v_user_3month_list t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id and t.YYYYMM = a.YYYYMM and  t.seq = a.seq
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
	where t.YYYYMM = '202406'
),
Tobacco_Purchaser as (
	select t.YYYYMM, t.SIDO_NM, t.id,
		    CASE 
		        WHEN SUM(CASE WHEN b.cigatype = 'CC' THEN 1 ELSE 0 END) > 0 
		         AND SUM(CASE WHEN b.cigatype = 'HnB' THEN 1 ELSE 0 END) > 0 
		        THEN 'Mixed' 
		        ELSE MAX(b.cigatype)  -- CC 또는 HnB가 없을 경우 가장 큰 값을 사용
	    	END AS cigatype
	 from temp t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id and t.YYYYMM = a.YYYYMM 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
	group by t.YYYYMM, t.SIDO_NM, t.id
)
select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct case when cigatype ='CC' then t.id end ) 'CC',
	count(distinct case when cigatype ='HnB' then t.id end ) 'HnB',
	count(distinct case when cigatype ='Mixed' then t.id end ) 'Mixed'
from Tobacco_Purchaser t
	join cu.dim_Regional_area c on t.SIDO_NM = c.sido_nm
where gr_cd = '광주'
group by
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM )
	)
;
;

--	count(distinct case when FLAVORSEG_type3 ='Fresh' then t.id end ) 'Fresh Total',
--	count(distinct case when FLAVORSEG_type3 ='New Taste' then t.id end ) 'New Taste Total',
--	count(distinct case when FLAVORSEG_type3 ='Regular' then t.id end ) 'Regular Total',
--	count(distinct case when b.cigatype = 'CC' and FLAVORSEG_type3 ='Fresh' then t.id end ) 'CC Fresh',
--	count(distinct case when b.cigatype = 'CC' and FLAVORSEG_type3 ='New Taste' then t.id end ) 'CC New Taste',
--	count(distinct case when b.cigatype = 'CC' and FLAVORSEG_type3 ='Regular' then t.id end ) 'CC Regular',
--	count(distinct case when b.cigatype = 'HnB' and FLAVORSEG_type3 ='Fresh' then t.id end ) 'HnB Fresh',
--	count(distinct case when b.cigatype = 'HnB' and FLAVORSEG_type3 ='New Taste' then t.id end ) 'HnB New Taste',
--	count(distinct case when b.cigatype = 'HnB' and FLAVORSEG_type3 ='Regular' then t.id end ) 'HnB Regular'



---	(6월) 전체/Gr.지역별 total terea purchaser 연령/성별/Previous Category Usage (Past 3M – CC, HNB, DUAL)

select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct t.id) total_Purchaser_cnt, 
	count(case when gender ='1' then 1 end ) 'Male',
	count(case when gender ='2' then 1 end ) 'Female',
	count(case when age in ( '1','2') then 1 end) '20s',
	count(case when age = '3' then 1 end) '30s',
	count(case when age = '4' then 1 end) '40s',
	count(case when age = '5' then 1 end) '50s',
	count(case when age = '6' then 1 end) '60s'
from ( 
		select t.YYYYMM, t.id, a.SIDO_NM , gr_cd, 	
		a.gender,
		a.age,
		row_number() over(partition by t.YYYYMM, t.id order by a.seq desc) rn
		from cu.v_user_3month_list t
			join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
			join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype = 'HnB'
				and b.ProductSubFamilyCode = 'TEREA'
			join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
		where  t.YYYYMM = '202406'
	) as t
where rn = 1
group by
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM )
	)
;




-- TEREA Past 3 Month Category Usage  (CC, HNB, DUAL)
with temp as (
	select
		t.YYYYMM, 
		a.SIDO_NM,
		t.id
	from cu.v_user_3month_list t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id and t.YYYYMM = a.YYYYMM and  t.seq = a.seq
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
			and b.productSubFamilyCode = 'TEREA'
	where t.YYYYMM = '202406'
),
TEREA_Purchaser as (
	select t.YYYYMM, t.SIDO_NM, t.id,
		    CASE 
		        WHEN SUM(CASE WHEN b.cigatype = 'CC' THEN 1 ELSE 0 END) > 0 
		         AND SUM(CASE WHEN b.cigatype = 'HnB' THEN 1 ELSE 0 END) > 0 
		        THEN 'Mixed' 
		        ELSE MAX(b.cigatype)  -- CC 또는 HnB가 없을 경우 가장 큰 값을 사용
	    	END AS cigatype
	 from temp t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id and t.YYYYMM = a.YYYYMM 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
	group by t.YYYYMM, t.SIDO_NM, t.id
)
select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct case when cigatype ='CC' then t.id end ) 'CC',
	count(distinct case when cigatype ='HnB' then t.id end ) 'HnB',
	count(distinct case when cigatype ='Mixed' then t.id end ) 'Mixed'
from TEREA_Purchaser t
	join cu.dim_Regional_area c on t.SIDO_NM = c.sido_nm
where 1=1
group by
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM )
	)
;

-- TEREA Current Category Usage  (CC, HNB, DUAL)
with temp as (
	select
		YYYYMM, 
		gr_cd,
		id
	from ( 
		select t.YYYYMM, t.id, a.SIDO_NM , gr_cd,
		row_number() over(partition by t.YYYYMM, t.id order by a.seq desc) rn
		from cu.v_user_3month_list t
			join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
			join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype = 'HnB'
				and b.ProductSubFamilyCode = 'TEREA'
			join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
		where  t.YYYYMM = '202406'
	) as t
	where rn = 1
)
select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct case when cigatype ='CC' then t.id end ) 'CC',
	count(distinct case when cigatype ='HnB' then t.id end ) 'HnB',
	count(distinct case when cigatype ='Mixed' then t.id end ) 'Mixed'
from 	
	(select t.YYYYMM, t.gr_cd, t.id,
		    CASE 
		        WHEN SUM(CASE WHEN b.cigatype = 'CC' THEN 1 ELSE 0 END) > 0 
		         AND SUM(CASE WHEN b.cigatype = 'HnB' THEN 1 ELSE 0 END) > 0 
		        THEN 'Mixed' 
		        ELSE MAX(b.cigatype)  -- CC 또는 HnB가 없을 경우 가장 큰 값을 사용
	    	END AS cigatype
	 from temp t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id and t.YYYYMM = a.YYYYMM 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
	group by t.YYYYMM, t.gr_cd, t.id
) as t
group by
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM )
	)
;




---	(6월) 전체/Gr.지역별 total miix purchaser 연령/성별/Previous Category Usage (Past 3M – CC, HNB, DUAL)
select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct t.id) total_Purchaser_cnt, 
	count(case when gender ='1' then 1 end ) 'Male',
	count(case when gender ='2' then 1 end ) 'Female',
	count(case when age in ( '1','2') then 1 end) '20s',
	count(case when age = '3' then 1 end) '30s',
	count(case when age = '4' then 1 end) '40s',
	count(case when age = '5' then 1 end) '50s',
	count(case when age = '6' then 1 end) '60s'
from ( 
		select t.YYYYMM, t.id, a.SIDO_NM , gr_cd, 	
		a.gender,
		a.age,
		row_number() over(partition by t.YYYYMM, t.id order by a.seq desc) rn
		from cu.v_user_3month_list t
			join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
			join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype = 'HnB'
				and b.ProductSubFamilyCode = 'MIIX'
			join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
		where  t.YYYYMM = '202406'
	) as t
where rn = 1
group by
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM )
	)
;

-- MIIX Current Category Usage  (CC, HNB, DUAL)
with temp as (
	select
		YYYYMM, 
		gr_cd,
		id
	from ( 
		select t.YYYYMM, t.id, a.SIDO_NM , gr_cd,
		row_number() over(partition by t.YYYYMM, t.id order by a.seq desc) rn
		from cu.v_user_3month_list t
			join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
			join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype = 'HnB'
				and b.ProductSubFamilyCode = 'MIIX'
			join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
		where  t.YYYYMM = '202406'
	) as t
	where rn = 1
)
select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct case when cigatype ='CC' then t.id end ) 'CC',
	count(distinct case when cigatype ='HnB' then t.id end ) 'HnB',
	count(distinct case when cigatype ='Mixed' then t.id end ) 'Mixed'
from 	
	(select t.YYYYMM, t.gr_cd, t.id,
		    CASE 
		        WHEN SUM(CASE WHEN b.cigatype = 'CC' THEN 1 ELSE 0 END) > 0 
		         AND SUM(CASE WHEN b.cigatype = 'HnB' THEN 1 ELSE 0 END) > 0 
		        THEN 'Mixed' 
		        ELSE MAX(b.cigatype)  -- CC 또는 HnB가 없을 경우 가장 큰 값을 사용
	    	END AS cigatype
	 from temp t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id and t.YYYYMM = a.YYYYMM 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
	group by t.YYYYMM, t.gr_cd, t.id
) as t
group by
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM )
	)
;
	
	
	
	
	



