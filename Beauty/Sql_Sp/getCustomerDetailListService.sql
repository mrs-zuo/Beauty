SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('getCustomerDetailListService', 'p') is not null
begin
  drop procedure getCustomerDetailListService
end
go

create procedure getCustomerDetailListService
  @BranchID integer,              --�ŵ�ID
  @SlaveID integer,               --�û�ID
  @productType integer,           --����/��Ʒ����
  @cycleType integer,             --ʱ��ɸѡ����(0:�� 1���� 2���� 3���� 4���Զ���)
  @startTime nvarchar(30),        --��ʼ����
  @endtime nvarchar(30),          --��������
  @sortType integer               --����flag

AS
begin

   begin try

--�˿����ѷ���-����service productType = 0 obejectType = 0������/Ա����
SELECT
  T7.Name ObjectName,
  T8.TotalPrice,
  T8.Quantity,
  sum(T8.Quantity)over() as TotalQuantity,
  sum(T8.TotalPrice)over() as Total
FROM (
  SELECT
    T6.CustomerID,
    ISNULL(SUM(T6.TotalPrice),0) TotalPrice,
    ISNULL(SUM(T6.Quantity),0) Quantity
  FROM (
    select
        T2.CustomerID,
        sum(T1.PaymentAmount * T1.ProfitRate * T1.typeflag) as TotalPrice,
        SUM(T2.Quantity) Quantity
    from
        vpayment T1
        inner join vorder T2 on T2.OrderID = T1.OrderID
        INNER JOIN [TBL_PROFIT] T4 ON T1.PaymentID = T4.MasterID
    WHERE
        T1.BranchID = @BranchID
    AND T1.PaymentTime > T2.StartTime
    AND T2.ProductType = @productType
    AND T2.PaymentStatus > 0
    AND T1.OrderNumber >= 1
	AND T2.Status<> 3
	and T1.flag = 0
    AND T4.Type = 2 AND T4.Available = 1 AND T4.SlaveID = @SlaveID
    AND ((T1.Type = 1 AND T1.Status in (2, 3)) OR (T1.Type = 2 AND T1.Status in (6, 7)))
    AND ((@cycleType = 0 and (DATEDIFF(dd, T1.PaymentTime, GETDATE()) = 0))
     or (@cycleType = 1 and (DATEPART(yy, T1.PaymentTime) = DATEPART(YY,GETDATE()) AND DATEPART(MM, T1.PaymentTime) = DATEPART(MM,GETDATE())))
     or (@cycleType = 2 and (DATEPART(qq, T1.PaymentTime) = DATEPART(qq, GETDATE()) and DATEPART(yy, T1.PaymentTime) = DATEPART(yy,GETDATE())))
     or (@cycleType = 3 and (DATEPART(yy, T1.PaymentTime) = DATEPART(YY,GETDATE())))
     or (@cycleType = 4 and (T1.PaymentTime BETWEEN @startTime and @endtime)))
    GROUP BY T2.CustomerID
	) T6
    GROUP BY T6.CustomerID
  ) T8 LEFT JOIN [CUSTOMER] T7 ON T8.CustomerID = T7.UserID
  order by
    case
      when @sortType = 1 then T8.Quantity
      else T8.TotalPrice end desc

END TRY

  BEGIN CATCH
     SELECT ERROR_MESSAGE() AS ErrorMessage
    ,ERROR_LINE() AS ErrorLINE
    ,ERROR_STATE() AS ErrorState
  END CATCH

end