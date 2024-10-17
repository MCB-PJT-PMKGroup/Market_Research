--체인 상품 마스터 KAPOS.dbo.POS_BRD_MST  =연계 ismsr.dbo.Prodrctlocalrpt
-- 체인 소매점 마스터 KAPOS.dbo.POS_OLT_MAP    

-- POS 데이터 
Select  top 10 *
FROM KAPOS.dbo.POS_DATA A --각 체인별 판매데이터 :
    left JOIN KAPOS.dbo.POS_OLT_MAP    B ON B.CHAIN_CODE = A.CHAIN_CODE AND B.CHAIN_OLTCODE = A.CHAIN_OLTCODE -- 각 체인 소매점 마스터
    left JOIN KAPOS.dbo.POS_BRD_MST    C ON C.CHAIN_CODE = A.CHAIN_CODE AND C.PROD_ID = A.PROD_ID -- 각 체인 상품 마스터
    left JOIN ISMSR.dbo.ProductLocalRpt D  on  C.MKTD_BRDCODE = D.SMARTSRCCode -- PM 상품 마스터
    Left JOIN [ISMSR].[dbo].[CustomerLocalRpt] E on B.pm_oltcode = E.CustomerCode -- PM소매점 마스터
    left join [CMRRPT].[dbo].[Corner_meta_working] F on E.customercode =  F.custcode and A.pdate = F.pdate -- 코너샵 운영일 데이터(R/C구분자)
where d.CIGADEVICE = 'CIGARETTES'
and d.CIGATYPE != 'CSV'
and d.Company = 'PMK'
and e.customerstatus = 'A' and e.CustomerTypeCode ='KA' 
--and a.PDATE between '20240901' and '20240930'
--and left(a.PDATE, 6) = '202409'
;


-- Communication 작업 
select event_id             ,
              office_desc          ,
              ev_date                    ,
              place_name           ,
              cast( CONCAT(ev_start_time , ':00') as time) as event_start_time,
              cast( CONCAT(ev_end_time , ':00') as time) as ev_end_time , 
              datediff(MINUTE, cast( CONCAT(ev_start_time , ':00') as time),  cast( CONCAT(ev_end_time , ':00') as time))   as ev_duration_minute ,
              attd_office_code     ,
              attd_office_desc     ,
              attd_position ,
              attd_zone_code       ,
              attd_employee ,
              attd_contri
--into #temp_event_participant 
from [TMP_POS].[PMI\JKo].[data_IEEMS_GSE_PARTICPANT]
;


-- Tier 분류
select [Dashboard Tier] , count(*)
from cmrrpt.dbo.OMNI_Tier
group by [Dashboard Tier] ;

-- Hero, Welcome, Welcome+


select * , format(GETDATE() , 'yyyyMMdd') as Load_Date
into cmrrpt.dbo.OMNI_Tier_tmp
from cmrrpt.dbo.OMNI_Tier;


declare @tbname nvarchar(100);

select @tbname = TABLE_NAME 
from information_schema.tables
where TABLE_CATALOG ='TMP_POS'
and TABLE_NAME like 'KA_Inventory_Monthlyclosing_%'
and limit 1
order by table_name desc;


select *
from KAPOS.dbo.POS_BRD_MST
where use_yn = 'Y'; --chain_code 

select *
from ismsr.dbo.ProductLocalRpt
where CIGADEVICE ='CIGARETTES'
and CIGATYPE != 'CSV';




SELECT TOP 10 * 
FROM ISMSRRP.DBO.LocalDCE_Coupon; --KA에서 사용하는 쿠폰(프로모션) 데이터

-- 51,214
select top 100 *
from KAPOS.dbo.POSTAXData A --KA 소매점 발주자료
	left join KAPOS.dbo.POSTAXCustomer  B on B.OltCode = A.OltCode  --KA 소매점 발주 마스터 84,205
	left join [KAPOS].[dbo].[POSTAXProduct] C on A.BrdCode = C.BrdCode  --KA 제품 발주 발주자료 1,805
WHERE LEFT(A.Pdate, 6) = '202409'
;



