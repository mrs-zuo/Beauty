SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('getAccountReportList', 'p') is not null
begin
  drop procedure getAccountReportList
end
go

create procedure getAccountReportList
  @SuperiorID integer    --店员ID
AS
begin

   begin try

      --抽取员工报表数据一览
      with
      SubQuery(SubordinateID, SuperiorID, LV, TreePath) as
      (
        select
           SubordinateID, --下级店员ID
           SuperiorID,      --上级店员ID
           0 as LV,
           convert(varchar(max), ID) as TreePath
        from
           HIERARCHY --层级
        where
           SuperiorID = @SuperiorID
        union all
        select
           T1.SubordinateID,
           T1.SuperiorID,
           T2.LV + 1,
           T2.TreePath + right('000000000' + convert(varchar(max), T1.ID), 9)
        from
           HIERARCHY T1
           inner join SubQuery T2 on T1.SuperiorID = T2.SubordinateID and lv < 10
      )

      select
         left('                    ', min(T1.LV) * 2) + max(T2.Name) ObjectName,
         T1.SubordinateID ObjectID
      from
         SubQuery T1
         inner JOIN [ACCOUNT] T2 ON T1.SubordinateID = T2.UserID
      group by T1.SubordinateID
      order by min(T1.TreePath)

END TRY

  BEGIN CATCH
     SELECT ERROR_MESSAGE() AS ErrorMessage
    ,ERROR_LINE() AS ErrorLINE
    ,ERROR_STATE() AS ErrorState
  END CATCH

end