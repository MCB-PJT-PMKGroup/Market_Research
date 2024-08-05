with temp as (
   select
       a.YYYYMM,
       a.id,
       a.gender,
       max(a.age) as age
   from
       cx.fct_K7_Monthly a
       join cx.product_master b on a.product_code = b.PROD_ID
           and b.CIGADEVICE = 'CIGARETTES'
           and b.cigatype != 'CSV'
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
   and a.YYYYMM = '202405' -- (2) Since 2022.11
   group by
       a.id, a.gender, a.YYYYMM
   having
       count(distinct a.product_code) < 11 -- (3) SKU 11종 미만
       and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만
)
select distinct
   b.ProductSubFamilyCode,
   a.YYYYMM,
   a.id,
   a.gender,
   a.age
from
   temp a
   join cx.fct_K7_Monthly c on a.id = c.id and a.YYYYMM = c.YYYYMM
   join cx.product_master b on c.product_code = b.PROD_ID
       and b.CIGADEVICE = 'CIGARETTES'
       and b.cigatype != 'CSV'
       and b.engname = 'TEREA ARBOR PEARL'
where
   not exists (
       -- (4) 해당 월 이전에 같은 제품을 구매한 사람 제외
       select 1
       from cx.fct_K7_Monthly x
			join cx.product_master y on x.product_code = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' and y.cigatype != 'CSV' 
       where x.id = a.id
       and x.YYYYMM < a.YYYYMM
       and y.engname = b.engname		-- 중요한 조건
);
	   
	   ;

   select
       a.YYYYMM,
       a.id,
       a.gender,
       max(a.age) as age,
       count(distinct a.product_code),
        sum(a.Pack_qty)
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
           having (count(distinct x.product_code) < 11 and sum( Pack_qty) < 61.0 ) and sum(Pack_qty) > 0
       )
       and a.YYYYMM = '202405' -- (2) 해당 월 (202403)
       and id ='6F474CC14D0252064A1852D270B7325E09B754578E0FE92CFF1ED9ADDA20B4FD'
   group by
       a.id, a.gender, a.YYYYMM
   having
       count(distinct a.product_code) < 11 -- (3) SKU 11종 미만
       and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만
      ;
       
       
-- 담배제품 매핑안된 구매건수 0으로 pack_qty 업데이트
--Updated Rows	1604137
update cx.fct_K7_Monthly 
set Pack_qty = 0
where Pack_qty is null;

-- pack_qty 0 이면 구매이력이 없는걸로 쳐야돼?

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
       and a.YYYYMM = '202403' -- (2) 해당 월 (202403)
   group by
       a.id, a.gender, a.YYYYMM
   having
       count(distinct a.product_code) < 11 -- (3) SKU 11종 미만
       and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만
)
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
and b.engname = 'TEREA ARBOR PEARL'
;


-- Validation 체크 
select id, YYYYMM ,
		count(distinct product_code)  -- (3) SKU 11종 미만
       , sum(Pack_qty)  
       from cx.fct_K7_Monthly a
       	join cx.product_master b on a.product_code  = b.PROD_ID 
where id ='21BCE943F6B85C9AB74C60E376F1329CCB284CE621327F373BB4613C0F070B28'
group by id, YYYYMM ;

-- 문제 있는 녀석들 pack_qty와 prodcut 등록이 안된 녀석들 떄문에 집계가 이상해짐
-- 202403 08BA5B3EFFFD3A4B1251ED7ADF993620AEEDA04B79510DAE59A0C87D525E3B0D SKU가 11개 넘는데.. 빠져야 되는거 아냐?

-- 2F32E9AB03B9C9D3D9DC59A7BF76CC4506F491DDCE046B097D2A785D484AB021  -- 얘는 나와야 되는데...  pack_qty가 널이라... 안나옴 0으로 채움

