SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('fgetCardRechargeProfit') is not null
begin
  drop function fgetCardRechargeProfit
end
go

create FUNCTION fgetCardRechargeProfit(@CompanyID int, @BranchID int, @FromDate datetime, @ToDate datetime)
RETURNS @table table(
    CustomerBalanceID int, 
    CardRechargeProfit nvarchar(max)
)
AS
begin
    insert into @table
    select
        a.CustomerBalanceID,
        (select
            e.name + '(' + convert(varchar(10), convert(int, d.ProfitPct * 100)) + '%), '
         from
            TBL_MONEY_BALANCE s
            inner join TBL_PROFIT d on d.MasterID = s.CustomerBalanceID
            inner join ACCOUNT e on e.UserID = d.SlaveID
        where
            s.CustomerBalanceID = a.CustomerBalanceID
        group by e.Name, d.ProfitPct
        for xml path('')) as CardRechargeProfit
    from
        TBL_MONEY_BALANCE a
    where a.CompanyID = @CompanyID
      and (@BranchID = 0 or a.BranchID = @BranchID)
      and a.CreateTime >= @FromDate
      and a.CreateTime <= @ToDate
    group by a.CustomerBalanceID
    return
end
