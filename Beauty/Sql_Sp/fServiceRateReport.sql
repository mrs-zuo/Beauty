SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('fServiceRateReport') is not null
begin
  drop function fServiceRateReport
end
go

create FUNCTION fServiceRateReport(@CompanyID int, @BranchID int, @BeginDate datetime, @EndDate datetime)
RETURNS @table table(
    BranchName nvarchar(30), 
    ServiceName nvarchar(30), 
    Satisfaction int, 
    StaffName nvarchar(30), 
    CustomerName nvarchar(30), 
    CustomerTel varchar(20), 
    RateDate varchar(10))
AS
begin
    insert into @table
    select
        g.BranchName as BranchName,
        i.ServiceName,
        a.Satisfaction,
        e.Name as StaffName,
        b.Name as CustomerName,
        isnull(c.CustomerTel, '') as CustomerTel,
        convert(varchar(10), a.CreateTime, 120) as RateDate
    from 
        TBL_TREATMENT_REVIEW a
        inner join CUSTOMER b on b.UserID = a.CreatorID
        left join (select UserID, max(PhoneNumber) as CustomerTel from phone group by UserID) c on c.UserID = b.UserID
        inner join TREATMENT d on d.ID = a.TreatmentID
        left join ACCOUNT e on e.UserID = d.ExecutorID
        left join BRANCH g on g.ID = d.BranchID
        inner join TBL_TREATGROUP h on h.GroupNo = d.GroupNo
        inner join TBL_ORDER_SERVICE i on i.ID = h.OrderServiceID
    where 
        d.CompanyID = @CompanyID
    and (@BranchID = 0 or d.BranchID = @BranchID)
    and a.CreateTime >= @BeginDate
    and a.CreateTime <= @EndDate
    return
end
go