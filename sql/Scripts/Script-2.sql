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


