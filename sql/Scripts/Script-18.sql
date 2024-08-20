   select  *
   from
       cu.Fct_BGFR_PMI_Monthly a
       join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
   where id ='00c32f336e2adf6f183ff4e5fc60d62f212c8528fde3fa57a8635ffec2eca7e3'
  order by seq;
   
 
   select  *
   from
       cu.Fct_BGFR_PMI_Monthly a
       join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
   where id ='00c32f336e2adf6f183ff4e5fc60d62f212c8528fde3fa57a8635ffec2eca7e3';
  
  
    select  YYYYMM  ,SIDO_NM, id,  seq, row_number() over (partition by id order by seq) rn  
   from
       cu.Fct_BGFR_PMI_Monthly a
       join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
   where id ='00c32f336e2adf6f183ff4e5fc60d62f212c8528fde3fa57a8635ffec2eca7e3'
   and b.ProductSubFamilyCode = 'TEREA'  
   group by YYYYMM , SIDO_NM, a.id, seq;
  
  
with temp as( 
select * 
from ( 
   select  YYYYMM  , id, max(seq) seq, row_number() over (partition by id order by YYYYMM) rn  
   from
       cu.Fct_BGFR_PMI_Monthly a
       join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
   where 1=1 -- id ='00c32f336e2adf6f183ff4e5fc60d62f212c8528fde3fa57a8635ffec2eca7e3'
   and b.ProductSubFamilyCode = 'TEREA'  
   group by YYYYMM , a.id
) as t
where rn = 1
)
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
   )
group by t.YYYYMM, t.id 
having
       count(distinct b.engname) < 11 -- (3) SKU 11종 미만
   and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만
;

with temp as( 
select * 
from ( 
   select  YYYYMM  , id, max(seq) seq, row_number() over (partition by id order by YYYYMM) rn  
   from
       cx.fct_K7_Monthly a
       join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
   where 1=1 -- id ='00c32f336e2adf6f183ff4e5fc60d62f212c8528fde3fa57a8635ffec2eca7e3'
   and b.ProductSubFamilyCode = 'TEREA'  
   group by YYYYMM , a.id
) as t
where rn = 1
)
select t.YYYYMM,  t.id
from temp t
   join cx.fct_K7_Monthly a on a.id = t.id  and  a.YYYYMM = t.YYYYMM
   join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
where t.YYYYMM = '202211'
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
   )
group by t.YYYYMM, t.id  
having
       count(distinct b.engname) < 11 -- (3) SKU 11종 미만
   and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만
;


-- 테리아 퍼플 웨이브	2022-11-23	88021492
select b.ProductDescription , * 
from cx.fct_K7_Monthly a
	   JOIN cx.product_master b ON a.product_code = b.PROD_ID AND b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV'
where id ='4FE5AF12A7CF34E59E589A98247AD4D14655ABA6EDC219BF3C8F99A73C4927B1';



select YYYYMM, count(distinct b.engname), sum(a.Pack_qty)
from cx.fct_K7_Monthly a
	   left JOIN cx.product_master b ON a.product_code = b.PROD_ID AND b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV'
where id ='4FE5AF12A7CF34E59E589A98247AD4D14655ABA6EDC219BF3C8F99A73C4927B1'
group by YYYYMM;


select count(*) from cx.product_master ;


--TRUNCATE table cx.product_master_tmp ;

select * 
from cx.product_master
where FLAVORSEG is not NULL
and FLAVORSEG_type3 is null;


--insert into cx.product_master 
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
    	end as FLAVORSEG_type6
from cx.product_master_tmp a
	left join  cx.product_master b on a.PROD_ID = b.PROD_ID 
where b.prod_id is null;


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
from cx.product_master a
where FLAVORSEG is not NULL
and FLAVORSEG_type3 is null;




-- 1,125,632 rows
insert into cx.fct_K7_Monthly 
select 
	de_dt
	,product_code
	,id
	,buy_ct
	,left(de_dt, 6) YYYYMM
	,buy_ct * cast(SAL_QNT as float) Pack_qty
	,gender
	,age
	,rct_seq
from cx.K7_202407 a
	left join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and 4 < len(a.id) and b.CIGATYPE != 'CSV'
;


-- ID가 '미상'인 구매자 제거 1662 Rows
delete 
from cx.fct_K7_Monthly 
WHERE len(id) < 6;


