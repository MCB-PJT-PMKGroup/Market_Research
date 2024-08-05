--CC Switching 2023 vs. 2022 SSL Regular
--CC Switching 2023 vs. 2022 SSL NTD
--CC Switching 2023 vs. 2022 SSL Regular to NTD
--CC Switching 2023 vs. 2022 SSL Fresh to NTD


-- SSL 대상
select 'SSL', CIGATYPE , ProductFamilyCode,FLAVORSEG_type6, count(*) "SSL SEG"
FROM cx.product_master_temp
where THICKSEG in ('SSL', 'SLI', 'MSL') 
--and ProductFamilyCode in ('ESSE', 'DUNHILL', 'MEVIUS', 'MLB' , 'RAISON');
group by CIGATYPE, ProductFamilyCode, FLAVORSEG_type6;


-- 구매자수 맞추기
select  case when THICKSEG = 'SLI' then 'SSL'
		    	when THICKSEG = 'MSL' then 'SSL'
		    	else THICKSEG
			end , FLAVORSEG_type6 , count(distinct id) purchaser, count(*) cnt
FROM cx.agg_CC_SSL_Switch_2022_2023
group by  case when THICKSEG = 'SLI' then 'SSL'
		    	when THICKSEG = 'MSL' then 'SSL'
		    	else THICKSEG
			end , FLAVORSEG_type6 ;

