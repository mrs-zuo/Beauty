SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('OldEffectCustomerGroup', 'p') is not null
begin
  drop procedure OldEffectCustomerGroup
end
go

create procedure OldEffectCustomerGroup
  @CompanyID integer,       --��˾ID
  @BranchID integer,        --�ŵ�ID
  @accountId integer,       --�û�ID
  @cycleType integer,       --ʱ��ɸѡ����(0:�� 1���� 2���� 3���� 4���Զ���)
  @startTime nvarchar(30),  --��ʼ����
  @endtime nvarchar(30),    --��������
  @StartDate datetime       --�¼��꿪ʼ����
  
AS
begin

   begin try
   --���� �˿�ɸѡ���Ϲ˿�/���飩
   select
     count(0)
   from (
     select distinct
       T2.UserID
     from
       [CUSTOMER] T2
       INNER join (
         SELECT distinct
           T9.CustomerID
         FROM (
           select
               T3.CustomerID
           from
               [ORDER] T3
               INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T4 ON T3.ID = T4.OrderID
               INNER JOIN [PAYMENT] T5 ON T4.PaymentID = T5.ID
           where
           --֧��״̬ 1��δ֧�� 2�����ָ� 3����֧�� 4�����˿� 5:��֧��
               T3.PaymentStatus > 0
           --��¼���� 1:��Ч 2����Ч 3������ɾ��
           and T3.RecordType = 1
           AND T5.BranchID = @BranchID
           --ʱ��
           AND ((@cycleType = 0 and (DATEDIFF(dd, T5.PaymentTime, GETDATE()) = 0))
            or (@cycleType = 1 and (DATEPART(yy, T5.PaymentTime) = DATEPART(YY,GETDATE()) AND DATEPART(MM, T5.PaymentTime) = DATEPART(MM,GETDATE())))
            or (@cycleType = 2 and (DATEPART(qq, T5.PaymentTime) = DATEPART(qq, GETDATE()) and DATEPART(yy, T5.PaymentTime) = DATEPART(yy,GETDATE())))
            or (@cycleType = 3 and (DATEPART(yy, T5.PaymentTime) = DATEPART(YY,GETDATE())))
            or (@cycleType = 4 and (T5.PaymentTime BETWEEN @startTime and @endtime)))
           group by T3.CustomerID
   
           UNION ALL
           SELECT
               T8.CustomerID
           FROM
               [TBL_TREATGROUP] T7
               INNER JOIN [ORDER] T8 ON T7.OrderID = T8.ID
           WHERE
               T7.BranchID = @BranchID
           --״̬��1�������� 2:����� 3����ȡ�� 4������ֹ 5����ɴ�ȷ��
           AND T8.RecordType = 1
           AND T7.TGStatus = 2
           --ʱ��
           AND ((@cycleType = 0 and (DATEDIFF(dd, T7.TGStartTime, GETDATE()) = 0))
            or (@cycleType = 1 and (DATEPART(yy, T7.TGStartTime) = DATEPART(YY,GETDATE()) AND DATEPART(MM, T7.TGStartTime) = DATEPART(MM,GETDATE())))
            or (@cycleType = 2 and (DATEPART(qq, T7.TGStartTime) = DATEPART(qq, GETDATE()) and DATEPART(yy, T7.TGStartTime) = DATEPART(yy,GETDATE())))
            or (@cycleType = 3 and (DATEPART(yy, T7.TGStartTime) = DATEPART(YY,GETDATE())))
            or (@cycleType = 4 and (T7.TGStartTime BETWEEN @startTime and @endtime)))
           ) T9 
         )T1 ON T2.USERID = T1.CustomerID
         INNER JOIN [RELATIONSHIP] T6 ON T6.CustomerID = T2.UserID
         where
             T2.Available = 1
         AND T2.CreateTime < @StartDate
         AND T2.RegistFrom <> 1
         --objectType == 3
         AND T6.AccountID in (
           select distinct
               P1.UserID
           from
               [ACCOUNT] P1
               INNER JOIN [TBL_USER_TAGS] P2 ON P1.UserID = P2.UserID
           WHERE
               P1.CompanyID = @CompanyID
           AND P2.Available = 1
           AND P2.TagID = @accountId)
   ) T10

END TRY

  BEGIN CATCH
     SELECT ERROR_MESSAGE() AS ErrorMessage
    ,ERROR_LINE() AS ErrorLINE
    ,ERROR_STATE() AS ErrorState
  END CATCH

end