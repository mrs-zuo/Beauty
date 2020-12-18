using BLToolkit.Data;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL.Customer
{
    public class Order_CDAL
    {
        #region 构造类实例
        public static Order_CDAL Instance
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
            internal static readonly Order_CDAL instance = new Order_CDAL();
        }
        #endregion

        public List<GetOrderList_Model> getOrderList(GetOrderListOperation_Model operationModel, int pageSize, int pageIndex, out int recordCount)
        {
            recordCount = 0;
            if (operationModel != null)
            {
                using (DbManager db = new DbManager())
                {
                    List<GetOrderList_Model> list = new List<GetOrderList_Model>();

                    string fileds = @" ROW_NUMBER() OVER ( ORDER BY T1.CreateTime DESC, T1.ID DESC ) AS rowNum ,
                                                  T1.ID AS OrderID ,T7.Name AS ResponsiblePersonName ,T5.Name AS CustomerName ,T1.ProductType ,T1.Quantity ,T1.TotalOrigPrice ,
                                                  T1.TotalSalePrice ,T1.UnPaidPrice ,CONVERT(VARCHAR(16), T1.OrderTime, 20) OrderTime ,
                                                  CASE T1.ProductType WHEN 0 THEN T3.ServiceName ELSE T4.CommodityName END AS ProductName ,
                                                  CASE T1.ProductType WHEN 0 THEN T3.ID ELSE T4.ID END AS OrderObjectID ,
                                                  CASE T1.ProductType WHEN 0 THEN T3.Status ELSE T4.Status END AS Status ,
                                                  ISNULL(T1.OrderSource, 0) AS OrderSource ,T1.PaymentStatus ,T1.CreateTime ";

                    string strSql = "";

                    strSql = @"SELECT  {0}
                                    FROM    [ORDER] T1 WITH ( NOLOCK )
                                            LEFT JOIN [TBL_ORDER_SERVICE] T3 WITH ( NOLOCK ) ON T1.ID = T3.OrderID
                                            LEFT JOIN [TBL_ORDER_COMMODITY] T4 WITH ( NOLOCK ) ON T1.ID = T4.OrderID 
                                            LEFT JOIN [CUSTOMER] T5 WITH ( NOLOCK ) ON T1.CustomerID = T5.UserID
                                            RIGHT JOIN [BRANCH] T6 WITH ( NOLOCK ) ON T1.BranchID = T6.ID
                                            LEFT JOIN [ACCOUNT] T7 WITH ( NOLOCK ) ON T7.UserID = T1.ResponsiblePersonID 
                                    WHERE  T5.Available = 1 AND T1.CreateTime >= T6.StartTime ";

                    if (operationModel.ResponsiblePersonIDs != null && operationModel.ResponsiblePersonIDs.Count > 0)
                    {
                        strSql += " AND (T1.ResponsiblePersonID in ( ";
                        for (int i = 0; i < operationModel.ResponsiblePersonIDs.Count; i++)
                        {
                            if (i == 0)
                            {
                                strSql += operationModel.ResponsiblePersonIDs[i].ToString();
                            }
                            else
                            {
                                strSql += "," + operationModel.ResponsiblePersonIDs[i].ToString();
                            }
                        }
                        strSql += " )";

                        strSql += " OR T1.SalesID in ( ";
                        for (int i = 0; i < operationModel.ResponsiblePersonIDs.Count; i++)
                        {
                            if (i == 0)
                            {
                                strSql += operationModel.ResponsiblePersonIDs[i].ToString();
                            }
                            else
                            {
                                strSql += "," + operationModel.ResponsiblePersonIDs[i].ToString();
                            }
                        }
                        strSql += " ))";
                    }

                    if (operationModel.BranchID > 0)
                    {
                        strSql += " AND T1.BranchID = @BranchID";
                    }

                    if (operationModel.PageIndex > 1)
                    {
                        strSql += " AND T1.CreateTime <= @CreateTime";
                    }

                    if (operationModel.ProductType == 0)
                    {
                        //取所有服务
                        strSql += " AND T1.ProductType=0 ";
                    }
                    else if (operationModel.ProductType == 1)
                    {
                        //取所有商品
                        strSql += " AND T1.ProductType=1 ";
                    }

                    if (operationModel.Status == 9)
                    {
                        strSql += " AND (T1.PaymentStatus=2 OR T1.PaymentStatus=1) ";
                        strSql += " AND T3.Status !=3 AND T4.Status !=3 ";
                    }
                    else
                    {
                        switch (operationModel.Status)
                        {
                            case -1:
                                strSql += " AND T1.Status !=3 ";
                                break;
                            case 0:
                                strSql += " AND (( T3.Status =1 OR T3.Status = 2 OR T3.Status = 5 ) OR ( T4.Status =1 OR T4.Status = 2 OR T4.Status = 5))";
                                break;
                            default:
                                strSql += " AND T1.Status = @Status";
                                break;
                        }

                        if (operationModel.PaymentStatus == 1)
                        {
                            strSql += " AND T1.PaymentStatus=1 ";
                        }
                        else if (operationModel.PaymentStatus == 2)
                        {
                            strSql += " AND T1.PaymentStatus=2 ";
                        }
                        else if (operationModel.PaymentStatus == 3)
                        {
                            strSql += " AND T1.PaymentStatus=3 ";
                        }
                        else if (operationModel.PaymentStatus == 4)
                        {
                            strSql += " AND T1.PaymentStatus=4 ";
                        }
                        else if (operationModel.PaymentStatus == 5)
                        {
                            strSql += " AND T1.PaymentStatus=5 ";
                        }
                    }



                    if (operationModel.FilterByTimeFlag == 1)
                    {

                        strSql += Common.APICommon.getSqlWhereData_1_7_2(4, operationModel.StartTime, operationModel.EndTime, " T1.OrderTime");
                    }

                    if (operationModel.CustomerID > 0)
                    {
                        strSql += " AND T1.CustomerID = @CustomerID";
                    }

                    string strCountSql = string.Format(strSql, " count(0) ");

                    string strgetListSql = "select * from( " + string.Format(strSql, fileds) + " ) a where  rowNum between  " + ((pageIndex - 1) * pageSize + 1) + " and " + pageIndex * pageSize;

                    recordCount = db.SetCommand(strCountSql, db.Parameter("@AccountID", operationModel.AccountID, DbType.Int32)
                                                            , db.Parameter("@BranchID", operationModel.BranchID, DbType.Int32)
                                                            , db.Parameter("@CreateTime", operationModel.CreateTime, DbType.DateTime)
                                                            , db.Parameter("@Status", operationModel.Status, DbType.Int32)
                                                            , db.Parameter("@CustomerID", operationModel.CustomerID, DbType.Int32)).ExecuteScalar<int>();

                    if (recordCount < 0)
                    {
                        return null;
                    }

                    list = db.SetCommand(strgetListSql, db.Parameter("@AccountID", operationModel.AccountID, DbType.Int32)
                                                    , db.Parameter("@BranchID", operationModel.BranchID, DbType.Int32)
                                                    , db.Parameter("@CreateTime", operationModel.CreateTime, DbType.DateTime)
                                                    , db.Parameter("@Status", operationModel.Status, DbType.Int32)
                                                    , db.Parameter("@CustomerID", operationModel.CustomerID, DbType.Int32)).ExecuteList<GetOrderList_Model>();
                    return list;
                }
            }
            else
            {
                return null;
            }
        }

        public GetOrderDetail_Model getOrderDetail(int orderObjectID, int productType, int CompanyID)
        {
            GetOrderDetail_Model model = new GetOrderDetail_Model();
            using (DbManager db = new DbManager())
            {
                string strSql = "";
                if (productType == 0)
                {
                    //0:服务 1：商品 
                    strSql = @"SELECT  T1.ID AS OrderID ,
                                T1.BranchID ,
                                T10.BranchName ,
                                CONVERT(VARCHAR(16), T1.OrderTime, 20) AS OrderTime ,
                                T1.ProductType ,
                                T3.ServiceCode AS ProductCode ,
                                T3.ServiceName ProductName ,
                                T1.Status ,
                                T1.TotalOrigPrice ,
                                T1.TotalCalcPrice,
                                T1.TotalSalePrice ,
                                T1.UnPaidPrice ,
                                ISNULL(T1.PaymentStatus, 2) AS PaymentStatus ,
                                T1.ResponsiblePersonID ,
                                T1.SalesID AS SalesPersonID ,
                                ISNULL(T3.SubServiceIDs, '') AS SubServiceIDs ,
                                T3.IsPast ,
                                T4.Name AS ResponsiblePersonName ,
                                T9.Name AS SalesName ,
                                T5.UserID CustomerID ,
                                T5.Name CustomerName ,
                                T1.CreatorID ,
                                CONVERT(VARCHAR(16), T1.CreateTime, 20) CreateTime ,
                                T3.Remark ,
                                T6.Name AS CreatorName ,
                                T3.Expirationtime AS ExpirationTime,
                                T3.TGFinishedCount AS FinishedCount,
                                T3.TGPastCount AS PastCount,
                                T3.TGTotalCount AS TotalCount, 
                                T3.TGTotalCount-T3.TGFinishedCount-T3.TGExecutingCount AS SurplusCount,
                                T3.Quantity ,
                                T3.ID AS OrderObjectID
                        FROM    [ORDER] T1 WITH ( NOLOCK )
                                LEFT JOIN [TBL_ORDER_SERVICE] T3 WITH ( NOLOCK ) ON T1.ID = T3.OrderID
                                LEFT JOIN [ACCOUNT] T4 WITH ( NOLOCK ) ON T4.UserID = T1.ResponsiblePersonID
                                LEFT JOIN [CUSTOMER] T5 WITH ( NOLOCK ) ON T1.CustomerID = T5.UserID
                                LEFT JOIN [ACCOUNT] T6 WITH ( NOLOCK ) ON T6.UserID = T1.CreatorID
                                LEFT JOIN [ACCOUNT] T9 WITH ( NOLOCK ) ON T9.UserID = T1.SalesID
                                LEFT JOIN [BRANCH] T10 WITH ( NOLOCK ) ON T1.BranchID = T10.ID
                                WHERE T1.CompanyID=@CompanyID AND T3.ID = @orderObjectID AND T1.ProductType = @ProductType";
                }
                else
                {
                    strSql = @" SELECT  T1.ID AS OrderID ,
                                T1.BranchID ,
                                T10.BranchName ,
                                CONVERT(VARCHAR(16), T1.OrderTime, 20) AS OrderTime ,
                                T1.ProductType ,
                                T3.CommodityCode AS ProductCode ,
                                T3.CommodityName ProductName ,
                                T1.Status ,
                                T1.TotalOrigPrice ,
                                T1.TotalCalcPrice,
                                T1.TotalSalePrice ,
                                T1.UnPaidPrice,
                                ISNULL(T1.PaymentStatus, 2) AS PaymentStatus ,
                                T1.ResponsiblePersonID ,
                                T1.SalesID AS SalesPersonID ,
                                '' AS SubServiceIDs ,
                                0 as IsPast ,
                                T4.Name AS ResponsiblePersonName ,
                                T9.Name AS SalesName ,
                                T5.UserID CustomerID ,
                                T5.Name CustomerName ,
                                T1.CreatorID ,
                                CONVERT(VARCHAR(16), T1.CreateTime, 20) CreateTime ,
                                T3.Remark ,
                                T6.Name AS CreatorName ,
                                '2099-12-31 23:59:59' AS ExpirationTime,
                                T3.DeliveredAmount AS FinishedCount,
                                0 AS PastCount, 
                                T3.Quantity AS TotalCount,
                                T3.Quantity-T3.DeliveredAmount-T3.UndeliveredAmount AS SurplusCount,
                                T3.Quantity ,
                                T3.ID AS OrderObjectID
                        FROM    [ORDER] T1 WITH ( NOLOCK )
                                LEFT JOIN [TBL_ORDER_COMMODITY] T3 WITH ( NOLOCK ) ON T1.ID = T3.OrderID
                                LEFT JOIN [ACCOUNT] T4 WITH ( NOLOCK ) ON T4.UserID = T1.ResponsiblePersonID
                                LEFT JOIN [CUSTOMER] T5 WITH ( NOLOCK ) ON T1.CustomerID = T5.UserID
                                LEFT JOIN [ACCOUNT] T6 WITH ( NOLOCK ) ON T6.UserID = T1.CreatorID
                                LEFT JOIN [ACCOUNT] T9 WITH ( NOLOCK ) ON T9.UserID = T1.SalesID
                                LEFT JOIN [BRANCH] T10 WITH ( NOLOCK ) ON T1.BranchID = T10.ID
                                  WHERE T1.CompanyID=@CompanyID AND T3.ID = @orderObjectID AND T1.ProductType = @ProductType";
                }

                model = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                , db.Parameter("@orderObjectID", orderObjectID, DbType.Int32)
                , db.Parameter("@ProductType", productType, DbType.Int32)).ExecuteObject<GetOrderDetail_Model>();

                return model;
            }
        }

        public List<Group> getGroupNoList(int orderObjectID, int productType, int status = 0)
        {
            List<Group> list = null;
            string strSql = string.Empty;

            if (status == 0)
            {
                status = 1;
            }

            using (DbManager db = new DbManager())
            {
                if (productType == 0)
                {
                    strSql = @"SELECT  T2.Name AS ServicePicName ,
                                        T1.ServicePIC AS ServicePicID ,
                                        T1.GroupNo ,
                                        T1.IsDesignated,
                                        T1.TGStatus AS Status ,
                                        T1.TGStartTime AS StartTime,
                                        1 AS Quantity 
                                FROM    [TBL_TREATGROUP] T1 WITH(NOLOCK) 
                                        INNER JOIN [ACCOUNT] T2 WITH(NOLOCK) ON T1.ServicePIC = T2.UserID
                                WHERE   T1.OrderServiceID = @OrderObjectID ";

                    if (status < 0)
                    {
                        strSql += " AND (T1.TGStatus = 2 OR T1.TGStatus=5) ";//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                    }
                    else
                    {
                        strSql += " AND T1.TGStatus = @Status  ";
                    }

                    strSql += " ORDER BY T1.TGStartTime ";
                }
                else
                {
                    strSql = @"SELECT  ISNULL(T2.Name,'') AS ServicePicName ,
                                        T1.ServicePIC AS ServicePicID ,
                                        T1.ID AS GroupNo ,
                                        0 AS IsDesignated,
                                        Status ,
                                        T1.CDStartTime AS StartTime ,
                                        T1.Quantity 
                                FROM    [TBL_COMMODITY_DELIVERY] T1 WITH ( NOLOCK )
                                        INNER JOIN [ACCOUNT] T2 WITH ( NOLOCK ) ON T1.ServicePIC = T2.UserID
                                WHERE   T1.OrderObjectID = @OrderObjectID ";

                    if (status < 0)
                    {
                        strSql += " AND (T1.Status = 2 OR T1.Status=5) ";//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                    }
                    else
                    {
                        strSql += " AND T1.Status = @Status  ";
                    }
                }

                list = db.SetCommand(strSql, db.Parameter("@OrderObjectID", orderObjectID, DbType.Int32)
                    , db.Parameter("@Status", status, DbType.Int32)).ExecuteList<Group>();
                return list;
            }
        }

        public List<Treatment> getTreatmentListByGroupNO(long groupNO, int CompanyID)
        {
            List<Treatment> list = new List<Treatment>();
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT a.ExecutorID,a.SubServiceID,a.StartTime,a.ID as TreatmentID,b.Name as ExecutorName,c.SubServiceName ,a.status
                                FROM dbo.TREATMENT a 
                                INNER JOIN [ACCOUNT] b ON a.ExecutorID=b.UserID
                                LEFT JOIN [TBL_SUBSERVICE] c ON a.SubServiceID=c.ID 
                                WHERE a.CompanyID=@CompanyID AND a.GroupNo=@GroupNo AND a.status<>3 AND a.status<>4";
                list = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@GroupNo", groupNO, DbType.Int64)).ExecuteList<Treatment>();
                return list;

            }
        }

        public List<ExecutingOrder_Model> GetExecutingOrderList(UtilityOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  
                                        CASE a.ProductType WHEN 0 THEN c.ServiceName ELSE b.CommodityName END AS ProductName ,
                                        CASE a.ProductType WHEN 0 THEN ISNULL(c.TGTotalCount, 0) ELSE ISNULL(b.Quantity, 0) END AS TotalCount ,
                                        CASE a.ProductType WHEN 0 THEN ISNULL(c.TGFinishedCount, 0) ELSE ISNULL(b.DeliveredAmount, 0) END AS FinishedCount ,
                                        CASE a.ProductType WHEN 0 THEN ISNULL(c.TGExecutingCount, 0) ELSE ISNULL(b.UndeliveredAmount, 0) END AS ExecutingCount ,
                                        CASE a.ProductType WHEN 0 THEN ISNULL(c.ID, 0) ELSE ISNULL(b.ID, 0) END AS OrderObjectID ,
                                        a.OrderTime ,
                                        d.Name AS AccountName ,
                                        d.UserID AS AccountID ,
                                        a.ID AS OrderID ,
                                        a.ProductType 
                                FROM    [ORDER] a
                                        LEFT JOIN [TBL_ORDER_COMMODITY] b ON b.OrderID = a.ID
                                        LEFT JOIN [TBL_ORDER_SERVICE] c ON c.OrderID = a.ID
                                        INNER JOIN [ACCOUNT] d ON a.ResponsiblePersonID = d.UserID 
                                        INNER JOIN [BRANCH] e ON a.BranchID = e.ID 
                                WHERE   a.CompanyID = @CompanyID
                                        AND a.CustomerID = @CustomerID
                                        AND a.Status = 1 AND a.OrderTime > e.StartTime ";
                List<ExecutingOrder_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteList<ExecutingOrder_Model>();
                return list;
            }
        }

        public List<UnfinishTG_Model> GetUnfinishTGList(UtilityOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = "";

                string strHeadImg = string.Format(WebAPI.Common.Const.getCustomerHeadImg, "T5.CompanyID", "T5.UserID", "T5.HeadImageFile", model.ImageHeight, model.ImageWidth);
                string serviceSql = @"SELECT  T4.Name AS AccountName ,
                                                T4.UserID AS AccountID ,
                                                0 AS ProductType ,
                                                T2.OrderID AS OrderID ,
                                                T1.TGStartTime ,
                                                T3.PaymentStatus ,
                                                T2.ServiceName AS ProductName ,
                                                T2.TGTotalCount AS TotalCount ,
                                                1 AS FinishedCount ,
                                                T2.ID AS OrderObjectID ,
                                                T1.GroupNo ,
                                                T1.TGStatus AS Status,
                                                T5.Name AS CustomerName ,
                                                T5.UserID AS CustomerID ,
                                                T1.IsDesignated ,"
                                                + strHeadImg +
                                        @" FROM    [TBL_TREATGROUP] T1 WITH ( NOLOCK )
                                                LEFT JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.OrderServiceID = T2.ID
                                                LEFT JOIN [ORDER] T3 WITH ( NOLOCK ) ON T2.OrderID = T3.ID
                                                LEFT JOIN [ACCOUNT] T4 WITH ( NOLOCK ) ON T1.ServicePIC = T4.UserID
                                                LEFT JOIN [CUSTOMER] T5 WITH ( NOLOCK ) ON T2.CustomerID = T5.UserID 
                                                LEFT JOIN [BRANCH] T6 WITH(NOLOCK) ON T1.BranchID = T6.ID 
                                        WHERE   T1.CompanyID = @CompanyID  AND T2.Status <> 3 AND T3.RecordType = 1 AND T1.TGStartTime > T6.StartTime";


                string commoditySql = @"SELECT  T4.Name AS AccountName ,
                                                T4.UserID AS AccountID ,
                                                1 AS ProductType ,
                                                T2.OrderID AS OrderID ,
                                                T1.CDStartTime AS TGStartTime ,
                                                T3.PaymentStatus ,
                                                T2.CommodityName AS ProductName ,
                                                T2.Quantity AS TotalCount ,
                                                T1.Quantity AS FinishedCount ,
                                                T2.ID AS OrderObjectID ,
                                                T1.ID AS GroupNo ,
                                                T1.Status ,
                                                T5.Name AS CustomerName ,
                                                T5.UserID AS CustomerID ,
                                                1 AS IsDesignated ,"
                                                + strHeadImg +
                                        @" FROM    [TBL_COMMODITY_DELIVERY] T1 WITH ( NOLOCK )
                                                    LEFT JOIN [TBL_ORDER_COMMODITY] T2 WITH ( NOLOCK ) ON T1.OrderObjectID = T2.ID
                                                    LEFT JOIN [ORDER] T3 WITH ( NOLOCK ) ON T2.OrderID = T3.ID
                                                    LEFT JOIN [ACCOUNT] T4 WITH ( NOLOCK ) ON T1.ServicePIC = T4.UserID
                                                    LEFT JOIN [CUSTOMER] T5 WITH ( NOLOCK ) ON T2.CustomerID = T5.UserID 
                                                    LEFT JOIN [BRANCH] T6 WITH(NOLOCK) ON T1.BranchID = T6.ID 
                                        WHERE   T1.CompanyID = @CompanyID AND T2.Status <> 3 AND T3.RecordType = 1 AND T1.CDStartTime > T6.StartTime ";

                if (model.CustomerID > 0)
                {
                    serviceSql += " AND T2.CustomerID = @CustomerID ";
                    commoditySql += " AND T2.CustomerID = @CustomerID ";
                }

                if (model.AccountID > 0)
                {
                    serviceSql += " AND (T1.ServicePIC=@AccountID OR T1.CreatorID=@AccountID) ";
                    commoditySql += " AND (T1.ServicePIC=@AccountID OR T1.CreatorID=@AccountID) ";
                }

                if (model.IsToday)
                {
                    serviceSql += " AND (T1.TGStatus = 1 OR T1.TGStatus = 2  OR T3.Status =1  OR T3.Status = 2) AND T1.TGStatus<>3";
                    serviceSql += " AND T1.TGStartTime >= CAST(CONVERT(CHAR(10),GETDATE(),102)+' 00:00:00' AS VARCHAR(20)) and T1.TGStartTime<=  CAST(CONVERT(CHAR(10),GETDATE(),102)+' 23:59:59' AS VARCHAR(20))";

                    commoditySql += " AND (T1.Status = 1 OR T1.Status = 2  OR T3.Status =1  OR T3.Status = 2) AND T1.TGStatus<>3";
                    commoditySql += " AND T1.CDStartTime >= CAST(CONVERT(CHAR(10),GETDATE(),102)+' 00:00:00' AS VARCHAR(20)) and T1.CDStartTime<=  CAST(CONVERT(CHAR(10),GETDATE(),102)+' 23:59:59' AS VARCHAR(20))";
                }
                else
                {
                    if (model.IsBusiness)
                    {
                        serviceSql += " AND T1.TGStatus = 1 AND T3.Status=1 ";
                        commoditySql += " AND T1.Status = 1 AND T3.Status=1 ";
                    }
                    else
                    {
                        serviceSql += " AND T1.TGStatus = 5 ";
                        commoditySql += " AND T1.Status = 5  ";
                    }
                }

                if (model.BranchID > 0)
                {
                    serviceSql += " AND T1.BranchID = @BranchID ";
                    commoditySql += " AND T1.BranchID = @BranchID ";
                }

                if (model.ProductType == 1)
                {
                    strSql = commoditySql;
                }
                else if ((model.ProductType == 0))
                {
                    strSql = serviceSql;
                }
                else
                {
                    strSql = serviceSql + " UNION ALL " + commoditySql;
                }

                List<UnfinishTG_Model> list = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                    , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                    , db.Parameter("@AccountID", model.AccountID, DbType.Int32)).ExecuteList<UnfinishTG_Model>();
                return list;
            }
        }

        public int ConfirmTreatGroup(CompleteTGOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                DataTable dt = new DataTable();
                foreach (CompleteTGDetailOperation_Model item in model.TGDetailList)
                {
                    if (item.OrderID == 0 || item.GroupNo == 0 || item.OrderObjectID == 0)
                    {
                        return -2;
                    }

                    if (item.OrderType == 0)
                    {
                        #region 服务
                        dt = new DataTable();

                        #region 查询基本数据
                        string strSelOrderServiceSql = @"SELECT  T1.ServiceID ,
                                                                T1.TGExecutingCount ,
                                                                T1.TGFinishedCount ,
                                                                T1.TGTotalCount,
                                                                T2.IsConfirmed,
																T1.ResponsiblePersonID,
                                                                T2.ServiceName,
                                                                T1.Remark,
																T2.VisitTime
                                                        FROM    [TBL_ORDER_SERVICE] T1 WITH(NOLOCK)
                                                        INNER JOIN [SERVICE] T2 WITH(NOLOCK) ON T1.ServiceID=T2.ID 
                                                        INNER JOIN [TBL_TREATGROUP] T3 WITH ( NOLOCK ) ON T2.ID=T3.OrderServiceID 
                                                        WHERE   T1.CompanyID = @CompanyID
                                                                AND T1.ID = @OrderObjectID 
                                                                AND T3.GroupNo=@GroupNo 
                                                                AND Status = 1 
                                                                AND T3.TGStatus=5 ";
                        dt = db.SetCommand(strSelOrderServiceSql
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)
                            , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)).ExecuteDataTable();



                        if (dt == null || dt.Rows.Count <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        int finishedCount = StringUtils.GetDbInt(dt.Rows[0]["TGFinishedCount"].ToString());
                        int executingCount = StringUtils.GetDbInt(dt.Rows[0]["TGExecutingCount"].ToString());
                        int totalCount = StringUtils.GetDbInt(dt.Rows[0]["TGTotalCount"].ToString());
                        bool isConfirmed = StringUtils.GetDbBool(dt.Rows[0]["IsConfirmed"].ToString());
                        int responsiblePersonID = StringUtils.GetDbInt(dt.Rows[0]["responsiblePersonID"].ToString());
                        string remark = dt.Rows[0]["Remark"].ToString();
                        string serviceName = dt.Rows[0]["ServiceName"].ToString();
                        string visitTime = dt.Rows[0]["VisitTime"].ToString();

                        int serviceID = StringUtils.GetDbInt(dt.Rows[0]["ServiceID"].ToString());
                        if (serviceID <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        int TGstatus = 2;//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                        int treatMentStatus = 2; //状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认

                        #region 修改Treatment
                        string strAddTreatmentHisSql = @"INSERT INTO [HISTORY_TREATMENT] SELECT * FROM [TREATMENT] WHERE CompanyID = @CompanyID AND GroupNo = @GroupNo";
                        int hisTreatmentCount = db.SetCommand(strAddTreatmentHisSql
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)).ExecuteNonQuery();

                        if (hisTreatmentCount <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        string strUpdateTreatmentSql = @"UPDATE  [TREATMENT]
                                                        SET     Status = @Status ,
                                                                FinishTime = @FinishTime ,
                                                                UpdaterID = @UpdaterID ,
                                                                UpdateTime = @UpdateTime
                                                        WHERE   CompanyID = @CompanyID
                                                                AND GroupNo = @GroupNo";

                        int updateTreatmentCount = db.SetCommand(strUpdateTreatmentSql
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)
                                            , db.Parameter("@Status", treatMentStatus, DbType.Int32)//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                                            , db.Parameter("@FinishTime", model.UpdateTime, DbType.DateTime2)
                                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                            , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)).ExecuteNonQuery();

                        //if (updateTreatmentCount <= 0)
                        //{
                        //    db.RollbackTransaction();
                        //    return 0;
                        //}
                        #endregion

                        #region 修改TreatGroup
                        string strAddTGHisSql = @"INSERT INTO [HST_TREATGROUP] SELECT * FROM [TBL_TREATGROUP] WHERE CompanyID = @CompanyID AND GroupNo = @GroupNo";
                        int hisTGCount = db.SetCommand(strAddTGHisSql
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)).ExecuteNonQuery();

                        if (hisTGCount <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        string strUpdateTGSql = @"UPDATE  [TBL_TREATGROUP]
                                                SET     TGStatus = @TGStatus ,
                                                        TGEndTime = @TGEndTime ,
                                                        UpdaterID = @UpdaterID ,
                                                        UpdateTime = @UpdateTime
                                                WHERE   CompanyID = @CompanyID
                                                        AND GroupNo = @GroupNo";
                        int updateTGCount = db.SetCommand(strUpdateTGSql
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)
                                            , db.Parameter("@TGStatus", TGstatus, DbType.Int32)//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                                            , db.Parameter("@TGEndTime", model.UpdateTime, DbType.DateTime2)
                                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                            , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)).ExecuteNonQuery();

                        if (updateTreatmentCount <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        #endregion

                        // 无限次服务不会自动完成订单
                        if (totalCount > 0)
                        {
                            //是否是最后次TG
                            if (executingCount == 0 && (finishedCount == totalCount))
                            {
                                #region 查询订单下还有没有进行中和待确认的TG
                                string strSelHasConfirmedSql = @"SELECT  COUNT(0)
                                                            FROM    [TBL_TREATGROUP]
                                                            WHERE   CompanyID = @CompanyID
                                                                    AND OrderServiceID = @OrderObjectID
                                                                    AND ( TGStatus = 1
                                                                          OR TGStatus = 5
                                                                        )";//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                                int count = db.SetCommand(strSelHasConfirmedSql
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)).ExecuteScalar<int>();
                                #endregion

                                if (count == 0)
                                {
                                    #region 没有进行中和待确认的TG订单被完成

                                    string strAddHisOrderSql = "INSERT INTO [HISTORY_ORDER] SELECT * FROM [ORDER] WHERE CompanyID = @CompanyID AND ID = @OrderID";
                                    int addOrderRes = db.SetCommand(strAddHisOrderSql
                                                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                , db.Parameter("@OrderID", item.OrderID, DbType.Int32)).ExecuteNonQuery();

                                    if (addOrderRes <= 0)
                                    {
                                        db.RollbackTransaction();
                                        return 0;
                                    }

                                    string strUpdateOrderStatusSql = @" UPDATE [ORDER] SET Status=@Status WHERE CompanyID = @CompanyID AND ID = @OrderID ";
                                    int updateOrderStatusRes = db.SetCommand(strUpdateOrderStatusSql
                                                                , db.Parameter("@Status", 2, DbType.Int32)//1:未完成 2已完成 3亿取消 4已中止
                                                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                , db.Parameter("@OrderID", item.OrderID, DbType.Int32)).ExecuteNonQuery();

                                    if (updateOrderStatusRes <= 0)
                                    {
                                        db.RollbackTransaction();
                                        return 0;
                                    }

                                    string strUpdateOrderCommodityStatusSql = @" UPDATE [TBL_ORDER_SERVICE] SET Status=@Status ,UpdaterID=@UpdaterID ,UpdateTime=@UpdateTime WHERE CompanyID = @CompanyID AND ID = @OrderObjectID ";
                                    int updateOrderCommodityStatusRes = db.SetCommand(strUpdateOrderCommodityStatusSql
                                                                , db.Parameter("@Status", 2, DbType.Int32)//1:未完成 2已完成 3亿取消 4已中止
                                                                , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                                                , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
                                                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                                    if (updateOrderCommodityStatusRes <= 0)
                                    {
                                        db.RollbackTransaction();
                                        return 0;
                                    }
                                    #endregion
                                }
                            }
                        }
                        #endregion
                    }
                    else
                    {
                        #region 商品
                        dt = new DataTable();

                        #region 查询基本数据
                        string strSelOrderServiceSql = @"SELECT  T1.CommodityID ,
                                                                T1.UndeliveredAmount ,
                                                                T1.DeliveredAmount ,
                                                                T1.Quantity ,
                                                                ISNULL(T2.Quantity, 0) AS Quantity2 ,
                                                                T3.IsConfirmed
                                                        FROM    [TBL_ORDER_COMMODITY] T1 WITH ( NOLOCK )
                                                                INNER JOIN [TBL_COMMODITY_DELIVERY] T2 WITH ( NOLOCK ) ON T1.ID = T2.OrderObjectID
                                                                INNER JOIN [COMMODITY] T3 WITH ( NOLOCK ) ON T1.CommodityID = T3.ID
                                                        WHERE   T1.CompanyID = @CompanyID
                                                                AND T2.ID = @GroupNo 
                                                                AND T1.Status = 1 
                                                                AND T2.Status = 5"; //1:未完成 2已完成 3亿取消 4已中止
                        dt = db.SetCommand(strSelOrderServiceSql
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)
                            , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)).ExecuteDataTable();



                        if (dt == null || dt.Rows.Count <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        int finishedCount = StringUtils.GetDbInt(dt.Rows[0]["DeliveredAmount"].ToString());
                        int executingCount = StringUtils.GetDbInt(dt.Rows[0]["UndeliveredAmount"].ToString());
                        int totalCount = StringUtils.GetDbInt(dt.Rows[0]["Quantity"].ToString());
                        int shouldDelivereCount = StringUtils.GetDbInt(dt.Rows[0]["Quantity2"].ToString());
                        bool isConfirmed = StringUtils.GetDbBool(dt.Rows[0]["IsConfirmed"].ToString());

                        int commodityID = StringUtils.GetDbInt(dt.Rows[0]["CommodityID"].ToString());
                        if (commodityID <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        int deliveryStatus = 2; //状态：1:未完成、2：已完成 、3：已取消、4:已终止、5：交付待确认

                        #region 修改TBL_COMMODITY_DELIVERY状态
                        string strAddHisDelivereSql = "INSERT INTO [HST_COMMODITY_DELIVERY] SELECT * FROM [TBL_COMMODITY_DELIVERY] WHERE CompanyID=@CompanyID AND ID=@GroupNo";
                        int hisDelivereCount = db.SetCommand(strAddHisDelivereSql
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)).ExecuteNonQuery();

                        if (hisDelivereCount <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        string updateDeliverSql = @"UPDATE  [TBL_COMMODITY_DELIVERY]
                                                    SET     Status = @Status ,
                                                            CDEndTime = @CDEndTime ,
                                                            UpdaterID = @UpdaterID ,
                                                            UpdateTime = @UpdateTime
                                                    WHERE   CompanyID = @CompanyID
                                                            AND ID = @GroupNo";

                        int updateDeliverRes = db.SetCommand(updateDeliverSql
                                            , db.Parameter("@Status", deliveryStatus, DbType.Int32)//状态：1:未完成、2：已完成 、3：已取消、4:已终止、5：交付待确认
                                            , db.Parameter("@CDEndTime", model.UpdateTime, DbType.DateTime2)
                                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                            , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)).ExecuteNonQuery();

                        //if (updateDeliverRes <= 0)
                        //{
                        //    db.RollbackTransaction();
                        //    return 0;
                        //}

                        #endregion

                        if (executingCount == 0 && (finishedCount == totalCount))
                        {
                            #region 查询订单下还有没有进行中和待确认的TG
                            string strSelHasConfirmedSql = @"SELECT  COUNT(0)
                                                            FROM    [TBL_COMMODITY_DELIVERY]
                                                            WHERE   CompanyID = @CompanyID
                                                                    AND OrderObjectID = @OrderObjectID
                                                                    AND ( Status = 1
                                                                          OR Status = 5
                                                                        )";
                            int count = db.SetCommand(strSelHasConfirmedSql
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)).ExecuteScalar<int>();
                            if (count <= 0)
                            {
                                #region 没有进行中和待确认的TG 订单被完成
                                string strAddHisOrderSql = "INSERT INTO [HISTORY_ORDER] SELECT * FROM [ORDER] WHERE CompanyID = @CompanyID AND ID = @OrderID";
                                int addOrderRes = db.SetCommand(strAddHisOrderSql
                                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                            , db.Parameter("@OrderID", item.OrderID, DbType.Int32)).ExecuteNonQuery();

                                if (addOrderRes <= 0)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }

                                string strUpdateOrderStatusSql = @" UPDATE [ORDER] SET Status=@Status WHERE CompanyID = @CompanyID AND ID = @OrderID ";
                                int updateOrderStatusRes = db.SetCommand(strUpdateOrderStatusSql
                                                            , db.Parameter("@Status", 2, DbType.Int32)//1:未完成 2已完成 3亿取消 4已中止
                                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                            , db.Parameter("@OrderID", item.OrderID, DbType.Int32)).ExecuteNonQuery();

                                if (updateOrderStatusRes <= 0)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }

                                string strUpdateOrderCommodityStatusSql = @" UPDATE [TBL_ORDER_COMMODITY] SET Status=@Status ,UpdaterID=@UpdaterID ,UpdateTime=@UpdateTime WHERE CompanyID = @CompanyID AND ID = @OrderObjectID ";
                                int updateOrderCommodityStatusRes = db.SetCommand(strUpdateOrderCommodityStatusSql
                                                            , db.Parameter("@Status", 2, DbType.Int32) //1:未完成 2:已完成 3:亿取消 4:已中止
                                                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                                            , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
                                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                            , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                                if (updateOrderCommodityStatusRes <= 0)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }
                                #endregion
                            }
                            #endregion
                        }
                        #endregion
                    }
                }
                db.CommitTransaction();
                return 1;
            }
        }
    }
}
