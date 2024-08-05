-- Category : CIGATYPE
-- CC, HnB




-- Taste Column : FLAVORSEG
--FS1: Regular						: Regular
--FS2: Regular Fresh				: Fresh
--FS3: Regular to Fresh				: Fresh
--FS4: Regular to New Taste			: New Taste
--FS5: Fresh to Fresh				: Fresh
--FS7: Aftercut (New Taste)			: New Taste
--FS8: Fresh to New Taste			: New Taste
--FS9: NTD (Fresh to NTD)			: New Taste
--FS10: NTD (Regular to NTD)		: New Taste
--FS11: Fresh (Fresh to Fresh)		: Fresh
--FS12: Fresh (Regular to Fresh)	: Fresh
--FS13: Fresh (Regular Fresh)		: Fresh
--FS14: NTD (Aftercut)				: New Taste




--Regular

-- Tar : TARSEGMENTAT 
--TS1: FF
--TS2: LTS
--TS3: ULT
--TS4: 1MG
--TS5: Below 1MG

-- 월별 담배 구매자 모수 테이블 생성.
-- Rows: 14,342,077


CREATE TABLE BPDA.cx.product_master_temp (
	PROD_ID varchar(255) COLLATE Korean_Wansung_CI_AS NOT NULL,
	ENGNAME varchar(255) COLLATE Korean_Wansung_CI_AS NOT NULL,
	ProductDescription varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	ProductFamilyCode varchar(50) COLLATE Korean_Wansung_CI_AS NOT NULL,
	CIGADEVICE varchar(50) COLLATE Korean_Wansung_CI_AS NOT NULL,
	CIGATYPE varchar(50) COLLATE Korean_Wansung_CI_AS NOT NULL,
	FLAVORSEG varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	LENGTHSEG int NULL,
	MENTHOLINDI varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	DELISTYN varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	THICKSEG varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	TARSEGMENTAT varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	CAPSULEYN varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	TARINFO varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	Company varchar(50) COLLATE Korean_Wansung_CI_AS NOT NULL,
	SAL_QNT varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	ProductSubFamilyCode varchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	Productcode varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	MKTD_BRDCODE varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	SMARTSRCCode varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	[check] varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	New_FLAVORSEG varchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	New_TARSEGMENTAT varchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	FLAVORSEG_type6 varchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	CONSTRAINT product_master_temp_pk PRIMARY KEY (PROD_ID)
);
 CREATE NONCLUSTERED INDEX product_master_temp_CIGADEVICE_IDX ON cx.product_master_temp (  CIGADEVICE ASC  , CIGATYPE ASC  , ProductFamilyCode ASC  , Company ASC  , ENGNAME ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;

select a.YYYYMM, 
		b.ENGNAME, 
		b.CIGATYPE , 
		b.FLAVORSEG,
		CASE 
	        WHEN FLAVORSEG like 'FS1:%' THEN 'Regular'
	        WHEN FLAVORSEG like 'FS2:%' THEN 'Fresh'
	        WHEN FLAVORSEG like 'FS3:%' THEN 'Fresh'
	        WHEN FLAVORSEG like 'FS4:%' THEN 'New Taste'
	        WHEN FLAVORSEG like 'FS5:%' THEN 'Fresh'
	        WHEN FLAVORSEG like 'FS7:%' THEN 'New Taste'
	        WHEN FLAVORSEG like 'FS8:%' THEN 'New Taste'
	        WHEN FLAVORSEG like 'FS9:%' THEN 'New Taste'
	        WHEN FLAVORSEG like 'FS10:%' THEN 'New Taste'
	        WHEN FLAVORSEG like 'FS11:%' THEN 'Fresh'
	        WHEN FLAVORSEG like 'FS12:%' THEN 'Fresh'
	        WHEN FLAVORSEG like 'FS13:%' THEN 'Fresh'
	        WHEN FLAVORSEG like 'FS14:%' THEN 'New Taste'
	        when FLAVORSEG like 'Aftercut (New%' then 'New Taste'
	        when FLAVORSEG like 'Regular Fresh' then 'Fresh' 
	        when FLAVORSEG like 'Regular to Fresh' then 'Fresh'
			when FLAVORSEG like 'Regular to New Taste' then 'New Taste'
			when FLAVORSEG like 'Fresh to New Taste' then 'New Taste'
	        ELSE FLAVORSEG
    	END as New_FLAVORSEG,
		b.TARSEGMENTAT,
		CASE 
	    	when TARSEGMENTAT like 'TS1:%' then 'FF'
	    	when TARSEGMENTAT like 'TS2:%' then 'LTS'
	    	when TARSEGMENTAT like 'TS3:%' then 'ULT'
	    	when TARSEGMENTAT like 'TS4:%' then '1MG'
	    	when TARSEGMENTAT like 'TS5:%' then 'Below 1MG'
	    	else TARSEGMENTAT 
	    END as New_TARSEGMENTAT,
		a.id, a.buy_ct , b.SAL_QNT,
		sum(cast(b.SAL_QNT as float) * a.buy_ct) as quantity
--into cx.fct_CC_purchases_monthly
FROM cx.fct_K7_Monthly a
    JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
WHERE b.ENGNAME != 'Cleaning Stick' AND b.cigatype != 'CSV' and 4 < len(a.id)		-- Default Condition
group by a.YYYYMM, b.ENGNAME, b.CIGATYPE , b.FLAVORSEG, b.TARSEGMENTAT, a.id, a.buy_ct , b.SAL_QNT ;



--alter table cx.product_master_temp add FLAVORSEG_type6 varchar(50) COLLATE Korean_Wansung_CI_AS NULL;
;
update a
set a.FLAVORSEG_type6 = 
	CASE 
	    WHEN b.FLAVORSEG like 'FS1:%' THEN 'Regular'
	    WHEN b.FLAVORSEG like 'FS2:%' THEN 'Regular to Fresh'
	    WHEN b.FLAVORSEG like 'FS3:%' THEN 'Regular to Fresh'
	    WHEN b.FLAVORSEG like 'FS4:%' THEN 'Regular to New Taste'
	    WHEN b.FLAVORSEG like 'FS5:%' THEN 'Fresh to Fresh'
	    WHEN b.FLAVORSEG like 'FS7:%' THEN 'New Taste'
	    WHEN b.FLAVORSEG like 'FS8:%' THEN 'Fresh to New Taste'
	    WHEN b.FLAVORSEG like 'FS9:%' THEN 'Fresh to New Taste'
	    WHEN b.FLAVORSEG like 'FS10:%' THEN 'Regular to New Taste'
	    WHEN b.FLAVORSEG like 'FS11:%' THEN 'Fresh to Fresh'
	    WHEN b.FLAVORSEG like 'FS12:%' THEN 'Regular to Fresh'
	    WHEN b.FLAVORSEG like 'FS13:%' THEN 'Regular Fresh'
	    WHEN b.FLAVORSEG like 'FS14:%' THEN 'New Taste'
	    when b.FLAVORSEG like 'Aftercut (New%' then 'New Taste'
	    when b.FLAVORSEG like 'Regular Fresh' then 'Regular Fresh' 
	    when b.FLAVORSEG like 'Regular to Fresh' then 'Regular to Fresh'
		when b.FLAVORSEG like 'Regular to New Taste' then 'Regular to New Taste'
		when b.FLAVORSEG like 'Fresh to New Taste' then 'Fresh to New Taste'
    ELSE b.FLAVORSEG
    end 
	from cx.product_master_temp a
		join cx.product_master_temp b on a.prod_id = b.prod_id;



-- 새로 추가되는 제품 추가하기 
insert into cx.product_master
select a.PROD_ID,a.ENGNAME,a.ProductDescription,a.ProductFamilyCode,a.CIGADEVICE,a.CIGATYPE,a.FLAVORSEG,a.LENGTHSEG,a.MENTHOLINDI,a.DELISTYN,a.THICKSEG,a.TARSEGMENTAT,a.CAPSULEYN,a.TARINFO,a.Company,a.SAL_QNT,a.ProductSubFamilyCode,a.Productcode,a.MKTD_BRDCODE,a.SMARTSRCCode,a.[check],
	CASE 
	    WHEN b.FLAVORSEG like 'FS1:%' THEN 'Regular'
	    WHEN b.FLAVORSEG like 'FS2:%' THEN 'Fresh'
	    WHEN b.FLAVORSEG like 'FS3:%' THEN 'Fresh'
	    WHEN b.FLAVORSEG like 'FS4:%' THEN 'New Taste'
	    WHEN b.FLAVORSEG like 'FS5:%' THEN 'Fresh'
	    WHEN b.FLAVORSEG like 'FS7:%' THEN 'New Taste'
	    WHEN b.FLAVORSEG like 'FS8:%' THEN 'New Taste'
	    WHEN b.FLAVORSEG like 'FS9:%' THEN 'New Taste'
	    WHEN b.FLAVORSEG like 'FS10:%' THEN 'New Taste'
	    WHEN b.FLAVORSEG like 'FS11:%' THEN 'Fresh'
	    WHEN b.FLAVORSEG like 'FS12:%' THEN 'Fresh'
	    WHEN b.FLAVORSEG like 'FS13:%' THEN 'Fresh'
	    WHEN b.FLAVORSEG like 'FS14:%' THEN 'New Taste'
	    when b.FLAVORSEG like 'Aftercut (New%' then 'New Taste'
	    when b.FLAVORSEG like 'Regular Fresh' then 'Fresh' 
	    when b.FLAVORSEG like 'Regular to Fresh' then 'Fresh'
		when b.FLAVORSEG like 'Regular to New Taste' then 'New Taste'
		when b.FLAVORSEG like 'Fresh to New Taste' then 'New Taste'
    	ELSE b.FLAVORSEG 
    end,
	CASE 
    	when b.TARSEGMENTAT like 'TS1:%' then 'FF'
    	when b.TARSEGMENTAT like 'TS2:%' then 'LTS'
    	when b.TARSEGMENTAT like 'TS3:%' then 'ULT'
    	when b.TARSEGMENTAT like 'TS4:%' then '1MG'
    	when b.TARSEGMENTAT like 'TS5:%' then 'Below 1MG'
    	else b.TARSEGMENTAT 
    END,
	CASE 
	    WHEN b.FLAVORSEG like 'FS1:%' THEN 'Regular'
	    WHEN b.FLAVORSEG like 'FS2:%' THEN 'Regular to Fresh'
	    WHEN b.FLAVORSEG like 'FS3:%' THEN 'Regular to Fresh'
	    WHEN b.FLAVORSEG like 'FS4:%' THEN 'Regular to New Taste'
	    WHEN b.FLAVORSEG like 'FS5:%' THEN 'Fresh to Fresh'
	    WHEN b.FLAVORSEG like 'FS7:%' THEN 'New Taste'
	    WHEN b.FLAVORSEG like 'FS8:%' THEN 'Fresh to New Taste'
	    WHEN b.FLAVORSEG like 'FS9:%' THEN 'Fresh to New Taste'
	    WHEN b.FLAVORSEG like 'FS10:%' THEN 'Regular to New Taste'
	    WHEN b.FLAVORSEG like 'FS11:%' THEN 'Fresh to Fresh'
	    WHEN b.FLAVORSEG like 'FS12:%' 				THEN 'Regular to Fresh'
	    WHEN b.FLAVORSEG like 'FS13:%' 				THEN 'Regular Fresh'
	    WHEN b.FLAVORSEG like 'FS14:%' 				THEN 'New Taste'
	    when b.FLAVORSEG like 'Aftercut (New%' 		then 'New Taste'
	    when b.FLAVORSEG like 'Regular Fresh' 		then 'Regular Fresh' 
	    when b.FLAVORSEG like 'Regular to Fresh' 	then 'Regular to Fresh'
		when b.FLAVORSEG like 'Regular to New Taste' then 'Regular to New Taste'
		when b.FLAVORSEG like 'Fresh to New Taste'	then 'Fresh to New Taste'
    	ELSE b.FLAVORSEG 
    end as FLAVORSEG_type6
from cx.product_master_tmp2 a
	left join cx.product_master b on a.PROD_ID  = b.PROD_ID 
where b.PROD_ID is null;