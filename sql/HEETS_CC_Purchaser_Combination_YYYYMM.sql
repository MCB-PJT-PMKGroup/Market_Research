-- YYYYMM(월별 기준) HEETS Combination 집계

-- HEETS 존재 하는지 체크, 이후 다른 제품 구매 이력 확인
select * 
from cx.fct_K7_Monthly a 
	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
where a.id ='083A6583C8C135929585A2544F93853F946659293B7E0B0790F3899CF1B8D348'
order by a.YYYYMM;

   

-- 1차 직전 4개월 ~ 12개월 전 마지막 HEETS 구매자 대상 17,520 건 
WITH HEETS_Purchasers AS (
	-- HEETS 구매한 적이 있는 사람들 마지막달 추출 (테리어 구매한 사람은 제외)
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
	    CASE WHEN FIIT_Purchased = 1 THEN ' + FIIT' ELSE '' END +
	    CASE WHEN MIIX_Purchased = 1 THEN ' + MIIX' ELSE '' END +
	    CASE WHEN AIIM_Purchased = 1 THEN ' + AIIM' ELSE '' END +
	    CASE WHEN GLO_Purchased = 1 THEN ' + GLO' ELSE '' END AS CustomerGroup,
    COUNT(*) AS CustomerCount
FROM (
    SELECT 
        a.id,
        MAX(CASE WHEN b.cigatype = 'CC' THEN 1 ELSE 0 END) AS CC_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductSubFamilyCode = 'FIIT' THEN 1 ELSE 0 END) AS FIIT_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductSubFamilyCode = 'MIIX' THEN 1 ELSE 0 END) AS MIIX_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductSubFamilyCode = 'AIIM' THEN 1 ELSE 0 END) AS AIIM_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductFamilyCode = 'GLO' AND b.ProductSubFamilyCode != 'GLOKIT' THEN 1 ELSE 0 END) AS GLO_Purchased
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
    CASE WHEN FIIT_Purchased = 1 THEN ' + FIIT' ELSE '' END +
    CASE WHEN MIIX_Purchased = 1 THEN ' + MIIX' ELSE '' END +
    CASE WHEN AIIM_Purchased = 1 THEN ' + AIIM' ELSE '' END +
    CASE WHEN GLO_Purchased = 1 THEN ' + GLO' ELSE '' END
;


-- 2차 직전 1개월 ~ 3개월 전 마지막 HEETS 구매자 대상. 4,077 건 
WITH HEETS_Purchasers AS (
	-- HEETS 구매한 적이 있는 사람들 마지막달 추출 (테리어 구매한 사람은 제외)
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
	    CASE WHEN FIIT_Purchased = 1 THEN ' + FIIT' ELSE '' END +
	    CASE WHEN MIIX_Purchased = 1 THEN ' + MIIX' ELSE '' END +
	    CASE WHEN AIIM_Purchased = 1 THEN ' + AIIM' ELSE '' END +
	    CASE WHEN GLO_Purchased = 1 THEN ' + GLO' ELSE '' END AS CustomerGroup,
    COUNT(*) AS CustomerCount
FROM (
    SELECT 
        a.id,
        MAX(CASE WHEN b.cigatype = 'CC' THEN 1 ELSE 0 END) AS CC_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductSubFamilyCode = 'FIIT' THEN 1 ELSE 0 END) AS FIIT_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductSubFamilyCode = 'MIIX' THEN 1 ELSE 0 END) AS MIIX_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductSubFamilyCode = 'AIIM' THEN 1 ELSE 0 END) AS AIIM_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductFamilyCode = 'GLO' AND b.ProductSubFamilyCode != 'GLOKIT' THEN 1 ELSE 0 END) AS GLO_Purchased
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.ENGNAME != 'Cleaning Stick' AND b.cigatype != 'CSV'
      AND LEN(a.id) > 4
      -- HEETS 구매이후 다른 담배 제품 구매한 이력여부 확인
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
    CASE WHEN FIIT_Purchased = 1 THEN ' + FIIT' ELSE '' END +
    CASE WHEN MIIX_Purchased = 1 THEN ' + MIIX' ELSE '' END +
    CASE WHEN AIIM_Purchased = 1 THEN ' + AIIM' ELSE '' END +
    CASE WHEN GLO_Purchased = 1 THEN ' + GLO' ELSE '' END
;



