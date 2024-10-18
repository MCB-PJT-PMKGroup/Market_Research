select *
from Dim_Kapos_OLT_MAP ;

--01
--05
--24
--03
--02

select * 
from KAPOS.dbo.POS_BRD_MST; -- chain_code, prod_id(POS_DATA), MKTD_BRDCODE

-- Main 19건
SELECT *
FROM ISMSR.dbo.ProductLocalRpt --SMARTSRCCODE
where engname in (
	'MARLBORO GOLD ORIGINAL',
	'PARLIAMENT AQUA 5',
	'MARLBORO RED',
	'Marlboro Vista Tropical Splash',
	'VS S. GOLD',
	'PARLIAMENT ONE',
	'PARLIAMENT HYBRID 5',
	'MARLBORO MEDIUM',
	'Marlboro Vista Forest Mist',
	'MARLBORO ICE BLAST',
	'MARLBORO ICE BLAST ONE',
	'PARLIAMENT AQUA 3',
	'MARLBORO WHITE FRESH',
	'MARLBORO SILVER',
	'Marlboro Vista Summer Splash',
	'HARMONY 1',
	'Marlboro Vista Blossom Mist',
	'Marlboro Vista Tropical Breeze',
	'Marlboro Vista Garden Splash'
);

-- Others 116건
select distinct engname
from ISMSR.dbo.ProductLocalRpt
where company = 'PMK'
and CIGADEVICE ='CIGARETTES';


-- POS
Select top 10 *
FROM KAPOS.dbo.POS_DATA A --각 체인별 판매데이터
    left JOIN KAPOS.dbo.POS_OLT_MAP    B ON B.CHAIN_CODE = A.CHAIN_CODE AND B.CHAIN_OLTCODE = A.CHAIN_OLTCODE -- 각 체인 소매점 마스터
    left JOIN KAPOS.dbo.POS_BRD_MST    C ON C.CHAIN_CODE = A.CHAIN_CODE AND C.PROD_ID = A.PROD_ID -- 각 체인 상품 마스터
    left JOIN   ISMSR.dbo.ProductLocalRpt D  on  C.MKTD_BRDCODE = D.SMARTSRCCode -- PM 상품 마스터
    Left JOIN [ISMSR].[dbo].[CustomerLocalRpt] E on B.pm_oltcode = E.CustomerCode -- PM소매점 마스터
where left(pdate, 6) = '202409'
and customerstatus = 'A' and CustomerTypeCode ='KA' 

;

select [Month],Chaincode, PMCode, SKU, Inventory_qty
from (
	select  *
	from TMP_POS.dbo.KA_Inventory_Monthlyclosing_240831 a
		join [ISMSR].[dbo].[CustomerLocalRpt] b on a.PMCode = b.CustomerCode 
	where customerstatus = 'A' and CustomerTypeCode ='KA' 
	) as tt
unpivot (Inventory_qty for SKU in (TOTAL, MFKSFT,MMEDFT,MBVTG,MLBGLD,MBTOUCH,MLBULT,MBGDULT,MBZGFU,MBZGDBL,MBZGMIX,MBHYB5,MBHYB1,MBTWIST,MBKSIBL,MBKSIB1,MBMTHFT,MWMTHFT,MLBSHUF,MLBVTS,MLBVTP,MLBVFM,MLBSSP,MLBBSM,MLBVGS,MBZADSS,MBFP,PLTKSB,PLTMLD,PLTHYB5,PLTHYB1,PLTRP,PLHYSS1,NPLHYSS1,PLTSSRD,PLTSSBL,PLTSSON,PLTSSCF,PLTDUAL,PLTFRS,PLTONE,PLTMBB,PLT03,PLTCAR5,PLTSPL,PLTTWIS,PLTDBW,VASLT,VASLTUL,VSONE,VASLTIN,VSRSVE,VSSS,VSSULT,VSSLTS,VSSSMTH,VSSONE,VSSCF4,VSSCF1,VSSSRFN,OASONE,OASMTH,LARKONE,LARKSS1,HGRLB20,HBLLB20,HAMLB20,HSVLB20,HPRLB20,HGRZG20,HGDLB20,HYLLB20,HBZLB20,HTQLB20,HSISE20,HSUBR20,HCDLB20,HNOOR20,HAMMI20,HYUGE20,HBLGR20,HBLPP20,HSAWA20,TEGREEN,TEBLUE,TEAMBER,TESILVE,TEPURWA,TEGRNZG,TESUMWA,TEYUGEN,TEBLKGR,TEBLKPU,TEBLKYL,TEOASPR,TESUNPR,TEABPL,TESTAPR,TERUSET,TETEAK) ) as unpivo
;

