SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('getBranchServicePayDetail', 'p') is not null
begin
  drop procedure getBranchServicePayDetail
end
go

CREATE procedure getBranchServicePayDetail
  @CompanyID integer,             --公司ID
  @BranchID integer,              --门店ID
  @BeginDay varchar(100),         --开始日期
  @EndDay varchar(100)            --结束日期
  
AS
begin

   begin try
   declare @tmptable table (
          PaymentID int,
          BranchName nvarchar(30),
          CustomerName nvarchar(30),
          CustomerPhoneNumber varchar(30),
          CustomerBranchName nvarchar(30),
          SourceName nvarchar(20),
          OrderTime varchar(10),
          ServiceName nvarchar(30),
          OrderNumber varchar(120),
          TotalOrigPrice money,
          TotalSalePrice money,
          PaymentTime varchar(10),
          PaymentNumber varchar(120),
          Remark nvarchar(300),
          IsUseRate tinyint,
          PolicyName nvarchar(40),
          OrderSource nvarchar(40),
          PayCash money,
          PayMoneyBalance money,
          PayBankCard money,
          PayOther money,
          PayPointBalance money,
          PayCouponBalance money,
          PayWeChatBalance money,
          PayAlipayBalance money,
          PayLoan money,
          PayThird money,
          ProfitAmount money,
          Mark nvarchar(40)
   )
   insert @tmptable
   select T22.PaymentID,
          T22.BranchName,
          T22.CustomerName,
          T22.CustomerPhoneNumber,
          isnull(T22.CustomerBranchName,'') CustomerBranchName,
          T22.SourceName,
          T22.OrderTime,
          T22.ServiceName,
          T22.OrderNumber,
          T22.TotalOrigPrice,
          T22.TotalSalePrice,
          T22.PaymentTime,
          T22.PaymentNumber,
          T22.Remark,
          T22.IsUseRate,
          T22.PolicyName,
          T22.OrderSource,
          (T22.TotalSalePrice * T23.PayCashRate + T23.PayCash) PayCash,
          (T22.TotalSalePrice * T23.PayMoneyBalanceRate + T23.PayMoneyBalance) PayMoneyBalance,
          (T22.TotalSalePrice * T23.PayBankCardRate + T23.PayBankCard) PayBankCard,
          (T22.TotalSalePrice * T23.PayOtherRate + T23.PayOther) PayOther,
          (T22.TotalSalePrice * T23.PayPointBalanceRate + T23.PayPointBalance) PayPointBalance,
          (T22.TotalSalePrice * T23.PayCouponBalanceRate + T23.PayCouponBalance) PayCouponBalance,
          (T22.TotalSalePrice * T23.PayWeChatBalanceRate + T23.PayWeChatBalance) PayWeChatBalance,
          (T22.TotalSalePrice * T23.PayAlipayBalanceRate + T23.PayAlipayBalance) PayAlipayBalance,
          (T22.TotalSalePrice * T23.PayLoanRate + T23.PayLoan) PayLoan,
          (T22.TotalSalePrice * T23.PayThirdRate + T23.PayThird) PayThird,
          (T22.TotalSalePrice * (T23.PayCashRate + T23.PayMoneyBalanceRate + T23.PayBankCardRate + T23.PayOtherRate + T23.PayWeChatBalanceRate + T23.PayAlipayBalanceRate + T23.PayLoanRate + T23.PayThirdRate)
		  + T23.PayCash + T23.PayMoneyBalance + T23.PayBankCard + T23.PayOther + T23.PayWeChatBalance + T23.PayAlipayBalance + T23.PayLoan + T23.PayThird ) ProfitAmount,
          case 
              when PayCash < 0 then '已取消'
              else ''
          end Mark 
   from
   (SELECT  T5.PaymentID,
            T5.BranchName,
            T7.Name CustomerName,
            T30.CustomerPhoneNumber,
            T5.CustomerBranchName,
            T14.Name AS SourceName,
            T5.OrderTime,
            T8.ServiceName,
            T5.OrderNumber,
            T5.TotalOrigPrice,
            T5.TotalSalePrice,
            T5.PaymentTime,
            T5.PaymentNumber,
            T5.Remark,
            T5.IsUseRate,
            T5.PolicyName,
            T5.OrderSource
    FROM ( SELECT  T1.PaymentID,
                   T4.BranchName,
                   T11.CustomerID,
                   T18.BranchName CustomerBranchName,
                   CONVERT(varchar(10),T2.OrderTime,111) OrderTime,
                   T11.ServiceID ProductID,
                   SUBSTRING(CONVERT(varchar(6) ,T2.OrderTime ,12),3,4) + right('000000'+ cast(T2.ID AS VARCHAR(10)),6) + CONVERT(varchar(2) ,T2.OrderTime ,12) OrderNumber,
                   T11.SumOrigPrice TotalOrigPrice,
                   T11.SumSalePrice TotalSalePrice,
                   CONVERT(varchar(10),T3.PaymentTime,111)  PaymentTime,
                   SUBSTRING(CONVERT(varchar(6) ,T3.PaymentTime ,12),3,4) + right('000000'+ cast(T3.ID AS VARCHAR(10)),6) + CONVERT(varchar(2) ,T3.PaymentTime ,12) PaymentNumber,
                   CASE T2.OrderSource 
                       WHEN 0 THEN '商家' 
                       WHEN 1 THEN '商机' 
                       WHEN 2 THEN '顾客' 
                       WHEN 3 THEN '预约' 
                       WHEN 4 THEN '导入' 
                       WHEN 5 THEN '抢购' 
                       ELSE ''  
                   END OrderSource,
                   T3.Remark  ,
                   T3.IsUseRate,
                   T13.PolicyName
           FROM [TBL_ORDERPAYMENT_RELATIONSHIP] T1 WITH (NOLOCK)   
           INNER JOIN [ORDER] T2 ON T2.ID = T1.OrderID AND T2.PaymentStatus > 0  and  T2.ProductType =0  
           INNER JOIN [TBL_ORDER_SERVICE] T11 ON T2.ID = T11.OrderID 
           LEFT JOIN [CUSTOMER] T17 ON T17.UserID = T11.CustomerID
           LEFT JOIN [BRANCH] T18 ON T17.BranchID = T18.ID
           INNER JOIN [PAYMENT] T3 ON T1.PaymentID = T3.ID 	
           left JOIN [TBL_CUSTOMER_BENEFIT] T12 ON T2.CustomerID = T12.UserID AND T2.ID = T12.OrderID AND T12.BenefitStatus = 2
           LEFT JOIN [TBL_BENEFIT_POLICY] T13 ON T12.PolicyID = T13.PolicyID
           LEFT JOIN [BRANCH] T4 ON T3.BranchID = T4.ID 
           where T11.CompanyID = @CompanyID 
           AND T3.PaymentTime >= @BeginDay 
           AND T3.PaymentTime <= @EndDay 
           AND T3.PaymentTime >= T4.StartTime  
           AND ((T3.Type = 1 AND (T3.Status = 2 OR T3.Status = 3)) OR (T3.Type = 2 AND (T3.Status = 6 OR T3.Status = 7))) 
           AND (( @branchId > 0 AND T3.BranchID = @BranchID) or @branchId <=0)
           GROUP BY T1.PaymentID,
                    T4.BranchName,
                    T11.CustomerID,
                    CONVERT(varchar(10),T2.OrderTime,111),SUBSTRING(CONVERT(varchar(6) ,T2.OrderTime ,12),3,4) + right('000000'+ cast(T2.ID AS VARCHAR(10)),6) + CONVERT(varchar(2) ,T2.OrderTime ,12) ,
                    T11.SumOrigPrice ,
                    T11.SumSalePrice ,
                    T11.ServiceID,
                    CONVERT(varchar(10),T3.PaymentTime,111),SUBSTRING(CONVERT(varchar(6) ,T3.PaymentTime ,12),3,4) + right('000000'+ cast(T3.ID AS VARCHAR(10)),6) + CONVERT(varchar(2) ,T3.PaymentTime ,12),
                    T3.Remark ,
                    T3.IsUseRate,
                    T13.PolicyName,
                    T2.OrderSource,
                    T18.BranchName
                    ) T5 
    INNER JOIN [CUSTOMER] T7 WITH (NOLOCK) on T5.CustomerID = T7.UserID
    left join (select UserID, max(PhoneNumber) as CustomerPhoneNumber from PHONE group by UserID) T30 on T30.UserID = T7.UserID
    left join [SERVICE] T8 WITH (NOLOCK) ON T5.ProductID = T8.ID 
    LEFT JOIN [TBL_CUSTOMER_SOURCE_TYPE] T14  WITH (NOLOCK) ON T7.SourceType = T14.ID ) T22,
   (select T21.PaymentID,
           SUM(T21.PayCash) PayCash,
           SUM(T21.PayMoneyBalance) PayMoneyBalance,
           SUM(T21.PayBankCard) PayBankCard,
           SUM(T21.PayOther) PayOther,
           SUM(T21.PayPointBalance) PayPointBalance,
           SUM(T21.PayCouponBalance) PayCouponBalance,
           SUM(T21.PayWeChatBalance) PayWeChatBalance,
           SUM(T21.PayAlipayBalance) PayAlipayBalance,
           SUM(T21.PayLoan) PayLoan,
           SUM(T21.PayThird) PayThird,
           SUM(T21.PayCashRate) PayCashRate,
           SUM(T21.PayMoneyBalanceRate) PayMoneyBalanceRate,
           SUM(T21.PayBankCardRate) PayBankCardRate,
           SUM(T21.PayOtherRate) PayOtherRate,
           SUM(T21.PayPointBalanceRate) PayPointBalanceRate,
           SUM(T21.PayCouponBalanceRate) PayCouponBalanceRate,
           SUM(T21.PayWeChatBalanceRate) PayWeChatBalanceRate,
           SUM(T21.PayAlipayBalanceRate) PayAlipayBalanceRate,
           SUM(T21.PayLoanRate) PayLoanRate,
           SUM(T21.PayThirdRate) PayThirdRate
    from (select T20.PaymentID,
                 case T20.PaymentMode
                     when 0 then case 
                                     when T20.OrderNumber = 1 then isnull(T20.PaymentAmount,0)
                                     else 0
                                 end
                     else 0
                 end PayCash,
                 case T20.PaymentMode
                     when 1 then case 
                                     when T20.OrderNumber = 1 then isnull(T20.PaymentAmount,0)
                                     else 0
                                 end
                     else 0
                 end PayMoneyBalance,
                 case T20.PaymentMode
                     when 2 then case 
                                     when T20.OrderNumber = 1 then isnull(T20.PaymentAmount,0)
                                     else 0
                                 end
                     else 0
                 end PayBankCard,
                 case T20.PaymentMode
                     when 3 then case 
                                     when T20.OrderNumber = 1 then isnull(T20.PaymentAmount,0)
                                     else 0
                                 end
                     else 0
                 end PayOther,
                 case T20.PaymentMode
                     when 6 then case 
                                     when T20.OrderNumber = 1 then isnull(T20.PaymentAmount,0)
                                     else 0
                                 end
                     else 0
                 end PayPointBalance,
                 case T20.PaymentMode
                     when 7 then case 
                                     when T20.OrderNumber = 1 then isnull(T20.PaymentAmount,0)
                                     else 0
                                 end
                     else 0
                 end PayCouponBalance,
                 case T20.PaymentMode
                     when 8 then case 
                                     when T20.OrderNumber = 1 then isnull(T20.PaymentAmount,0)
                                     else 0
                                 end
                     else 0
                 end PayWeChatBalance,
                 case T20.PaymentMode
                     when 9 then case 
                                     when T20.OrderNumber = 1 then isnull(T20.PaymentAmount,0)
                                     else 0
                                 end
                     else 0
                 end PayAlipayBalance,
                 case T20.PaymentMode
                     when 100 then case 
                                     when T20.OrderNumber = 1 then isnull(T20.PaymentAmount,0)
                                     else 0
                                 end
                     else 0
                 end PayLoan,
                 case T20.PaymentMode
                     when 101 then case 
                                     when T20.OrderNumber = 1 then isnull(T20.PaymentAmount,0)
                                     else 0
                                 end
                     else 0
                 end PayThird,
                 case T20.PaymentMode
                     when 0 then isnull(T20.ProfitRate,0)
                     else 0
                 end PayCashRate,
                 case T20.PaymentMode
                     when 1 then isnull(T20.ProfitRate,0)
                     else 0
                 end PayMoneyBalanceRate,
                 case T20.PaymentMode
                     when 2 then isnull(T20.ProfitRate,0)
                     else 0
                 end PayBankCardRate,
                 case T20.PaymentMode
                     when 3 then isnull(T20.ProfitRate,0)
                     else 0
                 end PayOtherRate,
                 case T20.PaymentMode
                     when 6 then isnull(T20.ProfitRate,0)
                     else 0
                 end PayPointBalanceRate,
                 case T20.PaymentMode
                     when 7 then isnull(T20.ProfitRate,0)
                     else 0
                 end PayCouponBalanceRate,
                 case T20.PaymentMode
                     when 8 then isnull(T20.ProfitRate,0)
                     else 0
                 end PayWeChatBalanceRate,
                 case T20.PaymentMode
                     when 9 then isnull(T20.ProfitRate,0)
                     else 0
                 end PayAlipayBalanceRate,
                 case T20.PaymentMode
                     when 100 then isnull(T20.ProfitRate,0)
                     else 0
                 end PayLoanRate,
                 case T20.PaymentMode
                     when 101 then isnull(T20.ProfitRate,0)
                     else 0
                 end PayThirdRate
          from (Select distinct T3.PaymentID,
                       T1.PaymentMode,
                       CASE T2.IsUseRate 
                           WHEN 1 THEN  SUM( CASE T2.Type 
                                                 WHEN 1 THEN T1.PaymentAmount* T1.ProfitRate 
                                                 ELSE T1.PaymentAmount * T1.ProfitRate * -1 
                                             END)  
                           ELSE SUM( CASE T2.Type 
                                         WHEN 1 THEN T1.PaymentAmount 
                                         ELSE T1.PaymentAmount * -1 
                                     END) 
                       END  PaymentAmount,
                       T2.OrderNumber ,
                       T2.Type,
                       CASE
								           WHEN T2.OrderNumber > 1 THEN case T2.IsUseRate 
								                                            when 1 then case T2.Type 
								                                                            when 2 then T1.ProfitRate * -1
								                                                            else T1.ProfitRate
								                                                        end
								                                            else case T2.Type 
								                                                            when 2 then -1
								                                                            else 1
								                                                 end
								                                        end
								           ELSE 0
								       END ProfitRate
                from [PAYMENT_DETAIL] T1 
                INNER JOIN [PAYMENT] T2 ON T1.PaymentID = T2.ID  
                INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T3 ON T1.PaymentID = T3.PaymentID 
                INNER JOIN [ORDER] T4 ON T3.OrderID = T4.ID  AND T4.ProductType = 0 AND T4.PaymentStatus > 0 
                LEFT JOIN [BRANCH] T5 ON T2.BranchID = T5.ID 
                WHERE T2.PaymentTime >= T5.StartTime 
                AND T2.PaymentTime >= @BeginDay
                AND T2.PaymentTime <=@EndDay
                AND T4.CompanyID =@CompanyID
                AND ((T2.Type = 1 AND (T2.Status = 2 OR T2.Status = 3)) OR (T2.Type = 2 AND (T2.Status = 6 OR T2.Status = 7)))
                AND (( @branchId > 0 AND T2.BranchID = @BranchID) or @branchId <=0)
                GROUP BY T3.PaymentID,
                         T1.PaymentMode,
                         T2.OrderNumber,
                         T2.Type,
                         T2.IsUseRate,
                         CASE
									           WHEN T2.OrderNumber > 1 THEN case T2.IsUseRate 
									                                            when 1 then case T2.Type 
									                                                            when 2 then T1.ProfitRate * -1
									                                                            else T1.ProfitRate
									                                                        end
									                                            else case T2.Type 
									                                                            when 2 then -1
									                                                            else 1
									                                                 end
									                                        end
									           ELSE 0
								         END ) T20
          GROUP BY T20.PaymentID,
                   T20.PaymentMode,
                   T20.PaymentAmount,
                   T20.OrderNumber,
                   T20.Type,
                   T20.ProfitRate ) T21
    GROUP BY T21.PaymentID) T23
   where T22.PaymentID = T23.PaymentID
   ORDER BY T22.PaymentID 
   update @tmptable set Mark = '已取消' where OrderNumber in (
          select OrderNumber from @tmptable where Mark = '已取消'
          )
   select * from @tmptable ORDER BY OrderTime 
   END TRY

   BEGIN CATCH
      SELECT ERROR_MESSAGE() AS ErrorMessage
     ,ERROR_LINE() AS ErrorLINE
     ,ERROR_STATE() AS ErrorState
   END CATCH

end
GO

