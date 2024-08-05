-- BPDA.cx.fct_K7_Monthly definition

-- Drop table

-- DROP TABLE BPDA.cx.fct_K7_Monthly;

CREATE TABLE BPDA.cx.fct_K7_Monthly (
	de_dt date NOT NULL,
	product_code varchar(255) COLLATE Korean_Wansung_CI_AS NOT NULL,
	id varchar(255) COLLATE Korean_Wansung_CI_AS NOT NULL,
	buy_ct int NULL,
	YYYYMM varchar(20) COLLATE Korean_Wansung_CI_AS NOT NULL,
	Pack_qty float NULL,
	gender varchar(20) COLLATE Korean_Wansung_CI_AS NULL,
	age varchar(20) COLLATE Korean_Wansung_CI_AS NULL,
	rct_seq varchar(100) COLLATE Korean_Wansung_CI_AS NOT NULL,
	CONSTRAINT pk_fct_k7_Monthly_id_product_code PRIMARY KEY (id,product_code,YYYYMM,rct_seq)
);
 

-- 1,089,136 rows
insert into cx.fct_K7_Monthly 
select 
	de_dt
	,product_code
	,id
	,buy_ct
	,left(de_dt, 6) YYYYMM
	,buy_ct * cast(SAL_QNT as float) Pack_qty
	,gender
	,age
	,rct_seq
from cx.K7_202406 a
	left join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and 4 < len(a.id) and b.CIGATYPE != 'CSV'
;


-- 담배제품 매핑안된 구매건수 0으로 pack_qty 업데이트
--Updated Rows	1604137
update cx.fct_K7_Monthly 
set Pack_qty = 0
where Pack_qty is null;




-- 월별 데이터 수량
select yyyymm, count(*)
from cx.fct_K7_Monthly
group by yyyymm;

--202107	701054
--202108	697627
--202109	649439
--202110	706325
--202111	713774
--202112	693568
--202201	657213
--202202	589719
--202203	709543
--202204	751698
--202205	819474
--202206	809461
--202207	837657
--202208	804864
--202209	790636
--202210	880463
--202211	859315
--202212	845229
--202301	835310
--202302	808160
--202303	958221
--202304	943080
--202305	1014279
--202306	1007127
--202307	1020240
--202308	1018149
--202309	1002879
--202310	1010444
--202311	960429
--202312	941254
--202401	946665
--202402	894483
--202403	1009427
--202404	1058451
--202405	1102170