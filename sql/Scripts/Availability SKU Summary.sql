

--TRUNCATE table CMRRPT.dbo.OMNI_Tier_tmp ;

select *
from CMRRPT.dbo.OMNI_Tier_tmp a
	join inserted i on a.CustomerCode = i.CustomerCode
where a.Load_date = i.Load_date
;



CREATE TABLE CMRRPT.dbo.OMNI_Tier_tmp (
	CustomerCode varchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	[Dashboard Tier] varchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	Load_Date nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	To_Date nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL
);


select max(a.Load_Date ), min(a.Load_date)
from CMRRPT.dbo.OMNI_Tier_tmp2 a
where 1=1
and a.to_date is null;

--20240621
--delete 
from CMRRPT.dbo.OMNI_Tier_tmp2
where load_date is null;


select *
FROM CMRRPT.dbo.OMNI_Tier_tmp
where Load_Date = '20240926';


-- CHAIN_CODE 4개 밖에 안됨
-- CHAIN_OLTCODE 52,222 개
select distinct CHAIN_OLTCODE 
from CMRRPT.dbo.POS_DATA_202408
;

-- 소매점 55,875
select distinct CustomerName 
from [ISMSR].[dbo].[CustomerLocalRpt]
where CustomerStatus ='A'
and CustomerTypeCode ='KA';


TRUNCATE table dbo.POS_DATA_2024;

--Updated Rows	18,517,792
--insert into dbo.POS_DATA_2024
select 
	PDATE, 
	--left(PDATE, 6) YYYYMM,
	a.CHAIN_CODE,
	a.CHAIN_OLTCODE, 
	COALESCE( t.CustomerCode, E.CustomerCode ) CustomerCode,
	a.PROD_ID,
	d.ProductCode, 
	a.SAL_QTY * C.SAL_QNT POS_Qty, 
	COALESCE( t.[Dashboard Tier], 'Others') Tier , 
	city,
	Region,
	e.IndustryClassificationLevelCode 
--into CMRRPT.dbo.POS_DATA_2024
from CMRRPT.dbo.POS_DATA_202408 A --각 체인별 판매데이터 (임시)
    left JOIN KAPOS.dbo.POS_OLT_MAP    B ON B.CHAIN_CODE = A.CHAIN_CODE AND B.CHAIN_OLTCODE = A.CHAIN_OLTCODE -- 각 체인 소매점 마스터
    left JOIN KAPOS.dbo.POS_BRD_MST    C ON C.CHAIN_CODE = A.CHAIN_CODE AND C.PROD_ID = A.PROD_ID -- 각 체인 상품 마스터
    left JOIN ISMSR.dbo.ProductLocalRpt D on C.MKTD_BRDCODE = D.SMARTSRCCode and D.company = 'PMK' -- PM 상품 마스터
	LEFT JOIN [ISMSR].[dbo].[CustomerLocalRpt] E on B.pm_oltcode = E.CustomerCode  and CustomerTypeCode = 'KA' and CustomerStatus = 'A' 
	left join OMNI_Tier_tmp t on E.CustomerCode = t.CustomerCode and A.PDATE BETWEEN t.Load_date and  t.to_date
where 1=1
and a.pdate between '20240901' and '20240931'
and e.CustomerCode is not null 
and d.ProductCode is not null
;


--    	and D.engname in (
--			'MARLBORO GOLD ORIGINAL',
--			'PARLIAMENT AQUA 5',
--			'MARLBORO RED',
--			'Marlboro Vista Tropical Splash',
--			'VS S. GOLD',
--			'PARLIAMENT ONE',
--			'PARLIAMENT HYBRID 5',
--			'MARLBORO MEDIUM',
--			'Marlboro Vista Forest Mist',
--			'MARLBORO ICE BLAST',
--			'MARLBORO ICE BLAST ONE',
--			'PARLIAMENT AQUA 3',
--			'MARLBORO WHITE FRESH',
--			'MARLBORO SILVER',
--			'Marlboro Vista Summer Splash',
--			'HARMONY 1',
--			'Marlboro Vista Blossom Mist',
--			'Marlboro Vista Tropical Breeze',
--			'Marlboro Vista Garden Splash'
--		)


-- 소매점, SKU 검증 
and e.CustomerCode is null 
and d.ProductCode is null

--9,828,470
select count(distinct CustomerCode ) 
from CMRRPT.dbo.POS_DATA_2024;
where IndustryClassificationLevelCode is null;


-- 전체 KA 소매점 52,879
select count(distinct CustomerCode ) 
from CMRRPT.dbo.POS_DATA_2024;

select * FROM OMNI_Tier_tmp 
where CustomerCode ='9004197';

select *
from dbo.TAX_AGG a
	full outer join dbo.POS_DATA_2024 b on a.OltCode  = b.CHAIN_OLTCODE 
where 1=1 
and b.CHAIN_OLTCODE is null 
and a.OltCode is null;




select * from Inventory_AGG2;

--18263	0000088013121	석계역점	9032145	PLTKSB
-- ChnInfo가 달라서 중복이 생김 ChnInfo 추가하기 
-- TAX 데이터 중복 제거 

-- Updated Rows	4,238,330
select Pdate, a.ChnInfo, a.OltCode, CustomerCode, OltName, c.BrdCode, Productcode , BrdName, (SalesQty * Qty) tax_qty
--into dbo.KA_TAXData_202409
from KAPOS.dbo.POSTAXData A --KA 소매점 발주자료
left join KAPOS.dbo.POSTAXCustomer B on a.ChnInfo = b.ChnInfo and B.OltCode = A.OltCode  --KA 소매점 발주 마스터
left join [KAPOS].[dbo].[POSTAXProduct] C on A.ChnInfo  = C.ChnInfo  and A.BrdCode = C.BrdCode  --KA 제품 발주 발주자료
where 1=1 --CustomerCode = '9034274' and ProductCode = 'PLTKSB'
and Pdate between '20240901' and '20240931'
;

--20240901	01	V7U84	9027187	GS25동해제일점	88013169	VSONE	버지니아슬림1mg	-10.00
-- TAX 왜 마이너스가 나오지?
select * 
from KAPOS.dbo.POSTAXData 
where 1=1 
and ChnInfo = '01'
and OltCode ='V7U84' and BrdCode ='88013169'


-- Inventory 
select *
from TMP_POS.dbo.KA_Inventory_Monthlyclosing_240831;


select top 100 * , Total_Inventory_Qty + tax_qty
from dbo.POS_DATA_2024 a
	left join dbo.KA_TAXData_202409 b on a.CustomerCode = b.CustomerCode  and a.ProductCode = b.ProductCode and a.PDATE  = b.Pdate
	left join CMRRPT.dbo.Inventory_AGG2 c on b.CustomerCode = c.PMCode and b.ProductCode = c.SKU and c.Month = a.Pdate --and [month] ='20240901'
where 1=1
and a.CustomerCode = '9036935';