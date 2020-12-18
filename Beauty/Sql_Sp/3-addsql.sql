if object_id('VORDER','v') is not null
begin
  drop view VORDER
end
go

create view VORDER as
  --view
  select
    A.ID as OrderID,
    H.ID as BranchID,
    H.CompanyID,
    A.CustomerID,
    A.OrderTime,
    A.RecordType,
    A.PaymentStatus,
    A.ProductType,
    B.ServiceCode as Code,
    B.ServiceName as Name,
    B.Quantity,
    B.TGTotalCount,
    B.Status,
    B.SumSalePrice,
    H.StartTime,
    0 as flag
  from
    [ORDER] A
    inner join [TBL_ORDER_SERVICE] B on B.OrderID = A.ID
    inner join [BRANCH] H on H.ID = A.BranchID

  union all
    select
    A.ID as OrderID,
    H.ID as BranchID,
    H.CompanyID,
    A.CustomerID,
    A.OrderTime,
    A.RecordType,
    A.PaymentStatus,
    A.ProductType,
    B.CommodityCode as Code,
    B.CommodityName as Name,
    B.Quantity,
    '',
    B.Status,
    B.SumSalePrice,
    H.StartTime,
    1 as flag
  from
    [ORDER] A
    inner join [TBL_ORDER_COMMODITY] B on B.OrderID = A.ID
    inner join [BRANCH] H on H.ID = A.BranchID
go