-- ALL 253690869
-- 202406 4277567
select count(*)
from KAPOS.dbo.POSTAXData 
where left(Pdate, 6) = '202406'
;


-- Channel, ChnnelDetail, Pdate, CustomerCode, ProductCode, Qty
select top 10 * 
from dbo.COTProgram
where Qty > 0;


-- 19분...ㅠㅠ
with temp as ( 
	select *, '20240801' StartDate, '20240830' EndDate
	from cmrrpt.dbo.OMNI_Tier
)
select top 10 * -- max([Dashboard Tier]) 
from KAPOS.dbo.POS_DATA a
	left JOIN KAPOS.dbo.POS_OLT_MAP B ON B.CHAIN_CODE = a.CHAIN_CODE AND B.CHAIN_OLTCODE = a.CHAIN_OLTCODE 
	join temp C on left(a.PDATE, 6) = left(C.StartDate, 6) and C.CustomerCode = B.PM_OLTCODE 
where left(a.Pdate, 6) = '202408'
;


Select  top 10 *  -- chain_code, chain_oltcode, prod_id, Total_Inventory_Qty
FROM KAPOS.dbo.POS_DATA A --각 체인별 판매데이터 :
    left JOIN KAPOS.dbo.POS_OLT_MAP    B ON B.CHAIN_CODE = A.CHAIN_CODE AND B.CHAIN_OLTCODE = A.CHAIN_OLTCODE -- 각 체인 소매점 마스터
    left JOIN KAPOS.dbo.POS_BRD_MST    C ON C.CHAIN_CODE = A.CHAIN_CODE AND C.PROD_ID = A.PROD_ID -- 각 체인 상품 마스터
    left JOIN ISMSR.dbo.ProductLocalRpt D  on  C.MKTD_BRDCODE = D.SMARTSRCCode -- PM 상품 마스터
    Left JOIN [ISMSR].[dbo].[CustomerLocalRpt] E on B.pm_oltcode = E.CustomerCode -- PM소매점 마스터
--    left join [CMRRPT].[dbo].[Corner_meta_working] F on E.customercode =  F.custcode and A.pdate = F.pdate -- 코너샵 운영일 데이터(R/C구분자)
    left join CMRRPT.dbo.Inventory_AGG2 g on g.PMCode = e.CustomerCode and d.ENGNAME = g.engname and eomonth(cast([Month] +'01' as date)) = a.PDATE -- Inventory 날짜
    left join cmrrpt.dbo.OMNI_Tier_tmp h on h.CustomerCode = e.CustomerCode and a.PDATE <= h.Load_Date 
where d.CIGADEVICE = 'CIGARETTES'
and d.CIGATYPE != 'CSV'
and d.Company = 'PMK'
and e.customerstatus = 'A' and e.CustomerTypeCode ='KA' 
and [Month] is not null
;



select * --count(distinct CustomerCode)
from [ISMSR].[dbo].[CustomerLocalRpt] a 
where CustomerTypeCode ='KA' ;-- IndustryClassificationLevelCode
;


-- 58,721 Total
select count(*)
from [ISMSR].[dbo].[CustomerLocalRpt]
where customerstatus = 'A' and CustomerTypeCode = 'KA'
;


select  * --count( distinct PMCode) 
from TMP_POS.dbo.KA_Inventory_Monthlyclosing_240831 a
	join [ISMSR].[dbo].[CustomerLocalRpt] b on a.PMCode = b.CustomerCode 
where customerstatus = 'A' and CustomerTypeCode ='KA';


