-- PLT 제품별 구매량 집계
-- (2022 vs. 2023) Family name: 팔리아멘트 / Taste segment: Regular taste 제품

--Aqua5, Aqua3, One, Hybrid5, Hybrid 제품별로 CC Switching 탐색
-- Product Code
--PLTKSB  	PARLIAMENT AQUA 5,
--PLTMLD 	PARLIAMENT AQUA 3
--PLTONE 	PARLIAMENT ONE
--PLTHYB1 	PARLIAMENT HYBRID
--PLTHYB5 	PARLIAMENT HYBRID 5
select * from cx.product_master_temp
where ProductFamilyCode ='PLT'; and Productcode ='PLTKSB';



-- 11분 걸림
-- 2022, 2023년에 (2022 vs. 2023) Family name: 팔리아멘트 / Taste segment: Regular taste 제품 >> In/Out 모수
with temp as (
	SELECT 
		b.cigatype,
	    b.ProductFamilyCode,
	    b.Productcode,
		a.id,
	    SUM(CASE WHEN left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) AS [Out],
	    SUM(CASE WHEN left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) AS [In]
	FROM 
	    cx.fct_K7_Monthly a
	    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
	where 1=1
	   	and left(a.YYYYMM, 4) in ('2022', '2023')
	    AND b.ProductFamilyCode ='PLT' and b.Productcode ='PLTKSB'
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
	        --AND b.ProductFamilyCode != y.ProductFamilyCode
	        and b.Productcode != y.Productcode
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
	        --AND b.ProductFamilyCode != y.ProductFamilyCode
	    	and b.Productcode != y.Productcode
	        )
	    )
);

-- CC Switching 작업
select cigatype,
	New_FLAVORSEG,
	New_TARSEGMENTAT,
	sum(Out_Purchaser_cnt) as Out_Purchaser_cnt,
	sum(In_Purchaser_cnt) as In_Purchaser_cnt,
    SUM(Out_quantity) AS Out_Quantity,
    SUM(In_quantity) AS In_Quantity
from (
	select b.cigatype,
		b.New_FLAVORSEG,
		b.New_TARSEGMENTAT,
		case 
			when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then count(distinct t.id) 
		end as Out_Purchaser_cnt,
		case 
			when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then count(distinct t.id) 
		end as In_Purchaser_cnt, 
		case 
			when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then sum(a.buy_ct * a.pack_qty) 
		end as Out_quantity,
		case 
			when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then sum(a.buy_ct * a.pack_qty) 
		end as In_quantity
	from 
		cx.agg_PLT_CC_Switch t
			join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023')
			join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
	where 1=1
--	and b.ProductFamilyCode != t.ProductFamilyCode
	and b.Productcode != t.Productcode and t.Productcode = 'PLTHYB1'
	group by  b.cigatype,  b.New_FLAVORSEG, b.New_TARSEGMENTAT, left(a.YYYYMM, 4), t.[In], t.[Out]
) as a
group by cigatype, New_FLAVORSEG, New_TARSEGMENTAT
;

-- Total Count 출력
select	Productcode,
	sum(Out_Purchaser_cnt) as Out_Purchaser_cnt,
	sum(In_Purchaser_cnt) as In_Purchaser_cnt,
    SUM(a.Out_quantity) AS Out_Quantity,
    SUM(a.In_quantity) AS In_Quantity
from (
	select t.Productcode,
		case 
			when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then count(distinct t.id) 
		end as Out_Purchaser_cnt,
		case 
			when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then count(distinct t.id) 
		end as In_Purchaser_cnt, 
		case 
			when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then sum(a.buy_ct * a.pack_qty) 
		end as Out_quantity,
		case 
			when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then sum(a.buy_ct * a.pack_qty) 
		end as In_quantity
	from 
		cx.agg_PLT_CC_Switch t
			join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023')
			join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
	where 1=1 
--	and b.ProductFamilyCode != t.ProductFamilyCode 
	and b.Productcode != t.Productcode
	group by t.Productcode, left(a.YYYYMM, 4), t.[In], t.[Out]
) as a
group by Productcode
;


-- Total CC/HnB Count 출력
select	
	cigatype,
	ProductCode,
	sum(Out_Purchaser_cnt) as Out_Purchaser_cnt,
	sum(In_Purchaser_cnt) as In_Purchaser_cnt,
    SUM(Out_quantity) AS Out_Quantity,
    SUM(In_quantity) AS In_Quantity
from (
	select  b.cigatype,
		t.ProductCode,
		case 
			when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then count(distinct t.id) 
		end as Out_Purchaser_cnt,
		case 
			when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then count(distinct t.id) 
		end as In_Purchaser_cnt, 
		case 
			when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then sum(a.buy_ct * a.pack_qty) 
		end as Out_quantity,
		case 
			when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then sum(a.buy_ct * a.pack_qty) 
		end as In_quantity
	from 
		cx.agg_PLT_CC_Switch t
			join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023')
			join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
	where 1=1
	and b.ProductFamilyCode != t.ProductFamilyCode
	and b.Productcode != t.Productcode 
	group by b.cigatype, t.ProductCode, left(a.YYYYMM, 4), t.[In], t.[Out]
) as a
group by cigatype, ProductCode
;

