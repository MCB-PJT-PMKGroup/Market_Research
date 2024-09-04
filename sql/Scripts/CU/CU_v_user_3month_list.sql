-- cu.v_user_3month_list source

create view cu.v_user_3month_list as
select a.YYYYMM, a.id, max(seq) seq
from  cu.Fct_BGFR_PMI_Monthly a 
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
where a.YYYYMM >= '202211'
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
       group by x.YYYYMM, x.id
	   having count(distinct y.engname) < 11 and sum(x.Pack_qty) < 61.0 -- (3) 구매 SKU 11종 미만 & 팩 수량 61개 미만
   )
group by a.YYYYMM, a.id 
having
       count(distinct b.engname) < 11 -- (3) SKU 11종 미만
   and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만;



-- New Purchaser (Sourcing Base)
-- seq을 이용해서 마지막 구매지역을 신규 구매로 인식
select * 
from ( 
	select t.YYYYMM, t.id, SIDO_NM ,
		row_number() over(partition by t.YYYYMM, t.id  order by a.seq desc) rn 
	from  cu.v_user_3month_list  t 
	   join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and a.YYYYMM = t.YYYYMM
	   join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
	where 
		not exists (
			select 1
		      from cu.Fct_BGFR_PMI_Monthly x
		   		join cu.dim_product_master y on x.ITEM_CD = y.PROD_ID and y.CIGADEVICE = 'CIGARETTES' and y.cigatype != 'CSV'
			where
		       x.YYYYMM < t.YYYYMM			-- 이전에 구매이력이 있으면 안됨. 최초 구매 월만
			and t.id = x.id
			and y.ProductSubFamilyCode = b.ProductSubFamilyCode   
		)
--	and b.ProductSubFamilyCode in ('NEO', 'NEOSTICKS')
) as t
where rn = 1