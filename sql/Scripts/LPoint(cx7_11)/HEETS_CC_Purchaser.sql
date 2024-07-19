-- 최근 1년 히츠와(테리어 제외) 다른 담배 제품을 구매한 적 있는 고객 (23년 7월 1일 부터 24년 6월 20일)
-- 날짜 범위 계산
select CONVERT(NVARCHAR(6), DATEADD(MONTH, -11, GETDATE()), 112) 
      , CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, GETDATE()), 112)
      , CONVERT(NVARCHAR(6), DATEADD(MONTH, -2, GETDATE()), 112) 
      , CONVERT(NVARCHAR(6), DATEADD(MONTH, 0, GETDATE()), 112);

-- 과거 날짜, 최신 일자 조회
select max(a.YYYYMM), min(a.YYYYMM) from cx.fct_K7_Monthly a ;

-- HEETS 존재 하는지 체크, 이후 다른 제품 구매 이력 확인
select * 
from cx.fct_K7_Monthly a 
	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
where a.id ='6226B1DE8D311B9C41399D6BDE015E78D336CDB5A6ACA7AE29F13B0D98831E40'
order by a.YYYYMM;


-- 106,548건. 전체 HEETS 구매자 조회 (테리어 제외)
 SELECT 
        a.id,
        MAX(a.YYYYMM) AS LastPurchaseMonth
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.ProductSubFamilyCode = 'HEETS'
    AND NOT EXISTS (
    	-- TEREA 구매자는 제외
        SELECT 1
        FROM cx.fct_K7_Monthly t
        	JOIN cx.product_master_temp c ON t.product_code = c.PROD_ID
        WHERE t.id = a.id AND c.ProductSubFamilyCode = 'TEREA'
    )
    GROUP BY a.id
    ;

-- 21,597건. 1년 동안 HEETS 구매자 Total 조회 (테리어 제외)
-- 17,520 건 
WITH HEETS_Purchasers AS (
	-- 1년 내에 HEETS 구매한 적이 있는 사람들 마지막달 추출 (테리어 구매한 사람은 제외)
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
		 AND LastPurchaseMonth BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -11, GETDATE()), 112) 
								   AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, GETDATE()), 112)
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


-- 직전 1 ~ 3개월 전 4,077 건 
WITH HEETS_Purchasers AS (
	-- 1년 내에 HEETS 구매한 적이 있는 사람들 마지막달 추출 (테리어 구매한 사람은 제외)
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
      -- HEETS이후 다른 담배 제품 구매한 이력여부 확인
      AND EXISTS (
      	SELECT 1 
		FROM HEETS_Purchasers c 
	   WHERE LastPurchaseMonth <= a.YYYYMM 
		 AND a.id = c.id
	     -- 직전 1개월 ~ 3개월 전 마지막 HEETS 구매자 대상
		 AND LastPurchaseMonth BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -2, GETDATE()), 112) 
                       			   AND CONVERT(NVARCHAR(6), DATEADD(MONTH, 0, GETDATE()), 112)
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





------------------------------------------------------------------------- 과거 작업  스크립트------------------------------------------------------
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
	-- HEETS 사용자가 다른 제품을 구매한 여부
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
    	-- 최근 1년 HEETS 구매한 적 있는 소비자 추출 (테리어 구매한 이력있는 소비자 제외)
        SELECT DISTINCT a.id
        FROM cx.fct_K7_Monthly a
        	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
        WHERE b.ProductSubFamilyCode = 'HEETS'
        AND not Exists (select 1 
						from cx.fct_K7_Monthly t 
							JOIN cx.product_master_temp c ON t.product_code = c.PROD_ID
						where t.id = a.id and c.ProductSubFamilyCode = 'TEREA')
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
	-- 최근 1년 HEETS 구매한 적 있는 소비자 추출 (테리어 구매한 이력있는 소비자 제외)
    SELECT DISTINCT a.id
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.ProductSubFamilyCode = 'HEETS'
    AND not Exists (select 1 
					from cx.fct_K7_Monthly t 
						JOIN cx.product_master_temp c ON t.product_code = c.PROD_ID
					where t.id = a.id and c.ProductSubFamilyCode = 'TEREA')
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
	-- HEETS 사용자가 다른 제품을 구매한 여부
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
    	-- 최근 1년 HEETS 구매한 적 있는 소비자 추출 (테리어 구매한 이력있는 소비자 제외)
        SELECT DISTINCT a.id
        FROM cx.fct_K7_Monthly a
        	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
        WHERE b.ProductSubFamilyCode = 'HEETS'
        AND not Exists (select 1 
						from cx.fct_K7_Monthly t 
							JOIN cx.product_master_temp c ON t.product_code = c.PROD_ID
						where t.id = a.id and c.ProductSubFamilyCode = 'TEREA')
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
	-- 최근 1년 HEETS 구매한 적 있는 소비자 추출 (테리어 제외)
    SELECT DISTINCT a.id
    FROM cx.fct_K7_Monthly a
    	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE b.ProductSubFamilyCode = 'HEETS'
    AND not Exists (select 1 
					from cx.fct_K7_Monthly t 
						JOIN cx.product_master_temp c ON t.product_code = c.PROD_ID
					where t.id = a.id and c.ProductSubFamilyCode = 'TEREA')
)

