-- 2024.07.26 작업
--CC Switching 2023 vs. 2022 KS Regular
--CC Switching 2023 vs. 2022 KS NTD
--CC Switching 2023 vs. 2022 KS Regular to NTD
--CC Switching 2023 vs. 2022 KS Fresh to NTD

-- 전체 CC KS 대상 탐색
select 'KS',CIGATYPE , ProductFamilyCode ,FLAVORSEG_type6, count(*) "KS SEG"
FROM cx.product_master
where THICKSEG = 'STD'
--and ProductFamilyCode in ('ESSE', 'DUNHILL', 'MEVIUS', 'MLB' , 'RAISON')  -- Top5 대상
group by CIGATYPE , ProductFamilyCode, FLAVORSEG_type6;

-- 전체 대상 조회
select 
	ProductFamilyCode,   
	case when THICKSEG = 'SLI' then 'SSL'
    	when THICKSEG = 'MSL' then 'SSL'
    	else THICKSEG
	end  THICKSEG, b.FLAVORSEG_type6,
	left(a.yyyymm,4) year,
	COUNT(distinct id ) Purchaser_Cnt,
	sum(a.buy_ct * a.pack_qty) as Total_Pack_Cnt
FROM 
	cx.fct_K7_Monthly a
    	join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
    	AND b.THICKSEG IN ('SSL', 'SLI', 'MSL')
    	and ProductFamilyCode in ('ESSE', 'DUNHILL', 'MEVIUS', 'MLB' , 'RAISON')  and b.FLAVORSEG_type6 in ('Regular', 'Fresh to New Taste', 'New Taste', 'Regular to New Taste') 
where 1=1
   	and left(a.YYYYMM, 4) in ('2022', '2023')
GROUP BY 
	ProductFamilyCode,   
	case when THICKSEG = 'SLI' then 'SSL'
    	 when THICKSEG = 'MSL' then 'SSL'
    	 else THICKSEG
	end , b.FLAVORSEG_type6, left(a.YYYYMM, 4)
order by ProductFamilyCode,FLAVORSEG_type6, year 
;

-- ('ESSE', 'DUNHILL', 'MEVIUS', 'MLB' , 'RAISON') Top 5 대상
-- SSL Regular 				ESSE 10220, DUNHILL 8492,  MEVIUS 9030
-- SSL New taste 			ESSE 3698 
-- SSL Regular to New Taste	ESSE 64297, DUNHILL 6222,  MEVIUS 4743
-- SSL Fresh to New Taste 	ESSE 45400, DUNHILL 4374, MEVIUS 1650, MLB 17228

