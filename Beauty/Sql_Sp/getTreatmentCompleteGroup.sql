SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('getTreatmentCompleteGroup', 'p') is not null
begin
  drop procedure getTreatmentCompleteGroup
end
go

create procedure getTreatmentCompleteGroup
  @CompanyID integer,       --公司ID
  @BranchID integer,        --门店ID
  @SlaveID integer,         --用户ID
  @cycleType integer,       --时间筛选类型(0:日 1：月 2：季 3：年 4：自定义)
  @startTime nvarchar(30),  --开始日期
  @endtime nvarchar(30)     --截至日期
AS
begin

   begin try

   --服务操作次数 指定次数 非指定次数（分组报表）
   select 
     Count(T3.GroupNo) Amount,
     T3.IsDesignated Type
   from
   (
     SELECT distinct
         T1.GroupNo, --TreatGroup ID
         T2.IsDesignated, --指定
         T2.OrderID
     FROM
         --TM表
         [TREATMENT] T1
         --服务组编号
         INNER JOIN [TBL_TREATGROUP] T2 ON T1.GroupNo = T2.GroupNo
         --状态：1:未完成、2：已完成 、3：已取消、4:已终止
         inner join vorder T3 on T3.OrderID = T2.OrderID
     WHERE
           T1.BranchID= @BranchID
       --状态：1：进行中 2:已完成 3：已取消 4：已终止 5：完成待确认
       AND T1.Status = 2
       --状态：1：进行中 2:已完成 3：已取消 4：已终止 5：完成待确认
       AND T2.TGStatus = 2
       AND T3.OrderTime > T3.StartTime
       AND T3.RecordType = 1
       AND T3.Status <> 3
       and T3.flag = 0
       and T1.ExecutorID in (
         select distinct
             P1.UserID
         from
             [ACCOUNT] P1
             INNER JOIN [TBL_USER_TAGS] P2 ON P1.UserID = P2.UserID
         WHERE
             P1.CompanyID = @CompanyID
         AND P2.Available = 1
         AND P2.TagID = @SlaveID)
       --时间条件
       AND ((@cycleType = 0 and (DATEDIFF(dd, T2.TGEndTime, GETDATE()) = 0))
        or (@cycleType = 1 and (DATEPART(yy, T2.TGEndTime) = DATEPART(YY,GETDATE()) AND DATEPART(MM, T2.TGEndTime) = DATEPART(MM,GETDATE())))
        or (@cycleType = 2 and (DATEPART(qq, T2.TGEndTime) = DATEPART(qq, GETDATE()) and DATEPART(yy, T2.TGEndTime) = DATEPART(yy,GETDATE())))
        or (@cycleType = 3 and (DATEPART(yy, T2.TGEndTime) =DATEPART(YY,GETDATE())))
        or (@cycleType = 4 and (T2.TGEndTime BETWEEN @startTime and @endtime)))
   ) T3 GROUP BY T3.IsDesignated

END TRY

  BEGIN CATCH
     SELECT ERROR_MESSAGE() AS ErrorMessage
    ,ERROR_LINE() AS ErrorLINE
    ,ERROR_STATE() AS ErrorState
  END CATCH

end