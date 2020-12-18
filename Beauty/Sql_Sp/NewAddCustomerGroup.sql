SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('NewAddCustomerGroup', 'p') is not null
begin
  drop procedure NewAddCustomerGroup
end
go

create procedure NewAddCustomerGroup
  @CompanyID integer,       --��˾ID
  @BranchID integer,        --�ŵ�ID
  @accountId integer,       --�û�ID
  @cycleType integer,       --ʱ��ɸѡ����(0:�� 1���� 2���� 3���� 4���Զ���)
  @startTime nvarchar(30),  --��ʼ����
  @endtime nvarchar(30)     --��������
AS
begin

   begin try

   --�ҵ�/Ա������ �˿�ɸѡ�����飩
   select
     Count(0)
   from
   (
     select distinct
         T1.UserID
     from
         [CUSTOMER] T1
         INNER JOIN [RELATIONSHIP] T2 ON T2.CustomerID = T1.UserID
     where
         --�Ƿ���Ч
         T1.Available = 1
     AND T1.RegistFrom <> 1
     AND T1.BranchID = @BranchID
     --ʱ��
     AND ((@cycleType = 0 and (DATEDIFF(dd, T1.CreateTime, GETDATE()) = 0))
      or (@cycleType = 1 and (DATEPART(yy, T1.CreateTime) = DATEPART(YY,GETDATE()) AND DATEPART(MM, T1.CreateTime) = DATEPART(MM,GETDATE())))
      or (@cycleType = 2 and (DATEPART(qq, T1.CreateTime) = DATEPART(qq, GETDATE()) and DATEPART(yy, T1.CreateTime) = DATEPART(yy,GETDATE())))
      or (@cycleType = 3 and (DATEPART(yy, T1.CreateTime) =DATEPART(YY,GETDATE())))
      or (@cycleType = 4 and (T1.CreateTime BETWEEN @startTime and @endtime)))
     --objectType == 3
     AND T2.AccountID in (
	   select distinct
           P1.UserID
       from
           [ACCOUNT] P1
           INNER JOIN [TBL_USER_TAGS] P2 ON P1.UserID = P2.UserID
       WHERE
           P1.CompanyID = @CompanyID
       AND P2.Available = 1
       AND P2.TagID = @accountId)
   ) T3

END TRY

  BEGIN CATCH
     SELECT ERROR_MESSAGE() AS ErrorMessage
    ,ERROR_LINE() AS ErrorLINE
    ,ERROR_STATE() AS ErrorState
  END CATCH

end

