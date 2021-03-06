SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('FN_getMarriage', 'fn') is not null																		
begin																		
  drop function FN_getMarriage																		
end																		
go	

create FUNCTION FN_getMarriage (@Marriage TINYINT)
	RETURNS VARCHAR(10)
AS

	--------when 0 then 未婚
	--------when 1 then 已婚
	--------else null
	BEGIN
		DECLARE @RESULT VARCHAR(10)

		IF @Marriage = 0
			SET @RESULT = '未婚'
		ELSE IF @Marriage = 1
			SET @RESULT = '已婚'
		ELSE
			SET @RESULT = NULL
	
		RETURN @RESULT
	END