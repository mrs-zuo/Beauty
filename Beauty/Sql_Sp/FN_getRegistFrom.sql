SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('FN_getRegistFrom', 'fn') is not null																		
begin																		
  drop function FN_getRegistFrom																		
end																		
go	

---------CASE RegistFrom WHEN 0 THEN '商家注册' WHEN 1 THEN '顾客导入' WHEN 2 THEN '自助注册(T站)' END RegistFrom
create FUNCTION FN_getRegistFrom (@RegistFrom TINYINT)
	RETURNS VARCHAR(10)
AS
	BEGIN
		DECLARE @RESULT VARCHAR(10)

		IF @RegistFrom = 0
			SET @RESULT = '商家注册'
		ELSE IF @RegistFrom = 1
			SET @RESULT = '顾客导入'
		ELSE
			SET @RESULT = '自助注册(T站)'

		RETURN @RESULT
	END