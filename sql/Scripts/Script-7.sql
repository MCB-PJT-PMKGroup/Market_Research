select 
	YM_CD , 
	count(distinct CUST_ID) 
from cu.Fct_BGFR_PMI_Monthly
where PACK_QTY >= 10
group by YM_CD ;


--202301	221522
--202302	209457
--202303	186302
--202304	178950
--202305	255516
--202306	257488
--202307	265164
--202308	268179
--202309	261610
--202310	261246
--202311	248504
--202312	243568
--202401	241655
--202402	228091
--202403	253830
--202404	262789
--202405	272882



ALTER TABLE BPDA.cx.fct_K7_Monthly ALTER COLUMN id varchar(255) COLLATE Korean_Wansung_CI_AS NOT NULL;
alter table cx.fct_K7_Monthly add pk_id int identity(1,1) primary key;
create index ix_fct_K7_Monthly_id on cx.fct_K7_Monthly  (id);
create index ix_fct_K7_Monthly_product_code on cx.fct_K7_Monthly  (product_code) include(id, YYYYMM);


--E0E687FE4B199A01B31CA709271D0DC05742B7B2DA96D6006FE66B0AC1442BDA, 202405, 8801116000937
-- (DD8E51EEBEA09D8B179799BA0D6F6947C28D4AB796CECCCFC7C086746ED22A90, 20220104, 88023205)

select id,de_dt,product_code, count(*)
from cx.fct_K7_Monthly 
group by id,de_dt,product_code
having count(*) > 1;

alter table cu.Fct_BGFR_PMI_Monthly add pk_id int identity(1,1) primary key;
create index ix_Fct_BGFR_PMI_Monthly_cust_id on cu.Fct_BGFR_PMI_Monthly  (cust_id);

