SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('getBalanceDetailData', 'p') is not null
begin
  drop procedure getBalanceDetailData
end
go

create procedure getBalanceDetailData
  @CompanyID integer,             --公司ID
  @BranchID integer,              --门店ID
  @BeginDay varchar(100),         --开始日期
  @EndDay varchar(100)            --结束日期
  
AS
begin

   begin try
   

   select T21.UserID,
          T21.UserCardNo,
          T21.Payment,
          T21.IncomeCash,
          T21.IncomeBank,
          T21.IncomeIn,
          T21.IncomeWeChat,
          T21.IncomeAlipay,
          T21.OutCome,
          T21.IncomeSend,
          T22.CustomerName,
          T22.CustomerBranchName,
          T22.CardName,
          T22.Available,
          T22.CardExpiredDate,
          T22.LastBalance,
          T22.NowBalance,
   	      (T21.IncomeCash + T21.IncomeBank + T21.IncomeIn + T21.IncomeSend + T21.IncomeWeChat + T21.IncomeAlipay) AllIn,
   	      (T21.Payment + T21.OutCome) AllOut
   from (select T16.UserID,
               T16.UserCardNo,
               SUM(T16.Payment) Payment,
               SUM(T16.IncomeCash) IncomeCash,
               SUM(T16.IncomeBank) IncomeBank,
               SUM(T16.IncomeIn) IncomeIn,
               SUM(T16.IncomeWeChat) IncomeWeChat,
               SUM(T16.IncomeAlipay) IncomeAlipay,
               SUM(T16.OutCome) OutCome,
               SUM(T16.IncomeSend) IncomeSend
        from (select T6.UserID,
                    T6.UserCardNo,
                    case T6.ActionMode
                        when 1 then SUM(T6.Amount)
                        else 0
                    end Payment,
                    case T6.ActionMode
                        when 3 then case T6.DepositMode
                                        when 1 then SUM(T6.Amount)
                                        else 0
                                    end
                        else 0
                    end IncomeCash,
                    case T6.ActionMode
                        when 3 then case T6.DepositMode
                                        when 2 then SUM(T6.Amount)
                                        else 0
                                    end
                        else 0
                    end IncomeBank,
                    case T6.ActionMode
                        when 3 then case T6.DepositMode
                                        when 3 then SUM(T6.Amount)
                                        else 0
                                    end
                        else 0
                    end IncomeIn,
                    case T6.ActionMode
                        when 3 then case T6.DepositMode
                                        when 4 then SUM(T6.Amount)
                                        else 0
                                    end
                        else 0
                    end IncomeWeChat,
                    case T6.ActionMode
                        when 3 then case DepositMode
                                        when 5 then SUM(T6.Amount)
                                        else 0
                                    end
                        else 0
                    end IncomeAlipay,
                    case T6.ActionMode
                        when 5 then SUM(T6.Amount)
                        else 0
                    end OutCome,
                    case T6.ActionMode
                        when 7 then SUM(T6.Amount)
                        else 0
                    end IncomeSend
             from (SELECT T5.UserID,
                          T5.UserCardNo,
                          SUM(T5.Amount) Amount,
                          CASE T5.ActionMode 
                              WHEN 2 THEN 1 
                              WHEN 4 THEN 3 
                              WHEN 6 THEN 5 
                              WHEN 8 THEN 7 
                              WHEN 10 THEN 9 
                              ELSE T5.ActionMode 
                          END ActionMode ,
                          T5.DepositMode 
                          FROM [TBL_MONEY_BALANCE] T5 
                          INNER JOIN (SELECT T1.ID 
                                      FROM [TBL_CUSTOMER_BALANCE] T1 
                                      WHERE   T1.CompanyID=@CompanyID 
                                      and T1.CreateTime>@BeginDay 
                                      AND T1.CreateTime <@EndDay
                                      AND (( @branchId > 0 AND T1.BranchID = @BranchID) or @branchId <=0)
                                      AND NOT EXISTS (SELECT RelatedID 
                                                      FROM (SELECT T2.RelatedID,
                                                                   COUNT(0) CNT 
                                                            FROM [TBL_CUSTOMER_BALANCE] T2 
                                                            WHERE T2.CompanyID=@CompanyID 
                                                            AND T2.CreateTime>@BeginDay 
                                                            AND T2.CreateTime <@EndDay 
                                                            GROUP BY T2.RelatedID
                                                            ) T3 
                                                      WHERE T3.CNT > 1 
                                                      AND T3.RelatedID IS NOT NULL 
                                                      AND T1.RelatedID = T3.RelatedID
                                                      )
                                      )T4 ON T5.CustomerBalanceID = T4.ID 
                           GROUP BY T5.UserID,
                           T5.UserCardNo,
                           T5.ActionMode ,
                           T5.DepositMode ) T6  
             GROUP BY T6.UserID,
                      T6.UserCardNo,
                      T6.ActionMode ,
                      T6.DepositMode ) T16
        GROUP BY T16.UserID,
                 T16.UserCardNo) T21,
    (SELECT distinct T7.UserID,
                     T6.UserCardNo,
                     T7.Name CustomerName,
                     T18.BranchName CustomerBranchName,
                     T9.CardName,
                     CASE T7.Available 
                         WHEN 1 THEN '正在使用' 
                         ELSE '已关闭' 
                     END Available,
                     CONVERT(varchar(10),T8.CardExpiredDate,111) CardExpiredDate,
                     ISNULL(T12.Balance,0) LastBalance,
                     ISNULL(T16.Balance,0) NowBalance 
              FROM (SELECT T5.UserID,
                           T5.UserCardNo,
                           SUM(T5.Amount) Amount,
                           T5.ActionMode ,
                           T5.DepositMode 
                           FROM [TBL_MONEY_BALANCE] T5 
                           INNER JOIN (SELECT T1.ID 
                                       FROM [TBL_CUSTOMER_BALANCE] T1 
                                       WHERE  T1.CompanyID=@CompanyID 
                                       and T1.CreateTime>@BeginDay 
                                       AND T1.CreateTime <@EndDay
                                       AND (( @branchId > 0 AND T1.BranchID = @BranchID) or @branchId <=0)
                                       AND NOT EXISTS (SELECT RelatedID 
                                                       FROM (SELECT T2.RelatedID,
                                                                    COUNT(0) CNT 
                                                             FROM [TBL_CUSTOMER_BALANCE] T2 
                                                             WHERE T2.CompanyID=@CompanyID 
                                                             AND T2.CreateTime>@BeginDay 
                                                             AND T2.CreateTime <@EndDay
                                                             GROUP BY T2.RelatedID) T3 
                                                       WHERE T3.CNT > 1 
                                                       AND T3.RelatedID IS NOT NULL 
                                                       AND T1.RelatedID = T3.RelatedID
                                                       )
                                       )T4 ON T5.CustomerBalanceID = T4.ID 
                           GROUP BY T5.UserID,
                                    T5.UserCardNo,
                                    T5.ActionMode ,
                                    T5.DepositMode) T6 
              LEFT JOIN [CUSTOMER] T7 ON T6.UserID = T7.UserID
              LEFT JOIN [TBL_CUSTOMER_CARD] T17 ON T17.UserCardNo = T6.UserCardNo
              LEFT JOIN [BRANCH] T18 ON T7.BranchID = T18.ID
              LEFT JOIN [TBL_CUSTOMER_CARD] T8 ON T6.UserCardNo = T8.UserCardNo AND T6.UserID = T8.UserID 
              LEFT JOIN [MST_CARD] T9 ON T8.CardID = T9.ID
              LEFT JOIN (SELECT  T11.Balance,
                                 T11.UserID ,
                                 T11.UserCardNo 
                         FROM [TBL_MONEY_BALANCE] T11 
                         INNER JOIN  (SELECT MAX(T12.ID) BalanceID  
                                      FROM [TBL_MONEY_BALANCE] T12  
                                      WHERE  T12.CompanyID=@CompanyID 
                                      AND T12.CreateTime<@BeginDay  
                                      Group by T12.UserID ,
                                               T12.UserCardNo
                                     ) T10 ON T11.ID = T10.BalanceID 
                         ) T12 ON T6.UserID = T12.UserID AND T6.UserCardNo = T12.UserCardNo
              LEFT JOIN (SELECT  T13.Balance,
                                 T13.UserID ,
                                 T13.UserCardNo 
                         FROM [TBL_MONEY_BALANCE] T13 
                         INNER JOIN  (SELECT MAX(T14.ID) BalanceID  
                                      FROM [TBL_MONEY_BALANCE] T14  
                                      WHERE  T14.CompanyID=@CompanyID 
                                      AND T14.CreateTime<@EndDay  
                                      Group by T14.UserID ,
                                               T14.UserCardNo
                                      ) T15 ON T13.ID = T15.BalanceID 
                         ) T16 ON T6.UserID = T16.UserID AND T6.UserCardNo = T16.UserCardNo ) T22 
   where T22.UserID = T21.UserID AND T22.UserCardNo = T21.UserCardNo
   order by T22.CustomerName,T21.UserCardNo
   
   END TRY

   BEGIN CATCH
      SELECT ERROR_MESSAGE() AS ErrorMessage
     ,ERROR_LINE() AS ErrorLINE
     ,ERROR_STATE() AS ErrorState
   END CATCH

end