;



-- 직전 4개월 ~ 12개월 전 마지막으로 히츠를 구매한	적이 사람들 추출 (테리어 구매한 사람은 제외)
SELECT 
    a.id,
    b.ProductSubFamilyCode,
    MAX(a.YYYYMM) AS LastPurchaseMonth,
    count(*)
FROM cx.fct_K7_Monthly a
	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
WHERE b.ProductSubFamilyCode = 'HEETS'
AND NOT EXISTS (
    SELECT 1
    FROM cx.fct_K7_Monthly t
    	JOIN cx.product_master_temp c ON t.product_code = c.PROD_ID
    WHERE t.id = a.id AND c.ProductSubFamilyCode = 'TEREA'
)
AND a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -11, GETDATE()), 112) 
             	 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, GETDATE()), 112)
GROUP BY a.id, b.ProductSubFamilyCode
;

-- 연습 
-- 009FB87150BB97EDFFE6AB7390FCB8E1B1AC24CDF26A2EFDACE82054357E734B	202307
-- 007BEBECD084A6CD3439890FA45D1AA51DF8370E00E67E14A1E04A5E7551094C	202403

-- 히츠 존재하는지 체크, 이후 다른 제품 구매 체크
select * 
from cx.fct_K7_Monthly a 
	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
where a.id ='049C4E73E91A0A71DC7AFED88E7D6F3BCD2015C9F80E932977CC29037011A1BF'
order by a.YYYYMM;


   
-- 구매자 '007BEBECD084A6CD3439890FA45D1AA51DF8370E00E67E14A1E04A5E7551094C' 조회가 되면 안됨
WITH HEETS_Purchasers AS (
	-- 직전 4개월 ~ 12개월 전 마지막으로 히츠를 구매한	사람들 추출
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
      AND a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -11, GETDATE()), 112) 
                 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, GETDATE()), 112)
    GROUP BY a.id
)
-- HEETS 구매자가 다른 제품을 구매한 여부
SELECT 
    a.id,
    MAX(CASE WHEN b.cigatype = 'CC' THEN 1 ELSE 0 END) AS CC_Purchased,
    MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductFamilyCode = 'LIL' THEN 1 ELSE 0 END) AS LIL_Purchased,
    MAX(CASE WHEN b.cigatype = 'HnB' AND b.ProductFamilyCode = 'GLO' AND b.ProductSubFamilyCode != 'GLOKIT' THEN 1 ELSE 0 END) AS GLO_Purchased
FROM cx.fct_K7_Monthly a
	JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
WHERE b.ENGNAME != 'Cleaning Stick' AND b.cigatype != 'CSV'
AND LEN(a.id) > 4
-- 마지막 구매한 HEETS 이후 다른 제품을 구매한 이력이 있는 사람
AND exists (SELECT 1 FROM HEETS_Purchasers c where LastPurchaseMonth < a.YYYYMM and a.id = c.id)
and a.id = '40C1ED0B30D650EC5C419E85674B0D110EB870F2D0050323C5823660204FD1A5'
GROUP BY a.id


