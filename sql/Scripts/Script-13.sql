SELECT New_FLAVORSEG , FLAVORSEG_type6 
FROM cx.product_master_temp
group by New_FLAVORSEG , FLAVORSEG_type6 ;



SELECT  New_FLAVORSEG , New_TARSEGMENTAT , THICKSEG 
FROM cx.product_master_temp
where New_FLAVORSEG = 'New Taste' --and THICKSEG = 'STD'
group by New_FLAVORSEG  ,New_TARSEGMENTAT, THICKSEG  ;

select ProductFamilyCode , THICKSEG, count(*)
from cx.agg_CC_KS_SSL_Switch_2022_2023
group by ProductFamilyCode , THICKSEG


-- 1. Create indexes if not already present
CREATE INDEX idx_fct_K7_Monthly_id_YYYYMM ON cx.fct_K7_Monthly(id, YYYYMM);
CREATE INDEX idx_product_master_temp ON cx.product_master_temp( CIGADEVICE, cigatype, THICKSEG, FLAVORSEG_type6);
 
-- Optimized Query
SELECT  
    b.cigatype,    
    b.FLAVORSEG_type6,
    b.New_TARSEGMENTAT,
    COUNT(DISTINCT CASE WHEN a.YYYYMM LIKE '2023%' AND t.[out] > 0 THEN t.id END) AS Out_Purchaser_Cnt,
    COUNT(DISTINCT CASE WHEN a.YYYYMM LIKE '2022%' AND t.[In] > 0 THEN t.id END) AS In_Purchaser_Cnt,
    '',
    '',
    '',
    SUM(CASE WHEN a.YYYYMM LIKE '2023%' AND t.[Out] > 0 THEN a.pack_qty ELSE 0 END) AS Out_quantity,
    SUM(CASE WHEN a.YYYYMM LIKE '2022%' AND t.[In] > 0 THEN a.pack_qty ELSE 0 END) AS In_quantity
FROM
    cx.agg_CC_KS_SSL_Switch_2022_2023 t
    JOIN cx.fct_K7_Monthly a ON a.id = t.id AND LEN(a.id) > 4 AND a.YYYYMM IN ('202201', '202202', '202203', '202204', '202205', '202206', '202207', '202208', '202209', '202210', '202211', '202212', '202301', '202302', '202303', '202304', '202305', '202306', '202307', '202308', '202309', '202310', '202311', '202312')
    JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID AND b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV'
        AND (b.THICKSEG != t.THICKSEG OR b.FLAVORSEG_type6 != t.FLAVORSEG_type6 OR b.THICKSEG IS NULL)
WHERE
    t.THICKSEG = 'STD' AND t.ProductFamilyCode = 'All' AND t.FLAVORSEG_type6 = 'Fresh to New Taste'
GROUP BY
    GROUPING SETS ((b.cigatype, b.FLAVORSEG_type6, b.New_TARSEGMENTAT), (b.cigatype, b.FLAVORSEG_type6), (b.cigatype), ());
   

-- 2. Create indexes if not already present
CREATE INDEX idx_fct_K7_Monthly_id_YYYYMM ON cx.fct_K7_Monthly(id, YYYYMM);

CREATE INDEX idx_product_master_temp_flavor_tar ON cx.product_master_temp(CIGADEVICE, cigatype, New_FLAVORSEG, FLAVORSEG_type6, New_Tarsegmentat, engname);
 
-- Optimized Query
SELECT
    b.cigatype,
    b.Engname,
    b.FLAVORSEG_type6,
    b.New_Tarsegmentat,
    b.THICKSEG,
    COUNT(DISTINCT CASE WHEN a.YYYYMM LIKE '2023%' AND t.[Out] > 0 THEN t.id END) AS Out_Purchaser_Cnt,
    COUNT(DISTINCT CASE WHEN a.YYYYMM LIKE '2022%' AND t.[In] > 0 THEN t.id END) AS In_Purchaser_Cnt,
    '',
    '',
    '',
    SUM(CASE WHEN a.YYYYMM LIKE '2023%' AND t.[Out] > 0 THEN a.Pack_qty ELSE 0 END) AS Out_Quantity,
    SUM(CASE WHEN a.YYYYMM LIKE '2022%' AND t.[In] > 0 THEN a.Pack_qty ELSE 0 END) AS In_Quantity
