-- id로 어떤 구매 데이터가 있는지 확인 ( 구매수량, 구매 카운트,)
select*
from 
	cx.agg_MLB_CC_Switch t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023')  and a.product_code not in( t.product_code)
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
WHERE t.product_code = '88011745'
and t.id ='053ADE079C0E63AA11D9AE2C617EC6DA908EBC4D9025D9EF5A7166C2DFA821E9'
;


SELECT 
    a.product_code,
	a.id,
	b.ProductFamilyCode , b.New_TARSEGMENTAT,
    SUM(CASE WHEN left(a.YYYYMM, 4) = '2022' THEN 1 ELSE 0 END) AS [Out],
    SUM(CASE WHEN left(a.YYYYMM, 4) = '2023' THEN 1 ELSE 0 END) AS [In]
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
    AND not EXISTS (
		-- 2023년에는 다른 제품을 구매한 사람
	    SELECT 1
	    FROM cx.fct_K7_Monthly x
	    	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
	    where a.id = x.id and left(x.YYYYMM, 4) = '2023'
		and x.product_code != a.product_code 
    	)
	);
	


	
select t.product_code, 
	count(case when [Out]> 0 then 1 end), 
	count(case when [In] > 0 then 1 end),
	sum(t.[out]),
	sum(t.[In])
from 
	cx.agg_MLB_CC_Switch t
WHERE t.product_code = '88011745'
group by t.product_code 
;

--1521590 rows 담배데이터 등록안된 건
select count(*) from cx.fct_K7_Monthly 
where product_code ='88011639';
--Pack_qty is null;

-- DUNHILL KS 중에서  88011639	DUNHILL DOLCE KS OCT 20	던힐 돌체 제외...?
select * 
from cx.product_master_temp
where ProductSubFamilyCode = 'DUNHILLKS' and New_FLAVORSEG='Regular' and TARINFO in ('1', '3', '6') and prod_id != '88011639';

select * 
from cx.product_master_temp
where ProductFamilyCode = 'DUNHILL' and New_FLAVORSEG='Regular' and thickseg ='SSL'  and TARINFO in ('1', '3', '0.1') ;

-- 데이터 검증
-- Out 5377
select distinct a.ID
from cx.fct_K7_Monthly a
	join cx.agg_DUNHILL_SSL_Switch_2022_2023 b on a.product_code = b.product_code  and a.id = b.id and b.[Out] > 0
where left(a.YYYYMM, 4) = '2022';

-- In 5023
select distinct a.ID  
from cx.fct_K7_Monthly a
	join cx.agg_DUNHILL_SSL_Switch_2022_2023 b on a.product_code = b.product_code  and a.id = b.id and b.[In] > 0
where left(a.YYYYMM, 4) = '2023';

select id, count(*)
from cx.agg_DUNHILL_SSL_Switch_2022_2023
group by id
having count(*)>1;

select * from cx.agg_DUNHILL_SSL_Switch_2022_2023 
where id ='0001C49BD0D710003D72A45445C486342FDAB6E19711D9AD1AEDE159BAEEF5D2';