select *
from CMRRPT.dbo.Inventory_AGG2;



-- Availability 재고 현황 
-- KA 54,763
select count(*)
from TMP_POS.dbo.kA_Inventory_Monthlyclosing_240831

-- new inventory table 생성(월말 재고 통합 계산 테이블)
/*
create table
CMRRPT.dbo.Inventory_AGG2
(
	Month VARCHAR(20),
	PMCode VARCHAR(20),
	SKU VARCHAR(200),
	ENGNAME VARCHAR(200),
	Total_Inventory_Qty INT)
*/
 
-- insert
/*
with Inventory as (
	select [Month], PMCode, SKU, Inventory_qty
		from TMP_POS.dbo.KA_Inventory_Monthlyclosing_240831
	unpivot (Inventory_qty for SKU in (TOTAL, MFKSFT,MMEDFT,MBVTG,MLBGLD,MBTOUCH,MLBULT,MBGDULT,MBZGFU,MBZGDBL,MBZGMIX,MBHYB5,MBHYB1,MBTWIST,MBKSIBL,MBKSIB1,MBMTHFT,MWMTHFT,MLBSHUF,MLBVTS,MLBVTP,MLBVFM,MLBSSP,MLBBSM,MLBVGS,MBZADSS,MBFP,PLTKSB,PLTMLD,PLTHYB5,PLTHYB1,PLTRP,PLHYSS1,NPLHYSS1,PLTSSRD,PLTSSBL,PLTSSON,PLTSSCF,PLTDUAL,PLTFRS,PLTONE,PLTMBB,PLT03,PLTCAR5,PLTSPL,PLTTWIS,PLTDBW,VASLT,VASLTUL,VSONE,VASLTIN,VSRSVE,VSSS,VSSULT,VSSLTS,VSSSMTH,VSSONE,VSSCF4,VSSCF1,VSSSRFN,OASONE,OASMTH,LARKONE,LARKSS1,HGRLB20,HBLLB20,HAMLB20,HSVLB20,HPRLB20,HGRZG20,HGDLB20,HYLLB20,HBZLB20,HTQLB20,HSISE20,HSUBR20,HCDLB20,HNOOR20,HAMMI20,HYUGE20,HBLGR20,HBLPP20,HSAWA20,TEGREEN,TEBLUE,TEAMBER,TESILVE,TEPURWA,TEGRNZG,TESUMWA,TEYUGEN,TEBLKGR,TEBLKPU,TEBLKYL,TEOASPR,TESUNPR,TEABPL,TESTAPR,TERUSET,TETEAK) ) as unpivo
)
insert into
CMRRPT.dbo.Inventory_AGG2 (Month,PMCode, SKU, ENGNAME, Total_Inventory_Qty)
select a.Month, a.PMCode, a.SKU, b.ENGNAME, sum(try_cast(Inventory_qty as int)) as total_Inventory_qty
from  Inventory a
		join ISMSR.dbo.ProductLocalrpt b on a.SKU COLLATE KOREAN_WANSUNG_CS_AS_WS = b.Productcode COLLATE KOREAN_WANSUNG_CS_AS_WS
group by a.SKU, b.ENGNAME, a.Month, a.PMCode
*/
 
 
 
 
 