FROM
    cx.agg_CC_KS_SSL_Switch_2022_2023 t
    JOIN cx.fct_K7_Monthly a ON t.id = a.id AND LEN(a.id) > 4 AND a.YYYYMM IN ('202201', '202202', '202203', '202204', '202205', '202206', '202207', '202208', '202209', '202210', '202211', '202212', '202301', '202302', '202303', '202304', '202305', '202306', '202307', '202308', '202309', '202310', '202311', '202312')
    JOIN cx.product_master_temp b ON a.Product_code = b.prod_id AND b.CIGADEVICE = 'CIGARETTES' AND b.CIGATYPE != 'CSV'
        AND (b.THICKSEG != t.THICKSEG OR b.FLAVORSEG_type6 != t.FLAVORSEG_type6 OR b.THICKSEG IS NULL)
WHERE
    t.ProductFamilyCode = 'All' AND t.FLAVORSEG_type6 = 'Fresh to New Taste'  
GROUP BY
    GROUPING SETS ((b.cigatype, b.Engname, b.FLAVORSEG_type6, b.New_Tarsegmentat, b.THICKSEG), (b.cigatype), ());

select id ,ProductFamilyCode, FLAVORSEG_type6 , count(*)
from cx.agg_CC_KS_SSL_Switch_2022_2023
group by id , ProductFamilyCode, FLAVORSEG_type6 
;

--ProductFamilyCode 5

select FLAVORSEG_type6, count(*) 
from cx.agg_CC_KS_SSL_Switch_2022_2023
group by FLAVORSEG_type6;


-- PROD_ID 데이터 분포 439
SELECT PROD_ID, COUNT(*) AS Frequency
FROM cx.product_master_temp
GROUP BY PROD_ID
ORDER BY Frequency DESC;
 
-- CIGADEVICE 데이터 분포 3
SELECT CIGADEVICE, COUNT(*) AS Frequency
FROM cx.product_master_temp
GROUP BY CIGADEVICE
ORDER BY Frequency DESC;
 
-- cigatype 데이터 분포 3
SELECT cigatype, COUNT(*) AS Frequency
FROM cx.product_master_temp
GROUP BY cigatype
ORDER BY Frequency DESC;
 
-- ProductFamilyCode 데이터 분포 5
SELECT ProductFamilyCode , COUNT(*) AS Frequency
FROM cx.agg_CC_SSL_Switch_2022_2023
GROUP BY ProductFamilyCode
ORDER BY Frequency DESC;
 
-- FLAVORSEG_type6 데이터 분포 8
SELECT FLAVORSEG_type6, COUNT(*) AS Frequency
FROM cx.product_master_temp
GROUP BY FLAVORSEG_type6
ORDER BY Frequency DESC;

-- New_TARSEGMENTAT 데이터 분포 6
SELECT New_TARSEGMENTAT, COUNT(*) AS Frequency
FROM cx.product_master_temp
GROUP BY New_TARSEGMENTAT 
ORDER BY Frequency DESC;

--201,392
select * from cx.agg_CC_SSL_Switch_2022_2023
where THICKSEG ='STD';

-- 231,808
delete  
from cx.agg_CC_KS_SSL_Switch_2022_2023
where THICKSEG ='STD' and ProductFamilyCode != 'All';

-- 231,808
select *
from cx.agg_CC_KS_SSL_Switch_2022_2023
where THICKSEG ='SSL' and ProductFamilyCode != 'All';


--insert into cx.agg_CC_KS_SSL_Switch_2022_2023 
select id, THICKSEG, FLAVORSEG_type6, [Out], [In], ProductFamilyCode 
from cx.agg_CC_SSL_Switch_2022_2023
where ProductFamilyCode != 'All';


-- 169,073
select *
from cx.agg_CC_KS_SSL_Switch_2022_2023
where THICKSEG ='SSL' and ProductFamilyCode != 'All';


--YM_CD
--SIDO_CD
--CUST_ID
--GENDER_CD
--AGE_CD
--ITEM_CD
--SALE_QTY
--PACK_QTY

TRUNCATE table cu.Fct_BGFR_PMI_Monthly ;

insert into cu.Fct_BGFR_PMI_Monthly 
select 
	YM_CD,
	SIDO_CD,
	CUST_ID,
	GENDER_CD,
	AGE_CD,
	ITEM_CD,
	SALE_QTY,
	COALESCE(a.SALE_QTY * b.SAL_QNT , 0) PACK_QTY
from cu.BGFR_PMI_202406 a
	left join cu.dim_product_master b on a.ITEM_CD  = b.prod_id
;


