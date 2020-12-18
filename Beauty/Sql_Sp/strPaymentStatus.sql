SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('strPaymentStatus') is not null
begin
  drop function strPaymentStatus
end
go

create FUNCTION strPaymentStatus(@PaymentStatus int)
RETURNS nvarchar(10)
AS
begin
    return
    case @PaymentStatus 
        when 1 then '未支付'
        when 2 then '部分付'
        when 3 then '已支付'
        when 4 then '已退款'
        when 5 then '免支付'
        else ''
    end
end
