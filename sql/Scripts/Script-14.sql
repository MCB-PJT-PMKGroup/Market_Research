select min(YYYYMM), max(YYYYMM)
from cx.fct_CC_purchases_monthly ;

select cast(pmt.SAL_QNT as float) from cx.product_master_temp pmt ;

-- 2022, 2023년에 (2022 vs. 2023) Family name: 말보로 / Tar: LTS 제품 >> In/Out 모수
-- 34615건 추가
SELECT 
    b.ProductFamilyCode,
	a.id,
    SUM(CASE WHEN c.Year = '2022' THEN 1 ELSE 0 END) AS 'Out',
    SUM(CASE WHEN c.Year = '2023' THEN 1 ELSE 0 END) AS 'In'
into cx.agg_MLB_LTS_Switch
FROM 
    cx.fct_K7_Monthly a
    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
    	join cx.dim_calendar c on a.YYYYMM = c.YYYYMM
where 1=1
    AND c.year IN ('2022', '2023')
    AND b.ProductFamilyCode = 'MLB' and b.New_TARSEGMENTAT = 'LTS'
GROUP BY 
    b.ProductFamilyCode, a.id
HAVING 
    -- "in" 상태: 2023년 에는 구매하고 2022년에는 구매하지 않음
    (SUM(CASE WHEN c.Year = '2023' THEN 1 ELSE 0 END) > 0
    AND SUM(CASE WHEN c.Year = '2022' THEN 1 ELSE 0 END) = 0
    AND EXISTS (
        -- 2022년에 구매한 이력이 있는 경우
        SELECT 1
        FROM cx.fct_K7_Monthly x
        	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
        	join cx.dim_calendar z on x.YYYYMM = z.YYYYMM and z.Year = '2022'
        where a.id = x.id
        AND b.ProductFamilyCode != y.ProductFamilyCode
        )
	)
    OR
    -- "out" 상태: 2022년 에는 구매하고 2023년에는 구매하지 않음
    (SUM(CASE WHEN  c.Year = '2022' THEN 1 ELSE 0 END) > 0
    AND SUM(CASE WHEN c.Year = '2023' THEN 1 ELSE 0 END) = 0
    AND EXISTS (
    	-- 3월에 구매한 이력이 있는 경우
        SELECT 1
        FROM cx.fct_K7_Monthly x
        	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
        	join cx.dim_calendar z on x.YYYYMM = z.YYYYMM and z.Year = '2023'
        where a.id = x.id
        AND b.ProductFamilyCode != y.ProductFamilyCode
    	)
    );