-- TAX 테이블 생성 (TAX 통합 계산 테이블)
/*
create table
CMRRPT.dbo.TAX_AGG
(
	Pdate VARCHAR(20),
	SalesQty BIGINT,
	OltCode VARCHAR(50),
	BrdCode VARCHAR(50),
	OltName VARCHAR(200),
	CustomerCode VARCHAR(100),
	ProductCode VARCHAR(100),
	ENGNAME VARCHAR(200),
	CIGATYPE VARCHAR(50),
	Company VARCHAR(200)
)
*/
 
 
-- Tax 테이블 데이터 추가 쿼리,	4,617,520
/*
insert into
CMRRPT.dbo.TAX_AGG(Pdate, SalesQty, OltCode, BrdCode, OltName, CustomerCode, ProductCode, ENGNAME, CIGATYPE, Company)
select A.Pdate, A.SalesQty, A.OltCode, A.BrdCode, B.OltName, B.CustomerCode, C.ProductCode, D.ENGNAME, D.CIGATYPE, D.Company
from KAPOS.dbo.POSTAXData	A
left join KAPOS.dbo.POSTAXCustomer	B on B.OltCode = A.OltCode
left join KAPOS.dbo.POSTAXProduct	C on A.BrdCode = C.BrdCode
left join ISMSR.dbo.ProductLocal	D on C.ProductCode = D.ProductCode
where left(Pdate, 6) = '202409'
group by A.Pdate, A.SalesQty, A.OltCode, A.BrdCode, B.OltName, B.CustomerCode, C.ProductCode, D.ENGNAME, D.CIGATYPE, D.Company
*/

/*
insert into
CMRRPT.dbo.TAX_AGG(Pdate, final_qty, OltCode, BrdCode, OltName, CustomerCode, ProductCode, ENGNAME, CIGATYPE, Company)
select Pdate, sum((try_cast(A.SalesQty as int)) * (try_cast(C.Qty as int))) as final_qty, A.OltCode, A.BrdCode, B.OltName, B.CustomerCode, C.ProductCode, D.ENGNAME, D.CIGATYPE, D.Company
from KAPOS.dbo.POSTAXData	A
left join KAPOS.dbo.POSTAXCustomer	B on B.OltCode = A.OltCode
left join KAPOS.dbo.POSTAXProduct	C on A.BrdCode = C.BrdCode
left join ISMSR.dbo.ProductLocal	D on C.ProductCode = D.ProductCode
where left(A.Pdate, 6) = '202409'
and (D.CIGATYPE = 'HNB' or D.CIGATYPE = 'CC')
and D.Company = 'PMK'
group by Pdate, A.OltCode, A.BrdCode, B.OltName, B.CustomerCode, C.ProductCode, D.ENGNAME, D.CIGATYPE, D.Company
*/

select *
from KAPOS.dbo.POSTAXData;

select * from KAPOS.dbo.POSTAXProduct;

select Load_Date, count(*)
from CMRRPT.dbo.OMNI_Tier_tmp 
group by Load_Date ;

--3000804	Welcome	20240903	99991231
	select CustomerCode, 
		[Dashboard Tier] , 
		Load_Date ,
		lead(Load_Date ) over (partition by CustomerCode order by Load_Date) as to_date
	from CMRRPT.dbo.OMNI_Tier_tmp 
order by Load_Date 


