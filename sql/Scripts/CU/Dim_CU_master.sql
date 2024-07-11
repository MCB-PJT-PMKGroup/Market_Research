-- BPDA.cu.dim_CU_master definition

-- Drop table

-- DROP TABLE BPDA.cu.dim_CU_master;

CREATE TABLE BPDA.cu.dim_CU_master (
	PROD_ID varchar(50) COLLATE Korean_Wansung_CI_AS NULL,
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
	TARINFO float NULL,
	Company nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	SAL_QNT float NULL,
	ProductSubFamilyCode nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	Productcode nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	MKTD_BRDCODE nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	SMARTSRCCode nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	New_FLAVORSEG varchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	New_TARSEGMENTAT varchar(50) COLLATE Korean_Wansung_CI_AS NULL
);
 CREATE NONCLUSTERED INDEX ix_dim_CU_master_PROD_ID ON cu.dim_CU_master (  PROD_ID ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;