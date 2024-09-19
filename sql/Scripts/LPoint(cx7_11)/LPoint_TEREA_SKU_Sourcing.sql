/* 2024.08.12 작업 시작
 
1. TEREA Sourcing by SKU 17 건 
*/

select distinct engname from cx.product_master  
where ProductSubFamilyCode='TEREA';


--016B0252CBECDD3C54445431FC2CA44FAAFBD37746B4D3088A4C186ED80854E2
--02A17CCB761BD1E90F80A39308E74545B80D5C8804323659E13DB1A5F21EE2DA
--06023937FF899343155F00F8EAF2C763206D68AD6517324A4B05BC0BAB484967


   select  YYYYMM , id, row_number() over (partition by id order by YYYYMM) rn  
   from
       cx.fct_K7_Monthly a
       join cx.product_master b on a.Product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
   where 1=1 --id ='016B0252CBECDD3C54445431FC2CA44FAAFBD37746B4D3088A4C186ED80854E2' 
   and b.ProductSubFamilyCode = 'TEREA' and engname ='TEREA STARLING PEARL'
   group by YYYYMM , a.id
;


select * FROM cx.fct_K7_Monthly 
where id ='016B0252CBECDD3C54445431FC2CA44FAAFBD37746B4D3088A4C186ED80854E2' 
;

--sourcing_M1 모수 테이블
with temp as( 
select * 
from ( -- (1) 최초 구매이력이 있는지 확인, 동월에 다른 지역에 구매한 케이스 마지막 구매일로 지정 
   select  YYYYMM , id,  row_number() over (partition by id order by YYYYMM) rn  
   from
       cx.fct_K7_Monthly a
       join cx.product_master b on a.Product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
   where 1=1 --id ='016B0252CBECDD3C54445431FC2CA44FAAFBD37746B4D3088A4C186ED80854E2' 
   and b.ProductSubFamilyCode = 'TEREA' and engname ='TEREA STARLING PEARL'
   group by YYYYMM , a.id
) as t
where rn = 1
)
select t.YYYYMM, t.id, 
	max(case when t.seq = a.seq then b.engname end) engname
from temp t
	join cx.fct_K7_Monthly a on a.id = t.id  and  a.YYYYMM = t.YYYYMM
	join cx.product_master b on a.Product_code = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
where t.YYYYMM >= '202407'
and
   exists (
       -- (2) 직전 3개월 동안 구매이력이 있는지 확인
       select 1
       from cx.fct_K7_Monthly x
       	join cx.product_master y on x.Product_code = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' and y.cigatype != 'CSV'
       where
           x.YYYYMM between convert(nvarchar(6), dateadd(month, -3, a.YYYYMM + '01'), 112)
           				and convert(nvarchar(6), dateadd(month, -1, a.YYYYMM + '01'), 112)
       and a.id = x.id
      group by x.YYYYMM, x.id
	   having count(distinct y.engname) < 11 and sum(x.Pack_qty) < 61.0 -- (3) 구매 SKU 11종 미만 & 팩 수량 61개 미만
   )
group by t.YYYYMM, t.id 
having
       count(distinct b.engname) < 11 -- (3) SKU 11종 미만
   and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만
;



-- Data Validation 데이터 검증 작업!!!!!!!!!!!!!
-- 중복 체크
select YYYYMM , id, count(*) 
from cx.agg_LPoint_TEREA_SKU_Sourcing
group by YYYYMM, id 
having count(*) > 1
;


--직전 3개월 다른 제품 구매이력 여부 및 SKU, pack 수 체크
select YYYYMM, count(distinct Product_code) sku, sum(Pack_qty) sum 
from cx.fct_K7_Monthly 
where id ='00851229FF4A0026F2682594CEDABB0AE1B73FF85E6CDED060ED4FB00B37ECC9'
		and YYYYMM BETWEEN '202208' and '202210'
group by YYYYMM;

--직전 3개월 구매 상세 이력 
select engname, productdescription, prod_id, de_dt, id, gender, age, YYYYMM, pack_qty
from cx.fct_K7_Monthly x
	join cx.product_master y on x.Product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
