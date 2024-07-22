-- Arber Pearl Sourcing 기본 가공
-- 88023540	TEREA ARBOR PEARL	테리아 아버 펄	IQOS	CIGARETTES	HnB	FS4: Regular to New Taste
-- Launch Date : 202403

-- 직전 1개월, 3개월 계산
select YYYYMM, 
	cast(yyyymm - 3 AS varchar)  TT, 	-- 이렇게 하면 안됨!
	CAST(YYYYMM+'01' AS DATE) yyyymm2,  
	CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, YYYYMM+'01'), 112) con_date,
	CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, YYYYMM+'01'), 112) con_date2,
	YYYYMM - 4 -- 숫자형으로 변환.
from cx.fct_K7_Monthly 
where YYYYMM='202403';
--cast(a.yyyymm - 3 AS VARCHAR) AND cast(a.yyyymm - 1 AS VARCHAR)


-- 2024년 3월 SKU 11개 이하, qty_sum < 61.0
-- 608 rows
with temp as (
	select 
		id,
		count(distinct engname) SKU_Cnt,
		sum(buy_ct * Pack_qty) Pack_Sum
--	into cx.test_arber_pearl
	FROM
		 cx.fct_K7_Monthly a
		    join cx.product_master_temp b on a.product_code = b.PROD_ID and CIGADEVICE =  'CIGARETTES' AND  cigatype != 'CSV' AND 4 < LEN(id)
	where 1=1
	and exists (
		-- 직전 3개월 동안 구매이력이 최소 1건인 사용자만 대상
		select 1 
		from cx.fct_K7_Monthly x
	    	join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
		where x.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, a.YYYYMM+'01'), 112)
						   AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, a.YYYYMM+'01'), 112) 
		and a.id = x.id
		group by x.id, x.YYYYMM
		having count(distinct y.engname) < 11 and sum(x.buy_ct * x.Pack_qty) < 61.0
	)
	and a.YYYYMM='202403'
	group by Id
	having (count(distinct b.engname) < 11 and sum(buy_ct * Pack_qty) < 61.0 )
)
select *
--into cx.test_arber_pearl
from temp
where id in ( 
	select id 
	FROM
		 cx.fct_K7_Monthly x
		    join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id) 
    and x.YYYYMM ='202403'
    and y.engname  ='TEREA ARBOR PEARL'
);
;


  SELECT
        a.id,
        COUNT(DISTINCT b.engname) AS SKU_Cnt,
        SUM(a.buy_ct * a.Pack_qty) AS Pack_Sum
    FROM cx.fct_K7_Monthly a
    JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
        AND b.CIGADEVICE = 'CIGARETTES'
        AND b.cigatype != 'CSV'
        AND LEN(a.id) > 4
    WHERE a.YYYYMM = '202403'
        AND b.engname = 'TEREA ARBOR PEARL'
        AND EXISTS (
            SELECT 1
            FROM cx.fct_K7_Monthly x
            JOIN cx.product_master_temp y ON x.product_code = y.PROD_ID
                AND y.CIGADEVICE = 'CIGARETTES'
                AND y.cigatype != 'CSV'
                AND LEN(x.id) > 4
            WHERE x.id = a.id
                AND x.YYYYMM BETWEEN CONVERT(NVARCHAR(6), DATEADD(MONTH, -3, CAST(a.YYYYMM+'01' AS DATE)), 112)
                                AND CONVERT(NVARCHAR(6), DATEADD(MONTH, -1, CAST(a.YYYYMM+'01' AS DATE)), 112)
            GROUP BY x.id, x.YYYYMM
            HAVING COUNT(DISTINCT y.engname) < 11 AND SUM(x.buy_ct * x.Pack_qty) < 61.0
        )
    GROUP BY a.id
    HAVING COUNT(DISTINCT b.engname) < 11 AND SUM(a.buy_ct * a.Pack_qty) < 61.0;
   



-- 데이터 검증
select 
	x.id, x.YYYYMM,
	count(distinct y.engname) SKU_Cnt,
	sum(x.buy_ct * x.Pack_qty) Pack_Sum
FROM
	 cx.fct_K7_Monthly x
	    join cx.product_master_temp y on x.product_code = y.PROD_ID and y.CIGADEVICE =  'CIGARETTES' AND  y.cigatype != 'CSV' AND 4 < LEN(x.id)
where x.YYYYMM BETWEEN '202312' and '202403'
and id ='47CA196EFC6AD4FCE0814574775ABFE15777F636E03D467F0D1FB247037D5475'
group by x.Id, x.YYYYMM
having (count(distinct y.engname) >= 11 or sum(x.buy_ct * x.Pack_qty) >= 61.0 )
;

--문제 있음
select id, YYYYMM,
	count(distinct b.engname) SKU_Cnt,
	sum(a.buy_ct * a.Pack_qty) Pack_Sum
FROM 
    cx.fct_K7_Monthly a
    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
where a.YYYYMM  BETWEEN '202312' and '202403'
--and b.ENGNAME != 'TEREA ARBOR PEARL'
and a.id ='F32F2FBC991E06D5936993DE32FBD745C3340A1710F608BA4EBCE3D4A7849B6E'
group by id, YYYYMM;
--2F32E9AB03B9C9D3D9DC59A7BF76CC4506F491DDCE046B097D2A785D484AB021
--7D8C197A63D8ED281275E98BEAB1BFF5A321C04EE8E083529FC4F36B52A62ECF
-- '8CAF3FCD132DE021AABCEE5D3F51E60C0128AFA05E50CEC9E39EF0F43CF6776C'


-- 617... 왜 계속..
with temp as(
	select id, a.yyyymm,
		count(distinct b.engname) SKU_Cnt,
		sum(a.buy_ct * a.Pack_qty) Pack_Sum
	FROM 
	    cx.fct_K7_Monthly a
	    	join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
	where 
		-- 직전 3개월 동안 구매이력이 최소 1건인 사용자만 대상
		 a.YYYYMM BETWEEN '202312' AND '202402'
	group by id, a.yyyymm
	having count(distinct b.engname) < 11 and sum(a.buy_ct * a.Pack_qty) < 61.0 
)
select distinct t.id
FROM 
	temp t
    join cx.fct_K7_Monthly a on a.id = t.id and t.yyyymm < a.yyyymm
    join cx.product_master_temp b on a.product_code = b.PROD_ID and b.CIGADEVICE =  'CIGARETTES' AND  b.cigatype != 'CSV' AND 4 < LEN(a.id)
where a.YYYYMM = '202403'
and b.ENGNAME ='TEREA ARBOR PEARL';

--87F4D3E853657A52372A879D49B5975A541DB474B69B6BF7A71EB2A8D4B586C5
--6D057883854965C2C37D994F1F71E66E49D43F1644B7A0FB1D23582A18BB646C
--D8B3A6E671869EC99EBE98917E807DF48D6CAC2D8D8C1185CCB4D3165D3B4815
--8CAF3FCD132DE021AABCEE5D3F51E60C0128AFA05E50CEC9E39EF0F43CF6776C
--6AA3652D4C31BBA4F9CFA11B9FFCCE30B244283A2DBF4D39B799DB0839E6810A
--7D8C197A63D8ED281275E98BEAB1BFF5A321C04EE8E083529FC4F36B52A62ECF
--A529479CDFE04E3EFEA4057B708710E19024E5F9A0B7D4FBB43EAA6095DCA8E6
--B24F259F1A8E286C7031B7AA1DFB2D6C687C376B0B5DC40EA90DB80545F4D634
--775FC7F68610091C6F456695D778669B5022506BFB356D1995832CDD45E50CE0
