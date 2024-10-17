

--TRUNCATE table CMRRPT.dbo.OMNI_Tier_tmp ;

select *
from CMRRPT.dbo.OMNI_Tier_tmp a
	join inserted i on a.CustomerCode = i.CustomerCode
where a.Load_date = i.Load_date
;



CREATE TABLE CMRRPT.dbo.OMNI_Tier_tmp2 (
	CustomerCode varchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	[Dashboard Tier] varchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	Load_Date nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL,
	To_Date nvarchar(50) COLLATE Korean_Wansung_CI_AS NULL
);


select max(a.Load_Date ), min(a.Load_date)
from CMRRPT.dbo.OMNI_Tier_tmp2 a
where 1=1
and a.to_date is null;

--20240621
--delete 
from CMRRPT.dbo.OMNI_Tier_tmp2
where load_date is null;


select *
FROM CMRRPT.dbo.OMNI_Tier_tmp
where Load_Date = '20240926';



select *
from CMRRPT.dbo.POS_DATA_2024 
where PDATE < '20240831';





