--말보로의 경우 말보로 미디엄 말보로 골드도 동일하게 볼 수 있을까요?
--
--아래 지속 구매자 데이터 및 2022 VS. 2023 SWITCHING자료 동일 포맷으로 작업해주시면 됩니다.
--88011745	MARLBORO GOLD ORIGINAL	말보로 골드 오리지널
--88011721	MARLBORO MEDIUM	말보로 미디엄
select PROD_ID, count(*)
from cx.product_master_temp 
group by PROD_ID
having count(*) > 1;

--26,581
SELECT 
    a.product_code,
	a.id,
	b.ProductFamilyCode , b.Productcode,
	sum(case when left(a.YYYYMM, 4) = '2022' then 1 else 0 end) as [Out],
	sum(case when left(a.YYYYMM, 4) = '2023' then 1 else 0 end) as [In]
--into cx.agg_MLB_CC_Switch
FROM cx.fct_K7_Monthly a
	join cx.product_master_temp b on a.Product_code = b.prod_id and b.CIGADEVICE ='CIGARETTES' and b.CIGATYPE != 'CSV' and 4 < len(a.id) 
where
	left(a.YYYYMM, 4) in ('2022', '2023')
	-- 말보로 골드, 말보로 미디엄
	and b.ProductFamilyCode = 'MLB' and b.Productcode in ('MLBGLD', 'MMEDFT')
	--2022, 2023년 모두 구매한 사람은 제외
    and a.id not in 
    (	
	    SELECT 
			x.id
		FROM cx.fct_K7_Monthly x
        	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
		where 1=1
		   	and left(x.YYYYMM, 4) in ('2022', '2023')
		    and y.ProductFamilyCode = 'MLB' and y.Productcode in ('MLBGLD', 'MMEDFT')
		GROUP BY 
		    y.cigatype, y.ProductFamilyCode, y.Productcode,  x.id
		HAVING 
		    -- 2023년, 2022년에 모두 구매함		
		    (SUM(CASE WHEN left(x.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) > 0
		    AND SUM(CASE WHEN left(x.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0)
	)
group by a.product_code, a.id, b.ProductFamilyCode , b.Productcode
having 
	-- In : 2022년도에는 구매하지 않고 2023년도에는 해당 제품을 구매하여 IN
	(sum(case when left(a.YYYYMM, 4) = '2023' then 1 else 0 end) > 0
	and sum(case when left(a.YYYYMM, 4) = '2022' then 1 else 0 end) = 0
	and exists 
		(
		-- 2022년에 다른 제품을 구매한 사람
		select 1
		from cx.fct_K7_Monthly x
			join cx.product_master_temp y on x.Product_code = y.prod_id and y.CIGADEVICE ='CIGARETTES' and y.CIGATYPE != 'CSV' and 4 < len(x.id)
		where a.id = x.id and left(x.YYYYMM, 4) = '2022'
		and x.product_code not in (a.product_code )
		)
	)
	OR
	-- Out : 2022년도에는 구매했지만 2023년도에는 해당 제품을 구매하지 않아 Out
	(sum(case when left(a.YYYYMM, 4) = '2022' then 1 else 0 end) > 0
	and sum(case when left(a.YYYYMM, 4) = '2023' then 1 else 0 end) = 0
	and exists 
		(
		-- 2023년에는 다른 제품을 구매한 사람
		select 1
		from cx.fct_K7_Monthly x
			join cx.product_master_temp y on x.Product_code = y.prod_id and y.CIGADEVICE ='CIGARETTES' and y.CIGATYPE != 'CSV' and 4 < len(x.id)
		where a.id = x.id and left(x.YYYYMM, 4) = '2023'
		and x.product_code not in (a.product_code )
		)
	);


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
	cx.agg_MLB_CC_Switch t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') and a.product_code not in( t.product_code)
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
WHERE t.product_code = '88011745'
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
from cx.agg_MLB_CC_Switch  t
	join cx.fct_K7_Monthly a on t.id = a.id and 4 < len(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') and a.product_code not in(t.product_code) 
	join cx.product_master_temp b on a.Product_code = b.prod_id and b.CIGADEVICE ='CIGARETTES' and b.CIGATYPE != 'CSV' 
WHERE t.product_code = '88011745'
group by grouping sets (( b.cigatype, b.Engname, b.New_Flavorseg, b.New_Tarsegmentat, b.THICKSEG), (b.cigatype), ())
;


--28,298
select product_code, count(case when [Out]>0 then 1 end ) out_cnt, count(case when [In]>0 then 1 end ) In_cnt, count(*)
FROM cx.agg_MLB_CC_Switch 
group by product_code 
 ;

select * from cx.product_master_temp ;
 
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



