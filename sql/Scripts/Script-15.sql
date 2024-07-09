CREATE TABLE BPDA.cx.fct_Lpoint_K7_Monthly (
	de_dt varchar(20) COLLATE Korean_Wansung_CI_AS NULL,
	YYYYMM varchar(20) COLLATE Korean_Wansung_CI_AS NULL,
	product_code varchar(255) COLLATE Korean_Wansung_CI_AS NULL,
	id varchar(255) COLLATE Korean_Wansung_CI_AS NULL,
	gender varchar(20) COLLATE Korean_Wansung_CI_AS NULL,
	age varchar(20) COLLATE Korean_Wansung_CI_AS NULL,
	buy_ct int NULL,
	Pack_qty float NULL
);

fct_Lpoint_K7_Monthly

select 
	de_dt,
	format(de_dt, 'yyyyMM') as YYYYMM,
	product_code,	
	id,
	gender,
	age,
	buy_ct,
	buy_ct * cast(b.SAL_QNT as float) as pack_qty
from cx.K7_202307 a
	left join cx.product_master_temp b on a.product_code = b.PROD_ID;


-- 로만을 피우는 사람 중에 다른 제품 피우는지 확인
select * 
from cx.fct_K7_Monthly a
		join cx.product_master_temp b on a.product_code = b.PROD_ID 
where a.id in (
	select id
	from cx.fct_K7_Monthly a
		join cx.product_master_temp b on a.product_code = b.PROD_ID 
	where b.ProductFamilyCode ='ROTHMANS'
)
-- 35E30AEC60C47A9C1C6A48F8D217AAB4936443FF475809E761C2399FEF39ABDF
-- 466E8FC3207A9B983C6A28F5B3FFEB06731C454431AB7FF11F5A0287F06CBB2A


select * 
from cx.fct_K7_Monthly a
		join cx.product_master_temp b on a.product_code = b.PROD_ID 
where a.id in (
select id
	from cx.fct_K7_Monthly a
		join cx.product_master_temp b on a.product_code = b.PROD_ID 
	where b.ProductFamilyCode ='SEVENSTAR'
	and left(YYYYMM, 4) in ('2022', '2023') 
);

select left(YYYYMM, 4)
	from cx.fct_K7_Monthly fkm ;


select ENGNAME, sum(qty)
from (
	select b.ENGNAME , a.buy_ct * a.Pack_qty as qty
	from cx.fct_K7_Monthly a
		join cx.product_master_temp b on a.product_code = b.PROD_ID 
	where ProductFamilyCode = 'ESSE'
	and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
	and left(YYYYMM, 4) in ('2022', '2023') 
) as t
group by ENGNAME;


