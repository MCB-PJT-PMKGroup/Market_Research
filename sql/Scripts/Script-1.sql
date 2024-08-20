-- 대상 Group 조회
select distinct CIGATYPE, ProductFamilyCode, ProductSubFamilyCode
from cx.product_master_temp
;

SELECT *
FROM CX.product_master_temp pm ; -- 439 ROWS
-- PROD_ID, CIGATYPE(cc, hnb), SAL_QNT(소수점단위) , TARSEGMENTAT, Company, TARINFO, ProductFamilyCode, ProductSubFamilyCode

-- Base 
select count(distinct a.id) -- 288,668
from cx.k7_202403 a 
	join cx.product_master_temp b on a.product_code = b.PROD_ID and cigatype != 'CSV' and b.ENGNAME != 'Cleaning Stick' and 4 < len(a.id)
;

-- Group A ... 35,914
-- 최근 1년 동안 'HEETS' 제품을 구매한 고객 ID 찾기
SELECT count(DISTINCT a.id)
FROM cx.fct_K7_Monthly a
	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
WHERE b.cigatype != 'CSV'
AND b.ENGNAME != 'Cleaning Stick'
AND a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -11, GETDATE()), 112) 
				 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, 0, GETDATE()), 112)
AND b.ProductSubFamilyCode = 'HEETS'
;

-- Group B: HEETS + CC  >> 17,307 rows
-- 최근 1년 히츠를 구매한 고객이 다른 담배 제품을 구매한 적이 있는 고객
WITH HeetsCustomers AS (
	-- Group A
    SELECT DISTINCT a.id
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.cigatype != 'CSV'
    AND b.ENGNAME != 'Cleaning Stick'
    AND LEN(a.id) > 4
    AND a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -11, GETDATE()), 112) 
    				 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, 0, GETDATE()), 112)
    AND b.ProductSubFamilyCode = 'HEETS'
)
-- 'HEETS' 제품을 구매한 고객이 다른 담배 제품도 구매한 경우 찾기
SELECT count(distinct a.id) 
FROM cx.fct_K7_Monthly a
	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
WHERE a.id IN (SELECT id FROM HeetsCustomers)
AND b.cigatype = 'CC'
AND b.ENGNAME != 'Cleaning Stick'
AND LEN(a.id) > 4
AND a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -11, GETDATE()), 112) 
				 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, GETDATE()), 112)

;

-- Group C : HEETS + LIL >> 5,433

WITH HeetsCustomers AS (
	-- 최근 1년 히츠를 구매한 고객
    SELECT DISTINCT a.id
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.cigatype != 'CSV'
    AND b.ENGNAME != 'Cleaning Stick'
    AND LEN(a.id) > 4
    AND a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -11, GETDATE()), 112) 
    				 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, 0, GETDATE()), 112)
    AND b.ProductSubFamilyCode = 'HEETS'
)
-- 'HEETS' 제품을 구매한 고객이 'LIL' 제품도 구매한 경우 찾기
SELECT 'GROUP C: HEETS + LIL' , count(distinct a.id) 
FROM cx.fct_K7_Monthly a
	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
WHERE a.id IN (SELECT id FROM HeetsCustomers)
AND b.cigatype = 'HnB' 
and b.ProductFamilyCode ='LIL'
AND b.ENGNAME != 'Cleaning Stick'
AND LEN(a.id) > 4
AND a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -11, GETDATE()), 112) 
				 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, GETDATE()), 112)
;


-- Group D : HEETS + GLO >> 1,042

WITH HeetsCustomers AS (
	-- 최근 1년 히츠를 구매한 고객
    SELECT DISTINCT a.id
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.cigatype != 'CSV'
    AND b.ENGNAME != 'Cleaning Stick'
    AND LEN(a.id) > 4
    AND a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -11, GETDATE()), 112) 
    				 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, 0, GETDATE()), 112)
    AND b.ProductSubFamilyCode = 'HEETS'
)
-- 'HEETS' 제품을 구매한 고객이 'GLO' 제품도 구매한 경우 찾기
SELECT 'GROUP C: HEETS + GLO' , count(distinct a.id) 
FROM cx.fct_K7_Monthly a
	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
WHERE a.id IN (SELECT id FROM HeetsCustomers)
AND b.cigatype = 'HnB' 
AND b.ProductFamilyCode ='GLO' 
AND b.ProductSubFamilyCode in ('NEO', 'NEOSTICKS')
AND b.ENGNAME != 'Cleaning Stick'
AND LEN(a.id) > 4
AND a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -11, GETDATE()), 112) 
				 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, GETDATE()), 112)
;

-- Group D : HEETS + GLO >> 1,042

WITH HeetsCustomers AS (
	-- 최근 1년 히츠를 구매한 고객
    SELECT DISTINCT a.id
    FROM cx.data_all a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.cigatype != 'CSV'
    AND b.ENGNAME != 'Cleaning Stick'
    AND LEN(a.id) > 4
    AND a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -11, GETDATE()), 112) 
    				 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, 0, GETDATE()), 112)
    AND b.ProductSubFamilyCode = 'HEETS'
)
-- 'HEETS' 제품을 구매한 고객이 'GLO' 제품도 구매한 경우 찾기
SELECT 'GROUP C: HEETS + GLO' , count(distinct a.id) 
FROM cx.data_all a
	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
WHERE a.id IN (SELECT id FROM HeetsCustomers)
AND b.cigatype = 'HnB' 
AND b.ProductFamilyCode ='GLO' 
AND b.ProductSubFamilyCode in ('NEO', 'NEOSTICKS')
AND b.ENGNAME != 'Cleaning Stick'
AND LEN(a.id) > 4
AND a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -11, GETDATE()), 112) 
				 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, GETDATE()), 112)
;


-- 202310 월이 맥스임..
select max(a.YYYYMM), min(a.YYYYMM) from cx.fct_K7_Monthly a ;



where a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, GETDATE()), 112) 
				 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, 0, GETDATE()), 112);


ALTER TABLE cx.product_master_temp ALTER COLUMN PROD_ID VARCHAR(255);

create index ix_product_master_temp_prod_id on cx.product_master_temp(PROD_ID);
create index ix_data_all_YYYYMM on cx.data_all(YYYYMM);
create index ix_data_all_product_code on cx.data_all(product_code);

-- 직전 4-12개월 이내 히츠만 사용중인 고객 뷰 생성
CREATE VIEW v_filtered_4_12 AS
SELECT a.id, a.product_code, a.YYYYMM
FROM cx.data_all a
	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
WHERE b.ENGNAME != 'Cleaning Stick'
AND LEN(a.id) > 4
AND a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -11, GETDATE()), 112) 
                 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, GETDATE()), 112);
                 
                
SELECT count(DISTINCT a.id)
FROM cx.data_all a
	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
WHERE 1=1 
AND b.ProductSubFamilyCode = 'HEETS'
and b.ENGNAME != 'Cleaning Stick'
AND LEN(a.id) > 4
AND a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -11, GETDATE()), 112) 
				 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, GETDATE()), 112)
;

select * from cx.product_master_temp pmt 
where ProductSubFamilyCode = 'HEETS';