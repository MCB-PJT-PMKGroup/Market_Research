--DROP TABLE BPDA.cu.Fct_BGFR_PMI_Monthly;



CREATE TABLE cu.Fct_BGFR_PMI_Monthly (
	YM_CD varchar(20) COLLATE Korean_Wansung_CI_AS NULL,
	SIDO_CD tinyint NULL,
	CUST_ID nvarchar(100) COLLATE Korean_Wansung_CI_AS NULL,
	GENDER_CD tinyint NULL,
	AGE_CD tinyint NULL,
	ITEM_CD varchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	SALE_QTY float NULL,
	PACK_QTY float NULL
);

--insert into cu.Fct_BGFR_PMI_Monthly 
--	(YYYYMM
--	,SIDO_CD
--	,CUST_ID
--	,GENDER_CD
--	,AGE_CD
--	,ITEM_CD
--	,SALE_QTY
--	,PACK_QTY
--	)
--select YM_CD
--,SIDO_CD
--,CUST_ID
--,GENDER_CD
--,AGE_CD
--,ITEM_CD
--,SALE_QTY
--, round(a.SALE_QTY * b.SAL_QNT, 2)  PACK_QTY
--from cu.BGFR_PMI_202301 a
--	left join cu.dim_CU_master b on a.ITEM_CD = b.PROD_ID ;

--create index ix_Fct_BGFR_PMI_Monthly_YYYYMM on cu.Fct_BGFR_PMI_Monthly (YYYYMM);
--create index ix_Fct_BGFR_PMI_Monthly_ITEM_CD on cu.Fct_BGFR_PMI_Monthly (ITEM_CD);


update cu.Fct_BGFR_PMI_Monthly
set PACK_QTY = a.SALE_QTY * b.SAL_QNT 
from cu.Fct_BGFR_PMI_Monthly a
	join cu.dim_CU_master b on a.ITEM_CD = b.PROD_ID  
;

