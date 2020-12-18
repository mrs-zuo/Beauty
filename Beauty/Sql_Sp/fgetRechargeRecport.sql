SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('fgetRechargeRecport') is not null
begin
  drop function fgetRechargeRecport
end
go

create FUNCTION fgetRechargeRecport(@CompanyID int, @BranchID int, @FromDate datetime, @ToDate datetime)
RETURNS @table table(
        BranchName nvarchar(30), 
        CustomerName nvarchar(30),
        PhoneNumber varchar(20),
        UserCardNo varchar(16),
        ActionMode nvarchar(20),
        Amount money,
        Balance money,
        InputStaffName nvarchar(30),
        InputTime varchar(19),
        CardRechargeProfit nvarchar(max)
    )
AS
begin
    insert into @table
    select 
        b.BranchName,
        c.Name as CustomerName,
        f.PhoneNumber,
        a.UserCardNo,
        dbo.strMoneyActionMode(a.ActionMode) as ActionMode,
        a.Amount,
        a.Balance,
        e.Name as InputStaffName,
        convert(varchar(19), a.CreateTime, 120) as InputTime,
        left(d.CardRechargeProfit, len(d.CardRechargeProfit) - 1) as CardRechargeProfit
    from 
        TBL_MONEY_BALANCE a
        inner join BRANCH b on b.ID = a.BranchID
        inner join CUSTOMER c on c.UserID = a.UserID
        left join fgetCardRechargeProfit(@CompanyID, @BranchID, @FromDate, @ToDate) d on d.CustomerBalanceID = a.CustomerBalanceID
        left join ACCOUNT e on e.UserID = a.CreatorID
        left join (select UserID, max(PhoneNumber) as PhoneNumber from PHONE group by UserID) f on f.UserID = a.UserID
    where a.CompanyID = @CompanyID
      and (@BranchID = 0 or a.BranchID = @BranchID)
      and a.CreateTime >= @FromDate
      and a.CreateTime <= @ToDate
      and a.ActionMode in (3, 4, 5, 6, 7, 8, 9, 10)
    return
end
go
