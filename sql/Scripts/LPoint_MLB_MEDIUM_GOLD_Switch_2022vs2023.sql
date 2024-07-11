--말보로의 경우 말보로 미디엄 말보로 골드도 동일하게 볼 수 있을까요?
--
--아래 지속 구매자 데이터 및 2022 VS. 2023 SWITCHING자료 동일 포맷으로 작업해주시면 됩니다.
--88011745	MARLBORO GOLD ORIGINAL	말보로 골드 오리지널
--88011721	MARLBORO MEDIUM	말보로 미디엄
select PROD_ID, count(*)
from cx.product_master_temp 
group by PROD_ID
having count(*) > 1;

-- 25,489
with temp as (
SELECT 
	a.Product_code, a.id, b.CIGATYPE,
	sum(case when left(a.YYYYMM, 4) = '2022' then 1 else 0 end) as [Out],
	sum(case when left(a.YYYYMM, 4) = '2023' then 1 else 0 end) as [In]
FROM cx.fct_K7_Monthly a
	join cx.product_master_temp b on a.Product_code = b.prod_id and b.CIGADEVICE ='CIGARETTES' and b.CIGATYPE != 'CSV' 
where
	4 < len(a.id) 
	and left(a.YYYYMM, 4) in ('2022', '2023')
	-- 말보로 골드, 말보로 미디엄
	and b.Productcode in ('MLBGLD', 'MMEDFT')
group by a.Product_code, a.id, b.CIGATYPE 
having 
	(sum(case when left(a.YYYYMM, 4) = '2022' then 1 else 0 end) > 0
	and sum(case when left(a.YYYYMM, 4) = '2023' then 1 else 0 end) = 0
	and exists (
		-- 2022년에 구매했지만, 다른제품을 구매한 사람
		select 1
		from cx.fct_K7_Monthly x
			join cx.product_master_temp y on x.Product_code = y.prod_id and y.CIGADEVICE ='CIGARETTES' and y.CIGATYPE != 'CSV' 
		where a.id = x.id and 4 < len(x.id) and left(x.YYYYMM, 4) = '2022'
		and a.Product_code != x.Product_code
		)
	)
	OR
	(sum(case when left(a.YYYYMM, 4) = '2022' then 1 else 0 end) = 0
	and sum(case when left(a.YYYYMM, 4) = '2023' then 1 else 0 end) > 0
	and exists (
		-- 2022년에 구매했지만, 다른제품을 구매한 사람
		select 1
		from cx.fct_K7_Monthly x
			join cx.product_master_temp y on x.Product_code = y.prod_id and y.CIGADEVICE ='CIGARETTES' and y.CIGATYPE != 'CSV'
		where a.id = x.id and 4 < len(x.id) and left(x.YYYYMM, 4) = '2023'
		and a.Product_code != x.Product_code
		)
	)
)
select
	t.Product_code,
	b.cigatype,
	b.New_Flavorseg,
	b.New_Tarsegmentat,
	count(DISTINCT case when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(DISTINCT case when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	sum(case when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then a.buy_ct * a.Pack_qty end ) as Out_Quantity,
	sum(case when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then a.buy_ct * a.Pack_qty end ) as In_Quantity
from temp t
	join cx.fct_K7_Monthly a on t.id = a.id and 4 < len(a.id) and left(a.YYYYMM, 4) in ('2022', '2023')
	join cx.product_master_temp b on a.Product_code = b.prod_id and b.CIGADEVICE ='CIGARETTES' and b.CIGATYPE != 'CSV' 
WHERE t.Product_code != a.Product_code
group by rollup (t.Product_code, b.cigatype, b.New_Flavorseg, b.New_Tarsegmentat)
;


-- 28298
select
	t.Product_code,
	b.cigatype,
	b.New_Flavorseg,
	b.New_Tarsegmentat,
	count(DISTINCT case when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(DISTINCT case when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	sum(case when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then a.buy_ct * a.Pack_qty end ) as Out_Quantity,
	sum(case when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then a.buy_ct * a.Pack_qty end ) as In_Quantity
from cx.agg_MLB_CC_Switch  t
	join cx.fct_K7_Monthly a on t.id = a.id and 4 < len(a.id) and left(a.YYYYMM, 4) in ('2022', '2023')
	join cx.product_master_temp b on a.Product_code = b.prod_id and b.CIGADEVICE ='CIGARETTES' and b.CIGATYPE != 'CSV' 
WHERE t.Product_code != a.Product_code
group by rollup (t.Product_code, b.cigatype, b.New_Flavorseg, b.New_Tarsegmentat)
;





-- 28298
SELECT 
	b.CIGATYPE, a.Product_code, a.id, 
	sum(case when left(a.YYYYMM, 4) = '2022' then 1 else 0 end) as [Out],
	sum(case when left(a.YYYYMM, 4) = '2023' then 1 else 0 end) as [In]
into cx.agg_MLB_CC_Switch
FROM cx.fct_K7_Monthly a
	join cx.product_master_temp b on a.Product_code = b.prod_id and b.CIGADEVICE ='CIGARETTES' and b.CIGATYPE != 'CSV' and 4 < len(a.id) 
where
	left(a.YYYYMM, 4) in ('2022', '2023')
	-- 말보로 골드, 말보로 미디엄
	and b.ProductFamilyCode = 'MLB' and b.Productcode in ('MLBGLD', 'MMEDFT')
group by b.CIGATYPE, a.Product_code, a.id
having 
	-- In
	(sum(case when left(a.YYYYMM, 4) = '2023' then 1 else 0 end) > 0
	and sum(case when left(a.YYYYMM, 4) = '2022' then 1 else 0 end) = 0
	and exists (
		-- 2022년에 구매했지만, 다른제품을 구매한 사람
		select 1
		from cx.fct_K7_Monthly x
			join cx.product_master_temp y on x.Product_code = y.prod_id and y.CIGADEVICE ='CIGARETTES' and y.CIGATYPE != 'CSV' and 4 < len(x.id)
		where a.id = x.id and left(x.YYYYMM, 4) = '2022'
		and a.Product_code != x.Product_code
		)
	)
	OR
	-- Out
	(sum(case when left(a.YYYYMM, 4) = '2022' then 1 else 0 end) > 0
	and sum(case when left(a.YYYYMM, 4) = '2023' then 1 else 0 end) = 0
	and exists (
		-- 2022년에 구매했지만, 다른제품을 구매한 사람
		select 1
		from cx.fct_K7_Monthly x
			join cx.product_master_temp y on x.Product_code = y.prod_id and y.CIGADEVICE ='CIGARETTES' and y.CIGATYPE != 'CSV' and 4 < len(x.id)
		where a.id = x.id and left(x.YYYYMM, 4) = '2023'
		and a.Product_code != x.Product_code
		)
	);
	
--28 298
select product_code, count(case when [Out]>0 then 1 end ) out_cnt, count(case when [In]>0 then 1 end ) In_cnt, count(*)
FROM cx.agg_MLB_CC_Switch 
group by product_code 
 ;
 
--  2022년 ~ 2023년동안 지속적으로 동일한 제품을 이용한 고객
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
	    AND b.ProductFamilyCode ='MLB' and b.Productcode in ('MLBGLD', 'MMEDFT')
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



