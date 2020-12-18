SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('getTreatmentAchievement', 'p') is not null
begin
  drop procedure getTreatmentAchievement
end
go

create procedure getTreatmentAchievement
  @BranchID integer,        --�ŵ�ID
  @SlaveID integer,         --�û�ID
  @cycleType integer,       --ʱ��ɸѡ����(0:�� 1���� 2���� 3���� 4���Զ���)
  @startTime nvarchar(30),  --��ʼ����
  @endtime nvarchar(30)     --��������
AS
begin

   begin try

   --�������ҵ��  ָ��ҵ��  ��ָ��ҵ��
   select
     SUM(T5.Price) Amount,
     T3.IsDesignated Type
   from
   (
     SELECT distinct
         T1.GroupNo,
         T2.IsDesignated,
         T2.OrderID
     FROM
         --TM��
         [TREATMENT] T1
   	  --��������
         INNER JOIN [TBL_TREATGROUP] T2 ON T1.GroupNo = T2.GroupNo
		 inner join vorder T3 on T3.OrderID = T2.OrderID
     WHERE
         
         T1.BranchID = @BranchID
     --״̬��1�������� 2:����� 3����ȡ�� 4������ֹ 5����ɴ�ȷ��
     AND T1.Status = 2
     --״̬��1�������� 2:����� 3����ȡ�� 4������ֹ 5����ɴ�ȷ��
     AND (T2.TGStatus = 2)
     AND T3.OrderTime > T3.StartTime
     --״̬��1:δ��ɡ�2������� ��3����ȡ����4:����ֹ
     AND T3.Status <> 3
     --�ܵ�TG����
     AND T3.TGTotalCount > 0
     --��¼���� RecordType
     AND T3.RecordType = 1
	 --���ַ���/��Ʒ
	 AND T3.flag = 0
     --objectType == 0
     and T1.ExecutorID = @SlaveID
     --ʱ������
     AND ((@cycleType = 0 and (DATEDIFF(dd, T2.TGEndTime, GETDATE()) = 0))
     or (@cycleType = 1 and (DATEPART(yy, T2.TGEndTime) = DATEPART(YY,GETDATE()) AND DATEPART(MM, T2.TGEndTime) = DATEPART(MM,GETDATE())))
     or (@cycleType = 2 and (DATEPART(qq, T2.TGEndTime) = DATEPART(qq, GETDATE()) and DATEPART(yy, T2.TGEndTime) = DATEPART(yy,GETDATE())))
     or (@cycleType = 3 and (DATEPART(yy, T2.TGEndTime) =DATEPART(YY,GETDATE())))
     or (@cycleType = 4 and (T2.TGEndTime BETWEEN @startTime and @endtime)))
   ) T3
   INNER JOIN (
     SELECT
         ROUND(T11.Price/T11.TGTotalCount,2) Price,
         T11.OrderID
     FROM (
         select
           --IsUseRate �Ƿ�ʹ��ҵ�������ʼ���ҵ��1��ʹ�� 2����ʹ�� 3��δ���ã�Ĭ�ϣ�
           CASE ISNULL(T6.IsUseRate ,2)
             WHEN 1 THEN
               --֧����� * ҵ��������
               SUM(CASE T6.Type WHEN 1 THEN T9.PaymentAmount * T9.ProfitRate * dbo.getProfitrate(@SlaveID, T6.ID,3) ELSE T9.PaymentAmount * T9.ProfitRate * dbo.getProfitrate(@SlaveID, T6.ID,3) * -1 END)
               --�����ۼ�
           ELSE T8.SumSalePrice * dbo.getProfitrate(@SlaveID, T6.ID,3) END Price,
           T8.OrderID,
           T8.TGTotalCount
         from
           [TBL_ORDER_SERVICE] T8
           LEFT JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T7 ON T7.OrderID = T8.OrderID
           LEFT JOIN [PAYMENT] T6 ON T6.ID = T7.PaymentID
           LEFT JOIN [PAYMENT_DETAIL] T9 ON T6.ID = T9.PaymentID
           LEFT JOIN [BRANCH] T10 ON T6.BranchID = T10.ID
           LEFT JOIN [BRANCH] T12 ON T8.BranchID = T12.ID
         WHERE
             T8.Status <> 3
         and T8.TGTotalCount > 0
         AND T8.SumSalePrice > 0
         GROUP BY T8.OrderID,T8.TGTotalCount,T8.SumSalePrice,T6.IsUseRate,T6.ID) T11
   ) T5 ON T3.OrderID = T5.OrderID 
   GROUP BY T3.IsDesignated

END TRY

  BEGIN CATCH
     SELECT ERROR_MESSAGE() AS ErrorMessage
    ,ERROR_LINE() AS ErrorLINE
    ,ERROR_STATE() AS ErrorState
  END CATCH

end