select * 
from TAX_AGG ta 
;

 
-- 52,190
-- Inventory
with Inventory as (
	select [Month], PMCode, SKU, Inventory_qty
	from (
		select  *
		from TMP_POS.dbo.KA_Inventory_Monthlyclosing_240831 a
			join [ISMSR].[dbo].[CustomerLocalRpt] b on a.PMCode = b.CustomerCode 
		where customerstatus = 'A' and CustomerTypeCode ='KA' 
		) as tt
	unpivot (Inventory_qty for SKU in (TOTAL, MFKSFT,MMEDFT,MBVTG,MLBGLD,MBTOUCH,MLBULT,MBGDULT,MBZGFU,MBZGDBL,MBZGMIX,MBHYB5,MBHYB1,MBTWIST,MBKSIBL,MBKSIB1,MBMTHFT,MWMTHFT,MLBSHUF,MLBVTS,MLBVTP,MLBVFM,MLBSSP,MLBBSM,MLBVGS,MBZADSS,MBFP,PLTKSB,PLTMLD,PLTHYB5,PLTHYB1,PLTRP,PLHYSS1,NPLHYSS1,PLTSSRD,PLTSSBL,PLTSSON,PLTSSCF,PLTDUAL,PLTFRS,PLTONE,PLTMBB,PLT03,PLTCAR5,PLTSPL,PLTTWIS,PLTDBW,VASLT,VASLTUL,VSONE,VASLTIN,VSRSVE,VSSS,VSSULT,VSSLTS,VSSSMTH,VSSONE,VSSCF4,VSSCF1,VSSSRFN,OASONE,OASMTH,LARKONE,LARKSS1,HGRLB20,HBLLB20,HAMLB20,HSVLB20,HPRLB20,HGRZG20,HGDLB20,HYLLB20,HBZLB20,HTQLB20,HSISE20,HSUBR20,HCDLB20,HNOOR20,HAMMI20,HYUGE20,HBLGR20,HBLPP20,HSAWA20,TEGREEN,TEBLUE,TEAMBER,TESILVE,TEPURWA,TEGRNZG,TESUMWA,TEYUGEN,TEBLKGR,TEBLKPU,TEBLKYL,TEOASPR,TESUNPR,TEABPL,TESTAPR,TERUSET,TETEAK) ) as unpivo
),
TAX as (
	select left(Pdate, 6) YYYYMM, b.oltCode, ProductCode, SalesQty
	from KAPOS.dbo.POSTAXData a --KA 소매점 발주자료
	left join KAPOS.dbo.POSTAXCustomer  b on b.OltCode = a.OltCode  --KA 소매점 발주 마스터
	left join [KAPOS].[dbo].[POSTAXProduct] c on a.BrdCode = c.BrdCode  --KA 제품 발주 발주자료
	where left(a.Pdate, 6) = '202409'
)
select [Month], PMCode, SKU, Inventory_qty , SalesQty --, POS --case when cnt = 0 then 'Y' else 'N' end as Target
from Inventory a
	left join KAPOS.dbo.POS_OLT_MAP b on a.PMCode = b.PM_OLTCODE 
	join TAX c on b.CHAIN_OLTCODE = c.OltCode and a.SKU = c.ProductCode


-- TAX 
select left(Pdate, 6) YYYYMM, a.oltCode, c.ProductCode, a.SalesQty
from KAPOS.dbo.POSTAXData a --KA 소매점 발주자료
left join KAPOS.dbo.POSTAXCustomer  b on b.OltCode = a.OltCode  --KA 소매점 발주 마스터
left join [KAPOS].[dbo].[POSTAXProduct] c on a.BrdCode = c.BrdCode  --KA 제품 발주 발주자료
where left(a.Pdate, 6) = '202408';


-- POS
Select top 10 *
FROM KAPOS.dbo.POS_DATA A --각 체인별 판매데이터
    left JOIN KAPOS.dbo.POS_OLT_MAP    B ON B.CHAIN_CODE = A.CHAIN_CODE AND B.CHAIN_OLTCODE = A.CHAIN_OLTCODE -- 각 체인 소매점 마스터
    left JOIN KAPOS.dbo.POS_BRD_MST    C ON C.CHAIN_CODE = A.CHAIN_CODE AND C.PROD_ID = A.PROD_ID -- 각 체인 상품 마스터
    left JOIN   ISMSR.dbo.ProductLocalRpt D  on  C.MKTD_BRDCODE = D.SMARTSRCCode -- PM 상품 마스터
    Left JOIN [ISMSR].[dbo].[CustomerLocalRpt] E on B.pm_oltcode = E.CustomerCode -- PM소매점 마스터
where left(pdate, 6) = '202409'    
and customerstatus = 'A' and CustomerTypeCode ='KA' 