-- 2분 40초
-- 202408 Main 2,462,775
select top 100 *
from OMNI_Tier_tmp2 t
	join KAPOS.dbo.POS_DATA A --각 체인별 판매데이터 
		on A.PDATE BETWEEN t.Load_date and t.to_date
    left JOIN KAPOS.dbo.POS_OLT_MAP    B ON B.CHAIN_CODE = A.CHAIN_CODE AND B.CHAIN_OLTCODE = A.CHAIN_OLTCODE -- 각 체인 소매점 마스터
    left JOIN KAPOS.dbo.POS_BRD_MST    C ON C.CHAIN_CODE = A.CHAIN_CODE AND C.PROD_ID = A.PROD_ID -- 각 체인 상품 마스터
    left JOIN ISMSR.dbo.ProductLocalRpt D on C.MKTD_BRDCODE = D.SMARTSRCCode -- PM 상품 마스터
	LEFT JOIN [ISMSR].[dbo].[CustomerLocalRpt] E on B.pm_oltcode = E.CustomerCode 
where  B.pm_oltcode = t.CustomerCode
and D.engname in (
	'MARLBORO GOLD ORIGINAL',
	'PARLIAMENT AQUA 5',
	'MARLBORO RED',
	'Marlboro Vista Tropical Splash',
	'VS S. GOLD',
	'PARLIAMENT ONE',
	'PARLIAMENT HYBRID 5',
	'MARLBORO MEDIUM',
	'Marlboro Vista Forest Mist',
	'MARLBORO ICE BLAST',
	'MARLBORO ICE BLAST ONE',
	'PARLIAMENT AQUA 3',
	'MARLBORO WHITE FRESH',
	'MARLBORO SILVER',
	'Marlboro Vista Summer Splash',
	'HARMONY 1',
	'Marlboro Vista Blossom Mist',
	'Marlboro Vista Tropical Breeze',
	'Marlboro Vista Garden Splash'
)
--and left(A.PDATE, 6) = '202408';				-- 빠름
and A.PDATE between '20240801' and '20240831'; 	-- 느림


--update statistics  CMRRPT.dbo.POS_DATA_202408;
;
-- T1, T2, T3, T4 조합... Others 추가.. 
select b.*, a.*
from [ISMSR].[dbo].[CustomerLocalRpt] a
	left join OMNI_Tier_tmp b on a.CustomerCode = b.CustomerCode 
where CustomerTypeCode = 'KA' and CustomerStatus = 'A'
;

select *
from [ISMSR].[dbo].[CustomerLocalRpt] a
where CustomerTypeCode = 'KA' and CustomerStatus = 'A'

select top 100000 *
from OMNI_Tier_tmp2 t
	join CMRRPT.dbo.POS_DATA_202408 A --각 체인별 판매데이터 (임시)
		on A.PDATE BETWEEN t.Load_date and  t.to_date
    left JOIN KAPOS.dbo.POS_OLT_MAP    B ON B.CHAIN_CODE = A.CHAIN_CODE AND B.CHAIN_OLTCODE = A.CHAIN_OLTCODE -- 각 체인 소매점 마스터
    left JOIN KAPOS.dbo.POS_BRD_MST    C ON C.CHAIN_CODE = A.CHAIN_CODE AND C.PROD_ID = A.PROD_ID -- 각 체인 상품 마스터
    left JOIN ISMSR.dbo.ProductLocalRpt D on C.MKTD_BRDCODE = D.SMARTSRCCode -- PM 상품 마스터
	LEFT JOIN [ISMSR].[dbo].[CustomerLocalRpt] E on B.pm_oltcode = E.CustomerCode  and CustomerTypeCode = 'KA' and CustomerStatus = 'A'
where B.pm_oltcode = t.CustomerCode
and D.engname in (
	'MARLBORO GOLD ORIGINAL',
	'PARLIAMENT AQUA 5',
	'MARLBORO RED',
	'Marlboro Vista Tropical Splash',
	'VS S. GOLD',
	'PARLIAMENT ONE',
	'PARLIAMENT HYBRID 5',
	'MARLBORO MEDIUM',
	'Marlboro Vista Forest Mist',
	'MARLBORO ICE BLAST',
	'MARLBORO ICE BLAST ONE',
	'PARLIAMENT AQUA 3',
	'MARLBORO WHITE FRESH',
	'MARLBORO SILVER',
	'Marlboro Vista Summer Splash',
	'HARMONY 1',
	'Marlboro Vista Blossom Mist',
	'Marlboro Vista Tropical Breeze',
	'Marlboro Vista Garden Splash'
)
and a.pdate between '20240801' and '20240831'


