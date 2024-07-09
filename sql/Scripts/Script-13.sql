select * from ;

update cx.fct_K7_Monthly
set Pack_qty = cast(b.SAL_QNT as float)
from cx.fct_K7_Monthly a 
	left join cx.product_master_temp b on a.product_code = b.PROD_ID ;
	

--	alter table cx.fct_K7_Monthly add gender varchar(20) COLLATE Korean_Wansung_CI_AS NULL;
--	alter table cx.fct_K7_Monthly add  age varchar(20) COLLATE Korean_Wansung_CI_AS NULL;

select * 
from cx.fct_K7_Monthly fkm 
where product_code  in (
	select prod_id 
	from cx.product_master_temp
	where SAL_QNT = '10'
);

-- 1,521,590건 매핑이 안됨 ... 제품id가 없음
select count(*) 
from cx.fct_K7_Monthly
where Pack_qty is null;