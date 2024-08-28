DECLARE @StartDate DATE = '2010-01-01';
DECLARE @EndDate DATE = '2050-12-31';

WHILE @StartDate <= @EndDate
BEGIN
    
    select 
        @StartDate,
        format(YEAR(@StartDate) , '0000') AS  [year] ,
        FORMAT(MONTH(@StartDate), '00') as [month],
        FORMAT(day(@StartDate), '00') as [day],
        DATEPART(WEEKDAY, @StartDate) dayofweek,
        datename(weekday, @StartDate) dayName,
        DATEPART(week, @StartDate) weekofyear,
        '' weekofMonth,
        DATEADD(DAY, 2 - DATEPART(WEEKDAY, @StartDate), @StartDate) AS MondayOfMonth,
        DENSE_RANK() OVER (PARTITION BY YEAR(MondayOfMonth), MONTH(MondayOfMonth) ORDER BY MondayOfMonth) AS Week_Num
	;
    
    SET @StartDate = DATEADD(DAY, 1, @StartDate);
END;


 

-- 참고 : 기간 달력 넣는방법
WITH tmp AS ( 
SELECT idx=1, dt = cast('20090101' AS datetime) 
UNION ALL 
SELECT idx = idx + 1, dt = dateadd(d, 1, dt) 
FROM tmp 
WHERE dt < cast('20101231' AS datetime) 
) 
SELECT 
dt
, year = datepart(year, dt) 
, month = datepart(month, dt) 
, day = datepart(day, dt) 
, weekofyear = datepart(wk , dt)
, weekofmonth = datepart(wk, dt) - datepart(wk, left(convert(varchar, dt, 112), 6)+ '01') + 1
, 요일 = datename(w, dt) 
, 분기 = datepart(q, dt) 
, 반기 = case when datepart(month,dt) BETWEEN 1 AND 6 then '상반기' else '하반기' end 
FROM tmp 
OPTION (maxrecursion 0) 
;

-- Create Calendar
WITH tmp AS ( 
	SELECT idx=1, dt = cast('20210101' AS date) 
	UNION ALL 
	SELECT idx = idx + 1, dt = dateadd(d, 1, dt) 
	FROM tmp 
	WHERE dt < cast('20501231' AS date) 
) 
SELECT
        dt,
        format(YEAR(dt) , '0000') AS  [year] ,
        FORMAT(MONTH(dt), '00') as [month],
        FORMAT(day(dt), '00') as [day],
        DATEPART(WEEKDAY, dt) dayofweek,
        datename(weekday, dt) dayName,
        DATEPART(week, dt) weekofyear,
        weekofmonth = datepart(wk, dt) - datepart(wk, left(convert(varchar, dt, 112), 6)+ '01') + 1,
        DATEADD(DAY, 2 - DATEPART(WEEKDAY, dt), dt) AS MondayOfMonth,
        CONVERT(nvarchar(6), dt, 112) as YYYYMM,
        datepart(q, dt) as quarterly
INTO dbo.Dim_Calendar 
FROM tmp 
OPTION (maxrecursion 0)
;

-- 주차 수 넣기
WITH temp AS (
SELECT 
	[date],
	DENSE_RANK() OVER (PARTITION BY YEAR(MondayOfMonth), MONTH(MondayOfMonth) ORDER BY MondayOfMonth) AS Week_Num 
FROM Dim_Calendar 
)
update cx.Dim_Calendar 
SET week_num = temp.week_num
FROM temp
WHERE Dim_Calendar.[date] = temp.[date]
;


SELECT * FROM cx.Dim_Calendar ;