with temp as ( 
	SELECT 
		a.id,
		b.ProductFamilyCode,
		b.THICKSEG , 
		b.FLAVORSEG_type6,
		sum(case when left(a.YYYYMM, 4) = '2022' then a.buy_ct * a.pack_qty else 0 end) as [Out],
		sum(case when left(a.YYYYMM, 4) = '2023' then a.buy_ct * a.pack_qty else 0 end) as [In]
	FROM 
	    cx.fct_K7_Monthly a
	     	join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id) 
	    	and b.THICKSEG  in ('SSL', 'SLI', 'MSL') and b.FLAVORSEG_type6 = 'Fresh to New Taste' 
	    	and b.ProductFamilyCode = 'MLB'
	where 1=1
	   	and left(a.YYYYMM, 4) in ('2022', '2023')
	    --2022, 2023년 모두 구매한 사람은 제외
	    and a.id not in (
			SELECT 
				x.id
			FROM cx.fct_K7_Monthly x
				join cx.product_master y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype = 'CC' AND 4 < LEN(x.id) 
					and y.THICKSEG in ('SSL', 'SLI', 'MSL') and y.FLAVORSEG_type6 = b.FLAVORSEG_type6 and y.ProductFamilyCode = b.ProductFamilyCode
			where 1=1
			   	and left(x.YYYYMM, 4) in ('2022', '2023')
			GROUP BY 
				y.ProductFamilyCode,
			    y.THICKSEG, 
				y.FLAVORSEG_type6, x.id
			HAVING 
			    -- 2023년, 2022년에 모두 구매함	
			    (SUM(CASE WHEN left(x.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) > 0
			    AND SUM(CASE WHEN left(x.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0)
		)
	GROUP BY 
	       a.id, b.ProductFamilyCode,   b.THICKSEG,     b.FLAVORSEG_type6
)
--insert into cx.agg_CC_KS_SSL_Switch_2022_2023
select 
	id,
	THICKSEG,
	FLAVORSEG_type6,
	[Out],
	[In],
	ProductFamilyCode
from temp a
where     -- Out : 2022년도에는 구매했지만 2023년도에는 해당 제품을 구매하지 않아 Out
	( [out] > 0
	and [In] = 0
    AND EXISTS (
		-- 2023년에는 다른 제품을 구매한 사람
	    SELECT 1
	    FROM cx.fct_K7_Monthly x
	    	join cx.product_master y on x.product_code = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' AND y.cigatype != 'CSV' AND 4 < LEN(x.id)
	    where a.id = x.id and left(x.YYYYMM, 4) = '2023'
	    and y.ProductFamilyCode != a.ProductFamilyCode 	
		and (y.THICKSEG not in ('SSL', 'SLI', 'MSL') or y.FLAVORSEG_type6 != a.FLAVORSEG_type6 or y.THICKSEG is null) 
    	)
	)
	OR
    -- In : 2022년도에는 구매하지 않고 2023년도에는 해당 제품을 구매하여 IN
    ( [In] > 0
    AND [out] = 0 
    AND EXISTS (
    	-- 2022년에 다른 제품을 구매한 사람
	    SELECT 1
	    FROM cx.fct_K7_Monthly x
	    	join cx.product_master y on x.product_code = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' AND y.cigatype != 'CSV' AND 4 < LEN(x.id)
	    where a.id = x.id and left(x.YYYYMM, 4) = '2022'
	    and y.ProductFamilyCode != a.ProductFamilyCode
	    and (y.THICKSEG not in ('SSL', 'SLI', 'MSL') or y.FLAVORSEG_type6 != a.FLAVORSEG_type6 or y.THICKSEG is null) 	
    	)
    )
;


-- cigatype, Taste, Tar CC Switching 작업
select  
	b.cigatype,	
	b.FLAVORSEG_type6,
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
	cx.agg_CC_KS_SSL_Switch_2022_2023 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') 
		join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV'
			and b.ProductFamilyCode != t.ProductFamilyCode
			and (b.THICKSEG not in ('SSL', 'SLI', 'MSL')  or b.FLAVORSEG_type6 != t.FLAVORSEG_type6 or b.THICKSEG is null) 		
WHERE t.THICKSEG in ('SSL', 'SLI', 'MSL') and t.FLAVORSEG_type6 = 'Fresh to New Taste' and  t.ProductFamilyCode = 'MLB' 
group by grouping sets ((b.cigatype, b.FLAVORSEG_type6, b.New_TARSEGMENTAT),  (b.cigatype, b.FLAVORSEG_type6),  (b.cigatype), ())
;



-- SKU 별 Switching In/Out
select
	b.cigatype,
	b.Engname,
	b.FLAVORSEG_type6,
	b.New_Tarsegmentat,
	b.THICKSEG,
	count(DISTINCT case when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(DISTINCT case when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	'',
	'',
	'',
	sum(case when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then a.buy_ct * a.Pack_qty else 0 end ) as Out_Quantity,
	sum(case when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then a.buy_ct * a.Pack_qty else 0 end ) as In_Quantity
from cx.agg_CC_KS_SSL_Switch_2022_2023  t
	join cx.fct_K7_Monthly a on t.id = a.id and 4 < len(a.id) and left(a.YYYYMM, 4) in ('2022', '2023')   
	join cx.product_master b on a.Product_code = b.prod_id and b.CIGADEVICE ='CIGARETTES' and b.CIGATYPE != 'CSV' 
		and b.ProductFamilyCode != t.ProductFamilyCode
		and (b.THICKSEG not in ('SSL', 'SLI', 'MSL')  or b.FLAVORSEG_type6 != t.FLAVORSEG_type6 or b.THICKSEG is null) 	
WHERE  t.THICKSEG in ('SSL', 'SLI', 'MSL') and t.FLAVORSEG_type6 = 'Regular' and  t.ProductFamilyCode = 'ESSE' 
group by grouping sets ((b.cigatype, b.Engname, b.FLAVORSEG_type6, b.New_Tarsegmentat, b.THICKSEG), (b.cigatype ), ())
order by Out_Purchaser_Cnt  desc 
;

-- 구매자, 구매팩수 총 카운트
select 
	ProductFamilyCode, b.THICKSEG, b.FLAVORSEG_type6,
	left(a.yyyymm,4) year,
	COUNT(distinct id ) Purchaser_Cnt,
	sum(a.buy_ct * a.pack_qty) as Total_Pack_Cnt
FROM 
	cx.fct_K7_Monthly a
    	join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
    	AND b.THICKSEG = 'STD' and ProductFamilyCode in ('ESSE', 'DUNHILL', 'MEVIUS', 'MLB' , 'RAISON')  --and b.FLAVORSEG_type6 = 'Fresh to New Taste' 
where 1=1
   	and left(a.YYYYMM, 4) in ('2022', '2023')
GROUP BY 
	ProductFamilyCode, b.THICKSEG, b.FLAVORSEG_type6, left(a.YYYYMM, 4)
;

    
-- In/Out별 구매자수, 총 구매 팩수 
select  
	t.ProductFamilyCode, t.THICKSEG, t.FLAVORSEG_type6,
	left(a.yyyymm,4) year,
	count(DISTINCT case when t.[Out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(DISTINCT case when t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	sum(case when t.[Out] > 0 then a.buy_ct * a.pack_qty end ) as Out_Quantity,
	sum(case when t.[In] > 0 then a.buy_ct * a.pack_qty end ) as In_Quantity
from 
	cx.agg_CC_KS_SSL_Switch_2022_2023 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') 
		join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV'
			and b.ProductFamilyCode = t.ProductFamilyCode
			and b.THICKSEG = t.THICKSEG and b.FLAVORSEG_type6 = t.FLAVORSEG_type6  	
where t.THICKSEG ='STD' and t.FLAVORSEG_type6 = 'Fresh to New Taste' --and t.ProductFamilyCode ='DUNHILL' 
group by
     t.ProductFamilyCode, t.THICKSEG, t.FLAVORSEG_type6, left(a.YYYYMM, 4)
;

-- 구매자, 구매팩수 총 카운트
select 
	b.ProductFamilyCode	,
    case when b.THICKSEG = 'SLI' then 'SSL'
		when b.THICKSEG = 'MSL' then 'SSL'
		else b.THICKSEG
	end THICKSEG, 
	b.FLAVORSEG_type6,
	left(a.yyyymm,4) year,
	COUNT(distinct id ) Purchaser_Cnt,
	sum(a.buy_ct * a.pack_qty) as Total_Pack_Cnt
FROM 
	cx.fct_K7_Monthly a
    	join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
	    	and b.ProductFamilyCode = t.ProductFamilyCode
	    	AND b.THICKSEG in ('SSL', 'SLI', 'MSL') and ProductFamilyCode in ('ESSE', 'DUNHILL', 'MEVIUS', 'MLB' , 'RAISON')  --and b.FLAVORSEG_type6 = 'Fresh to New Taste'
where 1=1
   	and left(a.YYYYMM, 4) in ('2022', '2023')
GROUP BY 
	b.ProductFamilyCode	,
    case when b.THICKSEG = 'SLI' then 'SSL'
		when b.THICKSEG = 'MSL' then 'SSL'
		else b.THICKSEG
	end, b.FLAVORSEG_type6, left(a.YYYYMM, 4)
;

    
-- In/Out별 구매자수, 총 구매 팩수 
select 
	t.ProductFamilyCode	,
	 case when t.THICKSEG = 'SLI' then 'SSL'
		when t.THICKSEG = 'MSL' then 'SSL'
		else t.THICKSEG
	end THICKSEG, 
	t.FLAVORSEG_type6,
	left(a.yyyymm,4) year,
	count(DISTINCT case when t.[Out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(DISTINCT case when t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	sum(case when t.[Out] > 0 then a.buy_ct * a.pack_qty end ) as Out_Quantity,
	sum(case when t.[In] > 0 then a.buy_ct * a.pack_qty end ) as In_Quantity
from 
	cx.agg_CC_KS_SSL_Switch_2022_2023 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') 
		join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV'
			and b.ProductFamilyCode = t.ProductFamilyCode
			and b.THICKSEG = t.THICKSEG  and t.FLAVORSEG_type6 = b.FLAVORSEG_type6 
where t.THICKSEG in ('SSL', 'MSL' ,'SLI') and t.FLAVORSEG_type6 = 'Fresh to New Taste'	--and t.ProductFamilyCode ='DUNHILL' 
group by
	t.ProductFamilyCode	,
    case when t.THICKSEG = 'SLI' then 'SSL'
		when t.THICKSEG = 'MSL' then 'SSL'
		else t.THICKSEG
	end, t.FLAVORSEG_type6, left(a.YYYYMM, 4)
;