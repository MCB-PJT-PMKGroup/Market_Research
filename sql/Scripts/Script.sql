-- BPDA.cx.product_master definition

-- Drop table

-- DROP TABLE BPDA.cx.product_master_temp;

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
	
	
-- NO Condition

SELECT *
FROM CX.product_master_temp pm ; -- 439 ROWS
-- PROD_ID, CIGATYPE(cc, hnb), SAL_QNT(소수점단위) , TARSEGMENTAT, Company, TARINFO, ProductFamilyCode, ProductSubFamilyCode
--HEETS, NEO, NEOSTICKS 

select * 
from cx.K7_202403 ;  -- 1,009,427 ROWS
-- product_code, id(소비자) , buy_ct

select distinct ProductSubFamilyCode 
from cx.K7_202403 ;  -- 1,009,427 ROWS



-- Base
select count(distinct a.id) -- 288,668
from cx.k7_202403 a 
	join cx.product_master_temp b on a.product_code = b.PROD_ID and cigatype != 'CSV' and b.ENGNAME != 'Cleaning Stick' and 4 < len(a.id)
;


-- Purchaser
select b.CIGATYPE , count(distinct a.id) 
from cx.k7_202403 a 
	join cx.product_master_temp b on a.product_code = b.PROD_ID and cigatype != 'CSV' and b.ENGNAME != 'Cleaning Stick' and 4 < len(a.id)
group by b.CIGATYPE 
;
--CC	235557
--HnB	79907


--tobacoo packs count (buy_ct * a.SAL_QNT)
select b.CIGATYPE , sum(cast(b.SAL_QNT as float) * buy_ct) 
from cx.k7_202403 a 
	join cx.product_master_temp b on a.product_code = b.PROD_ID and cigatype != 'CSV' and b.ENGNAME != 'Cleaning Stick' and 4 < len(a.id)
group by b.CIGATYPE 
;
--HnB	311441
--CC	951632


-- Gender
select a.gender, b.CIGATYPE, count(distinct a.id) 
from cx.k7_202403 a 
	join cx.product_master_temp b on a.product_code = b.PROD_ID and cigatype != 'CSV'
group by a.gender, b.CIGATYPE 
;

-- Age
select a.age, b.CIGATYPE, count(distinct a.id) 
from cx.k7_202403 a 
	join cx.product_master_temp b on a.product_code = b.PROD_ID and cigatype != 'CSV'
group by a.age, b.CIGATYPE 
;

-- TMO
select 'Total', Company, count(distinct a.id) , sum(cast(b.SAL_QNT as float) * buy_ct) 
from cx.k7_202403 a 
	join cx.product_master_temp b on a.product_code = b.PROD_ID and cigatype != 'CSV'
group by Company
union
select b.CIGATYPE ,Company, count(distinct a.id) , sum(cast(b.SAL_QNT as float) * buy_ct) 
from cx.k7_202403 a 
	join cx.product_master_temp b on a.product_code = b.PROD_ID and cigatype != 'CSV'
group by b.CIGATYPE , Company
;

-- Flavour

-- Tar
-- Product Family