--202301 1,637,029
--202302 1,567,616
--202303 1,737,333
--202304 1,734,126
--202305 1,816,764
--202306 1,791,262
--202307 1,801,693
--202308 1,806,478
--202309 1,819,937
--202310 1,797,934
--202311 1,669,557
--202312 1,672,828
--202401 1,637,875
--202402 1,624,032
--202403 1,727,622
--202404 1,773,180
--202405 1,821,034
--202406 1,809,086




--alter table cu.Fct_BGFR_PMI_Monthly  add constraint PK_fct_BGFR_PMI_Monthly primary key (ITEM_CD, CUST_ID, YM_CD, SIDO_CD );

--alter table  cu.dim_product_master add	New_FLAVORSEG varchar(50) COLLATE Korean_Wansung_CI_AS NULL;
--alter table cu.dim_product_master add FLAVORSEG_type6 varchar(50) COLLATE Korean_Wansung_CI_AS NULL;
--alter table  cu.dim_product_master add	New_TARSEGMENTAT varchar(50) COLLATE Korean_Wansung_CI_AS NULL;


update a
set a.FLAVORSEG_type6 = 
	CASE 
	    WHEN b.FLAVORSEG like 'FS1:%' THEN 'Regular'
	    WHEN b.FLAVORSEG like 'FS2:%' THEN 'Regular to Fresh'
	    WHEN b.FLAVORSEG like 'FS3:%' THEN 'Regular to Fresh'
	    WHEN b.FLAVORSEG like 'FS4:%' THEN 'Regular to New Taste'
	    WHEN b.FLAVORSEG like 'FS5:%' THEN 'Fresh to Fresh'
	    WHEN b.FLAVORSEG like 'FS7:%' THEN 'New Taste'
	    WHEN b.FLAVORSEG like 'FS8:%' THEN 'Fresh to New Taste'
	    WHEN b.FLAVORSEG like 'FS9:%' THEN 'Fresh to New Taste'
	    WHEN b.FLAVORSEG like 'FS10:%' THEN 'Regular to New Taste'
	    WHEN b.FLAVORSEG like 'FS11:%' THEN 'Fresh to Fresh'
	    WHEN b.FLAVORSEG like 'FS12:%' 				THEN 'Regular to Fresh'
	    WHEN b.FLAVORSEG like 'FS13:%' 				THEN 'Regular Fresh'
	    WHEN b.FLAVORSEG like 'FS14:%' 				THEN 'New Taste'
	    when b.FLAVORSEG like 'Aftercut (New%' 		then 'New Taste'
	    when b.FLAVORSEG like 'Regular Fresh' 		then 'Regular Fresh' 
	    when b.FLAVORSEG like 'Regular to Fresh' 	then 'Regular to Fresh'
		when b.FLAVORSEG like 'Regular to New Taste' then 'Regular to New Taste'
		when b.FLAVORSEG like 'Fresh to New Taste'	then 'Fresh to New Taste'
    ELSE b.FLAVORSEG
    end 
	from cu.dim_product_master a
		join cu.dim_product_master b on a.prod_id = b.prod_id;


update cx.product_master_temp 
set Company  = trim(Company);

