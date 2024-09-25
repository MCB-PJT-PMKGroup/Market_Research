with temp as (
select * 
from ( 
	select t.YYYYMM, t.id, SIDO_NM ,
--		row_number() over (partition by t.id order by t.YYYYMM) rn 
		row_number() over(partition by t.YYYYMM, t.id order by a.seq desc) rn 
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
	and b.ProductSubFamilyCode = 'MIIX'
) as t
where rn = 1
)
select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct t.id) HnB_New_Purchasers,
	sum(a.PACK_QTY) pack
from temp t
	join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype = 'HnB'
		and b.ProductSubFamilyCode = 'MIIX'
	join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
where t.YYYYMM ='202406'
group by
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM)
	)
;


with temp as (
select * 
from ( 
	select t.YYYYMM, t.id, SIDO_NM ,
--		row_number() over (partition by t.id order by t.YYYYMM) rn 
		row_number() over(partition by t.YYYYMM, t.id order by a.seq desc) rn 
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
--	and b.ProductSubFamilyCode = 'MIIX'
) as t
where rn = 1
)
select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct t.id) HnB_New_Purchasers,
	sum(a.PACK_QTY) pack
from temp t
	join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype = 'HnB'
--		and b.ProductSubFamilyCode = 'MIIX'
	join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
where t.YYYYMM ='202406'
group by
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM)
	)
;



select * from cu.v_user_3month_list ;

with temp as ( 
	select a.YYYYMM, a.id
	from  cu.Fct_BGFR_PMI_Monthly a 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
	where a.YYYYMM >= '202211'
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
	   and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만;
)
select t.YYYYMM, t.id, a.SIDO_NM , gr_cd, 	
	a.gender,
	a.age,
	row_number() over(partition by t.YYYYMM, t.id order by a.seq desc) rn
from temp t
	join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype != 'CSV'
	join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm

	
	
	

select  t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct t.id) Purchasers 
from ( 
	select t.YYYYMM, 
		t.id, 
		a.SIDO_NM , gr_cd, 	
		a.gender,
		a.age, 
		row_number() over(partition by t.YYYYMM, t.id order by a.seq desc) rn
	from cu.v_user_3month_list t
		join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype != 'CSV'
		join cu.dim_Regional_area c on a.SIDO_NM = c.sido_nm
	where a.YYYYMM = '202406'
) as t
where rn = 1
group by YYYYMM, gr_cd
;


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


select t.YYYYMM, sido_nm,
	count(distinct t.id) total_Purchaser_cnt, 
	count(case when gender ='1' then 1 end ) 'Male',
	count(case when gender ='2' then 1 end ) 'Female',
	count(case when age in ( '1','2') then 1 end) '20s',
	count(case when age = '3' then 1 end) '30s',
	count(case when age = '4' then 1 end) '40s',
	count(case when age = '5' then 1 end) '50s',
	count(case when age = '6' then 1 end) '60s'
from ( 
		select t.YYYYMM, t.id, a.SIDO_NM, 	
		a.gender,
		a.age,
		row_number() over(partition by t.YYYYMM, t.id order by a.seq desc) rn
		from cu.v_user_3month_list t
			join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
			join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype != 'CSV'
		where  t.YYYYMM = '202406'
	) as t
where rn = 1	-- 마지막 구매만 추출
group by t.YYYYMM, sido_nm
;




--	Gr.지역 별 sourcing 작업해주신 내용에서 current usage에서 iqos only 인 경우의 terea taste segment, terea sku usage
select *  
from ( 
		select t.YYYYMM, t.id, a.SIDO_NM , gr_cd, FLAVORSEG_type3,
		a.gender,
		a.age,
		row_number() over(partition by t.YYYYMM, t.id, b.FLAVORSEG_type3 order by a.seq desc) rn
		from cu.agg_CU_TEREA_Total_Sourcing t
			join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
			join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
				and ProductSubFamilyCode = 'TEREA'
			join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
		where  t.YYYYMM = '202406'
	) as t
