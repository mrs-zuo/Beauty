SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('getServiceRevenueGroup', 'p') is not null
begin
  drop procedure getServiceRevenueGroup
end
go

create procedure getServiceRevenueGroup
  @CompanyID integer,       --公司ID
  @BranchID integer,        --门店ID
  @SlaveID integer,         --用户ID
  @cycleType integer,       --时间筛选类型(0:日 1：月 2：季 3：年 4：自定义)
  @startTime nvarchar(30),  --开始日期
  @endtime nvarchar(30)     --截至日期
AS
begin

   begin try

   --报表-服务销售额（分组报表）
   select
     --IsUseRate 是否使用业绩折算率计算业绩1：使用 2：不使用 3：未设置（默认） ProfitRate 业绩折算率
     --Type 1：支付 2：退款 3：未支付(第三方支付数据)
     sum(B.PaymentAmount * B.ProfitRate * B.typeflag) as SalesAmount,
     --支付方式：0:现金、1:储值卡、2:银行卡。3:其他 4:免支付 5：过去支付 6:积分 7：现金券 8：微信第三方支付 9：支付宝第三方支付 100：消费贷款 101：第三方收款
     B.PaymentMode,
     SUM(sum(B.PaymentAmount * B.ProfitRate * B.typeflag))over() as TotalAmount
   from
     VORDER A 
     left join VPAYMENT B on B.OrderID = A.OrderID
     --0:个人 1：分店 2：公司 3:分组 object = 3      MasterID 收益项目ID     Type 是否可用
       INNER JOIN (
           select
               distinct P1.MasterID,
               P2.TagID
           from
               [TBL_PROFIT] P1
               INNER JOIN [TBL_USER_TAGS] P2 ON P1.SlaveID = P2.UserID
           where
               P1.Available = 1
           AND P1.Type = 2
           AND P2.Available = 1
           and P2.CompanyID = @CompanyID) P3 ON B.PaymentID = P3.MasterID
   WHERE
       --抽出条件（商品/服务筛选条件没有用到所以删除）
       B.PaymentTime >= A.StartTime
   and B.BranchID = @BranchID
   --Status 1：无效 2：支付执行 3：支付撤销 4:过去支付执行 5:过去支付撤消 6：支付撤销退款 7：订单终止退款  Type 1：支付 2：退款 3：未支付(第三方支付数据)
   AND ((B.Type = 1 AND (B.Status in (2, 3))) OR (B.Type = 2 AND (B.Status in (6, 7))))
   AND A.PaymentStatus > 0
   AND A.ProductType = 0
   --商品/服务flag 服务0
   and A.flag = 0
   AND P3.TagID = @SlaveID
   --时间条件
   AND ((@cycleType = 0 and (DATEDIFF(dd, B.PaymentTime, GETDATE()) = 0))
    or (@cycleType = 1 and (DATEPART(yy, B.PaymentTime) = DATEPART(YY,GETDATE()) AND DATEPART(MM, B.PaymentTime) = DATEPART(MM,GETDATE())))
    or (@cycleType = 2 and (DATEPART(qq, B.PaymentTime) = DATEPART(qq, GETDATE()) and DATEPART(yy, B.PaymentTime) = DATEPART(yy,GETDATE())))
    or (@cycleType = 3 and (DATEPART(yy, B.PaymentTime) =DATEPART(YY,GETDATE())))
    or (@cycleType = 4 and (B.PaymentTime BETWEEN @startTime and @endtime)))
   GROUP BY B.PaymentMode
   order by B.PaymentMode

END TRY

  BEGIN CATCH
     SELECT ERROR_MESSAGE() AS ErrorMessage
    ,ERROR_LINE() AS ErrorLINE
    ,ERROR_STATE() AS ErrorState
  END CATCH

end