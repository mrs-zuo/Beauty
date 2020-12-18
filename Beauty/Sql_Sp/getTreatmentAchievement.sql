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
  @BranchID integer,        --门店ID
  @SlaveID integer,         --用户ID
  @cycleType integer,       --时间筛选类型(0:日 1：月 2：季 3：年 4：自定义)
  @startTime nvarchar(30),  --开始日期
  @endtime nvarchar(30)     --截至日期
AS
begin

   begin try

   --服务操作业绩  指定业绩  非指定业绩
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
         --TM表
         [TREATMENT] T1
   	  --服务组编号
         INNER JOIN [TBL_TREATGROUP] T2 ON T1.GroupNo = T2.GroupNo
		 inner join vorder T3 on T3.OrderID = T2.OrderID
     WHERE
         
         T1.BranchID = @BranchID
     --状态：1：进行中 2:已完成 3：已取消 4：已终止 5：完成待确认
     AND T1.Status = 2
     --状态：1：进行中 2:已完成 3：已取消 4：已终止 5：完成待确认
     AND (T2.TGStatus = 2)
     AND T3.OrderTime > T3.StartTime
     --状态：1:未完成、2：已完成 、3：已取消、4:已终止
     AND T3.Status <> 3
     --总的TG数量
     AND T3.TGTotalCount > 0
     --记录类型 RecordType
     AND T3.RecordType = 1
	 --区分服务/商品
	 AND T3.flag = 0
     --objectType == 0
     and T1.ExecutorID = @SlaveID
     --时间条件
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
           --IsUseRate 是否使用业绩折算率计算业绩1：使用 2：不使用 3：未设置（默认）
           CASE ISNULL(T6.IsUseRate ,2)
             WHEN 1 THEN
               --支付金额 * 业绩折算率
               SUM(CASE T6.Type WHEN 1 THEN T9.PaymentAmount * T9.ProfitRate * dbo.getProfitrate(@SlaveID, T6.ID,3) ELSE T9.PaymentAmount * T9.ProfitRate * dbo.getProfitrate(@SlaveID, T6.ID,3) * -1 END)
               --最终售价
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