where rn = 1	-- 마지막 구매만 추출
;


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
	 max(case when b.cigatype='HnB' and b.company = 'PMK' then 1 else 0 end)  > 0 
	 and max(case when b.cigatype='CC' then 1 else 0 end) = 0 
	 and max(case when b.cigatype='HnB' and b.company != 'PMK' then 1 else 0 end) = 0
)
select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct t.id) n
from temp t
	join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
		and a.YYYYMM = t.YYYYMM
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
		and 
where 1=1 
group by 
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM )
	)
;


--	Gr.지역 별 sourcing 작업해주신 내용에서 current usage에서 iqos+cc인 경우의 terea taste segment, terea sku usage



select ym_cd, SIDO_CD , cust_id, item_cd
from cu.BGFR_PMI_202407 
group by ym_cd, SIDO_CD , cust_id, item_cd
having count(*) >1;

select * from cu.Fct_BGFR_PMI_Monthly 
where YYYYMM ='202301';


select yyyymm, count(*)
from cx.v_user_3month_list 
group by yyyymm;


select yyyymm, count(*)
from cx.seven11_user_3month_list 
group by yyyymm;


select * from cx.product_master
where 1=1-- [check] = 'new'
and cigatype ='CC'
and FLAVORSEG_type3 ='New Taste';


select YYYYMM, count(*) 
from cx.v_user_3month_list 
group by YYYYMM;



select * 
from cx.seven11_user_3month_list 
where id ='00B173F289BDEE8A52A24CE74B736DDC27AA2D86E513A6C00DD15D4D28D3AB0E'
order by YYYYMM;

-- 7개
select b.engname, * from cx.fct_K7_Monthly a
	join cx.product_master b on a.product_code  = b.PROD_ID 
where id ='00B173F289BDEE8A52A24CE74B736DDC27AA2D86E513A6C00DD15D4D28D3AB0E'
order by de_dt;

-- Cohort 분석 중 2가지 케이스
-- 04517C447A73A95CB2C3D26849A9662FB9A6AE031DC46FFBD64205B383A5B930 202302 기록 있는데 왜 빠지지??  그래서 202303월 초기 구매로 잡힘
-- 04792C5FEA2E970AE8AA8DBA4DA775B2B508BB9EFDB321AFCCB948A61D75DF29 202304 구매 기록이 없으니 빠져야함... 하란님 요청사항



select *
from cx.first_purchaser
where engname ='MEVIUS CITRO WAVE'
and first_purchase ='202404';



-- 이전 구매내역 필터 전
with Total_purchaser as(
	-- (2) 전체 구매이력 있는지 구매자 추출
	select
 		engname, t.YYYYMM, t.id
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
		having count(distinct a.yyyymm) = 4
	)
	and t.YYYYMM >= '202201'
	group by engname, t.YYYYMM, t.id
)
	select b.engname, 
		t.id, 
		min(a.YYYYMM) first_purchase 
	from Total_purchaser t
		join cx.fct_K7_Monthly a on t.id = a.id and t.YYYYMM = a.YYYYMM
		join cx.product_master b on a.product_code = b.PROD_ID  and CIGADEVICE ='CIGARETTES' and CIGATYPE != 'CSV' 
	where b.engname ='DUNHILL ALPS BOOST'
	group by b.engname, t.id
	having min(a.YYYYMM) = '202204'

;



insert into cx.fct_K7_Monthly 
select 
	de_dt
	,product_code
	,id
	,buy_ct
	,left(de_dt, 6) YYYYMM
	,buy_ct * cast(SAL_QNT as decimal) Pack_qty
	,gender
	,age
	,rct_seq
from cx.K7_202408 a
	left join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and 4 < len(a.id) and b.CIGATYPE != 'CSV'
;





