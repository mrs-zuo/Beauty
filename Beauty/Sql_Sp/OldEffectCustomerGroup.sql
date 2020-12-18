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
  @CompanyID integer,       --公司ID
  @BranchID integer,        --门店ID
  @accountId integer,       --用户ID
  @cycleType integer,       --时间筛选类型(0:日 1：月 2：季 3：年 4：自定义)
  @startTime nvarchar(30),  --开始日期
  @endtime nvarchar(30),    --截至日期
  @StartDate datetime       --月季年开始日期
  
AS
begin

   begin try
   --报表 顾客筛选（老顾客/分组）
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
           --支付状态 1：未支付 2：部分付 3：已支付 4：已退款 5:免支付
               T3.PaymentStatus > 0
           --记录类型 1:有效 2：无效 3：伦理删除
           and T3.RecordType = 1
           AND T5.BranchID = @BranchID
           --时间
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
           --状态：1：进行中 2:已完成 3：已取消 4：已终止 5：完成待确认
           AND T8.RecordType = 1
           AND T7.TGStatus = 2
           --时间
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