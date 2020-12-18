using BLToolkit.Data;
using HS.Framework.Common.Util;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL
{
    public class ReportDownload_DAL
    {
        #region 构造类实例
        public static ReportDownload_DAL Instance
        {
            get
            {
                return Nested.instance;
            }
        }

        class Nested
        {
            static Nested()
            {
            }
            internal static readonly ReportDownload_DAL instance = new ReportDownload_DAL();
        }
        #endregion


        /// <summary>
        /// 下载顾客报表
        /// </summary>
        /// <param name="companyId"></param>
        /// <returns></returns>
        public DataTable getCustomerReport(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSql = @"  select DISTINCT T2.UserID, T2.Name,T2.Title ,T5.PhoneNumber , T8.Address,T1.LoginMobile,[dbo].[FN_getGender](T2.Gender) Gender,CONVERT(varchar(10), T2.BirthDay, 111) BirthDay,[dbo].[FN_getHeightOrWeight](T2.Height) Height,[dbo].[FN_getHeightOrWeight](T2.Weight) Weight,T2.BloodType,[dbo].[FN_getMarriage](T2.Marriage) Marriage ,T2.Profession,T9.BranchName,CONVERT(varchar(10), T2.CreateTime, 111) CreateTime,T2.Remark,[dbo].[FN_getRegistFrom](T2.RegistFrom) RegistFrom,T12.Name AS SourceTypeName ,'' AS LastVisit,ISNULL(T13.TotalSale,0) AS TotalSale,0 as IsRed,ISNULL(T11.LostRemind,0) LostRemind
                                     from [USER] T1 INNER JOIN
                                    [CUSTOMER] T2 ON T1.ID = T2.UserID 
                                      LEFT JOIN (select T3.UserID,T3.PhoneNumber from [PHONE] T3  WHERE T3.ID IN (
                                    select MIN(T4.ID) FROM [PHONE] T4 WHERE T4.Available = 1 GROUP BY T4.UserID)) T5 ON T2.UserID = T5.UserID LEFT JOIN (select T6.UserID,T6.Address from [ADDRESS] T6  WHERE T6.ID IN (
                                    select MIN(T7.ID) FROM [ADDRESS] T7 WHERE T7.Available = 1 GROUP BY T7.UserID)) T8 ON T2.UserID = T8.UserID 
                                    LEFT JOIN [BRANCH] T9 ON T2.BranchID = T9.ID 
									LEFT JOIN [BRANCH] T11 ON T11.ID = @BranchID
									LEFT JOIN [TBL_CUSTOMER_SOURCE_TYPE] T12 ON T2.SourceType = T12.ID LEFT JOIN (
                                        select sum(TotalSalePrice - UnPaidPrice - RefundSumAmount) TotalSale, CustomerID from [ORDER] where (@BeginDay is null or [ORDER].OrderTime >= @BeginDay) and (@EndDay is null or [ORDER].OrderTime <= @EndDay) group by CustomerID) T13 ON T13.CustomerID = T2.USERID";
                if (branchId > 0)
                {
                    strSql += "  INNER JOIN [RELATIONSHIP] T10 ON T2.UserID = T10.CustomerID AND T10.Available = 1 AND T10.BranchID =" + branchId.ToString();
                }
                strSql += "  WHERE T1.UserType = 0 AND T1.CompanyID =@CompanyID AND T2.Available = 1 ORDER BY T2.USERID ";

                DataTable dt = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32), db.Parameter("@BranchID", branchId, DbType.Int32), db.Parameter("@BeginDay", beginDay, DbType.DateTime2)
                    , db.Parameter("@EndDay", endDay, DbType.DateTime2)).ExecuteDataTable();

                //string strSqlPhone = @" select T1.UserID,T1.PhoneNumber from [PHONE] T1 WHERE T1.CompanyID=@CompanyID AND T1.Available = 1 ";

                //DataTable dtPhone =
                //    db.SetCommand(strSqlPhone, db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteDataTable();

                //DataTable dtLastVisit = null;
                //if (branchId > 0)
                //{
                //    string strSqlLastVisit = "select  T2.CustomerID,CONVERT(varchar(10), MAX(T1.TGStartTime), 111)  TGStartTime from [TBL_TREATGROUP] T1 INNER JOIN [ORDER] T2 ON T1.OrderID = T2.ID WHERE T1.CompanyID =@CompanyID GROUP BY T2.CustomerID";
                //    dtLastVisit = db.SetCommand(strSqlLastVisit, db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteDataTable();
                //}

                //string today = DateTime.Now.ToLongDateString();
                //for (int i = 0; i < dt.Rows.Count; i++)
                //{
                //    DataRow[] drPhone = dtPhone.Select("UserID=" + StringUtils.GetDbInt(dt.Rows[i]["UserID"]));

                //    if (drPhone != null && drPhone.Length > 0)
                //    {
                //        string strPhone = "";
                //        foreach (DataRow item in drPhone)
                //        {
                //            if (strPhone != "")
                //            {
                //                strPhone += ",";
                //            }
                //            strPhone += item.ItemArray[1];
                //        }
                //        dt.Rows[i]["PhoneNumber"] = strPhone;
                //    }

                //    if (dtLastVisit != null && dtLastVisit.Rows.Count > 0)
                //    {
                //        DataRow[] drLastVisit = dtLastVisit.Select("CustomerID=" + StringUtils.GetDbInt(dt.Rows[i]["UserID"]));

                //        if (drLastVisit != null && drLastVisit.Length == 1)
                //        {
                //            //dt.Rows[i]["LastVisit"] = drLastVisit[0].ItemArray[1];
                //            if (StringUtils.GetDbInt(dt.Rows[i]["LostRemind"]) > 0 && DateTime.Compare(StringUtils.GetDbDateTime(drLastVisit[0].ItemArray[1]).AddDays(StringUtils.GetDbInt(dt.Rows[i]["LostRemind"])), StringUtils.GetDbDateTime(today)) < 0)
                //            {
                //                dt.Rows[i]["IsRed"] = 1;
                //            }
                //        }
                //        else if (StringUtils.GetDbInt(dt.Rows[i]["LostRemind"]) == 0 && (drLastVisit == null || drLastVisit.Length != 1))
                //        {
                //            dt.Rows[i]["IsRed"] = 0;
                //        }
                //        else
                //        {
                //            dt.Rows[i]["IsRed"] = 1;
                //        }
                //    }
                //}

                dt.Columns.Remove("UserID");
                dt.Columns.Remove("LostRemind");
                return dt;
            }
        }
        /// <summary>
        /// 下载商品库存报表
        /// </summary>
        /// <param name="companyId"></param>
        /// <returns></returns>
        public DataTable getCommodityStockReport(int companyId, int branchId)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSql = @"Select [COMMODITY].CommodityName,[BRANCH].BranchName,CASE [COMMODITY].Available WHEN 1 then '可售' ELSE '停售' END CommodityAvailable
                                    ,CASE [TBL_PRODUCT_STOCK].StockCalcType when 1 then '普通库存' when 2 then '不计库存' when 3 then '允许超卖' else '' END StockCalcType,[TBL_PRODUCT_STOCK].ProductQty,CASE [TBL_MARKET_RELATIONSHIP].Available WHEN 1 then '上架' ELSE '下架' END RelationShipAvailable,ISNULL([TBL_PRODUCT_STOCK].BuyingPrice,0) AS BuyingPrice ,ISNULL([TBL_PRODUCT_STOCK].ProductQty,0) * ISNULL([TBL_PRODUCT_STOCK].BuyingPrice,0) AS Total
                                    from [COMMODITY] WITH (NOLOCK) 
                                    LEFT JOIN [TBL_MARKET_RELATIONSHIP] WITH (NOLOCK) 
                                    ON [COMMODITY].Code = [TBL_MARKET_RELATIONSHIP].Code 
                                    AND [TBL_MARKET_RELATIONSHIP].Type = 1 

                                 LEFT JOIN [BRANCH] WITH (NOLOCK) 
                                ON [TBL_MARKET_RELATIONSHIP].BranchID = [BRANCH].ID 
                                LEFT JOIN [TBL_PRODUCT_STOCK] WITH (NOLOCK) 
                                ON [COMMODITY].Code = [TBL_PRODUCT_STOCK].ProductCode and [TBL_MARKET_RELATIONSHIP].BranchID=[TBL_PRODUCT_STOCK].BranchID
                                where [COMMODITY].ID IN (
                                select MAX(ID) FROM [COMMODITY] WITH (NOLOCK) 
                                WHERE CompanyID =@CompanyID group by Code)";
                if (branchId > 0)
                {
                    strSql += "and [TBL_MARKET_RELATIONSHIP].BranchID =" + branchId.ToString();
                }
                strSql += " order by [COMMODITY].CommodityName ";
                DataTable dt = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteDataTable();
                return dt;
            }
        }
        /// <summary>
        /// 下载商品库存批次报表
        /// </summary>
        /// <param name="companyId"></param>
        /// <returns></returns>
        public DataTable getCommoditybatch(int companyId, int branchId)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSql = @"select T2.CommodityName,T3.BranchName, T2.Specification,T2.Manufacturer,T1.BatchNO, T1.Quantity, T1.ExpiryDate, T4.SupplierName 
                                  from TBL_PRODUCT_STOCK_BATCH T1 WITH (NOLOCK)
                                  left join COMMODITY T2 WITH (NOLOCK) on T2.CODE = T1.ProductCode
                                  left join BRANCH T3 WITH (NOLOCK) on T3.ID = T1.BranchID
                                  left join Supplier T4 WITH (NOLOCK) ON T4.SupplierID = T1.SupplierID
                                  where T2.ID IN (
                                  select MAX(ID) FROM [COMMODITY] WITH (NOLOCK) 
                                  WHERE CompanyID = @CompanyID group by Code)";
                if (branchId > 0)
                {
                    strSql += "AND T1.BranchId =" + branchId.ToString();
                }
                strSql += " order by T2.CommodityName, T1.ExpiryDate desc";
                DataTable dt = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteDataTable();
                return dt;
            }
        }

        /// <summary>
        /// 下载库存变动信息
        /// </summary>
        /// <param name="companyId"></param>
        /// <returns></returns>
        public DataTable getProductStockOperateLog(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSql = @"SELECT ISNULL([COMMODITY].CommodityName,[QueryDeleteCommodity].CommodityName) ,[BRANCH].BranchName,[ACCOUNT].Name,CONVERT(varchar(10), [TBL_PRODUCT_STOCK_OPERATELOG].OperateTime, 111) + ' ' +  CONVERT(varchar(8), [TBL_PRODUCT_STOCK_OPERATELOG].OperateTime, 8) OperateTime, [SYS_PRODUCT_STOCK_OPERATETYPE].TypeName,[TBL_PRODUCT_STOCK_OPERATELOG].OperateQty,[TBL_PRODUCT_STOCK_OPERATELOG].ProductQty,[TBL_PRODUCT_STOCK_OPERATELOG].Remark 
                                    FROM [TBL_PRODUCT_STOCK_OPERATELOG] with (Nolock)
                                    LEFT JOIN [COMMODITY] with (Nolock) 
                                    ON [TBL_PRODUCT_STOCK_OPERATELOG].ProductCode = [COMMODITY].Code and [COMMODITY].Available = 1
	                                LEFT JOIN (SELECT [COMMODITY].Code,[COMMODITY].CommodityName  
                                    FROM [COMMODITY] with (Nolock) 
                                    WHERE [COMMODITY].ID IN (SELECT MAX([COMMODITY].ID) 
                                    FROM [COMMODITY] GROUP BY [COMMODITY].Code)) QueryDeleteCommodity 
                                    ON [TBL_PRODUCT_STOCK_OPERATELOG].ProductCode = [QueryDeleteCommodity].Code
                                    LEFT JOIN [BRANCH] with (Nolock) 
                                    ON [TBL_PRODUCT_STOCK_OPERATELOG].BranchID = [BRANCH].ID 
                                    LEFT JOIN [ACCOUNT] with (Nolock) 
                                    ON [TBL_PRODUCT_STOCK_OPERATELOG].OperatorID = [ACCOUNT].UserID
                                    LEFT JOIN [SYS_PRODUCT_STOCK_OPERATETYPE] with (Nolock) 
                                    ON [TBL_PRODUCT_STOCK_OPERATELOG].OperateType = [SYS_PRODUCT_STOCK_OPERATETYPE].ID
                                    WHERE [TBL_PRODUCT_STOCK_OPERATELOG].CompanyID =@CompanyID and [TBL_PRODUCT_STOCK_OPERATELOG].OperateTime >@BeginDay and [TBL_PRODUCT_STOCK_OPERATELOG].OperateTime <@EndDay ";
                if (branchId > 0)
                {
                    strSql += "and [TBL_PRODUCT_STOCK_OPERATELOG].BranchID =" + branchId.ToString();
                }

                DataTable dt = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();
                return dt;
            }
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="branchId"></param>
        /// <param name="beginDay"></param>
        /// <param name="endDay"></param>
        /// <returns></returns>
        //        public DataTable getServiceDeatilReport(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        //        {
        //            using (DbManager db = new DbManager())
        //            {
        //                string strSqlgetOrderId = @"( SELECT P1.OrderID from (
        //                                    Select T2.ID OrderID from [TBL_OrderPayment_RelationShip] T1
        //                                    inner join [ORDER] T2
        //                                    ON T1.OrderID = T2.ID AND T2.PaymentStatus > 0 AND T2.Status <> 2 and  T2.ProductType =0
        //                                    inner join [PAYMENT] T3
        //                                    on T1.PaymentID = T3.ID AND T3.Type = 1 and T3.Status = 2
        //                                    left join [BRANCH] T7 on T2.BranchID = T7.ID 
        //                                    WHERE T2.CompanyID =@CompanyID AND T3.PaymentTime > @BeginDay AND T3.PaymentTime <@EndDay AND T2.OrderTime > T7.StartTime ";
        //                if (branchId > 0)
        //                {
        //                    strSqlgetOrderId += "and T2.BranchID =" + branchId.ToString();
        //                }
        //                strSqlgetOrderId += @" union all 
        //                                            select T4.OrderID  from [SCHEDULE] T4 
        //                                            INNER JOIN [ORDER] T6
        //                                            ON T4.OrderID = T6.ID AND T6.Status <> 2 AND T6.PaymentStatus > 0 AND  T6.ProductType =0
        //                                            left join [BRANCH] T8 on T6.BranchID = T8.ID 
        //                                            WHERE T4.Status = 1 AND T4.CompanyID =@CompanyID AND T4.Type= 0 AND T4.ScheduleTime > @BeginDay AND T4.ScheduleTime <@EndDay AND T6.OrderTime > T8.StartTime ";
        //                if (branchId > 0)
        //                {
        //                    strSqlgetOrderId += "and T6.BranchID =" + branchId.ToString();
        //                }

        //                strSqlgetOrderId += "  ) P1 ";


        //                string strSqlOrderBasic = @" SELECT  T5.ResponsiblePersonID, T5.OrderID ,T5.BranchName,T6.Name AccountName,T7.Name CustomerName,T5.OrderTime,T5.OrderNumber,T5.TotalOrigPrice,T5.TotalSalePrice,T8.ServiceName,T5.ResponsibleName,T5.Remark FROM ( 
        //                                                 SELECT  T1.OrderID, T4.BranchName,ISNULL(P1.SlaveID,0) ResponsiblePersonID,T2.CustomerID, CONVERT(varchar(10), T2.OrderTime, 111) OrderTime,SUBSTRING(CONVERT(varchar(6) ,T2.OrderTime ,12),3,4) + right('000000'+ cast(T2.ID AS VARCHAR(10)),6) + CONVERT(varchar(2) ,T2.OrderTime ,12) OrderNumber,T2.TotalOrigPrice,T2.TotalSalePrice,T2.ProductID, '业绩参与' ResponsibleName,T2.Remark  
        //                                                 FROM [TBL_ORDERPAYMENT_RELATIONSHIP] T1 WITH (NOLOCK) 
        //                                                 INNER JOIN   [ORDER] T2  
        //                                                 ON T2.ID = T1.OrderID AND T2.PaymentStatus > 0 AND T2.Status <> 2 and  T2.ProductType =0 
        //                                                 INNER JOIN [PAYMENT] T3 
        //                                                 ON T1.PaymentID = T3.ID AND T3.Type = 1 and T3.Status = 2
        //                                                 LEFT JOIN [TBL_PROFIT] P1
        //                                                 ON T1.PaymentID = P1.MasterID AND P1.Available = 1 AND P1.Type =2 
        //                                                 LEFT JOIN [BRANCH] T4 
        //                                                 ON T2.BranchID = T4.ID 
        //                                                 where T2.CompanyID =@CompanyID AND T3.PaymentTime >@BeginDay AND T3.PaymentTime < @EndDay AND  T2.OrderTime > T4.StartTime AND  T1.ResponsiblePersonID IS NOT NULL AND T1.ResponsiblePersonID <> 0  ";

        //                if (branchId > 0)
        //                {
        //                    strSqlOrderBasic += "and T2.BranchID =" + branchId.ToString();
        //                }
        //                strSqlOrderBasic += @" GROUP BY T1.OrderID, T4.BranchName,P1.SlaveID,T2.CustomerID, CONVERT(varchar(10), T2.OrderTime, 111) ,SUBSTRING(CONVERT(varchar(6) ,T2.OrderTime ,12),3,4) + right('000000'+ cast(T2.ID AS VARCHAR(10)),6) + CONVERT(varchar(2) ,T2.OrderTime ,12) ,T2.TotalOrigPrice,T2.TotalSalePrice,T2.ProductID,T2.Remark
        //                                           ) T5 
        //                                           LEFT JOIN [ACCOUNT] T6 WITH (NOLOCK)
        //                                           ON T5.ResponsiblePersonID = T6.UserID
        //                                           INNER JOIN [CUSTOMER] T7 WITH (NOLOCK)
        //                                           on T5.CustomerID = T7.UserID
        //                                           left join [SERVICE] T8 WITH (NOLOCK)
        //                                           ON T5.ProductID = T8.ID ORDER BY T5.OrderID ";


        //                DataSet dsOrderBasic = db.SetCommand(strSqlOrderBasic, db.Parameter("@CompanyID", companyId, DbType.Int32)
        //                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
        //                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataSet();
        //                if (dsOrderBasic == null || dsOrderBasic.Tables[0].Rows.Count == 0)
        //                {
        //                    return null;
        //                }

        //                string strSqlTreatmentCount = @" SELECT T1.ID OrderID ,COUNT(T3.ID) TreatmentCount 
        //                                                FROM [ORDER] T1 WITH (NOLOCK)  
        //                                                left JOIN [COURSE] T2 WITH (NOLOCK)
        //                                                ON T1.ID = T2.OrderID AND T2.Available = 1
        //                                                left JOIN [TREATMENT] T3 WITH (NOLOCK) 
        //                                                ON T2.ID = T3.CourseID AND T3.Available = 1
        //                                                where EXISTS  " + strSqlgetOrderId
        //                                            + @"  where P1.OrderID = T1.ID group by P1.OrderID  )";
        //                if (branchId > 0)
        //                {
        //                    strSqlTreatmentCount += "and T1.BranchID =" + branchId.ToString();
        //                }
        //                strSqlTreatmentCount += "GROUP BY T1.ID ORDER BY T1.ID";
        //                DataSet dsTreatmentCount = db.SetCommand(strSqlTreatmentCount
        //                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
        //                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
        //                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataSet();

        //                string strSqlPaymentDetail = @" SELECT ISNULL(P1.SlaveID,0) ResponsiblePersonID, T1.ID OrderID,SUM(T4.PaymentAmount) PaymentAmount ,T4.PaymentMode,T3.OrderNumber 
        //                                                 FROM [ORDER]  T1 WITH (NOLOCK)
        //                                                 INNER JOIN [TBL_OrderPayment_RelationShip] T2 WITH (NOLOCK)
        //                                                 ON T1.ID = T2.OrderID 
        //                                                 INNER JOIN [PAYMENT] T3 WITH (NOLOCK)
        //                                                 ON T2.PaymentID = T3.ID AND T3.Type = 1 and T3.Status = 2
        //                                                 LEFT JOIN [TBL_PROFIT] P1
        //                                                 ON T2.PaymentID = P1.MasterID AND P1.Available = 1 AND P1.Type =2 
        //                                                 INNER JOIN [PAYMENT_DETAIL] T4 WITH (NOLOCK)
        //                                                 ON T2.PaymentID = T4.PaymentID WHERE  EXISTS  " + strSqlgetOrderId
        //                                            + @"  where P1.OrderID = T1.ID group by P1.OrderID  )";

        //                if (branchId > 0)
        //                {
        //                    strSqlPaymentDetail += "and T1.BranchID =" + branchId.ToString();
        //                }
        //                strSqlPaymentDetail += @" AND T3.PaymentTime >@BeginDay AND T3.PaymentTime <@EndDay and T2.ResponsiblePersonID IS NOT NULL  and T2.ResponsiblePersonID > 0
        //                                           GROUP BY T1.ID, P1.SlaveID,T4.PaymentMode,T3.OrderNumber
        //                                           ORDER BY T1.ID ";
        //                DataSet dsPaymentDetail = db.SetCommand(strSqlPaymentDetail
        //                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
        //                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
        //                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataSet();

        //                string strSqlTreatmentDetail = @" select T2.OrderID,T4.Name AccountName, ISNULL(T3.SubServiceName,'服务') ResponsibleName, CASE T1.IsDesignated WHEN 1 THEN '指定' else '非指定' END IsDesignated,T1.Remark 
        //                                                    From [TREATMENT] T1 WITH (NOLOCK)
        //                                                    INNER JOIN [SCHEDULE] T2 WITH (NOLOCK)
        //                                                    ON T1.ScheduleID = T2.ID AND T2.Status = 1 AND T2.Type = 0
        //                                                    LEFT JOIN [TBL_SubService] T3 WITH (NOLOCK)
        //                                                    ON T2.SubServiceID = T3.ID 
        //                                                    LEFT JOIN [ACCOUNT] T4 WITH (NOLOCK) 
        //                                                    ON T1.ExecutorID = T4.UserID
        //                                                    INNER JOIN [ORDER] T5 WITH (NOLOCK)
        //                                                    ON T2.OrderID = T5.ID
        //                                                    WHERE EXISTS  " + strSqlgetOrderId
        //                                            + @"  where P1.OrderID = T2.OrderID group by P1.OrderID  )";
        //                if (branchId > 0)
        //                {
        //                    strSqlTreatmentDetail += "and T5.BranchID =" + branchId.ToString();
        //                }
        //                strSqlTreatmentDetail += @" AND T2.ScheduleTime >@BeginDay AND T2.ScheduleTime <@EndDay 
        //                                             ORDER BY T2.OrderID";
        //                DataSet dsTreatmentDetail = db.SetCommand(strSqlTreatmentDetail
        //                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
        //                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
        //                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataSet();

        //                string strSqlDoCount = @" select COUNT(T5.OrderID) DoCount,T5.OrderID FROM(
        //                                                    select T2.OrderID,T4.Name AccountName, T3.SubServiceName ResponsibleName, CASE T1.IsDesignated WHEN 1 THEN '指定' else '非指定' END IsDesignated,T1.Remark 
        //                                                    From [TREATMENT] T1 WITH (NOLOCK)
        //                                                    INNER JOIN [SCHEDULE] T2 WITH (NOLOCK)
        //                                                    ON T1.ScheduleID = T2.ID AND T2.Status = 1 AND T2.Type = 0
        //                                                    LEFT JOIN [TBL_SubService] T3 WITH (NOLOCK)
        //                                                    ON T2.SubServiceID = T3.ID 
        //                                                    LEFT JOIN [ACCOUNT] T4 WITH (NOLOCK) 
        //                                                    ON T1.ExecutorID = T4.UserID
        //                                                    INNER JOIN [ORDER] T6 WITH (NOLOCK)
        //                                                    ON T2.OrderID = T6.ID
        //                                                    WHERE  EXISTS  " + strSqlgetOrderId
        //                                            + @"  where P1.OrderID = T2.OrderID group by P1.OrderID  )";
        //                if (branchId > 0)
        //                {
        //                    strSqlDoCount += "and T6.BranchID =" + branchId.ToString();
        //                }
        //                strSqlDoCount += @" AND T2.ScheduleTime >@BeginDay AND T2.ScheduleTime <@EndDay 
        //                                             ) T5 GROUP BY T5.OrderID ORDER BY T5.OrderID";
        //                DataSet dsDoCount = db.SetCommand(strSqlDoCount
        //                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
        //                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
        //                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataSet();

        //                string strSqlPaymentAll = @" SELECT T1.ID OrderID,SUM(T4.PaymentAmount) PaymentAmount ,T4.PaymentMode,T3.OrderNumber 
        //                                                 FROM [ORDER]  T1 WITH (NOLOCK)
        //                                                 INNER JOIN [TBL_OrderPayment_RelationShip] T2 WITH (NOLOCK)
        //                                                 ON T1.ID = T2.OrderID 
        //                                                 INNER JOIN [PAYMENT] T3 WITH (NOLOCK)
        //                                                 ON T2.PaymentID = T3.ID AND T3.Type = 1 and T3.Status = 2
        //                                                 INNER JOIN [PAYMENT_DETAIL] T4 WITH (NOLOCK)
        //                                                 ON T2.PaymentID = T4.PaymentID WHERE EXISTS  " + strSqlgetOrderId
        //                                            + @"  where P1.OrderID = T1.ID group by P1.OrderID  )";

        //                if (branchId > 0)
        //                {
        //                    strSqlPaymentAll += "and T1.BranchID =" + branchId.ToString();
        //                }
        //                strSqlPaymentAll += @" AND T3.CreateTime >@BeginDay AND T3.CreateTime <@EndDay 
        //                                           GROUP BY T1.ID,T4.PaymentMode,T3.OrderNumber ORDER BY T1.ID ";
        //                DataSet dsPaymentAll = db.SetCommand(strSqlPaymentAll
        //                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
        //                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
        //                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataSet();

        //                DataTable dt = new DataTable();
        //                dt.Columns.Add("BranchName");
        //                dt.Columns.Add("AccountName");
        //                dt.Columns.Add("CustomerName");
        //                dt.Columns.Add("OrderTime");
        //                dt.Columns.Add("OrderNumber");
        //                dt.Columns.Add("ServiceName");
        //                dt.Columns.Add("TreatmentCount");
        //                dt.Columns["TreatmentCount"].DataType = typeof(Int32);
        //                dt.Columns.Add("TotalOrigPrice");
        //                dt.Columns["TotalOrigPrice"].DataType = typeof(decimal);
        //                dt.Columns.Add("TotalSalePrice");
        //                dt.Columns["TotalSalePrice"].DataType = typeof(decimal);
        //                dt.Columns.Add("PayCash");
        //                dt.Columns["PayCash"].DataType = typeof(decimal);
        //                dt.Columns.Add("PayECard");
        //                dt.Columns["PayECard"].DataType = typeof(decimal);
        //                dt.Columns.Add("PayBankCard");
        //                dt.Columns["PayBankCard"].DataType = typeof(decimal);
        //                dt.Columns.Add("PayOther");
        //                dt.Columns["PayOther"].DataType = typeof(decimal);
        //                dt.Columns.Add("ResponsibleName");
        //                dt.Columns.Add("IsDesignated");
        //                dt.Columns.Add("DoCount");
        //                dt.Columns["DoCount"].DataType = typeof(Int32);
        //                dt.Columns.Add("Remark");

        //                for (int i = 0; i < dsOrderBasic.Tables[0].Rows.Count; i++)
        //                {
        //                    decimal totalPrice = 0;
        //                    if (StringUtils.GetDbInt(dsOrderBasic.Tables[0].Rows[i]["ResponsiblePersonID"]) == 0)
        //                    {
        //                        string strSqlCheck = @" select T1.TotalSalePrice from [ORDER] T1 WHERE T1.ID =@ID  ";
        //                        totalPrice = db.SetCommand(strSqlCheck, db.Parameter("@ID", StringUtils.GetDbInt(dsOrderBasic.Tables[0].Rows[i]["OrderID"]), DbType.Int32)).ExecuteScalar<decimal>();
        //                    }

        //                    if (totalPrice == 0)
        //                    {
        //                        DataRow dr = dt.NewRow();
        //                        dr["BranchName"] = dsOrderBasic.Tables[0].Rows[i]["BranchName"];
        //                        dr["AccountName"] = dsOrderBasic.Tables[0].Rows[i]["AccountName"];
        //                        dr["CustomerName"] = dsOrderBasic.Tables[0].Rows[i]["CustomerName"];
        //                        dr["OrderTime"] = dsOrderBasic.Tables[0].Rows[i]["OrderTime"];
        //                        dr["ServiceName"] = dsOrderBasic.Tables[0].Rows[i]["ServiceName"];
        //                        dr["OrderNumber"] = dsOrderBasic.Tables[0].Rows[i]["OrderNumber"];

        //                        DataRow[] drTreatmentCount = dsTreatmentCount.Tables[0].Select("OrderID=" + StringUtils.GetDbInt(dsOrderBasic.Tables[0].Rows[i]["OrderID"]));
        //                        if (drTreatmentCount.Length == 1)
        //                        {
        //                            dr["TreatmentCount"] = StringUtils.GetDbInt(drTreatmentCount[0].ItemArray[1]);
        //                        }
        //                        else
        //                        {
        //                            dr["TreatmentCount"] = 0;
        //                        }

        //                        dr["TotalOrigPrice"] = StringUtils.GetDbDecimal(dsOrderBasic.Tables[0].Rows[i]["TotalOrigPrice"]);
        //                        dr["TotalSalePrice"] = StringUtils.GetDbDecimal(dsOrderBasic.Tables[0].Rows[i]["TotalSalePrice"]);



        //                        string strWhere = "OrderID=" + dsOrderBasic.Tables[0].Rows[i]["OrderID"].ToString() + " AND  ResponsiblePersonID <> 0 AND ResponsiblePersonID=" + dsOrderBasic.Tables[0].Rows[i]["ResponsiblePersonID"].ToString();
        //                        DataRow[] drPayment = dsPaymentDetail.Tables[0].Select(strWhere);
        //                        foreach (DataRow item in drPayment)
        //                        {
        //                            int paymentMode = StringUtils.GetDbInt(item.ItemArray[3]);
        //                            int orderNumber = StringUtils.GetDbInt(item.ItemArray[4]);
        //                            switch (paymentMode)
        //                            {
        //                                case 0:
        //                                    if (orderNumber == 1)
        //                                    {
        //                                        dr["PayCash"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
        //                                    }
        //                                    else if (orderNumber > 1)
        //                                    {
        //                                        dr["PayCash"] = StringUtils.GetDbDecimal(dsOrderBasic.Tables[0].Rows[i]["TotalSalePrice"]);
        //                                    }
        //                                    break;
        //                                case 1:
        //                                    if (orderNumber == 1)
        //                                    {
        //                                        dr["PayECard"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
        //                                    }
        //                                    else if (orderNumber > 1)
        //                                    {
        //                                        dr["PayECard"] = StringUtils.GetDbDecimal(dsOrderBasic.Tables[0].Rows[i]["TotalSalePrice"]);
        //                                    }
        //                                    break;
        //                                case 2:
        //                                    if (orderNumber == 1)
        //                                    {
        //                                        dr["PayBankCard"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
        //                                    }
        //                                    else if (orderNumber > 1)
        //                                    {
        //                                        dr["PayBankCard"] = StringUtils.GetDbDecimal(dsOrderBasic.Tables[0].Rows[i]["TotalSalePrice"]);
        //                                    }
        //                                    break;
        //                                case 3:
        //                                    if (orderNumber == 1)
        //                                    {
        //                                        dr["PayOther"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
        //                                    }
        //                                    else if (orderNumber > 1)
        //                                    {
        //                                        dr["PayOther"] = StringUtils.GetDbDecimal(dsOrderBasic.Tables[0].Rows[i]["TotalSalePrice"]);
        //                                    }
        //                                    break;
        //                            }
        //                        }


        //                        dr["ResponsibleName"] = dsOrderBasic.Tables[0].Rows[i]["ResponsibleName"];
        //                        dr["DoCount"] = "0";

        //                        DataRow[] drDoCount = dsDoCount.Tables[0].Select("OrderID=" + StringUtils.GetDbInt(dsOrderBasic.Tables[0].Rows[i]["OrderID"]));
        //                        if (drDoCount.Length == 1)
        //                        {
        //                            dr["DoCount"] = StringUtils.GetDbInt(drDoCount[0].ItemArray[0]);
        //                        }
        //                        else
        //                        {
        //                            dr["DoCount"] = 0;
        //                        }
        //                        dr["Remark"] = dsOrderBasic.Tables[0].Rows[i]["Remark"];
        //                        dt.Rows.Add(dr);

        //                        if ((i < dsOrderBasic.Tables[0].Rows.Count - 1 && StringUtils.GetDbInt(dsOrderBasic.Tables[0].Rows[i]["OrderID"]) != StringUtils.GetDbInt(dsOrderBasic.Tables[0].Rows[i + 1]["OrderID"])) || i == dsOrderBasic.Tables[0].Rows.Count - 1)
        //                        {
        //                            DataRow[] drTreatmentDetail = dsTreatmentDetail.Tables[0].Select("OrderID=" + StringUtils.GetDbInt(dsOrderBasic.Tables[0].Rows[i]["OrderID"]));
        //                            foreach (DataRow itemTreatmentDetail in drTreatmentDetail)
        //                            {
        //                                DataRow drTreatment = dt.NewRow();
        //                                drTreatment.ItemArray = dr.ItemArray;
        //                                drTreatment["AccountName"] = itemTreatmentDetail.ItemArray[1];
        //                                drTreatment["ResponsibleName"] = itemTreatmentDetail.ItemArray[2];
        //                                drTreatment["IsDesignated"] = itemTreatmentDetail.ItemArray[3];
        //                                drTreatment["DoCount"] = 1;
        //                                drTreatment["Remark"] = itemTreatmentDetail.ItemArray[4];
        //                                DataRow[] drPayAll = dsPaymentAll.Tables[0].Select("OrderID=" + StringUtils.GetDbInt(itemTreatmentDetail.ItemArray[0]));
        //                                drTreatment["PayCash"] = (object)DBNull.Value;
        //                                drTreatment["PayECard"] = (object)DBNull.Value;
        //                                drTreatment["PayBankCard"] = (object)DBNull.Value;
        //                                drTreatment["PayOther"] = (object)DBNull.Value;
        //                                foreach (DataRow item in drPayAll)
        //                                {

        //                                    int paymentMode = StringUtils.GetDbInt(item.ItemArray[2]);
        //                                    int orderNumer = StringUtils.GetDbInt(item.ItemArray[3]);
        //                                    switch (paymentMode)
        //                                    {
        //                                        case 0:
        //                                            if (orderNumer == 1)
        //                                            {
        //                                                drTreatment["PayCash"] = StringUtils.GetDbDecimal(item.ItemArray[1]);

        //                                            }
        //                                            else
        //                                            {
        //                                                drTreatment["PayCash"] = StringUtils.GetDbDecimal(dsOrderBasic.Tables[0].Rows[i]["TotalSalePrice"]);
        //                                            }
        //                                            break;
        //                                        case 1:
        //                                            if (orderNumer == 1)
        //                                            {
        //                                                drTreatment["PayECard"] = StringUtils.GetDbDecimal(item.ItemArray[1]);

        //                                            }
        //                                            else
        //                                            {
        //                                                drTreatment["PayECard"] = StringUtils.GetDbDecimal(dsOrderBasic.Tables[0].Rows[i]["TotalSalePrice"]);
        //                                            }
        //                                            break;
        //                                        case 2:
        //                                            if (orderNumer == 1)
        //                                            {
        //                                                drTreatment["PayBankCard"] = StringUtils.GetDbDecimal(item.ItemArray[1]);
        //                                            }
        //                                            else
        //                                            {
        //                                                drTreatment["PayBankCard"] = StringUtils.GetDbDecimal(dsOrderBasic.Tables[0].Rows[i]["TotalSalePrice"]);
        //                                            }
        //                                            break;
        //                                        case 3:
        //                                            if (orderNumer == 1)
        //                                            {
        //                                                drTreatment["PayOther"] = StringUtils.GetDbDecimal(item.ItemArray[1]);
        //                                            }
        //                                            else
        //                                            {
        //                                                drTreatment["PayOther"] = StringUtils.GetDbDecimal(dsOrderBasic.Tables[0].Rows[i]["TotalSalePrice"]);
        //                                            }
        //                                            break;
        //                                    }

        //                                }
        //                                dt.Rows.Add(drTreatment);
        //                            }
        //                        }
        //                    }
        //                }
        //                return dt;
        //            }

        //        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="branchId"></param>
        /// <param name="beginDay"></param>
        /// <param name="endDay"></param>
        /// <returns></returns>
        public DataTable getCommodityDeatilReport(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {

            using (DbManager db = new DbManager("Report"))
            {
                string strSqlOrderBasic = @"getCommodityDeatilReport";
                DataTable dtOrderBasic = db.SetSpCommand(strSqlOrderBasic
                , db.Parameter("@CompanyID", companyId, DbType.Int32)
                , db.Parameter("@BranchID", branchId, DbType.Int32)
                , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();
                if (dtOrderBasic == null || dtOrderBasic.Rows.Count == 0)
                {
                    return null;
                }
                DataTable dt = new DataTable();
                dt.Columns.Add("BranchName");
                dt.Columns.Add("CustomerName");
                dt.Columns.Add("CustomerPhoneNumber");
                dt.Columns.Add("CustomerBranchName");
                dt.Columns.Add("SourceName");
                dt.Columns.Add("OrderTime");
                dt.Columns.Add("CommodityName");
                dt.Columns.Add("OrderNumber");
                dt.Columns.Add("Quantity");
                dt.Columns.Add("TotalOrigPrice");
                dt.Columns["TotalOrigPrice"].DataType = typeof(decimal);
                dt.Columns.Add("TotalSalePrice");
                dt.Columns["TotalSalePrice"].DataType = typeof(decimal);
                dt.Columns.Add("ProfitAmount");
                dt.Columns["ProfitAmount"].DataType = typeof(decimal);
                dt.Columns.Add("PaymentTime");
                dt.Columns.Add("PaymentNumber");
                dt.Columns.Add("PayCash");
                dt.Columns["PayCash"].DataType = typeof(decimal);
                dt.Columns.Add("PayBankCard");
                dt.Columns["PayBankCard"].DataType = typeof(decimal);
                dt.Columns.Add("PayWeChatBalance");
                dt.Columns["PayWeChatBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayAlipayBalance");
                dt.Columns["PayAlipayBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayMoneyBalance");
                dt.Columns["PayMoneyBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayPointBalance");
                dt.Columns["PayPointBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayCouponBalance");
                dt.Columns["PayCouponBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayLoan");
                dt.Columns["PayLoan"].DataType = typeof(decimal);
                dt.Columns.Add("PayThird");
                dt.Columns["PayThird"].DataType = typeof(decimal);
                dt.Columns.Add("PayOther");
                dt.Columns["PayOther"].DataType = typeof(decimal);
                dt.Columns.Add("ClientType");
                dt.Columns.Add("PeopleCount");
                dt.Columns.Add("rolename");
                dt.Columns.Add("name");
                dt.Columns.Add("isSend");
                dt.Columns.Add("PolicyName");
                dt.Columns.Add("Remark");

                for (int i = 0; i < dtOrderBasic.Rows.Count; i++)
                {
                    DataRow dr = dt.NewRow();
                    dr["BranchName"] = dtOrderBasic.Rows[i]["BranchName"];
                    dr["CustomerName"] = dtOrderBasic.Rows[i]["CustomerName"];
                    dr["CustomerPhoneNumber"] = dtOrderBasic.Rows[i]["CustomerPhoneNumber"];
                    dr["CustomerBranchName"] = dtOrderBasic.Rows[i]["CustomerBranchName"];
                    dr["SourceName"] = dtOrderBasic.Rows[i]["SourceName"];
                    dr["OrderTime"] = dtOrderBasic.Rows[i]["OrderTime"];
                    dr["CommodityName"] = dtOrderBasic.Rows[i]["CommodityName"];
                    dr["OrderNumber"] = dtOrderBasic.Rows[i]["OrderNumber"];
                    dr["Quantity"] = dtOrderBasic.Rows[i]["Quantity"];
                    dr["TotalOrigPrice"] = dtOrderBasic.Rows[i]["TotalOrigPrice"];
                    dr["TotalSalePrice"] = dtOrderBasic.Rows[i]["TotalSalePrice"];
                    dr["PaymentTime"] = dtOrderBasic.Rows[i]["PaymentTime"];
                    dr["PaymentNumber"] = dtOrderBasic.Rows[i]["PaymentNumber"];
                    dr["ClientType"] = dtOrderBasic.Rows[i]["ClientType"];
                    dr["isSend"] = dtOrderBasic.Rows[i]["isSend"];
                    dr["PeopleCount"] = dtOrderBasic.Rows[i]["PeopleCount"];
                    dr["rolename"] = dtOrderBasic.Rows[i]["rolename"];
                    dr["name"] = dtOrderBasic.Rows[i]["name"];
                    dr["PolicyName"] = dtOrderBasic.Rows[i]["PolicyName"];
                    dr["Remark"] = dtOrderBasic.Rows[i]["Remark"];
                    dr["PayCash"] = dtOrderBasic.Rows[i]["PayCash"];
                    dr["PayMoneyBalance"] = dtOrderBasic.Rows[i]["PayMoneyBalance"];
                    dr["PayBankCard"] = dtOrderBasic.Rows[i]["PayBankCard"];
                    dr["PayOther"] = dtOrderBasic.Rows[i]["PayOther"];
                    dr["PayPointBalance"] = dtOrderBasic.Rows[i]["PayPointBalance"];
                    dr["PayCouponBalance"] = dtOrderBasic.Rows[i]["PayCouponBalance"];
                    dr["PayWeChatBalance"] = dtOrderBasic.Rows[i]["PayWeChatBalance"];
                    dr["PayAlipayBalance"] = dtOrderBasic.Rows[i]["PayAlipayBalance"];
                    dr["PayLoan"] = dtOrderBasic.Rows[i]["PayLoan"];
                    dr["PayThird"] = dtOrderBasic.Rows[i]["PayThird"];
                    dr["ProfitAmount"] = dtOrderBasic.Rows[i]["ProfitAmount"];
                    dt.Rows.Add(dr);
                }


                return dt;

            }

        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="branchId"></param>
        /// <param name="beginDay"></param>
        /// <param name="endDay"></param>
        /// <returns></returns>
        public DataTable getReChargeDeatilReport(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSqlBasic = @"getReChargeDeatilReport";
                DataTable dsBasic = db.SetSpCommand(strSqlBasic
                , db.Parameter("@CompanyID", companyId, DbType.Int32)
                , db.Parameter("@BranchID", branchId, DbType.Int32)
                , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();
                if (dsBasic == null || dsBasic.Rows.Count == 0)
                {
                    return null;
                }

                return dsBasic;
            }
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="branchId"></param>
        /// <param name="beginDay"></param>
        /// <param name="endDay"></param>
        /// <returns></returns>
        public DataTable getBalanceDetailData(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSqlBasic = @"getBalanceDetailData";
                DataTable dtBasic = db.SetSpCommand(strSqlBasic
                , db.Parameter("@CompanyID", companyId, DbType.Int32)
                , db.Parameter("@BranchID", branchId, DbType.Int32)
                , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();
                if (dtBasic == null || dtBasic.Rows.Count == 0)
                {
                    return null;
                }
                DataTable dt = new DataTable();
                dt.Columns.Add("CustomerName");
                dt.Columns.Add("CustomerBranchName");
                dt.Columns.Add("CardName");
                dt.Columns.Add("Available");
                dt.Columns.Add("CardExpiredDate");
                dt.Columns.Add("LastBalance");
                dt.Columns["LastBalance"].DataType = typeof(decimal);
                dt.Columns.Add("IncomeCash");
                dt.Columns["IncomeCash"].DataType = typeof(decimal);
                dt.Columns.Add("IncomeBank");
                dt.Columns["IncomeBank"].DataType = typeof(decimal);
                dt.Columns.Add("IncomeWeChat");
                dt.Columns["IncomeWeChat"].DataType = typeof(decimal);
                dt.Columns.Add("IncomeAlipay");
                dt.Columns["IncomeAlipay"].DataType = typeof(decimal);
                dt.Columns.Add("IncomeSend");
                dt.Columns["IncomeSend"].DataType = typeof(decimal);
                dt.Columns.Add("IncomeIn");
                dt.Columns["IncomeIn"].DataType = typeof(decimal);
                dt.Columns.Add("Payment");
                dt.Columns["Payment"].DataType = typeof(decimal);
                dt.Columns.Add("OutCome");
                dt.Columns["OutCome"].DataType = typeof(decimal);
                //dt.Columns.Add("Related");
                //dt.Columns["Related"].DataType = typeof(decimal);
                dt.Columns.Add("AllIn");
                dt.Columns["AllIn"].DataType = typeof(decimal);
                dt.Columns.Add("AllOut");
                dt.Columns["AllOut"].DataType = typeof(decimal);
                dt.Columns.Add("NowBalance");
                dt.Columns["NowBalance"].DataType = typeof(decimal);
                for (int i = 0; i < dtBasic.Rows.Count; i++)
                {
                    DataRow dr = dt.NewRow();
                    dr["CustomerName"] = dtBasic.Rows[i]["CustomerName"];
                    dr["CustomerBranchName"] = dtBasic.Rows[i]["CustomerBranchName"];
                    dr["CardName"] = dtBasic.Rows[i]["CardName"];
                    dr["Available"] = dtBasic.Rows[i]["Available"];
                    dr["CardExpiredDate"] = dtBasic.Rows[i]["CardExpiredDate"];
                    dr["LastBalance"] = dtBasic.Rows[i]["LastBalance"];
                    dr["NowBalance"] = dtBasic.Rows[i]["NowBalance"];
                    dr["IncomeCash"] = dtBasic.Rows[i]["IncomeCash"];
                    dr["IncomeBank"] = dtBasic.Rows[i]["IncomeBank"];
                    dr["IncomeSend"] = dtBasic.Rows[i]["IncomeSend"];
                    dr["IncomeWeChat"] = dtBasic.Rows[i]["IncomeWeChat"];
                    dr["IncomeAlipay"] = dtBasic.Rows[i]["IncomeAlipay"];
                    dr["IncomeIn"] = dtBasic.Rows[i]["IncomeIn"];
                    dr["Payment"] = dtBasic.Rows[i]["Payment"];
                    dr["OutCome"] = dtBasic.Rows[i]["OutCome"];
                    dr["AllIn"] = dtBasic.Rows[i]["AllIn"];
                    dr["AllOut"] = dtBasic.Rows[i]["AllOut"];

                    dt.Rows.Add(dr);
                }
                return dt;
            }
        }

        /// <summary>
        /// 流量统计
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="branchId"></param>
        /// <param name="beginDay"></param>
        /// <param name="endDay"></param>
        /// <returns></returns>
        public DataTable getPeopleCount(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSql = @"getPeopleCount";
                DataTable dsBasic = db.SetSpCommand(strSql
                , db.Parameter("@CompanyID", companyId, DbType.Int32)
                , db.Parameter("@BranchID", branchId, DbType.Int32)
                , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();
                if (dsBasic == null || dsBasic.Rows.Count == 0)
                {
                    return null;
                }
                return dsBasic;
            }
        }



        public DataTable getServicePayDetail(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSqlOrderBasic = @"getServicePayDetail";
                DataTable dtOrderBasic = db.SetSpCommand(strSqlOrderBasic
                , db.Parameter("@CompanyID", companyId, DbType.Int32)
                , db.Parameter("@BranchID", branchId, DbType.Int32)
                , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();
                if (dtOrderBasic == null || dtOrderBasic.Rows.Count == 0)
                {
                    return null;
                }
                DataTable dt = new DataTable();
                dt.Columns.Add("BranchName");
                dt.Columns.Add("CustomerName");
                dt.Columns.Add("CustomerPhoneNumber");
                dt.Columns.Add("CustomerBranchName");
                dt.Columns.Add("SourceName");
                dt.Columns.Add("OrderTime");
                dt.Columns.Add("ServiceName");
                dt.Columns.Add("OrderNumber");
                dt.Columns.Add("TotalOrigPrice");
                dt.Columns["TotalOrigPrice"].DataType = typeof(decimal);
                dt.Columns.Add("TotalSalePrice");
                dt.Columns["TotalSalePrice"].DataType = typeof(decimal);
                dt.Columns.Add("ProfitAmount");
                dt.Columns["ProfitAmount"].DataType = typeof(decimal);
                dt.Columns.Add("PaymentTime");
                dt.Columns.Add("PaymentNumber");
                dt.Columns.Add("PayCash");
                dt.Columns["PayCash"].DataType = typeof(decimal);
                dt.Columns.Add("PayBankCard");
                dt.Columns["PayBankCard"].DataType = typeof(decimal);
                dt.Columns.Add("PayWeChatBalance");
                dt.Columns["PayWeChatBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayAlipayBalance");
                dt.Columns["PayAlipayBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayMoneyBalance");
                dt.Columns["PayMoneyBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayPointBalance");
                dt.Columns["PayPointBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayCouponBalance");
                dt.Columns["PayCouponBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayLoan");
                dt.Columns["PayLoan"].DataType = typeof(decimal);
                dt.Columns.Add("PayThird");
                dt.Columns["PayThird"].DataType = typeof(decimal);
                dt.Columns.Add("PayOther");
                dt.Columns["PayOther"].DataType = typeof(decimal);
                dt.Columns.Add("ClientType");
                dt.Columns.Add("PeopleCount");
                dt.Columns["PeopleCount"].DataType = typeof(Int32);
                dt.Columns.Add("rolename");
                dt.Columns.Add("name");
                dt.Columns.Add("PolicyName");
                dt.Columns.Add("Remark");

                for (int i = 0; i < dtOrderBasic.Rows.Count; i++)
                {
                    DataRow dr = dt.NewRow();
                    dr["BranchName"] = dtOrderBasic.Rows[i]["BranchName"];
                    dr["CustomerName"] = dtOrderBasic.Rows[i]["CustomerName"];
                    dr["CustomerPhoneNumber"] = dtOrderBasic.Rows[i]["CustomerPhoneNumber"];
                    dr["CustomerBranchName"] = dtOrderBasic.Rows[i]["CustomerBranchName"];
                    dr["SourceName"] = dtOrderBasic.Rows[i]["SourceName"];
                    dr["OrderTime"] = dtOrderBasic.Rows[i]["OrderTime"];
                    dr["ServiceName"] = dtOrderBasic.Rows[i]["ServiceName"];
                    dr["OrderNumber"] = dtOrderBasic.Rows[i]["OrderNumber"];
                    dr["TotalOrigPrice"] = dtOrderBasic.Rows[i]["TotalOrigPrice"];
                    dr["TotalSalePrice"] = dtOrderBasic.Rows[i]["TotalSalePrice"];
                    dr["PaymentTime"] = dtOrderBasic.Rows[i]["PaymentTime"];
                    dr["PaymentNumber"] = dtOrderBasic.Rows[i]["PaymentNumber"];
                    dr["PeopleCount"] = dtOrderBasic.Rows[i]["PeopleCount"];
                    dr["ClientType"] = dtOrderBasic.Rows[i]["ClientType"];
                    dr["PolicyName"] = dtOrderBasic.Rows[i]["PolicyName"];
                    dr["Remark"] = dtOrderBasic.Rows[i]["Remark"];
                    dr["rolename"] = dtOrderBasic.Rows[i]["rolename"];
                    dr["name"] = dtOrderBasic.Rows[i]["name"];
                    dr["PayCash"] = dtOrderBasic.Rows[i]["PayCash"];
                    dr["PayMoneyBalance"] = dtOrderBasic.Rows[i]["PayMoneyBalance"];
                    dr["PayBankCard"] = dtOrderBasic.Rows[i]["PayBankCard"];
                    dr["PayOther"] = dtOrderBasic.Rows[i]["PayOther"];
                    dr["PayPointBalance"] = dtOrderBasic.Rows[i]["PayPointBalance"];
                    dr["PayCouponBalance"] = dtOrderBasic.Rows[i]["PayCouponBalance"];
                    dr["PayWeChatBalance"] = dtOrderBasic.Rows[i]["PayWeChatBalance"];
                    dr["PayAlipayBalance"] = dtOrderBasic.Rows[i]["PayAlipayBalance"];
                    dr["PayLoan"] = dtOrderBasic.Rows[i]["PayLoan"];
                    dr["PayThird"] = dtOrderBasic.Rows[i]["PayThird"];
                    dr["ProfitAmount"] = dtOrderBasic.Rows[i]["ProfitAmount"];
                    dt.Rows.Add(dr);
                }

                return dt;

            }
        }

        public DataTable getTreatmentDetail(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSql = @"getTreatmentDetail";
                DataTable dt = db.SetSpCommand(strSql
                , db.Parameter("@CompanyID", companyId, DbType.Int32)
                , db.Parameter("@BranchID", branchId, DbType.Int32)
                , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();
                if (dt == null || dt.Rows.Count == 0)
                {
                    return null;
                }

                return dt;

            }
        }

        public DataTable getIsDesignatedDetail(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSql = @" SELECT  isnull(T51.BranchName,'') BranchName,
                                           isnull(T51.NAME,'') NAME,
                                           isnull(T51.RoleName,'') RoleName,
                                           (isnull(T32.IsDesignatedCount,0) + isnull(T33.IsNotDesignatedCount,0)) CountAll,
                                           isnull(T32.IsDesignatedCount,0) IsDesignatedCount,
                                           isnull(T33.IsNotDesignatedCount,0) IsNotDesignatedCount,
                                           CASE
                                               WHEN T32.IsDesignatedCount IS NULL THEN '0%'
                                               WHEN (T32.IsDesignatedCount + isnull(T33.IsNotDesignatedCount,0)) IS NULL then '0%'
                                               WHEN (T32.IsDesignatedCount + isnull(T33.IsNotDesignatedCount,0)) = 0 then '0%'
                                               else CONVERT(VARCHAR,(CONVERT(DECIMAL(18,0),round((1.0*T32.IsDesignatedCount)/(1.0*(T32.IsDesignatedCount + isnull(T33.IsNotDesignatedCount,0))),5,5)*100))) + '%'
                                           end DesignatedPecent
                                   FROM
                                   (SELECT T11.ExecutorID,
                                           T15.BranchName,
                                           T16.NAME,
                                           T17.RoleName
                                    FROM TREATMENT T11 
                                          INNER JOIN [TBL_TREATGROUP] T12 ON T11.GroupNo = T12.GroupNo
                                          INNER JOIN [TBL_ORDER_SERVICE] T13 ON T12.OrderID = T13.OrderID AND T13.Status <> 3 
                                          INNER JOIN [ORDER] T14 ON T13.OrderID = T14.ID AND T14.RecordType = 1
                                          LEFT JOIN [BRANCH] T15 ON T14.BranchID = T15.ID
                                          LEFT JOIN [ACCOUNT] T16 ON T11.ExecutorID = T16.UserID
                                          LEFT JOIN [TBL_ROLE] T17 ON T17.id = T16.roleid
                                    WHERE T11.Status = 2 
                                    AND (T12.TGStatus = 2)
                                    AND T14.OrderTime > T15.StartTime 
                                    AND T11.FinishTime >= @BeginDay 
                                    AND T11.FinishTime <= @EndDay 
                                    AND T11.CompanyID =@CompanyID ";
                if (branchId > 0)
                {
                    strSql += " AND T11.BranchID=" + branchId.ToString();
                }
                strSql += @" GROUP BY T11.ExecutorID,
                                             T15.BranchName,
                                             T16.NAME,
                                             T17.RoleName 
                                    ) T51
                                    LEFT JOIN (
                                        SELECT  T1.ExecutorID,
                                                count(1) as IsDesignatedCount
                                        FROM [TREATMENT] T1 
                                             INNER JOIN [TBL_TREATGROUP] T2 ON T1.GroupNo = T2.GroupNo AND T1.IsDesignated = 1
                                             INNER JOIN [TBL_ORDER_SERVICE] T3 ON T2.OrderID = T3.OrderID AND T3.Status <> 3 
                                             INNER JOIN [ORDER] T4 ON T3.OrderID = T4.ID AND T4.RecordType = 1
                                             LEFT JOIN [BRANCH] T5 ON T4.BranchID = T5.ID
                                        WHERE T1.Status = 2 
                                        AND (T2.TGStatus = 2)
                                        AND T4.OrderTime > T5.StartTime 
                                        AND T1.FinishTime >= @BeginDay 
                                        AND T1.FinishTime <= @EndDay 
                                        AND T1.CompanyID =@CompanyID ";
                if (branchId > 0)
                {
                    strSql += " AND T1.BranchID=" + branchId.ToString();
                }
                strSql += @" GROUP BY T1.ExecutorID
                                    ) T32 ON T51.ExecutorID = T32.ExecutorID
                                    LEFT JOIN  (
                                        SELECT  T6.ExecutorID,
                                                count(1) as IsNotDesignatedCount
                                        FROM [TREATMENT] T6 
                                             INNER JOIN [TBL_TREATGROUP] T7 ON T6.GroupNo = T7.GroupNo AND T6.IsDesignated = 0
                                             INNER JOIN [TBL_ORDER_SERVICE] T8 ON T7.OrderID = T8.OrderID AND T8.Status <> 3 
                                             INNER JOIN [ORDER] T9 ON T8.OrderID = T9.ID AND T9.RecordType = 1
                                             LEFT JOIN [BRANCH] T10 ON T9.BranchID = T10.ID
                                        WHERE T6.Status = 2 
                                        AND (T7.TGStatus = 2)
                                        AND T9.OrderTime > T10.StartTime 
                                        AND T6.FinishTime >= @BeginDay 
                                        AND T6.FinishTime <= @EndDay 
                                        AND T6.CompanyID =@CompanyID ";
                if (branchId > 0)
                {
                    strSql += "  AND T6.BranchID=" + branchId.ToString();
                }
                strSql += @" GROUP BY T6.ExecutorID
                                    ) T33 ON T51.ExecutorID = T33.ExecutorID
                                    ORDER BY T51.BranchName,
                                             T51.NAME ";

                DataTable dt = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                         , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                         , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();

                return dt;

            }
        }


        public DataTable getNoCompleteTreatmentDetail(int companyId, int branchId)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSql = @"getNoCompleteTreatmentDetail";
                DataTable dt = db.SetSpCommand(strSql
                , db.Parameter("@CompanyID", companyId, DbType.Int32)
                , db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteDataTable();

                return dt;
            }
        }





        public DataTable getNoDeliveryCommodity(int companyId, int branchId)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSql = @"getNoDeliveryCommodity";
                DataTable dt = db.SetSpCommand(strSql
                , db.Parameter("@CompanyID", companyId, DbType.Int32)
                , db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteDataTable();

                return dt;
            }
        }



        #region 门店报表

        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="branchId"></param>
        /// <param name="beginDay"></param>
        /// <param name="endDay"></param>
        /// <returns></returns>
        public DataTable getBranchPerformance(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSqlBasic = @" select T5.BranchID,T6.BranchName,T5.PaymentTime  FROM (
                                            select T3.BranchID,CONVERT(varchar(10), T3.PaymentTime, 111) PaymentTime 
                                            from [ORDER] T1 with (NOLOCK) 
                                            INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T2 with (NOLOCK) 
                                            ON T1.ID = T2.OrderID 
                                            INNER JOIN [PAYMENT] T3 with (NOLOCK) 
                                            ON T2.PaymentID = T3.ID
											LEFT JOIN [TBL_ORDER_SERVICE] T10 ON T1.ID = T10.OrderID AND T1.ProductType = 0
											LEFT JOIN [TBL_ORDER_COMMODITY] T11 ON T1.ID = T11.OrderID AND T1.ProductType = 1
                                            LEFT JOIN [BRANCH] T12 ON T3.BranchID = T12.ID 
                                            where T1.CompanyID=@CompanyID AND T3.PaymentTime >=@BeginDay AND T3.PaymentTime <= @EndDay AND T3.PaymentTime >= T12.StartTime   AND ((T3.Type = 1 AND (T3.Status = 2 OR T3.Status = 3)) OR (T3.Type = 2 AND (T3.Status = 6 OR T3.Status = 7)))
                                             ";
                if (branchId > 0)
                {
                    strSqlBasic += " AND T3.BranchID =@BranchID ";
                }
                strSqlBasic += @" GROUP BY T3.BranchID, CONVERT(varchar(10), T3.PaymentTime, 111) 
                                      union all 
                                    SELECT distinct T4.BranchID,CONVERT(varchar(10), T4.CreateTime, 111) PaymentTime
                                        FROM [TBL_CUSTOMER_BALANCE] T4
                                        INNER JOIN [TBL_MONEY_BALANCE] T7 ON T4.ID = T7.CustomerBalanceID
                                        LEFT JOIN [BRANCH] T8 ON T4.BranchID = T8.ID
                                        WHERE  T4.TargetAccount = 1 AND T4.CompanyID=@CompanyID and T4.CreateTime>@BeginDay AND T4.CreateTime <@EndDay 						
                                        AND NOT EXISTS (SELECT RelatedID FROM (
                                        SELECT T8.RelatedID,COUNT(0) CNT FROM [TBL_CUSTOMER_BALANCE] T8 
                                        WHERE T8.CompanyID=@CompanyID AND T8.CreateTime>@BeginDay AND T8.CreateTime <@EndDay GROUP BY T8.RelatedID
                                        ) T8 WHERE T8.CNT > 1 AND T8.RelatedID IS NOT NULL AND T4.RelatedID = T8.RelatedID)  ";
                if (branchId > 0)
                {
                    strSqlBasic += " AND T4.BranchID =@BranchID ";
                }
                strSqlBasic += @"   ) T5 LEFT JOIN [BRANCH] T6 
                                    ON T5.BranchID = T6.ID 
                                    GROUP BY T5.BranchID,T6.BranchName,T5.PaymentTime 
                                    order by T5.PaymentTime ";


                DataTable dtBasic = db.SetCommand(strSqlBasic
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@BranchID", branchId, DbType.Int32)
                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();

                if (dtBasic == null || dtBasic.Rows.Count == 0)
                {
                    return null;
                }

                string strSqlService = @"  select T8.BranchID,CONVERT(varchar(10), T8.PaymentTime, 111) PaymentTime ,
                                            SUM(T8.ServiceCash) ServiceCash,SUM(T8.ServiceBank) ServiceBank,SUM(T8.ServiceWeChat) ServiceWeChat,SUM(T8.ServiceECardMoney) ServiceECardMoney,SUM(T8.ServiceECardPoint) ServiceECardPoint,SUM(T8.ServiceECardCoupon) ServiceECardCoupon,SUM(T8.ServiceOther) ServiceOther,SUM(T8.ServiceAlipay) ServiceAlipay,SUM(T8.ServiceLoan) ServiceLoan,SUM(T8.ServiceThird) ServiceThird FROM(
                                            select T3.BranchID,T11.OrderID,T3.PaymentTime,
                                            ISNULL(CASE T3.IsUseRate WHEN 1 THEN SUM( CASE T3.Type WHEN 1 THEN T4.PaymentAmount * T4.ProfitRate ELSE T4.PaymentAmount * T4.ProfitRate * -1 END) ELSE SUM( CASE T3.Type WHEN 1 THEN T4.PaymentAmount ELSE T4.PaymentAmount * -1 END) END ,0) ServiceCash,
                                            ISNULL(CASE T3.IsUseRate WHEN 1 THEN SUM( CASE T3.Type WHEN 1 THEN T6.PaymentAmount * T6.ProfitRate ELSE T6.PaymentAmount * T6.ProfitRate * -1 END) ELSE SUM( CASE T3.Type WHEN 1 THEN T6.PaymentAmount ELSE T6.PaymentAmount * -1 END) END ,0) ServiceBank,
                                            ISNULL(CASE T3.IsUseRate WHEN 1 THEN SUM( CASE T3.Type WHEN 1 THEN T12.PaymentAmount * T12.ProfitRate ELSE T12.PaymentAmount * T12.ProfitRate * -1 END) ELSE SUM( CASE T3.Type WHEN 1 THEN T12.PaymentAmount ELSE T12.PaymentAmount * -1 END) END ,0) ServiceWeChat,
                                            ISNULL(SUM(T5.PaymentAmount) ,0) ServiceECardMoney,
                                            ISNULL(CASE T3.IsUseRate WHEN 1 THEN SUM( CASE T3.Type WHEN 1 THEN T9.PaymentAmount * T9.ProfitRate ELSE T9.PaymentAmount * T9.ProfitRate * -1 END) ELSE SUM( CASE T3.Type WHEN 1 THEN T9.PaymentAmount ELSE T9.PaymentAmount * -1 END) END ,0) ServiceECardPoint,
                                            ISNULL(CASE T3.IsUseRate WHEN 1 THEN SUM( CASE T3.Type WHEN 1 THEN T10.PaymentAmount * T10.ProfitRate ELSE T10.PaymentAmount * T10.ProfitRate * -1 END) ELSE SUM( CASE T3.Type WHEN 1 THEN T10.PaymentAmount ELSE T10.PaymentAmount * -1 END) END ,0) ServiceECardCoupon,
                                            ISNULL(CASE T3.IsUseRate WHEN 1 THEN SUM( CASE T3.Type WHEN 1 THEN T7.PaymentAmount * T7.ProfitRate ELSE T7.PaymentAmount * T7.ProfitRate * -1 END) ELSE SUM( CASE T3.Type WHEN 1 THEN T7.PaymentAmount ELSE T7.PaymentAmount * -1 END) END ,0) ServiceOther ,
                                            ISNULL(CASE T3.IsUseRate WHEN 1 THEN SUM( CASE T3.Type WHEN 1 THEN T14.PaymentAmount * T14.ProfitRate ELSE T14.PaymentAmount * T14.ProfitRate * -1 END) ELSE SUM( CASE T3.Type WHEN 1 THEN T14.PaymentAmount ELSE T14.PaymentAmount * -1 END) END ,0) ServiceAlipay,
                                            ISNULL(CASE T3.IsUseRate WHEN 1 THEN SUM( CASE T3.Type WHEN 1 THEN T15.PaymentAmount * T15.ProfitRate ELSE T15.PaymentAmount * T15.ProfitRate * -1 END) ELSE SUM( CASE T3.Type WHEN 1 THEN T15.PaymentAmount ELSE T15.PaymentAmount * -1 END) END ,0) ServiceLoan,
                                            ISNULL(CASE T3.IsUseRate WHEN 1 THEN SUM( CASE T3.Type WHEN 1 THEN T16.PaymentAmount * T16.ProfitRate ELSE T16.PaymentAmount * T16.ProfitRate * -1 END) ELSE SUM( CASE T3.Type WHEN 1 THEN T16.PaymentAmount ELSE T16.PaymentAmount * -1 END) END ,0) ServiceThird
                                            from [ORDER] T1 with (NOLOCK) 
											INNER JOIN [TBL_ORDER_SERVICE] T11 ON T1.ID = T11.OrderID 
                                            INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T2 with (NOLOCK) 
                                            ON T1.ID = T2.OrderID 
                                            INNER JOIN [PAYMENT] T3 with (NOLOCK) 
                                            ON T2.PaymentID = T3.ID  AND T3.OrderNumber = 1 
                                            LEFT JOIN [PAYMENT_DETAIL] T4 with (Nolock) 
                                            on T3.ID = T4.PaymentID AND T4.PaymentMode = 0 	
                                            LEFT JOIN 
                                            (select CASE T14.IsUseRate WHEN 1 THEN SUM(CASE T14.Type WHEN 1 THEN T11.PaymentAmount * T11.ProfitRate ELSE T11.PaymentAmount * T11.ProfitRate * - 1 END) ELSE SUM(CASE T14.Type WHEN 1 THEN T11.PaymentAmount ELSE T11.PaymentAmount * - 1 END) END PaymentAmount,T11.PaymentID from [PAYMENT_DETAIL] T11 INNER JOIN [PAYMENT] T14 ON T11.PaymentID = T14.ID LEFT JOIN [BRANCH] T15 ON T14.BranchID = T15.ID WHERE T11.PaymentMode = 1 GROUP BY T11.PaymentID,T14.IsUseRate,T15.ID )  T5
                                            ON T3.ID = T5.PaymentID
                                            LEFT JOIN [PAYMENT_DETAIL] T6 with (Nolock) 
                                            on T3.ID = T6.PaymentID AND T6.PaymentMode = 2
                                            LEFT JOIN [PAYMENT_DETAIL] T7 with (Nolock) 
                                            on T3.ID = T7.PaymentID AND T7.PaymentMode = 3
                                            LEFT JOIN [PAYMENT_DETAIL] T9 with (Nolock) 
                                            on T3.ID = T9.PaymentID AND T9.PaymentMode = 6
                                            LEFT JOIN [PAYMENT_DETAIL] T10 with (Nolock) 
                                            on T3.ID = T10.PaymentID AND T10.PaymentMode = 7
                                            LEFT JOIN [PAYMENT_DETAIL] T12 with (Nolock) 
                                            on T3.ID = T12.PaymentID AND T12.PaymentMode = 8
                                            LEFT JOIN [PAYMENT_DETAIL] T14 with (Nolock) 
                                            on T3.ID = T14.PaymentID AND T14.PaymentMode = 9
                                            LEFT JOIN [PAYMENT_DETAIL] T15 with (Nolock) 
                                            on T3.ID = T15.PaymentID AND T15.PaymentMode = 100
                                            LEFT JOIN [PAYMENT_DETAIL] T16 with (Nolock) 
                                            on T3.ID = T16.PaymentID AND T16.PaymentMode = 101
											left join [BRANCH] T13 ON T3.BranchID = T13.ID
                                            where T11.CompanyID=@CompanyID AND T3.PaymentTime >=@BeginDay AND T3.PaymentTime <= @EndDay 
                                            AND T1.ProductType = 0 and ((T3.Type = 1 AND (T3.Status = 2 OR T3.Status = 3)) OR (T3.Type = 2 AND (T3.Status = 6 OR T3.Status = 7))) AND T3.PaymentTime > T13.StartTime ";
                if (branchId > 0)
                {
                    strSqlService += " AND T11.BranchID =@BranchID ";
                }


                strSqlService += @"  GROUP BY  T3.BranchID,T11.OrderID,T3.PaymentTime,T3.IsUseRate
                                            union all
                                            select T3.BranchID,T11.OrderID,T3.PaymentTime,
                                            Case when ISNULL(SUM(T4.PaymentAmount),0) > 0 THEN 
											CASE T3.IsUseRate WHEN 1 THEN CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice * T4.ProfitRate) ELSE SUM(T11.SumSalePrice * T4.ProfitRate * -1) END ELSE
											CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice) ELSE SUM(T11.SumSalePrice * -1) END END ELSE 0 END ServiceCash, 
                                            Case when ISNULL(SUM(T6.PaymentAmount),0) > 0 THEN 
											CASE T3.IsUseRate WHEN 1 THEN CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice * T6.ProfitRate) ELSE SUM(T11.SumSalePrice * T6.ProfitRate * -1) END ELSE
											CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice) ELSE SUM(T11.SumSalePrice * -1) END END ELSE 0 END ServiceBank,
                                            Case when ISNULL(SUM(T12.PaymentAmount),0) > 0 THEN 
											CASE T3.IsUseRate WHEN 1 THEN CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice * T12.ProfitRate) ELSE SUM(T11.SumSalePrice * T12.ProfitRate * -1) END ELSE
											CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice) ELSE SUM(T11.SumSalePrice * -1) END END ELSE 0 END  ServiceWeChat,
                                            Case when ISNULL(SUM(T5.PaymentAmount),0) > 0 THEN 
											CASE T3.IsUseRate WHEN 1 THEN CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice * T5.ProfitRate) ELSE SUM(T11.SumSalePrice * T5.ProfitRate * -1) END ELSE
											CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice) ELSE SUM(T11.SumSalePrice * -1) END END ELSE 0 END ServiceECardMoney,
                                            Case when ISNULL(SUM(T9.PaymentAmount),0) > 0 THEN 
											CASE T3.IsUseRate WHEN 1 THEN CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice * T9.ProfitRate) ELSE SUM(T11.SumSalePrice * T9.ProfitRate * -1) END ELSE
											CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice) ELSE SUM(T11.SumSalePrice * -1) END END ELSE 0 END ServiceECardPoint,
                                            Case when ISNULL(SUM(T10.PaymentAmount),0) > 0 THEN 
											CASE T3.IsUseRate WHEN 1 THEN CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice * T10.ProfitRate) ELSE SUM(T11.SumSalePrice * T10.ProfitRate * -1) END ELSE
											CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice) ELSE SUM(T11.SumSalePrice * -1) END END ELSE 0 END  ServiceECardCoupon,
                                            Case when ISNULL(SUM(T7.PaymentAmount),0) > 0 THEN 
											CASE T3.IsUseRate WHEN 1 THEN CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice * T7.ProfitRate) ELSE SUM(T11.SumSalePrice * T7.ProfitRate * -1) END ELSE
											CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice) ELSE SUM(T11.SumSalePrice * -1) END END ELSE 0 END ServiceOther  ,
                                            Case when ISNULL(SUM(T14.PaymentAmount),0) > 0 THEN 
											CASE T3.IsUseRate WHEN 1 THEN CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice * T14.ProfitRate) ELSE SUM(T11.SumSalePrice * T14.ProfitRate * -1) END ELSE
											CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice) ELSE SUM(T11.SumSalePrice * -1) END END ELSE 0 END ServiceAlipay  ,
                                            Case when ISNULL(SUM(T15.PaymentAmount),0) > 0 THEN 
											CASE T3.IsUseRate WHEN 1 THEN CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice * T15.ProfitRate) ELSE SUM(T11.SumSalePrice * T15.ProfitRate * -1) END ELSE
											CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice) ELSE SUM(T11.SumSalePrice * -1) END END ELSE 0 END ServiceLoan   ,
                                            Case when ISNULL(SUM(T16.PaymentAmount),0) > 0 THEN 
											CASE T3.IsUseRate WHEN 1 THEN CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice * T16.ProfitRate) ELSE SUM(T11.SumSalePrice * T16.ProfitRate * -1) END ELSE
											CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice) ELSE SUM(T11.SumSalePrice * -1) END END ELSE 0 END ServiceThird   
                                            from  [ORDER] T1 with (NOLOCK) 
											INNER JOIN [TBL_ORDER_SERVICE] T11 ON T1.ID = T11.OrderID 
                                            INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T2 with (NOLOCK) 
                                            ON T1.ID = T2.OrderID 
                                            INNER JOIN [PAYMENT] T3 with (NOLOCK) 
                                            ON T2.PaymentID = T3.ID  AND T3.OrderNumber > 1 
                                            LEFT JOIN [PAYMENT_DETAIL] T4 with (Nolock) 
                                            on T3.ID = T4.PaymentID AND T4.PaymentMode = 0 
                                            LEFT JOIN 
                                            (select SUM(T11.PaymentAmount) PaymentAmount,T11.PaymentID,T11.ProfitRate from [PAYMENT_DETAIL] T11 WHERE T11.PaymentMode = 1 GROUP BY T11.PaymentID,T11.ProfitRate)  T5
                                            ON T3.ID = T5.PaymentID
                                            LEFT JOIN [PAYMENT_DETAIL] T6 with (Nolock) 
                                            on T3.ID = T6.PaymentID AND T6.PaymentMode = 2
                                            LEFT JOIN [PAYMENT_DETAIL] T7 with (Nolock) 
                                            on T3.ID = T7.PaymentID AND T7.PaymentMode = 3
                                            LEFT JOIN [PAYMENT_DETAIL] T9 with (Nolock) 
                                            on T3.ID = T9.PaymentID AND T9.PaymentMode = 6
                                            LEFT JOIN [PAYMENT_DETAIL] T10 with (Nolock) 
                                            on T3.ID = T10.PaymentID AND T10.PaymentMode = 7
                                            LEFT JOIN [PAYMENT_DETAIL] T12 with (Nolock) 
                                            on T3.ID = T12.PaymentID AND T12.PaymentMode = 8
                                            LEFT JOIN [PAYMENT_DETAIL] T14 with (Nolock) 
                                            on T3.ID = T14.PaymentID AND T14.PaymentMode = 9
                                            LEFT JOIN [PAYMENT_DETAIL] T15 with (Nolock) 
                                            on T3.ID = T15.PaymentID AND T15.PaymentMode = 100
                                            LEFT JOIN [PAYMENT_DETAIL] T16 with (Nolock) 
                                            on T3.ID = T16.PaymentID AND T16.PaymentMode = 101
											left join [BRANCH] T13 ON T3.BranchID = T13.ID
                                            where T11.CompanyID=@CompanyID AND T3.PaymentTime >=@BeginDay AND T3.PaymentTime <= @EndDay  AND T1.ProductType = 0 and ((T3.Type = 1 AND (T3.Status = 2 OR T3.Status = 3)) OR (T3.Type = 2 AND (T3.Status = 6 OR T3.Status = 7)))  AND T3.PaymentTime > T13.StartTime ";
                if (branchId > 0)
                {
                    strSqlService += " AND T11.BranchID =@BranchID ";
                }
                strSqlService += @" GROUP BY T3.BranchID ,T11.OrderID,T3.PaymentTime,T3.Type,T3.IsUseRate ) T8 
                                GROUP BY T8.BranchID,CONVERT(varchar(10), T8.PaymentTime, 111) 
                                order by T8.BranchID, CONVERT(varchar(10), T8.PaymentTime, 111) ";

                DataTable dtService = db.SetCommand(strSqlService
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@BranchID", branchId, DbType.Int32)
                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();

                string strSqlCommodity = @" select T8.BranchID,CONVERT(varchar(10), T8.PaymentTime, 111) PaymentTime ,
                                            SUM(T8.CommodityCash) CommodityCash,SUM(T8.CommodityBank) CommodityBank,SUM(T8.CommodityWeChat) CommodityWeChat,SUM(T8.CommodityECardMoney) CommodityECardMoney,SUM(T8.CommodityECardPoint) CommodityECardPoint,SUM(T8.CommodityECardCoupon) CommodityECardCoupon,SUM(T8.CommodityOther) CommodityOther ,SUM(T8.CommodityAlipay) CommodityAlipay  ,SUM(T8.CommodityLoan) CommodityLoan  ,SUM(T8.CommodityThird) CommodityThird  
                                            from (
                                                  select T3.BranchID,T11.OrderID,T3.PaymentTime,
                                            ISNULL(CASE T3.IsUseRate WHEN 1 THEN SUM( CASE T3.Type WHEN 1 THEN T4.PaymentAmount * T4.ProfitRate ELSE T4.PaymentAmount * T4.ProfitRate * -1 END) ELSE SUM( CASE T3.Type WHEN 1 THEN T4.PaymentAmount ELSE T4.PaymentAmount * -1 END) END ,0) CommodityCash,
                                            ISNULL(CASE T3.IsUseRate WHEN 1 THEN SUM( CASE T3.Type WHEN 1 THEN T6.PaymentAmount * T6.ProfitRate ELSE T6.PaymentAmount * T6.ProfitRate * -1 END) ELSE SUM( CASE T3.Type WHEN 1 THEN T6.PaymentAmount ELSE T6.PaymentAmount * -1 END) END ,0) CommodityBank,
                                            ISNULL(CASE T3.IsUseRate WHEN 1 THEN SUM( CASE T3.Type WHEN 1 THEN T12.PaymentAmount * T12.ProfitRate ELSE T12.PaymentAmount * T12.ProfitRate * -1 END) ELSE SUM( CASE T3.Type WHEN 1 THEN T12.PaymentAmount ELSE T12.PaymentAmount * -1 END) END ,0) CommodityWeChat,
                                            ISNULL(SUM(T5.PaymentAmount) ,0) CommodityECardMoney,
                                            ISNULL(CASE T3.IsUseRate WHEN 1 THEN SUM( CASE T3.Type WHEN 1 THEN T9.PaymentAmount * T9.ProfitRate ELSE T9.PaymentAmount * T9.ProfitRate * -1 END) ELSE SUM( CASE T3.Type WHEN 1 THEN T9.PaymentAmount ELSE T9.PaymentAmount * -1 END) END ,0) CommodityECardPoint,
                                            ISNULL(CASE T3.IsUseRate WHEN 1 THEN SUM( CASE T3.Type WHEN 1 THEN T10.PaymentAmount * T10.ProfitRate ELSE T10.PaymentAmount * T10.ProfitRate * -1 END) ELSE SUM( CASE T3.Type WHEN 1 THEN T10.PaymentAmount ELSE T10.PaymentAmount * -1 END) END ,0) CommodityECardCoupon,
                                            ISNULL(CASE T3.IsUseRate WHEN 1 THEN SUM( CASE T3.Type WHEN 1 THEN T7.PaymentAmount * T7.ProfitRate ELSE T7.PaymentAmount * T7.ProfitRate * -1 END) ELSE SUM( CASE T3.Type WHEN 1 THEN T7.PaymentAmount ELSE T7.PaymentAmount * -1 END) END ,0) CommodityOther ,
                                            ISNULL(CASE T3.IsUseRate WHEN 1 THEN SUM( CASE T3.Type WHEN 1 THEN T14.PaymentAmount * T14.ProfitRate ELSE T14.PaymentAmount * T14.ProfitRate * -1 END) ELSE SUM( CASE T3.Type WHEN 1 THEN T14.PaymentAmount ELSE T14.PaymentAmount * -1 END) END ,0) CommodityAlipay ,
                                            ISNULL(CASE T3.IsUseRate WHEN 1 THEN SUM( CASE T3.Type WHEN 1 THEN T15.PaymentAmount * T15.ProfitRate ELSE T15.PaymentAmount * T15.ProfitRate * -1 END) ELSE SUM( CASE T3.Type WHEN 1 THEN T15.PaymentAmount ELSE T15.PaymentAmount * -1 END) END ,0) CommodityLoan ,
                                            ISNULL(CASE T3.IsUseRate WHEN 1 THEN SUM( CASE T3.Type WHEN 1 THEN T16.PaymentAmount * T14.ProfitRate ELSE T16.PaymentAmount * T14.ProfitRate * -1 END) ELSE SUM( CASE T3.Type WHEN 1 THEN T16.PaymentAmount ELSE T16.PaymentAmount * -1 END) END ,0) CommodityThird 
                                            from [ORDER] T1 with (NOLOCK) 
											INNER JOIN [TBL_ORDER_COMMODITY] T11 ON T1.ID = T11.OrderID 
                                            INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T2 with (NOLOCK) 
                                            ON T1.ID = T2.OrderID 
                                            INNER JOIN [PAYMENT] T3 with (NOLOCK) 
                                            ON T2.PaymentID = T3.ID  AND T3.OrderNumber = 1 
                                            LEFT JOIN [PAYMENT_DETAIL] T4 with (Nolock) 
                                            on T3.ID = T4.PaymentID AND T4.PaymentMode = 0 
                                         
                                            LEFT JOIN 
                                            (select CASE T14.IsUseRate WHEN 1 THEN SUM(CASE T14.Type WHEN 1 THEN T11.PaymentAmount * T11.ProfitRate ELSE T11.PaymentAmount * T11.ProfitRate * - 1 END) ELSE SUM(CASE T14.Type WHEN 1 THEN T11.PaymentAmount ELSE T11.PaymentAmount * - 1 END) END PaymentAmount,T11.PaymentID from [PAYMENT_DETAIL] T11 INNER JOIN [PAYMENT] T14 ON T11.PaymentID = T14.ID LEFT JOIN [BRANCH] T15 ON T14.BranchID = T15.ID WHERE T11.PaymentMode = 1 GROUP BY T11.PaymentID,T14.IsUseRate,T15.ID )  T5
                                            ON T3.ID = T5.PaymentID
                                            LEFT JOIN [PAYMENT_DETAIL] T6 with (Nolock) 
                                            on T3.ID = T6.PaymentID AND T6.PaymentMode = 2
                                            LEFT JOIN [PAYMENT_DETAIL] T7 with (Nolock) 
                                            on T3.ID = T7.PaymentID AND T7.PaymentMode = 3
                                            LEFT JOIN [PAYMENT_DETAIL] T9 with (Nolock) 
                                            on T3.ID = T9.PaymentID AND T9.PaymentMode = 6
                                            LEFT JOIN [PAYMENT_DETAIL] T10 with (Nolock) 
                                            on T3.ID = T10.PaymentID AND T10.PaymentMode = 7
                                            LEFT JOIN [PAYMENT_DETAIL] T12 with (Nolock) 
                                            on T3.ID = T12.PaymentID AND T12.PaymentMode = 8
                                            LEFT JOIN [PAYMENT_DETAIL] T14 with (Nolock) 
                                            on T3.ID = T14.PaymentID AND T14.PaymentMode = 9
                                            LEFT JOIN [PAYMENT_DETAIL] T15 with (Nolock) 
                                            on T3.ID = T15.PaymentID AND T15.PaymentMode = 100
                                            LEFT JOIN [PAYMENT_DETAIL] T16 with (Nolock) 
                                            on T3.ID = T16.PaymentID AND T16.PaymentMode = 101
											left join [BRANCH] T13 ON T3.BranchID = T13.ID
                                            where T11.CompanyID=@CompanyID AND T3.PaymentTime >=@BeginDay AND T3.PaymentTime <= @EndDay AND  T1.ProductType = 1 and  ((T3.Type = 1 AND (T3.Status = 2 OR T3.Status = 3)) OR (T3.Type = 2 AND (T3.Status = 6 OR T3.Status = 7))) AND T3.PaymentTime > T13.StartTime  ";
                if (branchId > 0)
                {
                    strSqlCommodity += " AND T11.BranchID =@BranchID ";
                }


                strSqlCommodity += @" GROUP BY  T3.BranchID,T11.OrderID,T3.PaymentTime,T3.IsUseRate
                                            union all
                                            select T3.BranchID,T11.OrderID,T3.PaymentTime,

                                            Case when ISNULL(SUM(T4.PaymentAmount),0) > 0 THEN 
											CASE T3.IsUseRate WHEN 1 THEN CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice * T4.ProfitRate) ELSE SUM(T11.SumSalePrice * T4.ProfitRate * -1) END ELSE
											 CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice) ELSE SUM(T11.SumSalePrice * -1) END END ELSE 0 END CommodityCash, 
                                             Case when ISNULL(SUM(T6.PaymentAmount),0) > 0 THEN 
											CASE T3.IsUseRate WHEN 1 THEN CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice * T6.ProfitRate) ELSE SUM(T11.SumSalePrice * T6.ProfitRate * -1) END ELSE
											 CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice) ELSE SUM(T11.SumSalePrice * -1) END END ELSE 0 END CommodityBank,
                                           Case when ISNULL(SUM(T12.PaymentAmount),0) > 0 THEN 
											CASE T3.IsUseRate WHEN 1 THEN CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice * T12.ProfitRate) ELSE SUM(T11.SumSalePrice * T12.ProfitRate * -1) END ELSE
											 CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice) ELSE SUM(T11.SumSalePrice * -1) END END ELSE 0 END  CommodityWeChat,
                                             Case when ISNULL(SUM(T5.PaymentAmount),0) > 0 THEN 
											CASE T3.IsUseRate WHEN 1 THEN CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice * T5.ProfitRate) ELSE SUM(T11.SumSalePrice * T5.ProfitRate * -1) END ELSE
											 CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice) ELSE SUM(T11.SumSalePrice * -1) END END ELSE 0 END CommodityECardMoney,
                                             Case when ISNULL(SUM(T9.PaymentAmount),0) > 0 THEN 
											CASE T3.IsUseRate WHEN 1 THEN CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice * T9.ProfitRate) ELSE SUM(T11.SumSalePrice * T9.ProfitRate * -1) END ELSE
											 CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice) ELSE SUM(T11.SumSalePrice * -1) END END ELSE 0 END CommodityECardPoint,
                                           Case when ISNULL(SUM(T10.PaymentAmount),0) > 0 THEN 
											CASE T3.IsUseRate WHEN 1 THEN CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice * T10.ProfitRate) ELSE SUM(T11.SumSalePrice * T10.ProfitRate * -1) END ELSE
											 CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice) ELSE SUM(T11.SumSalePrice * -1) END END ELSE 0 END  CommodityECardCoupon,
                                             Case when ISNULL(SUM(T7.PaymentAmount),0) > 0 THEN 
											CASE T3.IsUseRate WHEN 1 THEN CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice * T7.ProfitRate) ELSE SUM(T11.SumSalePrice * T7.ProfitRate * -1) END ELSE
											 CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice) ELSE SUM(T11.SumSalePrice * -1) END END ELSE 0 END CommodityOther  ,
                                             Case when ISNULL(SUM(T14.PaymentAmount),0) > 0 THEN 
											CASE T3.IsUseRate WHEN 1 THEN CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice * T14.ProfitRate) ELSE SUM(T11.SumSalePrice * T14.ProfitRate * -1) END ELSE
											 CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice) ELSE SUM(T11.SumSalePrice * -1) END END ELSE 0 END CommodityAlipay ,
                                             Case when ISNULL(SUM(T15.PaymentAmount),0) > 0 THEN 
											CASE T3.IsUseRate WHEN 1 THEN CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice * T15.ProfitRate) ELSE SUM(T11.SumSalePrice * T15.ProfitRate * -1) END ELSE
											 CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice) ELSE SUM(T11.SumSalePrice * -1) END END ELSE 0 END CommodityLoan ,
                                             Case when ISNULL(SUM(T16.PaymentAmount),0) > 0 THEN 
											CASE T3.IsUseRate WHEN 1 THEN CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice * T16.ProfitRate) ELSE SUM(T11.SumSalePrice * T16.ProfitRate * -1) END ELSE
											 CASE T3.Type WHEN 1 THEN SUM(T11.SumSalePrice) ELSE SUM(T11.SumSalePrice * -1) END END ELSE 0 END CommodityThird
                                            from  [ORDER] T1 with (NOLOCK) 
											INNER JOIN [TBL_ORDER_COMMODITY] T11 ON T1.ID = T11.OrderID 
                                            INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T2 with (NOLOCK) 
                                            ON T1.ID = T2.OrderID 
                                            INNER JOIN [PAYMENT] T3 with (NOLOCK) 
                                            ON T2.PaymentID = T3.ID  AND T3.OrderNumber > 1 
                                            LEFT JOIN [PAYMENT_DETAIL] T4 with (Nolock) 
                                            on T3.ID = T4.PaymentID AND T4.PaymentMode = 0 
                                         
                                            LEFT JOIN 
                                            (select SUM(T12.PaymentAmount) PaymentAmount,T12.PaymentID,T12.ProfitRate from [PAYMENT_DETAIL] T12 WHERE T12.PaymentMode = 1 GROUP BY T12.PaymentID,T12.ProfitRate)  T5
                                            ON T3.ID = T5.PaymentID
                                            LEFT JOIN [PAYMENT_DETAIL] T6 with (Nolock) 
                                            on T3.ID = T6.PaymentID AND T6.PaymentMode = 2
                                            LEFT JOIN [PAYMENT_DETAIL] T7 with (Nolock) 
                                            on T3.ID = T7.PaymentID AND T7.PaymentMode = 3
                                            LEFT JOIN [PAYMENT_DETAIL] T9 with (Nolock) 
                                            on T3.ID = T9.PaymentID AND T9.PaymentMode = 6
                                            LEFT JOIN [PAYMENT_DETAIL] T10 with (Nolock) 
                                            on T3.ID = T10.PaymentID AND T10.PaymentMode = 7
                                            LEFT JOIN [PAYMENT_DETAIL] T12 with (Nolock) 
                                            on T3.ID = T12.PaymentID AND T12.PaymentMode = 8
                                            LEFT JOIN [PAYMENT_DETAIL] T14 with (Nolock) 
                                            on T3.ID = T14.PaymentID AND T14.PaymentMode = 9
                                            LEFT JOIN [PAYMENT_DETAIL] T15 with (Nolock) 
                                            on T3.ID = T15.PaymentID AND T15.PaymentMode = 100
                                            LEFT JOIN [PAYMENT_DETAIL] T16 with (Nolock) 
                                            on T3.ID = T16.PaymentID AND T16.PaymentMode = 101
											left join [BRANCH] T13 ON T3.BranchID = T13.ID
                                            where T11.CompanyID=@CompanyID AND T3.PaymentTime >=@BeginDay AND T3.PaymentTime <= @EndDay       AND T1.ProductType = 1 and ((T3.Type = 1 AND (T3.Status = 2 OR T3.Status = 3)) OR (T3.Type = 2 AND (T3.Status = 6 OR T3.Status = 7))) AND T3.PaymentTime > T13.StartTime  ";
                if (branchId > 0)
                {
                    strSqlCommodity += " AND T11.BranchID =@BranchID ";
                }
                strSqlCommodity += @" 	GROUP BY  T3.BranchID,T11.OrderID,T3.PaymentTime,T3.Type,T3.IsUseRate) T8 
                                        GROUP BY T8.BranchID,CONVERT(varchar(10), T8.PaymentTime, 111) 
                                        order by T8.BranchID, CONVERT(varchar(10), T8.PaymentTime, 111) ";

                DataTable dtCommodity = db.SetCommand(strSqlCommodity
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@BranchID", branchId, DbType.Int32)
                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();

                string strSqlRecharge = @"SELECT SUM(T4.Cash) Cash , SUM(T4.Bank) Bank,SUM(T4.WeChat) WeChat,SUM(T4.Alipay) Alipay,T4.BranchID,T4.PaymentTime FROM (
                                        SELECT  CASE WHEN T2.ActionMode = 3 AND T2.DepositMode = 1 THEN ISNULL(T2.Amount,0) WHEN T2.ActionMode = 4 AND T2.DepositMode = 1 THEN ISNULL(T2.Amount,0) ELSE 0 END Cash,
                                        CASE WHEN T2.ActionMode = 3 AND T2.DepositMode = 2 THEN ISNULL(T2.Amount,0) WHEN T2.ActionMode = 4 AND T2.DepositMode = 2 THEN ISNULL(T2.Amount,0) ELSE 0 END Bank,
                                        CASE WHEN T2.ActionMode = 3 AND T2.DepositMode = 4 THEN ISNULL(T2.Amount,0) WHEN T2.ActionMode = 4 AND T2.DepositMode = 4 THEN ISNULL(T2.Amount,0) ELSE 0 END WeChat,
                                        CASE WHEN T2.ActionMode = 3 AND T2.DepositMode = 5 THEN ISNULL(T2.Amount,0) WHEN T2.ActionMode = 4 AND T2.DepositMode = 4 THEN ISNULL(T2.Amount,0) ELSE 0 END Alipay,
                                        T1.BranchID,CONVERT(varchar(10), T1.CreateTime, 111) PaymentTime
                                        FROM [TBL_CUSTOMER_BALANCE] T1
                                        INNER JOIN [TBL_MONEY_BALANCE] T2 ON T1.ID = T2.CustomerBalanceID
                                        LEFT JOIN [BRANCH] T3 ON T1.BranchID = T3.ID
                                        WHERE  T1.TargetAccount = 1 AND T1.CompanyID=@CompanyID and T1.CreateTime>@BeginDay AND T1.CreateTime <@EndDay AND T1.CreateTime > T3.StartTime							
                                        AND NOT EXISTS (SELECT RelatedID FROM (
                                        SELECT T8.RelatedID,COUNT(0) CNT FROM [TBL_CUSTOMER_BALANCE] T8 
                                        WHERE T8.CompanyID=@CompanyID AND T8.CreateTime>=@BeginDay AND T8.CreateTime <=@EndDay GROUP BY T8.RelatedID
                                        ) T3 WHERE T3.CNT > 1 AND T3.RelatedID IS NOT NULL AND T1.RelatedID = T3.RelatedID) ";
                if (branchId > 0)
                {
                    strSqlRecharge += " and T1.BranchID =@BranchID ";
                }
                strSqlRecharge += @"  ) T4 
	                                        left join [BRANCH] T11 ON T4.BranchID = T11.ID
                                            GROUP BY T4.BranchID,T4.PaymentTime ";

                DataTable dtRecharge = db.SetCommand(strSqlRecharge
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@BranchID", branchId, DbType.Int32)
                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();


                DataTable dt = new DataTable();
                dt.Columns.Add("BranchName");
                dt.Columns.Add("PaymentTime");
                dt.Columns.Add("ServiceCash");
                dt.Columns["ServiceCash"].DataType = typeof(decimal);
                dt.Columns.Add("ServiceBank");
                dt.Columns["ServiceBank"].DataType = typeof(decimal);
                dt.Columns.Add("ServiceWeChat");
                dt.Columns["ServiceWeChat"].DataType = typeof(decimal);
                dt.Columns.Add("ServiceAlipay");
                dt.Columns["ServiceAlipay"].DataType = typeof(decimal);
                dt.Columns.Add("ServiceECardMoney");
                dt.Columns["ServiceECardMoney"].DataType = typeof(decimal);
                dt.Columns.Add("ServiceECardPoint");
                dt.Columns["ServiceECardPoint"].DataType = typeof(decimal);
                dt.Columns.Add("ServiceECardCoupon");
                dt.Columns["ServiceECardCoupon"].DataType = typeof(decimal);
                dt.Columns.Add("ServiceLoan");
                dt.Columns["ServiceLoan"].DataType = typeof(decimal);
                dt.Columns.Add("ServiceThird");
                dt.Columns["ServiceThird"].DataType = typeof(decimal);
                dt.Columns.Add("ServiceOther");
                dt.Columns["ServiceOther"].DataType = typeof(decimal);
                dt.Columns.Add("ServiceAll");
                dt.Columns.Add("ServiceImcome");
                dt.Columns.Add("CommodityCash");
                dt.Columns["CommodityCash"].DataType = typeof(decimal);
                dt.Columns.Add("CommodityBank");
                dt.Columns["CommodityBank"].DataType = typeof(decimal);
                dt.Columns.Add("CommodityWeChat");
                dt.Columns["CommodityWeChat"].DataType = typeof(decimal);
                dt.Columns.Add("CommodityAlipay");
                dt.Columns["CommodityAlipay"].DataType = typeof(decimal);
                dt.Columns.Add("CommodityECardMoney");
                dt.Columns["CommodityECardMoney"].DataType = typeof(decimal);
                dt.Columns.Add("CommodityECardPoint");
                dt.Columns["CommodityECardPoint"].DataType = typeof(decimal);
                dt.Columns.Add("CommodityECardCoupon");
                dt.Columns["CommodityECardCoupon"].DataType = typeof(decimal);
                dt.Columns.Add("CommodityLoan");
                dt.Columns["CommodityLoan"].DataType = typeof(decimal);
                dt.Columns.Add("CommodityThird");
                dt.Columns["CommodityThird"].DataType = typeof(decimal);
                dt.Columns.Add("CommodityOther");
                dt.Columns["CommodityOther"].DataType = typeof(decimal);
                dt.Columns.Add("CommodityAll");
                dt.Columns.Add("CommodityImcome");
                dt.Columns.Add("RechargeCash");
                dt.Columns["RechargeCash"].DataType = typeof(decimal);
                dt.Columns.Add("RechargeBank");
                dt.Columns["RechargeBank"].DataType = typeof(decimal);
                dt.Columns.Add("RechargeWeChat");
                dt.Columns["RechargeWeChat"].DataType = typeof(decimal);
                dt.Columns.Add("RechargeAlipay");
                dt.Columns["RechargeAlipay"].DataType = typeof(decimal);
                dt.Columns.Add("ProductAll");
                dt.Columns.Add("RechargeAll");
                dt.Columns["RechargeAll"].DataType = typeof(decimal);
                dt.Columns.Add("ImcomeAll");
                for (int i = 0; i < dtBasic.Rows.Count; i++)
                {
                    DataRow dr = dt.NewRow();
                    dr["BranchName"] = dtBasic.Rows[i]["BranchName"];
                    dr["PaymentTime"] = dtBasic.Rows[i]["PaymentTime"];

                    string strWhere = "BranchID='" + StringUtils.GetDbInt(dtBasic.Rows[i]["BranchID"]) + "' AND PaymentTime = '" + StringUtils.GetDbDateTime(dtBasic.Rows[i]["PaymentTime"]).ToString("yyyy/MM/dd") + "'";
                    DataRow[] drService = dtService.Select(strWhere);
                    if (drService != null && drService.Length == 1)
                    {
                        dr["ServiceCash"] = drService[0].ItemArray[2];
                        dr["ServiceBank"] = drService[0].ItemArray[3];
                        dr["ServiceWeChat"] = drService[0].ItemArray[4];
                        dr["ServiceECardMoney"] = drService[0].ItemArray[5];
                        dr["ServiceECardPoint"] = drService[0].ItemArray[6];
                        dr["ServiceECardCoupon"] = drService[0].ItemArray[7];
                        dr["ServiceOther"] = drService[0].ItemArray[8];
                        dr["ServiceAlipay"] = drService[0].ItemArray[9];
                        dr["ServiceLoan"] = drService[0].ItemArray[10];
                        dr["ServiceThird"] = drService[0].ItemArray[11];
                    }
                    else
                    {
                        dr["ServiceCash"] = 0;
                        dr["ServiceBank"] = 0;
                        dr["ServiceWeChat"] = 0;
                        dr["ServiceECardMoney"] = 0;
                        dr["ServiceECardPoint"] = 0;
                        dr["ServiceECardCoupon"] = 0;
                        dr["ServiceLoan"] = 0;
                        dr["ServiceThird"] = 0;
                        dr["ServiceOther"] = 0;
                        dr["ServiceAlipay"] = 0;
                    }

                    DataRow[] drCommodity = dtCommodity.Select(strWhere);
                    if (drCommodity != null && drCommodity.Length == 1)
                    {
                        dr["CommodityCash"] = drCommodity[0].ItemArray[2];
                        dr["CommodityBank"] = drCommodity[0].ItemArray[3];
                        dr["CommodityWeChat"] = drCommodity[0].ItemArray[4];
                        dr["CommodityECardMoney"] = drCommodity[0].ItemArray[5];
                        dr["CommodityECardPoint"] = drCommodity[0].ItemArray[6];
                        dr["CommodityECardCoupon"] = drCommodity[0].ItemArray[7];
                        dr["CommodityOther"] = drCommodity[0].ItemArray[8];
                        dr["CommodityAlipay"] = drCommodity[0].ItemArray[9];
                        dr["CommodityLoan"] = drCommodity[0].ItemArray[10];
                        dr["CommodityThird"] = drCommodity[0].ItemArray[11];
                    }
                    else
                    {
                        dr["CommodityCash"] = 0;
                        dr["CommodityBank"] = 0;
                        dr["CommodityWeChat"] = 0;
                        dr["CommodityECardMoney"] = 0;
                        dr["CommodityECardPoint"] = 0;
                        dr["CommodityECardCoupon"] = 0;
                        dr["CommodityOther"] = 0;
                        dr["CommodityAlipay"] = 0;
                        dr["CommodityLoan"] = 0;
                        dr["CommodityThird"] = 0;
                    }

                    DataRow[] drRecharge = dtRecharge.Select(strWhere);
                    if (drRecharge != null && drRecharge.Length == 1)
                    {
                        dr["RechargeCash"] = drRecharge[0].ItemArray[0];
                        dr["RechargeBank"] = drRecharge[0].ItemArray[1];
                        dr["RechargeWeChat"] = drRecharge[0].ItemArray[2];
                        dr["RechargeAlipay"] = drRecharge[0].ItemArray[3];
                    }
                    else
                    {
                        dr["RechargeCash"] = 0;
                        dr["RechargeBank"] = 0;
                        dr["RechargeWeChat"] = 0;
                        dr["RechargeAlipay"] = 0;
                    }
                    dt.Rows.Add(dr);
                }
                return dt;
            }
        }

        public DataTable getBranchServicePayDetail(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSqlOrderBasic = @"getBranchServicePayDetail";
                DataTable dtOrderBasic = db.SetSpCommand(strSqlOrderBasic
                , db.Parameter("@CompanyID", companyId, DbType.Int32)
                , db.Parameter("@BranchID", branchId, DbType.Int32)
                , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();
                if (dtOrderBasic == null || dtOrderBasic.Rows.Count == 0)
                {
                    return null;
                }
                DataTable dt = new DataTable();
                dt.Columns.Add("BranchName");
                dt.Columns.Add("CustomerName");
                dt.Columns.Add("CustomerPhoneNumber");
                dt.Columns.Add("CustomerBranchName");
                dt.Columns.Add("SourceName");
                dt.Columns.Add("OrderTime");
                dt.Columns.Add("ServiceName");
                dt.Columns.Add("OrderNumber");
                dt.Columns.Add("TotalOrigPrice");
                dt.Columns["TotalOrigPrice"].DataType = typeof(decimal);
                dt.Columns.Add("TotalSalePrice");
                dt.Columns["TotalSalePrice"].DataType = typeof(decimal);
                dt.Columns.Add("ProfitAmount");
                dt.Columns["ProfitAmount"].DataType = typeof(decimal);
                dt.Columns.Add("PaymentTime");
                dt.Columns.Add("PaymentNumber");
                dt.Columns.Add("PayCash");
                dt.Columns["PayCash"].DataType = typeof(decimal);
                dt.Columns.Add("PayBankCard");
                dt.Columns["PayBankCard"].DataType = typeof(decimal);
                dt.Columns.Add("PayWeChatBalance");
                dt.Columns["PayWeChatBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayAlipayBalance");
                dt.Columns["PayAlipayBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayMoneyBalance");
                dt.Columns["PayMoneyBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayPointBalance");
                dt.Columns["PayPointBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayCouponBalance");
                dt.Columns["PayCouponBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayLoan");
                dt.Columns["PayLoan"].DataType = typeof(decimal);
                dt.Columns.Add("PayThird");
                dt.Columns["PayThird"].DataType = typeof(decimal);
                dt.Columns.Add("PayOther");
                dt.Columns["PayOther"].DataType = typeof(decimal);
                dt.Columns.Add("PolicyName");
                dt.Columns.Add("OrderSource");
                dt.Columns.Add("Remark");
                dt.Columns.Add("Mark");

                for (int i = 0; i < dtOrderBasic.Rows.Count; i++)
                {
                    DataRow dr = dt.NewRow();
                    dr["BranchName"] = dtOrderBasic.Rows[i]["BranchName"];
                    dr["CustomerName"] = dtOrderBasic.Rows[i]["CustomerName"];
                    dr["CustomerPhoneNumber"] = dtOrderBasic.Rows[i]["CustomerPhoneNumber"];
                    dr["CustomerBranchName"] = dtOrderBasic.Rows[i]["CustomerBranchName"];
                    dr["SourceName"] = dtOrderBasic.Rows[i]["SourceName"];
                    dr["OrderTime"] = dtOrderBasic.Rows[i]["OrderTime"];
                    dr["ServiceName"] = dtOrderBasic.Rows[i]["ServiceName"];
                    dr["OrderNumber"] = dtOrderBasic.Rows[i]["OrderNumber"];
                    dr["TotalOrigPrice"] = dtOrderBasic.Rows[i]["TotalOrigPrice"];
                    dr["TotalSalePrice"] = dtOrderBasic.Rows[i]["TotalSalePrice"];
                    dr["PaymentTime"] = dtOrderBasic.Rows[i]["PaymentTime"];
                    dr["PaymentNumber"] = dtOrderBasic.Rows[i]["PaymentNumber"];
                    dr["PolicyName"] = dtOrderBasic.Rows[i]["PolicyName"];
                    dr["OrderSource"] = dtOrderBasic.Rows[i]["OrderSource"];
                    dr["Remark"] = dtOrderBasic.Rows[i]["Remark"];
                    dr["PayCash"] = dtOrderBasic.Rows[i]["PayCash"];
                    dr["PayMoneyBalance"] = dtOrderBasic.Rows[i]["PayMoneyBalance"];
                    dr["PayBankCard"] = dtOrderBasic.Rows[i]["PayBankCard"];
                    dr["PayOther"] = dtOrderBasic.Rows[i]["PayOther"];
                    dr["PayPointBalance"] = dtOrderBasic.Rows[i]["PayPointBalance"];
                    dr["PayCouponBalance"] = dtOrderBasic.Rows[i]["PayCouponBalance"];
                    dr["PayWeChatBalance"] = dtOrderBasic.Rows[i]["PayWeChatBalance"];
                    dr["PayAlipayBalance"] = dtOrderBasic.Rows[i]["PayAlipayBalance"];
                    dr["PayLoan"] = dtOrderBasic.Rows[i]["PayLoan"];
                    dr["PayThird"] = dtOrderBasic.Rows[i]["PayThird"];
                    dr["ProfitAmount"] = dtOrderBasic.Rows[i]["ProfitAmount"];
                    dr["Mark"] = dtOrderBasic.Rows[i]["Mark"];
                    dt.Rows.Add(dr);
                }

                return dt;

            }
        }


        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="branchId"></param>
        /// <param name="beginDay"></param>
        /// <param name="endDay"></param>
        /// <returns></returns>
        public DataTable getBranchCommodityDeatilReport(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSqlOrderBasic = @"getBranchCommodityDeatilReport";
                DataTable dtOrderBasic = db.SetSpCommand(strSqlOrderBasic
                , db.Parameter("@CompanyID", companyId, DbType.Int32)
                , db.Parameter("@BranchID", branchId, DbType.Int32)
                , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();
                if (dtOrderBasic == null || dtOrderBasic.Rows.Count == 0)
                {
                    return null;
                }
                DataTable dt = new DataTable();
                dt.Columns.Add("BranchName");
                dt.Columns.Add("CustomerName");
                dt.Columns.Add("CustomerPhoneNumber");
                dt.Columns.Add("CustomerBranchName");
                dt.Columns.Add("SourceName");
                dt.Columns.Add("OrderTime");
                dt.Columns.Add("CommodityName");
                dt.Columns.Add("OrderNumber");
                dt.Columns.Add("Quantity");
                dt.Columns.Add("TotalOrigPrice");
                dt.Columns["TotalOrigPrice"].DataType = typeof(decimal);
                dt.Columns.Add("TotalSalePrice");
                dt.Columns["TotalSalePrice"].DataType = typeof(decimal);
                dt.Columns.Add("ProfitAmount");
                dt.Columns["ProfitAmount"].DataType = typeof(decimal);
                dt.Columns.Add("PaymentTime");
                dt.Columns.Add("PaymentNumber");
                dt.Columns.Add("PayCash");
                dt.Columns["PayCash"].DataType = typeof(decimal);
                dt.Columns.Add("PayBankCard");
                dt.Columns["PayBankCard"].DataType = typeof(decimal);
                dt.Columns.Add("PayWeChatBalance");
                dt.Columns["PayWeChatBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayAlipayBalance");
                dt.Columns["PayAlipayBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayMoneyBalance");
                dt.Columns["PayMoneyBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayPointBalance");
                dt.Columns["PayPointBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayCouponBalance");
                dt.Columns["PayCouponBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayLoan");
                dt.Columns["PayLoan"].DataType = typeof(decimal);
                dt.Columns.Add("PayThird");
                dt.Columns["PayThird"].DataType = typeof(decimal);
                dt.Columns.Add("PayOther");
                dt.Columns["PayOther"].DataType = typeof(decimal);
                dt.Columns.Add("PolicyName");
                dt.Columns.Add("OrderSource");
                dt.Columns.Add("Remark");

                for (int i = 0; i < dtOrderBasic.Rows.Count; i++)
                {
                    DataRow dr = dt.NewRow();
                    dr["BranchName"] = dtOrderBasic.Rows[i]["BranchName"];
                    dr["CustomerName"] = dtOrderBasic.Rows[i]["CustomerName"];
                    dr["CustomerPhoneNumber"] = dtOrderBasic.Rows[i]["CustomerPhoneNumber"];
                    dr["CustomerBranchName"] = dtOrderBasic.Rows[i]["CustomerBranchName"];
                    dr["SourceName"] = dtOrderBasic.Rows[i]["SourceName"];
                    dr["OrderTime"] = dtOrderBasic.Rows[i]["OrderTime"];
                    dr["CommodityName"] = dtOrderBasic.Rows[i]["CommodityName"];
                    dr["OrderNumber"] = dtOrderBasic.Rows[i]["OrderNumber"];
                    dr["Quantity"] = dtOrderBasic.Rows[i]["Quantity"];
                    dr["TotalOrigPrice"] = dtOrderBasic.Rows[i]["TotalOrigPrice"];
                    dr["TotalSalePrice"] = dtOrderBasic.Rows[i]["TotalSalePrice"];
                    dr["PaymentTime"] = dtOrderBasic.Rows[i]["PaymentTime"];
                    dr["PaymentNumber"] = dtOrderBasic.Rows[i]["PaymentNumber"];
                    dr["PolicyName"] = dtOrderBasic.Rows[i]["PolicyName"];
                    dr["OrderSource"] = dtOrderBasic.Rows[i]["OrderSource"];
                    dr["Remark"] = dtOrderBasic.Rows[i]["Remark"];
                    dr["PayCash"] = dtOrderBasic.Rows[i]["PayCash"];
                    dr["PayMoneyBalance"] = dtOrderBasic.Rows[i]["PayMoneyBalance"];
                    dr["PayBankCard"] = dtOrderBasic.Rows[i]["PayBankCard"];
                    dr["PayOther"] = dtOrderBasic.Rows[i]["PayOther"];
                    dr["PayPointBalance"] = dtOrderBasic.Rows[i]["PayPointBalance"];
                    dr["PayCouponBalance"] = dtOrderBasic.Rows[i]["PayCouponBalance"];
                    dr["PayWeChatBalance"] = dtOrderBasic.Rows[i]["PayWeChatBalance"];
                    dr["PayAlipayBalance"] = dtOrderBasic.Rows[i]["PayAlipayBalance"];
                    dr["PayLoan"] = dtOrderBasic.Rows[i]["PayLoan"];
                    dr["PayThird"] = dtOrderBasic.Rows[i]["PayThird"];
                    dr["ProfitAmount"] = dtOrderBasic.Rows[i]["ProfitAmount"];
                    dt.Rows.Add(dr);
                }

                return dt;

            }

        }


        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="branchId"></param>
        /// <param name="beginDay"></param>
        /// <param name="endDay"></param>
        /// <returns></returns>
        public DataTable getBranchReChargeDeatilReport(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSqlBasic = @"getBranchReChargeDeatilReport";
                DataTable dsBasic = db.SetSpCommand(strSqlBasic
                , db.Parameter("@CompanyID", companyId, DbType.Int32)
                , db.Parameter("@BranchID", branchId, DbType.Int32)
                , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();
                if (dsBasic == null || dsBasic.Rows.Count == 0)
                {
                    return null;
                }

                return dsBasic;
            }
        }
        #endregion



        public DataTable getStatementServicePayDetail(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSqlOrderBasic = @" SELECT   T4.BranchName,T6.Name AccountName,T13.CategoryName,T3.IsUseRate,T1.PaymentID,T2.TotalSalePrice,T2.ID
                                            FROM [TBL_ORDERPAYMENT_RELATIONSHIP] T1 WITH (NOLOCK)   
                                            INNER JOIN   [ORDER] T2  
                                            ON T2.ID = T1.OrderID AND T2.PaymentStatus > 0  and  T2.ProductType =0  
                                            INNER JOIN   [TBL_ORDER_SERVICE] T11  
                                            ON T2.ID = T11.OrderID 
                                            INNER JOIN [TBL_STATEMENT] T12 ON T11.ServiceCode = T12.ProductCode and T12.ProductType = 0 
											INNER JOIN [TBL_STATEMENT_CATEGORY] T13 ON T12.CategoryID = T13.ID
                                            INNER JOIN [PAYMENT] T3 
                                            ON T1.PaymentID = T3.ID 
                                            INNER JOIN [TBL_PROFIT] P1
                                            ON T1.PaymentID = P1.MasterID AND P1.Available = 1 AND P1.Type =2 
                                            LEFT JOIN [BRANCH] T4 
                                            ON T3.BranchID = T4.ID 
                                           LEFT JOIN [ACCOUNT] T6 WITH (NOLOCK)
                                           ON P1.SlaveID = T6.UserID
                                            where T11.CompanyID =@CompanyID AND T3.PaymentTime >=@BeginDay AND T3.PaymentTime <= @EndDay AND T3.PaymentTime >= T4.StartTime AND ((T3.Type = 1 AND (T3.Status = 2 OR T3.Status = 3)) OR (T3.Type = 2 AND (T3.Status = 6 OR T3.Status = 7)))";

                if (branchId > 0)
                {
                    strSqlOrderBasic += "and T3.BranchID =" + branchId.ToString();
                }
                strSqlOrderBasic += @" GROUP BY  T4.BranchName,T6.Name,T13.CategoryName,T3.IsUseRate,T1.PaymentID,T2.TotalSalePrice ,T2.ID order by T4.BranchName,T6.Name,T13.CategoryName ";


                DataTable dtOrderBasic = db.SetCommand(strSqlOrderBasic, db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();
                if (dtOrderBasic == null || dtOrderBasic.Rows.Count == 0)
                {
                    return null;
                }

                string strPaymentDetail = @"    Select distinct T1.PaymentID,T1.PaymentMode,CASE T2.IsUseRate WHEN 1 THEN SUM(CASE T2.Type WHEN 1 THEN T1.PaymentAmount * T1.ProfitRate ELSE T1.PaymentAmount * T1.ProfitRate * - 1  END) ELSE SUM(CASE T2.Type WHEN 1 THEN T1.PaymentAmount  ELSE T1.PaymentAmount  * - 1  END) END PaymentAmount,T2.OrderNumber ,T2.Type,CASE T2.OrderNumber WHEN 1 THEN 1 ELSE T1.ProfitRate END ProfitRate
                                        from [PAYMENT_DETAIL] T1 
                                        INNER JOIN [PAYMENT] T2 
                                        ON T1.PaymentID = T2.ID  
                                        INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T3 
                                        ON T1.PaymentID = T3.PaymentID 
                                        INNER JOIN [ORDER] T4 
                                        ON T3.OrderID = T4.ID  AND T4.ProductType = 0 AND T4.PaymentStatus > 0 
                                        LEFT JOIN [BRANCH] T5 
                                        ON T2.BranchID = T5.ID 
                                        WHERE T2.PaymentTime >= T5.StartTime AND T2.PaymentTime >= @BeginDay AND T2.PaymentTime <=@EndDay AND T4.CompanyID =@CompanyID AND ((T2.Type = 1 AND (T2.Status = 2 OR T2.Status = 3)) OR (T2.Type = 2 AND (T2.Status = 6 OR T2.Status = 7))) ";

                if (branchId > 0)
                {
                    strPaymentDetail += "and T2.BranchID =" + branchId.ToString();
                }

                strPaymentDetail += " group by T1.PaymentID,T1.PaymentMode,T2.OrderNumber,T2.Type,T2.IsUseRate, T4.TotalSalePrice ,CASE T2.OrderNumber WHEN 1 THEN 1 ELSE T1.ProfitRate END ";

                DataTable dtPaymentDetail = db.SetCommand(strPaymentDetail, db.Parameter("@CompanyID", companyId, DbType.Int32)
                                         , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                                         , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();




                DataTable dt = new DataTable();
                dt.Columns.Add("BranchName");
                dt.Columns.Add("AccountName");
                dt.Columns.Add("CategoryName");
                dt.Columns.Add("ProfitAmount");
                dt.Columns["ProfitAmount"].DataType = typeof(decimal);
                dt.Columns.Add("PayCash");
                dt.Columns["PayCash"].DataType = typeof(decimal);
                dt.Columns.Add("PayBankCard");
                dt.Columns["PayBankCard"].DataType = typeof(decimal);
                dt.Columns.Add("PayWeChatBalance");
                dt.Columns["PayWeChatBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayAlipayBalance");
                dt.Columns["PayAlipayBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayMoneyBalance");
                dt.Columns["PayMoneyBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayPointBalance");
                dt.Columns["PayPointBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayCouponBalance");
                dt.Columns["PayCouponBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayLoan");
                dt.Columns["PayLoan"].DataType = typeof(decimal);
                dt.Columns.Add("PayThird");
                dt.Columns["PayThird"].DataType = typeof(decimal);
                dt.Columns.Add("PayOther");
                dt.Columns["PayOther"].DataType = typeof(decimal);
                dt.Columns.Add("TotalSalePrice");
                dt.Columns["TotalSalePrice"].DataType = typeof(decimal);

                for (int i = 0; i < dtOrderBasic.Rows.Count; i++)
                {
                    DataRow dr = dt.NewRow();
                    dr["BranchName"] = dtOrderBasic.Rows[i]["BranchName"];
                    dr["AccountName"] = dtOrderBasic.Rows[i]["AccountName"];
                    dr["CategoryName"] = dtOrderBasic.Rows[i]["CategoryName"];

                    DataRow[] drPayment = dtPaymentDetail.Select("PaymentID=" + StringUtils.GetDbInt(dtOrderBasic.Rows[i]["PaymentID"]));
                    decimal profitAmount = 0;
                    if (drPayment != null && drPayment.Length > 0)
                    {

                        foreach (DataRow item in drPayment)
                        {
                            int mode = StringUtils.GetDbInt(item.ItemArray[1]);
                            int orderNumber = StringUtils.GetDbInt(item.ItemArray[3]);
                            int type = StringUtils.GetDbInt(item.ItemArray[4]);
                            switch (mode)
                            {
                                case 0:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayCash"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {

                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayCash"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayCash"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayCash"] = StringUtils.GetDbDecimal(dr["PayCash"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayCash"]);
                                    }
                                    else
                                    {
                                        dr["PayCash"] = 0;
                                    }
                                    break;
                                case 1:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayMoneyBalance"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {

                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayMoneyBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayMoneyBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayMoneyBalance"] = StringUtils.GetDbDecimal(dr["PayMoneyBalance"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayMoneyBalance"]);
                                    }
                                    else
                                    {
                                        dr["PayMoneyBalance"] = 0;
                                    }
                                    break;
                                case 2:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayBankCard"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {

                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayBankCard"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayBankCard"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayBankCard"] = StringUtils.GetDbDecimal(dr["PayBankCard"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayBankCard"]);
                                    }
                                    else
                                    {
                                        dr["PayBankCard"] = 0;
                                    }
                                    break;
                                case 3:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayOther"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {

                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayOther"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayOther"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayOther"] = StringUtils.GetDbDecimal(dr["PayOther"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayOther"]);
                                    }
                                    else
                                    {
                                        dr["PayOther"] = 0;
                                    }
                                    break;
                                case 6:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayPointBalance"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {

                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayPointBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayPointBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayPointBalance"] = StringUtils.GetDbDecimal(dr["PayPointBalance"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayPointBalance"]);
                                    }
                                    else
                                    {
                                        dr["PayPointBalance"] = 0;
                                    }
                                    break;
                                case 7:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayCouponBalance"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {

                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayCouponBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayCouponBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayCouponBalance"] = StringUtils.GetDbDecimal(dr["PayCouponBalance"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayCouponBalance"]);
                                    }
                                    else
                                    {
                                        dr["PayCouponBalance"] = 0;
                                    }
                                    break;
                                case 8:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayWeChatBalance"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {

                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayWeChatBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayWeChatBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayWeChatBalance"] = StringUtils.GetDbDecimal(dr["PayWeChatBalance"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayWeChatBalance"]);
                                    }
                                    else
                                    {
                                        dr["PayWeChatBalance"] = 0;
                                    }
                                    break;
                                case 9:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayAlipayBalance"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {

                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayAlipayBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayAlipayBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayAlipayBalance"] = StringUtils.GetDbDecimal(dr["PayAlipayBalance"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayAlipayBalance"]);
                                    }
                                    else
                                    {
                                        dr["PayAlipayBalance"] = 0;
                                    }
                                    break;
                                case 100:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayLoan"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {

                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayLoan"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayLoan"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayLoan"] = StringUtils.GetDbDecimal(dr["PayLoan"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayLoan"]);
                                    }
                                    else
                                    {
                                        dr["PayLoan"] = 0;
                                    }
                                    break;
                                case 101:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayThird"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {

                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayThird"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayThird"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayThird"] = StringUtils.GetDbDecimal(dr["PayThird"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayThird"]);
                                    }
                                    else
                                    {
                                        dr["PayThird"] = 0;
                                    }
                                    break;

                            }
                        }

                    }
                    dr["ProfitAmount"] = StringUtils.GetDbDecimal(dr["PayCash"]) + StringUtils.GetDbDecimal(dr["PayBankCard"]) + StringUtils.GetDbDecimal(dr["PayWeChatBalance"]) + StringUtils.GetDbDecimal(dr["PayMoneyBalance"]) + StringUtils.GetDbDecimal(dr["PayPointBalance"]) + StringUtils.GetDbDecimal(dr["PayCouponBalance"]) + StringUtils.GetDbDecimal(dr["PayOther"]) + StringUtils.GetDbDecimal(dr["PayAlipayBalance"]) + StringUtils.GetDbDecimal(dr["PayLoan"]) + StringUtils.GetDbDecimal(dr["PayThird"]);

                    dt.Rows.Add(dr);
                }


                DataTable dtResult = dt.Clone();
                for (int i = 0; i < dt.Rows.Count; )
                {
                    DataRow dr = dtResult.NewRow();
                    string BranchName = dt.Rows[i]["BranchName"].ToString();
                    string AccountName = dt.Rows[i]["AccountName"].ToString();
                    string CategoryName = dt.Rows[i]["CategoryName"].ToString();
                    dr["BranchName"] = BranchName;
                    dr["AccountName"] = AccountName;
                    dr["CategoryName"] = CategoryName;
                    decimal ProfitAmount = 0;
                    decimal PayCash = 0;
                    decimal PayBankCard = 0;
                    decimal PayWeChatBalance = 0;
                    decimal PayMoneyBalance = 0;
                    decimal PayPointBalance = 0;
                    decimal PayCouponBalance = 0;
                    decimal PayAlipayBalance = 0;
                    decimal PayOther = 0;
                    decimal PayLoan = 0;
                    decimal PayThird = 0;

                    for (; i < dt.Rows.Count; )
                    {
                        if (BranchName == dt.Rows[i]["BranchName"].ToString() && AccountName == dt.Rows[i]["AccountName"].ToString() && CategoryName == dt.Rows[i]["CategoryName"].ToString())
                        {
                            ProfitAmount += StringUtils.GetDbDecimal(dt.Rows[i]["ProfitAmount"]);
                            PayCash += StringUtils.GetDbDecimal(dt.Rows[i]["PayCash"]);
                            PayBankCard += StringUtils.GetDbDecimal(dt.Rows[i]["PayBankCard"]);
                            PayWeChatBalance += StringUtils.GetDbDecimal(dt.Rows[i]["PayWeChatBalance"]);
                            PayAlipayBalance += StringUtils.GetDbDecimal(dt.Rows[i]["PayAlipayBalance"]);
                            PayMoneyBalance += StringUtils.GetDbDecimal(dt.Rows[i]["PayMoneyBalance"]);
                            PayPointBalance += StringUtils.GetDbDecimal(dt.Rows[i]["PayPointBalance"]);
                            PayCouponBalance += StringUtils.GetDbDecimal(dt.Rows[i]["PayCouponBalance"]);
                            PayOther += StringUtils.GetDbDecimal(dt.Rows[i]["PayOther"]);
                            PayLoan += StringUtils.GetDbDecimal(dt.Rows[i]["PayLoan"]);
                            PayThird += StringUtils.GetDbDecimal(dt.Rows[i]["PayThird"]);
                            i++;
                        }
                        else
                        {
                            break;
                        }
                    }

                    dr["ProfitAmount"] = ProfitAmount;
                    dr["PayCash"] = PayCash;
                    dr["PayBankCard"] = PayBankCard;
                    dr["PayWeChatBalance"] = PayWeChatBalance;
                    dr["PayAlipayBalance"] = PayAlipayBalance;
                    dr["PayMoneyBalance"] = PayMoneyBalance;
                    dr["PayPointBalance"] = PayPointBalance;
                    dr["PayCouponBalance"] = PayCouponBalance;
                    dr["PayOther"] = PayOther;
                    dr["PayLoan"] = PayLoan;
                    dr["PayThird"] = PayThird;

                    dtResult.Rows.Add(dr);

                }


                dtResult.Columns.Remove("TotalSalePrice");
                return dtResult;
            }
        }


        public DataTable getStatementTreatmentDetail(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSql = @"   select T5.BranchName,T6.Name ExecutorName,T12.CategoryName,ISNULL(T13.SubServiceName,'服务') SubServiceName ,T1.ID DoCount,CASE T1.IsDesignated WHEN 1 THEN 1 ELSE  0 END Designated,CASE T1.IsDesignated WHEN 0 THEN 1 ELSE 0 END NotDesignated ,0.00 as ProfitAmount, T3.ID OrderID,T4.TGTotalCount
                                from [TREATMENT] T1 
                                INNER JOIN [TBL_TREATGROUP] T2 ON T1.GroupNo  = T2.GroupNo  AND T2.TGStatus = 2
                                INNER JOIN [ORDER] T3 ON T2.OrderID = T3.ID AND T3.ProductType = 0 and T3.RecordType = 1
                                INNER JOIN [TBL_ORDER_SERVICE] T4 ON T3.ID = T4.OrderID and T4.TGTotalCount > 0
								INNER JOIN [TBL_STATEMENT] T11 ON T4.ServiceCode = T11.ProductCode AND T11.ProductType = 0
								INNER JOIN [TBL_STATEMENT_CATEGORY] T12 ON T11.CategoryID = T12.ID 
                                LEFT JOIN [BRANCH] T5 ON T2.BranchID = T5.ID 
                                LEFT JOIN [ACCOUNT] T6 ON T1.ExecutorID = T6.UserID
								left join [TBL_SUBSERVICE] T13 ON T1.SubServiceID = T13.ID AND T13.Available = 1
                                WHERE  T1.FinishTime > @BeginDay AND T1.FinishTime < @EndDay AND T1.CompanyID =@CompanyID AND T2.TGEndTime > T5.StartTime AND T1.Status = 2    ";

                if (branchId > 0)
                {
                    strSql += "and T2.BranchID =" + branchId.ToString();
                }

                strSql += @" ORDER BY T5.BranchName,T6.Name,T12.CategoryName,ISNULL(T13.SubServiceName,'服务') ";

                DataTable dt = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                         , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                         , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();

                if (dt != null && dt.Rows.Count > 0)
                {
                    string strSqlProfitAmount = @"   select T3.ID OrderID, CASE T6.IsUseRate 
                                WHEN 1 THEN  SUM(CASE T6.Type WHEN 1 THEN T7.PaymentAmount * T7.ProfitRate ELSE T7.PaymentAmount * T7.ProfitRate * -1 END) ELSE T3.TotalSalePrice END ProfitAmount
                                from [ORDER] T3 
								LEFT JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T5  ON T3.ID = T5.OrderID
								LEFT JOIN [PAYMENT] T6  ON T5.PaymentID = T6.ID
								LEFT JOIN  [PAYMENT_DETAIL] T7 ON T6.ID = T7.PaymentID
								LEFT JOIN [BRANCH] T4 ON T3.BranchID = T4.ID 
                                WHERE  T3.ProductType = 0 and T3.RecordType = 1 and  T3.CompanyID =@CompanyID AND T3.OrderTime > T4.StartTime  	 group by T3.ID,T6.IsUseRate,T3.TotalSalePrice";

                    DataTable dtProfitAmount = db.SetCommand(strSqlProfitAmount, db.Parameter("@CompanyID", companyId, DbType.Int32)
                             , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                             , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();

                    for (int i = 0; i < dt.Rows.Count; i++)
                    {
                        DataRow[] drProfitAmount = dtProfitAmount.Select("OrderID=" + StringUtils.GetDbInt(dt.Rows[i]["OrderID"]));

                        if (drProfitAmount != null && drProfitAmount.Length > 0)
                        {
                            dt.Rows[i]["ProfitAmount"] = StringUtils.GetDbDecimal(drProfitAmount[0]["ProfitAmount"]) / StringUtils.GetDbDecimal(dt.Rows[i]["TGTotalCount"]);
                        }
                    }
                }

                dt.Columns.Remove("OrderID");
                dt.Columns.Remove("TGTotalCount");





                DataTable dtResult = dt.Clone();
                for (int i = 0; i < dt.Rows.Count; )
                {
                    DataRow dr = dtResult.NewRow();
                    string BranchName = dt.Rows[i]["BranchName"].ToString();
                    string ExecutorName = dt.Rows[i]["ExecutorName"].ToString();
                    string CategoryName = dt.Rows[i]["CategoryName"].ToString();
                    string SubServiceName = dt.Rows[i]["SubServiceName"].ToString();
                    dr["BranchName"] = BranchName;
                    dr["ExecutorName"] = ExecutorName;
                    dr["CategoryName"] = CategoryName;
                    dr["SubServiceName"] = SubServiceName;
                    int DoCount = 0;
                    int Designated = 0;
                    int NotDesignated = 0;
                    decimal ProfitAmount = 0;

                    for (; i < dt.Rows.Count; )
                    {
                        if (BranchName == dt.Rows[i]["BranchName"].ToString() && ExecutorName == dt.Rows[i]["ExecutorName"].ToString() && CategoryName == dt.Rows[i]["CategoryName"].ToString() && SubServiceName == dt.Rows[i]["SubServiceName"].ToString())
                        {
                            ProfitAmount += StringUtils.GetDbDecimal(dt.Rows[i]["ProfitAmount"]);
                            DoCount += 1;
                            if (StringUtils.GetDbInt(dt.Rows[i]["Designated"]) == 1)
                            {
                                Designated += 1;
                            }
                            if (StringUtils.GetDbInt(dt.Rows[i]["NotDesignated"]) == 1)
                            {
                                NotDesignated += 1;
                            }
                            i++;
                        }
                        else
                        {
                            break;
                        }
                    }

                    dr["ProfitAmount"] = ProfitAmount;
                    dr["DoCount"] = DoCount;
                    dr["Designated"] = Designated;
                    dr["NotDesignated"] = NotDesignated;

                    dtResult.Rows.Add(dr);

                }
                return dtResult;
            }
        }

        public DataTable getStatementCommodityDetail(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSqlOrderBasic = @" SELECT   T4.BranchName,T6.Name AccountName,T13.CategoryName,T11.Quantity,T3.IsUseRate,T1.PaymentID,T11.OrderID,T2.TotalSalePrice,T2.ID
                                            FROM [TBL_ORDERPAYMENT_RELATIONSHIP] T1 WITH (NOLOCK)   
                                            INNER JOIN   [ORDER] T2  
                                            ON T2.ID = T1.OrderID AND T2.PaymentStatus > 0  and  T2.ProductType =1
                                            INNER JOIN   [TBL_ORDER_COMMODITY] T11  
                                            ON T2.ID = T11.OrderID 
                                            INNER JOIN [TBL_STATEMENT] T12 ON T11.CommodityCode = T12.ProductCode and T12.ProductType = 1
											INNER JOIN [TBL_STATEMENT_CATEGORY] T13 ON T12.CategoryID = T13.ID
                                            INNER JOIN [PAYMENT] T3 
                                            ON T1.PaymentID = T3.ID 
                                            INNER JOIN [TBL_PROFIT] P1
                                            ON T1.PaymentID = P1.MasterID AND P1.Available = 1 AND P1.Type =2 
                                            LEFT JOIN [BRANCH] T4 
                                            ON T3.BranchID = T4.ID 
                                           LEFT JOIN [ACCOUNT] T6 WITH (NOLOCK)
                                           ON P1.SlaveID = T6.UserID
                                            where T11.CompanyID =@CompanyID AND T3.PaymentTime >=@BeginDay AND T3.PaymentTime <= @EndDay AND T3.PaymentTime >= T4.StartTime AND ((T3.Type = 1 AND (T3.Status = 2 OR T3.Status = 3)) OR (T3.Type = 2 AND (T3.Status = 6 OR T3.Status = 7)))";

                if (branchId > 0)
                {
                    strSqlOrderBasic += "and T3.BranchID =" + branchId.ToString();
                }
                strSqlOrderBasic += @"  GROUP BY  T4.BranchName,T6.Name,T13.CategoryName,T11.Quantity,T3.IsUseRate,T1.PaymentID ,T11.OrderID,T2.TotalSalePrice,T2.ID order by T4.BranchName,T6.Name,T13.CategoryName  ,T11.OrderID ";


                DataTable dtOrderBasic = db.SetCommand(strSqlOrderBasic, db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();
                if (dtOrderBasic == null || dtOrderBasic.Rows.Count == 0)
                {
                    return null;
                }

                string strPaymentDetail = @"    Select distinct T1.PaymentID,T1.PaymentMode,CASE T2.IsUseRate WHEN 1 THEN SUM(CASE T2.Type WHEN 1 THEN T1.PaymentAmount * T1.ProfitRate ELSE T1.PaymentAmount * T1.ProfitRate * - 1  END) ELSE SUM(CASE T2.Type WHEN 1 THEN T1.PaymentAmount  ELSE T1.PaymentAmount  * - 1  END) END PaymentAmount,T2.OrderNumber ,T2.Type,CASE T2.OrderNumber WHEN 1 THEN 1 ELSE T1.ProfitRate END ProfitRate
                                        from [PAYMENT_DETAIL] T1 
                                        INNER JOIN [PAYMENT] T2 
                                        ON T1.PaymentID = T2.ID  
                                        INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T3 
                                        ON T1.PaymentID = T3.PaymentID 
                                        INNER JOIN [ORDER] T4 
                                        ON T3.OrderID = T4.ID  AND T4.ProductType = 1 AND T4.PaymentStatus > 0 
                                        LEFT JOIN [BRANCH] T5 
                                        ON T2.BranchID = T5.ID 
                                        WHERE T2.PaymentTime >= T5.StartTime AND T2.PaymentTime >= @BeginDay AND T2.PaymentTime <=@EndDay AND T4.CompanyID =@CompanyID AND ((T2.Type = 1 AND (T2.Status = 2 OR T2.Status = 3)) OR (T2.Type = 2 AND (T2.Status = 6 OR T2.Status = 7))) ";

                if (branchId > 0)
                {
                    strPaymentDetail += "and T2.BranchID =" + branchId.ToString();
                }

                strPaymentDetail += " group by T1.PaymentID,T1.PaymentMode,T2.OrderNumber,T2.Type,T2.IsUseRate, T4.TotalSalePrice ,CASE T2.OrderNumber WHEN 1 THEN 1 ELSE T1.ProfitRate END ";

                DataTable dtPaymentDetail = db.SetCommand(strPaymentDetail, db.Parameter("@CompanyID", companyId, DbType.Int32)
                                         , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                                         , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();




                DataTable dt = new DataTable();
                dt.Columns.Add("BranchName");
                dt.Columns.Add("AccountName");
                dt.Columns.Add("CategoryName");
                dt.Columns.Add("ProfitAmount");
                dt.Columns["ProfitAmount"].DataType = typeof(decimal);
                dt.Columns.Add("PayCash");
                dt.Columns["PayCash"].DataType = typeof(decimal);
                dt.Columns.Add("PayBankCard");
                dt.Columns["PayBankCard"].DataType = typeof(decimal);
                dt.Columns.Add("PayWeChatBalance");
                dt.Columns["PayWeChatBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayAlipayBalance");
                dt.Columns["PayAlipayBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayMoneyBalance");
                dt.Columns["PayMoneyBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayPointBalance");
                dt.Columns["PayPointBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayCouponBalance");
                dt.Columns["PayCouponBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayLoan");
                dt.Columns["PayLoan"].DataType = typeof(decimal);
                dt.Columns.Add("PayThird");
                dt.Columns["PayThird"].DataType = typeof(decimal);
                dt.Columns.Add("PayOther");
                dt.Columns["PayOther"].DataType = typeof(decimal);
                dt.Columns.Add("OrderID");
                dt.Columns["OrderID"].DataType = typeof(Int32);
                dt.Columns.Add("TotalSalePrice");
                dt.Columns["TotalSalePrice"].DataType = typeof(decimal);

                for (int i = 0; i < dtOrderBasic.Rows.Count; i++)
                {
                    DataRow dr = dt.NewRow();
                    dr["BranchName"] = dtOrderBasic.Rows[i]["BranchName"];
                    dr["AccountName"] = dtOrderBasic.Rows[i]["AccountName"];
                    dr["CategoryName"] = dtOrderBasic.Rows[i]["CategoryName"];
                    dr["OrderID"] = dtOrderBasic.Rows[i]["OrderID"];

                    DataRow[] drPayment = dtPaymentDetail.Select("PaymentID=" + StringUtils.GetDbInt(dtOrderBasic.Rows[i]["PaymentID"]));
                    decimal profitAmount = 0;
                    if (drPayment != null && drPayment.Length > 0)
                    {

                        foreach (DataRow item in drPayment)
                        {
                            int mode = StringUtils.GetDbInt(item.ItemArray[1]);
                            int orderNumber = StringUtils.GetDbInt(item.ItemArray[3]);
                            int type = StringUtils.GetDbInt(item.ItemArray[4]);
                            switch (mode)
                            {
                                case 0:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayCash"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayCash"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayCash"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayCash"] = StringUtils.GetDbDecimal(dr["PayCash"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayCash"]);
                                    }
                                    else
                                    {
                                        dr["PayCash"] = 0;
                                    }
                                    break;
                                case 1:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayMoneyBalance"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayMoneyBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayMoneyBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayMoneyBalance"] = StringUtils.GetDbDecimal(dr["PayMoneyBalance"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayMoneyBalance"]);
                                    }
                                    else
                                    {
                                        dr["PayMoneyBalance"] = 0;
                                    }
                                    break;
                                case 2:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayBankCard"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayBankCard"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayBankCard"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayBankCard"] = StringUtils.GetDbDecimal(dr["PayBankCard"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayBankCard"]);
                                    }
                                    else
                                    {
                                        dr["PayBankCard"] = 0;
                                    }
                                    break;
                                case 3:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayOther"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayOther"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayOther"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayOther"] = StringUtils.GetDbDecimal(dr["PayOther"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayOther"]);
                                    }
                                    else
                                    {
                                        dr["PayOther"] = 0;
                                    }
                                    break;
                                case 6:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayPointBalance"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayPointBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayPointBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayPointBalance"] = StringUtils.GetDbDecimal(dr["PayPointBalance"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayPointBalance"]);
                                    }
                                    else
                                    {
                                        dr["PayPointBalance"] = 0;
                                    }
                                    break;
                                case 7:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayCouponBalance"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayCouponBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayCouponBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayCouponBalance"] = StringUtils.GetDbDecimal(dr["PayCouponBalance"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayCouponBalance"]);
                                    }
                                    else
                                    {
                                        dr["PayCouponBalance"] = 0;
                                    }
                                    break;
                                case 8:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayWeChatBalance"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayWeChatBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayWeChatBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayWeChatBalance"] = StringUtils.GetDbDecimal(dr["PayWeChatBalance"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayWeChatBalance"]);
                                    }
                                    else
                                    {
                                        dr["PayWeChatBalance"] = 0;
                                    }
                                    break;
                                case 9:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayAlipayBalance"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayAlipayBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayAlipayBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayAlipayBalance"] = StringUtils.GetDbDecimal(dr["PayAlipayBalance"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayAlipayBalance"]);
                                    }
                                    else
                                    {
                                        dr["PayAlipayBalance"] = 0;
                                    }
                                    break;
                                case 100:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayLoan"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayLoan"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayLoan"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayLoan"] = StringUtils.GetDbDecimal(dr["PayLoan"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayLoan"]);
                                    }
                                    else
                                    {
                                        dr["PayLoan"] = 0;
                                    }
                                    break;
                                case 101:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayThird"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayThird"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayThird"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayThird"] = StringUtils.GetDbDecimal(dr["PayThird"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayThird"]);
                                    }
                                    else
                                    {
                                        dr["PayThird"] = 0;
                                    }
                                    break;

                            }
                        }

                    }
                    dr["ProfitAmount"] = StringUtils.GetDbDecimal(dr["PayCash"]) + StringUtils.GetDbDecimal(dr["PayBankCard"]) + StringUtils.GetDbDecimal(dr["PayWeChatBalance"]) + StringUtils.GetDbDecimal(dr["PayMoneyBalance"]) + StringUtils.GetDbDecimal(dr["PayPointBalance"]) + StringUtils.GetDbDecimal(dr["PayCouponBalance"]) + StringUtils.GetDbDecimal(dr["PayOther"]) + StringUtils.GetDbDecimal(dr["PayAlipayBalance"]) + StringUtils.GetDbDecimal(dr["PayLoan"]) + StringUtils.GetDbDecimal(dr["PayThird"]);

                    dt.Rows.Add(dr);
                }


                DataTable dtResult = dt.Clone();
                for (int i = 0; i < dt.Rows.Count; )
                {
                    DataRow dr = dtResult.NewRow();
                    string BranchName = dt.Rows[i]["BranchName"].ToString();
                    string AccountName = dt.Rows[i]["AccountName"].ToString();
                    string CategoryName = dt.Rows[i]["CategoryName"].ToString();
                    dr["BranchName"] = BranchName;
                    dr["AccountName"] = AccountName;
                    dr["CategoryName"] = CategoryName;
                    int OrderID = StringUtils.GetDbInt(dt.Rows[i]["OrderID"]);
                    decimal ProfitAmount = 0;
                    decimal PayCash = 0;
                    decimal PayBankCard = 0;
                    decimal PayWeChatBalance = 0;
                    decimal PayMoneyBalance = 0;
                    decimal PayPointBalance = 0;
                    decimal PayCouponBalance = 0;
                    decimal PayAlipayBalance = 0;
                    decimal PayOther = 0;
                    decimal PayLoan = 0;
                    decimal PayThird = 0;

                    for (; i < dt.Rows.Count; )
                    {
                        if (BranchName == dt.Rows[i]["BranchName"].ToString() && AccountName == dt.Rows[i]["AccountName"].ToString() && CategoryName == dt.Rows[i]["CategoryName"].ToString())
                        {
                            ProfitAmount += StringUtils.GetDbDecimal(dt.Rows[i]["ProfitAmount"]);
                            PayCash += StringUtils.GetDbDecimal(dt.Rows[i]["PayCash"]);
                            PayBankCard += StringUtils.GetDbDecimal(dt.Rows[i]["PayBankCard"]);
                            PayWeChatBalance += StringUtils.GetDbDecimal(dt.Rows[i]["PayWeChatBalance"]);
                            PayMoneyBalance += StringUtils.GetDbDecimal(dt.Rows[i]["PayMoneyBalance"]);
                            PayPointBalance += StringUtils.GetDbDecimal(dt.Rows[i]["PayPointBalance"]);
                            PayCouponBalance += StringUtils.GetDbDecimal(dt.Rows[i]["PayCouponBalance"]);
                            PayAlipayBalance += StringUtils.GetDbDecimal(dt.Rows[i]["PayAlipayBalance"]);
                            PayOther += StringUtils.GetDbDecimal(dt.Rows[i]["PayOther"]);
                            PayLoan += StringUtils.GetDbDecimal(dt.Rows[i]["PayLoan"]);
                            PayThird += StringUtils.GetDbDecimal(dt.Rows[i]["PayThird"]);
                            if (StringUtils.GetDbInt(dt.Rows[i]["OrderID"]) != OrderID)
                            {
                                OrderID = StringUtils.GetDbInt(dt.Rows[i]["OrderID"]);
                            }
                            i++;
                        }
                        else
                        {
                            break;
                        }
                    }

                    dr["ProfitAmount"] = ProfitAmount;
                    dr["PayCash"] = PayCash;
                    dr["PayBankCard"] = PayBankCard;
                    dr["PayWeChatBalance"] = PayWeChatBalance;
                    dr["PayMoneyBalance"] = PayMoneyBalance;
                    dr["PayPointBalance"] = PayPointBalance;
                    dr["PayCouponBalance"] = PayCouponBalance;
                    dr["PayAlipayBalance"] = PayAlipayBalance;
                    dr["PayOther"] = PayOther;
                    dr["PayLoan"] = PayLoan;
                    dr["PayThird"] = PayThird;
                    dtResult.Rows.Add(dr);

                }
                dtResult.Columns.Remove("OrderID");
                dtResult.Columns.Remove("TotalSalePrice");
                return dtResult;
            }
        }


        public DataTable getBranchStatementServicePayDetail(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSqlOrderBasic = @" SELECT   T4.BranchName,T13.CategoryName,T3.IsUseRate,T1.PaymentID,T2.TotalSalePrice,T2.ID
                                            FROM [TBL_ORDERPAYMENT_RELATIONSHIP] T1 WITH (NOLOCK)   
                                            INNER JOIN   [ORDER] T2  
                                            ON T2.ID = T1.OrderID AND T2.PaymentStatus > 0  and  T2.ProductType =0  
                                            INNER JOIN   [TBL_ORDER_SERVICE] T11  
                                            ON T2.ID = T11.OrderID 
                                            INNER JOIN [TBL_STATEMENT] T12 ON T11.ServiceCode = T12.ProductCode and T12.ProductType = 0 
											INNER JOIN [TBL_STATEMENT_CATEGORY] T13 ON T12.CategoryID = T13.ID
                                            INNER JOIN [PAYMENT] T3 
                                            ON T1.PaymentID = T3.ID 
                                            LEFT JOIN [BRANCH] T4 
                                            ON T3.BranchID = T4.ID 
                                            where T11.CompanyID =@CompanyID AND T3.PaymentTime >=@BeginDay AND T3.PaymentTime <= @EndDay AND T3.PaymentTime >= T4.StartTime AND ((T3.Type = 1 AND (T3.Status = 2 OR T3.Status = 3)) OR (T3.Type = 2 AND (T3.Status = 6 OR T3.Status = 7)))";

                if (branchId > 0)
                {
                    strSqlOrderBasic += "and T3.BranchID =" + branchId.ToString();
                }
                strSqlOrderBasic += @" GROUP BY  T4.BranchName,T13.CategoryName,T3.IsUseRate,T1.PaymentID ,T2.TotalSalePrice,T2.ID order by T4.BranchName,T13.CategoryName ";


                DataTable dtOrderBasic = db.SetCommand(strSqlOrderBasic, db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();
                if (dtOrderBasic == null || dtOrderBasic.Rows.Count == 0)
                {
                    return null;
                }

                string strPaymentDetail = @"    Select distinct T1.PaymentID,T1.PaymentMode,CASE T2.IsUseRate WHEN 1 THEN SUM(CASE T2.Type WHEN 1 THEN T1.PaymentAmount * T1.ProfitRate ELSE T1.PaymentAmount * T1.ProfitRate * - 1  END) ELSE SUM(CASE T2.Type WHEN 1 THEN T1.PaymentAmount  ELSE T1.PaymentAmount  * - 1  END) END PaymentAmount,T2.OrderNumber ,T2.Type,CASE T2.OrderNumber WHEN 1 THEN 1 ELSE T1.ProfitRate END ProfitRate
                                        from [PAYMENT_DETAIL] T1 
                                        INNER JOIN [PAYMENT] T2 
                                        ON T1.PaymentID = T2.ID  
                                        INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T3 
                                        ON T1.PaymentID = T3.PaymentID 
                                        INNER JOIN [ORDER] T4 
                                        ON T3.OrderID = T4.ID  AND T4.ProductType = 0 AND T4.PaymentStatus > 0 
                                        LEFT JOIN [BRANCH] T5 
                                        ON T2.BranchID = T5.ID 
                                        WHERE T2.PaymentTime >= T5.StartTime AND T2.PaymentTime >= @BeginDay AND T2.PaymentTime <=@EndDay AND T4.CompanyID =@CompanyID AND ((T2.Type = 1 AND (T2.Status = 2 OR T2.Status = 3)) OR (T2.Type = 2 AND (T2.Status = 6 OR T2.Status = 7))) ";

                if (branchId > 0)
                {
                    strPaymentDetail += "and T2.BranchID =" + branchId.ToString();
                }

                strPaymentDetail += " group by T1.PaymentID,T1.PaymentMode,T2.OrderNumber,T2.Type,T2.IsUseRate, T4.TotalSalePrice ,CASE T2.OrderNumber WHEN 1 THEN 1 ELSE T1.ProfitRate END ";

                DataTable dtPaymentDetail = db.SetCommand(strPaymentDetail, db.Parameter("@CompanyID", companyId, DbType.Int32)
                                         , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                                         , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();




                DataTable dt = new DataTable();
                dt.Columns.Add("BranchName");
                dt.Columns.Add("CategoryName");
                dt.Columns.Add("ProfitAmount");
                dt.Columns["ProfitAmount"].DataType = typeof(decimal);
                dt.Columns.Add("PayCash");
                dt.Columns["PayCash"].DataType = typeof(decimal);
                dt.Columns.Add("PayBankCard");
                dt.Columns["PayBankCard"].DataType = typeof(decimal);
                dt.Columns.Add("PayWeChatBalance");
                dt.Columns["PayWeChatBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayAipay");
                dt.Columns["PayAipay"].DataType = typeof(decimal);
                dt.Columns.Add("PayMoneyBalance");
                dt.Columns["PayMoneyBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayPointBalance");
                dt.Columns["PayPointBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayCouponBalance");
                dt.Columns["PayCouponBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayLoan");
                dt.Columns["PayLoan"].DataType = typeof(decimal);
                dt.Columns.Add("PayThird");
                dt.Columns["PayThird"].DataType = typeof(decimal);
                dt.Columns.Add("PayOther");
                dt.Columns["PayOther"].DataType = typeof(decimal);
                dt.Columns.Add("PayAll");
                dt.Columns["PayAll"].DataType = typeof(decimal);
                dt.Columns.Add("IncomeAll");
                dt.Columns["IncomeAll"].DataType = typeof(decimal);
                dt.Columns.Add("TotalSalePrice");
                dt.Columns["TotalSalePrice"].DataType = typeof(decimal);

                for (int i = 0; i < dtOrderBasic.Rows.Count; i++)
                {
                    DataRow dr = dt.NewRow();
                    dr["BranchName"] = dtOrderBasic.Rows[i]["BranchName"];
                    dr["CategoryName"] = dtOrderBasic.Rows[i]["CategoryName"];

                    DataRow[] drPayment = dtPaymentDetail.Select("PaymentID=" + StringUtils.GetDbInt(dtOrderBasic.Rows[i]["PaymentID"]));
                    decimal profitAmount = 0;
                    if (drPayment != null && drPayment.Length > 0)
                    {

                        foreach (DataRow item in drPayment)
                        {
                            int mode = StringUtils.GetDbInt(item.ItemArray[1]);
                            int orderNumber = StringUtils.GetDbInt(item.ItemArray[3]);
                            int type = StringUtils.GetDbInt(item.ItemArray[4]);
                            switch (mode)
                            {
                                case 0:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayCash"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayCash"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayCash"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayCash"] = StringUtils.GetDbDecimal(dr["PayCash"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayCash"]);
                                    }
                                    else
                                    {
                                        dr["PayCash"] = 0;
                                    }
                                    break;
                                case 1:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayMoneyBalance"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayMoneyBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayMoneyBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayMoneyBalance"] = StringUtils.GetDbDecimal(dr["PayMoneyBalance"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayMoneyBalance"]);
                                    }
                                    else
                                    {
                                        dr["PayMoneyBalance"] = 0;
                                    }
                                    break;
                                case 2:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayBankCard"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayBankCard"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayBankCard"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayBankCard"] = StringUtils.GetDbDecimal(dr["PayBankCard"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayBankCard"]);
                                    }
                                    else
                                    {
                                        dr["PayBankCard"] = 0;
                                    }
                                    break;
                                case 3:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayOther"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayOther"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayOther"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayOther"] = StringUtils.GetDbDecimal(dr["PayOther"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayOther"]);
                                    }
                                    else
                                    {
                                        dr["PayOther"] = 0;
                                    }
                                    break;
                                case 6:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayPointBalance"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayPointBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayPointBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayPointBalance"] = StringUtils.GetDbDecimal(dr["PayPointBalance"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayPointBalance"]);
                                    }
                                    else
                                    {
                                        dr["PayPointBalance"] = 0;
                                    }
                                    break;
                                case 7:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayCouponBalance"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayCouponBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayCouponBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayCouponBalance"] = StringUtils.GetDbDecimal(dr["PayCouponBalance"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayCouponBalance"]);
                                    }
                                    else
                                    {
                                        dr["PayCouponBalance"] = 0;
                                    }
                                    break;
                                case 8:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayWeChatBalance"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayWeChatBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayWeChatBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayWeChatBalance"] = StringUtils.GetDbDecimal(dr["PayWeChatBalance"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayWeChatBalance"]);
                                    }
                                    else
                                    {
                                        dr["PayWeChatBalance"] = 0;
                                    }
                                    break;
                                case 9:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayAipay"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayAipay"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayAipay"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayAipay"] = StringUtils.GetDbDecimal(dr["PayAipay"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayAipay"]);
                                    }
                                    else
                                    {
                                        dr["PayAipay"] = 0;
                                    }
                                    break;
                                case 100:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayLoan"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayLoan"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayLoan"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayLoan"] = StringUtils.GetDbDecimal(dr["PayLoan"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayLoan"]);
                                    }
                                    else
                                    {
                                        dr["PayLoan"] = 0;
                                    }
                                    break;
                                case 101:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayThird"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayThird"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayThird"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayThird"] = StringUtils.GetDbDecimal(dr["PayThird"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayThird"]);
                                    }
                                    else
                                    {
                                        dr["PayThird"] = 0;
                                    }
                                    break;

                            }
                        }

                    }
                    dr["ProfitAmount"] = StringUtils.GetDbDecimal(dr["PayCash"]) + StringUtils.GetDbDecimal(dr["PayBankCard"]) + StringUtils.GetDbDecimal(dr["PayWeChatBalance"]) + StringUtils.GetDbDecimal(dr["PayMoneyBalance"]) + StringUtils.GetDbDecimal(dr["PayPointBalance"]) + StringUtils.GetDbDecimal(dr["PayCouponBalance"]) + StringUtils.GetDbDecimal(dr["PayOther"]) + StringUtils.GetDbDecimal(dr["PayAipay"]) + StringUtils.GetDbDecimal(dr["PayLoan"]) + StringUtils.GetDbDecimal(dr["PayThird"]);

                    dt.Rows.Add(dr);
                }


                DataTable dtResult = dt.Clone();
                for (int i = 0; i < dt.Rows.Count; )
                {
                    DataRow dr = dtResult.NewRow();
                    string BranchName = dt.Rows[i]["BranchName"].ToString();
                    string CategoryName = dt.Rows[i]["CategoryName"].ToString();
                    dr["BranchName"] = BranchName;
                    dr["CategoryName"] = CategoryName;
                    decimal ProfitAmount = 0;
                    decimal PayCash = 0;
                    decimal PayBankCard = 0;
                    decimal PayWeChatBalance = 0;
                    decimal PayAipay = 0;
                    decimal PayMoneyBalance = 0;
                    decimal PayPointBalance = 0;
                    decimal PayCouponBalance = 0;
                    decimal PayOther = 0;
                    decimal PayLoan = 0;
                    decimal PayThird = 0;

                    for (; i < dt.Rows.Count; )
                    {
                        if (BranchName == dt.Rows[i]["BranchName"].ToString() && CategoryName == dt.Rows[i]["CategoryName"].ToString())
                        {
                            ProfitAmount += StringUtils.GetDbDecimal(dt.Rows[i]["ProfitAmount"]);
                            PayCash += StringUtils.GetDbDecimal(dt.Rows[i]["PayCash"]);
                            PayBankCard += StringUtils.GetDbDecimal(dt.Rows[i]["PayBankCard"]);
                            PayWeChatBalance += StringUtils.GetDbDecimal(dt.Rows[i]["PayWeChatBalance"]);
                            PayAipay += StringUtils.GetDbDecimal(dt.Rows[i]["PayAipay"]);
                            PayMoneyBalance += StringUtils.GetDbDecimal(dt.Rows[i]["PayMoneyBalance"]);
                            PayPointBalance += StringUtils.GetDbDecimal(dt.Rows[i]["PayPointBalance"]);
                            PayCouponBalance += StringUtils.GetDbDecimal(dt.Rows[i]["PayCouponBalance"]);
                            PayOther += StringUtils.GetDbDecimal(dt.Rows[i]["PayOther"]);
                            PayLoan += StringUtils.GetDbDecimal(dt.Rows[i]["PayLoan"]);
                            PayThird += StringUtils.GetDbDecimal(dt.Rows[i]["PayThird"]);
                            i++;
                        }
                        else
                        {
                            break;
                        }
                    }

                    dr["ProfitAmount"] = ProfitAmount;
                    dr["PayCash"] = PayCash;
                    dr["PayBankCard"] = PayBankCard;
                    dr["PayWeChatBalance"] = PayWeChatBalance;
                    dr["PayAipay"] = PayAipay;
                    dr["PayMoneyBalance"] = PayMoneyBalance;
                    dr["PayPointBalance"] = PayPointBalance;
                    dr["PayCouponBalance"] = PayCouponBalance;
                    dr["PayOther"] = PayOther;
                    dr["PayLoan"] = PayLoan;
                    dr["PayThird"] = PayThird;

                    dr["PayAll"] = PayCash + PayBankCard + PayWeChatBalance + PayMoneyBalance + PayPointBalance + PayCouponBalance + PayOther + PayAipay + PayLoan + PayThird;
                    dr["IncomeAll"] = PayCash + PayBankCard + PayWeChatBalance + PayAipay + PayLoan + PayThird;
                    dtResult.Rows.Add(dr);

                }
                dtResult.Columns.Remove("TotalSalePrice");
                return dtResult;
            }
        }


        public DataTable getBranchStatementCommodityDetail(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSqlOrderBasic = @" SELECT   T4.BranchName,T13.CategoryName,T11.Quantity,T3.IsUseRate,T1.PaymentID,T11.OrderID,T2.TotalSalePrice,T2.ID
                                            FROM [TBL_ORDERPAYMENT_RELATIONSHIP] T1 WITH (NOLOCK)   
                                            INNER JOIN   [ORDER] T2  
                                            ON T2.ID = T1.OrderID AND T2.PaymentStatus > 0  and  T2.ProductType =1  
                                            INNER JOIN   [TBL_ORDER_COMMODITY] T11  
                                            ON T2.ID = T11.OrderID 
                                            INNER JOIN [TBL_STATEMENT] T12 ON T11.CommodityCode = T12.ProductCode and T12.ProductType = 1
											INNER JOIN [TBL_STATEMENT_CATEGORY] T13 ON T12.CategoryID = T13.ID
                                            INNER JOIN [PAYMENT] T3 
                                            ON T1.PaymentID = T3.ID 
                                            LEFT JOIN [BRANCH] T4 
                                            ON T3.BranchID = T4.ID 
                                            where T11.CompanyID =@CompanyID AND T3.PaymentTime >=@BeginDay AND T3.PaymentTime <= @EndDay AND T3.PaymentTime >= T4.StartTime AND ((T3.Type = 1 AND (T3.Status = 2 OR T3.Status = 3)) OR (T3.Type = 2 AND (T3.Status = 6 OR T3.Status = 7)))";

                if (branchId > 0)
                {
                    strSqlOrderBasic += "and T3.BranchID =" + branchId.ToString();
                }
                strSqlOrderBasic += @"  GROUP BY  T4.BranchName,T13.CategoryName,T11.Quantity,T3.IsUseRate,T1.PaymentID ,T11.OrderID,T2.TotalSalePrice,T2.ID order by T4.BranchName,T13.CategoryName  ,T11.OrderID ";


                DataTable dtOrderBasic = db.SetCommand(strSqlOrderBasic, db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();
                if (dtOrderBasic == null || dtOrderBasic.Rows.Count == 0)
                {
                    return null;
                }

                string strPaymentDetail = @"    Select distinct T1.PaymentID,T1.PaymentMode,CASE T2.IsUseRate WHEN 1 THEN SUM(CASE T2.Type WHEN 1 THEN T1.PaymentAmount * T1.ProfitRate ELSE T1.PaymentAmount * T1.ProfitRate * - 1  END) ELSE SUM(CASE T2.Type WHEN 1 THEN T1.PaymentAmount  ELSE T1.PaymentAmount  * - 1  END) END PaymentAmount,T2.OrderNumber ,T2.Type,CASE T2.OrderNumber WHEN 1 THEN 1 ELSE T1.ProfitRate END ProfitRate
                                        from [PAYMENT_DETAIL] T1 
                                        INNER JOIN [PAYMENT] T2 
                                        ON T1.PaymentID = T2.ID  
                                        INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T3 
                                        ON T1.PaymentID = T3.PaymentID 
                                        INNER JOIN [ORDER] T4 
                                        ON T3.OrderID = T4.ID  AND T4.ProductType = 1 AND T4.PaymentStatus > 0 
                                        LEFT JOIN [BRANCH] T5 
                                        ON T2.BranchID = T5.ID 
                                        WHERE T2.PaymentTime >= T5.StartTime AND T2.PaymentTime >= @BeginDay AND T2.PaymentTime <=@EndDay AND T4.CompanyID =@CompanyID AND ((T2.Type = 1 AND (T2.Status = 2 OR T2.Status = 3)) OR (T2.Type = 2 AND (T2.Status = 6 OR T2.Status = 7))) ";

                if (branchId > 0)
                {
                    strPaymentDetail += "and T2.BranchID =" + branchId.ToString();
                }

                strPaymentDetail += " group by T1.PaymentID,T1.PaymentMode,T2.OrderNumber,T2.Type,T2.IsUseRate, T4.TotalSalePrice ,CASE T2.OrderNumber WHEN 1 THEN 1 ELSE T1.ProfitRate END ";

                DataTable dtPaymentDetail = db.SetCommand(strPaymentDetail, db.Parameter("@CompanyID", companyId, DbType.Int32)
                                         , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                                         , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();




                DataTable dt = new DataTable();
                dt.Columns.Add("BranchName");
                dt.Columns.Add("CategoryName");
                dt.Columns.Add("ProfitAmount");
                dt.Columns["ProfitAmount"].DataType = typeof(decimal);
                dt.Columns.Add("PayCash");
                dt.Columns["PayCash"].DataType = typeof(decimal);
                dt.Columns.Add("PayBankCard");
                dt.Columns["PayBankCard"].DataType = typeof(decimal);
                dt.Columns.Add("PayWeChatBalance");
                dt.Columns["PayWeChatBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayAipay");
                dt.Columns["PayAipay"].DataType = typeof(decimal);
                dt.Columns.Add("PayMoneyBalance");
                dt.Columns["PayMoneyBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayPointBalance");
                dt.Columns["PayPointBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayCouponBalance");
                dt.Columns["PayCouponBalance"].DataType = typeof(decimal);
                dt.Columns.Add("PayLoan");
                dt.Columns["PayLoan"].DataType = typeof(decimal);
                dt.Columns.Add("PayThird");
                dt.Columns["PayThird"].DataType = typeof(decimal);
                dt.Columns.Add("PayOther");
                dt.Columns["PayOther"].DataType = typeof(decimal);
                dt.Columns.Add("OrderID");
                dt.Columns["OrderID"].DataType = typeof(Int32);
                dt.Columns.Add("PayAll");
                dt.Columns["PayAll"].DataType = typeof(decimal);
                dt.Columns.Add("IncomeAll");
                dt.Columns["IncomeAll"].DataType = typeof(decimal);
                dt.Columns.Add("TotalSalePrice");
                dt.Columns["TotalSalePrice"].DataType = typeof(decimal);

                for (int i = 0; i < dtOrderBasic.Rows.Count; i++)
                {
                    DataRow dr = dt.NewRow();
                    dr["BranchName"] = dtOrderBasic.Rows[i]["BranchName"];
                    dr["CategoryName"] = dtOrderBasic.Rows[i]["CategoryName"];
                    dr["OrderID"] = dtOrderBasic.Rows[i]["OrderID"];

                    DataRow[] drPayment = dtPaymentDetail.Select("PaymentID=" + StringUtils.GetDbInt(dtOrderBasic.Rows[i]["PaymentID"]));
                    decimal profitAmount = 0;
                    if (drPayment != null && drPayment.Length > 0)
                    {

                        foreach (DataRow item in drPayment)
                        {
                            int mode = StringUtils.GetDbInt(item.ItemArray[1]);
                            int orderNumber = StringUtils.GetDbInt(item.ItemArray[3]);
                            int type = StringUtils.GetDbInt(item.ItemArray[4]);
                            switch (mode)
                            {
                                case 0:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayCash"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayCash"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayCash"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayCash"] = StringUtils.GetDbDecimal(dr["PayCash"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayCash"]);
                                    }
                                    else
                                    {
                                        dr["PayCash"] = 0;
                                    }
                                    break;
                                case 1:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayMoneyBalance"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayMoneyBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayMoneyBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayMoneyBalance"] = StringUtils.GetDbDecimal(dr["PayMoneyBalance"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayMoneyBalance"]);
                                    }
                                    else
                                    {
                                        dr["PayMoneyBalance"] = 0;
                                    }
                                    break;
                                case 2:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayBankCard"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayBankCard"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayBankCard"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayBankCard"] = StringUtils.GetDbDecimal(dr["PayBankCard"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayBankCard"]);
                                    }
                                    else
                                    {
                                        dr["PayBankCard"] = 0;
                                    }
                                    break;
                                case 3:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayOther"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayOther"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayOther"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayOther"] = StringUtils.GetDbDecimal(dr["PayOther"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayOther"]);
                                    }
                                    else
                                    {
                                        dr["PayOther"] = 0;
                                    }
                                    break;
                                case 6:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayPointBalance"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayPointBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayPointBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayPointBalance"] = StringUtils.GetDbDecimal(dr["PayPointBalance"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayPointBalance"]);
                                    }
                                    else
                                    {
                                        dr["PayPointBalance"] = 0;
                                    }
                                    break;
                                case 7:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayCouponBalance"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayCouponBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayCouponBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayCouponBalance"] = StringUtils.GetDbDecimal(dr["PayCouponBalance"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayCouponBalance"]);
                                    }
                                    else
                                    {
                                        dr["PayCouponBalance"] = 0;
                                    }
                                    break;
                                case 8:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayWeChatBalance"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayWeChatBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayWeChatBalance"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayWeChatBalance"] = StringUtils.GetDbDecimal(dr["PayWeChatBalance"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayWeChatBalance"]);
                                    }
                                    else
                                    {
                                        dr["PayWeChatBalance"] = 0;
                                    }
                                    break;
                                case 9:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayAipay"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayAipay"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayAipay"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayAipay"] = StringUtils.GetDbDecimal(dr["PayAipay"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayAipay"]);
                                    }
                                    else
                                    {
                                        dr["PayAipay"] = 0;
                                    }
                                    break;
                                case 100:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayLoan"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayLoan"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayLoan"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayLoan"] = StringUtils.GetDbDecimal(dr["PayLoan"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayLoan"]);
                                    }
                                    else
                                    {
                                        dr["PayLoan"] = 0;
                                    }
                                    break;
                                case 101:
                                    if (orderNumber == 1)
                                    {
                                        dr["PayThird"] = StringUtils.GetDbDecimal(item.ItemArray[2]);
                                        profitAmount += StringUtils.GetDbDecimal(item.ItemArray[2]);
                                    }
                                    else if (orderNumber > 1)
                                    {
                                        if (StringUtils.GetDbInt(dtOrderBasic.Rows[i]["IsUseRate"]) == 1)
                                        {
                                            dr["PayThird"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]) * StringUtils.GetDbDecimal(item.ItemArray[5]);
                                        }
                                        else
                                        {
                                            dr["PayThird"] = StringUtils.GetDbDecimal(dtOrderBasic.Rows[i]["TotalSalePrice"]);
                                        }
                                        if (type == 2)
                                        {
                                            dr["PayThird"] = StringUtils.GetDbDecimal(dr["PayThird"]) * -1;
                                        }
                                        profitAmount += StringUtils.GetDbDecimal(dr["PayThird"]);
                                    }
                                    else
                                    {
                                        dr["PayThird"] = 0;
                                    }
                                    break;

                            }
                        }

                    }
                    dr["ProfitAmount"] = StringUtils.GetDbDecimal(dr["PayCash"]) + StringUtils.GetDbDecimal(dr["PayBankCard"]) + StringUtils.GetDbDecimal(dr["PayWeChatBalance"]) + StringUtils.GetDbDecimal(dr["PayMoneyBalance"]) + StringUtils.GetDbDecimal(dr["PayPointBalance"]) + StringUtils.GetDbDecimal(dr["PayCouponBalance"]) + StringUtils.GetDbDecimal(dr["PayOther"]) + StringUtils.GetDbDecimal(dr["PayAipay"]) + StringUtils.GetDbDecimal(dr["PayLoan"]) + StringUtils.GetDbDecimal(dr["PayThird"]);


                    dt.Rows.Add(dr);
                }


                DataTable dtResult = dt.Clone();
                for (int i = 0; i < dt.Rows.Count; )
                {
                    DataRow dr = dtResult.NewRow();
                    string BranchName = dt.Rows[i]["BranchName"].ToString();
                    string CategoryName = dt.Rows[i]["CategoryName"].ToString();
                    dr["BranchName"] = BranchName;
                    dr["CategoryName"] = CategoryName;
                    int OrderID = StringUtils.GetDbInt(dt.Rows[i]["OrderID"]);
                    decimal ProfitAmount = 0;
                    decimal PayCash = 0;
                    decimal PayBankCard = 0;
                    decimal PayWeChatBalance = 0;
                    decimal PayAipay = 0;
                    decimal PayMoneyBalance = 0;
                    decimal PayPointBalance = 0;
                    decimal PayCouponBalance = 0;
                    decimal PayOther = 0;
                    decimal PayLoan = 0;
                    decimal PayThird = 0;

                    for (; i < dt.Rows.Count; )
                    {
                        if (BranchName == dt.Rows[i]["BranchName"].ToString() && CategoryName == dt.Rows[i]["CategoryName"].ToString())
                        {
                            ProfitAmount += StringUtils.GetDbDecimal(dt.Rows[i]["ProfitAmount"]);
                            PayCash += StringUtils.GetDbDecimal(dt.Rows[i]["PayCash"]);
                            PayBankCard += StringUtils.GetDbDecimal(dt.Rows[i]["PayBankCard"]);
                            PayWeChatBalance += StringUtils.GetDbDecimal(dt.Rows[i]["PayWeChatBalance"]);
                            PayAipay += StringUtils.GetDbDecimal(dt.Rows[i]["PayAipay"]);
                            PayMoneyBalance += StringUtils.GetDbDecimal(dt.Rows[i]["PayMoneyBalance"]);
                            PayPointBalance += StringUtils.GetDbDecimal(dt.Rows[i]["PayPointBalance"]);
                            PayCouponBalance += StringUtils.GetDbDecimal(dt.Rows[i]["PayCouponBalance"]);
                            PayOther += StringUtils.GetDbDecimal(dt.Rows[i]["PayOther"]);
                            PayLoan += StringUtils.GetDbDecimal(dt.Rows[i]["PayLoan"]);
                            PayThird += StringUtils.GetDbDecimal(dt.Rows[i]["PayThird"]);
                            if (StringUtils.GetDbInt(dt.Rows[i]["OrderID"]) != OrderID)
                            {
                                OrderID = StringUtils.GetDbInt(dt.Rows[i]["OrderID"]);
                            }
                            i++;
                        }
                        else
                        {
                            break;
                        }
                    }

                    dr["ProfitAmount"] = ProfitAmount;
                    dr["PayCash"] = PayCash;
                    dr["PayBankCard"] = PayBankCard;
                    dr["PayWeChatBalance"] = PayWeChatBalance;
                    dr["PayAipay"] = PayAipay;
                    dr["PayMoneyBalance"] = PayMoneyBalance;
                    dr["PayPointBalance"] = PayPointBalance;
                    dr["PayCouponBalance"] = PayCouponBalance;
                    dr["PayOther"] = PayOther;
                    dr["PayLoan"] = PayLoan;
                    dr["PayThird"] = PayThird;


                    dr["PayAll"] = PayCash + PayBankCard + PayWeChatBalance + PayMoneyBalance + PayPointBalance + PayCouponBalance + PayOther + PayAipay + PayLoan + PayThird;
                    dr["IncomeAll"] = PayCash + PayBankCard + PayWeChatBalance + PayAipay + PayLoan + PayThird;
                    dtResult.Rows.Add(dr);

                }
                dtResult.Columns.Remove("OrderID");
                dtResult.Columns.Remove("TotalSalePrice");
                return dtResult;
            }
        }




        public DataTable getCardInfo(int CompanyID, int BranchID)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSql = @" SELECT T1.CardName,ISNULL(T4.AllCount,0) AllCount,ISNULL(T8.Balance,0) Balance FROM [MST_CARD] T1 ";

                if (BranchID > 0)
                {
                    strSql += " INNER JOIN [MST_CARD_BRANCH] T2 ON T1.ID = T2.CardID AND T2.BranchID=@BranchID  ";
                }

                strSql += @" LEFT JOIN (SELECT T3.CardID,COUNT(T3.UserCardNo) AllCount FROM [TBL_CUSTOMER_CARD] T3 WHERE T3.CompanyID=@CompanyID GROUP BY T3.CardID ) T4 ON T1.ID= T4.CardID
                             LEFT JOIN (SELECT T7.CardID,SUM(T7.Balance) Balance FROM [TBL_CUSTOMER_CARD] T7 WHERE T7.CompanyID=@CompanyID AND T7.Balance > 0 GROUP BY T7.CardID ) T8 ON T1.ID= T8.CardID
                             WHERE T1.CompanyID=@CompanyID ";

                DataTable dt = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32), db.Parameter("@BranchID", BranchID, DbType.Int32)).ExecuteDataTable();

                return dt;
            }
        }

        public DataTable getCardInfoDetail(int CompanyID, int BranchID)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSql = @" select T2.Name,T3.BranchName,T4.CardName,T1.UserCardNo,CASE T2.Available WHEN 1 THEN '正在使用' ELSE '已关闭' END AS Status,T1.CardExpiredDate,T1.Balance from [TBL_CUSTOMER_CARD] T1 
                                INNER JOIN [CUSTOMER] T2 ON T1.UserID = T2.UserID 
                                LEFT JOIN [BRANCH] T3 ON T1.BranchID = T3.ID
                                INNER JOIN [MST_CARD] T4 ON T1.CardID = T4.ID
                                WHERE T1.CompanyID=@CompanyID ";

                DataTable dt = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32), db.Parameter("@BranchID", BranchID, DbType.Int32)).ExecuteDataTable();

                return dt;
            }
        }

        public DataTable getAttendanceInfo(int CompanyID, int BranchID, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSql = @" select distinct T2.BranchName,T3.Name AccountName,CONVERT(nvarchar(10),T1.Today,120) CheckOnDay  ,T1.BranchID,T1.AccountID from [TBL_ACCOUNT_ATTENDANCE] T1 WITH (NOLOCK) 
                                    LEFT JOIN [BRANCH] T2 WITH (NOLOCK)  ON T1.BranchID = T2.ID
                                    LEFT JOIN [ACCOUNT] T3 WITH (NOLOCK)  ON T1.AccountID = T3.UserID
                                    where T1.CompanyID = @CompanyID AND T1.Today >=@BeginDay AND T1.Today <= @EndDay  ";

                if (BranchID > 0)
                {
                    strSql += " and T1.BranchID = @BranchID ";
                }

                DataTable dt = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", BranchID, DbType.Int32)
                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();

                string strSqlTime = @" select CONVERT(nvarchar(10),T1.Today,120)  as CheckOnDay ,T1.AccountID,T1.BranchID,T1.CheckOnTime,T2.Name from [TBL_ACCOUNT_ATTENDANCE] T1 WITH (NOLOCK) 
                                        LEFT JOIN [ACCOUNT] T2  WITH (NOLOCK)  ON T1.CheckOnAccID = T2.UserID
									  where T1.CompanyID = @CompanyID AND T1.Today >=@BeginDay AND T1.Today <= @EndDay  order by T1.CheckOnTime ";

                DataTable dtTime = db.SetCommand(strSqlTime, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", BranchID, DbType.Int32)
                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();



                DataTable dtRes = new DataTable();
                dtRes.Columns.Add("BranchName");
                dtRes.Columns.Add("AccountName");
                dtRes.Columns.Add("Today");
                dtRes.Columns.Add("EarlyTime");
                dtRes.Columns["EarlyTime"].DataType = typeof(DateTime);
                dtRes.Columns.Add("EarlyMan");
                dtRes.Columns["EarlyMan"].DataType = typeof(string);
                dtRes.Columns.Add("LastTime");
                dtRes.Columns["LastTime"].DataType = typeof(DateTime);
                dtRes.Columns.Add("LastMan");
                dtRes.Columns["LastMan"].DataType = typeof(string);
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    DataRow dr = dtRes.NewRow();
                    dr["BranchName"] = dt.Rows[i]["BranchName"];
                    dr["AccountName"] = dt.Rows[i]["AccountName"];
                    dr["Today"] = dt.Rows[i]["CheckOnDay"];
                    string strWhere = " CheckOnDay = '" + StringUtils.GetDbString(dt.Rows[i]["CheckOnDay"]) + "' and BranchID = " + StringUtils.GetDbInt(dt.Rows[i]["BranchID"]) + " AND AccountID = " + StringUtils.GetDbInt(dt.Rows[i]["AccountID"]);
                    DataRow[] drTime = dtTime.Select(strWhere);
                    if (drTime != null && drTime.Length > 0)
                    {
                        dr["EarlyTime"] = StringUtils.GetDbDateTime(drTime[0].ItemArray[3]);
                        dr["EarlyMan"] = StringUtils.GetDbString(drTime[0].ItemArray[4]);
                        dr["LastTime"] = StringUtils.GetDbDateTime(drTime[drTime.Length - 1].ItemArray[3]);
                        dr["LastMan"] = StringUtils.GetDbString(drTime[drTime.Length - 1].ItemArray[4]);
                    }

                    dtRes.Rows.Add(dr);
                }
                return dtRes;
            }
        }


        public DataTable getCommissionSales(int CompanyID, int BranchID, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSql = @"  select T2.BranchName,CONVERT(varchar(16), T1.CreateTime, 120) As CreateTime , Case T1.SourceType WHEN 1 THEN '销售' WHEN 2 THEN '操作' WHEN 3 THEN '充值' ELSE '' END AS SourceType,Isnull(T4.ServiceName,T5.CommodityName) as SourceName,T1.Income,convert(varchar(20),T1.ProfitPct * 100) + '%' as ProfitPct ,T1.Profit,CASE T1.CommType WHEN 1 THEN convert(varchar(20),T1.CommValue * 100) + '%' when 2 then convert(varchar(20),T1.CommValue) + '元' END AS CommValue,T3.Name,T1.AccountProfit,T1.AccountComm,CASE T1.CommFlag WHEN 1 THEN '首充' WHEN 2 THEN '指定' WHEN 3 THEN 'e账户支付' end as CommFlag
                                            from [TBL_PROFIT_COMMISSION_DETAIL] T1 With (NOLOCK) 
											left join [BRANCH] T2  With (NOLOCK) 
											ON T1.BranchID = T2.ID
											LEFT JOIN [ACCOUNT] T3 With (NOLOCK) 
											ON T1.AccountID = T3.UserID
											LEFT JOIN [TBL_ORDER_SERVICE] T4 ON T1.SubSourceID = T4.OrderID
											LEFT JOIN [TBL_ORDER_COMMODITY] T5 ON T1.SubSourceID = T5.OrderID
                                            WHERE T1.CompanyID=@CompanyID AND T1.RecordType = 1 AND T1.CreateTime >@BeginDay AND T1.CreateTime <@EndDay and T1.SourceType = 1   ";

                if (BranchID > 0)
                {
                    strSql += " and T1.BranchID = @BranchID ";
                }

                DataTable dt = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", BranchID, DbType.Int32)
                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();

                return dt;
            }
        }




        public DataTable getCommissionOpt(int CompanyID, int BranchID, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSql = @" select T2.BranchName,CONVERT(varchar(16), T1.CreateTime, 120) As CreateTime , Case T1.SourceType WHEN 1 THEN '销售' WHEN 2 THEN '操作' WHEN 3 THEN '充值' ELSE '' END AS SourceType,Isnull(T5.SubServiceName,T6.ServiceName) as SourceName,T1.Income,convert(varchar(20),T1.ProfitPct * 100) + '%' as ProfitPct,T1.Profit,CASE T1.CommType WHEN 1 THEN convert(varchar(20),T1.CommValue * 100) + '%' when 2 then convert(varchar(20),T1.CommValue) + '元' END AS CommValue,T3.Name,T1.AccountProfit,T1.AccountComm,CASE T1.CommFlag WHEN 1 THEN '首充' WHEN 2 THEN '指定' end as CommFlag
                                            from [TBL_PROFIT_COMMISSION_DETAIL] T1 With (NOLOCK) 
											left join [BRANCH] T2  With (NOLOCK) 
											ON T1.BranchID = T2.ID
											LEFT JOIN [ACCOUNT] T3 With (NOLOCK) 
											ON T1.AccountID = T3.UserID
											LEFT JOIN [TREATMENT] T4 ON T1.SourceID = T4.ID
											LEFT JOIN [TBL_SUBSERVICE] T5 ON T4.SubServiceID = T5.ID AND T5.Available = 1
											LEFT JOIN [TBL_ORDER_SERVICE] T6 ON T1.SubSourceID = T6.OrderID
                                            WHERE T1.CompanyID=@CompanyID AND T1.RecordType = 1 AND T1.CreateTime >@BeginDay AND T1.CreateTime <@EndDay and T1.SourceType = 2 ";

                if (BranchID > 0)
                {
                    strSql += " and T1.BranchID = @BranchID ";
                }

                DataTable dt = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", BranchID, DbType.Int32)
                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();

                return dt;
            }
        }






        public DataTable getCommissionRecharge(int CompanyID, int BranchID, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSql = @" select T2.BranchName,CONVERT(varchar(16), T1.CreateTime, 120) As CreateTime , Case T1.SourceType WHEN 1 THEN '销售' WHEN 2 THEN '操作' WHEN 3 THEN '充值' ELSE '' END AS SourceType,T4.CardName as SourceName,T1.Income, convert(varchar(20),T1.ProfitPct * 100) + '%' as ProfitPct,T1.Profit,CASE T1.CommType WHEN 1 THEN convert(varchar(20),T1.CommValue * 100) + '%' when 2 then convert(varchar(20),T1.CommValue) + '元' END AS CommValue,T3.Name,T1.AccountProfit,T1.AccountComm,CASE T1.CommFlag WHEN 1 THEN '首充' WHEN 2 THEN '指定' end as CommFlag
                                            from [TBL_PROFIT_COMMISSION_DETAIL] T1 With (NOLOCK) 
											left join [BRANCH] T2  With (NOLOCK) 
											ON T1.BranchID = T2.ID
											LEFT JOIN [ACCOUNT] T3 With (NOLOCK) 
											ON T1.AccountID = T3.UserID
											LEFT JOIN [MST_CARD] T4 ON T1.SubSourceID = T4.CardCode AND T4.Available = 1
                                            WHERE T1.CompanyID=@CompanyID AND T1.RecordType = 1 AND T1.CreateTime >@BeginDay AND T1.CreateTime <@EndDay and T1.SourceType = 3 ";

                if (BranchID > 0)
                {
                    strSql += " and T1.BranchID = @BranchID ";
                }

                DataTable dt = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", BranchID, DbType.Int32)
                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();

                return dt;
            }
        }

        public DataTable getSalaryInfo(int CompanyID, int BranchID, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSqlBasic = @" select distinct T2.Name As AccountName,T1.AccountID,T3.BranchName,T1.BranchID
                                            from [TBL_PROFIT_COMMISSION_DETAIL] T1 With (NOLOCK) 
                                            INNER JOIN [ACCOUNT] T2  With (NOLOCK) 
                                            ON T1.AccountID = T2.UserID 
											LEFT JOIN [BRANCH] T3 ON T1.BranchID = T3.ID
                                            WHERE T1.CompanyID=@CompanyID AND T1.RecordType = 1 AND  T1.CreateTime >@BeginDay AND T1.CreateTime <@EndDay ";
                if (BranchID > 0)
                {
                    strSqlBasic += " and T1.BranchID = @BranchID ";
                }

                DataTable dtBasic = db.SetCommand(strSqlBasic, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", BranchID, DbType.Int32)
                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();

                if (dtBasic == null || dtBasic.Rows.Count == 0)
                {
                    return null;
                }

                string strSqlComm = @"select Sum(AccountProfit) as AccountProfit ,Sum(AccountComm) As AccountComm   ,T1.SourceType ,T1.AccountID,T1.BranchID
                                            from [TBL_PROFIT_COMMISSION_DETAIL] T1 With (NOLOCK) 
                                            WHERE T1.CompanyID=@CompanyID  AND T1.RecordType = 1 AND  T1.CreateTime >@BeginDay AND T1.CreateTime <@EndDay  ";

                if (BranchID > 0)
                {
                    strSqlComm += " and T1.BranchID = @BranchID ";
                }

                strSqlComm += "  GROUP BY T1.SourceType,T1.AccountID,T1.BranchID";

                DataTable dtComm = db.SetCommand(strSqlComm, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", BranchID, DbType.Int32)
                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();

                string strSqlRule = @" select T1.AccountID,T1.BaseSalary,T1.CommType,T1.CommPattern,T1.ProfitRangeUnit,T1.ProfitMinRange,T1.ProfitMaxRange,T1.ProfitPct 
                                            from [TBL_ACCOUNT_COMMISSION_RULE] T1 WITH (NOLOCK) WHERE T1.CompanyID=@CompanyID AND T1.RecordType = 1 ";


                DataTable dtRule = db.SetCommand(strSqlRule, db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteDataTable();

                string strSqlOpCount = @" select COUNT(0) As OpCount ,T1.AccountID,T1.BranchID
                                            from [TBL_PROFIT_COMMISSION_DETAIL] T1 With (NOLOCK) 
                                            WHERE T1.CompanyID=@CompanyID  AND T1.RecordType = 1 AND  T1.CreateTime >@BeginDay AND T1.CreateTime <@EndDay AND T1.SourceType = 2  ";

                if (BranchID > 0)
                {
                    strSqlOpCount += " and T1.BranchID = @BranchID ";
                }

                strSqlOpCount += " GROUP BY T1.AccountID,T1.BranchID";

                DataTable dtOpCount = db.SetCommand(strSqlOpCount, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", BranchID, DbType.Int32)
                    , db.Parameter("@BeginDay", beginDay, DbType.DateTime)
                    , db.Parameter("@EndDay", endDay, DbType.DateTime)).ExecuteDataTable();


                DataTable dt = new DataTable();
                dt.Columns.Add("BranchName");
                dt.Columns.Add("AccountName");
                dt.Columns.Add("BaseSalary");
                dt.Columns["BaseSalary"].DataType = typeof(decimal);
                dt.Columns.Add("SalesProfit");
                dt.Columns["SalesProfit"].DataType = typeof(decimal);
                dt.Columns.Add("SalesComm");
                dt.Columns["SalesComm"].DataType = typeof(decimal);
                dt.Columns.Add("OptProfit");
                dt.Columns["OptProfit"].DataType = typeof(decimal);
                dt.Columns.Add("OptComm");
                dt.Columns["OptComm"].DataType = typeof(decimal);
                dt.Columns.Add("ECardProfit");
                dt.Columns["ECardProfit"].DataType = typeof(decimal);
                dt.Columns.Add("ECardComm");
                dt.Columns["ECardComm"].DataType = typeof(decimal);

                for (int i = 0; i < dtBasic.Rows.Count; i++)
                {
                    DataRow dr = dt.NewRow();
                    dr["BranchName"] = dtBasic.Rows[i]["BranchName"];
                    dr["AccountName"] = dtBasic.Rows[i]["AccountName"];
                    int AccountIDBasic = StringUtils.GetDbInt(dtBasic.Rows[i]["AccountID"]);
                    int BranchIDBasic = StringUtils.GetDbInt(dtBasic.Rows[i]["BranchID"]);

                    DataRow[] drRule = dtRule.Select("AccountID=" + AccountIDBasic);
                    if (drRule != null && drRule.Length > 0)
                    {
                        dr["BaseSalary"] = drRule[0].ItemArray[1];
                    }
                    else
                    {
                        dr["BaseSalary"] = 0;
                    }

                    dr["SalesProfit"] = 0;
                    dr["SalesComm"] = 0;
                    dr["OptProfit"] = 0;
                    dr["OptComm"] = 0;
                    dr["ECardProfit"] = 0;
                    dr["ECardComm"] = 0;
                    DataRow[] drComm = dtComm.Select("AccountID=" + AccountIDBasic + " and BranchID=" + BranchIDBasic);
                    if (drComm != null && drComm.Length > 0)
                    {

                        foreach (DataRow item in drComm)
                        {
                            decimal profit = StringUtils.GetDbDecimal(item["AccountProfit"]);
                            decimal comm = StringUtils.GetDbDecimal(item["AccountComm"]);

                            switch (StringUtils.GetDbInt(item["SourceType"]))
                            {
                                #region 销售提成
                                case 1:
                                    dr["SalesProfit"] = profit;
                                    DataRow[] drRuleTemp = dtRule.Select("AccountID=" + AccountIDBasic + " AND CommType = 1");
                                    if (drRule != null && drRule.Length > 0)
                                    {
                                        if (StringUtils.GetDbInt(drRule[0]["CommPattern"]) == 1)
                                        {
                                            dr["SalesComm"] = comm;
                                        }
                                        else if (StringUtils.GetDbInt(drRule[0]["CommPattern"]) == 2)
                                        {
                                            if (profit > 0)
                                            {
                                                DataRow[] drRuleMin = dtRule.Select("AccountID=" + AccountIDBasic + " AND CommType = 1 and  ProfitMinRange <=" + profit + " and ProfitMaxRange >= " + profit);
                                                if (drRuleMin != null && drRuleMin.Length == 1)
                                                {
                                                    dr["SalesComm"] = profit * StringUtils.GetDbDecimal(drRuleMin[0]["ProfitPct"]);
                                                }
                                                else
                                                {
                                                    dr["SalesComm"] = comm;
                                                }
                                            }
                                            else
                                            {
                                                dr["SalesComm"] = 0;
                                            }
                                        }
                                    }
                                    break;
                                #endregion
                                case 2:
                                    dr["OptProfit"] = profit;
                                    drRuleTemp = dtRule.Select("AccountID=" + AccountIDBasic + " AND CommType = 2");
                                    if (drRule != null && drRule.Length > 0)
                                    {

                                        if (StringUtils.GetDbInt(drRule[0]["CommPattern"]) == 1)
                                        {
                                            dr["OptComm"] = comm;
                                        }
                                        else if (StringUtils.GetDbInt(drRule[0]["CommPattern"]) == 2)
                                        {
                                            if (profit > 0)
                                            {
                                                DataRow[] drRuleMin = null;
                                                if (StringUtils.GetDbInt(drRule[0]["ProfitRangeUnit"]) == 1)
                                                {
                                                    drRuleMin = dtRule.Select("AccountID=" + AccountIDBasic + " AND CommType = 2 and ProfitRangeUnit = 1 and  ProfitMinRange <=" + profit + " and ProfitMaxRange >= " + profit);
                                                }
                                                else if (StringUtils.GetDbInt(drRule[0]["ProfitRangeUnit"]) == 2)
                                                {
                                                    DataRow[] drOpCount = dtOpCount.Select("AccountID=" + AccountIDBasic + " and BranchID=" + BranchIDBasic);
                                                    if (drOpCount != null && drOpCount.Length == 1)
                                                    {
                                                        int OpCount = StringUtils.GetDbInt(drOpCount[0].ItemArray[0]);
                                                        drRuleMin = dtRule.Select("AccountID=" + AccountIDBasic + " AND CommType = 2 and ProfitRangeUnit = 2 and  ProfitMinRange <=" + OpCount + " and ProfitMaxRange >= " + OpCount);
                                                    }
                                                }
                                                if (drRuleMin != null && drRuleMin.Length == 1)
                                                {
                                                    dr["OptComm"] = profit * StringUtils.GetDbDecimal(drRuleMin[0]["ProfitPct"]);
                                                }
                                                else
                                                {
                                                    dr["OptComm"] = comm;
                                                }
                                            }
                                            else
                                            {
                                                dr["OptComm"] = 0;
                                            }
                                        }
                                    }
                                    break;
                                case 3:
                                    dr["ECardProfit"] = profit;
                                    drRuleTemp = dtRule.Select("AccountID=" + AccountIDBasic + " AND CommType = 3");
                                    if (drRule != null && drRule.Length > 0)
                                    {
                                        if (StringUtils.GetDbInt(drRule[0]["CommPattern"]) == 1)
                                        {
                                            dr["ECardComm"] = comm;
                                        }
                                        else if (StringUtils.GetDbInt(drRule[0]["CommPattern"]) == 2)
                                        {
                                            if (profit > 0)
                                            {
                                                DataRow[] drRuleMin = dtRule.Select("AccountID=" + AccountIDBasic + " AND CommType = 3 and  ProfitMinRange <=" + profit + " and ProfitMaxRange >= " + profit);
                                                if (drRuleMin != null && drRuleMin.Length == 1)
                                                {
                                                    dr["ECardComm"] = profit * StringUtils.GetDbDecimal(drRuleMin[0]["ProfitPct"]);
                                                }
                                                else
                                                {
                                                    dr["ECardComm"] = comm;
                                                }
                                            }
                                            else
                                            {
                                                dr["ECardComm"] = 0;
                                            }
                                        }
                                    }
                                    break;
                            }
                        }
                    }
                    dt.Rows.Add(dr);
                }

                return dt;
            }
        }


        public DataTable getCustomerRelation(int CompanyID, int BranchID)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSqlBasic = @" select distinct T2.Name as CustomerName,T3.LoginMobile,T4.BranchName,T1.BranchID,T1.CustomerID, '' as Service, '' as Sales FROM [RELATIONSHIP] T1 with (nolock) 
                                        LEFT JOIN [CUSTOMER] T2 WITH (NOLOCK) on T1.CustomerID = T2.UserID 
                                        LEFT JOIN [USER] T3  with (nolock) on T1.CustomerID = T3.ID
                                        LEFT JOIN [BRANCH] T4  with (nolock) on T1.BranchID = T4.ID
                                        WHERE T1.CompanyID = @CompanyID and T1.Available = 1  ";
                if (BranchID > 0) {
                    strSqlBasic += " AND T1.BranchID =@BranchID";
                }

                DataTable dtBasic = db.SetCommand(strSqlBasic, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", BranchID, DbType.Int32)).ExecuteDataTable();

                if (dtBasic == null && dtBasic.Rows.Count == 0) {
                    return null;
                }

                string strSqlSub = @" select T2.Name AS AccountName, T1.BranchID , T1.CustomerID,T1.Type from [RELATIONSHIP] T1 with (nolock) 
                                        LEFT JOIN [ACCOUNT] T2 ON T1.AccountID = T2.UserID
                                        WHERE T1.CompanyID =@CompanyID AND T1.Available = 1 ";

                if (BranchID > 0)
                {
                    strSqlBasic += " and T1.BranchID = @BranchID ";
                }

                DataTable dtSub = db.SetCommand(strSqlSub, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                        , db.Parameter("@BranchID", BranchID, DbType.Int32)).ExecuteDataTable();

                if (dtSub != null && dtSub.Rows.Count > 0) {
                    for (int i = 0; i < dtBasic.Rows.Count; i++)
                    {
                        DataRow[] drService = dtSub.Select("BranchID=" + dtBasic.Rows[i]["BranchID"] + " and CustomerID=" + dtBasic.Rows[i]["CustomerID"] + " AND Type = 1");
                        if (drService != null && drService.Length > 0)
                        {
                            string strService = "";
                            foreach (DataRow item in drService)
                            {
                                strService += "," + item["AccountName"].ToString();
                            }
                            dtBasic.Rows[i]["Service"] = strService.Substring(1);
                        }

                        DataRow[] drSales = dtSub.Select("BranchID=" + dtBasic.Rows[i]["BranchID"] + " and CustomerID=" + dtBasic.Rows[i]["CustomerID"] + " AND Type = 2");
                        if (drSales != null && drSales.Length > 0)
                        {
                            string strSales = "";
                            foreach (DataRow item in drSales)
                            {
                                strSales += "," + item["AccountName"].ToString();
                            }
                            dtBasic.Rows[i]["Sales"] = strSales.Substring(1);
                        }
                    }
                }

                dtBasic.Columns.Remove("BranchID");
                dtBasic.Columns.Remove("CustomerID");
                return dtBasic;
            }
        }
        /// <summary>
        /// 下载顾客评价报表
        /// </summary>
        /// <param name="companyId"></param>
        /// <returns></returns>
        public DataTable GetServiceRate(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSql = 
                    @"select 
                        BranchName, 
                        ServiceName, 
                        Satisfaction, 
                        StaffName, 
                        CustomerName, 
                        CustomerTel, 
                        RateDate 
                    from 
                        dbo.fServiceRateReport(@CompanyID, @BranchID, @BeginDay, @EndDay) 
                    order by BranchName, RateDate, ServiceName";

                DataTable dt = db.SetCommand(strSql, 
                                    db.Parameter("@CompanyID", companyId, DbType.Int32), 
                                    db.Parameter("@BranchID", branchId, DbType.Int32), 
                                    db.Parameter("@BeginDay", beginDay, DbType.DateTime2), 
                                    db.Parameter("@EndDay", endDay, DbType.DateTime2)
                                ).ExecuteDataTable();
                return dt;
            }
        }
        /// <summary>
        /// 下载录入订单报表
        /// </summary>
        /// <param name="companyId"></param>
        /// <returns></returns>
        public DataTable GetInputOrderReport(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSql =
                    @"select
                        BranchName,
                        CustomerName,
                        isnull(PhoneNumber, '') as PhoneNumber,
                        ServiceName,
                        OrderStatus,
                        PaymentStatus,
                        TotalSalePrice,
                        InputStaffName,
                        InputTime,
                        isnull(SaleProfit, '') as SaleProfit,
                        isnull(ServeProfit, '') as ServeProfit
                    from 
                        dbo.fgetInputOrderRecport(@CompanyID, @BranchID, @BeginDay, @EndDay) 
                    order by BranchName, InputTime";

                DataTable dt = db.SetCommand(strSql,
                                    db.Parameter("@CompanyID", companyId, DbType.Int32),
                                    db.Parameter("@BranchID", branchId, DbType.Int32),
                                    db.Parameter("@BeginDay", beginDay, DbType.DateTime),
                                    db.Parameter("@EndDay", endDay, DbType.DateTime)
                                ).ExecuteDataTable();
                return dt;
            }
        }

        /// <summary>
        /// 下载储值卡充值报表
        /// </summary>
        /// <param name="companyId"></param>
        /// <returns></returns>
        public DataTable GetRechargeReport(int companyId, int branchId, DateTime beginDay, DateTime endDay)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSql =
                    @"select
                        BranchName,
                        CustomerName,
                        isnull(PhoneNumber, '') as PhoneNumber,
                        UserCardNo,
                        ActionMode,
                        Amount,
                        Balance,
                        InputStaffName,
                        InputTime,
                        isnull(CardRechargeProfit, '') as CardRechargeProfit
                    from 
                        dbo.fgetRechargeRecport(@CompanyID, @BranchID, @BeginDay, @EndDay) 
                    order by BranchName, InputTime";

                DataTable dt = db.SetCommand(strSql,
                                    db.Parameter("@CompanyID", companyId, DbType.Int32),
                                    db.Parameter("@BranchID", branchId, DbType.Int32),
                                    db.Parameter("@BeginDay", beginDay, DbType.DateTime),
                                    db.Parameter("@EndDay", endDay, DbType.DateTime)
                                ).ExecuteDataTable();
                return dt;
            }
        }
    }
}
