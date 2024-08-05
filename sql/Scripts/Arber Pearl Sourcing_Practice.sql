-- 2024.07.30 작업 시작
-- 88023540	TEREA ARBOR PEARL	테리아 아버 펄	IQOS	CIGARETTES	HnB	FS4: Regular to New Taste
-- Launch Date : 202403

-- 직전 1개월, 3개월 계산
select YYYYMM, 
	cast(yyyymm - 3 AS varchar)  TT, 	-- 이렇게 하면 안됨! '202403' - 4 = 202312 가 아니고 202399가 나옴.. string에서 빼기한 값이라
	CAST(YYYYMM+'01' AS DATE) yyyymm2,  
	CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, YYYYMM+'01'), 112) con_date,
	CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, YYYYMM+'01'), 112) con_date2,
	YYYYMM - 4 -- 숫자형으로 변환.
from cx.fct_K7_Monthly 
where YYYYMM='202403';

select * from cx.product_master_temp 
where ProductSubFamilyCode='TEREA';

-- Arber Pearl Sourcing 기본 가공 - Base
-- 2024년 3월 SKU 11개 이하, qty_sum < 61.0  && 직전 3개월 구매이력 있는 사람들
with temp as (
	select 
		 'TEREA' SKU, 
		 YYYYMM, 
		 id,  
		 gender, 
		 max(age) age
	FROM
		 cx.fct_K7_Monthly a
		    join cx.product_master_temp b on a.product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  cigatype != 'CSV' AND 4 < LEN(a.id)
	where 1=1
	and  exists (
		-- 직전 3개월 동안 구매이력이 최소 1건 있는 구매자만 대상
		select 1 
		from cx.fct_K7_Monthly x
	    	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
		where x.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, a.YYYYMM+'01'), 112)
						   AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, a.YYYYMM+'01'), 112) 
		and a.id = x.id
		group by x.id, x.YYYYMM
		-- 각 월에 SKU 11종 미만, 팩수 61개 미만
		having (count(distinct y.engname) < 11 and sum( Pack_qty) < 61.0 )
	)
	and a.YYYYMM >= '202211'		-- 타겟 date 
	group by id, gender, YYYYMM
	having (count(distinct engname) < 11 and sum(Pack_qty) < 61.0 )
)
--insert into cx.agg_TEREA_Sourcing
select distinct
	b.ProductSubFamilyCode,
	a.YYYYMM,
	a.id, 
	a.gender, 
	a.age
--into cx.agg_TEREA_Sourcing
from temp a
	join cx.product_master_temp b on CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)  and a.SKU = b.ProductSubFamilyCode 
-- 저번 달 구매자는 제외
where not exists (SELECT 1 FROM cx.fct_K7_Monthly WHERE id = a.id and YYYYMM <= CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, a.YYYYMM+'01'), 112) and product_code =  b.prod_id )
and id in ( 
	select id 
	FROM
		 cx.fct_K7_Monthly x
		    join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id) 
    and x.YYYYMM = a.YYYYMM
    and y.engname = b.ENGNAME 
	)
;

-- Data Validation 데이터 검증 작업!!!!!!!!!!!!!
-- 중복 체크
select YYYYMM , id, count(*) 
from cx.agg_TEREA_Sourcing
group by YYYYMM, id 
having count(*) > 1
;

-- 회사별 제품 구매 내역 
select * from cx.agg_TEREA_Sourcing 
where id ='00851229FF4A0026F2682594CEDABB0AE1B73FF85E6CDED060ED4FB00B37ECC9';

-- 해당 월에 제품을 구매한 이력
select YYYYMM, id, count(*) purchase_cnt
FROM cx.fct_K7_Monthly a
    join cx.product_master_temp b on a.product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  cigatype != 'CSV' AND 4 < LEN(a.id) 
    	and b.ProductSubFamilyCode ='TEREA'	-- Target SKU
		and YYYYMM = '202211'				-- Target Date
where not exists (SELECT 1 FROM cx.fct_K7_Monthly WHERE id = a.id and YYYYMM <= CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, a.YYYYMM+'01'), 112) and product_code = b.PROD_ID )
and exists (
		-- 직전 3개월 동안 구매이력이 최소 1건 있는 구매자만 대상
		select 1 
		from cx.fct_K7_Monthly x
		where x.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, a.YYYYMM+'01'), 112)
						   AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, a.YYYYMM+'01'), 112) 
		and a.id = x.id
	)
