SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('strMoneyActionMode') is not null
begin
  drop function strMoneyActionMode
end
go

create FUNCTION strMoneyActionMode(@MoneyActionMode int)
RETURNS nvarchar(20)
AS
begin
    return
    case @MoneyActionMode 
        when 1 then '����֧��'
        when 2 then '����֧������'
        when 3 then '��ֵ����ֵ'
        when 4 then '��ֵ����ֵ����'
        when 5 then '��ֵ��ֱ��'
        when 6 then '��ֵ��ֱ�۳���'
        when 7 then '��ֵ��ֱ������'
        when 8 then '��ֵ��ֱ�����ͳ���'
        when 9 then '��ֵ���˿�'
        when 10 then '��ֵ���˿��'
        else ''
    end
end
