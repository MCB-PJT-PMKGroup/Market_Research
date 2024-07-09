-- 2월 3월 사이에 Marlboro Vista Blossom Mist 구매한 사용자가 다른 제품들을 구매한 이력
-- CC x Tar x Taste x Thickness 별 제품 구매량 집계
select  a.CIGATYPE, a.New_Flavorseg, a.New_TARSEGMENTAT, a.THICKSEG,
	    SUM(a.Out_cnt) AS Out_Quantity,     
		SUM(a.In_cnt) AS In_Quantity
from (	
	select  b.CIGATYPE, b.New_Flavorseg, b.New_TARSEGMENTAT, b.THICKSEG,
		--count( a.id) as Purchaser_cnt, 
		case 
			when b.YYYYMM = '202403' and  a.[Out] > 0 then sum(b.quantity) 
		end as Out_cnt,
		case 
			when b.YYYYMM = '202402' and a.[In] > 0 then sum(b.quantity) 
		end as In_cnt
	from 
		cx.fct_CC_Switch_monthly a
		join cx.fct_CC_purchases_monthly b on a.id = b.id and b.YYYYMM in ('202402', '202403') and a.engname = 'Marlboro Vista Blossom Mist'
	where b.ENGNAME != a.engname
	group by  b.CIGATYPE, b.New_Flavorseg, b.New_TARSEGMENTAT, b.THICKSEG, b.YYYYMM, a.[In], a.[Out]
	) as a
group by  a.CIGATYPE, a.New_Flavorseg, a.New_TARSEGMENTAT, a.THICKSEG
;


--alter table cx.fct_CC_purchases_monthly add THICKSEG varchar(5);

select * 
from cx.fct_CC_purchases_monthly;

select * from cx.k7_202403
where h_cate != '담배';


--create index ix_dim_CU_master_PROD_ID on cu.dim_CU_master (PROD_ID);

--DROP TABLE BPDA.cu.Fct_BGFR_PMI_Monthly;



CREATE TABLE cu.Fct_BGFR_PMI_Monthly (
	YM_CD varchar(20) COLLATE Korean_Wansung_CI_AS NULL,
	SIDO_CD tinyint NULL,
	CUST_ID nvarchar(100) COLLATE Korean_Wansung_CI_AS NULL,
	GENDER_CD tinyint NULL,
	AGE_CD tinyint NULL,
	ITEM_CD varchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	SALE_QTY float NULL,
	PACK_QTY float NULL
);

--insert into cu.Fct_BGFR_PMI_Monthly 
--	(YYYYMM
--	,SIDO_CD
--	,CUST_ID
--	,GENDER_CD
--	,AGE_CD
--	,ITEM_CD
--	,SALE_QTY
--	,PACK_QTY
--	)
--select YM_CD
--,SIDO_CD
--,CUST_ID
--,GENDER_CD
--,AGE_CD
--,ITEM_CD
--,SALE_QTY
--, round(a.SALE_QTY * b.SAL_QNT, 2)  PACK_QTY
--from cu.BGFR_PMI_202301 a
--	left join cu.dim_CU_master b on a.ITEM_CD = b.PROD_ID ;

--create index ix_Fct_BGFR_PMI_Monthly_YYYYMM on cu.Fct_BGFR_PMI_Monthly (YYYYMM);
--create index ix_Fct_BGFR_PMI_Monthly_ITEM_CD on cu.Fct_BGFR_PMI_Monthly (ITEM_CD);


update cu.Fct_BGFR_PMI_Monthly
set PACK_QTY = a.SALE_QTY * b.SAL_QNT 
from cu.Fct_BGFR_PMI_Monthly a
	left join cu.dim_CU_master b on a.ITEM_CD = b.PROD_ID  
;