and id not in (
		-- 각 월에 SKU 11종 이상, 팩수 61개 이상 제외 
		select id
		from cx.fct_K7_Monthly x
		where x.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, a.YYYYMM+'01'), 112)
					   AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, a.YYYYMM+'01'), 112) 
		group by id, YYYYMM
		having (count(distinct product_code) >= 11 or sum( Pack_qty) >= 61.0 )
)
and id ='00851229FF4A0026F2682594CEDABB0AE1B73FF85E6CDED060ED4FB00B37ECC9'
group by YYYYMM, id
-- 각 월에 SKU 11종 미만, 팩수 61개 미만
having (count(distinct product_code) < 11 and sum( Pack_qty) < 61.0 );


--직전 3개월 다른 제품 구매이력 여부 및 SKU, pack 수 체크
select YYYYMM, count(distinct product_code) sku, sum(Pack_qty) sum 
from cx.fct_K7_Monthly 
where id ='00851229FF4A0026F2682594CEDABB0AE1B73FF85E6CDED060ED4FB00B37ECC9'
		and YYYYMM BETWEEN '202208' and '202210'
group by YYYYMM;

--직전 3개월 구매 상세 이력 
select engname, productdescription, prod_id, de_dt, id, gender, age, YYYYMM, pack_qty
from cx.fct_K7_Monthly x
	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
where x.YYYYMM BETWEEN '202208' and '202211'
and x.id = '01E685679696C9867F8FF57E04863525BC7B8933FBC303B252898F72C83C2A40'
order by de_dt; 

-- 데이터 검증 끝



-- Arbor_sourcing_M1 모수 테이블

