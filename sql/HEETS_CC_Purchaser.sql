-- 최근 1년 히츠와(테리어 제외) 다른 담배 제품을 구매한 적 있는 고객 (23년 7월 1일 부터 24년 6월 20일)
select CONVERT(NVARCHAR(6), DATEADD(MONTH, -11, GETDATE()), 112) 
      , CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, GETDATE()), 112)
      , CONVERT(NVARCHAR(6), DATEADD(MONTH, -2, GETDATE()), 112) 
      , CONVERT(NVARCHAR(6), DATEADD(MONTH, 0, GETDATE()), 112);

select max(a.YYYYMM), min(a.YYYYMM) from cx.fct_K7_Monthly a ;



-- 직전 4~12개월 이내 구매 고객 수
SELECT 
    CASE 
        WHEN CC_Purchased = 1 AND LIL_Purchased = 1 AND GLO_Purchased = 1 THEN 'HEETS + CC + LIL + GLO'
        WHEN CC_Purchased = 1 AND LIL_Purchased = 1 AND GLO_Purchased = 0 THEN 'HEETS + CC + LIL'
        WHEN CC_Purchased = 1 AND LIL_Purchased = 0 AND GLO_Purchased = 1 THEN 'HEETS + CC + GLO'
        WHEN CC_Purchased = 1 AND LIL_Purchased = 0 AND GLO_Purchased = 0 THEN 'HEETS + CC'
        WHEN CC_Purchased = 0 AND LIL_Purchased = 1 AND GLO_Purchased = 1 THEN 'HEETS + LIL + GLO'
        WHEN CC_Purchased = 0 AND LIL_Purchased = 1 AND GLO_Purchased = 0 THEN 'HEETS + LIL'
        WHEN CC_Purchased = 0 AND LIL_Purchased = 0 AND GLO_Purchased = 1 THEN 'HEETS + GLO'
        WHEN CC_Purchased = 0 AND LIL_Purchased = 0 AND GLO_Purchased = 0 THEN 'HEETS Only'
    END AS CustomerGroup,
    COUNT(*) AS CustomerCount
FROM (
	-- HEETS 사용자가 다른 제품 구매 여부
    SELECT 
        a.id,
        MAX(CASE WHEN b.cigatype = 'CC' THEN 1 ELSE 0 END) AS CC_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductFamilyCode = 'LIL' THEN 1 ELSE 0 END) AS LIL_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductFamilyCode = 'GLO' and b.ProductSubFamilyCode != 'GLOKIT' THEN 1 ELSE 0 END) AS GLO_Purchased
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.ENGNAME != 'Cleaning Stick' and b.cigatype != 'CSV'
    AND LEN(a.id) > 4
    AND a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -11, GETDATE()), 112) 
                     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, GETDATE()), 112)
    AND a.id IN (
    	-- 최근 1년 HEETS 구매한 적 있는 소비자 추출
        SELECT DISTINCT a.id
        FROM cx.fct_K7_Monthly a
        	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
        WHERE b.ProductSubFamilyCode = 'HEETS'
	    AND a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -11, GETDATE()), 112) 
	                 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, 0, GETDATE()), 112)
    )
    GROUP BY a.id
) AS CustomerPurchases
GROUP BY 
    CASE 
        WHEN CC_Purchased = 1 AND LIL_Purchased = 1 AND GLO_Purchased = 1 THEN 'HEETS + CC + LIL + GLO'
        WHEN CC_Purchased = 1 AND LIL_Purchased = 1 AND GLO_Purchased = 0 THEN 'HEETS + CC + LIL'
        WHEN CC_Purchased = 1 AND LIL_Purchased = 0 AND GLO_Purchased = 1 THEN 'HEETS + CC + GLO'
        WHEN CC_Purchased = 1 AND LIL_Purchased = 0 AND GLO_Purchased = 0 THEN 'HEETS + CC'
        WHEN CC_Purchased = 0 AND LIL_Purchased = 1 AND GLO_Purchased = 1 THEN 'HEETS + LIL + GLO'
        WHEN CC_Purchased = 0 AND LIL_Purchased = 1 AND GLO_Purchased = 0 THEN 'HEETS + LIL'
        WHEN CC_Purchased = 0 AND LIL_Purchased = 0 AND GLO_Purchased = 1 THEN 'HEETS + GLO'
        WHEN CC_Purchased = 0 AND LIL_Purchased = 0 AND GLO_Purchased = 0 THEN 'HEETS Only'
    END
;


-- 직전 4~12개월 이내 총 합계(중복 제거) 34,769
SELECT 
 	count(DISTINCT a.id)
FROM cx.fct_K7_Monthly a
	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
WHERE b.ENGNAME != 'Cleaning Stick' and b.cigatype != 'CSV'
AND LEN(a.id) > 4
AND a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -11, GETDATE()), 112) 
                 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, GETDATE()), 112)
AND a.id IN (
    SELECT DISTINCT a.id
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.ProductSubFamilyCode = 'HEETS'
)
;



