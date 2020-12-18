SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('fgetSaleProfit') is not null
begin
  drop function fgetSaleProfit
end
go

create FUNCTION fgetSaleProfit(@CompanyID int, @BranchID int, @FromDate datetime, @ToDate datetime)
RETURNS @table table(
    OrderID int, 
    SaleProfit nvarchar(max)
)
AS
begin
    insert into @table
    select
        a.ID as OrderID,
        (select
            e.name + '(' + case c.type when 2 then '-' else '' end + convert(varchar(10), convert(int, d.ProfitPct * 100)) + '%), '
         from
            [order] s
            inner join TBL_ORDERPAYMENT_RELATIONSHIP b on b.OrderID = s.ID
            inner join PAYMENT c on c.ID = b.PaymentID
            inner join TBL_PROFIT d on d.MasterID = c.ID
            inner join ACCOUNT e on e.UserID = d.SlaveID
        where
            s.ID = a.ID
        for xml path('')) as SaleProfit
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
