SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('CustomerGenderGroup', 'p') is not null
begin
  drop procedure CustomerGenderGroup
end
go

create procedure CustomerGenderGroup
  @CompanyID integer,       --��˾ID
  @BranchID integer,        --�ŵ�ID
  @accountId integer,       --�û�ID
  @cycleType integer,       --ʱ��ɸѡ����(0:�� 1���� 2���� 3���� 4���Զ���)
  @startTime nvarchar(30),  --��ʼ����
  @endtime nvarchar(30)    --��������
  
AS
begin

   begin try
   --������������飩
   select
     Count(T5.CustomerID) Amount,
     ISNULL(T6.Gender,2) Type
   from (
     select
         T3.CustomerID,
         CONVERT(varchar(10),T2.TGStartTime,111) TGStartTime
     from
         TREATMENT T1
         INNER JOIN [TBL_TREATGROUP] T2 ON T1.GroupNo = T2.GroupNo
         INNER JOIN [ORDER] T3 ON T2.OrderID = T3.ID
         LEFT JOIN [BRANCH] T4 ON T1.BranchID = T4.ID
     WHERE
     --�Ƿ���Ч
         T1.Available = 1
     AND T3.OrderTime > T4.StartTime
     AND T1.BranchID = @BranchID
     --״̬��1�������� 2:����� 3����ȡ�� 4������ֹ 5����ɴ�ȷ��
     AND T1.Status = 2
     --״̬��1�������� 2:����� 3����ȡ�� 4������ֹ 5����ɴ�ȷ��
     AND (T2.TGStatus = 2)
     AND T3.OrderTime > T4.StartTime
     --��¼���� 1:��Ч 2����Ч 3������ɾ��
     AND T3.RecordType = 1
     --objectType == 3 ִ����ID
     and T1.ExecutorID in (
       select distinct
           P1.UserID
       from
           [ACCOUNT] P1
           INNER JOIN [TBL_USER_TAGS] P2 ON P1.UserID = P2.UserID
       WHERE
           P1.CompanyID = @CompanyID
       AND P2.Available = 1
       AND P2.TagID = @accountId)
     --ʱ��
     AND ((@cycleType = 0 and (DATEDIFF(dd, T2.TGStartTime, GETDATE()) = 0))
      or (@cycleType = 1 and (DATEPART(yy, T2.TGStartTime) = DATEPART(YY,GETDATE()) AND DATEPART(MM, T2.TGStartTime) = DATEPART(MM,GETDATE())))
      or (@cycleType = 2 and (DATEPART(qq, T2.TGStartTime) = DATEPART(qq, GETDATE()) and DATEPART(yy, T2.TGStartTime) = DATEPART(yy,GETDATE())))
      or (@cycleType = 3 and (DATEPART(yy, T2.TGStartTime) = DATEPART(YY,GETDATE())))
      or (@cycleType = 4 and (T2.TGStartTime BETWEEN @startTime and @endtime)))
     GROUP BY T3.CustomerID, CONVERT(varchar(10),T2.TGStartTime,111)) T5
     LEFT JOIN [CUSTOMER] T6 ON T5.CustomerID = T6.UserID
   Group by T6.Gender

END TRY

  BEGIN CATCH
     SELECT ERROR_MESSAGE() AS ErrorMessage
    ,ERROR_LINE() AS ErrorLINE
    ,ERROR_STATE() AS ErrorState
  END CATCH

end