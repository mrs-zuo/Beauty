SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('getCommodityDeatilReport', 'p') is not null
begin
  drop procedure getCommodityDeatilReport
end
go

create procedure getCommodityDeatilReport
  @CompanyID integer,             --公司ID
  @BranchID integer,              --门店ID
  @BeginDay varchar(100),         --开始日期
  @EndDay varchar(100)            --结束日期

AS
begin

   begin try
    select
        b.BranchName,
        e.Name as CustomerName,
        dbo.fgetStrPhoneNumber(e.UserID, ' ') as CustomerPhoneNumber,
        f.BranchName as CustomerBranchName,
        g.Name as SourceName,
        CONVERT(varchar(10), c.OrderTime, 111) as OrderTime,
        d.CommodityName,
        SUBSTRING(CONVERT(varchar(6) ,c.OrderTime ,12),3,4) + right('000000'+ cast(c.OrderID AS VARCHAR(10)),6) + CONVERT(varchar(2) ,c.OrderTime ,12) OrderNumber,
        c.Quantity,
        c.TotalOrigPrice,
        c.TotalSalePrice,
        n.ProfitAmount,
        CONVERT(varchar(10), a.PaymentTime, 111)  PaymentTime,
        SUBSTRING(CONVERT(varchar(6) ,a.PaymentTime ,12),3,4) + right('000000'+ cast(a.ID AS VARCHAR(10)),6) + CONVERT(varchar(2) ,a.PaymentTime ,12) PaymentNumber,
        n.PayCash,
        n.PayBankCard,
        n.PayWeChatBalance,
        n.PayAlipayBalance,
        n.PayMoneyBalance,
        n.PayPointBalance,
        n.PayCouponBalance,
        n.PayLoan,
        n.PayThird,
        n.PayOther,
        CASE
            WHEN a.ClientType in (1, 3) THEN '商家'
            WHEN a.ClientType in (2, 4) THEN '顾客'
            ELSE ''
        END ClientType,
        i.PeopleCount,
        case when i.RoleName is not null and len(i.RoleName) > 0 then SUBSTRING(i.RoleName, 1, len(i.RoleName) - 1) else '' end as RoleName,
        case when i.ProfitName is not null and len(i.ProfitName) > 0 then SUBSTRING(i.ProfitName, 1, len(i.ProfitName) - 1) else '' end as ProfitName,
        dbo.strOrderStatus(c.OrderStatus) as OrderStatus,
        m.PolicyName,
        a.Remark
    from
        PAYMENT a
        inner join BRANCH b on b.ID = a.BranchID
        inner join (
            select 
                c1.PaymentID, 
                max(c1.OrderID) as OrderID,
                max(c2.CustomerID) as CustomerID,
                max(c2.OrderTime) as OrderTime,
                max(c2.Quantity) as Quantity,
                sum(c2.TotalOrigPrice) as TotalOrigPrice,
                sum(c2.TotalSalePrice) as TotalSalePrice,
                max(c2.Status) as OrderStatus
            from 
                TBL_ORDERPAYMENT_RELATIONSHIP c1
                inner join [order] c2 on c2.ID = c1.OrderID and c2.PaymentStatus > 0  and  c2.ProductType = 1
            group by c1.PaymentID)c on c.PaymentID = a.ID
        inner join(
            select 
                d1.ID as PaymentID,
                (select
                    d2.CommodityName + ' '
                from
                    TBL_ORDER_COMMODITY d2
                    inner join TBL_ORDERPAYMENT_RELATIONSHIP d3 on d3.OrderID = d2.OrderID
                where d3.PaymentID = d1.ID
                group by d2.CommodityName
                for xml path ('')
                ) as CommodityName
            from
                PAYMENT d1
            group by d1.ID
        ) d on d.PaymentID = a.ID
        inner join CUSTOMER e on e.UserID = c.CustomerID
        inner join BRANCH f on f.ID = e.BranchID
        left join TBL_CUSTOMER_SOURCE_TYPE g on g.ID = e.SourceType and g.RecordType = 1
        inner JOIN (
                SELECT
                    MasterID,
                    Count(1) PeopleCount,
                    (select
                        isnull(s3.rolename,' ') + ', '
                    from
                        tbl_profit s1
                        left join ACCOUNT s2 on s1.SlaveID = s2.UserID
                        left join TBL_ROLE s3 on s3.id = s2.roleid
                    where s1.masterid = m1.masterid
                      and s1.Type = 2
                      and s1.Available = 1
                      AND exists(select 1 from TBL_ACCOUNTBRANCH_RELATIONSHIP m2 where m2.CompanyID = @CompanyID and m2.Available = 1 and m2.UserID = s1.SlaveID)
                    for xml path('')
                    ) RoleName,
                    (select
                        s2.Name  + '(' + convert(varchar(12), convert(int, s1.ProfitPct * 100)) + '%)' + ', '
                    from
                    tbl_profit s1
                    left join ACCOUNT s2 on s1.SlaveID = s2.UserID
                    where s1.masterid = m1.masterid
                      and s1.Type = 2
                      and s1.Available = 1
                      AND exists(select 1 from TBL_ACCOUNTBRANCH_RELATIONSHIP m2 where m2.CompanyID = @CompanyID and m2.Available = 1 and m2.UserID = s1.SlaveID)
                    for xml path('')
                    ) ProfitName
                FROM
                    [TBL_PROFIT] m1
                WHERE
                    m1.Available = 1
                AND m1.Type = 2
                AND exists(select 1 from TBL_ACCOUNTBRANCH_RELATIONSHIP m2 where m2.CompanyID = @CompanyID and m2.Available = 1 and m2.UserID = m1.SlaveID) 
                Group by MasterID
            ) i ON a.status = 6 and a.TargetPaymentID = i.MasterID or a.status <> 6 and a.ID = i.MasterID
            left JOIN [TBL_CUSTOMER_BENEFIT] l ON c.CustomerID = l.UserID AND c.OrderID = l.OrderID AND l.BenefitStatus = 2
            LEFT JOIN [TBL_BENEFIT_POLICY] m ON l.PolicyID = m.PolicyID
            inner join dbo.fGetPaymentGroupByMode(@CompanyID, @BranchID, @BeginDay, @EndDay) n on n.PaymentID = a.ID
    where a.CompanyID = @CompanyID
      and (@BranchID = 0 or a.BranchID = @BranchID)
      and a.PaymentTime >= @BeginDay
      and a.PaymentTime <= @EndDay
      and a.PaymentTime > b.StartTime
      and ((a.Type = 1 AND a.Status in (2, 3)) OR (a.Type = 2 AND a.Status in (6, 7)))
    order by a.ID   
   END TRY

   BEGIN CATCH
      SELECT ERROR_MESSAGE() AS ErrorMessage
     ,ERROR_LINE() AS ErrorLINE
     ,ERROR_STATE() AS ErrorState
   END CATCH

end
