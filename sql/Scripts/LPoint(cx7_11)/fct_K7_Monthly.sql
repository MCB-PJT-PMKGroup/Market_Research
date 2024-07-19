-- BPDA.cx.fct_K7_Monthly definition

-- Drop table

-- DROP TABLE BPDA.cx.fct_K7_Monthly;

CREATE TABLE BPDA.cx.fct_K7_Monthly (
	de_dt varchar(20) COLLATE Korean_Wansung_CI_AS NOT NULL,
	product_code varchar(255) COLLATE Korean_Wansung_CI_AS NOT NULL,
	id varchar(255) COLLATE Korean_Wansung_CI_AS NOT NULL,
	buy_ct int NULL,
	YYYYMM varchar(20) COLLATE Korean_Wansung_CI_AS NOT NULL,
	Pack_qty float NULL,
	gender varchar(20) COLLATE Korean_Wansung_CI_AS NULL,
	age varchar(20) COLLATE Korean_Wansung_CI_AS NULL,
	pk_id int IDENTITY(1,1) NOT NULL,
	CONSTRAINT PK__fct_K7_M__1543595E6D52BFA3 PRIMARY KEY (pk_id)
);
 CREATE NONCLUSTERED INDEX ix_fct_K7_Monthly_id ON cx.fct_K7_Monthly (  id ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;
 CREATE NONCLUSTERED INDEX ix_fct_K7_Monthly_product_code ON cx.fct_K7_Monthly (  product_code ASC  )  
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;

-- Category : CIGATYPE
-- CC, HnB

-- Taste : FLAVORSEG
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



-- 월별 데이터 수량
select yyyymm, count(*)
from cx.fct_K7_Monthly
group by yyyymm;

--202107	701054
--202108	697627
--202109	649439
--202110	706325
--202111	713774
--202112	693568
--202201	657213
--202202	589719
--202203	709543
--202204	751698
--202205	819474
--202206	809461
--202207	837657
--202208	804864
--202209	790636
--202210	880463
--202211	859315
--202212	845229
--202301	835310
--202302	808160
--202303	958221
--202304	943080
--202305	1014279
--202306	1007127
--202307	1020240
--202308	1018149
--202309	1002879
--202310	1010444
--202311	960429
--202312	941254
--202401	946665
--202402	894483
--202403	1009427
--202404	1058451
--202405	1102170