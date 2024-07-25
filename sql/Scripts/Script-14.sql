select YM_CD ,count(*), count(distinct cust_id) Purchaser_count
from cu.Fct_BGFR_PMI_Monthly a
	left join cu.product_master b on a.ITEM_CD = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.CIGATYPE != 'CSV'
where b.PROD_ID is null
and ym_cd = '202303'
group by YM_CD;


select YM_CD ,count(*), count(distinct cust_id) Purchaser_count
from cu.Fct_BGFR_PMI_Monthly a
	join cu.product_master b on a.ITEM_CD = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.CIGATYPE != 'CSV'
group by YM_CD;

select distinct a.item_cd
from cu.Fct_BGFR_PMI_Monthly a
	left join cu.product_master b on a.ITEM_CD = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.CIGATYPE != 'CSV'
where b.PROD_ID is null
;

select count(*)
from cu.BGFR_PMI_202303;

select * from cu.product_master
where prod_id in (
select a.item_cd
from cu.Fct_BGFR_PMI_Monthly a
	left join cu.product_master b on a.ITEM_CD = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.CIGATYPE != 'CSV'
where b.PROD_ID is null
);