where x.YYYYMM BETWEEN '202208' and '202211'
and x.id = '01E685679696C9867F8FF57E04863525BC7B8933FBC303B252898F72C83C2A40'
order by de_dt; 


-- 데이터 검증 끝


--TEREA AMBER 				7,754
--TEREA ARBOR PEARL			2,579
--TEREA BLACK GREEN			6,314
--TEREA BLACK PURPLE		15,116
--TEREA BLACK YELLOW		4,900
--TEREA BLUE				11,479
--TEREA GREEN				9,249
--TEREA GREEN ZING			3,270
--TEREA OASIS PEARL			11,856
--TEREA PURPLE WAVE			15,776
--TEREA RUSSET				2,946
--TEREA SILVER				7,725
--TEREA STARLING PEARL		1,838
--TEREA SUMMER WAVE			8,849
--TEREA SUN PEARL			6,849
--TEREA TEAK				2,233
--TEREA YUGEN				4,729


-- L Point sourcing_M1 모수 테이블
with temp as( 
select * 
from ( 
   select  YYYYMM  , id, max(engname) eng_name, row_number() over (partition by id order by YYYYMM) rn  
   from
       cx.fct_K7_Monthly a
       join cx.product_master b on a.Product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
   where 1=1
   and b.ProductSubFamilyCode = 'TEREA' and  engname ='TEREA YUGEN'
   group by YYYYMM , a.id
) as t
where rn = 1
),
TEREA_Purchasers as ( 
	select t.YYYYMM, t.id, 
		eng_name
	from temp t
		join cx.fct_K7_Monthly a on a.id = t.id  and  a.YYYYMM = t.YYYYMM
		join cx.product_master b on a.Product_code = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
	where t.YYYYMM = '202408'
	and
	   exists (
	       -- (2) 직전 3개월 동안 구매이력이 있는지 확인
	       select 1
	       from cx.fct_K7_Monthly x
	       	join cx.product_master y on x.Product_code = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' and y.cigatype != 'CSV'
	       where
	           x.YYYYMM between convert(nvarchar(6), dateadd(month, -3, a.YYYYMM + '01'), 112)
	           				and convert(nvarchar(6), dateadd(month, -1, a.YYYYMM + '01'), 112)
           and a.id = x.id
          group by x.YYYYMM, x.id
          having count(distinct y.engname) < 11 and sum(x.Pack_qty) < 61.0 -- (3) 구매 SKU 11종 미만 & 팩 수량 61개 미만
	   )
	group by t.YYYYMM, t.id , eng_name
	having
	       count(distinct b.engname) < 11 -- (3) SKU 11종 미만
	   and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만
)   
--insert into cx.agg_LPoint_TEREA_SKU_Sourcing
select 
	t.YYYYMM, t.id,
	t.eng_name engname,
	max(a.gender) gender, 
	max(a.age) age , 
    CASE 
        WHEN SUM(CASE WHEN b.cigatype = 'CC' and a.YYYYMM < t.YYYYMM THEN 1 ELSE 0 END) > 0 
         AND SUM(CASE WHEN b.cigatype = 'HnB' and a.YYYYMM < t.YYYYMM THEN 1 ELSE 0 END) > 0 
        THEN 'Mixed' 
        ELSE MAX(b.cigatype)  -- CC 또는 HnB가 없을 경우 가장 큰 값을 사용
    END AS cigatype,
	 STUFF(
       (SELECT ','+ trim(company) 
	    FROM cx.fct_K7_Monthly x
	     	join cx.product_master y on x.Product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' 
	    where t.id = x.id
		and x.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
						 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)
	    group by company
	    FOR XML PATH('')
	  )
	  , 1, 1, '') AS [company],
	 STUFF(
       (SELECT ','+ trim(FLAVORSEG_type3) 
	    FROM cx.fct_K7_Monthly x
	     	join cx.product_master y on x.Product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' 
	    where t.id = x.id
		and x.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
						 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)
	    group by FLAVORSEG_type3
	    FOR XML PATH('')
	  )
	  , 1, 1, '') AS [Flavor],
	sum(a.pack_qty) 'Total_Pack_Qty',
	sum(case when company='BAT' then a.Pack_qty end ) 'BAT',
	sum(case when company='JTI' then a.Pack_qty end ) 'JTI',
	sum(case when company='KTG' then a.Pack_qty end ) 'KTG',
	sum(case when company='PMK' then a.Pack_qty end ) 'PMK',
	sum(case when cigatype='CC' and FLAVORSEG_type3 = 'Fresh' then a.Pack_qty end ) 'CC Fresh',
	sum(case when cigatype='CC' and FLAVORSEG_type3 = 'New Taste' then  a.Pack_qty end ) 'CC New Taste',
	sum(case when cigatype='CC' and FLAVORSEG_type3 = 'Regular' then  a.Pack_qty end ) 'CC Regular',
	sum(case when cigatype='HnB' and FLAVORSEG_type3 = 'Fresh' then  a.Pack_qty end ) 'HnB Fresh',
	sum(case when cigatype='HnB' and FLAVORSEG_type3 = 'New Taste' then  a.Pack_qty end ) 'HnB New Taste',
	sum(case when cigatype='HnB' and FLAVORSEG_type3 = 'Regular' then  a.Pack_qty end ) 'HnB Regular',
	sum(case when b.productSubFamilyCode = 'AIIM' and FLAVORSEG_type3 = 'Fresh' then  a.Pack_qty end ) 'AIIM Fresh',
	sum(case when b.productSubFamilyCode = 'AIIM' and FLAVORSEG_type3 = 'New Taste' then  a.Pack_qty end ) 'AIIM New Taste',
	sum(case when b.productSubFamilyCode = 'AIIM' and FLAVORSEG_type3 = 'Regular' then  a.Pack_qty end ) 'AIIM Regular',
	sum(case when b.productSubFamilyCode = 'FIIT' and FLAVORSEG_type3 = 'Fresh' then  a.Pack_qty end ) 'FIIT Fresh',
	sum(case when b.productSubFamilyCode = 'FIIT' and FLAVORSEG_type3 = 'New Taste' then  a.Pack_qty end ) 'FIIT New Taste',
	sum(case when b.productSubFamilyCode = 'HEETS' and FLAVORSEG_type3 = 'Fresh' then  a.Pack_qty end ) 'HEETS Fresh',
	sum(case when b.productSubFamilyCode = 'HEETS' and FLAVORSEG_type3 = 'New Taste' then  a.Pack_qty end ) 'HEETS New Taste',
	sum(case when b.productSubFamilyCode = 'HEETS' and FLAVORSEG_type3 = 'Regular' then  a.Pack_qty end ) 'HEETS Regular',
	sum(case when b.productSubFamilyCode = 'MIIX' and FLAVORSEG_type3 = 'Fresh' then  a.Pack_qty end ) 'MIIX Fresh',
	sum(case when b.productSubFamilyCode = 'MIIX' and FLAVORSEG_type3 = 'New Taste' then  a.Pack_qty end ) 'MIIX New Taste' ,
	sum(case when b.productSubFamilyCode = 'MIIX' and FLAVORSEG_type3 = 'Regular' then  a.Pack_qty end ) 'MIIX Regular',
	sum(case when b.productSubFamilyCode = 'NEO' and FLAVORSEG_type3 = 'Fresh' then  a.Pack_qty end ) 'NEO Fresh',
	sum(case when b.productSubFamilyCode = 'NEO' and FLAVORSEG_type3 = 'New Taste' then  a.Pack_qty end ) 'NEO New Taste',
	sum(case when b.productSubFamilyCode = 'NEO' and FLAVORSEG_type3 = 'Regular' then  a.Pack_qty end ) 'NEO Regular',
	sum(case when b.productSubFamilyCode = 'NEOSTICKS' and FLAVORSEG_type3 = 'Fresh' then  a.Pack_qty end ) 'NEOSTICKS Fresh',
	sum(case when b.productSubFamilyCode = 'NEOSTICKS' and FLAVORSEG_type3 = 'New Taste' then  a.Pack_qty end ) 'NEOSTICKS New Taste',
	sum(case when b.productSubFamilyCode = 'NEOSTICKS' and FLAVORSEG_type3 = 'Regular' then  a.Pack_qty end ) 'NEOSTICKS Regular',
	sum(case when b.productSubFamilyCode = 'TEREA' and FLAVORSEG_type3 = 'Fresh' then  a.Pack_qty end ) 'TEREA Fresh' ,
	sum(case when b.productSubFamilyCode = 'TEREA' and FLAVORSEG_type3 = 'New Taste' then  a.Pack_qty end ) 'TEREA New Taste',
	sum(case when b.productSubFamilyCode = 'TEREA' and FLAVORSEG_type3 = 'Regular' then  a.Pack_qty end ) 'TEREA Regular',
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
--into cx.agg_LPoint_TEREA_SKU_Sourcing
from TEREA_Purchasers t
	join cx.fct_K7_Monthly a on t.id = a.id 	-- 구매자
		-- 테리어 구매자가 이전 3개월 동안 무엇을 구매했는지
		and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
						 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
	join cx.product_master b on a.Product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  cigatype != 'CSV' 
