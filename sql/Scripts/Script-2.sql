--ALTER TABLE cx.product_master_temp ALTER COLUMN PROD_ID VARCHAR(255);

--create table cx.fct_K7_Monthly(
--	de_dt varchar(20) COLLATE Korean_Wansung_CI_AS NULL,
--	product_code varchar(255) COLLATE Korean_Wansung_CI_AS NULL,
--	id varchar(255) COLLATE Korean_Wansung_CI_AS NULL,
--	buy_ct int NULL,
--	YYYYMM varchar(20) COLLATE Korean_Wansung_CI_AS NULL
--)
--;
--create index ix_fct_K7_Monthly_YYYYMM on cx.fct_K7_Monthly(YYYYMM);

select * from cx.fct_K7_Monthly;