with temp as (
   select
       a.YYYYMM,
       a.id,
       a.gender,
       max(a.age) as age
   from
       cx.fct_K7_Monthly a
       join cx.product_master_temp b on a.product_code = b.PROD_ID
           and b.CIGADEVICE = 'CIGARETTES'
           and b.cigatype != 'CSV'
           and len(a.id) > 4 
   where
       exists (
           -- (1) 직전 3개월 동안 구매이력이 있는지 확인
           select 1
           from cx.fct_K7_Monthly x
           where
               x.YYYYMM between convert(nvarchar(6), dateadd(month, -3, a.YYYYMM + '01'), 112)
               				and convert(nvarchar(6), dateadd(month, -1, a.YYYYMM + '01'), 112)
               and a.id = x.id  
           group by x.id, x.YYYYMM 
           having count(distinct x.product_code) < 11 and sum( Pack_qty) < 61.0  and sum(Pack_qty) > 0
       )
       and a.YYYYMM >= '202211' -- (2) Since 2022.11
   group by
       a.id, a.gender, a.YYYYMM
   having
       count(distinct a.product_code) < 11 -- (3) SKU 11종 미만
       and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만
),
TEREA_Purchasers as (
	select distinct
	   b.ProductSubFamilyCode,
	   a.YYYYMM,
	   a.id,
	   a.gender,
	   a.age
	from
	   temp a
	   join cx.fct_K7_Monthly c on a.id = c.id and a.YYYYMM = c.YYYYMM
	   join cx.product_master_temp b on c.product_code = b.PROD_ID
	       and b.CIGADEVICE = 'CIGARETTES'
	       and b.cigatype != 'CSV'
	       and len(a.id) > 4
	       and b.ProductSubFamilyCode = 'TEREA'
	where
	   not exists (
	       -- (4) 해당 월 이전에 같은 제품을 구매한 사람 제외
	       select 1
	       from cx.fct_K7_Monthly x
				join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' and y.cigatype != 'CSV' and len(x.id) > 4
	       where x.id = a.id
	           and x.YYYYMM < a.YYYYMM
	           and y.engname = b.engname
	   )
)
-- 해당 월에 테리어를 구매한 구매자가 직전 3개월에는 어떤 제품을 구매했는지 소싱
select 
	t.YYYYMM, t.Id, 
	max(t.gender) gender, 
	max(t.age) age , 
    CASE 
        WHEN SUM(CASE WHEN b.cigatype = 'CC' and a.YYYYMM < t.YYYYMM THEN 1 ELSE 0 END) > 0 
         AND SUM(CASE WHEN b.cigatype = 'HnB' and a.YYYYMM < t.YYYYMM THEN 1 ELSE 0 END) > 0 
        THEN 'Mixed' 
        ELSE MAX(b.cigatype)  -- CC 또는 HnB가 없을 경우 가장 큰 값을 사용
    END AS cigatype,
	 STUFF(
       (SELECT ','+ trim(company) 
	    FROM cx.fct_K7_Monthly x
	     	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
	    where t.id = x.id
		and x.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
						 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)
	    group by company
	    FOR XML PATH('')
	  )
	  , 1, 1, '') AS [company],
	 STUFF(
       (SELECT ','+ trim(New_Flavorseg) 
	    FROM cx.fct_K7_Monthly x
	     	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
	    where t.id = x.id
		and x.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
						 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)
	    group by New_Flavorseg
	    FOR XML PATH('')
	  )
	  , 1, 1, '') AS [Flavor],
	sum(case when company='BAT' then a.Pack_qty end ) 'BAT',
	sum(case when company='JTI' then a.Pack_qty end ) 'JTI',
	sum(case when company='KTG' then a.Pack_qty end ) 'KTG',
	sum(case when company='PMK' then a.Pack_qty end ) 'PMK',
	sum(case when cigatype='CC' and New_Flavorseg = 'Fresh' then a.Pack_qty end ) 'CC Fresh',
	sum(case when cigatype='CC' and New_Flavorseg = 'New Taste' then  a.Pack_qty end ) 'CC New Taste',
	sum(case when cigatype='CC' and New_Flavorseg = 'Regular' then  a.Pack_qty end ) 'CC Regular',
	sum(case when cigatype='HnB' and New_Flavorseg = 'Fresh' then  a.Pack_qty end ) 'HnB Fresh',
	sum(case when cigatype='HnB' and New_Flavorseg = 'New Taste' then  a.Pack_qty end ) 'HnB New Taste',
	sum(case when cigatype='HnB' and New_Flavorseg = 'Regular' then  a.Pack_qty end ) 'HnB Regular',
	sum(case when b.productSubFamilyCode = 'AIIM' and New_FLAVORSEG = 'Fresh' then  a.Pack_qty end ) 'AIIM Fresh',
	sum(case when b.productSubFamilyCode = 'AIIM' and New_FLAVORSEG = 'New Taste' then  a.Pack_qty end ) 'AIIM New Taste',
	sum(case when b.productSubFamilyCode = 'AIIM' and New_FLAVORSEG = 'Regular' then  a.Pack_qty end ) 'AIIM Regular',
	sum(case when b.productSubFamilyCode = 'FIIT' and New_FLAVORSEG = 'Fresh' then  a.Pack_qty end ) 'FIIT Fresh',
	sum(case when b.productSubFamilyCode = 'FIIT' and New_FLAVORSEG = 'New Taste' then  a.Pack_qty end ) 'FIIT New Taste',
	sum(case when b.productSubFamilyCode = 'HEETS' and New_FLAVORSEG = 'Fresh' then  a.Pack_qty end ) 'HEETS Fresh',
	sum(case when b.productSubFamilyCode = 'HEETS' and New_FLAVORSEG = 'New Taste' then  a.Pack_qty end ) 'HEETS New Taste',
	sum(case when b.productSubFamilyCode = 'HEETS' and New_FLAVORSEG = 'Regular' then  a.Pack_qty end ) 'HEETS Regular',
	sum(case when b.productSubFamilyCode = 'MIIX' and New_FLAVORSEG = 'Fresh' then  a.Pack_qty end ) 'MIIX Fresh',
	sum(case when b.productSubFamilyCode = 'MIIX' and New_FLAVORSEG = 'New Taste' then  a.Pack_qty end ) 'MIIX New Taste' ,
	sum(case when b.productSubFamilyCode = 'MIIX' and New_FLAVORSEG = 'Regular' then  a.Pack_qty end ) 'MIIX Regular',
	sum(case when b.productSubFamilyCode = 'NEO' and New_FLAVORSEG = 'Fresh' then  a.Pack_qty end ) 'NEO Fresh',
	sum(case when b.productSubFamilyCode = 'NEO' and New_FLAVORSEG = 'New Taste' then  a.Pack_qty end ) 'NEO New Taste',
	sum(case when b.productSubFamilyCode = 'NEO' and New_FLAVORSEG = 'Regular' then  a.Pack_qty end ) 'NEO Regular',
	sum(case when b.productSubFamilyCode = 'NEOSTICKS' and New_FLAVORSEG = 'Fresh' then  a.Pack_qty end ) 'NEOSTICKS Fresh',
	sum(case when b.productSubFamilyCode = 'NEOSTICKS' and New_FLAVORSEG = 'New Taste' then  a.Pack_qty end ) 'NEOSTICKS New Taste',
	sum(case when b.productSubFamilyCode = 'NEOSTICKS' and New_FLAVORSEG = 'Regular' then  a.Pack_qty end ) 'NEOSTICKS Regular',
	sum(case when b.productSubFamilyCode = 'TEREA' and New_FLAVORSEG = 'Fresh' then  a.Pack_qty end ) 'TEREA Fresh' ,
	sum(case when b.productSubFamilyCode = 'TEREA' and New_FLAVORSEG = 'New Taste' then  a.Pack_qty end ) 'TEREA New Taste',
	sum(case when b.productSubFamilyCode = 'TEREA' and New_FLAVORSEG = 'Regular' then  a.Pack_qty end ) 'TEREA Regular',
	sum(case when engname = 'HEETS AMBER LABEL' then  a.Pack_qty end ) 'HEETS AMBER LABEL',
	sum(case when engname = 'HEETS BLACK GREEN SELECTION' then  a.Pack_qty end ) 'HEETS BLACK GREEN SELECTION',
	sum(case when engname = 'HEETS BLACK PURPLE SELECTION' then  a.Pack_qty end ) 'HEETS BLACK PURPLE SELECTION',
	sum(case when engname = 'HEETS BLUE LABEL' then  a.Pack_qty end ) 'HEETS BLUE LABEL',
	sum(case when engname = 'HEETS BRONZE LABEL' then  a.Pack_qty end ) 'HEETS BRONZE LABEL',
	sum(case when engname = 'HEETS GOLD SELECTION' then  a.Pack_qty end ) 'HEETS GOLD SELECTION',
	sum(case when engname = 'HEETS GREEN LABEL' then  a.Pack_qty end ) 'HEETS GREEN LABEL',
	sum(case when engname = 'HEETS GREEN ZING' then  a.Pack_qty end ) 'HEETS GREEN ZING',
	sum(case when engname = 'HEETS PURPLE LABEL' then  a.Pack_qty end ) 'HEETS PURPLE LABEL',
	sum(case when engname = 'HEETS SATIN WAVE' then  a.Pack_qty end ) 'HEETS SATIN WAVE',
	sum(case when engname = 'HEETS SILVER LABEL' then  a.Pack_qty end )'HEETS SILVER LABEL',
	sum(case when engname = 'HEETS SUMMER BREEZE' then  a.Pack_qty end ) 'HEETS SUMMER BREEZE',
	sum(case when engname = 'HEETS TURQUOISE LABEL' then  a.Pack_qty end ) 'HEETS TURQUOISE LABEL',
	sum(case when engname = 'HEETS YUGEN' then  a.Pack_qty end ) 'HEETS YUGEN',
	sum(case when engname = 'TEREA AMBER' then  a.Pack_qty end ) 'TEREA AMBER',
	sum(case when engname = 'TEREA ARBOR PEARL' then  a.Pack_qty end ) 'TEREA ARBOR PEARL',
	sum(case when engname = 'TEREA BLACK GREEN' then  a.Pack_qty end ) 'TEREA BLACK GREEN',
	sum(case when engname = 'TEREA BLACK PURPLE' then  a.Pack_qty end ) 'TEREA BLACK PURPLE',
	sum(case when engname = 'TEREA BLACK YELLOW' then  a.Pack_qty end ) 'TEREA BLACK YELLOW',
	sum(case when engname = 'TEREA BLUE' then  a.Pack_qty end ) 'TEREA BLUE' ,
	sum(case when engname = 'TEREA GREEN' then  a.Pack_qty end ) 'TEREA GREEN' ,
	sum(case when engname = 'TEREA GREEN ZING' then  a.Pack_qty end ) 'TEREA GREEN ZING',
	sum(case when engname = 'TEREA OASIS PEARL' then  a.Pack_qty end ) 'TEREA OASIS PEARL',
	sum(case when engname = 'TEREA PURPLE WAVE' then  a.Pack_qty end ) 'TEREA PURPLE WAVE',
	sum(case when engname = 'TEREA RUSSET' then  a.Pack_qty end ) 'TEREA RUSSET' ,
	sum(case when engname = 'TEREA SILVER' then  a.Pack_qty end ) 'TEREA SILVER',
	sum(case when engname = 'TEREA SUMMER WAVE' then  a.Pack_qty end ) 'TEREA SUMMER WAVE',
	sum(case when engname = 'TEREA SUN PEARL' then  a.Pack_qty end ) 'TEREA SUN PEARL',
	sum(case when engname = 'TEREA TEAK' then  a.Pack_qty end ) 'TEREA TEAK',
	sum(case when engname = 'TEREA YUGEN' then  a.Pack_qty end ) 'TEREA YUGEN'	
