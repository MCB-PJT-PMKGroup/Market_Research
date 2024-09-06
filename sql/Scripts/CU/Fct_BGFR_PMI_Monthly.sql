-- BPDA.cu.Fct_BGFR_PMI_Monthly definition

-- Drop table

-- DROP TABLE BPDA.cu.Fct_BGFR_PMI_Monthly;
CREATE TABLE BPDA.cu.Fct_BGFR_PMI_Monthly (
	YYYYMM varchar(20) COLLATE Korean_Wansung_CI_AS NOT NULL,
	SIDO_CD tinyint NOT NULL,
	id nvarchar(100) COLLATE Korean_Wansung_CI_AS NOT NULL,
	GENDER tinyint NULL,
	AGE tinyint NULL,
	ITEM_CD varchar(50) COLLATE Korean_Wansung_CI_AS NOT NULL,
	SALE_QTY float NULL,
	PACK_QTY float NULL,
	seq int IDENTITY(1,1) NOT NULL,
	SIDO_NM varchar(50) COLLATE Korean_Wansung_CI_AS NOT NULL,
	price int NULL,
	row_id varchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	CONSTRAINT Fct_BGFR_PMI_Monthly_PK PRIMARY KEY (id,ITEM_CD,YYYYMM,SIDO_NM)
);

-- alter table cu.Fct_BGFR_PMI_Monthly  add constraint PK_fct_BGFR_PMI_Monthly primary key (ITEM_CD, CUST_ID, YM_CD, SIDO_CD );

update statistics cu.fct_BGFR_PMI_Monthly;
-- update statistics cx.fct_k7_monthly;

drop INDEX ix_Fct_BGFR_PMI_Monthly_ITEM_CD on cu.Fct_BGFR_PMI_Monthly ;

CREATE NONCLUSTERED INDEX ix_Fct_BGFR_PMI_Monthly_ITEM_CD
ON [cu].[Fct_BGFR_PMI_Monthly] ( ITEM_CD, YYYYMM)
include ( pack_qty, row_id);

----;


-- 원천 Raw Data
CREATE TABLE BPDA.cu.BGFR_PMI_202302 (
	YM_CD nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	SIDO_CD tinyint NULL,
	SIDO_NM nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	CUST_ID nvarchar(100) COLLATE Korean_Wansung_CI_AS NULL,
	GENDER_CD tinyint NULL,
	AGE_CD tinyint NULL,
	MCLASS_CD tinyint NULL,
	MCLASS_NM nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	LCLASS_CD smallint NULL,
	LCLASS_NM nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	ITEM_CD nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	ITEM_NM nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	NOW_SLPR int NULL,
	SALE_QTY int NULL,
	SALE_AMT int NULL,
	SALE_CNT int NULL,
	row_id nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL
);

-- 데이터 전처리
-- Row_id 시작 : 2023010000001

insert into cu.Fct_BGFR_PMI_Monthly 
		(YYYYMM
	  	,SIDO_CD
		,SIDO_NM
		,id
		,GENDER
		,AGE
		,ITEM_CD
		,SALE_QTY
		,PACK_QTY
		, price 
		, row_id
		)
select YM_CD
	,SIDO_CD
	,SIDO_NM
	,CUST_ID
	,GENDER_CD
	,AGE_CD
	,ITEM_CD
	,SALE_QTY
	, round(a.SALE_QTY * b.SAL_QNT, 2)  PACK_QTY
	, NOW_SLPR 
	, row_id
from cu.BGFR_PMI_202407 a
	left join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID ;


-- update cu.Fct_BGFR_PMI_Monthly
-- set PACK_QTY = a.SALE_QTY * b.SAL_QNT 
-- from cu.Fct_BGFR_PMI_Monthly a
-- 	join cu.dim_CU_master b on a.ITEM_CD = b.PROD_ID  
-- ;


-- 가격, row ID 업데이트
update a 
set a.price = b.NOW_SLPR , a.row_id = b.row_id
from cu.Fct_BGFR_PMI_Monthly a
	join cu.BGFR_PMI_202301 b on a.id = b.CUST_ID and a.ITEM_CD = b.ITEM_CD and  a.YYYYMM = b.YM_CD and a.SIDO_CD = b.SIDO_CD
where a.row_id is NULL 
;



--202301 1,637,029
--202302 1,567,616
--202303 1,737,333
--202304 1,734,126
--202305 1,816,764
--202306 1,791,262
--202307 1,801,693
--202308 1,806,478
--202309 1,819,937
--202310 1,797,934
--202311 1,669,557
--202312 1,672,828
--202401 1,637,875
--202402 1,624,032
--202403 1,727,622
--202404 1,773,180
--202405 1,821,034
--202406 1,809,086
--202407 1,806,190
