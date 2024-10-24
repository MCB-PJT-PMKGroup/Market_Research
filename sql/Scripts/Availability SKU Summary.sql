

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
	d.CIGADEVICE,
	d.CIGATYPE,
	a.SAL_QTY * C.SAL_QNT POS_Qty, 
	COALESCE( t.[Dashboard Tier], 'Others') Tier , 
	city,
	Region,
	e.IndustryClassificationLevelCode 
--into CMRRPT.dbo.POS_DATA_2024
from KAPOS.dbo.POS_DATA A --각 체인별 판매데이터 (임시)
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


select 
	ProductDescription, ENGNAME , sum((A.SAL_QTY*C.SAL_QNT)) POS_Qty
--into CMRRPT.dbo.POS_DATA_2024
from KAPOS.dbo.POS_DATA A --각 체인별 판매데이터 (임시)
    left JOIN KAPOS.dbo.POS_OLT_MAP    B ON B.CHAIN_CODE = A.CHAIN_CODE AND B.CHAIN_OLTCODE = A.CHAIN_OLTCODE -- 각 체인 소매점 마스터
    left JOIN KAPOS.dbo.POS_BRD_MST    C ON C.CHAIN_CODE = A.CHAIN_CODE AND C.PROD_ID = A.PROD_ID -- 각 체인 상품 마스터
    left JOIN ISMSR.dbo.ProductLocalRpt D on C.MKTD_BRDCODE = D.SMARTSRCCode and D.company = 'PMK' -- PM 상품 마스터
	LEFT JOIN [ISMSR].[dbo].[CustomerLocalRpt] E on B.pm_oltcode = E.CustomerCode  and CustomerTypeCode = 'KA' and CustomerStatus = 'A' 
	left join OMNI_Tier_tmp t on E.CustomerCode = t.CustomerCode and A.PDATE BETWEEN t.Load_date and  t.to_date
where 1=1
and a.pdate between '20240901' and '20240931'
and d.ProductSubFamilyCode = 'MOBILITYKIT'
and e.CustomerCode is not null 
and d.ProductCode is not null
group by ProductDescription, ENGNAME


-- TAX AGG
select Pdate, (A.SalesQty * C.Qty) as tax_qty, A.OltCode, A.BrdCode, B.OltName, B.CustomerCode, C.ProductCode, D.ENGNAME, D.CIGATYPE, D.Company, A.ChnInfo
from KAPOS.dbo.POSTAXData A
left join KAPOS.dbo.POSTAXCustomer B on B.OltCode = A.OltCode
left join KAPOS.dbo.POSTAXProduct C on A.BrdCode = C.BrdCode and C.ChnInfo = A.ChnInfo
left join ISMSR.dbo.ProductLocalRpt D on C.ProductCode = D.ProductCode
left join ISMSR.dbo.CustomerLocalRpt E on E.CustomerCode = B.CustomerCode
where left(A.Pdate, 6) = '202409'
and D.CIGADEVICE = 'CIGARETTES'
and D.Company = 'PMK'
and E.CustomerTypeCode = 'KA' and CustomerStatus = 'A' 


-- Inventory  AGG 2
-- 4,928,670
with Inventory as (
  select [Month], PMCode, SKU, Inventory_qty, Chaincode
    from TMP_POS.dbo.KA_Inventory_Monthlyclosing_240831
  unpivot (Inventory_qty for SKU in (MFKSFT,MMEDFT,MBVTG,MLBGLD,MBTOUCH,MLBULT,MBGDULT,MBZGFU,MBZGDBL,MBZGMIX,MBHYB5,MBHYB1,MBTWIST,MBKSIBL,MBKSIB1,MBMTHFT,MWMTHFT,MLBSHUF,MLBVTS,MLBVTP,MLBVFM,MLBSSP,MLBBSM,MLBVGS,MBZADSS,MBFP,PLTKSB,PLTMLD,PLTHYB5,PLTHYB1,PLTRP,PLHYSS1,NPLHYSS1,PLTSSRD,PLTSSBL,PLTSSON,PLTSSCF,PLTDUAL,PLTFRS,PLTONE,PLTMBB,PLT03,PLTCAR5,PLTSPL,PLTTWIS,PLTDBW,VASLT,VASLTUL,VSONE,VASLTIN,VSRSVE,VSSS,VSSULT,VSSLTS,VSSSMTH,VSSONE,VSSCF4,VSSCF1,VSSSRFN,OASONE,OASMTH,LARKONE,LARKSS1,HGRLB20,HBLLB20,HAMLB20,HSVLB20,HPRLB20,HGRZG20,HGDLB20,HYLLB20,HBZLB20,HTQLB20,HSISE20,HSUBR20,HCDLB20,HNOOR20,HAMMI20,HYUGE20,HBLGR20,HBLPP20,HSAWA20,TEGREEN,TEBLUE,TEAMBER,TESILVE,TEPURWA,TEGRNZG,TESUMWA,TEYUGEN,TEBLKGR,TEBLKPU,TEBLKYL,TEOASPR,TESUNPR,TEABPL,TESTAPR,TERUSET,TETEAK) ) as unpivo
)
--insert into CMRRPT.dbo.Inventory_AGG2 (Month, PMCode, SKU, ENGNAME, Total_Inventory_Qty, Chaincode)
select a.Month, a.PMCode, a.SKU, b.ENGNAME, Inventory_qty, a.Chaincode
from  Inventory a
  join ISMSR.dbo.ProductLocalrpt b on a.SKU COLLATE KOREAN_WANSUNG_CS_AS_WS = b.Productcode COLLATE KOREAN_WANSUNG_CS_AS_WS

