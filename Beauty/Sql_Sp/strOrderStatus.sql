SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('strOrderStatus') is not null
begin
  drop function strOrderStatus
end
go

create FUNCTION strOrderStatus(@OrderStatus int)
RETURNS nvarchar(10)
AS
begin
    return
    case @OrderStatus 
        when 1 then '未完成'
        when 2 then '已完成'
        when 3 then '已取消'
        when 4 then '已终止'
        else ''
    end
end
