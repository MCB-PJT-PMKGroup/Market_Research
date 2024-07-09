-- Switching In/Out 작업 - 모수 집계
WITH Purchases AS (
    SELECT 
        a.id, 
        b.engname, 
        SUM(CASE WHEN a.YYYYMM = '202402' THEN cast(b.SAL_QNT as float) * a.buy_ct ELSE 0 END) AS Feb_Quantity,
        SUM(CASE WHEN a.YYYYMM = '202403' THEN cast(b.SAL_QNT as float) * a.buy_ct ELSE 0 END) AS March_Quantity
    FROM 
        cx.fct_K7_Monthly a
        JOIN cx.product_master_temp b ON a.product_code = b.PROD_ID
    WHERE   b.ENGNAME != 'Cleaning Stick' 
	    AND b.cigatype != 'CSV' 
	    AND 4 < LEN(a.id)
	    AND a.YYYYMM IN ('202402', '202403') 
	    --AND b.engname = 'Marlboro Vista Blossom Mist'
    GROUP BY 
        a.id, b.engname
)
SELECT 
    id,
    engname,
    Feb_Quantity,
    March_Quantity,
    CASE
        WHEN Feb_Quantity > 0 AND March_Quantity = 0 THEN 'Out'
        WHEN Feb_Quantity = 0 AND March_Quantity > 0 THEN 'In'
        ELSE 'No Switch'
    END AS SwitchStatus
--INTO cx.fct_CC_Switch_monthly
FROM Purchases
;




-- 업그레이드 Ver2.0 2월, 3월에 해당하는 In/Out 모수
SELECT 
    a.id,
    a.engname,
    SUM(CASE WHEN a.YYYYMM = '202402' THEN 1 ELSE 0 END) AS 'Out',
    SUM(CASE WHEN a.YYYYMM = '202403' THEN 1 ELSE 0 END) AS 'In'
--into cx.fct_CC_Switch_monthly
FROM 
    cx.fct_CC_purchases_monthly a
where 1=1
    AND a.YYYYMM IN ('202402', '202403')
    --AND a.engname = 'Marlboro Vista Blossom Mist'
GROUP BY 
    a.engname, a.id
HAVING 
    -- "in" 상태: 3월에는 구매하고 2월에는 다른 제품을 구매한 경우
    (SUM(CASE WHEN a.YYYYMM = '202403' THEN 1 ELSE 0 END) > 0
    AND SUM(CASE WHEN a.YYYYMM = '202402' THEN 1 ELSE 0 END) = 0
    AND EXISTS (
        -- 2월에 구매한 이력이 있는 경우
        SELECT 1
        FROM cx.fct_CC_purchases_monthly c
        where a.id = c.id
        and c.YYYYMM = '202402'
        AND c.engname != a.engname
        )
	)
    OR
    -- "out" 상태: 2월에는 구매하고 3월에는 다른 제품을 구매한 경우
    (SUM(CASE WHEN a.YYYYMM = '202402' THEN 1 ELSE 0 END) > 0
    AND SUM(CASE WHEN a.YYYYMM = '202403' THEN 1 ELSE 0 END) = 0
    AND EXISTS (
    	-- 3월에 구매한 이력이 있는 경우
        SELECT 1
        FROM cx.fct_CC_purchases_monthly c
        where a.id = c.id
        and c.YYYYMM = '202403'
        AND c.engname != a.engname
    ));

-- Switching In/Out Count
--select CIGATYPE, New_Flavorseg, New_TARSEGMENTAT,    
--	SUM(a.Purchaser_cnt) AS total_purchaser_cnt, 
--    SUM(a.In_cnt) AS total_in, 
--    SUM(a.Out_cnt) AS total_out 
--from (
--	select b.engname, a.SwitchStatus, b.CIGATYPE, b.New_Flavorseg, b.New_TARSEGMENTAT, 
--		count(distinct a.id) as Purchaser_cnt, 
--		case 
--			when SwitchStatus ='In' then count(distinct a.id) 
--		end as In_cnt,
--		case 
--			when SwitchStatus ='Out' then count(distinct a.id) 
--		end as Out_cnt
--	from 
--		cx.fct_CC_Switch_monthly a
--		join cx.fct_CC_purchases_monthly b on a.id = b.id and a.SwitchStatus != 'No Switch' and b.YYYYMM in ('202402', '202403')	
--  where b.ENGNAME != 'Marlboro Vista Blossom Mist'
--	group by b.engname, a.SwitchStatus, b.CIGATYPE, b.New_Flavorseg, b.New_TARSEGMENTAT
--) as a
--group by CIGATYPE, New_Flavorseg, New_TARSEGMENTAT
--;