insert into cx.product_master
select a.PROD_ID,a.ENGNAME,a.ProductDescription,a.ProductFamilyCode,a.CIGADEVICE,a.CIGATYPE,a.FLAVORSEG,a.LENGTHSEG,a.MENTHOLINDI,a.DELISTYN,a.THICKSEG,a.TARSEGMENTAT,a.CAPSULEYN,a.TARINFO,a.Company,a.SAL_QNT,a.ProductSubFamilyCode,a.Productcode,a.MKTD_BRDCODE,a.SMARTSRCCode,a.[check],
	CASE 
	    WHEN b.FLAVORSEG like 'FS1:%' THEN 'Regular'
	    WHEN b.FLAVORSEG like 'FS2:%' THEN 'Fresh'
	    WHEN b.FLAVORSEG like 'FS3:%' THEN 'Fresh'
	    WHEN b.FLAVORSEG like 'FS4:%' THEN 'New Taste'
	    WHEN b.FLAVORSEG like 'FS5:%' THEN 'Fresh'
	    WHEN b.FLAVORSEG like 'FS7:%' THEN 'New Taste'
	    WHEN b.FLAVORSEG like 'FS8:%' THEN 'New Taste'
	    WHEN b.FLAVORSEG like 'FS9:%' THEN 'New Taste'
	    WHEN b.FLAVORSEG like 'FS10:%' THEN 'New Taste'
	    WHEN b.FLAVORSEG like 'FS11:%' THEN 'Fresh'
	    WHEN b.FLAVORSEG like 'FS12:%' THEN 'Fresh'
	    WHEN b.FLAVORSEG like 'FS13:%' THEN 'Fresh'
	    WHEN b.FLAVORSEG like 'FS14:%' THEN 'New Taste'
	    when b.FLAVORSEG like 'Aftercut (New%' then 'New Taste'
	    when b.FLAVORSEG like 'Regular Fresh' then 'Fresh' 
	    when b.FLAVORSEG like 'Regular to Fresh' then 'Fresh'
		when b.FLAVORSEG like 'Regular to New Taste' then 'New Taste'
		when b.FLAVORSEG like 'Fresh to New Taste' then 'New Taste'
    	ELSE b.FLAVORSEG 
    end,
	CASE 
    	when b.TARSEGMENTAT like 'TS1:%' then 'FF'
    	when b.TARSEGMENTAT like 'TS2:%' then 'LTS'
    	when b.TARSEGMENTAT like 'TS3:%' then 'ULT'
    	when b.TARSEGMENTAT like 'TS4:%' then '1MG'
    	when b.TARSEGMENTAT like 'TS5:%' then 'Below 1MG'
    	else b.TARSEGMENTAT 
    END,
	CASE 
	    WHEN b.FLAVORSEG like 'FS1:%' THEN 'Regular'
	    WHEN b.FLAVORSEG like 'FS2:%' THEN 'Regular to Fresh'
	    WHEN b.FLAVORSEG like 'FS3:%' THEN 'Regular to Fresh'
	    WHEN b.FLAVORSEG like 'FS4:%' THEN 'Regular to New Taste'
	    WHEN b.FLAVORSEG like 'FS5:%' THEN 'Fresh to Fresh'
	    WHEN b.FLAVORSEG like 'FS7:%' THEN 'New Taste'
	    WHEN b.FLAVORSEG like 'FS8:%' THEN 'Fresh to New Taste'
	    WHEN b.FLAVORSEG like 'FS9:%' THEN 'Fresh to New Taste'
	    WHEN b.FLAVORSEG like 'FS10:%' THEN 'Regular to New Taste'
	    WHEN b.FLAVORSEG like 'FS11:%' THEN 'Fresh to Fresh'
	    WHEN b.FLAVORSEG like 'FS12:%' 				THEN 'Regular to Fresh'
	    WHEN b.FLAVORSEG like 'FS13:%' 				THEN 'Regular Fresh'
	    WHEN b.FLAVORSEG like 'FS14:%' 				THEN 'New Taste'
	    when b.FLAVORSEG like 'Aftercut (New%' 		then 'New Taste'
	    when b.FLAVORSEG like 'Regular Fresh' 		then 'Regular Fresh' 
	    when b.FLAVORSEG like 'Regular to Fresh' 	then 'Regular to Fresh'
		when b.FLAVORSEG like 'Regular to New Taste' then 'Regular to New Taste'
		when b.FLAVORSEG like 'Fresh to New Taste'	then 'Fresh to New Taste'
    	ELSE b.FLAVORSEG 
    end as FLAVORSEG_type6
from cx.product_master_tmp a
	left join cx.product_master b on a.PROD_ID  = b.PROD_ID 
where b.PROD_ID is null;


 
update a
set a.Pack_qty = a.buy_ct * cast(b.sal_qnt as decimal)
from cx.fct_K7_Monthly a
	left join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.CIGATYPE != 'CSV'
;

--1799633
select * 
from cx.fct_K7_Monthly a
where Pack_qty is null;


select YYYYMM ,count(*)
from cx.agg_TEREA_Sourcing2
group by YYYYMM;
having count(*)>1;


-- 직전 3개월 구매이력 있는 유저 뽑기
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
	and a.YYYYMM >= '202211'
	--and b.ProductSubFamilyCode = 'TEREA'
	--and not exists (
	--	       -- (2) 해당 월 이전에 같은 제품을 구매한 사람 제외
	--	       select 1
	--	       from cx.fct_K7_Monthly x
	--				join cx.product_master y on x.product_code = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' and y.cigatype != 'CSV' 
	--	       where x.id = a.id
	--           and x.YYYYMM < a.YYYYMM
	--           and y.ProductSubFamilyCode = b.ProductSubFamilyCode 		-- 중요한 조건
	--)
	group by YYYYMM , id
	--having count(distinct b.engname) < 11 and sum( a.Pack_qty) < 61.0
)
select YYYYMM, count(*) ee
from temp
group by YYYYMM
;



-- 비어있는 data 찾기
select * 
from cu.cu_master_tmp a
	left join  cu.dim_product_master b on a.PROD_ID = b.PROD_ID 
where b.prod_id is null;