select top 10 *
from OMNI_Tier_tmp2 t
	join CMRRPT.dbo.POS_DATA_2024 A --각 체인별 판매데이터 (임시)
		on A.PDATE BETWEEN t.Load_date and  t.to_date
    left JOIN KAPOS.dbo.POS_OLT_MAP    B ON B.CHAIN_CODE = A.CHAIN_CODE AND B.CHAIN_OLTCODE = A.CHAIN_OLTCODE -- 각 체인 소매점 마스터
    left JOIN KAPOS.dbo.POS_BRD_MST    C ON C.CHAIN_CODE = A.CHAIN_CODE AND C.PROD_ID = A.PROD_ID -- 각 체인 상품 마스터
    left JOIN ISMSR.dbo.ProductLocalRpt D on C.MKTD_BRDCODE = D.SMARTSRCCode -- PM 상품 마스터
	LEFT JOIN [ISMSR].[dbo].[CustomerLocalRpt] E on B.pm_oltcode = E.CustomerCode 
where  B.pm_oltcode = t.CustomerCode
and D.engname in (
	'MARLBORO GOLD ORIGINAL',
	'PARLIAMENT AQUA 5',
	'MARLBORO RED',
	'Marlboro Vista Tropical Splash',
	'VS S. GOLD',
	'PARLIAMENT ONE',
	'PARLIAMENT HYBRID 5',
	'MARLBORO MEDIUM',
	'Marlboro Vista Forest Mist',
	'MARLBORO ICE BLAST',
	'MARLBORO ICE BLAST ONE',
	'PARLIAMENT AQUA 3',
	'MARLBORO WHITE FRESH',
	'MARLBORO SILVER',
	'Marlboro Vista Summer Splash',
	'HARMONY 1',
	'Marlboro Vista Blossom Mist',
	'Marlboro Vista Tropical Breeze',
	'Marlboro Vista Garden Splash'
);




-- CustomerCode, [Dashboard Tier], PDATE ,engname, sal_qty

--3001488
--3001518



-- Insert Rows	87908760  202408
select * 
into CMRRPT.dbo.POS_DATA_2024
from KAPOS.dbo.POS_DATA
where left(PDATE , 6) = '202409';



-- POS 데이터 중복 확인
select  PDATE, CHAIN_CODE, CHAIN_OLTCODE, PROD_ID, count(*)
from CMRRPT.dbo.POS_DATA_202408
group by PDATE, CHAIN_CODE, CHAIN_OLTCODE, PROD_ID
having count(*) > 1
;


alter table OMNI_Tier_tmp add To_Date nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL;


drop trigger dbo.update_to_date ;


-- Tier 테이블에 To_date 생성하는 Trigger 생성
create trigger dbo.update_to_date on CMRRPT.dbo.OMNI_Tier_tmp2
after insert 
as
begin
		-- 기존 모든 행의 to_date를 삽입된 데이터의 load_date로 업데이트
		update a 
		set to_date = CONVERT(NVARCHAR(8), DATEADD(DAY, -1, i.Load_date), 112)
		from CMRRPT.dbo.OMNI_Tier_tmp2 a
			cross join inserted i
		where a.Load_date < i.Load_date 
		and a.to_date is null
		
		-- 새로 삽입된 행의 to_date는 NULL로 업데이트
		update a 
		set to_date = NULL
		from CMRRPT.dbo.OMNI_Tier_tmp2 a
			left join inserted i on a.CustomerCode = i.CustomerCode
		where a.Load_date = i.Load_date 
end;
/




select * 
from [ISMSR].[dbo].[CustomerLocalRpt];