truncate table CMRRPT.dbo.Inventory_AGG2;


-- AGG_Availability_Daily
select  * ,
	sum(coalesce(Total_Inventory_Qty, 0) + coalesce(final_qty, 0) - coalesce(SAL_QTY, 0) ) over (partition by PMCode, ProductCode order by Date) as daily_inv
FROM 
( 
	select top 10
		coalesce(A.Month, B.Pdate, C.PDATE) as Date, 
		coalesce(A.PMCode, B.CustomerCode, C.CustomerCode) as PMCode, 
		coalesce(A.SKU, B.ProductCode, C.ProductCode) as ProductCode, 
		sum(A.Total_Inventory_Qty ) Total_Inventory_Qty,
		sum(B.final_qty) final_qty, 
		sum(C.SAL_QTY )	SAL_QTY
	from CMRRPT.dbo.Inventory_AGG2	A
		full outer join CMRRPT.dbo.TAX_AGG 	B on B.CustomerCode = A.PMCode and B.ProductCode = A.SKU and A.Month = B.Pdate and CustomerCode != ''
		full outer join CMRRPT.dbo.POS_DATA_2024 C on C.CustomerCode = A.PMCode and C.ProductCode = A.SKU and C.PDATE = A.Month
	where 
		left(coalesce(A.Month, B.Pdate, C.PDATE), 6) = '202409'
	and coalesce(A.PMCode, B.CustomerCode, C.CustomerCode) = '3000201'
	and coalesce(A.SKU, B.ProductCode, C.ProductCode) = 'MBKSIBL'
--	and PMCode != '?????'
	group by coalesce(A.Month, B.Pdate, C.PDATE), coalesce(A.PMCode, B.CustomerCode, C.CustomerCode), coalesce(A.SKU, B.ProductCode, C.ProductCode)
) t
; 


select * from dbo.AGG_Availability_Daily


select * 
from CMRRPT.dbo.POS_DATA_2024 a
	join ISMSR.dbo.ProductLocalRpt b on a.ProductCode = b.ProductCode 
where ProductSubFamilyCode = 'MOBILITYKIT' ;


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



select  * ,
 sum(coalesce(Total_Inventory_Qty, 0) + coalesce(final_qty, 0) - coalesce(SAL_QTY, 0) ) over (partition by PMCode, ProductCode order by Date) as daily_inv
FROM 
( 
 select
  coalesce(A.Month, B.Pdate, C.PDATE) as Date, 
  coalesce(A.PMCode, B.CustomerCode, C.CustomerCode) as PMCode, 
  coalesce(A.SKU, B.ProductCode, C.ProductCode) as ProductCode, 
  sum(A.Total_Inventory_Qty ) Total_Inventory_Qty,
  sum(B.final_qty) final_qty, 
  sum(C.SAL_QTY ) SAL_QTY,
  C.Tier
 from CMRRPT.dbo.Inventory_AGG2 A
  full outer join CMRRPT.dbo.TAX_AGG  B on B.CustomerCode = A.PMCode and B.ProductCode = A.SKU and A.Month = B.Pdate and CustomerCode != ''
  full outer join CMRRPT.dbo.POS_DATA_2024 C on C.CustomerCode = A.PMCode and C.ProductCode = A.SKU and C.PDATE = A.Month
 /*
 where 
  left(coalesce(A.Month, B.Pdate, C.PDATE), 6) = '202409'
 and coalesce(A.PMCode, B.CustomerCode, C.CustomerCode) = '3000201'
 and coalesce(A.SKU, B.ProductCode, C.ProductCode) = 'MBKSIBL'
--and PMCode != '?????'
*/
 group by coalesce(A.Month, B.Pdate, C.PDATE), coalesce(A.PMCode, B.CustomerCode, C.CustomerCode), coalesce(A.SKU, B.ProductCode, C.ProductCode), C.Tier
) t
where t.PMCode != '?????'
; 




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




