SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

if object_id('getBranchReChargeDeatilReport', 'p') is not null
begin
  drop procedure getBranchReChargeDeatilReport
end
go


CREATE procedure getBranchReChargeDeatilReport
  @CompanyID integer,             --公司ID
  @BranchID integer,              --门店ID
  @BeginDay varchar(100),         --开始日期
  @EndDay varchar(100)            --结束日期
  
AS
begin

   begin try
   SELECT T3.BranchName,
          T5.Name CustomerName,
          T10.CustomerPhoneNumber,
          T9.BranchName CustomerBranchName,
          T8.Name AS SourceName,
          T7.CardName,
          CASE T2.ActionMode 
              WHEN 3 THEN '储值卡直充' 
              WHEN 4 THEN '储值卡直充撤销' 
              WHEN 5 THEN '储值卡直扣' 
              WHEN 6 THEN '储值卡直扣撤销'  
          END ActionMode ,
          CONVERT(varchar(10), T1.CreateTime, 111) CreateTime,
          SUBSTRING(CONVERT(varchar(6) ,T1.CreateTime ,12),3,4) + right('000000'+ cast(T1.ID AS VARCHAR(10)),6) + CONVERT(varchar(2) ,T1.CreateTime ,12) PaymentNumber,
          CASE 
              WHEN T2.ActionMode = 3 AND T2.DepositMode = 1 THEN ISNULL(T2.Amount,0) 
              ELSE 0 
          END Cash,
          CASE 
              WHEN T2.ActionMode = 3 AND T2.DepositMode = 2 THEN ISNULL(T2.Amount,0) 
              ELSE 0 
          END Bank,
          CASE 
              WHEN T2.ActionMode = 3 AND T2.DepositMode = 4 THEN ISNULL(T2.Amount,0) 
              ELSE 0 
          END WeChat,
          CASE 
              WHEN T2.ActionMode = 3 AND T2.DepositMode = 5 THEN ISNULL(T2.Amount,0) 
              ELSE 0 
          END Alipay,
          CASE 
              WHEN T2.ActionMode = 4 OR T2.ActionMode = 5 OR T2.ActionMode = 6 THEN ISNULL(T2.Amount,0) 
              ELSE 0 
          END RelatedMoney,
          T1.Remark
   FROM [TBL_CUSTOMER_BALANCE] T1
   INNER JOIN [TBL_MONEY_BALANCE] T2 ON T1.ID = T2.CustomerBalanceID
   LEFT JOIN [BRANCH] T3 ON T1.BranchID = T3.ID
   LEFT JOIN [CUSTOMER] T5 ON T1.UserID = T5.UserID
   left join (select UserID, max(PhoneNumber) as CustomerPhoneNumber from PHONE group by UserID) T10 on T10.UserID = T5.UserID
   LEFT JOIN [TBL_CUSTOMER_CARD] T6 ON T2.UserID = T6.UserID AND T2.UserCardNo = T6.UserCardNo 
   LEFT JOIN [BRANCH] T9 ON T5.BranchID = T9.ID
   LEFT JOIN [MST_CARD] T7 ON T7.ID = T6.CardID
   LEFT JOIN [TBL_CUSTOMER_SOURCE_TYPE] T8 ON T5.SourceType = T8.ID
   WHERE  T1.TargetAccount = 1 
   AND T1.CompanyID=@CompanyID 
   and T1.CreateTime>@BeginDay 
   AND T1.CreateTime <@EndDay 
   AND (T2.ActionMode = 3 OR T2.ActionMode = 4 OR T2.ActionMode = 5 OR T2.ActionMode = 6) 
   and T2.DepositMode <> 3 
   AND (( @branchId > 0 AND T1.BranchID = @BranchID) or @branchId <=0)
   ORDER BY  CreateTime
   END TRY

   BEGIN CATCH
      SELECT ERROR_MESSAGE() AS ErrorMessage
     ,ERROR_LINE() AS ErrorLINE
     ,ERROR_STATE() AS ErrorState
   END CATCH

end
GO

