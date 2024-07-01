-- Summary Competitors 
select * from cx.product_master_temp b
where  b.cigatype = 'HnB' AND b.ProductFamilyCode != 'IQOS' AND b.ProductSubFamilyCode != 'GLOKIT' ;


-- YYYYMM
-- 1열 직전 4개월 ~ 12개월 전 마지막 HEETS 구매자 대상
WITH HEETS_Purchasers AS (
	-- HEETS 구매한 적이 있는 사람들 마지막 일자 추출 (테리어 구매한 사람은 제외)
    SELECT 
        a.id,
        MAX(a.YYYYMM) AS LastPurchaseMonth
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.ProductSubFamilyCode = 'HEETS'
    AND NOT EXISTS (
        SELECT 1
        FROM cx.fct_K7_Monthly t
        	JOIN cx.product_master_temp c ON t.product_code = c.PROD_ID
        WHERE t.id = a.id AND c.ProductSubFamilyCode = 'TEREA'
    )
    GROUP BY a.id
)
SELECT 
 	'HEETS' + 
	    CASE WHEN CC_Purchased = 1 THEN ' + CC' ELSE '' END +
	    CASE WHEN Competitors_Purchased = 1 THEN ' + Competitors' ELSE '' END AS CompetitorGroup,
    COUNT(*) AS CustomerCount
FROM (
    SELECT 
        a.id,
        MAX(CASE WHEN b.cigatype = 'CC' THEN 1 ELSE 0 END) AS CC_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductFamilyCode != 'IQOS' AND b.ProductSubFamilyCode != 'GLOKIT' THEN 1 ELSE 0 END) AS Competitors_Purchased
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.ENGNAME != 'Cleaning Stick' AND b.cigatype != 'CSV'
      AND LEN(a.id) > 4
      -- HEETS 이후 다른 담배 제품 구매한 이력여부 확인
      AND EXISTS (
      	SELECT 1 
		FROM HEETS_Purchasers c 
	   WHERE LastPurchaseMonth <= a.YYYYMM 
		 AND a.id = c.id
	     -- 직전 4개월 ~ 12개월 전 마지막 HEETS 구매자 대상
		 AND LastPurchaseMonth BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -12, GETDATE()), 112) 
								   AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -4, GETDATE()), 112)
      )
    GROUP BY a.id
) AS CustomerPurchases
GROUP BY 
 'HEETS' + 
    CASE WHEN CC_Purchased = 1 THEN ' + CC' ELSE '' END +
    CASE WHEN Competitors_Purchased = 1 THEN ' + Competitors' ELSE '' END
;




-- YYYYMM
-- 2열 직전 1개월 ~ 3개월 전 마지막 HEETS 구매자 대상
WITH HEETS_Purchasers AS (
	-- HEETS 구매한 적이 있는 사람들 마지막 일자 추출 (테리어 구매한 사람은 제외)
    SELECT 
        a.id,
        MAX(a.YYYYMM) AS LastPurchaseMonth
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.ProductSubFamilyCode = 'HEETS'
    AND NOT EXISTS (
        SELECT 1
        FROM cx.fct_K7_Monthly t
        	JOIN cx.product_master_temp c ON t.product_code = c.PROD_ID
        WHERE t.id = a.id AND c.ProductSubFamilyCode = 'TEREA'
    )
    GROUP BY a.id
)
SELECT 
 	'HEETS' + 
	    CASE WHEN CC_Purchased = 1 THEN ' + CC' ELSE '' END +
	    CASE WHEN Competitors_Purchased = 1 THEN ' + Competitors' ELSE '' END AS CompetitorGroup,
    COUNT(*) AS CustomerCount
FROM (
    SELECT 
        a.id,
        MAX(CASE WHEN b.cigatype = 'CC' THEN 1 ELSE 0 END) AS CC_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductFamilyCode != 'IQOS' AND b.ProductSubFamilyCode != 'GLOKIT' THEN 1 ELSE 0 END) AS Competitors_Purchased
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.ENGNAME != 'Cleaning Stick' AND b.cigatype != 'CSV'
      AND LEN(a.id) > 4
      -- HEETS 이후 다른 담배 제품 구매한 이력여부 확인
      AND EXISTS (
      	SELECT 1 
		FROM HEETS_Purchasers c 
	   WHERE LastPurchaseMonth <= a.YYYYMM 
		 AND a.id = c.id
	     -- 직전 1개월 ~ 3개월 전 마지막 HEETS 구매자 대상
		 AND LastPurchaseMonth BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, GETDATE()), 112) 
                       			   AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, GETDATE()), 112)
      )
    GROUP BY a.id
) AS CustomerPurchases
GROUP BY 
 'HEETS' + 
    CASE WHEN CC_Purchased = 1 THEN ' + CC' ELSE '' END +
    CASE WHEN Competitors_Purchased = 1 THEN ' + Competitors' ELSE '' END