select top 100
	coalesce(A.Month, B.Pdate, C.PDATE) as Date, 
	coalesce(A.PMCode, B.CustomerCode, C.CustomerCode) as PMCode, 
	coalesce(A.SKU, B.ProductCode, C.ProductCode) as ProductCode, 
	A.Total_Inventory_Qty, 
	B.final_qty, 
	C.SAL_QTY, 
	sum(coalesce(A.Total_Inventory_Qty, 0) + coalesce(B.final_qty, 0) - coalesce(C.SAL_QTY, 0)) over (partition by coalesce(A.PMCode, B.CustomerCode, C.CustomerCode), coalesce(A.SKU, B.ProductCode, C.ProductCode) order by coalesce(A.Month, B.Pdate, C.PDATE)) as Daily_Inventory
from (select * from CMRRPT.dbo.Inventory_AGG2 where PMCode != '?????')	A
	full outer join (select * from CMRRPT.dbo.TAX_AGG where CustomerCode != '')	B on B.CustomerCode = A.PMCode and B.ProductCode = A.SKU and A.Month = B.Pdate
	full outer join CMRRPT.dbo.POS_DATA_2024	C on C.CustomerCode = B.CustomerCode and C.ProductCode = B.ProductCode and B.Pdate = C.PDATE --and C.CHAIN_CODE = B.ChnInfo
where left(coalesce(A.Month, B.Pdate, C.PDATE), 6) = '202409'
and coalesce(A.PMCode, B.CustomerCode, C.CustomerCode) = '3000265'
and coalesce(A.SKU, B.ProductCode, C.ProductCode) = 'TEBLKPU'
;




-- 디바이스 쿼리
Select 
 ProductDescription, ENGNAME , sum((A.SAL_QTY*C.SAL_QNT)) POS_Qty
--into #temp123
FROM KAPOS.dbo.POS_DATA A
    left JOIN KAPOS.dbo.POS_OLT_MAP    B ON B.CHAIN_CODE = A.CHAIN_CODE AND B.CHAIN_OLTCODE = A.CHAIN_OLTCODE
    left JOIN KAPOS.dbo.POS_BRD_MST    C ON C.CHAIN_CODE = A.CHAIN_CODE AND C.PROD_ID = A.PROD_ID
    left JOIN   ISMSR.dbo.ProductLocalRpt D  on  C.MKTD_BRDCODE = D.SMARTSRCCode
    --Left JOIN [ISMSR].[dbo].[CustomerLocalRpt] E on B.pm_oltcode = E.CustomerCode
    --left join [CMRRPT].[dbo].[Corner_meta_working] F on E.customercode =  F.custcode and A.pdate = F.pdate
Where a.pdate between '20240901' and '20240931'
--and f.corner_type is null('Corner','POPUP')--null은KA,Corner는 코너, POPUP은 G.SalesEvent
--and d.cigatype = 'HNB'--Cigarrett 추출 시
--and d.cigadevice = 'device' --/ 'Cigarettes'--Cigarrett 추출 시
--and d.Company = 'KTG'--특정 회사 추출 시
and d.ProductSubFamilyCode = 'MOBILITYKIT'--mobilitykit은 PMK의 디바이스만 나옴
--and d.ProductCode = '10098541'--하나의 프로덕트만 구할 때
group by ProductDescription, ENGNAME 
;


select ProductDescription, ENGNAME , sum(SAL_QTY) POS_Qty
from CMRRPT.dbo.POS_DATA_2024 a
 join ISMSR.dbo.ProductLocalRpt b on a.ProductCode = b.ProductCode 
where ProductSubFamilyCode = 'MOBILITYKIT' 
group by ProductDescription, ENGNAME;
