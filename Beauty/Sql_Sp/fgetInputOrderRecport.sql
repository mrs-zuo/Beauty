SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('fgetInputOrderRecport') is not null
begin
  drop function fgetInputOrderRecport
end
go

create FUNCTION fgetInputOrderRecport(@CompanyID int, @BranchID int, @FromDate datetime, @ToDate datetime)
RETURNS @table table(
        BranchName nvarchar(30), 
        CustomerName nvarchar(30),
        PhoneNumber varchar(20),
        ServiceName nvarchar(30),
        OrderStatus nvarchar(10),
        PaymentStatus nvarchar(10),
        TotalSalePrice money,
        InputStaffName nvarchar(30),
        InputTime varchar(20),
        SaleProfit nvarchar(max),
        ServeProfit nvarchar(max)
    )
AS
begin
    insert into @table
    select 
        d.BranchName,
        e.Name as CustomerName,
        f.PhoneNumber,
        b.ServiceName,
        dbo.strOrderStatus(a.Status) as OrderStatus,
        dbo.strPaymentStatus(a.PaymentStatus) as PaymentStatus,
        a.TotalSalePrice,
        g.Name as InputStaffName,
        convert(varchar(20), a.CreateTime, 120) as InputTime,
        h.SaleProfit,
        i.ServeProfit
    from 
        [order] a
        inner join (
            select OrderID, ServiceName from TBL_ORDER_SERVICE
            union
            select OrderID, CommodityName as ServiceName from TBL_ORDER_COMMODITY
        ) b on b.OrderID = a.ID
        inner join BRANCH d on d.ID = a.BranchID
        inner join CUSTOMER e on e.UserID = a.CustomerID
        left join (select UserID, max(PhoneNumber) as PhoneNumber from PHONE group by UserID) f on f.UserID = e.UserID
        inner join ACCOUNT g on g.UserID = a.CreatorID
        left join fgetSaleProfit(@CompanyID, @BranchID, @FromDate, @ToDate) h on h.OrderID = a.ID
        left join fgetServeProfit(@CompanyID, @BranchID, @FromDate, @ToDate) i on i.OrderID = a.ID
    where
        a.CompanyID = @CompanyID
    and (@BranchID = 0 or a.BranchID = @BranchID)
    and a.CreateTime >= isnull(@FromDate, getdate())
    and a.CreateTime <= isnull(@ToDate, getdate())
    and a.RecordType = 1
    return
end
go