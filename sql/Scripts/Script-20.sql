with temp as (
	-- (1) 23년 9월 부터 구매자가 월별 구매이력
	select a.YYYYMM, a.id
	from  cu.Fct_BGFR_PMI_Monthly a 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
	where a.YYYYMM >= '202406'
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
  	join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id and t.YYYYMM = a.YYYYMM
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



with temp as (
	-- (1) 23년 9월 부터 구매자가 월별 구매이력
	select a.YYYYMM, a.id ,max(seq) seq
	from  cu.Fct_BGFR_PMI_Monthly a 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.cigatype = 'HnB'
	where a.YYYYMM >= '202406'
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
	count(distinct t.id) 'HnB Total'
from temp t
  	join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id and t.seq = a.seq 
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE = 'CIGARETTES' and cigatype != 'CSV'
	join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
where t.YYYYMM >= '202406'
group by 
	grouping sets (
	(t.YYYYMM, c.gr_cd), 
	(t.YYYYMM) 
	)
order by YYYYMM, 'Gr Region'
;


select * from cu.v_user_3month_list ;

with temp as (
	-- (1) 23년 9월 부터 구매자가 월별 구매이력
	select a.YYYYMM, a.id, max(seq) seq
	from  cu.Fct_BGFR_PMI_Monthly a 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.cigatype = 'HnB'
			and b.ProductSubFamilyCode ='TEREA'
	where a.YYYYMM >= '202406'
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
	count(distinct t.id) 'HnB Total'
from temp t
  	join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id and t.seq = a.seq 
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE = 'CIGARETTES' and cigatype != 'CSV'
	join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
where t.YYYYMM >= '202406'
group by 
	grouping sets (
	(t.YYYYMM, c.gr_cd), 
	(t.YYYYMM) 
	)
order by YYYYMM, 'Gr Region'
;


select * from cu.Fct_BGFR_PMI_Monthly 
where id = '0597dce6e08bc35a213a51eae012d6df94ed0695ea5769658921c1646570c32a';

--drop view cu.v_user_3month_list

select * from  cu.v_user_3month_list;



select a.YYYYMM, a.id, max(seq) seq
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
   and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만
;





UPDATE a 
SET FLAVORSEG_type3 = CASE 
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
    	END ,
		New_TARSEGMENTAT = CASE 
	    	when a.TARSEGMENTAT like 'TS1:%' then 'FF'
	    	when a.TARSEGMENTAT like 'TS2:%' then 'LTS'
	    	when a.TARSEGMENTAT like 'TS3:%' then 'ULT'
	    	when a.TARSEGMENTAT like 'TS4:%' then '1MG'
	    	when a.TARSEGMENTAT like 'TS5:%' then 'Below 1MG'
	    	else a.TARSEGMENTAT 
	    END ,
    	FLAVORSEG_type6 = CASE 
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
    	end 
from cu.dim_product_master a
where FLAVORSEG is not NULL
and FLAVORSEG_type3 is null;



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
select *
from TEREA_Purchaser t
	join cu.dim_Regional_area c on t.SIDO_NM = c.sido_nm
where gr_cd = '광주'
;


select *
from cu.Fct_BGFR_PMI_Monthly a
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
where id = '0439d9b6ab436931a31677cbbcc81bb21f76604578cceee65bf677f5bb055395'
and YYYYMM >= '202406'
;



with temp as(   
	select
		t.YYYYMM, 
		gr_cd,
		t.id,
		sum(case when b.cigatype='HnB' and b.company = 'PMK' then a.SALE_QTY end) IQOS_Purchased,
		sum(case when b.cigatype='CC' then a.SALE_QTY end) CC_Purchased,
		sum(case when b.cigatype='HnB' and b.company = 'PMK' then a.SALE_QTY end) + sum(case when b.cigatype='CC' then a.SALE_QTY end) CompHnB_Purchased,
		sum(case when b.cigatype='HnB' and b.company = 'PMK' then a.SALE_QTY end) / (sum(case when b.cigatype='HnB' and b.company = 'PMK' then a.SALE_QTY end) + sum(case when b.cigatype='CC' then a.SALE_QTY end)) *100 iqos_per,
		sum(case when b.cigatype='CC' then a.SALE_QTY end) / (sum(case when b.cigatype='HnB' and b.company = 'PMK' then a.SALE_QTY end) + sum(case when b.cigatype='CC' then a.SALE_QTY end)) *100 cc_per
	from  cu.agg_CU_TEREA_Total_Sourcing t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
			and a.YYYYMM = t.YYYYMM
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
		join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
	where t.YYYYMM >= '202406'
	group BY 	    	
		t.YYYYMM, 
		gr_cd,
		t.id
	having  sum(case when b.cigatype='HnB' and b.company = 'PMK' then a.SALE_QTY end) > 0
		and sum(case when b.cigatype='CC' then a.SALE_QTY end)  > 0
)
select YYYYMM, gr_cd, avg(iqos_per) iqos_per, avg(cc_per) cc_per, avg(IQOS_Purchased) IQOS_Purchased_ratio, avg(CC_Purchased) CC_Purchased_ratio
from temp 
group by YYYYMM, gr_cd

;

select  t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct t.id) Tobacco_Purchaser 
from ( 
	select t.YYYYMM, t.id, a.SIDO_NM , gr_cd, row_number() over(partition by t.YYYYMM, t.id order by a.seq desc) rn
	from cu.v_user_3month_list t
		join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype ='HnB'
			and ProductSubFamilyCode ='MIIX'
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


select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct t.id) Tobacco_Purchaser
from cu.v_user_3month_list t
	join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype ='HnB'
		and ProductSubFamilyCode ='MIIX'
	join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
where  t.YYYYMM >= '202401'
group by 
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM)
	)
