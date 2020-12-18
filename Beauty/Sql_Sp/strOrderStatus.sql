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
        when 1 then 'δ���'
        when 2 then '�����'
        when 3 then '��ȡ��'
        when 4 then '����ֹ'
        else ''
    end
end
