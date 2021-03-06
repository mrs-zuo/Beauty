SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('FN_getHeightOrWeight', 'fn') is not null																		
begin																		
  drop function FN_getHeightOrWeight																		
end																		
go	

create FUNCTION FN_getHeightOrWeight (@Height decimal(4,1))
	RETURNS decimal(4,1)
AS
	----如果0就设置为空
	BEGIN
		DECLARE @RESULT decimal(4,1)

		IF @Height = 0
			SET @RESULT = null
		ELSE	
			SET @RESULT = @Height

		RETURN @RESULT
	END