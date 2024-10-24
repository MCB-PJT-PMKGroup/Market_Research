DECLARE @StartDate DATE = '2010-01-01';
DECLARE @EndDate DATE = '2050-12-31';

WHILE @StartDate <= @EndDate
BEGIN
    
    select 
        @StartDate,
        format(YEAR(@StartDate) , '0000') AS  [year] ,
        FORMAT(MONTH(@StartDate), '00') as [month],
        FORMAT(day(@StartDate), '00') as [day],
        DATEPART(WEEKDAY, @StartDate) dayofweek,
        datename(weekday, @StartDate) dayName,
        DATEPART(week, @StartDate) weekofyear,
        '' weekofMonth,
        DATEADD(DAY, 2 - DATEPART(WEEKDAY, @StartDate), @StartDate) AS MondayOfMonth,
        DENSE_RANK() OVER (PARTITION BY YEAR(MondayOfMonth), MONTH(MondayOfMonth) ORDER BY MondayOfMonth) AS Week_Num
	;
    
    SET @StartDate = DATEADD(DAY, 1, @StartDate);
END;


 

-- 참고 : 기간 달력 넣는방법
WITH tmp AS ( 
SELECT idx=1, dt = cast('20090101' AS datetime) 
UNION ALL 
SELECT idx = idx + 1, dt = dateadd(d, 1, dt) 
FROM tmp 
WHERE dt < cast('20101231' AS datetime) 
) 
SELECT 
dt
, year = datepart(year, dt) 
, month = datepart(month, dt) 
, day = datepart(day, dt) 
, weekofyear = datepart(wk , dt)
, weekofmonth = datepart(wk, dt) - datepart(wk, left(convert(varchar, dt, 112), 6)+ '01') + 1
, 요일 = datename(w, dt) 
, 분기 = datepart(q, dt) 
, 반기 = case when datepart(month,dt) BETWEEN 1 AND 6 then '상반기' else '하반기' end 
FROM tmp 
OPTION (maxrecursion 0) 
;

-- Create Calendar
WITH tmp AS ( 
	SELECT idx=1, dt = cast('20210101' AS date) 
	UNION ALL 
	SELECT idx = idx + 1, dt = dateadd(d, 1, dt) 
	FROM tmp 
	WHERE dt < cast('20501231' AS date) 
) 
SELECT
        dt,
        format(YEAR(dt) , '0000') AS  [year] ,
        FORMAT(MONTH(dt), '00') as [month],
        FORMAT(day(dt), '00') as [day],
        DATEPART(WEEKDAY, dt) dayofweek,
        datename(weekday, dt) dayName,
        DATEPART(week, dt) weekofyear,
        weekofmonth = datepart(wk, dt) - datepart(wk, left(convert(varchar, dt, 112), 6)+ '01') + 1,
        DATEADD(DAY, 2 - DATEPART(WEEKDAY, dt), dt) AS MondayOfMonth,
        CONVERT(nvarchar(6), dt, 112) as YYYYMM,
        concat(format(year(dt), '0000'), datepart(q, dt)) as quarterly
--INTO cx.Dim_Calendar 
FROM tmp 
OPTION (maxrecursion 0)
;




drop table cx.Dim_Calendar ;

SELECT * FROM cx.Dim_Calendar ;

--alter table cx.seven11_user_3month_list drop constraint pk_seven11_user_3month_list_id_YYYYMM ;
--alter table cx.seven11_user_3month_list add constraint pk_seven11_user_3month_list_YYYYMM_id primary key( YYYYMM, id ) ;

alter table cx.Dim_Calendar drop constraint pk_dim_calendar_YYYYMM_quarter;
alter table cx.Dim_Calendar add constraint pk_dim_calendar_YYYYMM_quarter primary key ( quarterly, YYYYMM, dt);


-- NULL, pack 0.7 검색하기
select * from cx.product_master a
	join cx.l_point_product_master_tmp  b on a.PROD_ID  = b.PROD_ID  and a.SAL_QNT <> b.SAL_QNT 
;