insert into cx.product_master 
select a.*,
		CASE 
	        WHEN a.FLAVORSEG like 'FS1:%' THEN 'Regular'
	        WHEN a.FLAVORSEG like 'FS2:%' THEN 'Fresh'
	        WHEN a.FLAVORSEG like 'FS3:%' THEN 'Fresh'
	        WHEN a.FLAVORSEG like 'FS4:%' THEN 'New Taste'
	        WHEN a.FLAVORSEG like 'FS5:%' THEN 'Fresh'
	        WHEN a.FLAVORSEG like 'FS7:%' THEN 'New Taste'
	        WHEN a.FLAVORSEG like 'FS8:%' THEN 'New Taste'
	        WHEN a.FLAVORSEG like 'FS9:%' THEN 'New Taste'
	        WHEN a.FLAVORSEG like 'FS10:%' THEN 'New Taste'
	        WHEN a.FLAVORSEG like 'FS11:%' THEN 'Fresh'
	        WHEN a.FLAVORSEG like 'FS12:%' THEN 'Fresh'
	        WHEN a.FLAVORSEG like 'FS13:%' THEN 'Fresh'
	        WHEN a.FLAVORSEG like 'FS14:%' THEN 'New Taste'
	        when a.FLAVORSEG like 'Aftercut (New%' then 'New Taste'
	        when a.FLAVORSEG like 'Regular Fresh' then 'Fresh' 
	        when a.FLAVORSEG like 'Regular to Fresh' then 'Fresh'
			when a.FLAVORSEG like 'Regular to New Taste' then 'New Taste'
			when a.FLAVORSEG like 'Fresh to New Taste' then 'New Taste'
	        ELSE a.FLAVORSEG
    	END as FLAVORSEG_type3,
		CASE 
	    	when a.TARSEGMENTAT like 'TS1:%' then 'FF'
	    	when a.TARSEGMENTAT like 'TS2:%' then 'LTS'
	    	when a.TARSEGMENTAT like 'TS3:%' then 'ULT'
	    	when a.TARSEGMENTAT like 'TS4:%' then '1MG'
	    	when a.TARSEGMENTAT like 'TS5:%' then 'Below 1MG'
	    	else a.TARSEGMENTAT 
	    END as New_TARSEGMENTAT,
    	CASE 
		    WHEN a.FLAVORSEG like 'FS1:%' THEN 'Regular'
		    WHEN a.FLAVORSEG like 'FS2:%' THEN 'Regular to Fresh'
		    WHEN a.FLAVORSEG like 'FS3:%' THEN 'Regular to Fresh'
		    WHEN a.FLAVORSEG like 'FS4:%' THEN 'Regular to New Taste'
		    WHEN a.FLAVORSEG like 'FS5:%' THEN 'Fresh to Fresh'
		    WHEN a.FLAVORSEG like 'FS7:%' THEN 'New Taste'
		    WHEN a.FLAVORSEG like 'FS8:%' THEN 'Fresh to New Taste'
		    WHEN a.FLAVORSEG like 'FS9:%' THEN 'Fresh to New Taste'
		    WHEN a.FLAVORSEG like 'FS10:%' THEN 'Regular to New Taste'
		    WHEN a.FLAVORSEG like 'FS11:%' THEN 'Fresh to Fresh'
		    WHEN a.FLAVORSEG like 'FS12:%' THEN 'Regular to Fresh'
		    WHEN a.FLAVORSEG like 'FS13:%' THEN 'Regular Fresh'
		    WHEN a.FLAVORSEG like 'FS14:%' THEN 'New Taste'
		    when a.FLAVORSEG like 'Aftercut (New%' then 'New Taste'
		    when a.FLAVORSEG like 'Regular Fresh' then 'Regular Fresh' 
		    when a.FLAVORSEG like 'Regular to Fresh' then 'Regular to Fresh'
			when a.FLAVORSEG like 'Regular to New Taste' then 'Regular to New Taste'
			when a.FLAVORSEG like 'Fresh to New Taste' then 'Fresh to New Taste'
    	ELSE a.FLAVORSEG
    	end as FLAVORSEG_type6,
    	'N' NPL_YN
from cx.product_master_tmp a
	left join  cx.product_master b on a.PROD_ID = b.PROD_ID 
where b.prod_id is null;

