SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('NewAddCustomerDefault', 'p') is not null
begin
  drop procedure NewAddCustomerDefault
end
go

create procedure NewAddCustomerDefault
  @BranchID integer,        --门店ID
  @cycleType integer,       --时间筛选类型(0:日 1：月 2：季 3：年 4：自定义)
  @startTime nvarchar(30),  --开始日期
  @endtime nvarchar(30)     --截至日期
AS
begin

   begin try

   --我的/员工报表 顾客筛选（周期报表）
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
         --是否有效
         T1.Available = 1
     AND T1.RegistFrom <> 1
     AND T1.BranchID = @BranchID
     --时间
     AND ((@cycleType = 0 and (DATEDIFF(dd, T1.CreateTime, GETDATE()) = 0))
      or (@cycleType = 1 and (DATEPART(yy, T1.CreateTime) = DATEPART(YY,GETDATE()) AND DATEPART(MM, T1.CreateTime) = DATEPART(MM,GETDATE())))
      or (@cycleType = 2 and (DATEPART(qq, T1.CreateTime) = DATEPART(qq, GETDATE()) and DATEPART(yy, T1.CreateTime) = DATEPART(yy,GETDATE())))
      or (@cycleType = 3 and (DATEPART(yy, T1.CreateTime) =DATEPART(YY,GETDATE())))
      or (@cycleType = 4 and (T1.CreateTime BETWEEN @startTime and @endtime)))
   ) T3

END TRY

  BEGIN CATCH
     SELECT ERROR_MESSAGE() AS ErrorMessage
    ,ERROR_LINE() AS ErrorLINE
    ,ERROR_STATE() AS ErrorState
  END CATCH

end