--into cx.agg_TEREA_Sourcing
from TEREA_Purchasers t
	join cx.fct_K7_Monthly a on t.id = a.id 	-- 구매자
		and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
						 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
	join cx.product_master_temp b on a.product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  cigatype != 'CSV' AND 4 < LEN(a.id)
where 1=1 
group by t.YYYYMM, t.id
--order by t.YYYYMM, t.id
;

-- For Python Aggregation
select 
	t.YYYYMM, t.id, t.gender, t.age, 
	b.cigatype,
	b.company,
    b.ProductFamilyCode,
    b.productSubFamilyCode,
	b.New_FLAVORSEG,
    b.New_TARSEGMENTAT,
	b.engname,
    sum(a.pack_qty) qty
from  cx.agg_TEREA_Sourcing2 t
	join cx.fct_K7_Monthly a on t.id = a.id 
		and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
					     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
join cx.product_master_temp b on a.product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
where t.YYYYMM='202211'	
group by 
	t.YYYYMM, t.id, t.gender, t.age,
	b.cigatype,
	b.company,
    b.ProductFamilyCode,
    b.productSubFamilyCode,
	b.New_FLAVORSEG,
    b.New_TARSEGMENTAT,
	b.engname
	;

-- 엑셀 시트 데이터 반영 작업
-- Cigatype, Taste Total (Taste는 구매자 수가 다를 수 있음. 한 사람이 여러 맛을 구매)
select 
	t.YYYYMM,
	count(distinct t.id) total_Purchaser_Cnt,
	count(distinct case when t.cigatype ='CC' then t.id end ) 'CC',
	count(distinct case when t.cigatype ='HnB' then t.id end ) 'HnB',
	count(distinct case when t.cigatype ='Mixed' then t.id end ) 'Mixed',
	count(distinct case when New_FLAVORSEG ='Fresh' then t.id end ) 'Fresh',
	count(distinct case when New_FLAVORSEG ='New Taste' then t.id end ) 'New Taste',
	count(distinct case when New_FLAVORSEG ='Regular' then t.id end ) 'Regular'
