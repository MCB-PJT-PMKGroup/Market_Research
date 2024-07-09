-- 2,3월에 Blossom을 구매한 사람이 아닌건가?

SELECT count(distinct id) as [out]
FROM bpda.cx.fct_K7_Monthly a
         JOIN bpda.cx.product_master_temp b ON a.product_code = b.PROD_ID
WHERE b.ENGNAME != 'Cleaning Stick'
  AND b.cigatype != 'CSV'
  AND 4 < LEN(a.id)
  AND a.YYYYMM IN ('202402')
  AND b.engname = 'Marlboro Vista Blossom Mist'
  and not exists (select 1
                FROM
                bpda.cx.fct_K7_Monthly c
                JOIN bpda.cx.product_master_temp d ON c.product_code = d.PROD_ID
                WHERE c.id = a.id
                    and d.ENGNAME != 'Cleaning Stick'
                    AND d.cigatype != 'CSV'
                    AND 4 < LEN(c.id)
                    AND c.YYYYMM IN ('202403')
                    AND d.engname = 'Marlboro Vista Blossom Mist')
  and exists (select 1
            FROM
            bpda.cx.fct_K7_Monthly e
            JOIN bpda.cx.product_master_temp f ON e.product_code = f.PROD_ID
            WHERE e.id = a.id
                and f.ENGNAME != 'Cleaning Stick'
                AND f.cigatype != 'CSV'
                AND 4 < LEN(e.id)
                AND e.YYYYMM IN ('202403')
      );


SELECT distinct id as [in]
FROM bpda.cx.fct_K7_Monthly a
         JOIN bpda.cx.product_master_temp b ON a.product_code = b.PROD_ID
WHERE b.ENGNAME != 'Cleaning Stick'
  AND b.cigatype != 'CSV'
  AND 4 < LEN(a.id)
  AND a.YYYYMM IN ('202403')
  AND b.engname = 'Marlboro Vista Blossom Mist'
  and not exists (select 1
                FROM
                bpda.cx.fct_K7_Monthly c
                JOIN bpda.cx.product_master_temp d ON c.product_code = d.PROD_ID
                WHERE c.id = a.id
                    and d.ENGNAME != 'Cleaning Stick'
                    AND d.cigatype != 'CSV'
                    AND 4 < LEN(c.id)
                    AND c.YYYYMM IN ('202402')
                    AND d.engname = 'Marlboro Vista Blossom Mist')
  -- 구매한 사람이 있어야 함
  and exists (select 1
            FROM
            bpda.cx.fct_K7_Monthly e
            JOIN bpda.cx.product_master_temp f ON e.product_code = f.PROD_ID
            WHERE e.id = a.id
                and f.ENGNAME != 'Cleaning Stick'
                AND f.cigatype != 'CSV'
                AND 4 < LEN(e.id)
                AND e.YYYYMM IN ('202402')
      );
      