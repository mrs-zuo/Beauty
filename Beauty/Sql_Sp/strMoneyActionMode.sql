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
        when 1 then '消费支出'
        when 2 then '消费支出撤销'
        when 3 then '储值卡充值'
        when 4 then '储值卡充值撤销'
        when 5 then '储值卡直扣'
        when 6 then '储值卡直扣撤销'
        when 7 then '储值卡直充赠送'
        when 8 then '储值卡直充赠送撤销'
        when 9 then '储值卡退款'
        when 10 then '储值卡退款撤销'
        else ''
    end
end