from  cx.agg_TEREA_Sourcing2 t
	join cx.fct_K7_Monthly a on t.id = a.id 
		and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
				 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
	join cx.product_master_temp b on a.product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND b.cigatype != 'CSV' AND 4 < LEN(a.id)
where 1=1 	-- Target Date
group BY t.YYYYMM
order by t.YYYYMM
;


-- gender, age  by purchasers
select yyyymm, count(*) total_Purchaser_cnt, 
	count(case when gender ='남' then 1 end ) 'Male',
	count(case when gender ='여' then 1 end ) 'Female',
	count(case when gender not in ( '남','여') then 1 end ) 'Unknown',
	count(case when age = '20대' then 1 end) '20',
	count(case when age = '30대' then 1 end) '30',
	count(case when age = '40대' then 1 end) '40',
	count(case when age = '50대' then 1 end) '50',
	count(case when age = '60대' then 1 end) '60',
	count(case when age = '70대' then 1 end) '70',
	count(case when age = '미상' then 1 end) 'Unknown'
from cx.agg_TEREA_Sourcing  
group by yyyymm
order by yyyymm;


-- PMO Qty, CC Taste, HnB Taste, IQOS Qty
SELECT YYYYMM, 
    SUM([BAT]) AS BAT,
    SUM([JTI]) AS JTI,
    SUM([KTG]) AS KTG,
    SUM([PMK]) AS PMK,
    SUM([CC Fresh]) AS "CC Fresh",
    SUM([CC New Taste]) AS "CC New Taste",
    SUM([CC Regular]) AS "CC Regular",
    SUM([HnB Fresh]) AS "HnB Fresh",
    SUM([HnB New Taste]) AS "HnB New Taste",
    SUM([HnB Regular]) AS "HnB Regular",
    SUM([AIIM Fresh]) AS "AIIM Fresh",
    SUM([AIIM New Taste]) AS "AIIM New Taste",
    SUM([AIIM Regular]) AS "AIIM Regular",
    SUM([FIIT Fresh]) AS "FIIT Fresh",
    SUM([FIIT New Taste]) AS "FIIT New Taste",
    SUM([HEETS Fresh]) AS "HEETS Fresh",
    SUM([HEETS New Taste]) AS "HEETS New Taste",
    SUM([HEETS Regular]) AS "HEETS Regular",
    SUM([MIIX Fresh]) AS "MIIX Fresh",
    SUM([MIIX New Taste]) AS "MIIX New Taste",
    SUM([MIIX Regular]) AS "MIIX Regular",
    SUM([NEO Fresh]) AS "NEO Fresh",
    SUM([NEO New Taste]) AS "NEO New Taste",
    SUM([NEO Regular]) AS "NEO Regular",
    SUM([NEOSTICKS Fresh]) AS "NEOSTICKS Fresh",
    SUM([NEOSTICKS New Taste]) AS "NEOSTICKS New Taste",
    SUM([NEOSTICKS Regular]) AS "NEOSTICKS Regular",
    SUM([TEREA Fresh]) AS "TEREA Fresh",
    SUM([TEREA New Taste]) AS "TEREA New Taste",
    SUM([TEREA Regular]) AS "TEREA Regular",
    SUM([HEETS AMBER LABEL]) AS "HEETS AMBER LABEL",
    SUM([HEETS BLACK GREEN SELECTION]) AS "HEETS BLACK GREEN SELECTION",
    SUM([HEETS BLACK PURPLE SELECTION]) AS "HEETS BLACK PURPLE SELECTION",
    SUM([HEETS BLUE LABEL]) AS "HEETS BLUE LABEL",
    SUM([HEETS BRONZE LABEL]) AS "HEETS BRONZE LABEL",
    SUM([HEETS GOLD SELECTION]) AS "HEETS GOLD SELECTION",
    SUM([HEETS GREEN LABEL]) AS "HEETS GREEN LABEL",
    SUM([HEETS GREEN ZING]) AS "HEETS GREEN ZING",
    SUM([HEETS PURPLE LABEL]) AS "HEETS PURPLE LABEL",
    SUM([HEETS SATIN WAVE]) AS "HEETS SATIN WAVE",
    SUM([HEETS SILVER LABEL]) AS "HEETS SILVER LABEL",
    SUM([HEETS SUMMER BREEZE]) AS "HEETS SUMMER BREEZE",
    SUM([HEETS TURQUOISE LABEL]) AS "HEETS TURQUOISE LABEL",
    SUM([HEETS YUGEN]) AS "HEETS YUGEN",
    SUM([TEREA AMBER]) AS "TEREA AMBER",
    SUM([TEREA ARBOR PEARL]) AS "TEREA ARBOR PEARL",
    SUM([TEREA BLACK GREEN]) AS "TEREA BLACK GREEN",
    SUM([TEREA BLACK PURPLE]) AS "TEREA BLACK PURPLE",
    SUM([TEREA BLACK YELLOW]) AS "TEREA BLACK YELLOW",
    SUM([TEREA BLUE]) AS "TEREA BLUE",
    SUM([TEREA GREEN]) AS "TEREA GREEN",
    SUM([TEREA GREEN ZING]) AS "TEREA GREEN ZING",
    SUM([TEREA OASIS PEARL]) AS "TEREA OASIS PEARL",
    SUM([TEREA PURPLE WAVE]) AS "TEREA PURPLE WAVE",
    SUM([TEREA RUSSET]) AS "TEREA RUSSET",
    SUM([TEREA SILVER]) AS "TEREA SILVER",
    SUM([TEREA SUMMER WAVE]) AS "TEREA SUMMER WAVE",
    SUM([TEREA SUN PEARL]) AS "TEREA SUN PEARL",
    SUM([TEREA TEAK]) AS "TEREA TEAK",
    SUM([TEREA YUGEN]) AS "TEREA YUGEN"
