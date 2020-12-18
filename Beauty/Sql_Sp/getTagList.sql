SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('getTagList', 'p') is not null
begin
  drop procedure getTagList
end
go

create procedure getTagList
  @CompanyID integer,        --公司ID
  @Type integer              --1：NOTEPAD 2 用户分组
AS
begin

   begin try

   SELECT
       ID,
       Name
   FROM
       TBL_TAG 
   WHERE
       CompanyID = @CompanyID
   AND [Type] = @Type
   AND Available =1

END TRY

  BEGIN CATCH
     SELECT ERROR_MESSAGE() AS ErrorMessage
    ,ERROR_LINE() AS ErrorLINE
    ,ERROR_STATE() AS ErrorState
  END CATCH

end