where 1=1 
group by t.YYYYMM, t.id, t.eng_name
--order by t.YYYYMM, t.id
;

--41991
-- 월별 신규 테리어 유입 대상자 추출 
select YYYYMM, count(*) 
from cx.agg_LPoint_TEREA_SKU_Sourcing
group by YYYYMM;

select engname, min(YYYYMM), count(*) 
from cx.agg_LPoint_TEREA_SKU_Sourcing
group by engname;

-- 중복 제거
select id, engname , count(*)
from cx.agg_LPoint_TEREA_SKU_Sourcing
group by id ,engname 
having count(*) > 1;

--delete from cx.agg_LPoint_TEREA_SKU_Sourcing
--where YYYYMM = '202407';




-- 엑셀 시트 데이터 반영 작업 SKU

-- gender, age  by purchasers
select t.YYYYMM, t.engname , 
	count(*) total_Purchaser_cnt, 
	count(case when t.gender ='남' then 1 end ) 'Male',
	count(case when t.gender ='여' then 1 end ) 'Female',
	count(case when t.age in ( '10대','20대') then 1 end) '20s',
	count(case when t.age = '30대' then 1 end) '30s',
	count(case when t.age = '40대' then 1 end) '40s',
	count(case when t.age = '50대' then 1 end) '50s',
	count(case when t.age = '60대' then 1 end) '60s',
	count(case when t.age = '70대' then 1 end) '70s'
