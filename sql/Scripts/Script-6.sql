drop table cx.fct_CC_Switch_monthly ;

-- 2월, 3월에 해당하는 In/Out 모수
SELECT 
    a.id,
    a.engname,
    SUM(CASE WHEN a.YYYYMM = '202402' THEN 1 ELSE 0 END) AS 'Out',
    SUM(CASE WHEN a.YYYYMM = '202403' THEN 1 ELSE 0 END) AS 'In'
into cx.fct_CC_Switch_monthly
FROM 
    cx.fct_CC_purchases_monthly a
where 1=1
    AND a.YYYYMM IN ('202402', '202403')
    --AND a.engname = 'Marlboro Vista Blossom Mist'
GROUP BY 
    a.engname, a.id
HAVING 
    -- "in" 상태: 3월에는 구매하고 2월에는 구매하지 않음
    (SUM(CASE WHEN a.YYYYMM = '202403' THEN 1 ELSE 0 END) > 0
    AND SUM(CASE WHEN a.YYYYMM = '202402' THEN 1 ELSE 0 END) = 0
    AND EXISTS (
        SELECT 1
        FROM cx.fct_CC_purchases_monthly c
        where a.id = c.id
        and c.YYYYMM = '202402'
        AND c.engname != a.engname
        )
	)
    OR
    -- "out" 상태: 2월에는 구매하고 3월에는 구매하지 않음
    (SUM(CASE WHEN a.YYYYMM = '202402' THEN 1 ELSE 0 END) > 0
    AND SUM(CASE WHEN a.YYYYMM = '202403' THEN 1 ELSE 0 END) = 0
    AND EXISTS (
        SELECT 1
        FROM cx.fct_CC_purchases_monthly c
        where a.id = c.id
        and c.YYYYMM = '202403'
        AND c.engname != a.engname
    ));
