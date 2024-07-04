-- L.Point(SevenEleven CVS)

-- DROP TABLE BPDA.cx.product_master_temp;

CREATE TABLE BPDA.cx.product_master_temp (
	PROD_ID varchar(255) COLLATE Korean_Wansung_CI_AS NULL,
	ENGNAME varchar(255) COLLATE Korean_Wansung_CI_AS NULL,
	ProductDescription varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	ProductFamilyCode varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	CIGADEVICE varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	CIGATYPE varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	FLAVORSEG varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	LENGTHSEG int NULL,
	MENTHOLINDI varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	DELISTYN varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	THICKSEG varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	TARSEGMENTAT varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	CAPSULEYN varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	TARINFO varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	Company varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	SAL_QNT varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	ProductSubFamilyCode varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	Productcode varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	MKTD_BRDCODE varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	SMARTSRCCode varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	[check] varchar(MAX) COLLATE Korean_Wansung_CI_AS NULL,
	New_FLAVORSEG varchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	New_TARSEGMENTAT varchar(50) COLLATE Korean_Wansung_CI_AS NULL
);
 CREATE NONCLUSTERED INDEX ix_product_master_temp_ENGNAME ON cx.product_master_temp (  ENGNAME ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;