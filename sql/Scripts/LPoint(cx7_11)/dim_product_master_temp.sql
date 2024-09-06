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


-- BPDA.cx.product_master definition

-- Drop table

-- DROP TABLE BPDA.cx.product_master;

CREATE TABLE BPDA.cx.product_master (
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
	FLAVORSEG_type3 varchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	New_TARSEGMENTAT varchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	FLAVORSEG_type6 varchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	CONSTRAINT product_master_temp_pk PRIMARY KEY (PROD_ID)
);
 CREATE NONCLUSTERED INDEX product_master_temp_CIGADEVICE_IDX ON cx.product_master (  CIGADEVICE ASC  , CIGATYPE ASC  , ProductFamilyCode ASC  , Company ASC  , ENGNAME ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;

-- 비어있는 data 찾기
select * 
from cx.product_master_tmp a
	left join  cx.product_master b on a.PROD_ID = b.PROD_ID 
where b.prod_id is null;


-- 새로 추가되는 제품 추가하기 
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
    	end as FLAVORSEG_type6
from cx.product_master_tmp a
	left join  cx.product_master b on a.PROD_ID = b.PROD_ID 
where b.prod_id is null;


-- 안들어간 데이터 확인
select * 
from cx.product_master
where FLAVORSEG is not NULL
and FLAVORSEG_type3 is null;



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






-- NPL (New Product Launch) 최신 제품 데이터 추가 작업 45 rows
--update a 
--set NPL_YN = 'Y'
--from cx.product_master a
--where engname in ('BOHEM CIGAR CARIBE',
--'BOHEM CIGAR ICE FIT',
--'BOHEM MINI ROAST KS RCB 20 SSL',
--'BOHEM PIPE BRITON',
--'ESSE CHANGE COOLIPS',
--'ESSE CHANGE DOUBLE',
--'ESSE CHANGE GRAM 100 DHX 20 SSL',
--'ESSE CHANGE ICEFALL 120 DSP 20 MSL',
--'ESSE CHANGE SHOOTING RED',
--'ESSE Himalaya Winter',
--'ESSE ITS DEEP BROWN',
--'RAISON FRENCH ICE BLAN',
--'RAISON FRENCH SSOM',
--'RAISON IONIA AQUA GREEN',
--'RAISON IONIA ISLAND PINK',
--'RAISON RESERVE',
--'THIS AFRICA HAI HAI',
--'Marlboro Vista Blossom Mist',
--'Marlboro Vista Forest Mist',
--'Marlboro Vista Summer Splash',
--'Marlboro Vista Tropical Breeze',
--'Marlboro Vista Tropical Splash',
--'Parliament Double Wave',
--'DUNHILL ALPS BOOST',
--'Dunhill Electric Crush',
--'DUNHILL EXOTIC CRUSH',
--'DUNHILL FINECUT RAINBOW BOOST',
--'DUNHILL GREEN BOOST MNT 100 BOX 20 SSL',
--'DUNHILL LIT ZEPHYR MNT KS OCT 20',
--'DUNHILL RUBY BOOST',
--'Dunhill Smooth Crush',
--'MEVIUS CITRO WAVE',
--'MEVIUS LBS 2.0 ICE FIZZ 100 DSP 20 SSL',
--'MEVIUS LBS 2.0 MAX YELLOW',
--'MEVIUS LBS 2.0 MAX YELLOW SS',
--'MEVIUS LBS 2.0 SUNSET BEACH KS RCB 20',
--'MEVIUS LBS BANA SSL',
--'MEVIUS LBS LONG ISLAND',
--'MEVIUS LBS SPARKLING DEW',
--'MEVIUS LBS TROPICAL MIX 3mg',
--'Marlboro Vista Garden Splash',
--'Raison Hyvaa Ice Tundra')