from cx.agg_LPoint_TEREA_SKU_Sourcing  t
where 1=1 	
group by t.engname, t.YYYYMM
order by t.engname, t.YYYYMM;


-- Cigatype, Taste Total (Taste는 구매자 수가 다를 수 있음. 한 사람이 여러 Taste를 구매)
select 
	t.YYYYMM, t.engname  ,
	count(distinct t.id) total_Purchaser_Cnt,
	count(distinct case when t.cigatype ='CC' then t.id end ) 'CC',
	count(distinct case when t.cigatype ='HnB' then t.id end ) 'HnB',
	count(distinct case when t.cigatype ='Mixed' then t.id end ) 'Mixed',
	count(distinct case when FLAVORSEG_type3 ='Fresh' then t.id end ) 'Fresh Total',
	count(distinct case when FLAVORSEG_type3 ='New Taste' then t.id end ) 'New Taste Total',
	count(distinct case when FLAVORSEG_type3 ='Regular' then t.id end ) 'Regular Total',
	count(distinct case when b.cigatype = 'CC' and FLAVORSEG_type3 ='Fresh' then t.id end ) 'CC Fresh',
	count(distinct case when b.cigatype = 'CC' and FLAVORSEG_type3 ='New Taste' then t.id end ) 'CC New Taste',
	count(distinct case when b.cigatype = 'CC' and FLAVORSEG_type3 ='Regular' then t.id end ) 'CC Regular',
	count(distinct case when b.cigatype = 'HnB' and FLAVORSEG_type3 ='Fresh' then t.id end ) 'HnB Fresh',
	count(distinct case when b.cigatype = 'HnB' and FLAVORSEG_type3 ='New Taste' then t.id end ) 'HnB New Taste',
	count(distinct case when b.cigatype = 'HnB' and FLAVORSEG_type3 ='Regular' then t.id end ) 'HnB Regular'
