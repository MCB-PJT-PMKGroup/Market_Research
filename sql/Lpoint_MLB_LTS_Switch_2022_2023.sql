-- Family 별 제품 구매량 집계
-- (2022 vs. 2023) Family name: 말보로 / Tar: LTS 제품 구매자가 다른 Family 제품 구매자 파악


-- 2022, 2023년에 (2022 vs. 2023) Family name: 말보로 / Tar: LTS 제품 >> In/Out 모수
--with temp as (
	SELECT 
		b.cigatype,
	    b.ProductFamilyCode,
	    b.Productcode,
		a.id,
	    SUM(CASE WHEN left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) AS [Out],
	    SUM(CASE WHEN left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) AS [In]
--	into cx.agg_MLB_LTS_Switch
	FROM 
	    cx.fct_K7_Monthly a
	    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
	where 1=1
	   	and left(a.YYYYMM, 4) in ('2022', '2023')
	    AND b.ProductFamilyCode = 'MLB' and b.New_TARSEGMENTAT = 'LTS'
	GROUP BY 
	    b.cigatype, b.ProductFamilyCode, b.Productcode,  a.id
	HAVING 
	    -- "in" 상태: 2023년 에는 구매하고 2022년에는 구매하지 않음
	    (SUM(CASE WHEN left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) > 0
	    AND SUM(CASE WHEN left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) = 0
	    AND EXISTS (
	        -- 2022년에 구매한 이력이 있는 경우
	        SELECT 1
	        FROM cx.fct_K7_Monthly x
	        	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
	        where a.id = x.id and left(x.YYYYMM, 4) = '2022'
	        AND b.ProductFamilyCode != y.ProductFamilyCode
--	        and b.Productcode != y.Productcode
	        )
		)
	    OR
	    -- "out" 상태: 2022년 에는 구매하고 2023년에는 구매하지 않음
	    (SUM(CASE WHEN  left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0
	    AND SUM(CASE WHEN left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) = 0
	    AND EXISTS (
	    	-- 2023년에 구매한 이력이 있는 경우
	        SELECT 1
	        FROM cx.fct_K7_Monthly x
	        	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
	        where a.id = x.id and left(x.YYYYMM, 4) = '2023'
	        AND b.ProductFamilyCode != y.ProductFamilyCode
--	    	and b.Productcode != y.Productcode
	        )
	    )
--)

;

-- CC Switching 작업
select  
	b.cigatype,	
	b.New_FLAVORSEG,
	b.New_TARSEGMENTAT,
	'', 					-- 엑셀 공백
	count(distinct 
	case 
		when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then t.id
	end ) as Out_Purchaser_cnt,
	count(distinct 
	case 
		when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then t.id
	end ) as In_Purchaser_cnt, 
	'',
	'',
	'',
	sum(case 
		when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then a.buy_ct * a.pack_qty 
	end )as Out_quantity,
	sum(case 
		when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then a.buy_ct * a.pack_qty 
	end) as In_quantity
from 
	cx.agg_MLB_LTS_Switch t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023')
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
where b.ProductFamilyCode != t.ProductFamilyCode 
group by rollup(b.cigatype, b.New_FLAVORSEG, b.New_TARSEGMENTAT)

;
