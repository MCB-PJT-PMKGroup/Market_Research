
create view cx.v_user_3month_list as
select a.YYYYMM,  a.id
from  cx.fct_K7_Monthly a 
	join cx.product_master b on a.product_code = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
where a.YYYYMM >= '202111'
and
   exists (
       -- (2) 직전 3개월 동안 구매이력이 있는지 확인
       select 1
       from cx.fct_K7_Monthly x
       	join cx.product_master y on x.product_code = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' and y.cigatype != 'CSV'
       where
           x.YYYYMM between convert(nvarchar(6), dateadd(month, -3, a.YYYYMM + '01'), 112)
           				and convert(nvarchar(6), dateadd(month, -1, a.YYYYMM + '01'), 112)
       and a.id = x.id
       group by x.YYYYMM, x.id
	       	   having
	       count(distinct y.engname) < 11 -- (3) SKU 11종 미만
	       and sum(x.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만
   )
group by a.YYYYMM, a.id
having
       count(distinct b.engname) < 11 -- (3) SKU 11종 미만
   and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만
