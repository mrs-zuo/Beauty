SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('fgetServeProfit') is not null
begin
  drop function fgetServeProfit
end
go

create FUNCTION fgetServeProfit(@CompanyID int, @BranchID int, @FromDate datetime, @ToDate datetime)
RETURNS @table table(
    OrderID int, 
    ServeProfit nvarchar(max)
)
AS
begin
    insert into @table
    select
        a.ID as OrderID,
        (select
            s4.Name + ', '
         from
            TBL_TREATGROUP s2
            inner join TREATMENT s3 on s3.GroupNo = s2.GroupNo and s3.Available = 1
            inner join ACCOUNT s4 on s4.UserID = s3.ExecutorID
         where s2.OrderID = a.ID
           and s2.DeleteFlag = 1
           and s3.Status in (2, 5) 
         for xml path('')
        ) as ServeProfit
    from
        [order] a
    where a.CompanyID = @CompanyID
      and (@BranchID = 0 or a.BranchID = @BranchID)
      and a.CreateTime >= @FromDate
      and a.CreateTime <= @ToDate
      and a.RecordType = 1
    group by a.ID
    return
end
