with temp as (
	-- (1) 23년 9월 부터 구매자가 월별 구매이력
	select a.YYYYMM, a.id
	from  cu.Fct_BGFR_PMI_Monthly a 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
	where a.YYYYMM >= '202406'
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
	   and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만
)
select t.YYYYMM,  COALESCE(gr_cd, '합계') 'Gr Region',
	count(distinct t.id) 'HnB Total',
	count(distinct case when ProductSubFamilyCode ='TEREA' then t.id end) 'TEREA',
	count(distinct case when ProductSubFamilyCode ='MIIX' then t.id end) 'MIIX'
from temp t
  	join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id and t.YYYYMM = a.YYYYMM
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE = 'CIGARETTES' and cigatype = 'HnB'
	join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
where t.YYYYMM >= '202401'
--and t.id ='003e54a35c1ffbc50c2bce638da7fc74f1aed60b44e6385b9b88427ca7fcdea5'
group by 
	grouping sets (
	(t.YYYYMM, c.gr_cd), 
	(t.YYYYMM) 
	)
order by YYYYMM, 'Gr Region'
;



with temp as (
	-- (1) 23년 9월 부터 구매자가 월별 구매이력
	select a.YYYYMM, a.id ,max(seq) seq
	from  cu.Fct_BGFR_PMI_Monthly a 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.cigatype = 'HnB'
	where a.YYYYMM >= '202406'
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
	   and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만
)
select t.YYYYMM,  COALESCE(gr_cd, '합계') 'Gr Region',
	count(distinct t.id) 'HnB Total'
from temp t
  	join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id and t.seq = a.seq 
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE = 'CIGARETTES' and cigatype != 'CSV'
	join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
where t.YYYYMM >= '202406'
group by 
	grouping sets (
	(t.YYYYMM, c.gr_cd), 
	(t.YYYYMM) 
	)
order by YYYYMM, 'Gr Region'
;


select * from cu.v_user_3month_list ;

with temp as (
	-- (1) 23년 9월 부터 구매자가 월별 구매이력
	select a.YYYYMM, a.id, max(seq) seq
	from  cu.Fct_BGFR_PMI_Monthly a 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.cigatype = 'HnB'
			and b.ProductSubFamilyCode ='TEREA'
	where a.YYYYMM >= '202406'
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
	   and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만
)
select t.YYYYMM,  COALESCE(gr_cd, '합계') 'Gr Region',
	count(distinct t.id) 'HnB Total'
from temp t
  	join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id and t.seq = a.seq 
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE = 'CIGARETTES' and cigatype != 'CSV'
	join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
where t.YYYYMM >= '202406'
group by 
	grouping sets (
	(t.YYYYMM, c.gr_cd), 
	(t.YYYYMM) 
	)
order by YYYYMM, 'Gr Region'
;


select * from cu.Fct_BGFR_PMI_Monthly 
where id = '0597dce6e08bc35a213a51eae012d6df94ed0695ea5769658921c1646570c32a';

--drop view cu.v_user_3month_list

select * from  cu.v_user_3month_list;



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
   and sum(a.Pack_qty) < 61.0 -- (3) 구매 팩 수량 61개 미만
;

-- 905,797
-- HnB 127,037
-- CC 778,760
select count(a.id)
from cu.v_user_3month_list a
	join cu.Fct_BGFR_PMI_Monthly b on a.id = b.id and a.seq = b.seq
	join cu.dim_product_master c on b.ITEM_CD = c.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype = 'CC'
where a.YYYYMM = '202406';



select 
	t.YYYYMM, 
	a.SIDO_NM,
	t.id,
	a.gender,
	a.age
from cu.v_user_3month_list t
	join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id and t.YYYYMM = a.YYYYMM and  t.seq = a.seq
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
where t.YYYYMM ='202406'
;





with temp as (
	select
		t.YYYYMM, 
		a.SIDO_NM,
		t.id
	from cu.v_user_3month_list t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id and t.YYYYMM = a.YYYYMM and  t.seq = a.seq
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and b.CIGADEVICE = 'CIGARETTES' and b.cigatype != 'CSV'
	where t.YYYYMM = '202406'
),
TEREA_Purchaser as (
	select t.YYYYMM, t.SIDO_NM, t.id,
		    CASE 
		        WHEN SUM(CASE WHEN b.cigatype = 'CC' THEN 1 ELSE 0 END) > 0 
		         AND SUM(CASE WHEN b.cigatype = 'HnB' THEN 1 ELSE 0 END) > 0 
		        THEN 'Mixed' 
		        ELSE MAX(b.cigatype)  -- CC 또는 HnB가 없을 경우 가장 큰 값을 사용
	    	END AS cigatype
	 from temp t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id and t.YYYYMM = a.YYYYMM 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
	group by t.YYYYMM, t.SIDO_NM, t.id
)
select *
from TEREA_Purchaser t
	join cu.dim_Regional_area c on t.SIDO_NM = c.sido_nm