-- 직전 1~3개월 이내 구매 고객 수
SELECT 
    CASE 
        WHEN CC_Purchased = 1 AND LIL_Purchased = 1 AND GLO_Purchased = 1 THEN 'HEETS + CC + LIL + GLO'
        WHEN CC_Purchased = 1 AND LIL_Purchased = 1 AND GLO_Purchased = 0 THEN 'HEETS + CC + LIL'
        WHEN CC_Purchased = 1 AND LIL_Purchased = 0 AND GLO_Purchased = 1 THEN 'HEETS + CC + GLO'
        WHEN CC_Purchased = 1 AND LIL_Purchased = 0 AND GLO_Purchased = 0 THEN 'HEETS + CC'
        WHEN CC_Purchased = 0 AND LIL_Purchased = 1 AND GLO_Purchased = 1 THEN 'HEETS + LIL + GLO'
        WHEN CC_Purchased = 0 AND LIL_Purchased = 1 AND GLO_Purchased = 0 THEN 'HEETS + LIL'
        WHEN CC_Purchased = 0 AND LIL_Purchased = 0 AND GLO_Purchased = 1 THEN 'HEETS + GLO'
        WHEN CC_Purchased = 0 AND LIL_Purchased = 0 AND GLO_Purchased = 0 THEN 'HEETS Only'
    END AS CustomerGroup,
    COUNT(*) AS CustomerCount
FROM (
	-- HEETS 사용자가 다른 제품 구매 여부
    SELECT 
        a.id,
        MAX(CASE WHEN b.cigatype = 'CC' THEN 1 ELSE 0 END) AS CC_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductFamilyCode = 'LIL' THEN 1 ELSE 0 END) AS LIL_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductFamilyCode = 'GLO' and b.ProductSubFamilyCode != 'GLOKIT' THEN 1 ELSE 0 END) AS GLO_Purchased
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.ENGNAME != 'Cleaning Stick' and b.cigatype != 'CSV'
    AND LEN(a.id) > 4
    AND a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -2, GETDATE()), 112) 
                     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, 0, GETDATE()), 112)
    AND a.id IN (
    	-- HEETS 구매한 적 있는 소비자 추출
        SELECT DISTINCT a.id
        FROM cx.fct_K7_Monthly a
        	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
        WHERE b.ProductSubFamilyCode = 'HEETS'
        AND a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -11, GETDATE()), 112) 
                     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, 0, GETDATE()), 112)
    )
    GROUP BY a.id
) AS CustomerPurchases
GROUP BY 
    CASE 
        WHEN CC_Purchased = 1 AND LIL_Purchased = 1 AND GLO_Purchased = 1 THEN 'HEETS + CC + LIL + GLO'
        WHEN CC_Purchased = 1 AND LIL_Purchased = 1 AND GLO_Purchased = 0 THEN 'HEETS + CC + LIL'
        WHEN CC_Purchased = 1 AND LIL_Purchased = 0 AND GLO_Purchased = 1 THEN 'HEETS + CC + GLO'
        WHEN CC_Purchased = 1 AND LIL_Purchased = 0 AND GLO_Purchased = 0 THEN 'HEETS + CC'
        WHEN CC_Purchased = 0 AND LIL_Purchased = 1 AND GLO_Purchased = 1 THEN 'HEETS + LIL + GLO'
        WHEN CC_Purchased = 0 AND LIL_Purchased = 1 AND GLO_Purchased = 0 THEN 'HEETS + LIL'
        WHEN CC_Purchased = 0 AND LIL_Purchased = 0 AND GLO_Purchased = 1 THEN 'HEETS + GLO'
        WHEN CC_Purchased = 0 AND LIL_Purchased = 0 AND GLO_Purchased = 0 THEN 'HEETS Only'
    END
;



-- 직전 1~3개월 이내 총 합계(중복 제거) 18,204
SELECT 
 	count(DISTINCT a.id)
FROM cx.fct_K7_Monthly a
	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
WHERE b.ENGNAME != 'Cleaning Stick'  and b.cigatype != 'CSV'
AND LEN(a.id) > 4
AND a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -2, GETDATE()), 112) 
                 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, 0, GETDATE()), 112)
AND a.id IN (
    SELECT DISTINCT a.id
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.ProductSubFamilyCode = 'HEETS'
)

;








-- 연습 
SELECT 
    a.id,
    MAX(CASE WHEN b.cigatype = 'CC' THEN 1 ELSE 0 END) AS CC_Purchased,
    MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductFamilyCode = 'LIL' THEN 1 ELSE 0 END) AS LIL_Purchased,
    MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductFamilyCode = 'GLO' and b.ProductSubFamilyCode != 'GLOKIT' THEN 1 ELSE 0 END) AS GLO_Purchased,
    max(prod_id)
FROM cx.fct_K7_Monthly a
	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
WHERE b.ENGNAME != 'Cleaning Stick'
AND LEN(a.id) > 4
AND a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -2, GETDATE()), 112) 
                 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, 0, GETDATE()), 112)
AND a.id IN (
	-- HEETS 구매한 적 있는 소비자 추출
    SELECT DISTINCT a.id
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.ProductSubFamilyCode = 'HEETS'
    AND a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -11, GETDATE()), 112) 
                 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, 0, GETDATE()), 112)
)
GROUP BY a.id;

-- 34,769, 18,204
SELECT 
 	count(DISTINCT a.id)
FROM cx.fct_K7_Monthly a
	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
WHERE b.ENGNAME != 'Cleaning Stick'
AND LEN(a.id) > 4
AND a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -2, GETDATE()), 112) 
                 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, 0, GETDATE()), 112)
AND a.id IN (
    SELECT DISTINCT a.id
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.ProductSubFamilyCode = 'HEETS'
)
;

-- NEO, NEOSTICKS 만 추출
select * from cx.product_master_temp b 
where b.cigatype = 'HnB' AND b.ProductFamilyCode = 'GLO' and b.ProductSubFamilyCode != 'GLOKIT';