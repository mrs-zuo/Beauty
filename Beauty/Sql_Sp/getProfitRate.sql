SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('getProfitRate', 'FN') is not null
begin
  drop function getProfitRate
end
go

CREATE function getProfitRate(
  @slaveid bigint,
  @paymentid bigint,
  @profitflg int --1:返回TBL_PROFIT表profitpct，2:返回PAYMENT表BranchProfitRate，3:返回TBL_PROFIT表profitpct*PAYMENT表BranchProfitRate
)
returns numeric(4,3)
AS
begin
    declare @result numeric(4,3) = null;

	if (@profitflg = 1)
	begin
		select @result = a.profitpct
		from TBL_PROFIT a
		where a.MasterID = @paymentid
		  and a.SlaveID = @slaveid
          and a.Available = 1
	end
	if (@profitflg = 2)
	begin
		select @result = case b.IsUseRate when 1 then b.BranchProfitRate else 1 end
		from TBL_PROFIT a
			 inner join PAYMENT b on b.ID = a.MasterID 
		where a.MasterID = @paymentid
		  and a.SlaveID = @slaveid
          and a.Available = 1
	end
	if (@profitflg = 3)
	begin
		select @result = a.profitpct * case b.IsUseRate when 1 then b.BranchProfitRate else 1 end 
		from TBL_PROFIT a
			 inner join PAYMENT b on b.ID = a.MasterID 
		where a.MasterID = @paymentid
		  and a.SlaveID = @slaveid
          and a.Available = 1
	end
    if @result is null 
        set @result = 0

    return @result
end
