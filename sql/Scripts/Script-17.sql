WITH CustomerPurchases AS (
    SELECT
        a.product_code,
        a.id,
        b.ProductFamilyCode,
        b.New_TARSEGMENTAT,
        LEFT(a.YYYYMM, 4) AS Year,
        COUNT(*) AS Purchases
    FROM
        cx.fct_K7_Monthly a
        JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE
        b.CIGADEVICE = 'CIGARETTES'
        AND b.cigatype != 'CSV'
        AND LEN(a.id) > 4
        AND LEFT(a.YYYYMM, 4) IN ('2022', '2023')
        AND b.ProductFamilyCode = 'PLT'
        AND b.Productcode IN ('PLTKSB', 'PLTMLD', 'PLTONE', 'PLTHYB1', 'PLTHYB5')
    GROUP BY
        a.product_code, a.id, b.ProductFamilyCode, b.New_TARSEGMENTAT, LEFT(a.YYYYMM, 4)
),
ExcludedCustomers AS (
    SELECT
        id
    FROM
        CustomerPurchases
    GROUP BY
        id
    HAVING
        COUNT(DISTINCT Year) > 1
),
FilteredPurchases AS (
    SELECT
        product_code,
        id,
        ProductFamilyCode,
        New_TARSEGMENTAT,
        SUM(CASE WHEN Year = '2022' THEN Purchases ELSE 0 END) AS [Out],
        SUM(CASE WHEN Year = '2023' THEN Purchases ELSE 0 END) AS [In]
    FROM
        CustomerPurchases
    WHERE
        id NOT IN (SELECT id FROM ExcludedCustomers)
    GROUP BY
        product_code, id, ProductFamilyCode, New_TARSEGMENTAT
)
SELECT
    *
--INTO    cx.agg_PLT_CC_Switch3
FROM
    FilteredPurchases
WHERE
    ([Out] > 0 AND [In] = 0)
    OR ([In] > 0 AND [Out] = 0);
    
   