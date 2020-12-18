SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

if object_id('getNoDeliveryCommodity', 'p') is not null
begin
  drop procedure getNoDeliveryCommodity
end
go


CREATE procedure getNoDeliveryCommodity
  @CompanyID integer,             --公司ID
  @BranchID integer               --门店ID
  
AS
begin

   begin try
   

   select T3.BranchName,
          T4.Name CustomerName,
          T10.BranchName CustomerBranchName,
          T4.Title,
          case
              when T13.PhoneNumber is null or ltrim(T13.PhoneNumber) = '' then ''
              else left(T13.PhoneNumber, len(T13.PhoneNumber) - 1)
          end PhoneNumber,
          T5.LoginMobile,
          CASE T4.Gender 
              WHEN 0 THEN '女' 
              WHEN 1 THEN '男' 
              WHEN 2 THEN '其他' 
          END  Gender ,
          T1.CommodityName,
          T1.Quantity,
          T1.DeliveredAmount,
          T1.Quantity - T1.DeliveredAmount,
          T1.SumSalePrice,
          T2.UnPaidPrice,
          T7.LastSendTime,
          T8.Name ResponsiblePersionName
   from [TBL_ORDER_COMMODITY] T1 
   INNER JOIN [ORDER] T2 ON T2.ID = T1.OrderID 
   LEFT JOIN [BRANCH] T3 ON T1.BranchID = T3.ID
   LEFT JOIN [CUSTOMER] T4 ON T2.CustomerID = T4.UserID
   LEFT JOIN [TBL_CUSTOMER_CARD] T14 ON T14.UserCardNo = T1.UserCardNo 
   LEFT JOIN [BRANCH] T10 ON T4.BranchID = T10.ID
   LEFT JOIN [USER] T5 ON T2.CustomerID = T5.id
   LEFT JOIN (select max(T6.CreateTime) LastSendTime,
                     T6.OrderID 
              from [TBL_COMMODITY_DELIVERY] T6 
              WHERE T6.CompanyID=@CompanyID 
              AND T6.Status =2 
              group by T6.OrderID) T7 ON T1.OrderID = T7.OrderID
   LEFT JOIN [TBL_BUSINESS_CONSULTANT] T9 ON T9.BusinessType = 1 AND T9.MasterID = T1.OrderID AND T9.ConsultantType = 1			
   LEFT JOIN [ACCOUNT] T8 ON T9.ConsultantID = T8.UserID
   LEFT JOIN (select 
                   T11.CustomerID,
                   (select T12.PhoneNumber + ', '  
                    from [PHONE] T12 
   		              WHERE T12.CompanyID=@CompanyID 
   		              AND T12.Available = 1	
   	    	          AND T12.UserID=T11.CustomerID
   		              for xml path('')) PhoneNumber
   		        from [TBL_ORDER_SERVICE] T11 group by T11.CustomerID
   		       ) T13 ON T13.CustomerID = T1.CustomerID
   WHERE (T1.Status = 1 OR T1.Status = 5)  
   AND T1.CompanyID=@CompanyID 
   AND T2.OrderTime > T3.StartTime
   AND (( @branchId > 0 AND T1.BranchID = @BranchID) or @branchId <=0)
   
   END TRY

   BEGIN CATCH
      SELECT ERROR_MESSAGE() AS ErrorMessage
     ,ERROR_LINE() AS ErrorLINE
     ,ERROR_STATE() AS ErrorState
   END CATCH

end
GO

