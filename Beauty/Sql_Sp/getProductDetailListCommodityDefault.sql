SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('getProductDetailListCommodityDefault', 'p') is not null
begin
  drop procedure getProductDetailListCommodityDefault
end
go

create procedure getProductDetailListCommodityDefault
  @BranchID integer,              --�ŵ�ID
  @productType integer,           --����/��Ʒ����
  @cycleType integer,             --ʱ��ɸѡ����(0:�� 1���� 2���� 3���� 4���Զ���)
  @startTime nvarchar(30),        --��ʼ����
  @endtime nvarchar(30),          --��������
  @sortType integer               --����flag

AS
begin

   begin try
   

--�������۷���-��ƷCommodity productType = 1 obejectType != 0,3�����ڱ���
SELECT
    T8.ObjectName,
    sum(T8.TotalPrice) as TotalPrice,
    sum(T8.TotalProfitRatePrice) as TotalProfitRatePrice,
    sum(sum(T8.TotalPrice))over() as Total,
    sum(sum(T8.TotalProfitRatePrice))over() as AllDetailTotalPrice
FROM
(
  select
    T7.TotalPrice,
    T7.Code,
    T9.CommodityName ObjectName,
    T7.TotalPrice * T7.BranchProfitRate as TotalProfitRatePrice
  from (
    select
         sum(T1.PaymentAmount * T1.ProfitRate * T1.typeflag) as TotalPrice
        ,T2.Code Code
        ,ISNULL(T1.BranchProfitRate, 1) BranchProfitRate
    from
        vpayment T1
        inner join vorder T2 on T2.OrderID = T1.OrderID
    WHERE
        T1.BranchID = @BranchID
    AND T1.OrderNumber >= 1
    AND T2.PaymentStatus > 0
    AND T1.PaymentTime > T2.StartTime
    AND T2.ProductType = @productType
    and T1.flag = 1
    AND ((T1.Type = 1 AND T1.Status in (2, 3)) OR (T1.Type = 2 AND T1.Status in (6, 7)))
    AND ((@cycleType = 0 and (DATEDIFF(dd, T1.PaymentTime, GETDATE()) = 0))
     or (@cycleType = 1 and (DATEPART(yy, T1.PaymentTime) = DATEPART(YY,GETDATE()) AND DATEPART(MM, T1.PaymentTime) = DATEPART(MM,GETDATE())))
     or (@cycleType = 2 and (DATEPART(qq, T1.PaymentTime) = DATEPART(qq, GETDATE()) and DATEPART(yy, T1.PaymentTime) = DATEPART(yy,GETDATE())))
     or (@cycleType = 3 and (DATEPART(yy, T1.PaymentTime) = DATEPART(YY,GETDATE())))
     or (@cycleType = 4 and (T1.PaymentTime BETWEEN @startTime and @endtime)))
    GROUP BY
     T1.IsUseRate
    ,T2.Code
    ,T1.BranchProfitRate
  ) T7
  LEFT JOIN [Commodity] T9 ON T7.Code = T9.Code AND T9.Available = 1
  GROUP BY T7.Code, T7.BranchProfitRate, T7.TotalPrice, T9.CommodityName
) T8
GROUP by T8.code, T8.ObjectName
order by
case
  when @sortType = 1 then sum(T8.TotalProfitRatePrice)
  else sum(T8.TotalPrice) end desc

END TRY

  BEGIN CATCH
     SELECT ERROR_MESSAGE() AS ErrorMessage
    ,ERROR_LINE() AS ErrorLINE
    ,ERROR_STATE() AS ErrorState
  END CATCH

end