-- SKU 별 제품 구매량 집계
-- id, In/Out으로 'Marlboro Vista Blossom Mist'외에 다른 제품 구매자 파악
select engname,
    SUM(a.Out_cnt) AS Out_Quantity,
    SUM(a.In_cnt) AS In_Quantity
from (
	select b.engname, 
		--count( a.id) as Purchaser_cnt, 
		case 
			when b.YYYYMM = '202403' and a.[Out] > 0 then sum(b.quantity) 
		end as Out_cnt,
		case 
			when b.YYYYMM = '202402' and a.[In] > 0 then sum(b.quantity) 
		end as In_cnt
	from 
		cx.fct_CC_Switch_monthly a
			join cx.fct_CC_purchases_monthly b on a.id = b.id  and b.YYYYMM in ('202402', '202403') and a.engname = 'Marlboro Vista Blossom Mist'
	where b.ENGNAME != a.engname
	group by b.engname, b.YYYYMM, a.[In], a.[Out]
	) as a
group by engname
;

-- CC x Tar x Taste x Thickness 별 제품 구매량 집계
-- 2월 3월 사이에 Marlboro Vista Blossom Mist 구매한 사용자가 다른 제품들을 구매한 이력
select  CIGATYPE, New_Flavorseg, New_TARSEGMENTAT, THICKSEG,
		concat(CIGATYPE, ' ', New_Flavorseg, ' ', New_TARSEGMENTAT, ' ', THICKSEG) as Pack_seg,
	    SUM(Out_cnt) AS Out_Quantity,     
		SUM(In_cnt) AS In_Quantity
from (	
	select b.CIGATYPE, b.New_Flavorseg, b.New_TARSEGMENTAT, b.THICKSEG,
		--count(distinct a.id) as Purchaser_cnt, 
		case 
			when b.YYYYMM = '202403' and a.[Out] > 0 then sum(b.quantity) 
		end as Out_cnt,
		case 
			when b.YYYYMM = '202402' and a.[In] > 0 then sum(b.quantity) 
		end as In_cnt
	from 
		cx.fct_CC_Switch_monthly a
			join cx.fct_CC_purchases_monthly b on a.id = b.id and b.YYYYMM in ('202402', '202403') and a.engname = 'Marlboro Vista Blossom Mist'
	where b.ENGNAME != a.engname
	group by  b.CIGATYPE, b.New_Flavorseg, b.New_TARSEGMENTAT, b.THICKSEG, b.YYYYMM, a.[In], a.[Out]
	) as t
group by CIGATYPE, New_Flavorseg, New_TARSEGMENTAT, THICKSEG
;

select distinct THICKSEG from cx.product_master_temp ;
where New_FLAVORSEG ='New Taste' and New_TARSEGMENTAT ='1MG' and THICKSEG ='SSL';

-- 데이터 확인 
select * from cx.fct_CC_purchases_monthly
where 1=1 --engname ='DUNHILL 1MG'
and YYYYMM in ('202402', '202403')
and id ='09A3E60F8C223F496CF96629B49BF122090EE309C4010297F370362B97DC76F8'
;
--202402	MIIX ICE DOUBLE	HnB	FS8: Fresh to New Taste	New Taste			09A3E60F8C223F496CF96629B49BF122090EE309C4010297F370362B97DC76F8	1.0
--202403	MIIX MIX	HnB	FS4: Regular to New Taste	New Taste			09A3E60F8C223F496CF96629B49BF122090EE309C4010297F370362B97DC76F8	1.0
--202403	MIIX ICE DOUBLE	HnB	FS8: Fresh to New Taste	New Taste			09A3E60F8C223F496CF96629B49BF122090EE309C4010297F370362B97DC76F8	7.0
--202402	Marlboro Vista Blossom Mist	CC	FS9: NTD (Fresh to NTD)	New Taste	TS4: 1MG	1MG	09A3E60F8C223F496CF96629B49BF122090EE309C4010297F370362B97DC76F8	1.0

