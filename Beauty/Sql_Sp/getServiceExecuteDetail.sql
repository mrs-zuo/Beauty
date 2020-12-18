SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('getServiceExecuteDetail', 'p') is not null
begin
  drop procedure getServiceExecuteDetail
end
go

create procedure getServiceExecuteDetail
  @BranchID integer,        --�ŵ�ID
  @SlaveID integer,         --�û�ID
  @cycleType integer,       --ʱ��ɸѡ����(0:�� 1���� 2���� 3���� 4���Զ���)
  @startTime nvarchar(30),  --��ʼ����
  @endtime nvarchar(30),    --��������
  @sortType integer         --����flag
AS
begin

   begin try

   --����������/����������������������� ����/Ա������
   SELECT
     Count(T8.GroupNo) Quantity,
     SUM(T8.TotalPrice) TotalPrice,
     T5.ServiceName ObjectName,
     sum(Count(T8.GroupNo))over() as TotalQuantity,
     round(sum(SUM(T8.TotalPrice))over(),2) as Total
   FROM (
     SELECT
       T13.GroupNo,
       T13.ServiceCode,
       ROUND(SUM(T13.TotalPrice)/T13.TGTotalCount,2) TotalPrice
     FROM (
       select
		   distinct T1.GroupNo GroupNo,
           T3.Code as ServiceCode,
           CASE ISNULL(T11.IsUseRate ,2)
             WHEN 1 THEN
               CASE T11.Type
                 WHEN 1 THEN T12.PaymentAmount * T12.ProfitRate * dbo.getProfitrate(@SlaveID, T11.ID,1)
               ELSE T12.PaymentAmount * T12.ProfitRate * dbo.getProfitrate(@SlaveID, T11.ID,1) * -1 END
             ELSE T3.SumSalePrice * dbo.getProfitrate(@SlaveID, T11.ID,1)
           END TotalPrice,
           T3.TGTotalCount,
           T3.OrderID
       from
           [TREATMENT] T1
           INNER JOIN [TBL_TREATGROUP] T2 ON T1.GroupNo = T2.GroupNo
           inner join vorder T3 on T3.OrderID = T2.OrderID
           LEFT JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T10 ON T3.OrderID = T10.OrderID
           LEFT JOIN [PAYMENT] T11 ON T11.ID = T10.PaymentID
           LEFT JOIN [PAYMENT_DETAIL] T12 ON T10.PaymentID = T12.PaymentID
       WHERE
           T1.BranchID = @BranchID
       AND T1.Status = 2
       AND T2.TGStatus = 2
       and T3.RecordType = 1
       AND T3.OrderTime > T3.StartTime
       AND T3.TGTotalCount > 0
       and T3.SumSalePrice > 0
       and T3.flag = 0
	   --objectType == 0
       AND T1.ExecutorID = @SlaveID
       --ʱ������
       AND ((@cycleType = 0 and (DATEDIFF(dd, T2.TGEndTime, GETDATE()) = 0))
       or (@cycleType = 1 and (DATEPART(yy, T2.TGEndTime) = DATEPART(YY,GETDATE()) AND DATEPART(MM, T2.TGEndTime) = DATEPART(MM,GETDATE())))
       or (@cycleType = 2 and (DATEPART(qq, T2.TGEndTime) = DATEPART(qq, GETDATE()) AND DATEPART(yy, T2.TGEndTime) = DATEPART(yy,GETDATE())))
       or (@cycleType = 3 and (DATEPART(yy, T2.TGEndTime) = DATEPART(YY,GETDATE())))
       or (@cycleType = 4 and (T2.TGEndTime BETWEEN @startTime and @endtime)))
       GROUP BY T3.Code,T1.GroupNo,T3.TGTotalCount,T3.SumSalePrice,T11.Type,T11.IsUseRate,T3.OrderID,T12.PaymentAmount,T12.ProfitRate,T12.ID,T1.GroupNo,T11.ID
     ) T13 group by T13.ServiceCode,T13.TGTotalCount,T13.GroupNo
   ) T8
   LEFT JOIN [SERVICE] T5 ON T8.ServiceCode = T5.Code AND T5.Available = 1
   GROUP BY T8.ServiceCode, T5.ServiceName
   order by
    case
      when @sortType = 1 then Count(T8.ServiceCode)
      else SUM(T8.TotalPrice) end desc

  
END TRY

  BEGIN CATCH
     SELECT ERROR_MESSAGE() AS ErrorMessage
    ,ERROR_LINE() AS ErrorLINE
    ,ERROR_STATE() AS ErrorState
  END CATCH

end