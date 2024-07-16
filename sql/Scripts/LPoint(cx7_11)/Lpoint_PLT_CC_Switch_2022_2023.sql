SELECT 
    a.product_code,
	a.id,
	b.ProductFamilyCode , b.New_TARSEGMENTAT,
    SUM(CASE WHEN left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) AS [Out],
    SUM(CASE WHEN left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) AS [In]
into cx.agg_PLT_CC_Switch3
FROM 
    cx.fct_K7_Monthly a
    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
where 1=1
   	and left(a.YYYYMM, 4) in ('2022', '2023')
    -- 말보로 골드, 말보로 미디엄
	AND b.ProductFamilyCode ='PLT' and b.Productcode in ('PLTKSB', 'PLTMLD', 'PLTONE', 'PLTHYB1','PLTHYB5')
    --2022, 2023년 모두 구매한 사람은 제외
    and a.id not in (	
	    SELECT 
			x.id
        FROM cx.fct_K7_Monthly x
        	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
		where 1=1
		   	and left(x.YYYYMM, 4) in ('2022', '2023')
		   	-- 팔리아멘트
			AND y.ProductFamilyCode ='PLT' and y.Productcode in ('PLTKSB', 'PLTMLD', 'PLTONE', 'PLTHYB1','PLTHYB5')
		GROUP BY 
		    y.cigatype, y.ProductFamilyCode, y.Productcode, x.id
		HAVING 
		    -- 2023년, 2022년에 모두 구매함	
		    (SUM(CASE WHEN left(x.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) > 0
		    AND SUM(CASE WHEN left(x.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0)
	)
GROUP BY 
    a.product_code, a.id ,b.ProductFamilyCode , b.New_TARSEGMENTAT
HAVING
    -- Out : 2022년도에는 구매했지만 2023년도에는 해당 제품을 구매하지 않아 Out
	(SUM(CASE WHEN  left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0
	and SUM(CASE WHEN  left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) = 0
    AND EXISTS (
		-- 2023년에는 다른 제품을 구매한 사람
	    SELECT 1
	    FROM cx.fct_K7_Monthly x
	    	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
	    where a.id = x.id and left(x.YYYYMM, 4) = '2023'
		and x.product_code != a.product_code 
    	)
	)
	OR
    -- In : 2022년도에는 구매하지 않고 2023년도에는 해당 제품을 구매하여 IN
    (SUM(CASE WHEN left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) > 0
    AND SUM(CASE WHEN left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) = 0 
    AND EXISTS (
    	-- 2022년에 다른 제품을 구매한 사람
	    SELECT 1
	    FROM cx.fct_K7_Monthly x
	    	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
	    where a.id = x.id and left(x.YYYYMM, 4) = '2022'
	    and x.product_code != a.product_code 
    	)
    )
;



--	SELECT 
--		b.cigatype,
--	    b.ProductFamilyCode,
--	    a.product_code,
--		a.id,
--	    SUM(CASE WHEN left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) AS [Out],
--	    SUM(CASE WHEN left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) AS [In]
--	into cx.agg_PLT_CC_Switch2
--	FROM 
--	    cx.fct_K7_Monthly a
--	    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
--	where 1=1
--	   	and left(a.YYYYMM, 4) in ('2022', '2023')
--	    AND b.ProductFamilyCode ='PLT' and b.Productcode in ('PLTKSB', 'PLTMLD', 'PLTONE', 'PLTHYB1','PLTHYB5')
--	GROUP BY 
--	    b.cigatype, b.ProductFamilyCode, a.product_code,  a.id
--	HAVING 
--	    -- "in" 상태: 2023년 에는 구매하고 2022년에는 구매하지 않음
--	    (SUM(CASE WHEN left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) > 0
--	    AND SUM(CASE WHEN left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) = 0
--	    AND EXISTS (
--	        -- 2022년에 구매한 이력이 있는 경우
--	        SELECT 1
--	        FROM cx.fct_K7_Monthly x
--	        	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
--	        where a.id = x.id and left(x.YYYYMM, 4) = '2022'
--	        and a.product_code != x.product_code
--	        )
--		)
--	    OR
--	    -- "out" 상태: 2022년 에는 구매하고 2023년에는 구매하지 않음
--	    (SUM(CASE WHEN  left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0
--	    AND SUM(CASE WHEN left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) = 0
--	    AND EXISTS (
--	    	-- 2023년에 다른 제품을 구매한 이력이 있는 사람만
--	        SELECT 1
--	        FROM cx.fct_K7_Monthly x
--	        	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
--	        where a.id = x.id and left(x.YYYYMM, 4) = '2023'
--	        --AND b.ProductFamilyCode != y.ProductFamilyCode
--	    	and a.product_code != x.product_code
--	        )
--	    );
	   
--88013121	PARLIAMENT AQUA 5
--88014463	PARLIAMENT AQUA 3
--88013114	PARLIAMENT ONE
--88017693	PARLIAMENT HYBRID
--88017624	PARLIAMENT HYBRID 5
SELECT distinct product_code , b.engname
FROM BPDA.cx.agg_PLT_CC_Switch2 a
	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id);
	   
-- cigatype, Taste, Tar CC Switching 작업
select  
	b.cigatype,	
	b.New_FLAVORSEG,
	b.New_TARSEGMENTAT,
	count(distinct case when left(a.YYYYMM, 4) = '2023' and t.[out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(distinct case when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
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
	cx.agg_PLT_CC_Switch3 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') and a.product_code not in( t.product_code)
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
WHERE t.product_code = '88017693'
group by grouping sets ((b.cigatype, b.New_FLAVORSEG, b.New_TARSEGMENTAT),  (b.cigatype, b.New_FLAVORSEG),  (b.cigatype), ())
;

-- SKU 별 Switching In/Out
select
	b.cigatype,
	b.Engname,
	b.New_Flavorseg,
	b.New_Tarsegmentat,
	b.THICKSEG,
	count(DISTINCT case when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(DISTINCT case when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	'',
	'',
	'',
	sum(case when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then a.buy_ct * a.Pack_qty end ) as Out_Quantity,
	sum(case when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then a.buy_ct * a.Pack_qty end ) as In_Quantity
from cx.agg_PLT_CC_Switch3  t
	join cx.fct_K7_Monthly a on t.id = a.id and 4 < len(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') and a.product_code not in(t.product_code) 
	join cx.product_master_temp b on a.Product_code = b.prod_id and b.CIGADEVICE ='CIGARETTES' and b.CIGATYPE != 'CSV' 
WHERE t.product_code = '88017693'
group by grouping sets ((b.cigatype, b.Engname, b.New_Flavorseg, b.New_Tarsegmentat, b.THICKSEG), (b.cigatype), ())
;
	   


-- 2022년 ~ 2023년동안 지속적으로 동일한 제품을 이용한 고객
-- 25,404
with temp as (
	SELECT 
		b.cigatype,
	    b.ProductFamilyCode,
	    b.engname,
		a.id,
	    SUM(CASE WHEN left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) AS [Out],
	    SUM(CASE WHEN left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) AS [In]
	FROM 
	    cx.fct_K7_Monthly a
	    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
	where 1=1
	   	and left(a.YYYYMM, 4) in ('2022', '2023')
	    AND b.ProductFamilyCode ='PLT' and b.Productcode in ('PLTKSB', 'PLTMLD', 'PLTONE', 'PLTHYB1','PLTHYB5')
	GROUP BY 
	    b.cigatype, b.ProductFamilyCode, b.engname,  a.id
	HAVING    
	 	-- 2022년에 구매하고 2023년에도 구매한 사람들
	    (SUM(CASE WHEN  left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0
	    AND SUM(CASE WHEN left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) > 0)
)
select 
	engname, 
	count(distinct id) as Purchaser_cnt
from temp
group by engname
;
