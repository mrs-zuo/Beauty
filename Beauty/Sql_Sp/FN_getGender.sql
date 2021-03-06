SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('FN_getGender', 'fn') is not null																		
begin																		
  drop function FN_getGender																		
end																		
go																		

create FUNCTION FN_getGender (@Gender TINYINT)
	RETURNS VARCHAR(10)
AS
	------when 0 then 女
	------when 1 then 男
	------else 其他
	BEGIN
		DECLARE @SEX VARCHAR(10)
		
		IF @Gender = 0
			SET @SEX = '女'
		ELSE IF @Gender = 1
			SET @SEX = '男'
		ELSE
			SET @SEX = '其他'
		
		RETURN @SEX
	END