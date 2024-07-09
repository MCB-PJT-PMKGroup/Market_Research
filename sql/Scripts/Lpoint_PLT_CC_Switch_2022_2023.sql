	SELECT 
		b.cigatype,
	    b.ProductFamilyCode,
	    a.product_code,
		a.id,
	    SUM(CASE WHEN left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) AS [Out],
	    SUM(CASE WHEN left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) AS [In]
	into cx.agg_PLT_CC_Switch2
	FROM 
	    cx.fct_K7_Monthly a
	    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
	where 1=1
	   	and left(a.YYYYMM, 4) in ('2022', '2023')
	    AND b.ProductFamilyCode ='PLT' and b.Productcode in ('PLTKSB', 'PLTMLD', 'PLTONE', 'PLTHYB1','PLTHYB5')
	GROUP BY 
	    b.cigatype, b.ProductFamilyCode, a.product_code,  a.id
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
	        and a.product_code != x.product_code
	        )
		)
	    OR
	    -- "out" 상태: 2022년 에는 구매하고 2023년에는 구매하지 않음
	    (SUM(CASE WHEN  left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0
	    AND SUM(CASE WHEN left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) = 0
	    AND EXISTS (
	    	-- 2023년에 다른 제품을 구매한 이력이 있는 사람만
	        SELECT 1
	        FROM cx.fct_K7_Monthly x
	        	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
	        where a.id = x.id and left(x.YYYYMM, 4) = '2023'
	        --AND b.ProductFamilyCode != y.ProductFamilyCode
	    	and a.product_code != x.product_code
	        )
	    );
	    
	   
--PLTHYB1	2956
--PLTKSB	15890
--PLTMLD	6059
--PLTONE	7830
--PLTHYB5	11382	   
   select Productcode , count(*)
   from cx.agg_PLT_CC_Switch
   group by Productcode ;
   
  
-- CC Switching 작업
-- Total CC/HnB Count 출력
select  
	t.ProductCode,
	b.cigatype,
	b.New_FLAVORSEG,
	b.New_TARSEGMENTAT,
	'',	-- 엑셀 공백
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
	end)as Out_quantity,
	sum(case 
		when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then a.buy_ct * a.pack_qty 
	end) as In_quantity
from 
	cx.agg_PLT_CC_Switch t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023')
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
where 
--	and b.ProductFamilyCode != t.ProductFamilyCode
	 b.Productcode != t.Productcode 
group by rollup(t.ProductCode, b.cigatype, b.New_FLAVORSEG, New_TARSEGMENTAT)
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
