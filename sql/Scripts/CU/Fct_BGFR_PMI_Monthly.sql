--DROP TABLE BPDA.cu.Fct_BGFR_PMI_Monthly;



-- BPDA.cu.Fct_BGFR_PMI_Monthly definition

-- Drop table

-- DROP TABLE BPDA.cu.Fct_BGFR_PMI_Monthly;

CREATE TABLE BPDA.cu.Fct_BGFR_PMI_Monthly (
	YM_CD varchar(20) COLLATE Korean_Wansung_CI_AS NULL,
	SIDO_CD tinyint NULL,
	CUST_ID nvarchar(100) COLLATE Korean_Wansung_CI_AS NOT NULL,
	GENDER_CD tinyint NULL,
	AGE_CD tinyint NULL,
	ITEM_CD varchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	SALE_QTY float NULL,
	PACK_QTY float NULL,
	pk_id int IDENTITY(1,1) NOT NULL,
	CONSTRAINT PK__Fct_BGFR__1543595E65F36A75 PRIMARY KEY (pk_id)
);
 CREATE NONCLUSTERED INDEX ix_Fct_BGFR_PMI_Monthly_cust_id ON cu.Fct_BGFR_PMI_Monthly (  CUST_ID ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;

--insert into cu.Fct_BGFR_PMI_Monthly 
--	(YM_CD
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

update cu.Fct_BGFR_PMI_Monthly
set PACK_QTY = a.SALE_QTY * b.SAL_QNT 
from cu.Fct_BGFR_PMI_Monthly a
	join cu.dim_CU_master b on a.ITEM_CD = b.PROD_ID  
;

