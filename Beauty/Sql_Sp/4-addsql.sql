if object_id('VPAYMENT','v') is not null
begin
  drop view VPAYMENT
end
go

create view VPAYMENT as
  --֧��view
  select
    A.OrderID,
    A.PaymentID,
    B.CompanyID,
    B.BranchID,
    B.Type,
    B.Status,
    B.PaymentTime,
    B.OrderNumber,
    B.IsUseRate,
    B.BranchProfitRate,
    C.PaymentMode,
    C.UserCardNo,
    E.ID,
	E.CustomerID,
    E.TGTotalCount,
    E.SumSalePrice,
    0 as flag,
    case B.type
      when 1 
        then 1 else (-1) end as typeflag,
    --payment���ж϶�������
    case 
      when B.OrderNumber = 1 then C.PaymentAmount
      when B.OrderNumber > 1 then E.SumSalePrice
      else 0 end as PaymentAmount,
    case B.IsUseRate
      when 1 then C.ProfitRate
    else
      1 end as ProfitRate,
    --����������/����Ҫ�ж϶�������
    case B.IsUseRate
      when 1 then C.PaymentAmount
    else
      E.SumSalePrice end as Price
  from
    [TBL_ORDERPAYMENT_RELATIONSHIP] A
    left join [PAYMENT] B on B.ID = A.PaymentID
    left join [PAYMENT_DETAIL] C on C.PaymentID = B.ID
    inner join [TBL_ORDER_SERVICE] E on E.OrderID = A.OrderID

  union all
    select
    A.OrderID,
    A.PaymentID,
    B.CompanyID,
    B.BranchID,
    B.Type,
    B.Status,
    B.PaymentTime,
    B.OrderNumber,
    B.IsUseRate,
    B.BranchProfitRate,
    C.PaymentMode,
    C.UserCardNo,
    E.ID,
	E.CustomerID,
    '',
    E.SumSalePrice,
    1 as flag,
    case B.type
      when 1 
        then 1 else (-1) end as typeflag,
    --payment���ж϶�������
    case 
      when B.OrderNumber = 1 then C.PaymentAmount
      when B.OrderNumber > 1 then E.SumSalePrice
      else 0 end as PaymentAmount,
    case B.IsUseRate
      when 1 then C.ProfitRate
    else
      1 end as ProfitRate,
    --����������/����Ҫ�ж϶�������
    case B.IsUseRate
      when 1 then C.PaymentAmount
    else
      E.SumSalePrice end as Price
  from
    [TBL_ORDERPAYMENT_RELATIONSHIP] A
    left join [PAYMENT] B on B.ID = A.PaymentID
    left join [PAYMENT_DETAIL] C on C.PaymentID = B.ID
	inner join [TBL_ORDER_COMMODITY] E on E.OrderID = A.OrderID
go