-- 202404 CEB252BFA51C73058D79E5C71ED727FAB0B391857B5088FC151F62704EB5A77E 왜 2024년 4월에 SKU 8건으로 있는거지?? SKU가 11건이 넘는데..
-- D30C7CB485B20A1067551BBFAE6270CC3F418E16DC627E1A8F4036C31FEA9556  정상 같은데?
-- 21BCE943F6B85C9AB74C60E376F1329CCB284CE621327F373BB4613C0F070B28 어떤 문제? 팩수 62개 넘음



-- M3:446건, 난 449 건 
-- 202405 E6E3D04963F280D04E202D2C35B22143775CF41A186F9C449287F7706B7ABEFC  202404월에 다른제품 구매이력이 있어서 포함되야 하는거 아닌가?
-- 6F474CC14D0252064A1852D270B7325E09B754578E0FE92CFF1ED9ADDA20B4FD 202402월에 SKU 없는 구매이력인데...
 


--11, 12
select *
       from cx.fct_K7_Monthly 
where id ='21BCE943F6B85C9AB74C60E376F1329CCB284CE621327F373BB4613C0F070B28';
and YYYYMM='202405';


 

SELECT ','+ trim(New_Flavorseg) 
	    FROM cx.fct_K7_Monthly x
	     	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
	    where  x.YYYYMM = '202404' and x.id='9DCA31A5ED770F7424053B48C9074157088EF7028A58E62E382FE46A362686B1'
	    group by New_Flavorseg;
	   
select  *from cx.product_master_temp pmt 
where prod_id in (
'88023540',
'88024134',
'88021492',
'88024158'

)
;



select YYYYMM, id , count(*)
from cx.agg_TEREA_Sourcing
group by YYYYMM, id 
having count(*) >1
;

select *
from cx.agg_TEREA_Sourcing;

--202301	0000DB160A1F35B1EF63C914DCF1B8206F73F97BD0CA082BE26A62373853D7B4

   select count(distinct  id) aa
   from
       cx.fct_K7_Monthly a
       join cx.product_master b on a.product_code = b.PROD_ID
           and b.CIGADEVICE = 'CIGARETTES'
           and b.cigatype != 'CSV'
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
       and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만;



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
--insert into cx.agg_TEREA_Sourcing
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

-- 33건 
select yyyymm, id 
from cx.fct_K7_Monthly 
WHERE len(id) < 6
group by yyyymm, Id;

delete 
from cx.fct_K7_Monthly 
WHERE len(id) < 6;


--truncate table cx.agg_TEREA_Sourcing;

-- TEREA 소싱 91,569
select * 
from cx.agg_TEREA_Sourcing 
where 1=1
and yyyymm='202403';


select b.ENGNAME, b.ProductDescription, a.* 
from cx.fct_K7_Monthly a
	join cx.product_master_temp b on a.product_code = b.PROD_ID 
where id ='031FA96410FD731549551FCC708D147FC8A0E5D6D1D4E4D3CCAE5B1CC10294B0'
order by de_dt desc;

select * from cx.agg_TEREA_Sourcing 
where id ='37E57B326FB8AE92038FC8C4E3FD0156CD6D23EDF7EAFFA87D3EB9192D2D4CEF';

--TEREA 제품을 구매한 이력이 2건이나 있는데..? 그럼 한건만 가져가야지..

select id ,count(*) 
from cx.agg_TEREA_Sourcing 
group by id
having count(*) > 1;

--count cigatype
select *
from (
	select yyyymm, cigatype , count(id) ee
	from cx.agg_TEREA_Sourcing
	group by yyyymm, cigatype 
) a
pivot 
	(sum(ee) for cigatype in ([CC], [HnB], [Mixed])) as b

-- count flavor
select
	YYYYMM,
	count(case when flavor like '%Fresh%' then id end) [Fresh],
	count(case when flavor like '%New Taste%' then id end) [New Taste],
	count(case when flavor like '%Regular%' then id end) [Regular]
from cx.agg_TEREA_Sourcing
group by YYYYMM
order by YYYYMM
;



SELECT
    p.yyyymm,
    p.[CC],
    p.[HnB],
    p.[Mixed],
    f.[Fresh],
    f.[New Taste],
    f.[Regular]
