SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('getReChargeDeatilReport', 'p') is not null
begin
  drop procedure getReChargeDeatilReport
end
go

create procedure getReChargeDeatilReport
  @CompanyID integer,             --公司ID
  @BranchID integer,              --门店ID
  @BeginDay varchar(100),         --开始日期
  @EndDay varchar(100)            --结束日期
  
AS
begin

   begin try
    SELECT 
        T3.BranchName,
        T5.Name CustomerName,
        dbo.fgetStrPhoneNumber(T5.UserID, ' ') as CustomerPhoneNumber,
        T10.BranchName CustomerBranchName,
        T9.Name AS SourceName,
        T7.CardName,
        dbo.strMoneyActionMode(T2.ActionMode) as ActionMode,
        CONVERT(varchar(10),T1.CreateTime,111) CreateTime,
        SUBSTRING(CONVERT(varchar(6) ,T1.CreateTime ,12),3,4) + right('000000'+ cast(T1.ID AS VARCHAR(10)),6) + CONVERT(varchar(2) ,T1.CreateTime ,12) PaymentNumber,
        T2.Amount,
        CASE 
            WHEN T2.ActionMode = 3 AND T2.DepositMode = 1 THEN ISNULL(T2.Amount,0) 
            ELSE 0 
        END Cash,
        CASE 
            WHEN T2.ActionMode = 3 AND T2.DepositMode = 2 THEN ISNULL(T2.Amount,0) 
            ELSE 0 
        END Bank,
        CASE 
            WHEN T2.ActionMode = 3 AND T2.DepositMode = 4 THEN ISNULL(T2.Amount,0) 
            ELSE 0 
        END WeChat,
        CASE 
            WHEN T2.ActionMode = 3 AND T2.DepositMode = 5 THEN ISNULL(T2.Amount,0) 
            ELSE 0 
        END Alipay,
        CASE 
            WHEN T2.ActionMode = 4 OR T2.ActionMode = 5 OR T2.ActionMode = 6 THEN ISNULL(T2.Amount,0) 
            ELSE 0 
        END RelatedMoney,
        isnull(T8.PeopleCount, 0) as PeopleCount,
        case when T8.RoleName is not null and len(T8.RoleName) > 0 then SUBSTRING(T8.RoleName, 1, len(T8.RoleName) - 1) else '' end as RoleName,
        case when T8.ProfitName is not null and len(T8.ProfitName) > 0 then SUBSTRING(T8.ProfitName, 1, len(T8.ProfitName) - 1) else '' end as ProfitName,
        T1.Remark
    FROM 
        [TBL_CUSTOMER_BALANCE] T1
        INNER JOIN [TBL_MONEY_BALANCE] T2 ON T1.ID = T2.CustomerBalanceID
        LEFT JOIN [BRANCH] T3 ON T1.BranchID = T3.ID
        LEFT JOIN [CUSTOMER] T5 ON T1.UserID = T5.UserID
        LEFT JOIN [TBL_CUSTOMER_CARD] T6 ON T2.UserID = T6.UserID AND T2.UserCardNo = T6.UserCardNo 
        LEFT JOIN [BRANCH] T10 ON T5.BranchID = T10.ID
        LEFT JOIN [MST_CARD] T7 ON T7.ID = T6.CardID
        LEFT JOIN [TBL_CUSTOMER_SOURCE_TYPE] T9 ON T5.SourceType = T9.ID
        left join (
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
                      and s1.Type = 1
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
                      and s1.Type = 1
                      and s1.Available = 1
                      AND exists(select 1 from TBL_ACCOUNTBRANCH_RELATIONSHIP m2 where m2.CompanyID = @CompanyID and m2.Available = 1 and m2.UserID = s1.SlaveID)
                    for xml path('')
                    ) ProfitName
                FROM
                    [TBL_PROFIT] m1
                WHERE
                    m1.Available = 1
                AND m1.Type = 1
                AND exists(select 1 from TBL_ACCOUNTBRANCH_RELATIONSHIP m2 where m2.CompanyID = @CompanyID and m2.Available = 1 and m2.UserID = m1.SlaveID) 
                Group by MasterID
            ) T8 ON T8.MasterID = t1.ID

    WHERE T1.TargetAccount = 1 
      AND T1.CompanyID = @CompanyID 
      AND T1.CreateTime > @BeginDay 
      AND T1.CreateTime < @EndDay 						
      AND T2.ActionMode in (3, 4, 5, 6)  
      AND T2.DepositMode <> 3
      AND (@branchId = 0 or T1.BranchID = @BranchID)
    ORDER BY T2.ID   END TRY

   BEGIN CATCH
      SELECT ERROR_MESSAGE() AS ErrorMessage
     ,ERROR_LINE() AS ErrorLINE
     ,ERROR_STATE() AS ErrorState
   END CATCH

end