;

--31219748
select * from cu.Fct_BGFR_PMI_Monthly 
where id ='004432a5c036aaa5ff9b2a451e99877bcc3788d6e087c5271a9171426ed3ab07';
select * from cu.v_user_3month_list 
where id ='004432a5c036aaa5ff9b2a451e99877bcc3788d6e087c5271a9171426ed3ab07';
	;
	
select *
from cu.v_user_3month_list t
	join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype ='HnB'
		and productSubFamilyCode = 'TEREA'
	join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
where  t.YYYYMM >= '202406'



	select t.YYYYMM, t.id, a.SIDO_NM , gr_cd, b.ProductSubFamilyCode, row_number() over(partition by t.YYYYMM, t.id order by a.seq desc) rn
	from cu.v_user_3month_list t
		join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype = 'HnB'
			and ProductSubFamilyCode  = 'TEREA'
		join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
	where  t.YYYYMM = '202406';
	



select max(row_id) row_id from cu.BGFR_PMI_202407;
--202301 1637029
--202302 1567616
--202303 1737333
--202304 1734126
--202305 1816764
--202306 1791262
--202307 1801693
--202308 1806478
--202309 1819937
--202310 1797934
--202311 1669557
--202312 1672828
--202401 1637875
--202402 1624032
--202403 1727622
--202404 1773180
--202405 1821034
--202406 1809086
--202407 1806190




-- 직전 3개월 구매이력이 있는 구매자
-- 내 결과는 4,240,360 건
-- user_3month_list CSV는 6,270,511 rows


select count(*)
from ( 
select a.YYYYMM,  a.id
from  cx.fct_K7_Monthly a 
	join cx.product_master b on a.product_code = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
where a.YYYYMM >= '202211'
and
   exists (
       -- (2) 직전 3개월 동안 구매이력이 있는지 확인
       select 1
       from cx.fct_K7_Monthly x
       	join cx.product_master y on x.product_code = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' and y.cigatype != 'CSV'
       where
           x.YYYYMM between convert(nvarchar(6), dateadd(month, -3, a.YYYYMM + '01'), 112)
           				and convert(nvarchar(6), dateadd(month, -1, a.YYYYMM + '01'), 112)
       and a.id = x.id
       group by x.YYYYMM, x.id
	       	   having
	       count(distinct y.engname) < 11 -- (3) SKU 11종 미만
	       and sum(x.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만
   )
group by a.YYYYMM, a.id
having
       count(distinct b.engname) < 11 -- (3) SKU 11종 미만
   and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만
)as t

;

select count(*) from cu.v_user_3month_list ;
--14,724,007 rows CU 3개월 이력
-- CSV는 13,273,204 rows 차이가 있네..



select * 
from cx.fct_K7_Monthly a
where YYYYMM ='202407'
and Pack_qty is null
and product_code in (select prod_id from cx.product_master where  CIGADEVICE = 'CIGARETTES' and cigatype != 'CSV' )
;




CREATE NONCLUSTERED INDEX ix_fct_K7_Monthly_product_code
ON cx.fct_K7_Monthly ( YYYYMM, product_code)
include ( pack_qty);