FROM cx.agg_TEREA_Sourcing2
GROUP BY YYYYMM
ORDER BY YYYYMM
;

select * from cx.fct_K7_Monthly
where YYYYMM='202403'
and product_code = '88023540';

-- Arbor_user_current_type_M1
with temp as (
select  
	t.YYYYMM, t.id,
	max(case when cigatype='HnB' and company = 'PMK' then 1 else 0 end) IQOS_Purchased,
	max(case when cigatype='CC' then 1 else 0 end) CC_Purchased,
	max(case when cigatype='HnB' and company != 'PMK' then 1 else 0 end) CompHnB_Purchased
from  cx.agg_TEREA_Sourcing t
	join cx.fct_K7_Monthly a on t.id = a.id 
		and a.YYYYMM = t.YYYYMM
	join cx.product_master_temp b on a.product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  cigatype != 'CSV' AND 4 < LEN(a.id)
where 1=1 -- Target Date
group BY 	    
	t.YYYYMM, t.id
)
select YYYYMM,
    'IQOS' +
    CASE WHEN CompHnB_Purchased = 1 THEN ' + Comp. HnB' ELSE '' END + 
    CASE WHEN CC_Purchased = 1 THEN ' + CC' ELSE '' END 
     as Cigatype,
    count(*) purchaser_cnt
