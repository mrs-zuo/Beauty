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
        when 1 then 'δ֧��'
        when 2 then '���ָ�'
        when 3 then '��֧��'
        when 4 then '���˿�'
        when 5 then '��֧��'
        else ''
    end
end
