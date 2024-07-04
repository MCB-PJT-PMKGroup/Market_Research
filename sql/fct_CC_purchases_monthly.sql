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

-- alter table cx.fct_CC_purchases_monthly add New_FLAVORSEG varchar(50);
-- alter table cx.fct_CC_purchases_monthly add New_TARSEGMENTAT varchar(50);
-- CREATE INDEX ix_fct_CC_purchases_monthly_YYYYMM ON cx.fct_CC_purchases_monthly (  YYYYMM ASC  ) ;
-- CREATE INDEX ix_fct_CC_purchases_monthly_ENGNAME ON cx.fct_CC_purchases_monthly (  ENGNAME ASC  ) ;
-- CREATE INDEX ix_product_master_temp_ENGNAME ON cx.product_master_temp (  ENGNAME ASC  ) ;
--alter table cu.dim_CU_master add New_FLAVORSEG varchar(50) ;
--alter table cu.dim_CU_master add New_TARSEGMENTAT varchar(50) ;

update cu.dim_CU_master 
set 	New_FLAVORSEG=	CASE 
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
    	END ,
		New_TARSEGMENTAT = CASE 
	    	when TARSEGMENTAT like 'TS1:%' then 'FF'
	    	when TARSEGMENTAT like 'TS2:%' then 'LTS'
	    	when TARSEGMENTAT like 'TS3:%' then 'ULT'
	    	when TARSEGMENTAT like 'TS4:%' then '1MG'
	    	when TARSEGMENTAT like 'TS5:%' then 'Below 1MG'
	    	else TARSEGMENTAT 
	    END ;
		
select a.YYYYMM, b.ENGNAME, b.CIGATYPE , b.FLAVORSEG, b.TARSEGMENTAT, a.id, a.buy_ct , b.SAL_QNT, count(*) as month_cnt, sum(cast(b.SAL_QNT as float) * a.buy_ct) as quantity
FROM cx.fct_K7_Monthly a
    JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
WHERE b.ENGNAME != 'Cleaning Stick' AND b.cigatype != 'CSV' and 4 < len(a.id)		-- Default Condition
group by a.YYYYMM, b.ENGNAME, b.CIGATYPE , b.FLAVORSEG, b.TARSEGMENTAT, a.id, a.buy_ct , b.SAL_QNT 
having count(*) > 1;


-- -- CIGATYPE 구분자로 SUM
-- select distinct YYYYMM, ENGNAME, CIGATYPE, FLAVORSEG, TARSEGMENTAT,
-- 	sum(cast(quantity as int)) over (partition by YYYYMM, ENGNAME )as Total_Product_qty,
-- 	sum(cast(quantity as int)) over (partition by YYYYMM, CIGATYPE ) as Total_CIGA_qty,
-- 	sum(cast(quantity as int)) over (partition by YYYYMM, NEW_FLAVORSEG ) as Total_Flavor_qty,
-- 	sum(cast(quantity as int)) over (partition by YYYYMM, NEW_TARSEGMENTAT ) as Total_Taste_qty
-- --into cx.fct_CC_purchases_qty_monthly
-- 	from cx.fct_CC_purchases_monthly 
-- ;

-- FLAVORSEG, TARSEGMENTAT 데이터가 없음 
select * from cx.fct_CC_purchases_monthly
order by YYYYMM, engname, id 
;


select *, cast(SAL_QNT as float) * buy_ct as total 
FROM cx.fct_CC_purchases_monthly 
where id ='17325089A0C527F9A71906969D614ACAE7711F21D0418FBC7F528EA8C451DA54'
;


-- Switching In/Out 작업 
WITH FebPurchases AS (
    SELECT YYYYMM, id, engname, quantity AS FebQuantity
    FROM cx.fct_CC_purchases_monthly
    WHERE YYYYMM = '202402' and engname = 'Marlboro Vista Blossom Mist'
),
MarchPurchases AS (
    SELECT YYYYMM, id, engname, quantity AS MarchQuantity
    FROM cx.fct_CC_purchases_monthly
    WHERE YYYYMM = '202403' and engname = 'Marlboro Vista Blossom Mist'
)
SELECT 
    COALESCE(f.id, m.id) AS id,
    f.FebQuantity,
    m.MarchQuantity,
    CASE
        WHEN f.FebQuantity IS NULL AND m.MarchQuantity IS NOT NULL THEN 'In'
        WHEN f.FebQuantity IS NOT NULL AND m.MarchQuantity IS NULL THEN 'Out'
        ELSE 'No Switch' -- 이 경우는 두 달 모두 구매하거나 두 달 모두 구매하지 않은 경우를 포함합니다.
    END AS SwitchStatus
FROM FebPurchases f
	FULL OUTER JOIN MarchPurchases m ON f.id = m.id
ORDER BY COALESCE(f.id, m.id);


 

 