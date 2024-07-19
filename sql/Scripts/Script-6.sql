--2023년 1월~ 별 담배 및 담배 주변기기 구매 회원수, 구매 횟수
select 
	a.YYYYMM, 
	count(distinct id) as purchaser_cnt,
	count(id) Purchase_cnt,
	sum(a.buy_ct * a.Pack_qty) as pack_qty
from cx.fct_K7_Monthly a
	join cx.product_master_temp b on a.product_code = b.PROD_ID and 4 < len(a.id) and b.CIGATYPE != 'CSV'
where left(a.YYYYMM, 4) = '2023'
group by a.YYYYMM
;

	;
select distinct CIGADEVICE, CIGATYPE 
from cx.product_master_temp 
;

--Demographics ( Base: 2023년 전체 구매자 기준)  - consumable기준
select 
	a.age, 
	count(distinct a.id) as purchaser_cnt,
	count(distinct case when b.CIGATYPE ='CC' then a.id end) as CC_purchaser_cnt,
	count(distinct case when b.CIGATYPE ='HnB' then a.id end) as HnB_purchaser_cnt,
	count(id) Purchase_cnt,
	sum(a.buy_ct * a.Pack_qty) as pack_qty
from cx.fct_K7_Monthly a
	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and 4 < len(a.id) and b.CIGATYPE != 'CSV'
where left(a.YYYYMM, 4) = '2023'
group by a.age
;

select * 
from cx.fct_K7_Monthly 
where 4 > len(id);
