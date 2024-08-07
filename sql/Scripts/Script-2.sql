select * 
from cx.fct_K7_Monthly
--where gender is null or age is null;

-- id, yyyymm, gender, age
select id, 
	left(de_dt, 6) as yyyymm ,
	gender, age
from cx.K7_202307;




update cx.fct_K7_Monthly 
set gender = a.gender , age = a.age
from cx.K7_230718 a
	join cx.fct_K7_Monthly b on a.id = b.id and b.yyyymm = left(a.de_dt,6) ;


--202107 ~ 202306 Updated Rows	19083236
--202307 Updated Rows	1020240
--202308 Updated Rows	1018149
--202309 Updated Rows	10028 79
--202310 Updated Rows	1010444
--202311 Updated Rows	960429
--202312 Updated Rows	941230
--202401 Updated Rows	946645
--202402 Updated Rows	894483
--202403 Updated Rows	1009427
--202404 Updated Rows	1058451
--202405 Updated Rows	1102170



01A360EAC742624C2E602438237E284B4ED81582369C21B35C1261A473D07908
01B79EC0053E657CBBA0EDD87E564ED3D49C375E9CC4B25680B372A461F5A1BD
01BD0F0CC80C8143AE4BB815CF4418847BC40596864EB5AACAC1EF135F6E9335
;
-- 문제 있었던 데이터 2022, 2023년 둘다 제품 사용.. 제외해야할 필요성
select *
FROM 
    cx.fct_K7_Monthly a
    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
where 1=1
   	and left(a.YYYYMM, 4) = '2022'
    AND b.ProductFamilyCode = 'MLB' and b.New_TARSEGMENTAT = 'LTS'
    and a.id ='0001C49BD0D710003D72A45445C486342FDAB6E19711D9AD1AEDE159BAEEF5D2';
    
    

select * 
from  cx.fct_K7_Monthly x
	    join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
where x.id ='2F32E9AB03B9C9D3D9DC59A7BF76CC4506F491DDCE046B097D2A785D484AB021'
order by de_dt desc 
;

select * from cx.agg_PLT_CC_Switch3
where id ='3276DDDA96AB8A24974DACBE5C79931B1116820054E784D0B0F42A5DD7212F3F';

select *
from 
	cx.agg_MLB_LTS_Switch2 t
		join cx.fct_K7_Monthly a on a.id = t.id AND 4 < LEN(a.id) and left(a.YYYYMM, 4) in ('2022', '2023') and a.product_code not in( t.product_code)
		join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE = 'CIGARETTES' AND b.cigatype != 'CSV' 
		--and b.ProductFamilyCode != t.ProductFamilyCode and b.New_TARSEGMENTAT != t.New_TARSEGMENTAT
group by rollup(b.cigatype, b.New_FLAVORSEG, b.New_TARSEGMENTAT);

select id , count(*) ttt
from  cx.agg_MLB_LTS_Switch2
group by id 
having count(*) >1
order by  count(*) DESC 
;

select * 
FROM 
	cx.fct_K7_Monthly a
    	join cx.product_master b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV'
where 1=1
   	and left(a.YYYYMM, 4) in ('2022', '2023')
GROUP BY 
	b.FLAVORSEG_type3, b.cigatype, left(a.YYYYMM, 4)
;