FROM
    (
        SELECT
            yyyymm,
            [CC],
            [HnB],
            [Mixed]
        FROM
            (
                SELECT
                    yyyymm,
                    cigatype,
                    COUNT(id) AS ee
                FROM
                    cx.agg_TEREA_Sourcing
                GROUP BY
                    yyyymm,
                    cigatype
            ) AS a
        PIVOT (
            SUM(ee) FOR cigatype IN ([CC], [HnB], [Mixed])
        ) AS pvt
    ) AS p
JOIN
    (
        SELECT
            YYYYMM,
            COUNT(CASE WHEN flavor LIKE '%Fresh%' THEN id END) AS [Fresh],
            COUNT(CASE WHEN flavor LIKE '%New Taste%' THEN id END) AS [New Taste],
            COUNT(CASE WHEN flavor LIKE '%Regular%' THEN id END) AS [Regular]
        FROM
            cx.agg_TEREA_Sourcing
        GROUP BY
            YYYYMM
    ) AS f
ON
    p.yyyymm = f.yyyymm
ORDER BY
    p.yyyymm;
 
   
-- Flavor X Tar

   
   
select distinct product_code 
from cx.fct_K7_Monthly a 
	left join cx.product_master b on product_code = prod_id
where prod_id is null;


select YYYYMM, count(*) 
from cx.agg_TEREA_Sourcing
group by YYYYMM;

with temp as (
select YYYYMM, id, count(*) ee
from cx.fct_K7_Monthly a
	join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
where exists (select 1 	-- (1) 3개월 구매이력 있는 ID만 추출
				from cx.fct_K7_Monthly x
					join cx.product_master y  on x.product_code = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' and y.cigatype != 'CSV'
				where  a.id = x.id
				and x.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, a.YYYYMM+'01'), 112)
				 				 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, a.YYYYMM+'01'), 112)
				group by YYYYMM, id
				having count(distinct y.engname) < 11 and sum( x.Pack_qty) < 61.0  
				)
and a.YYYYMM = '202405'
and b.ENGNAME = 'TEREA ARBOR PEARL'
and not exists (
	       -- (2) 해당 월 이전에 같은 제품을 구매한 사람 제외
	       select 1
	       from cx.fct_K7_Monthly x
				join cx.product_master y on x.product_code = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' and y.cigatype != 'CSV' 
	       where x.id = a.id
           and x.YYYYMM < a.YYYYMM
           and y.engname = b.engname 		-- 중요한 조건
	   )
group by YYYYMM, id
)
select c.YYYYMM, c.id
from temp a
   join cx.fct_K7_Monthly c on a.id = c.id and a.YYYYMM = c.YYYYMM
   join cx.product_master d  on c.product_code = d.PROD_ID and CIGADEVICE = 'CIGARETTES' and cigatype != 'CSV'
group by c.YYYYMM, c.id
having count(distinct d.engname) < 11 and sum( c.Pack_qty) < 61.0  
;



select YYYYMM, id, count(*) ee
from cx.fct_K7_Monthly a
	join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
where exists (select 1 	-- (1) 3개월 구매이력 있는 ID만 추출
				from cx.fct_K7_Monthly x
					join cx.product_master y  on x.product_code = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' and y.cigatype != 'CSV'
				where  a.id = x.id
				and x.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, a.YYYYMM+'01'), 112)
				 				 AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, a.YYYYMM+'01'), 112)
				group by YYYYMM, id
				having count(distinct y.engname) < 11 and sum( x.Pack_qty) < 61.0  
				)
and a.YYYYMM >= '202211'
and b.ProductSubFamilyCode = 'TEREA'
and not exists (
	       -- (2) 해당 월 이전에 같은 제품을 구매한 사람 제외
	       select 1
	       from cx.fct_K7_Monthly x
				join cx.product_master y on x.product_code = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' and y.cigatype != 'CSV' 
	       where x.id = a.id
           and x.YYYYMM < a.YYYYMM
           and y.ProductSubFamilyCode = b.ProductSubFamilyCode 		-- 중요한 조건
	   )
group by YYYYMM, id