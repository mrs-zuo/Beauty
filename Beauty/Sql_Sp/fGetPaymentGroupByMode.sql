SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('fGetPaymentGroupByMode') is not null
begin
  drop function fGetPaymentGroupByMode
end
go

create FUNCTION fGetPaymentGroupByMode(@CompanyID int, @BranchID int, @BeginDay varchar(100), @EndDay varchar(100))
RETURNS table as
return (
select 
    a.ID as PaymentID,
    sum(case b.PaymentMode when 0 then b.PaymentAmount * case a.IsUseRate when 1 then b.ProfitRate else 1 end else 0 end * case a.type when 2 then -1 else 1 end) as PayCash,
    sum(case b.PaymentMode when 1 then b.PaymentAmount * case a.IsUseRate when 1 then b.ProfitRate else 1 end else 0 end  * case a.type when 2 then -1 else 1 end) as PayMoneyBalance,
    sum(case b.PaymentMode when 2 then b.PaymentAmount * case a.IsUseRate when 1 then b.ProfitRate else 1 end else 0 end  * case a.type when 2 then -1 else 1 end) as PayBankCard,
    sum(case b.PaymentMode when 3 then b.PaymentAmount * case a.IsUseRate when 1 then b.ProfitRate else 1 end else 0 end  * case a.type when 2 then -1 else 1 end) as PayOther,
    sum(case b.PaymentMode when 6 then b.PaymentAmount * case a.IsUseRate when 1 then b.ProfitRate else 1 end else 0 end  * case a.type when 2 then -1 else 1 end) as PayPointBalance,
    sum(case b.PaymentMode when 7 then b.PaymentAmount * case a.IsUseRate when 1 then b.ProfitRate else 1 end else 0 end  * case a.type when 2 then -1 else 1 end) as PayCouponBalance,
    sum(case b.PaymentMode when 8 then b.PaymentAmount * case a.IsUseRate when 1 then b.ProfitRate else 1 end else 0 end  * case a.type when 2 then -1 else 1 end) as PayWeChatBalance,
    sum(case b.PaymentMode when 9 then b.PaymentAmount * case a.IsUseRate when 1 then b.ProfitRate else 1 end else 0 end  * case a.type when 2 then -1 else 1 end) as PayAlipayBalance,
    sum(case b.PaymentMode when 100 then b.PaymentAmount * case a.IsUseRate when 1 then b.ProfitRate else 1 end else 0 end  * case a.type when 2 then -1 else 1 end) as PayLoan,
    sum(case b.PaymentMode when 101 then b.PaymentAmount * case a.IsUseRate when 1 then b.ProfitRate else 1 end else 0 end  * case a.type when 2 then -1 else 1 end) as PayThird,
    sum(case a.IsUseRate
            when 1 then b.PaymentAmount * b.ProfitRate
            else b.PaymentAmount
        end * case a.type when 2 then -1 else 1 end) as ProfitAmount
from
    Payment a
    inner join PAYMENT_DETAIL b on b.PaymentID = a.ID
where a.CompanyID = @CompanyID
  and (@BranchID = 0 or a.BranchID = @BranchID)
  and a.PaymentTime >= @BeginDay
  and a.PaymentTime <= @EndDay
group by a.ID
)