from  cx.agg_LPoint_TEREA_SKU_Sourcing t
	join cx.fct_K7_Monthly a on a.id = t.id 
		and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
				 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
	join cx.product_master b on a.Product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND b.cigatype != 'CSV'
where 1=1 
group BY  t.engname, t.YYYYMM
order by  t.engname, t.YYYYMM
;





-- PMO Qty, CC Taste, HnB Taste, IQOS Qty
SELECT YYYYMM, t.engname ,
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
FROM cx.agg_LPoint_TEREA_SKU_Sourcing t
where 1=1 	
GROUP BY t.engname, t.YYYYMM
ORDER BY t.engname, t.YYYYMM
;



-- Pivot 이 필요한 대상들...

-- TEREA flavorXtar from 202211
select  
	t.YYYYMM,
	t.engname,
	concat(FLAVORSEG_type3,' X ', New_TARSEGMENTAT) flavorXtar,
	count(distinct case when b.cigatype ='CC' then t.id end) CC,
	count(distinct case when b.cigatype ='HnB' then t.id end) HnB
from  cx.agg_LPoint_TEREA_SKU_Sourcing t
	join cx.fct_K7_Monthly a on t.id = a.id 
		and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
				 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
	join cx.product_master b on a.Product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND b.cigatype != 'CSV'  
where 1=1 
group BY 
	t.YYYYMM,
	t.engname,
	concat(FLAVORSEG_type3,' X ', New_TARSEGMENTAT) 
;


-- user_past_type_M1
select  
	t.YYYYMM, 
	t.id,
	t.engname,
	max(case when b.cigatype='HnB' and b.company = 'PMK' then 1 else 0 end) IQOS_Purchased,
	max(case when b.cigatype='CC' then 1 else 0 end) CC_Purchased,
	max(case when b.cigatype='HnB' and b.company != 'PMK' then 1 else 0 end) CompHnB_Purchased
from cx.agg_LPoint_TEREA_SKU_Sourcing t
	join cx.fct_K7_Monthly a on t.id = a.id 
		and a.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, t.YYYYMM+'01'), 112)
				 	     AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, t.YYYYMM+'01'), 112)	
	join cx.product_master b on a.Product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
where 1=1 
group BY 	    
	t.YYYYMM, 
	t.id,
	t.engname
;


-- user_current_type_M1
with temp as (
select  
	t.YYYYMM,  
	t.id,
	t.engname,
	max(case when b.cigatype='HnB' and b.company = 'PMK' then 1 else 0 end) IQOS_Purchased,
	max(case when b.cigatype='CC' then 1 else 0 end) CC_Purchased,
	max(case when b.cigatype='HnB' and b.company != 'PMK' then 1 else 0 end) CompHnB_Purchased
from  cx.agg_LPoint_TEREA_SKU_Sourcing t
	join cx.fct_K7_Monthly a on t.id = a.id 
		and a.YYYYMM = t.YYYYMM
	join cx.product_master b on a.Product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
where 1=1 	
group BY 	    	
	t.YYYYMM, 
	t.id,
	t.engname
)
select YYYYMM, engname,
    'IQOS' +
    CASE WHEN CompHnB_Purchased = 1 THEN ' + Comp. HnB' ELSE '' END + 
    CASE WHEN CC_Purchased = 1 THEN ' + CC' ELSE '' END 
     as Cigatype,
    count(*) purchaser_cnt
from temp
group by YYYYMM, engname,
    'IQOS' +
    CASE WHEN CompHnB_Purchased = 1 THEN ' + Comp. HnB' ELSE '' END + 
    CASE WHEN CC_Purchased = 1 THEN ' + CC' ELSE '' END 
;

select count(*) from cx.agg_LPoint_TEREA_SKU_Sourcing ;