;




-- YYYYMMDD
-- 3열 직전 4개월 ~ 12개월 전 마지막 HEETS 구매자 대상
WITH HEETS_Purchasers AS (
	-- HEETS 구매한 적이 있는 사람들 마지막 일자 추출 (테리어 구매한 사람은 제외)
    SELECT 
        a.id,
        MAX(a.de_dt) AS LastPurchaseDate
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.ProductSubFamilyCode = 'HEETS'
    AND NOT EXISTS (
        SELECT 1
        FROM cx.fct_K7_Monthly t
        	JOIN cx.product_master_temp c ON t.product_code = c.PROD_ID
        WHERE t.id = a.id AND c.ProductSubFamilyCode = 'TEREA'
    )
    GROUP BY a.id
)
SELECT 
 	'HEETS' + 
	    CASE WHEN CC_Purchased = 1 THEN ' + CC' ELSE '' END +
	    CASE WHEN Competitors_Purchased = 1 THEN ' + Competitors' ELSE '' END AS CompetitorGroup,
    COUNT(*) AS CustomerCount
FROM (
    SELECT 
        a.id,
        MAX(CASE WHEN b.cigatype = 'CC' THEN 1 ELSE 0 END) AS CC_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductFamilyCode != 'IQOS' AND b.ProductSubFamilyCode != 'GLOKIT' THEN 1 ELSE 0 END) AS Competitors_Purchased
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.ENGNAME != 'Cleaning Stick' AND b.cigatype != 'CSV'
      AND LEN(a.id) > 4
      -- HEETS 이후 다른 담배 제품 구매한 이력여부 확인
      AND EXISTS (
      	SELECT 1 
		FROM HEETS_Purchasers c 
	   WHERE LastPurchaseDate <= a.de_dt 
		 AND a.id = c.id
		 -- 직전 4개월 ~ 12개월 전 마지막 HEETS 구매자 대상
		 AND format(CAST(LastPurchaseDate AS DATE), 'yyyyMM') BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -12, GETDATE()), 112) 
                       			  								  AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -4, GETDATE()), 112)
      )
    GROUP BY a.id
) AS CustomerPurchases
GROUP BY 
 'HEETS' + 
    CASE WHEN CC_Purchased = 1 THEN ' + CC' ELSE '' END +
    CASE WHEN Competitors_Purchased = 1 THEN ' + Competitors' ELSE '' END
;




-- YYYYMMDD
-- 4열 직전 1개월 ~ 3개월 전체 HEETS 구매자 대상
WITH HEETS_Purchasers AS (
	-- HEETS 구매한 적이 있는 사람들 마지막 일자 추출 (테리어 구매한 사람은 제외)
    SELECT 
        a.id,
        MAX(a.de_dt) AS LastPurchaseDate
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.ProductSubFamilyCode = 'HEETS'
    AND NOT EXISTS (
        SELECT 1
        FROM cx.fct_K7_Monthly t
        	JOIN cx.product_master_temp c ON t.product_code = c.PROD_ID
        WHERE t.id = a.id AND c.ProductSubFamilyCode = 'TEREA'
    )
    GROUP BY a.id
)
SELECT 
 	'HEETS' + 
	    CASE WHEN CC_Purchased = 1 THEN ' + CC' ELSE '' END +
	    CASE WHEN Competitors_Purchased = 1 THEN ' + Competitors' ELSE '' END AS CompetitorGroup,
    COUNT(*) AS CustomerCount
FROM (
    SELECT 
        a.id,
        MAX(CASE WHEN b.cigatype = 'CC' THEN 1 ELSE 0 END) AS CC_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductFamilyCode != 'IQOS' AND b.ProductSubFamilyCode != 'GLOKIT' THEN 1 ELSE 0 END) AS Competitors_Purchased
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.ENGNAME != 'Cleaning Stick' AND b.cigatype != 'CSV'
      AND LEN(a.id) > 4
      -- HEETS 이후 다른 담배 제품 구매한 이력여부 확인
      AND EXISTS (
      	SELECT 1 
		FROM HEETS_Purchasers c 
	   WHERE LastPurchaseDate <= a.de_dt 
		 AND a.id = c.id
		 -- 직전 1개월 ~ 3개월 전 마지막 HEETS 구매자 대상
		 AND format(CAST(LastPurchaseDate AS DATE), 'yyyyMM') BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, GETDATE()), 112) 
                       			   								  AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, GETDATE()), 112)
      )
    GROUP BY a.id
) AS CustomerPurchases
GROUP BY 
 'HEETS' + 
    CASE WHEN CC_Purchased = 1 THEN ' + CC' ELSE '' END +
    CASE WHEN Competitors_Purchased = 1 THEN ' + Competitors' ELSE '' END
;