from temp
group by YYYYMM,
    'IQOS' +
    CASE WHEN CompHnB_Purchased = 1 THEN ' + Comp. HnB' ELSE '' END + 
    CASE WHEN CC_Purchased = 1 THEN ' + CC' ELSE '' END 
order by YYYYMM;



-- arbor_user_past_type_M1
with temp as (
select  ;
	t.YYYYMM, t.id,
	max(case when cigatype='HnB' and company = 'PMK' then 1 else 0 end) IQOS_Purchased,
	max(case when cigatype='CC' then 1 else 0 end) CC_Purchased,
	max(case when cigatype='HnB' and company != 'PMK' then 1 else 0 end) CompHnB_Purchased
from  cx.agg_TEREA_Sourcing t
	join cx.fct_K7_Monthly a on t.id = a.id 
		and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
				 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
	join cx.product_master_temp b on a.product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  cigatype != 'CSV' AND 4 < LEN(a.id)
where 1=1 	-- Target Date
group BY 	    
	t.YYYYMM, t.id
)
select 
    CASE WHEN IQOS_Purchased = 1 THEN 'IQOS' ELSE '' END  +
    CASE WHEN CompHnB_Purchased = 1 THEN ' + Comp. HnB' ELSE '' END + 
    CASE WHEN CC_Purchased = 1 THEN ' + CC' ELSE '' END
     as Cigatype,
    count(*) purchaser_cnt
from temp
group by
    CASE WHEN IQOS_Purchased = 1 THEN 'IQOS' ELSE '' END  +
    CASE WHEN CompHnB_Purchased = 1 THEN ' + Comp. HnB' ELSE '' END + 
    CASE WHEN CC_Purchased = 1 THEN ' + CC' ELSE '' END
;

-- arbor_flaXtar_M1   
select  
	t.YYYYMM,
	concat(New_FLAVORSEG,' X ', New_TARSEGMENTAT) flavorXtar,
	count(distinct case when cigatype ='CC' then t.id end) CC,
	count(distinct case when cigatype ='HnB' then t.id end) HnB
from cx.agg_TEREA_Sourcing t
	join cx.fct_K7_Monthly a on t.id = a.id 
		and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
				 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
	join cx.product_master_temp b on a.product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  cigatype != 'CSV' AND 4 < LEN(a.id)
where 1=1 -- Target Date
group BY t.YYYYMM, concat(New_FLAVORSEG,' X ', New_TARSEGMENTAT)  
order by t.YYYYMM, concat(New_FLAVORSEG,' X ', New_TARSEGMENTAT)
;


