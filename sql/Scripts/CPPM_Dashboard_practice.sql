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