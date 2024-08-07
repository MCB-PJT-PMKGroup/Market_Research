

CREATE TABLE BPDA.cu.dim_product_master (
	PROD_ID nvarchar(50) COLLATE Korean_Wansung_CI_AS NOT NULL,
	ENGNAME nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	ProductDescription nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	ProductFamilyCode nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	CIGADEVICE nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	CIGATYPE nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	FLAVORSEG nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	LENGTHSEG tinyint NULL,
	MENTHOLINDI bit NULL,
	DELISTYN bit NULL,
	THICKSEG nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	TARSEGMENTAT nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	CAPSULEYN bit NULL,
	TARINFO decimal(18,10) NULL,
	Company nvarchar(50) COLLATE Korean_Wansung_CI_AS NOT NULL,
	SAL_QNT decimal(18,10) NOT NULL,
	ProductSubFamilyCode nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	Productcode nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	MKTD_BRDCODE nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	SMARTSRCCode nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	FLAVORSEG_type3 varchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	New_TARSEGMENTAT varchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	FLAVORSEG_type6 varchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	CONSTRAINT PK_dim_product_master PRIMARY KEY (PROD_ID)
);


-- 비어있는 data 찾고 SKU 채우기
insert into cu.dim_product_master 
select a.PROD_ID,a.ENGNAME, a.ProductDescription,a.ProductFamilyCode,a.CIGADEVICE,a.CIGATYPE,a.FLAVORSEG,a.LENGTHSEG,a.MENTHOLINDI,a.DELISTYN,a.THICKSEG,a.TARSEGMENTAT,a.CAPSULEYN,a.TARINFO,a.Company,a.SAL_QNT,a.ProductSubFamilyCode,a.Productcode,a.MKTD_BRDCODE,a.SMARTSRCCode,
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
	    WHEN b.FLAVORSEG like 'FS1:%' 				THEN 'Regular'
	    WHEN b.FLAVORSEG like 'FS2:%' 				THEN 'Regular to Fresh'
	    WHEN b.FLAVORSEG like 'FS3:%' 				THEN 'Regular to Fresh'
	    WHEN b.FLAVORSEG like 'FS4:%' 				THEN 'Regular to New Taste'
	    WHEN b.FLAVORSEG like 'FS5:%' 				THEN 'Fresh to Fresh'
	    WHEN b.FLAVORSEG like 'FS7:%' 				THEN 'New Taste'
	    WHEN b.FLAVORSEG like 'FS8:%' 				THEN 'Fresh to New Taste'
	    WHEN b.FLAVORSEG like 'FS9:%' 				THEN 'Fresh to New Taste'
	    WHEN b.FLAVORSEG like 'FS10:%' 				THEN 'Regular to New Taste'
	    WHEN b.FLAVORSEG like 'FS11:%' 				THEN 'Fresh to Fresh'
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
from cu.cu_master_tmp a
	left join  cu.dim_product_master b on a.PROD_ID = b.PROD_ID 
where b.prod_id is null;


-- Pack 수 업데이트 
update a 
set a.PACK_QTY  = a.SALE_QTY  * b.SAL_QNT 
from cu.Fct_BGFR_PMI_Monthly a
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID 
where PACK_QTY =0;


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

update a
set a.FLAVORSEG_type3 = 
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
    end 
	from cu.dim_product_master a
		join cu.dim_product_master b on a.prod_id = b.prod_id;


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
	from cu.dim_product_master a
		join cu.dim_product_master b on a.prod_id = b.prod_id;


--Regular

-- Tar : TARSEGMENTAT 
--TS1: FF
--TS2: LTS
--TS3: ULT
--TS4: 1MG
--TS5: Below 1MG
update A 
set a.New_TARSEGMENTAT =
	CASE 
    	when b.TARSEGMENTAT like 'TS1:%' then 'FF'
    	when b.TARSEGMENTAT like 'TS2:%' then 'LTS'
    	when b.TARSEGMENTAT like 'TS3:%' then 'ULT'
    	when b.TARSEGMENTAT like 'TS4:%' then '1MG'
    	when b.TARSEGMENTAT like 'TS5:%' then 'Below 1MG'
    	else b.TARSEGMENTAT 
    END
from cu.dim_product_master a
	join cu.dim_product_master b on a.prod_id = b.prod_id;