select * from cx.product_master 
where PROD_ID  in ( 
	select product_code 
	from cx.fct_K7_Monthly
	where Pack_qty is null
)
;

select * 
from cx.l_point_product_master_tmp 
where PROD_ID ='8801116012176';


-- 6,557,558 
with ttt as( 
	select id, YYYYMM 
	from cx.seven11_user_3month_list_tmp
	except
	select id, YYYYMM
	from cx.v_user_3month_list
)
select *
from ttt;



select *
from cx.fct_K7_Monthly 
where buy_ct = 14;

select *
from cx.fct_K7_Monthly 
where Pack_qty =14;


select min(YYYYMM)
FROM cx.seven11_user_3month_list_tmp
;



-- cx.v_user_3month_list source

with temp as  ( 
select a.YYYYMM,  a.id
from  cx.fct_K7_Monthly a 
	join cx.product_master b on a.product_code = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
where a.YYYYMM >= '202105'
and
   exists (
       -- (2) 직전 3개월 동안 구매이력이 있는지 확인
       select 1
       from cx.fct_K7_Monthly x
       	join cx.product_master y on x.product_code = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' and y.cigatype != 'CSV'
       where
           x.YYYYMM between convert(nvarchar(6), dateadd(month, -3, a.YYYYMM + '01'), 112)
           				and convert(nvarchar(6), dateadd(month, -1, a.YYYYMM + '01'), 112)
       and a.id = x.id
       group by x.YYYYMM, x.id
	       	   having
	       count(distinct y.engname) < 11 -- (3) SKU 11종 미만
	       and sum(x.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만
   )
and a.id in (
	select id 
	from 
)
group by a.YYYYMM, a.id
having
       count(distinct b.engname) < 11 -- (3) SKU 11종 미만
   and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만;
)
select count(*)
from temp ;;
D

select engname, b.SAL_QNT, buy_ct * cast(SAL_QNT as decimal(18,10)) Pack_qty , a.*
from cx.fct_K7_Monthly a
	join cx.product_master b on a.product_code = b.PROD_ID 
where id ='24A271EF18CC1080BB16E9D1A9D12C2238E907F7EEFE08D47A0975F4F6AE6EA6'
order by de_dt ;

select engname, b.SAL_QNT, SALE_QTY * cast(SAL_QNT as decimal(18,10)) Pack_qty , a.*
from cu.Fct_BGFR_PMI_Monthly a
	left join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and 4 < len(a.id) and b.CIGATYPE != 'CSV'
order by YYYYMM ;


update a
set Pack_qty =  buy_ct * cast(SAL_QNT as decimal(18,10))
from cx.fct_K7_Monthly a
	left join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and 4 < len(a.id) and b.CIGATYPE != 'CSV'
;




select 
	engname, SAL_QNT 
	,de_dt
	,product_code
	,id
	,buy_ct
	,left(de_dt, 6) YYYYMM
	,buy_ct * cast(SAL_QNT as decimal(18,10)) Pack_qty
	,gender
	,age
	,rct_seq
from cx.K7_202406 a
	left join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and 4 < len(a.id) and b.CIGATYPE != 'CSV'
where  id ='24A271EF18CC1080BB16E9D1A9D12C2238E907F7EEFE08D47A0975F4F6AE6EA6'
;

drop table cu.cu_master_tmp ;


select max(YYYYMM)
from cu.user_3month_list ;



select *
from cu.Fct_BGFR_PMI_Monthly  
where YYYYMM = '202408';



-- BPDA.cu.user_3month_list definition

-- Drop table

-- DROP TABLE BPDA.cu.user_3month_list;

CREATE TABLE BPDA.cu.cu_user_3month_list (
	id nvarchar(100) COLLATE Korean_Wansung_CI_AS NOT NULL,
	YYYYMM nvarchar(10) COLLATE Korean_Wansung_CI_AS NOT NULL
);


insert into cu.cu_user_3month_list
select * from cu.output22 ;


select id, YYYYMM, count(*)
from cu.cu_user_3month_list
group by id, YYYYMM
having count(*)>1;



TRUNCATE table  cu.user_3month_list;

drop view cu.v_user_3month_list;

create view cu.v_user_3month_list as
select a.YYYYMM, a.id, max(row_id) row_id
from  cu.Fct_BGFR_PMI_Monthly a 
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
where a.YYYYMM >= '202302'
and
   exists (
       -- (2) 직전 3개월 동안 구매이력이 있는지 확인
       select 1
       from cu.Fct_BGFR_PMI_Monthly x
       		join cu.dim_product_master y on x.ITEM_CD = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' and y.cigatype != 'CSV'
       where
           x.YYYYMM between convert(nvarchar(6), dateadd(month, -3, a.YYYYMM + '01'), 112)
           				and convert(nvarchar(6), dateadd(month, -1, a.YYYYMM + '01'), 112)
       and a.id = x.id
       group by x.YYYYMM, x.id
	   having count(distinct y.engname) < 11 and sum(x.Pack_qty) < 61.0 -- (3) 구매 SKU 11종 미만 & 팩 수량 61개 미만
   )
group by a.YYYYMM, a.id 
having
       count(distinct b.engname) < 11 -- (3) SKU 11종 미만
   and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만;

  
  insert into cu.user_3month_list 
select id, YYYYMM from cu.v_user_3month_list
where YYYYMM >= '202302';




select id,YYYYMM, count(*) 
from  cu.user_3month_list
group by id,YYYYMM
having count(*)>1;






with temp as (
	select
		t.YYYYMM, 
		t.id
    from cx.seven11_user_3month_list t
		join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM
		join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND b.cigatype != 'CSV'
	where t.YYYYMM >= '202211'
	group BY t.YYYYMM, t.id
	having sum(pack_qty) > 1
)
select 
	t.YYYYMM, ProductFamilyCode, b.company,
    count(distinct t.id ) n
from temp t
	join cx.fct_K7_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM
	join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND b.cigatype = 'CC'
where 1=1
group BY t.YYYYMM, ProductFamilyCode , b.company
;



with temp as ( 
	select * 
	from ( 
		select t.YYYYMM, t.id, a.SIDO_NM , gr_cd,
		row_number() over(partition by t.YYYYMM, t.id  order by a.row_id desc) rn,
		sum(pack_qty) over(partition by t.YYYYMM, t.id) qty 
		from cu.cu_user_3month_list_incl_csv t
			join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
			join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE = 'CIGARETTES' and cigatype !='CSV'
			join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
		where  t.YYYYMM >= '202401'
	) as t
	where rn = 1 -- gr_cd 마지막 구매지역
	and qty > 1
)
select YYYYMM, count(distinct id) cnt
from temp 
group by YYYYMM;




select distinct ProductFamilyCode , ProductSubFamilyCode , ProductDescription , Engname
from cx.product_master 
where ProductFamilyCode = 'ESSE';


-- Sentia 구매이력 
with temp as (
	select YYYYMM, id 
	from cx.fct_K7_Monthly a
		join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
	where ProductSubFamilyCode like 'SENTIA'
	and YYYYMM = '202409'
),
purchasers as (
	select b.Company , b.ProductFamilyCode , b.ProductSubFamilyCode , b.ProductDescription, b.engname, a.*
	from temp t
	join cx.fct_K7_Monthly a on t.id = a.id 
		and a.YYYYMM < t.YYYYMM
	join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV'
)
select ProductSubFamilyCode, count(distinct id) n
from purchasers
group by  ProductSubFamilyCode
order by ProductSubFamilyCode
;


select b.Company , b.ProductFamilyCode , b.ProductSubFamilyCode , b.ProductDescription, b.engname, a.*
from cx.fct_K7_Monthly a
	join cx.product_master b on a.product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV'
where id In (
'51DE9CBC29993CF89FF17D99971587F4D597B752142C1DE07F90C54675565494',
'752272A1D3975194A6A70CDE39D41CA7136F96617EA4E7CB2B79DE714CBF9313',
'6065AB8B896FE839905E58FDEF23A4771FC99C863B1D000CDF40C46F888F1E67'

)
and ProductSubFamilyCode ='TEREA'
;


