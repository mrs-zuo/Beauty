SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('getTreatmentDetail', 'p') is not null
begin
  drop procedure getTreatmentDetail
end
go

create procedure getTreatmentDetail
  @CompanyID integer,             --公司ID
  @BranchID integer,              --门店ID
  @BeginDay varchar(100),         --开始日期
  @EndDay varchar(100)            --结束日期

AS
begin

   begin try
   SELECT
       T20.BranchName,
       T20.CustomerName,
       T20.CustomerPhoneNumber,
       T20.CustomerBranchName,
       T20.SourceName,
       T20.OrderTime,
       T20.ServiceName,
       T20.OrderNumber,
       T20.GroupNo,
       T20.TGTotalCount,
       T20.ServicePicName,
       isnull(T20.PeopleCnt, '1') PeopleCnt,
       CASE
           WHEN T20.SubServiceID IS NULL AND (t35.name is null or ltrim(t35.name) = '') then ''
           WHEN T20.SubServiceID IS NULL AND (t44.rolename is null or ltrim(t44.rolename) = '') then ''
           WHEN T20.SubServiceID IS NULL THEN left(t44.rolename, len(t44.rolename) - 1)
           when t15.name is null or ltrim(t15.name) = '' then ''
           when t24.rolename is null or ltrim(t24.rolename) = '' then ''
           else left(t24.rolename, len(t24.rolename) - 1)
       end rolename,
       CASE
           WHEN T20.SubServiceID IS NULL AND (t35.name is null or ltrim(t35.name) = '') then ''
           WHEN T20.SubServiceID IS NULL THEN left(t35.name, len(t35.name) - 1)
           when t15.name is null or ltrim(t15.name) = '' then ''
           else left(t15.name, len(t15.name) - 1)
       end name,
       T20.StartTime,
       T20.FinishTime,
       T20.SumOrigPrice,
       T20.SumSalePrice,
       isnull(T50.ProfitAmount,0.00) ProfitAmount,
       CASE T20.TGTotalCount
            WHEN '不限次' THEN 0
            ELSE isnull(T50.ProfitAmount,0.00)/convert(int,T20.TGTotalCount)
       END averagePrice,
       T20.SubServiceName,
       T20.IsDesignated ,
       case
           WHEN T20.SubServiceID IS NULL AND (T46.Remark is null or ltrim(T46.Remark) = '') then ''
           WHEN T20.SubServiceID IS NULL THEN left(T46.Remark, len(T46.Remark) - 1)
           when T26.Remark is null or ltrim(T26.Remark) = '' then ''
           else left(T26.Remark, len(T26.Remark) - 1)
       end Remark,
       T20.Remark Remark2
   from (SELECT
             min(T1.ID) as minid,
             T1.SubServiceID,
             T5.BranchName BranchName,
             T7.Name CustomerName,
             T60.CustomerPhoneNumber,
             T38.BranchName CustomerBranchName,
             T13.Name AS SourceName,
             CONVERT(varchar(10),T3.OrderTime,111) OrderTime,
             T8.ServiceName ServiceName,
             SUBSTRING(CONVERT(varchar(6) ,T3.CreateTime ,12),3,4) + right('000000'+ cast(T3.ID AS VARCHAR(10)),6) + CONVERT(varchar(2) ,T3.CreateTime ,12) OrderNumber,
             CAST(T1.GroupNo as varchar(16)) GroupNo,
             CASE T4.TGTotalCount
                  WHEN 0 THEN '不限次'
                  ELSE CONVERT(VARCHAR(20),T4.TGTotalCount)
             END TGTotalCount,
             max(t51.name) as ServicePicName,
             CASE T1.SubServiceID
                  WHEN NULL THEN T11.PeopleCnt
                  ELSE T10.PeopleCnt
             END PeopleCnt,
             CONVERT(varchar(10),T1.StartTime,111) StartTime,
             CONVERT(varchar(10),T1.FinishTime,111) FinishTime,
             T4.SumOrigPrice SumOrigPrice,
             T4.SumSalePrice SumSalePrice,
             0.00 as ProfitAmount,
             T10.SubServiceName SubServiceName,
             CASE T1.IsDesignated
                  WHEN 1 THEN '指定'
                  ELSE '不指定'
             END IsDesignated ,
             T2.Remark,
             T3.ID OrderID
         from [TREATMENT] T1
              INNER JOIN [TBL_TREATGROUP] T2 ON T1.GroupNo  = T2.GroupNo  AND T2.TGStatus = 2
              INNER JOIN [ORDER] T3 ON T2.OrderID = T3.ID AND T3.ProductType = 0 and T3.RecordType = 1
              INNER JOIN [TBL_ORDER_SERVICE] T4 ON T3.ID = T4.OrderID
              LEFT JOIN [TBL_CUSTOMER_CARD] T37 ON T37.UserCardNo = T4.UserCardNo
              LEFT JOIN [BRANCH] T5 ON T2.BranchID = T5.ID
              LEFT JOIN [CUSTOMER] T7 ON T4.CustomerID = T7.UserID
              left join (select UserID, max(PhoneNumber) as CustomerPhoneNumber from PHONE group by UserID) T60 on T60.UserID = T7.UserID
              LEFT JOIN [BRANCH] T38 ON T7.BranchID = T38.ID
              LEFT JOIN [SERVICE] T8 ON T4.ServiceID = T8.ID
              inner join ACCOUNT t51 on t51.UserID = T2.ServicePIC
              LEFT JOIN (
                  select
                      COUNT(isnull(T9.SubServiceID, '')) PeopleCnt,
                      T9.GroupNo,
                      T9.SubServiceID,
                      ISNULL(T14.SubServiceName,'服务') SubServiceName
                  from [TREATMENT] T9
                  LEFT JOIN [TBL_SUBSERVICE] T14 ON T9.SubServiceID = T14.ID
                  where T9.CompanyID =@CompanyID
                  and
                  T9.Status <> 3
                  and T9.Status <> 4
                  Group by T9.GroupNo ,
                           T14.SubServiceName,
                           T9.SubServiceID
              ) T10 ON T1.GroupNo = T10.GroupNo AND T1.SubServiceID = T10.SubServiceID
              LEFT JOIN (
                  select
                      COUNT(T12.ID) PeopleCnt,
                      T12.GroupNo
                  from [TREATMENT] T12
                  where T12.CompanyID =@CompanyID
                  and
                  T12.Status <> 3
                  and T12.Status <> 4
                  Group by T12.GroupNo
              ) T11 ON T1.GroupNo = T11.GroupNo
              LEFT JOIN [TBL_CUSTOMER_SOURCE_TYPE] T13 ON T7.SourceType = T13.ID
         WHERE  T1.FinishTime >= @BeginDay
         AND T1.FinishTime <= @EndDay
         AND T1.CompanyID =@CompanyID
         AND
         T2.TGEndTime > T5.StartTime
         AND T1.Status = 2
         AND (( @branchId > 0 AND T2.BranchID = @BranchID) or @branchId <=0)
         Group by
             T1.SubServiceID,
             T5.BranchName,
             T7.Name ,
             T60.CustomerPhoneNumber,
             T13.Name  ,
             CONVERT(varchar(10),T3.OrderTime,111) ,
             T8.ServiceName,
             SUBSTRING(CONVERT(varchar(6) ,T3.CreateTime ,12),3,4) + right('000000'+ cast(T3.ID AS VARCHAR(10)),6) + CONVERT(varchar(2) ,T3.CreateTime ,12) ,
             CAST(T1.GroupNo as varchar(16)) ,
             TGTotalCount,
             T10.PeopleCnt,
             CONVERT(varchar(10),T1.StartTime,111) ,
             CONVERT(varchar(10),T1.FinishTime,111),
             T4.SumOrigPrice,
             T4.SumSalePrice,
             T10.SubServiceName,
             T1.IsDesignated,
             T3.ID,
             T2.Remark,
             T4.OrderID,
             T1.GroupNo,
             T38.BranchName
             ) T20
   left join (
       select
           T18.SubServiceID,
           T18.GroupNo,
           (select
               isnull(t21.rolename,' ') + ', '
            from
               TREATMENT t19
               left join ACCOUNT t20 on t19.ExecutorID = t20.UserID
               left join TBL_ROLE t21 on t21.id = t20.roleid
            where
               t19.SubServiceID = t18.SubServiceID AND
               t19.GroupNo = t18.GroupNo AND
               t19.CompanyID =@CompanyID
            for xml path('')
           )  rolename
       from
           [TREATMENT] T18
       GROUP BY
               T18.SubServiceID,
               T18.GroupNo
   ) T24 on  T20.SubServiceID = T24.SubServiceID AND T20.GroupNo = T24.GroupNo
   left join (
       select
           T25.SubServiceID,
           T25.GroupNo,
           (select
               t23.Name + ', '
            from
               TREATMENT t22
               left join ACCOUNT t23 on t22.ExecutorID = t23.UserID
            where
               t22.SubServiceID = t25.SubServiceID AND
               t22.GroupNo = t25.GroupNo AND
               t22.CompanyID =@CompanyID
            for xml path('')
           )  name
       from
           [TREATMENT] T25
       GROUP BY
               T25.SubServiceID,
               T25.GroupNo
   ) T15 on  T20.SubServiceID = T15.SubServiceID AND T20.GroupNo = T15.GroupNo
   left join (
       select
           T27.SubServiceID,
           T27.GroupNo,
           (select
               isnull(t28.Remark,' ') + ', '
            from
               TREATMENT t28
            where
               t28.SubServiceID = t27.SubServiceID AND
               t28.GroupNo = t27.GroupNo AND
               t28.CompanyID =@CompanyID
            for xml path('')
           )  Remark
       from
           [TREATMENT] T27
       GROUP BY
               T27.SubServiceID,
               T27.GroupNo
   ) T26 on  T20.SubServiceID = T26.SubServiceID AND T20.GroupNo = T26.GroupNo
   left join (
       select
           T38.GroupNo,
           (select
               isnull(t41.rolename,' ') + ', '
            from
               TREATMENT t39
               left join ACCOUNT t40 on t39.ExecutorID = t40.UserID
               left join TBL_ROLE t41 on t41.id = t40.roleid
            where
               t39.GroupNo = t38.GroupNo AND
               t39.CompanyID =@CompanyID
            for xml path('')
           )  rolename
       from
           [TREATMENT] T38
       GROUP BY
               T38.GroupNo
   ) T44 on T20.GroupNo = T44.GroupNo
   left join (
       select
           T45.GroupNo,
           (select
               t43.Name + ', '
            from
               TREATMENT t42
               left join ACCOUNT t43 on t42.ExecutorID = t43.UserID
            where
               t42.GroupNo = t45.GroupNo AND
               t42.CompanyID =@CompanyID
            for xml path('')
           )  name
       from
           [TREATMENT] T45
       GROUP BY
               T45.GroupNo
   ) T35 on T20.GroupNo = T35.GroupNo
   left join (
       select
           T47.GroupNo,
           (select
               isnull(t48.Remark,' ') + ', '
            from
               TREATMENT t48
            where
               t48.GroupNo = t47.GroupNo AND
               t48.CompanyID =@CompanyID
            for xml path('')
           )  Remark
       from
           [TREATMENT] T47
       GROUP BY
               T47.GroupNo
   ) T46 on T20.GroupNo = T46.GroupNo
   left join (
       select T3.ID OrderID,
              CASE max(T6.IsUseRate)
                  WHEN 1 THEN  SUM(CASE T6.Type
                                       WHEN
1
                                        THEN
                                             (case T7.paymentmode when 6 then 0 when 7 then 0 else T7.PaymentAmount end)
                                       ELSE T7.PaymentAmount * T7.ProfitRate * -1
                                   END)
                  ELSE max(T3.TotalSalePrice)  - SUM(CASE T7.PAYMENTMODE WHEN 6 THEN T7.PaymentAmount WHEN 7 THEN T7.PaymentAmount ELSE 0 END)
              END ProfitAmount
       from [ORDER] T3
       LEFT JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T5 ON T3.ID = T5.OrderID
       LEFT JOIN [PAYMENT] T6 ON T5.PaymentID = T6.ID
       LEFT JOIN [PAYMENT_DETAIL] T7 ON T6.ID = T7.PaymentID
       LEFT JOIN [BRANCH] T4 ON T3.BranchID = T4.ID
       WHERE  T3.ProductType = 0
       and T3.RecordType = 1
       and  T3.CompanyID =@CompanyID
       AND T3.OrderTime > T4.StartTime
       group by T3.ID
       --         T6.IsUseRate,
       --         T3.TotalSalePrice
   ) T50 on T50.OrderID = T20.OrderID
   ORDER BY T20.OrderTime
            --T20.OrderID,
            --T20.GroupNo,
            --T20.minid
   END TRY

   BEGIN CATCH
      SELECT ERROR_MESSAGE() AS ErrorMessage
     ,ERROR_LINE() AS ErrorLINE
     ,ERROR_STATE() AS ErrorState
   END CATCH

end

GO
