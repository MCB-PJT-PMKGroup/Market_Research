   select  *
   from
       cu.Fct_BGFR_PMI_Monthly a
       join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
   where id ='00c32f336e2adf6f183ff4e5fc60d62f212c8528fde3fa57a8635ffec2eca7e3'
  order by seq;
   
  
  202403	41	00c32f336e2adf6f183ff4e5fc60d62f212c8528fde3fa57a8635ffec2eca7e3	1	4	0000088021492	8.0	8.0	24583373	경기도
202403	11	00c32f336e2adf6f183ff4e5fc60d62f212c8528fde3fa57a8635ffec2eca7e3	1	4	0000088021492	5.0	5.0	24114715	서울특별시
;

   select  *
   from
       cu.Fct_BGFR_PMI_Monthly a
       join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
   where id ='00c32f336e2adf6f183ff4e5fc60d62f212c8528fde3fa57a8635ffec2eca7e3';
  
  
    select  YYYYMM  ,SIDO_NM, id,  seq, row_number() over (partition by id order by seq) rn  
   from
       cu.Fct_BGFR_PMI_Monthly a
       join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
   where id ='00c32f336e2adf6f183ff4e5fc60d62f212c8528fde3fa57a8635ffec2eca7e3'
   and b.ProductSubFamilyCode = 'TEREA'  
   group by YYYYMM , SIDO_NM, a.id, seq;
  
  
with temp as( 
select * 
from ( 
   select  YYYYMM  , id, max(seq) seq, row_number() over (partition by id order by YYYYMM) rn  
   from
       cu.Fct_BGFR_PMI_Monthly a
       join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
   where id ='00c32f336e2adf6f183ff4e5fc60d62f212c8528fde3fa57a8635ffec2eca7e3'
   and b.ProductSubFamilyCode = 'TEREA'  
   group by YYYYMM , a.id
) as t
where rn = 1
)
select t.YYYYMM, max(case when t.seq = a.seq then a.SIDO_NM end) SIDO_NM, t.id
from temp t
	join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id  and  a.YYYYMM = t.YYYYMM
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
where t.YYYYMM >= '202401'
and
   exists (
       -- (2) 직전 3개월 동안 구매이력이 있는지 확인
       select 1
       from cu.Fct_BGFR_PMI_Monthly x
       	join cu.dim_product_master y on x.ITEM_CD = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' and y.cigatype != 'CSV'
       where
           x.YYYYMM between convert(nvarchar(6), dateadd(month, -3, a.YYYYMM + '01'), 112)
           				and convert(nvarchar(6), dateadd(month, -1, a.YYYYMM + '01'), 112)
           and a.id = x.id
   )
group by t.YYYYMM, t.id 
having
       count(distinct b.engname) < 11 -- (3) SKU 11종 미만
   and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만
;