where gr_cd = '광주'
;


select *
from cu.Fct_BGFR_PMI_Monthly a
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
where id = '0439d9b6ab436931a31677cbbcc81bb21f76604578cceee65bf677f5bb055395'
and YYYYMM >= '202406'
;



with temp as(   
	select
		t.YYYYMM, 
		gr_cd,
		t.id,
		sum(case when b.cigatype='HnB' and b.company = 'PMK' then a.SALE_QTY end) IQOS_Purchased,
		sum(case when b.cigatype='CC' then a.SALE_QTY end) CC_Purchased,
		sum(case when b.cigatype='HnB' and b.company = 'PMK' then a.SALE_QTY end) + sum(case when b.cigatype='CC' then a.SALE_QTY end) CompHnB_Purchased,
		sum(case when b.cigatype='HnB' and b.company = 'PMK' then a.SALE_QTY end) / (sum(case when b.cigatype='HnB' and b.company = 'PMK' then a.SALE_QTY end) + sum(case when b.cigatype='CC' then a.SALE_QTY end)) *100 iqos_per,
		sum(case when b.cigatype='CC' then a.SALE_QTY end) / (sum(case when b.cigatype='HnB' and b.company = 'PMK' then a.SALE_QTY end) + sum(case when b.cigatype='CC' then a.SALE_QTY end)) *100 cc_per
	from  cu.agg_CU_TEREA_Total_Sourcing t
		join cu.Fct_BGFR_PMI_Monthly a on t.id = a.id 
			and a.YYYYMM = t.YYYYMM
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' 
		join cu.dim_Regional_area c on t.SIDO_nm = c.sido_nm
	where t.YYYYMM >= '202406'
	group BY 	    	
		t.YYYYMM, 
		gr_cd,
		t.id
	having  sum(case when b.cigatype='HnB' and b.company = 'PMK' then a.SALE_QTY end) > 0
		and sum(case when b.cigatype='CC' then a.SALE_QTY end)  > 0
)
select YYYYMM, gr_cd, avg(iqos_per) iqos_per, avg(cc_per) cc_per, avg(IQOS_Purchased) IQOS_Purchased_ratio, avg(CC_Purchased) CC_Purchased_ratio
from temp 
group by YYYYMM, gr_cd

;

select  t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct t.id) Tobacco_Purchaser 
from ( 
	select t.YYYYMM, t.id, a.SIDO_NM , gr_cd, row_number() over(partition by t.YYYYMM, t.id order by a.seq desc) rn
	from cu.v_user_3month_list t
		join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype ='HnB'
			and ProductSubFamilyCode ='MIIX'
		join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
	where  t.YYYYMM >= '202401'
) as t
where rn = 1
group by 
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM)
	)
;


select t.YYYYMM, COALESCE(gr_cd, '합계')  'Gr Region',
	count(distinct t.id) Tobacco_Purchaser
from cu.v_user_3month_list t
	join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype ='HnB'
		and ProductSubFamilyCode ='MIIX'
	join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
where  t.YYYYMM >= '202401'
group by 
	grouping sets ( 
		(t.YYYYMM, gr_cd),
		(t.YYYYMM)
	)
;

--31219748
select * from cu.Fct_BGFR_PMI_Monthly 
where id ='004432a5c036aaa5ff9b2a451e99877bcc3788d6e087c5271a9171426ed3ab07';
select * from cu.v_user_3month_list 
where id ='004432a5c036aaa5ff9b2a451e99877bcc3788d6e087c5271a9171426ed3ab07';
	;
	
select *
from cu.v_user_3month_list t
	join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM
	join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype ='HnB'
		and productSubFamilyCode = 'TEREA'
	join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
where  t.YYYYMM >= '202406'



	select t.YYYYMM, t.id, a.SIDO_NM , gr_cd, b.ProductSubFamilyCode, row_number() over(partition by t.YYYYMM, t.id order by a.seq desc) rn
	from cu.v_user_3month_list t
		join cu.Fct_BGFR_PMI_Monthly a on a.id = t.id and t.YYYYMM  = a.YYYYMM 
		join cu.dim_product_master b on a.ITEM_CD = b.PROD_ID  and CIGADEVICE = 'CIGARETTES' and cigatype = 'HnB'
			and ProductSubFamilyCode  = 'TEREA'
		join cu.dim_Regional_area c on a.SIDO_nm = c.sido_nm
	where  t.YYYYMM = '202406';