delete from cx.agg_CC_SSL_Switch_2022_2023 
where productFamilyCode ='All' and Thickseg='MSL' and FLAVORSEG_type6='New Taste';

		
--insert into cx.agg_CC_KS_SSL_Switch_2022_2023
--SELECT  
--    a.product_code, b.ProductFamilyCode, 
--	a.id,
--	b.THICKSEG , 
--	b.FLAVORSEG_type6,
--	sum(case when left(a.YYYYMM, 4) = '2022' then a.buy_ct * a.pack_qty else 0 end) as [Out],
--	sum(case when left(a.YYYYMM, 4) = '2023' then a.buy_ct * a.pack_qty else 0 end) as [In]
--FROM 
--    cx.fct_K7_Monthly a
--     	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id) 
--    	and b.THICKSEG in ('SSL', 'SLI', 'MSL') and b.FLAVORSEG_type6 = 'Regular'
--where 1=1
--   	and left(a.YYYYMM, 4) in ('2022', '2023')
--    2022, 2023년 모두 구매한 사람은 제외
--    and a.id not in (
--		SELECT 
--			x.id
--		FROM cx.fct_K7_Monthly x
--			join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype = 'CC' AND 4 < LEN(x.id) 
--			and y.THICKSEG in ('SSL', 'SLI', 'MSL') and y.FLAVORSEG_type6 = 'Regular'
--		where 1=1
--		   	and left(x.YYYYMM, 4) in ('2022', '2023')
--		GROUP BY          
--		    case when y.THICKSEG = 'SLI' then 'SSL'
--		    	when y.THICKSEG = 'MSL' then 'SSL'
--		    	else y.THICKSEG
--			end, 
--			y.FLAVORSEG_type6, x.id
--		HAVING 
--		     2023년, 2022년에 모두 구매함	
--		    (SUM(CASE WHEN left(x.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) > 0
--		    AND SUM(CASE WHEN left(x.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0)
--	)
--GROUP BY 
--    a.product_code, b.ProductFamilyCode, 
--    a.id,
--    b.THICKSEG, 
--    b.FLAVORSEG_type6
--HAVING
--     Out : 2022년도에는 구매했지만 2023년도에는 해당 제품을 구매하지 않아 Out
--	(SUM(CASE WHEN  left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0
--	and SUM(CASE WHEN  left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) = 0
--    AND EXISTS (
--		 2023년에는 다른 제품을 구매한 사람
--	    SELECT 1
--	    FROM cx.fct_K7_Monthly x
--	    	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
--	    where a.id = x.id and left(x.YYYYMM, 4) = '2023'
--		and x.product_code != a.product_code 
--    	)
--	)
--	OR
--     In : 2022년도에는 구매하지 않고 2023년도에는 해당 제품을 구매하여 IN
--    (SUM(CASE WHEN left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) > 0
--    AND SUM(CASE WHEN left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) = 0 
--    AND EXISTS (
--    	 2022년에 다른 제품을 구매한 사람
--	    SELECT 1
--	    FROM cx.fct_K7_Monthly x
--	    	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
--	    where a.id = x.id and left(x.YYYYMM, 4) = '2022'
--	    and x.product_code != a.product_code 
--    	)
--    )
--;
		
-- 조건에 New_FLAVORSEG 사용 
-- SSL Regular 				56,948 rows
-- SSL New taste 			93,762

-- 조건에 FLAVORSEG_type6 사용
-- SSL Regular to New Taste	84,519
-- SSL Fresh to New Taste 	67,252
with temp as ( 
	SELECT 
		a.id,
		case when THICKSEG = 'SLI' then 'SSL'
    	when THICKSEG = 'MSL' then 'SSL'
    	else THICKSEG
		end THICKSEG, 
		b.New_FLAVORSEG,
		sum(case when left(a.YYYYMM, 4) = '2022' then a.pack_qty else 0 end) as [Out],
		sum(case when left(a.YYYYMM, 4) = '2023' then a.pack_qty else 0 end) as [In]
	FROM 
	    cx.fct_K7_Monthly a
	     	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id) 
	    		and b.THICKSEG in ('SSL', 'SLI', 'MSL') and b.New_FLAVORSEG = 'New taste'
	where 1=1
	   	and left(a.YYYYMM, 4) in ('2022', '2023')
	    --2022, 2023년 모두 구매한 사람은 제외
	    and a.id not in (
			SELECT 
				x.id
			FROM cx.fct_K7_Monthly x
				join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype = 'CC' AND 4 < LEN(x.id) 
				and y.THICKSEG in ('SSL', 'SLI', 'MSL') and y.New_FLAVORSEG = b.New_FLAVORSEG
			where 1=1
			   	and left(x.YYYYMM, 4) in ('2022', '2023')
			GROUP BY   
				x.id,
			    case when y.THICKSEG = 'SLI' then 'SSL'
			    	when y.THICKSEG = 'MSL' then 'SSL'
			    	else y.THICKSEG
				end, 
				y.New_FLAVORSEG
			HAVING 
			    -- 2023년, 2022년에 모두 구매함	
			    (SUM(CASE WHEN left(x.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) > 0
			    AND SUM(CASE WHEN left(x.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) > 0)
		)
	GROUP BY 
	       a.id,  	
	       case when THICKSEG = 'SLI' then 'SSL'
	    	when THICKSEG = 'MSL' then 'SSL'
	    	else THICKSEG
			end,     
			b.New_FLAVORSEG
)
--insert into cx.agg_CC_KS_SSL_Switch_2022_2023
select 
		id,
		THICKSEG , 
		New_FLAVORSEG,
		[Out],
		[In],
		'All' ProductFamilyCode
from temp a
where     -- Out : 2022년도에는 구매했지만 2023년도에는 해당 제품을 구매하지 않아 Out
	( [out] > 0
	and [In] = 0
    AND EXISTS (
		-- 2023년에는 다른 제품을 구매한 사람
	    SELECT 1
	    FROM cx.fct_K7_Monthly x
	    	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' AND y.cigatype != 'CSV' AND 4 < LEN(x.id)
	    where a.id = x.id and left(x.YYYYMM, 4) = '2023'
		--and x.product_code not in ( a.product_code)
	    and (y.THICKSEG not in ('SSL', 'SLI', 'MSL') or y.New_FLAVORSEG != a.New_FLAVORSEG or y.THICKSEG is null) 	
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
	    	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' AND y.cigatype != 'CSV' AND 4 < LEN(x.id)
	    where a.id = x.id and left(x.YYYYMM, 4) = '2022'
	    --and x.product_code not in( a.product_code)
	    and (y.THICKSEG not in ('SSL', 'SLI', 'MSL') or y.New_FLAVORSEG != a.New_FLAVORSEG or y.THICKSEG is null) 	
    	)
    )
;

-- 데이터 검증
select ProductFamilyCode ,THICKSEG ,FLAVORSEG_type6 , count(distinct id), sum([out]), sum([In])
from cx.agg_CC_SSL_Switch_2022_2023 
where ProductFamilyCode='All'
group by ProductFamilyCode, THICKSEG ,FLAVORSEG_type6
;

delete from cx.agg_CC_SSL_Switch_2022_2023  
where ProductFamilyCode = 'All' and FLAVORSEG_type6 = 'New Taste';

SELECT     
	case when THICKSEG = 'SLI' then 'SSL'
		    	when THICKSEG = 'MSL' then 'SSL'
		    	else THICKSEG
			end , 
	FLAVORSEG_type6 ,
	count(distinct id),
	count(*)
from cx.agg_CC_SSL_Switch_2022_2023 acss 
group by    
	case when THICKSEG = 'SLI' then 'SSL'
    	when THICKSEG = 'MSL' then 'SSL'
    	else THICKSEG
	end , FLAVORSEG_type6 
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
		when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then a.pack_qty else 0
	end )as Out_quantity,
	sum(case 
		when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then a.pack_qty else 0
	end) as In_quantity
from 
	cx.agg_CC_SSL_Switch_2022_2023 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') 
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
			and (b.THICKSEG not in ('SSL', 'SLI', 'MSL') or t.FLAVORSEG_type6 != b.FLAVORSEG_type6 or b.THICKSEG is null) 		-- 다른 제품만 추출
WHERE t.THICKSEG in ('SSL', 'SLI', 'MSL') and t.FLAVORSEG_type6 = 'Regular' and t.ProductFamilyCode = 'All'
group by grouping sets ((b.cigatype, b.FLAVORSEG_type6, b.New_TARSEGMENTAT), (b.cigatype, b.FLAVORSEG_type6), (b.cigatype), ())
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
	sum(case when left(a.YYYYMM, 4) = '2023' and t.[Out] > 0 then a.Pack_qty else 0 end ) as Out_Quantity,
	sum(case when left(a.YYYYMM, 4) = '2022' and t.[In] > 0 then a.Pack_qty else 0 end ) as In_Quantity
from cx.agg_CC_SSL_Switch_2022_2023  t
	join cx.fct_K7_Monthly a on t.id = a.id and 4 < len(a.id) and left(a.YYYYMM, 4) in ('2022', '2023')
	join cx.product_master_temp b on a.Product_code = b.prod_id and b.CIGADEVICE ='CIGARETTES' and b.CIGATYPE != 'CSV'  
		and (b.THICKSEG not in ('SSL', 'SLI', 'MSL') or t.FLAVORSEG_type6 != b.FLAVORSEG_type6 or b.THICKSEG is null) 		-- 다른 제품만 추출
WHERE t.THICKSEG in ('SSL', 'SLI', 'MSL') and t.FLAVORSEG_type6 = 'Regular' and t.ProductFamilyCode = 'All'
group by grouping sets (
	(b.cigatype, b.Engname, b.FLAVORSEG_type6, b.New_Tarsegmentat, b.THICKSEG ), 
	(b.cigatype), 
	()
	)
;


-- 구매자, 구매팩수 총 카운트
select 
    case when b.THICKSEG = 'SLI' then 'SSL'
		when b.THICKSEG = 'MSL' then 'SSL'
		else b.THICKSEG
	end THICKSEG, 
	b.FLAVORSEG_type6,
	left(a.yyyymm,4) year,
	COUNT(distinct id ) Purchaser_Cnt,
	sum(  a.pack_qty) as Total_Pack_Cnt
FROM 
	cx.fct_K7_Monthly a
    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
    	AND b.THICKSEG in ('SSL', 'SLI','MSL') --and b.FLAVORSEG_type6 = 'Fresh to New Taste'
where 1=1
   	and left(a.YYYYMM, 4) in ('2022', '2023')
GROUP BY 
    case when b.THICKSEG = 'SLI' then 'SSL'
		when b.THICKSEG = 'MSL' then 'SSL'
		else b.THICKSEG
	end, b.FLAVORSEG_type6, left(a.YYYYMM, 4)
;

    
-- In/Out별 구매자수, 총 구매 팩수 
select  
	 case when t.THICKSEG = 'SLI' then 'SSL'
		when t.THICKSEG = 'MSL' then 'SSL'
		else t.THICKSEG
	end THICKSEG, 
	t.FLAVORSEG_type6,
	left(a.yyyymm,4) year,
	count(DISTINCT case when t.[Out] > 0 then t.id end ) as Out_Purchaser_Cnt,
	count(DISTINCT case when t.[In] > 0 then t.id end ) as In_Purchaser_Cnt,
	sum(case when t.[Out] > 0 then a.pack_qty end ) as Out_Quantity,
	sum(case when t.[In] > 0 then a.pack_qty end ) as In_Quantity
from 
	cx.agg_CC_SSL_Switch_2022_2023 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') 
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV'
			and b.THICKSEG in ('SSL', 'MSL' ,'SLI')  and t.FLAVORSEG_type6 = b.FLAVORSEG_type6 
where  t.ProductFamilyCode = 'All' --and  t.THICKSEG in ('SSL', 'MSL' ,'SLI') and t.FLAVORSEG_type6 = 'New Taste' 
group by
    case when t.THICKSEG = 'SLI' then 'SSL'
		when t.THICKSEG = 'MSL' then 'SSL'
		else t.THICKSEG
	end, t.FLAVORSEG_type6, left(a.YYYYMM, 4)
;