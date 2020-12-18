SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('getServiceCountDeatailDefault', 'p') is not null
begin
  drop procedure getServiceCountDeatailDefault
end
go

create procedure getServiceCountDeatailDefault
  @BranchID integer,        --门店ID
  @cycleType integer,       --时间筛选类型(0:日 1：月 2：季 3：年 4：自定义)
  @startTime nvarchar(30),  --开始日期
  @endtime nvarchar(30)     --截至日期
AS
begin

   begin try

   --服务操作次数-服务次数分析(周期报表)
   select
     T4.Total,
     T4.IsDesignated,
     T5.ServiceName ObjectName
   from
   (
     select
       Count(T3.GroupNo) Total,
       T3.IsDesignated,
       T3.ServiceCode
     from
     (
       SELECT distinct
           T1.GroupNo,
           T2.IsDesignated,
           T3.Code as ServiceCode
       FROM
           [TREATMENT] T1
           INNER JOIN [TBL_TREATGROUP] T2 ON T1.GroupNo = T2.GroupNo
           inner join vorder T3 on T3.OrderID = T2.OrderID
       WHERE
           T1.BranchID = @BranchID
	   --状态：1：进行中 2:已完成 3：已取消 4：已终止 5：完成待确认
       AND T1.Status = 2
       AND T2.TGStatus = 2
       AND T3.Status <> 3
	   --记录类型 1:有效 2：无效 3：伦理删除
       AND T3.RecordType = 1
       AND T3.OrderTime > T3.StartTime
       --时间条件
       AND ((@cycleType = 0 and (DATEDIFF(dd, T2.TGEndTime, GETDATE()) = 0))
        or (@cycleType = 1 and (DATEPART(yy, T2.TGEndTime) = DATEPART(YY,GETDATE()) AND DATEPART(MM, T2.TGEndTime) = DATEPART(MM,GETDATE())))
        or (@cycleType = 2 and (DATEPART(qq, T2.TGEndTime) = DATEPART(qq, GETDATE()) AND DATEPART(yy, T2.TGEndTime) = DATEPART(yy,GETDATE())))
        or (@cycleType = 3 and (DATEPART(yy, T2.TGEndTime) = DATEPART(YY,GETDATE())))
        or (@cycleType = 4 and (T2.TGEndTime BETWEEN @startTime and @endtime)))
     ) T3
     GROUP BY T3.IsDesignated ,T3.ServiceCode) T4
   LEFT JOIN [SERVICE] T5 ON T4.ServiceCode = T5.Code AND T5.Available = 1
   order by T4.Total DESC

END TRY

  BEGIN CATCH
     SELECT ERROR_MESSAGE() AS ErrorMessage
    ,ERROR_LINE() AS ErrorLINE
    ,ERROR_STATE() AS ErrorState
  END CATCH

end