-- 전체 HEETS 구매 내역

-- 3차 직전 4개월 ~ 12개월 전 마지막 HEETS 구매자 대상 17,520 건 
WITH HEETS_Purchasers AS (
	-- HEETS 구매한 적이 있는 사람들 마지막달 추출 (테리어 구매한 사람은 제외)
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
	    CASE WHEN FIIT_Purchased = 1 THEN ' + FIIT' ELSE '' END +
	    CASE WHEN MIIX_Purchased = 1 THEN ' + MIIX' ELSE '' END +
	    CASE WHEN AIIM_Purchased = 1 THEN ' + AIIM' ELSE '' END +
	    CASE WHEN GLO_Purchased = 1 THEN ' + GLO' ELSE '' END AS CustomerGroup,
    COUNT(*) AS CustomerCount
FROM (
    SELECT 
        a.id,
        MAX(CASE WHEN b.cigatype = 'CC' THEN 1 ELSE 0 END) AS CC_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductSubFamilyCode = 'FIIT' THEN 1 ELSE 0 END) AS FIIT_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductSubFamilyCode = 'MIIX' THEN 1 ELSE 0 END) AS MIIX_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductSubFamilyCode = 'AIIM' THEN 1 ELSE 0 END) AS AIIM_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductFamilyCode = 'GLO' AND b.ProductSubFamilyCode != 'GLOKIT' THEN 1 ELSE 0 END) AS GLO_Purchased
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.ENGNAME != 'Cleaning Stick' AND b.cigatype != 'CSV'
      AND LEN(a.id) > 4
      -- HEETS 이후 다른 담배 제품 구매한 이력여부 확인
      AND EXISTS (
      	SELECT 1 
		FROM HEETS_Purchasers c 
	   WHERE 1=1
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
    CASE WHEN FIIT_Purchased = 1 THEN ' + FIIT' ELSE '' END +
    CASE WHEN MIIX_Purchased = 1 THEN ' + MIIX' ELSE '' END +
    CASE WHEN AIIM_Purchased = 1 THEN ' + AIIM' ELSE '' END +
    CASE WHEN GLO_Purchased = 1 THEN ' + GLO' ELSE '' END
;


-- 4차 직전 1개월 ~ 3개월 전 마지막 HEETS 구매자 대상. 4,077 건 
WITH HEETS_Purchasers AS (
	-- HEETS 구매한 적이 있는 사람들 마지막달 추출 (테리어 구매한 사람은 제외)
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
	    CASE WHEN FIIT_Purchased = 1 THEN ' + FIIT' ELSE '' END +
	    CASE WHEN MIIX_Purchased = 1 THEN ' + MIIX' ELSE '' END +
	    CASE WHEN AIIM_Purchased = 1 THEN ' + AIIM' ELSE '' END +
	    CASE WHEN GLO_Purchased = 1 THEN ' + GLO' ELSE '' END AS CustomerGroup,
    COUNT(*) AS CustomerCount
FROM (
    SELECT 
        a.id,
        MAX(CASE WHEN b.cigatype = 'CC' THEN 1 ELSE 0 END) AS CC_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductSubFamilyCode = 'FIIT' THEN 1 ELSE 0 END) AS FIIT_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductSubFamilyCode = 'MIIX' THEN 1 ELSE 0 END) AS MIIX_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductSubFamilyCode = 'AIIM' THEN 1 ELSE 0 END) AS AIIM_Purchased,
        MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductFamilyCode = 'GLO' AND b.ProductSubFamilyCode != 'GLOKIT' THEN 1 ELSE 0 END) AS GLO_Purchased
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.ENGNAME != 'Cleaning Stick' AND b.cigatype != 'CSV'
      AND LEN(a.id) > 4
      -- HEETS 구매이후 다른 담배 제품 구매한 이력여부 확인
      AND EXISTS (
      	SELECT 1 
		FROM HEETS_Purchasers c 
	   WHERE 1 = 1
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
    CASE WHEN FIIT_Purchased = 1 THEN ' + FIIT' ELSE '' END +
    CASE WHEN MIIX_Purchased = 1 THEN ' + MIIX' ELSE '' END +
    CASE WHEN AIIM_Purchased = 1 THEN ' + AIIM' ELSE '' END +
    CASE WHEN GLO_Purchased = 1 THEN ' + GLO' ELSE '' END
;
