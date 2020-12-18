using BLToolkit.Data;
using HS.Framework.Common;
using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.Common;

namespace ClientAPI.DAL
{
    public class Order_DAL
    {
        #region 构造类实例
        public static Order_DAL Instance
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
            internal static readonly Order_DAL instance = new Order_DAL();
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
                                                  T1.ID AS OrderID ,ISNULL(T8.Name, '') AS ResponsiblePersonName ,T5.Name AS CustomerName ,T1.ProductType ,T1.Quantity ,T1.TotalOrigPrice ,
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
                                            LEFT JOIN [TBL_BUSINESS_CONSULTANT] T7 ON T1.ID = T7.MasterID AND T7.BusinessType = 1 AND ConsultantType = 1
                                            LEFT JOIN [ACCOUNT] T8 WITH ( NOLOCK ) ON T7.ConsultantID = T8.UserID 
                                    WHERE  T5.Available = 1 AND T1.CreateTime >= T6.StartTime AND T1.CompanyID = @CompanyID";





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
                        strSql += " AND (T3.Status !=3 OR T4.Status !=3) ";
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

                        if (operationModel.PaymentStatus > 0)
                        {
                            strSql += " AND T1.PaymentStatus = @PaymentStatus "; //支付状态 1：未支付 2：部分付 3：已支付 4：已退款 5:免支付
                        }
                    }

                    if (operationModel.CustomerID > 0)
                    {
                        strSql += " AND T1.CustomerID = @CustomerID";
                    }

                    string strCountSql = string.Format(strSql, " count(0) ");

                    string strgetListSql = "select * from( " + string.Format(strSql, fileds) + " ) a where  rowNum between  " + ((pageIndex - 1) * pageSize + 1) + " and " + pageIndex * pageSize;

                    recordCount = db.SetCommand(strCountSql
                        , db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)
                        , db.Parameter("@CreateTime", operationModel.CreateTime, DbType.DateTime)
                        , db.Parameter("@Status", operationModel.Status, DbType.Int32)
                        , db.Parameter("@PaymentStatus", operationModel.PaymentStatus, DbType.Int32)
                        , db.Parameter("@CustomerID", operationModel.CustomerID, DbType.Int32)).ExecuteScalar<int>();

                    if (recordCount < 0)
                    {
                        return null;
                    }

                    list = db.SetCommand(strgetListSql
                        , db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)
                        , db.Parameter("@CreateTime", operationModel.CreateTime, DbType.DateTime)
                        , db.Parameter("@Status", operationModel.Status, DbType.Int32)
                        , db.Parameter("@PaymentStatus", operationModel.PaymentStatus, DbType.Int32)
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
                                T1.RefundSumAmount , 
                                ISNULL(T1.PaymentStatus, 2) AS PaymentStatus ,
                                ISNULL(T3.SubServiceIDs, '') AS SubServiceIDs ,
                                T3.IsPast ,
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
                                LEFT JOIN [CUSTOMER] T5 WITH ( NOLOCK ) ON T1.CustomerID = T5.UserID
                                LEFT JOIN [ACCOUNT] T6 WITH ( NOLOCK ) ON T6.UserID = T1.CreatorID
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
                                T1.UnPaidPrice ,
                                T1.RefundSumAmount ,
                                ISNULL(T1.PaymentStatus, 2) AS PaymentStatus ,
                                '' AS SubServiceIDs ,
                                0 as IsPast ,
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
                                LEFT JOIN [CUSTOMER] T5 WITH ( NOLOCK ) ON T1.CustomerID = T5.UserID
                                LEFT JOIN [ACCOUNT] T6 WITH ( NOLOCK ) ON T6.UserID = T1.CreatorID
                                LEFT JOIN [BRANCH] T10 WITH ( NOLOCK ) ON T1.BranchID = T10.ID
                                  WHERE T1.CompanyID=@CompanyID AND T3.ID = @orderObjectID AND T1.ProductType = @ProductType";
                }

                model = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                , db.Parameter("@orderObjectID", orderObjectID, DbType.Int32)
                , db.Parameter("@ProductType", productType, DbType.Int32)).ExecuteObject<GetOrderDetail_Model>();
                if (model != null && model.OrderID > 0)
                {
                    string strSelSalesSql = @" SELECT  T2.UserID AS SalesPersonID ,
                                                    T2.Name AS SalesName
                                            FROM    [TBL_BUSINESS_CONSULTANT] T1 WITH ( NOLOCK )
                                                    INNER JOIN [ACCOUNT] T2 WITH ( NOLOCK ) ON T1.ConsultantID = T2.UserID
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.BusinessType = 1
                                                    AND MasterID = @MasterID
                                                    AND ConsultantType = @ConsultantType ";

                    DataTable dt = db.SetCommand(strSelSalesSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                    , db.Parameter("@MasterID", model.OrderID, DbType.Int32)
                                    , db.Parameter("@ConsultantType", 1, DbType.Int32)).ExecuteDataTable();

                    if (dt != null && dt.Rows.Count > 0)
                    {
                        model.ResponsiblePersonName = StringUtils.GetDbString(dt.Rows[0]["SalesName"].ToString());
                        model.ResponsiblePersonID = StringUtils.GetDbInt(dt.Rows[0]["SalesPersonID"].ToString());
                    }

                    model.SalesList = db.SetCommand(strSelSalesSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                    , db.Parameter("@MasterID", model.OrderID, DbType.Int32)
                                    , db.Parameter("@ConsultantType", 2, DbType.Int32)).ExecuteList<Sales_Model>();
                }
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

                    if (status < 1)
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

        public List<TGList_Model> GetUnconfirmTreatGroup(int companyID, int customerID, int type = -1)
        {
            List<TGList_Model> list = new List<TGList_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = "";
                string strServiceSql = @"SELECT  T3.OrderID ,
                                                T1.OrderServiceID AS OrderObjectID ,
                                                0 AS ProductType ,
                                                T1.GroupNo ,
                                                T3.TGTotalCount AS TotalCount ,
                                                1 AS FinishedCount ,
                                                T3.ServiceName AS ProductName ,
                                                T1.TGStartTime ,
                                                T5.Name AS ServicePICName 
                                        FROM    [TBL_TREATGROUP] T1 WITH ( NOLOCK )
                                                INNER JOIN [Order] T2 WITH ( NOLOCK ) ON T1.OrderID = T2.ID
                                                INNER JOIN [TBL_ORDER_SERVICE] T3 WITH ( NOLOCK ) ON T1.OrderServiceID = T3.ID
                                                INNER JOIN [BRANCH] T4 WITH ( NOLOCK ) ON T2.BranchID = T4.ID 
                                                INNER JOIN [ACCOUNT] T5 WITH(NOLOCK) ON T1.ServicePIC=T5.UserID 
                                        WHERE   T1.TGStatus = 5
                                                AND T2.OrderTime > T4.StartTime
                                                AND T2.RecordType = 1
                                                AND T1.CompanyID = @CompanyID
                                                AND T2.CustomerID = @CustomerID ";
                //UNION ALL
                string strCommoditySql = @" SELECT distinct T3.OrderID ,
                                                    T1.OrderObjectID ,
                                                    1 AS ProductType ,
                                                    T1.ID AS GroupNo ,
                                                    T3.Quantity AS TotalCount ,
                                                    T1.Quantity AS FinishedCount ,
                                                    T3.CommodityName AS ProductName ,
                                                    T1.CDStartTime AS TGStartTime ,
                                                    T5.Name AS ServicePICName 
                                            FROM    [TBL_COMMODITY_DELIVERY] T1 WITH ( NOLOCK )
                                                    INNER JOIN [Order] T2 WITH ( NOLOCK ) ON T1.OrderID = T2.ID
                                                    INNER JOIN [TBL_ORDER_COMMODITY] T3 WITH ( NOLOCK ) ON T1.OrderObjectID = T3.ID
                                                    INNER JOIN [BRANCH] T4 WITH ( NOLOCK ) ON T2.BranchID = T4.ID 
                                                    INNER JOIN [ACCOUNT] T5 WITH(NOLOCK) ON T1.ServicePIC=T5.UserID 
                                            WHERE   T1.Status = 5
                                                    AND T2.OrderTime > T4.StartTime
                                                    AND T2.RecordType = 1
                                                    AND T1.CompanyID = @CompanyID
                                                    AND T2.CustomerID = @CustomerID ";

                if (type == 0)
                {
                    strSql = strServiceSql;
                }
                else if (type == 1)
                {
                    strSql = strCommoditySql;
                }
                else
                {
                    strSql = strServiceSql + " UNION ALL " + strCommoditySql;
                }

                list = db.SetCommand(strSql
                     , db.Parameter("@CompanyID", companyID, DbType.Int32)
                     , db.Parameter("@CustomerID", customerID, DbType.Int32)).ExecuteList<TGList_Model>();

                return list;
            }
        }

        public List<Treatment> getTreatmentListByGroupNO(long groupNO, int CompanyID)
        {
            List<Treatment> list = new List<Treatment>();
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT a.ExecutorID,a.SubServiceID,a.StartTime,a.ID as TreatmentID,b.Name as ExecutorName,c.SubServiceName ,a.status,a.IsDesignated
                                FROM dbo.TREATMENT a 
                                INNER JOIN [ACCOUNT] b ON a.ExecutorID=b.UserID
                                LEFT JOIN [TBL_SUBSERVICE] c ON a.SubServiceID=c.ID 
                                WHERE a.CompanyID=@CompanyID AND a.GroupNo=@GroupNo AND a.status<>3 AND a.status<>4";
                list = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@GroupNo", groupNO, DbType.Int64)).ExecuteList<Treatment>();
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

                    //AND T1.Status = 1  这个条件暂时去掉 未完成和已终止的都可以确认
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
                                                                T2.ServiceName,
                                                                T1.Remark,
																T2.VisitTime
                                                        FROM    [TBL_ORDER_SERVICE] T1 WITH(NOLOCK)
                                                        INNER JOIN [SERVICE] T2 WITH(NOLOCK) ON T1.ServiceID=T2.ID 
                                                        INNER JOIN [TBL_TREATGROUP] T3 WITH ( NOLOCK ) ON T1.ID = T3.OrderServiceID 
                                                        WHERE   T1.CompanyID = @CompanyID
                                                                AND T1.ID = @OrderObjectID 
                                                                AND T3.GroupNo=@GroupNo 
                                                                AND (T1.Status = 1 OR T1.Status = 4)
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
                        //int responsiblePersonID = StringUtils.GetDbInt(dt.Rows[0]["responsiblePersonID"].ToString());
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
                                                                AND (T1.Status = 1 OR T1.Status = 4)
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

        public GetOrderCount_Model getOrderCount(OrderCountOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSqlTotal = @" select COUNT(*) Total 
                                    from  [ORDER] T1  
                                    RIGHT JOIN [BRANCH] T2 WITH(NOLOCK) 
                                    ON T1.BranchID=T2.ID 
                                    where T1.CustomerID = @CustomerID and T1.CompanyID=@CompanyID and T1.RecordType = 1 AND T1.CreateTime>=T2.StartTime ";

                GetOrderCount_Model res = new GetOrderCount_Model();
                res.Total = db.SetCommand(strSqlTotal, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();

                string strSqlUnpaid = @" select  COUNT(*) Unpaid 
                                    from [order] T1 
                                    RIGHT JOIN [BRANCH] T2 WITH(NOLOCK) 
                                    ON T1.BranchID=T2.ID 
                                    where T1.CustomerID =@CustomerID and T1.RecordType = 1 AND (T1.PaymentStatus = 1 OR T1.PaymentStatus = 2 )  AND T1.CreateTime>=T2.StartTime AND T1.CompanyID = @CompanyID ";

                res.Unpaid = db.SetCommand(strSqlUnpaid, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();

                string strSqlUncompletedService = @"   select COUNT(*) UncompletedService
                                    from [ORDER] T1
                                    RIGHT JOIN [BRANCH] T2 WITH(NOLOCK) 
                                    ON T1.BranchID=T2.ID  
                                    where RecordType = 1 AND T1.Status <> 4 AND T1.Status <> 2  and T1.ProductType = 0  and T1.CustomerID =@CustomerID AND T1.CreateTime>=T2.StartTime AND T1.CompanyID = @CompanyID ";

                res.UncompletedService = db.SetCommand(strSqlUncompletedService, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();

                string strSqlUndeliveredCommodity = @"  select COUNT(*) UndeliveredCommodity
                                from [ORDER] T1
                                RIGHT JOIN [BRANCH] T2 WITH(NOLOCK) 
                                ON T1.BranchID=T2.ID 
                                where  T1.ProductType = 1 and T1.RecordType = 1 AND T1.Status <> 4 AND T1.Status <> 2 and T1.CustomerID =@CustomerID AND T1.CreateTime>=T2.StartTime AND T1.CompanyID =@CompanyID ";

                res.UndeliveredCommodity = db.SetCommand(strSqlUndeliveredCommodity, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();


                return res;
            }
        }

        public GetTGDetail_Model getTGDetail(long GroupNo, int companyId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"select T1.GroupNo , T1.TGStartTime,T1.TGEndTime,T1.TGStatus,T1.Remark,T2.BranchName from TBL_TREATGROUP T1 INNER JOIN dbo.BRANCH T2
                                  ON T1.BranchID=T2.ID AND T1.CompanyID=T2.CompanyID WHERE T1.GroupNo =@GroupNo  and T1.CompanyID=@CompanyID";



                GetTGDetail_Model model = db.SetCommand(strSql
                     , db.Parameter("@GroupNo", GroupNo, DbType.Int64)
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteObject<GetTGDetail_Model>();

                return model;
            }
        }

        public GetTreatmentDetail_Model GetTreatmentDetail(UtilityOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT ID,Status,Remark,StartTime,FinishTime FROM dbo.TREATMENT WHERE CompanyID=@CompanyID AND ID=@ID";
                return db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@ID", model.TreatmentID, DbType.Int32)).ExecuteObject<GetTreatmentDetail_Model>();
            }
        }

        public int getUnpaidOrderCount(int customerId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  COUNT(0)
                                 FROM    [ORDER] T1 WITH ( NOLOCK )
                                         LEFT JOIN [CUSTOMER] T5 WITH ( NOLOCK ) ON T1.CustomerID = T5.UserID
                                         RIGHT JOIN [BRANCH] T6 WITH ( NOLOCK ) ON T1.BranchID = T6.ID
                                 WHERE   T5.Available = 1
                                         AND T1.CreateTime >= T6.StartTime
                                         AND ( T1.PaymentStatus = 1
                                               OR T1.PaymentStatus = 2
                                             )
                                         AND (T1.Status <> 3 and T1.Status <> 4)and T1.UnPaidPrice > 0
                                         AND T1.CustomerID = @CustomerID";

                int count = db.SetCommand(strSql, db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteScalar<int>();
                return count;
            }
        }

        public int getUnconfirmedOrderCount(int companyID, int customerId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  SUM(cnt)
                                    FROM    ( SELECT  COUNT(0) cnt
                                                FROM    [TBL_TREATGROUP] T1 WITH ( NOLOCK )
                                                        INNER JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T2.ID = T1.OrderServiceID
                                                        INNER JOIN [ORDER] T3 WITH ( NOLOCK ) ON T3.ID = T2.OrderID
                                                        INNER JOIN [BRANCH] T4 WITH ( NOLOCK ) ON T4.ID = T2.BranchID
                                                WHERE   T2.CompanyID = @CompanyID
                                                        AND T2.CustomerID = @CustomerID
                                                        AND T1.TGStatus = 5
                                                        AND T3.OrderTime > T4.StartTime
                                                UNION ALL
                                                SELECT  COUNT(0) cnt
                                                FROM    [TBL_COMMODITY_DELIVERY] T1 WITH ( NOLOCK )
                                                        INNER JOIN [TBL_ORDER_COMMODITY] T2 WITH ( NOLOCK ) ON T2.ID = T1.OrderObjectID
                                                        INNER JOIN [ORDER] T3 WITH ( NOLOCK ) ON T3.ID = T2.OrderID
                                                        INNER JOIN [BRANCH] T4 WITH ( NOLOCK ) ON T4.ID = T2.BranchID
                                                WHERE   T2.CompanyID = @CompanyID
                                                        AND T2.CustomerID = @CustomerID
                                                        AND T1.Status = 5
                                                        AND T3.OrderTime > T4.StartTime
                                            ) a
                                                             ";

                int count = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteScalar<int>();
                return count;
            }
        }

        public List<GetUnfinishOrder_Model> getUnfinishOrder(int companyId, int customerId, int productType)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = "";
                string strServiceSql = @" SELECT  T2.OrderID ,
                                                T2.ServiceName AS ProductName,
                                                T1.OrderTime ,
                                                T3.Name AS ResponsiblePersonName ,
                                                T2.TGExecutingCount,
                                                T2.TGFinishedCount ,
                                                T2.TGTotalCount ,
                                                T1.ProductType ,
												T1.BranchID,
												T2.ID OrderObjectID
                                        FROM    [ORDER] T1
                                                INNER JOIN [TBL_ORDER_SERVICE] T2 ON T1.ID = T2.OrderID
                                                                                     AND T2.Status = 1
												left join [TBL_BUSINESS_CONSULTANT] T6 
                                                ON T1.ID = T6.MasterID AND T6.BusinessType = 1 AND T6.ConsultantType = 1
                                                LEFT JOIN [ACCOUNT] T3 ON T6.ConsultantID = T3.UserID
                                                LEFT JOIN [ORDER] T4 ON T2.OrderID = T4.ID
                                                LEFT JOIN [BRANCH] T5 ON T2.BranchID = T5.ID
                                        WHERE   T1.Status = 1
                                                AND T1.CompanyID = @CompanyID
                                                AND T1.CustomerID = @CustomerID
                                                AND T4.OrderTime > T5.StartTime ";

                string strCommoditySql = @" SELECT  T2.OrderID ,
                                                    T2.CommodityName AS ProductName ,
                                                    T1.OrderTime ,
                                                    T3.Name AS ResponsiblePersonName ,
                                                    T2.UndeliveredAmount AS TGExecutingCount,
                                                    T2.DeliveredAmount AS TGFinishedCount ,
                                                    T2.Quantity AS TGTotalCount ,
                                                    T1.ProductType,
												    T1.BranchID,
												    T2.ID OrderObjectID
                                            FROM    [ORDER] T1
                                                    INNER JOIN [TBL_ORDER_COMMODITY] T2 ON T1.ID = T2.OrderID
                                                                                           AND T2.Status = 1
												left join [TBL_BUSINESS_CONSULTANT] T6 
                                                ON T1.ID = T6.MasterID AND T6.BusinessType = 1 AND T6.ConsultantType = 1
                                                    LEFT JOIN [ACCOUNT] T3 ON T6.ConsultantID = T3.UserID
                                                    LEFT JOIN [ORDER] T4 ON T2.OrderID = T4.ID
                                                    LEFT JOIN [BRANCH] T5 ON T2.BranchID = T5.ID
                                            WHERE   T1.Status = 1
                                                    AND T1.CompanyID = @CompanyID
                                                    AND T1.CustomerID = @CustomerID
                                                    AND T4.OrderTime > T5.StartTime ";

                if (productType == 1)
                {
                    strSql = strCommoditySql;
                }
                else if (productType == 0)
                {
                    strSql = strServiceSql;
                }
                else
                {
                    strSql = strServiceSql + " UNION ALL " + strCommoditySql;
                }

                List<GetUnfinishOrder_Model> list = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteList<GetUnfinishOrder_Model>();
                return list;
            }
        }

        public ObjectResult<List<int>> addNewOrder(OrderOperation_Model model)
        {
            ObjectResult<List<int>> listres = new ObjectResult<List<int>>();
            List<OrderAddRes_Model> list = new List<OrderAddRes_Model>();
            bool issuccess = true;
            int orderid = 0;
            int orderObjectID = 0;

            string qtymsg = "";


            listres.Code = "1";
            listres.Message = "";
            listres.Data = null;

            if (model != null && model.OrderList != null)
            {
                using (DbManager db = new DbManager())
                {
                    try
                    {
                        db.BeginTransaction();
                        int customerResponsiblePersonID = 0;
                        int customerSalesPersonID = 0;

                        foreach (OrderDetailOperation_Model item in model.OrderList)
                        {
                            string subServiceIDs = "";
                            string[] arrSubServiceCodes = null;
                            List<int> arrSubServiceID = new List<int>();
                            if (string.IsNullOrWhiteSpace(item.CartId))
                            {
                                listres.Code = "2";
                                listres.Message = "参数错误";
                                listres.Data = null;
                                return listres;
                            }

                            if (item.BranchID <= 0)
                            {
                                listres.Code = "2";
                                listres.Message = "参数错误";
                                listres.Data = null;
                                return listres;
                            }

                            #region 购物车转订单
                            if (!string.IsNullOrWhiteSpace(item.CartId))
                            {
                                string strSqlOppCheck = @"select CartID,Quantity from [TBL_CART] where CartID=@CartID and Status = 1";
                                DataTable dt = db.SetCommand(strSqlOppCheck, db.Parameter("@CartID", item.CartId, DbType.String)).ExecuteDataTable();

                                if (dt == null || dt.Rows.Count != 1)
                                {
                                    db.RollbackTransaction();
                                    listres.Code = "5";
                                    listres.Message = "购物车已经转换订单";
                                    listres.Data = null;
                                    return listres;
                                }

                                item.CartId = StringUtils.GetDbString(dt.Rows[0]["CartID"]);
                                item.Quantity = StringUtils.GetDbInt(dt.Rows[0]["Quantity"]);

                                #region 更改Cart表状态
                                string strSqlDel = @"update [TBL_CART] set Status=@Status,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime where CartID=@CartID";
                                int delrs = db.SetCommand(strSqlDel,
                                db.Parameter("@Status", 2, DbType.Int32),
                                db.Parameter("@UpdaterID", model.CustomerID, DbType.Int32),
                                db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2),
                                db.Parameter("@CartID", item.CartId, DbType.String)).ExecuteNonQuery();
                                #endregion

                                if (delrs <= 0)
                                {
                                    db.RollbackTransaction();
                                    listres.Code = "2";
                                    listres.Message = "strSqlDel失败";
                                    listres.Data = null;
                                    return listres;
                                }
                            }
                            #endregion

                            #region 计算价格,获取proID
                            Commodity_Model com_model = new Commodity_Model();
                            if (item.ProductType == 1)
                            {
                                string strSqlSelectProId = @"select T1.ID ,T1.MarketingPolicy ,T1.UnitPrice ,T1.PromotionPrice,'' AS SubServiceCodes ,T1.DiscountID ,T1.CommodityName 
                                                            FROM [COMMODITY] T1 WITH(NOLOCK) 
                                                            INNER JOIN [TBL_MARKET_RELATIONSHIP] T2 WITH(NOLOCK) ON T1.Code=T2.Code AND T2.Type=1 AND T2.Available=1 
                                                            WHERE T1.CompanyID=@CompanyID AND T1.Code=@Code AND T1.Available=1 AND T2.BranchID=@BranchID 
                                                            ORDER BY T1.CreateTime DESC";
                                com_model = db.SetCommand(strSqlSelectProId,
                                db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                db.Parameter("@Code", item.ProductCode, DbType.Int64),
                                db.Parameter("@BranchID", item.BranchID, DbType.Int32)).ExecuteObject<Commodity_Model>();
                            }
                            else
                            {
                                string strSqlSelectProId = @"select T1.ID ,T1.MarketingPolicy ,T1.UnitPrice ,T1.PromotionPrice,T1.SubServiceCodes ,T1.DiscountID ,T1.ServiceName AS CommodityName ,T1.CourseFrequency ,T1.ExpirationDate    
                                                            FROM [SERVICE] T1 WITH(NOLOCK) 
                                                            INNER JOIN [TBL_MARKET_RELATIONSHIP] T2 WITH(NOLOCK) ON T1.Code=T2.Code AND T2.Type=0 AND T2.Available=1 
                                                            WHERE T1.CompanyID=@CompanyID AND T1.Code=@Code AND T1.Available=1 AND T2.BranchID=@BranchID 
                                                            ORDER BY T1.CreateTime DESC";
                                com_model = db.SetCommand(strSqlSelectProId,
                                db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                db.Parameter("@Code", item.ProductCode, DbType.Int64),
                                db.Parameter("@BranchID", item.BranchID, DbType.Int32)).ExecuteObject<Commodity_Model>();

                                #region 拿出子服务编号
                                if (!string.IsNullOrEmpty(com_model.SubServiceCodes))
                                {
                                    arrSubServiceCodes = com_model.SubServiceCodes.Split(new string[] { "|" }, StringSplitOptions.RemoveEmptyEntries);

                                    #region 根据SubServiceCode获取SubServiceID
                                    foreach (var codes in arrSubServiceCodes)
                                    {
                                        string StrSqlGetSubServiceID = @"SELECT ISNULL(MAX(ID),0) AS SubServiceID FROM [TBL_SubService] WHERE SubServiceCode=@SubServiceCode AND Available=1";
                                        int subServiceID = db.SetCommand(StrSqlGetSubServiceID, db.Parameter("@SubServiceCode", codes, DbType.Int64)).ExecuteScalar<int>();
                                        if (subServiceID <= 0)
                                        {
                                            db.RollbackTransaction();
                                            listres.Code = "2";
                                            listres.Message = "StrSqlGetSubServiceID添加失败";
                                            listres.Data = null;
                                            return listres;
                                        }
                                        subServiceIDs += "|" + subServiceID.ToString();
                                        arrSubServiceID.Add(subServiceID);
                                    }

                                    #endregion

                                    subServiceIDs += "|";
                                }

                                #endregion


                            }
                            if (com_model == null)
                            {
                                listres.Code = "2";
                                listres.Message = "strSqlInsertOrder添加失败";
                                listres.Data = null;
                                return listres;
                            }

                            item.ProductID = com_model.ID;
                            // 服务器获取数据库A价格 
                            decimal totalOrigPriceFromService = Math.Round(com_model.UnitPrice * (decimal)item.Quantity, 2);
                            if (item.TotalOrigPrice != totalOrigPriceFromService)
                            {
                                // 传来的A价格与数据库中A价格不符合,有人变动数据 
                                listres.Code = "-2";//前台需要刷新接口,获取新价格 
                                listres.Message = "价格变动";
                                listres.Data = null;
                                return listres;
                            }
                            item.TotalOrigPrice = totalOrigPriceFromService;

                            #region 计算价格
                            decimal totalCalcPriceFromService = 0;//服务器计算B价格 
                            //按等级折扣 
                            if (com_model.MarketingPolicy == 1)
                            {
                                //查询等级折扣 
                                string strSelectDiscount = @"SELECT ISNULL(T1.Discount, 1) Discount FROM [TBL_CARD_DISCOUNT] T1 WITH ( NOLOCK ) WHERE T1.DiscountID=@DiscountID AND T1.CardID=@CardID ";
                                decimal dicount = db.SetCommand(strSelectDiscount
                                , db.Parameter("@DiscountID", com_model.DiscountID, DbType.Int32)
                                , db.Parameter("@CardID", item.CardID, DbType.Int32)).ExecuteScalar<decimal>();


                                if (dicount > 0)
                                {
                                    totalCalcPriceFromService = Math.Round(com_model.UnitPrice * dicount * (decimal)item.Quantity, 2);
                                }
                                else
                                {
                                    totalCalcPriceFromService = Math.Round(com_model.UnitPrice * (decimal)item.Quantity, 2);
                                }
                            }
                            //促销价销售 
                            else if (com_model.MarketingPolicy == 2)
                            {
                                string strLevelPolicy = @" SELECT  COUNT(0)
                                                            FROM    TBL_CUSTOMER_CARD T1 WITH ( NOLOCK )
                                                                    INNER JOIN [MST_CARD] T2 WITH ( NOLOCK ) ON T1.CardID = T2.ID
                                                                    INNER JOIN [MST_CARD_BRANCH] T3 WITH ( NOLOCK ) ON T2.ID = T3.CardID
                                                            WHERE   T1.UserID = @UserID
                                                                    AND T3.BranchID = @BranchID ";
                                int branchCardCount = db.SetCommand(strLevelPolicy
                                    , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                    , db.Parameter("@BranchID", item.BranchID, DbType.Int32)).ExecuteScalar<int>();

                                if (branchCardCount > 0 && item.CardID > 0)
                                {
                                    totalCalcPriceFromService = Math.Round(com_model.PromotionPrice * (decimal)item.Quantity, 2);
                                }
                                else
                                {
                                    totalCalcPriceFromService = Math.Round(com_model.UnitPrice * (decimal)item.Quantity, 2);
                                }
                            }
                            //原价销售 
                            else
                            {
                                totalCalcPriceFromService = Math.Round(com_model.UnitPrice * (decimal)item.Quantity, 2);
                            }

                            if (item.TotalCalcPrice != totalCalcPriceFromService)//传来的B价格与计算的B价格不符合 
                            {
                                listres.Code = "-2";//前台需要刷新接口,获取新价格 
                                listres.Message = "价格变动";
                                listres.Data = null;
                                return listres;
                            }

                            item.TotalCalcPrice = totalCalcPriceFromService;

                            //实际售价赋值 
                            if (item.TotalSalePrice < 0)
                            {
                                item.TotalSalePrice = item.TotalCalcPrice;
                            }
                            #endregion

                            #endregion

                            #region 订单主表操作
                            int OrderSource = 0;//0:普通下单 1:需求转换订单 2:购物车转换订单 3:预约转换订单
                            string SourceID = "";

                            if (!string.IsNullOrWhiteSpace(item.CartId))
                            {
                                OrderSource = 2;
                                SourceID = item.CartId;
                                item.IsPast = false;
                            }
                            else
                            {
                                OrderSource = 0;
                                SourceID = "";
                            }

                            string strSqlInsertOrder = @"insert into [ORDER] (CompanyID,BranchID,CustomerID,OrderTime,ProductType,Quantity,TotalOrigPrice,TotalCalcPrice,TotalSalePrice,Status,OrderSource,SourceID,CreatorID,CreateTime,UnPaidPrice,PaymentStatus)
                            values (@CompanyID,@BranchID,@CustomerID,@OrderTime,@ProductType,@Quantity,@TotalOrigPrice,@TotalCalcPrice,@TotalSalePrice,@Status,@OrderSource,@SourceID,@CreatorID,@CreateTime,@UnPaidPrice,@PaymentStatus);select @@IDENTITY";

                            object objIDs = DBNull.Value;
                            if (!string.IsNullOrEmpty(subServiceIDs) && subServiceIDs != "")
                            {
                                objIDs = subServiceIDs;
                            }

                            int orderStatus = 1;

                            if (item.ProductType == 0 && item.TGTotalCount > 0 && item.TGTotalCount == item.TGPastCount)
                            {
                                orderStatus = 2;
                            }

                            orderid = db.SetCommand(strSqlInsertOrder
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@BranchID", item.BranchID, DbType.Int32)
                            , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                //, db.Parameter("@ResponsiblePersonID", item.ResponsiblePersonID == 0 ? (object)DBNull.Value : item.ResponsiblePersonID, DbType.Int32)
                            , db.Parameter("@OrderTime", model.OrderTime, DbType.DateTime2)
                            , db.Parameter("@ProductType", item.ProductType, DbType.Int32)
                            , db.Parameter("@Quantity", item.Quantity, DbType.Int32)
                            , db.Parameter("@TotalOrigPrice", item.TotalOrigPrice, DbType.Decimal)
                            , db.Parameter("@TotalCalcPrice", item.TotalCalcPrice, DbType.Decimal)
                            , db.Parameter("@TotalSalePrice", item.TotalSalePrice, DbType.Decimal)
                            , db.Parameter("@Status", orderStatus, DbType.Int32)// 订单状态：1:未完成、2：已完成 、3：已取消、4:已终止
                            , db.Parameter("@OrderSource", OrderSource, DbType.Int32)
                            , db.Parameter("@SourceID", SourceID, DbType.String)
                            , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                            , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                //, db.Parameter("@SalesID", item.SalesID == 0 ? (object)DBNull.Value : item.SalesID, DbType.Int32)
                            , db.Parameter("@UnPaidPrice", item.TotalSalePrice, DbType.Decimal)
                            , db.Parameter("@PaymentStatus", 1, DbType.Int32) // 支付状态 1：未支付 2：部分付 3：已支付
                            ).ExecuteScalar<int>();
                            #endregion

                            if (orderid <= 0)
                            {
                                db.RollbackTransaction();
                                listres.Code = "2";
                                listres.Message = "strSqlInsertOrder添加失败";
                                listres.Data = null;
                                return listres;
                            }

                            #region 获取UserCardNo
                            string selUserCardNoSql = @"SELECT  UserCardNo
                                                        FROM    [TBL_CUSTOMER_CARD] WITH ( NOLOCK )
                                                        WHERE   CompanyID = @CompanyID
                                                                AND CardID = @CardID
                                                                AND UserID = @CustomerID";
                            string userCardNo = db.SetCommand(selUserCardNoSql
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@CardID", item.CardID, DbType.Int32)
                                , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                ).ExecuteScalar<string>();
                            #endregion

                            if (item.ProductType == 0)
                            {
                                #region 服务操作

                                item.TGTotalCount = com_model.CourseFrequency * item.Quantity;
                                item.Expirationtime = model.OrderTime.AddDays(com_model.ExpirationDate);

                                string strAddOrderServiceSql = @"INSERT INTO [TBL_ORDER_SERVICE]( CompanyID ,BranchID  ,CustomerID ,OrderID ,UserCardNo ,ServiceCode ,ServiceID ,ServiceName ,Quantity ,SumOrigPrice ,SumCalcPrice ,SumSalePrice ,Remark ,Status ,SubServiceIDs ,IsPast ,TGPastCount ,TGExecutingCount ,TGFinishedCount ,TGLastTime ,TGTotalCount ,Available ,CreatorID ,CreateTime ,Expirationtime ) 
VALUES ( @CompanyID ,@BranchID  ,@CustomerID ,@OrderID ,@UserCardNo ,@ServiceCode ,@ServiceID ,@ServiceName ,@Quantity ,@SumOrigPrice ,@SumCalcPrice ,@SumSalePrice ,@Remark ,@Status ,@SubServiceIDs ,@IsPast ,@TGPastCount ,@TGExecutingCount ,@TGFinishedCount ,@TGLastTime ,@TGTotalCount ,@Available ,@CreatorID ,@CreateTime ,@Expirationtime ) ;select @@IDENTITY";

                                orderObjectID = db.SetCommand(strAddOrderServiceSql
                                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                    , db.Parameter("@BranchID", item.BranchID, DbType.Int32)
                                    //, db.Parameter("@ResponsiblePersonID", item.ResponsiblePersonID == 0 ? (object)DBNull.Value : item.ResponsiblePersonID, DbType.Int32)
                                                    , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                                    , db.Parameter("@OrderID", orderid, DbType.Int32)
                                                    , db.Parameter("@UserCardNo", userCardNo, DbType.String)
                                                    , db.Parameter("@ServiceCode", item.ProductCode, DbType.Int64)
                                                    , db.Parameter("@ServiceID", item.ProductID, DbType.Int32)
                                                    , db.Parameter("@ServiceName", com_model.CommodityName, DbType.String)
                                                    , db.Parameter("@Quantity", item.Quantity, DbType.Int32)
                                                    , db.Parameter("@SumOrigPrice", item.TotalOrigPrice, DbType.Decimal)
                                                    , db.Parameter("@SumCalcPrice", item.TotalCalcPrice, DbType.Decimal)
                                                    , db.Parameter("@SumSalePrice", item.TotalSalePrice, DbType.Decimal)
                                                    , db.Parameter("@Remark", item.Remark, DbType.String)
                                                    , db.Parameter("@Status", orderStatus, DbType.Int32)// 状态：1:未完成、2：已完成 、3：已取消、4:已终止
                                                    , db.Parameter("@SubServiceIDs", objIDs, DbType.String)
                                                    , db.Parameter("@IsPast", item.IsPast, DbType.Boolean)
                                                    , db.Parameter("@TGExecutingCount", 0, DbType.Int32)
                                                    , db.Parameter("@TGFinishedCount", item.TGPastCount, DbType.Int32)
                                                    , db.Parameter("@TGTotalCount", item.TGTotalCount, DbType.Int32)
                                                    , db.Parameter("@TGPastCount", item.TGPastCount, DbType.Int32)
                                                    , db.Parameter("@TGLastTime", null, DbType.DateTime2)
                                                    , db.Parameter("@Available", true, DbType.Boolean)
                                                    , db.Parameter("@Expirationtime", item.Expirationtime, DbType.DateTime2)
                                                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                                                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)).ExecuteScalar<int>();

                                #endregion
                            }
                            else
                            {
                                #region 商品操作

                                #region 插入商品订单表
                                string strAddOrderCommodity = @"INSERT INTO dbo.TBL_ORDER_COMMODITY( CompanyID ,BranchID ,CustomerID ,OrderID ,UserCardNo ,CommodityCode ,CommodityID ,CommodityName ,Quantity ,SumOrigPrice ,SumCalcPrice ,SumSalePrice ,Remark ,Status ,DeliveredAmount ,UndeliveredAmount ,ReturnedAmount ,CreatorID ,CreateTime ) 
VALUES ( @CompanyID ,@BranchID ,@CustomerID ,@OrderID ,@UserCardNo ,@CommodityCode ,@CommodityID ,@CommodityName ,@Quantity ,@SumOrigPrice ,@SumCalcPrice ,@SumSalePrice ,@Remark ,@Status ,@DeliveredAmount ,@UndeliveredAmount ,@ReturnedAmount ,@CreatorID ,@CreateTime ) ;select @@IDENTITY";

                                orderObjectID = db.SetCommand(strAddOrderCommodity
                                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                    , db.Parameter("@BranchID", item.BranchID, DbType.Int32)
                                    //, db.Parameter("@ResponsiblePersonID", item.ResponsiblePersonID == 0 ? (object)DBNull.Value : item.ResponsiblePersonID, DbType.Int32)
                                                    , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                                    , db.Parameter("@OrderID", orderid, DbType.Int32)
                                                    , db.Parameter("@UserCardNo", userCardNo, DbType.String)
                                                    , db.Parameter("@CommodityCode", item.ProductCode, DbType.Int64)
                                                    , db.Parameter("@CommodityID", item.ProductID, DbType.Int32)
                                                    , db.Parameter("@CommodityName", com_model.CommodityName, DbType.String)
                                                    , db.Parameter("@Quantity", item.Quantity, DbType.Int32)
                                                    , db.Parameter("@SumOrigPrice", item.TotalOrigPrice, DbType.Decimal)
                                                    , db.Parameter("@SumCalcPrice", item.TotalCalcPrice, DbType.Decimal)
                                                    , db.Parameter("@SumSalePrice", item.TotalSalePrice, DbType.Decimal)
                                                    , db.Parameter("@Remark", item.Remark, DbType.String)
                                                    , db.Parameter("@Status", 1, DbType.Int32)// 状态：1:未完成、2：已完成 、3：已取消、4:已终止
                                                    , db.Parameter("@DeliveredAmount", item.TGPastCount, DbType.Int32)// 已交付数量
                                                    , db.Parameter("@UndeliveredAmount", 0, DbType.Int32)
                                                    , db.Parameter("@ReturnedAmount", 0, DbType.Int32)// 退货数量
                                                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                                                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)).ExecuteScalar<int>();

                                if (orderObjectID <= 0)
                                {
                                    db.RollbackTransaction();
                                    listres.Code = "2";
                                    listres.Message = "strAddOrderCommodity添加失败";
                                    listres.Data = null;
                                    return listres;
                                }

                                #endregion

                                #region 查询库存
                                string strSqlSelectQty = @" SELECT TOP 1 * FROM [TBL_PRODUCT_STOCK] WHERE ProductCode=@ProductCode AND CompanyID=@CompanyID AND BranchID=@BranchID ORDER BY ID DESC ";
                                ProductStockOperation_Model stockModel = db.SetCommand(strSqlSelectQty,
                                db.Parameter("@ProductCode", item.ProductCode, DbType.Int64),
                                db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                db.Parameter("@BranchID", item.BranchID, DbType.Int32)).ExecuteObject<ProductStockOperation_Model>();
                                #endregion

                                if (stockModel == null)
                                {
                                    db.RollbackTransaction();
                                    listres.Code = "2";
                                    listres.Message = "strSqlSelectQty失败";
                                    listres.Data = null;
                                    return listres;
                                }
                                // 不计库存与超卖库存不需要判断库存是否足够 
                                if (stockModel.StockCalcType == 1)
                                {
                                    #region 判断库存
                                    if (stockModel.ProductQty <= 0 || stockModel.ProductQty < item.Quantity)
                                    {
                                        //db.RollbackTransaction(); 
                                        issuccess = false;
                                        string strSqlSelectPro = " SELECT CommodityName AS ProductName FROM [COMMODITY] WHERE ID=@ID ";
                                        string proname = db.SetCommand(strSqlSelectPro, db.Parameter("@ID", item.ProductID, DbType.Int32)).ExecuteScalar<string>();
                                        qtymsg += proname + "库存不足(" + stockModel.ProductQty + "),";
                                        continue;
                                    }
                                    #endregion
                                }


                                // 正常商品与超卖商品 操作库存表 
                                if (stockModel.StockCalcType == 1 || stockModel.StockCalcType == 3)
                                {
                                    #region 修改库存
                                    string strSqlUpdateStock = @" UPDATE TBL_PRODUCT_STOCK SET ProductQty=ProductQty-@ProductQty,OperatorID=@OperatorID,OperateTime=@OperateTime WHERE ProductCode=@ProductCode AND CompanyID=@CompanyID AND BranchID=@BranchID ";
                                    int updatestockrs = db.SetCommand(strSqlUpdateStock,
                                    db.Parameter("@ProductQty", item.Quantity, DbType.Int32),
                                    db.Parameter("@OperatorID", model.CreatorID, DbType.Int32),
                                    db.Parameter("@OperateTime", model.CreateTime, DbType.DateTime2),
                                    db.Parameter("@ProductCode", item.ProductCode, DbType.Int64),
                                    db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                    db.Parameter("@BranchID", item.BranchID, DbType.Int32)).ExecuteNonQuery();
                                    #endregion

                                    if (updatestockrs <= 0)
                                    {
                                        db.RollbackTransaction();
                                        listres.Code = "2";
                                        listres.Message = "更新库存失败";
                                        listres.Data = null;
                                        return listres;
                                    }

                                    #region 批次表修改数量操作
                                    string strSqlSelectStockBatch = @" SELECT * FROM [TBL_PRODUCT_STOCK_BATCH] WHERE ProductCode=@ProductCode AND CompanyID=@CompanyID AND BranchID=@BranchID ORDER BY ID ";
                                    List<Product_Stock_Batch_Model> stockBatchList = db.SetCommand(strSqlSelectStockBatch,
                                    db.Parameter("@ProductCode", item.ProductCode, DbType.Int64),
                                    db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                    db.Parameter("@BranchID", item.BranchID, DbType.Int32)).ExecuteList<Product_Stock_Batch_Model>();
                                    if (stockBatchList != null && stockBatchList.Count > 0)
                                    {
                                        int qtyForUpd = item.Quantity;
                                        for (int i = 0; i < stockBatchList.Count; i++)
                                        {
                                            if (qtyForUpd > stockBatchList[i].Quantity)
                                            {
                                                string strSqlUpdateStockBatch = @" UPDATE TBL_PRODUCT_STOCK_BATCH SET Quantity=0 WHERE ID = @ID ";
                                                int updStockBatch = db.SetCommand(strSqlUpdateStockBatch,
                                                db.Parameter("@ID", stockBatchList[i].ID, DbType.Int32)).ExecuteNonQuery();
                                                if (updStockBatch <= 0)
                                                {
                                                    db.RollbackTransaction();
                                                    listres.Code = "2";
                                                    listres.Message = "更新库存失败";
                                                    listres.Data = null;
                                                    return listres;
                                                }
                                                qtyForUpd = qtyForUpd - stockBatchList[i].Quantity;
                                            }else {
                                                string strSqlUpdateStockBatch = @" UPDATE TBL_PRODUCT_STOCK_BATCH SET Quantity=Quantity-@qtyForUpd WHERE ID = @ID ";
                                                int updStockBatch = db.SetCommand(strSqlUpdateStockBatch,
                                                db.Parameter("@qtyForUpd", qtyForUpd, DbType.Int32),
                                                db.Parameter("@ID", stockBatchList[i].ID, DbType.Int32)).ExecuteNonQuery();
                                                if (updStockBatch <= 0)
                                                {
                                                    db.RollbackTransaction();
                                                    listres.Code = "2";
                                                    listres.Message = "更新库存失败";
                                                    listres.Data = null;
                                                    return listres;
                                                }
                                                qtyForUpd = 0;
                                            }
                                        }
                                    }
                                    #endregion

                                    #region 操作库存
                                    #region 插入库存操作记录表
                                    string strSqlInsertStockLog = @"INSERT INTO [TBL_PRODUCT_STOCK_OPERATELOG](CompanyID,BranchID,ProductType,ProductCode,OperateType,OperateQty,OperateSign,OrderID,ProductQty,OperatorID,OperateTime)
VALUES(@CompanyID,@BranchID,@ProductType,@ProductCode,@OperateType,@OperateQty,@OperateSign,@OrderID,@ProductQty,@OperatorID,@OperateTime)";
                                    int insertStocklogRs = db.SetCommand(strSqlInsertStockLog,
                                    db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                    db.Parameter("@BranchID", item.BranchID, DbType.Int32),
                                    db.Parameter("@ProductType", 1, DbType.Int32),
                                    db.Parameter("@ProductCode", item.ProductCode, DbType.Int64),
                                    db.Parameter("@OperateType", 4, DbType.Int32),//售出 
                                    db.Parameter("@OperateQty", item.Quantity, DbType.Int32),
                                    db.Parameter("@OperateSign", "-", DbType.String),
                                    db.Parameter("@OrderID", orderid, DbType.Int32),
                                    db.Parameter("@ProductQty", stockModel.ProductQty - item.Quantity, DbType.Int32),
                                    db.Parameter("@OperatorID", model.CreatorID, DbType.Int32),
                                    db.Parameter("@OperateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)).ExecuteNonQuery();
                                    #endregion

                                    if (insertStocklogRs <= 0)
                                    {
                                        db.RollbackTransaction();
                                        listres.Code = "2";
                                        listres.Message = "strSqlInsertStockLog添加失败";
                                        listres.Data = null;
                                        return listres;
                                    }


                                    #endregion

                                    #region 查询购买后库存是否足够
                                    string strSqlSelectQtyafter = @" SELECT TOP 1 ProductQty FROM [TBL_PRODUCT_STOCK] WHERE ProductCode=@ProductCode AND CompanyID=@CompanyID AND BranchID=@BranchID ORDER BY ID DESC ";
                                    int productqtyafter = db.SetCommand(strSqlSelectQtyafter,
                                    db.Parameter("@ProductCode", item.ProductCode, DbType.Int64),
                                    db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                    db.Parameter("@BranchID", item.BranchID, DbType.Int32)).ExecuteScalar<int>();
                                    #endregion

                                    if (stockModel.StockCalcType == 1)
                                    {
                                        // 库存不足 
                                        if (productqtyafter < 0)
                                        {
                                            //db.RollbackTransaction(); 
                                            issuccess = false;
                                            string strSqlSelectPro = " SELECT CommodityName AS ProductName FROM [COMMODITY] WHERE ID=@ID ";
                                            string proname = db.SetCommand(strSqlSelectPro, db.Parameter("@ID", item.ProductID, DbType.Int32)).ExecuteScalar<string>();
                                            qtymsg += proname + "库存不足(" + stockModel.ProductQty + "),";
                                            continue;
                                        }
                                    }
                                }
                                #endregion
                            }

                            #region 0元订单修改订单状态
                            if (item.TotalSalePrice == 0)
                            {
                                #region 0元订单支付成功修改Order
                                string strSqlOrderUpt = @"update [ORDER] set UnPaidPrice=@UnPaidPrice, PaymentStatus=@PaymentStatus, UpdaterID = @UpdaterID,UpdateTime = @UpdateTime where ID = @OrderID";
                                int updateorderrs = db.SetCommand(strSqlOrderUpt,
                                db.Parameter("@UnPaidPrice", 0, DbType.Decimal),// 未支付金额 
                                db.Parameter("@PaymentStatus", 5, DbType.Int32),// 1：未支付 2：部分付 3：已支付 4：已退款 5:免支付
                                db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32),
                                db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2),
                                db.Parameter("@OrderID", orderid, DbType.Int32)).ExecuteNonQuery();
                                if (updateorderrs <= 0)
                                {
                                    db.RollbackTransaction();
                                    listres.Code = "2";
                                    listres.Message = "strSqlOrderUpt添加失败";
                                    listres.Data = null;
                                    return listres;
                                }
                                #endregion
                            }
                            #endregion

                            #region 美丽顾问/销售顾问
                            string strAddConsultant = @" INSERT INTO [TBL_BUSINESS_CONSULTANT]( CompanyID ,BusinessType ,MasterID ,ConsultantType ,ConsultantID ,CreatorID ,CreateTime )
                                                    VALUES ( @CompanyID ,@BusinessType ,@MasterID ,@ConsultantType ,@ConsultantID ,@CreatorID ,@CreateTime )";

                            #region 美丽顾问
                            string strSqlGetResponsiblePersonID = @"SELECT AccountID FROM RELATIONSHIP WHERE CustomerID=@CustomerID AND BranchID=@BranchID AND Available=1 AND Type=1 ";
                            customerResponsiblePersonID = db.SetCommand(strSqlGetResponsiblePersonID, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32), db.Parameter("@BranchID", item.BranchID, DbType.Int32)).ExecuteScalar<int>();

                            if (customerResponsiblePersonID > 0)
                            {
                                int addConsultantRes = db.SetCommand(strAddConsultant
                                       , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                       , db.Parameter("@BusinessType", 1, DbType.Int32)//1：订单，2：支付，3：充值
                                       , db.Parameter("@MasterID", orderid, DbType.Int32)
                                       , db.Parameter("@ConsultantType", 1, DbType.Int32)//1:美丽顾问 2:销售顾问
                                       , db.Parameter("@ConsultantID", customerResponsiblePersonID, DbType.Int32)
                                       , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                       , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                                if (addConsultantRes <= 0)
                                {
                                    db.RollbackTransaction();
                                    listres.Code = "2";
                                    listres.Message = "strAddConsultant添加失败";
                                    listres.Data = null;
                                    return listres;
                                }
                            }
                            #endregion

                            #region 销售顾问
                            string advanced = Company_DAL.Instance.getAdvancedByCompanyID(model.CompanyID);
                            if (advanced.Contains("|4|"))
                            {
                                string strSelSalesSql = @"SELECT  AccountID
                                            FROM    [RELATIONSHIP]
                                            WHERE   companyID = @CompanyID
                                                    AND BranchID = @BranchID
                                                    AND CustomerID = @CustomerID
                                                    AND Available = 1
                                                    AND Type = 2";

                                List<int> SalesPersonIDList = db.SetCommand(strSelSalesSql,
                                        db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                        db.Parameter("@BranchID", item.BranchID, DbType.Int32),
                                        db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteScalarList<int>();

                                if (SalesPersonIDList != null || SalesPersonIDList.Count > 0)
                                {
                                    foreach (int SalesPersonID in SalesPersonIDList)
                                    {
                                        int addConsultantRes = db.SetCommand(strAddConsultant
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@BusinessType", 1, DbType.Int32)//1：订单，2：支付，3：充值
                                        , db.Parameter("@MasterID", orderid, DbType.Int32)
                                        , db.Parameter("@ConsultantType", 2, DbType.Int32)//1:美丽顾问 2:销售顾问
                                        , db.Parameter("@ConsultantID", SalesPersonID, DbType.Int32)
                                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                                        if (addConsultantRes <= 0)
                                        {
                                            db.RollbackTransaction();
                                            listres.Code = "2";
                                            listres.Message = "strAddConsultant添加失败";
                                            listres.Data = null;
                                            return listres;
                                        }

                                        //item.strSalesIDs = "|" + SalesPersonID + "|";
                                    }
                                }
                            }
                            #endregion
                            #endregion

                            if (model.OldOrderIDs == null || model.OldOrderIDs.Count <= 0)
                            {
                                model.OldOrderIDs = new List<int>();
                            }

                            model.OldOrderIDs.Add(orderid);
                        }


                        if (issuccess && model.OldOrderIDs != null && model.OldOrderIDs.Count > 0)
                        {
                            //成功 
                            db.CommitTransaction();
                            listres.Code = "1";
                            listres.Message = "success";
                            listres.Data = model.OldOrderIDs;


                            //根据每个订单抽取 订单中的需要推送的 美容师 
                            List<PushOperation_Model> listPushTagets = new List<PushOperation_Model>();
                            string CustomerName = "";

                            string selectCustomerDevice = @"SELECT TOP 1 T1.Name AS CustomerName
                                                                    FROM [CUSTOMER] T1 WITH ( NOLOCK ) 
                                                                    WHERE T1.UserID = @CustomerID";
                            CustomerName = db.SetCommand(selectCustomerDevice, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteScalar<string>();
                            List<Echo_Model> accountList = new List<Echo_Model>();
                            foreach (var item in model.OrderList)
                            {
                                if (!string.IsNullOrWhiteSpace(CustomerName))
                                {
                                    #region Customer端
                                    string strSelectaccountSql = @"SELECT  T3.UserID AS AccountID,T2.BranchID 
                                                                            FROM    RELATIONSHIP T1 WITH ( NOLOCK ) 
                                                                                    LEFT JOIN TBL_ACCOUNTBRANCH_RELATIONSHIP T2 WITH ( NOLOCK ) ON T1.BranchID = T2.BranchID
                                                                                    LEFT JOIN ACCOUNT T3 WITH ( NOLOCK ) ON T2.UserID = T3.UserID
                                                                                    LEFT JOIN TBL_ROLE T4 WITH ( NOLOCK ) ON T3.RoleID = T4.ID
                                                                            WHERE   ( T1.BranchID = @BranchID
                                                                                      AND T1.CustomerID = @CustomerID
                                                                                      AND T2.Available=1
                                                                                      AND T2.UserID=T1.AccountID
                                                                                    )
                                                                                    OR ( T4.Available = 1
                                                                                         AND CHARINDEX('|41|', T4.Jurisdictions) > 0
                                                                                         AND T1.BranchID = @BranchID
                                                                                         AND T1.CustomerID = @CustomerID
                                                                                         AND T2.Available=1
                                                                                       ) ";
                                    List<Echo_Model> accountListTemp = db.SetCommand(strSelectaccountSql, db.Parameter("@BranchID", item.BranchID, DbType.Int32), db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteList<Echo_Model>();
                                    if (accountListTemp != null && accountListTemp.Count > 0)
                                    {
                                        accountList.AddRange(accountListTemp);
                                    }
                                    #endregion
                                }
                            }

                            //将同一分店 同一美容师 去重 
                            accountList = accountList.Distinct(new APICommon.Compare<Echo_Model>((x, y) => (null != x && null != y) && (x.AccountID == y.AccountID) && (x.BranchID == y.BranchID))).Where(c => c.AccountID != model.CreatorID).ToList();

                            if (accountList != null && accountList.Count > 0)
                            {
                                foreach (Echo_Model item in accountList)
                                {
                                    PushOperation_Model pushmodel = new PushOperation_Model();
                                    string strPushSql = @"SELECT   T1.DeviceID AS DeviceID ,T1.UserID AS AccountID ,
                                                        T1.DeviceType,
                                                        T3.BranchName
                                                        FROM    [LOGIN] T1 WITH(NOLOCK)
                                                                LEFT JOIN [TBL_ACCOUNTBRANCH_RELATIONSHIP] T2 WITH(NOLOCK) ON T1.UserID = T2.UserID
                                                                LEFT JOIN [Branch] T3 WITH(NOLOCK) ON T2.BranchID=T3.ID
                                                        WHERE   T1.UserID =@AccountID
                                                                AND T2.BranchID = @BranchID
                                                                AND ISNULL(T1.DeviceID,'')<>'' 
                                                                AND T1.ClientType=1 
                                                                AND T3.Available=1 ";
                                    pushmodel = db.SetCommand(strPushSql, db.Parameter("@AccountID", item.AccountID, DbType.Int32)
                                                                        , db.Parameter("@BranchID", item.BranchID, DbType.Int32)).ExecuteObject<PushOperation_Model>();

                                    if (pushmodel != null)
                                    {
                                        listPushTagets.Add(pushmodel);
                                    }
                                }
                            }

                            if (listPushTagets != null && listPushTagets.Count > 0)
                            {
                                Task.Factory.StartNew(() =>
                                {
                                    for (int j = 0; j < listPushTagets.Count; j++)
                                    {
                                        try
                                        {
                                            HS.Framework.Common.Push.HSPush.pushMsg(listPushTagets[j].DeviceID, listPushTagets[j].DeviceType, 1, "顾客:" + CustomerName + "在" + listPushTagets[j].BranchName + "于" + model.OrderTime.ToString("yyyy-MM-dd HH:mm") + "有新增订单。", Convert.ToBoolean(System.Configuration.ConfigurationManager.AppSettings["IsProduction"]), "4");
                                        }
                                        catch (Exception)
                                        {
                                            LogUtil.Log("push失败", model.CustomerID + "push订单失败,时间:" + model.CreateTime + "美容师ID:" + listPushTagets[j].AccountID + ",DeviceID:" + listPushTagets[j].DeviceID + "DeviceType:" + listPushTagets[j].DeviceType);
                                            continue;
                                        }
                                    }

                                });
                            }
                            else
                            {
                                LogUtil.Log("push失败", model.CustomerID + "数据抽取失败");
                            }

                            return listres;
                        }
                        else
                        {
                            //库存不足 
                            db.RollbackTransaction();
                            listres.Code = "3";
                            listres.Message = qtymsg;
                            listres.Data = null;
                            return listres;
                        }
                    }
                    catch
                    {
                        db.RollbackTransaction();
                        throw;
                    }
                }
            }
            else
            {
                listres.Code = "2";
                listres.Message = "参数不对";
                listres.Data = null;
                return listres;
            }
        }


        public int AddRushOrder(AddRushOrderOperation_Model addModel, out string msg)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strSqlRulesSql = @" SELECT  PRCode,PRValue ,T1.PromotionID ,T3.PromotionType ,T3.StartDate,T3.EndDate
                                            FROM    [TBL_PROMOTION_PRODUCT] T1
                                                    LEFT JOIN [TBL_PROMOTION_RULE] T2 ON T2.PromotionID = T1.PromotionID 
                                                    LEFT JOIN [TBL_PROMOTION] T3 ON T1.PromotionID=T3.PromotionCode 
                                            WHERE   T1.PromotionID = @PromotionID
                                                    AND T1.ProductID = @ProductID
                                                    AND T1.ProductType = @ProductType 
                                                    AND T1.CompanyID = @CompanyID ";

                DataTable dt = db.SetCommand(strSqlRulesSql
                    , db.Parameter("@PromotionID", addModel.PromotionID, DbType.String)
                    , db.Parameter("@ProductID", addModel.ProductID, DbType.Int32)
                    , db.Parameter("@ProductType", addModel.ProductType, DbType.Int32)
                    , db.Parameter("@CompanyID", addModel.CompanyID, DbType.Int32)).ExecuteDataTable();

                if (dt == null || dt.Rows.Count <= 0)
                {
                    db.RollbackTransaction();
                    msg = "该促销不存在";
                    return 0;
                }
                else
                {
                    DateTime dtNow = DateTime.Now.ToLocalTime();
                    if (StringUtils.GetDbDateTime(dt.Rows[0]["StartDate"]) > dtNow)
                    {
                        db.RollbackTransaction();
                        msg = "该促销未开始";
                        return 0;
                    }
                    else if (StringUtils.GetDbDateTime(dt.Rows[0]["EndDate"]) < dtNow)
                    {
                        db.RollbackTransaction();
                        msg = "该促销已结束";
                        return 0;
                    }
                }




                #region 循环判断规则
                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    string strSelProProductCountSql = @" SELECT  {0} 
                                                            FROM    [TBL_RUSH_ORDER] T1 
                                                            WHERE   T1.CompanyID = @CompanyID
                                                                    AND T1.PromotionID = @PromotionID
                                                                    AND T1.ProductID = @ProductID
                                                                    AND T1.ProductType = @ProductType
                                                                    AND ( T1.ReleaseTime > @Time
                                                                          OR T1.PaymentStatus = 2
                                                                        ) ";

                    addModel.PromotionID = StringUtils.GetDbString(dt.Rows[i]["PromotionID"]);
                    if (string.IsNullOrWhiteSpace(addModel.PromotionID))
                    {
                        db.RollbackTransaction();
                        msg = "该促销不能购买";
                        return 0;
                    }

                    int promotionType = StringUtils.GetDbInt(dt.Rows[i]["PromotionType"]);

                    if (promotionType != 1)
                    {
                        db.RollbackTransaction();
                        msg = "该促销不能购买";
                        return 0;
                    }

                    if (promotionType == 1)
                    {
                        #region 限时限量
                        string prCode = StringUtils.GetDbString(dt.Rows[i]["PRCode"]);
                        decimal prValue = StringUtils.GetDbDecimal(dt.Rows[i]["prValue"]);

                        if (prValue > 0)
                        {
                            if (prCode == "1")
                            {
                                #region 总促销数量
                                if (addModel.Qty > prValue)
                                {
                                    db.RollbackTransaction();
                                    msg = "购买数量超过促销总数量";
                                    return 0;
                                }

                                strSelProProductCountSql = string.Format(strSelProProductCountSql, " ISNULL(SUM(RushQuantity),0) AS OccupyingQty ");
                                decimal OccupyingQty = db.SetCommand(strSelProProductCountSql
                                    , db.Parameter("@CompanyID", addModel.CompanyID, DbType.Int32)
                                    , db.Parameter("@PromotionID", addModel.PromotionID, DbType.String)
                                    , db.Parameter("@ProductID", addModel.ProductID, DbType.Int32)
                                    , db.Parameter("@ProductType", addModel.ProductType, DbType.Int32)
                                    , db.Parameter("@Time", addModel.Time, DbType.DateTime)).ExecuteScalar<decimal>();

                                if (OccupyingQty + addModel.Qty > prValue)
                                {
                                    db.RollbackTransaction();
                                    msg = "购买数量超过促销总数量";
                                    return 0;
                                }

                                #endregion
                            }

                            if (prCode == "2")
                            {
                                #region 单账户每笔数量
                                if (addModel.Qty > prValue)
                                {
                                    db.RollbackTransaction();
                                    msg = "该促销单个用户每笔只能购买" + (int)prValue + "个";
                                    return 0;
                                }
                                #endregion
                            }

                            if (prCode == "3")
                            {
                                #region 单账户每日笔数
                                strSelProProductCountSql += " AND  DATEDIFF(day,T1.RushTime,@Time)=0 AND T1.CustomerID = @CustomerID ";
                                strSelProProductCountSql = string.Format(strSelProProductCountSql, " COUNT(0) ");
                                decimal singleCanBuyOrderCount = db.SetCommand(strSelProProductCountSql
                                    , db.Parameter("@CompanyID", addModel.CompanyID, DbType.Int32)
                                    , db.Parameter("@PromotionID", addModel.PromotionID, DbType.String)
                                    , db.Parameter("@ProductID", addModel.ProductID, DbType.Int32)
                                    , db.Parameter("@ProductType", addModel.ProductType, DbType.Int32)
                                    , db.Parameter("@Time", addModel.Time, DbType.DateTime)
                                    , db.Parameter("@CustomerID", addModel.CustomerID, DbType.Int32)).ExecuteScalar<decimal>();

                                if (singleCanBuyOrderCount >= prValue)
                                {
                                    db.RollbackTransaction();
                                    msg = "该促销单个用户每日只能购买" + (int)prValue + "笔";
                                    return 0;
                                }
                                #endregion
                            }

                            if (prCode == "4")
                            {
                                #region 单账户总数量
                                strSelProProductCountSql += " AND T1.CustomerID = @CustomerID ";
                                strSelProProductCountSql = string.Format(strSelProProductCountSql, " ISNULL(SUM(RushQuantity),0) AS OccupyingQty ");
                                decimal OccupyingQty = db.SetCommand(strSelProProductCountSql
                                    , db.Parameter("@CompanyID", addModel.CompanyID, DbType.Int32)
                                    , db.Parameter("@PromotionID", addModel.PromotionID, DbType.String)
                                    , db.Parameter("@ProductID", addModel.ProductID, DbType.Int32)
                                    , db.Parameter("@ProductType", addModel.ProductType, DbType.Int32)
                                    , db.Parameter("@Time", addModel.Time, DbType.DateTime)
                                    , db.Parameter("@CustomerID", addModel.CustomerID, DbType.Int32)).ExecuteScalar<decimal>();

                                if (OccupyingQty + addModel.Qty > prValue)
                                {
                                    db.RollbackTransaction();
                                    msg = "该促销单个用户只能购买" + (int)prValue + "个";
                                    return 0;
                                }
                                #endregion
                            }

                            if (prCode == "5")
                            {
                                #region 单账户总笔数
                                strSelProProductCountSql += " AND T1.CustomerID = @CustomerID ";
                                strSelProProductCountSql = string.Format(strSelProProductCountSql, " COUNT(0) ");
                                decimal singleCanBuyOrderCount = db.SetCommand(strSelProProductCountSql
                                    , db.Parameter("@CompanyID", addModel.CompanyID, DbType.Int32)
                                    , db.Parameter("@PromotionID", addModel.PromotionID, DbType.String)
                                    , db.Parameter("@ProductID", addModel.ProductID, DbType.Int32)
                                    , db.Parameter("@ProductType", addModel.ProductType, DbType.Int32)
                                    , db.Parameter("@Time", addModel.Time, DbType.DateTime)
                                    , db.Parameter("@CustomerID", addModel.CustomerID, DbType.Int32)).ExecuteScalar<decimal>();

                                if (singleCanBuyOrderCount >= prValue)
                                {
                                    db.RollbackTransaction();
                                    msg = "该促销单个用户只能购买" + (int)prValue + "笔";
                                    return 0;
                                }
                                #endregion
                            }
                        }
                        #endregion
                    }
                }
                #endregion

                string strSelProductBas = @" SELECT  T1.DiscountPrice,
                                                CASE @ProductType WHEN 0 THEN T2.ServiceName ELSE T3.CommodityName END AS ProductName ,
                                                CASE @ProductType WHEN 0 THEN T2.UnitPrice ELSE T3.UnitPrice END AS UnitPrice 
                                                FROM    [TBL_PROMOTION_PRODUCT] T1
                                                        LEFT JOIN [SERVICE] T2 ON T1.ProductID = T2.ID
                                                        LEFT JOIN [COMMODITY] T3 ON T1.ProductID = T3.ID
                                                WHERE   T1.ProductID = @ProductID
                                                        AND T1.CompanyID = @CompanyID 
                                                        AND PromotionID = @PromotionID ";
                DataTable productDT = db.SetCommand(strSelProductBas
                , db.Parameter("@ProductID", addModel.ProductID, DbType.Int32)
                , db.Parameter("@ProductType", addModel.ProductType, DbType.Int32)
                , db.Parameter("@CompanyID", addModel.CompanyID, DbType.Int32)
                , db.Parameter("@PromotionID", addModel.PromotionID, DbType.String)).ExecuteDataTable();

                if (productDT == null || productDT.Rows.Count != 1)
                {
                    db.RollbackTransaction();
                    msg = "该促销不能购买";
                    return 0;
                }

                decimal discountPrice = StringUtils.GetDbDecimal(productDT.Rows[0]["DiscountPrice"]);
                string productName = StringUtils.GetDbString(productDT.Rows[0]["ProductName"]);
                decimal UnitPrice = StringUtils.GetDbDecimal(productDT.Rows[0]["UnitPrice"]);

                #region 生成TBL_NETTRADE_CONTROL
                string netTradeNo = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "NetTradeNo", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<string>();

                string strAddControlSql = @" INSERT INTO TBL_NETTRADE_CONTROL( CompanyID ,BranchID ,CustomerID ,NetTradeNo ,NetActionType ,ChangeType ,NetTradeVendor ,NetTradeActionMode ,ProductName ,NetTradeAmount ,SubmitTime ,RelatedNetTradeNo ,PointAmount ,CouponAmount ,MoneyAmount ,UserCardNo ,Participants ,Remark ,CreatorID ,CreateTime ) 
                                            VALUES ( @CompanyID ,@BranchID ,@CustomerID ,@NetTradeNo ,@NetActionType ,@ChangeType ,@NetTradeVendor ,@NetTradeActionMode ,@ProductName ,@NetTradeAmount ,@SubmitTime ,@RelatedNetTradeNo ,@PointAmount ,@CouponAmount ,@MoneyAmount ,@UserCardNo ,@Participants ,@Remark ,@CreatorID ,@CreateTime ) ";

                int addControlRes = db.SetCommand(strAddControlSql
                    , db.Parameter("@CompanyID", addModel.CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", addModel.BranchID, DbType.Int32)
                    , db.Parameter("@CustomerID", addModel.CustomerID, DbType.Int32)
                    , db.Parameter("@NetTradeNo", netTradeNo, DbType.String)
                    , db.Parameter("@NetActionType", 1, DbType.Int32)//1:支付 2:退款
                    , db.Parameter("@ChangeType", 1, DbType.Int32)//1:消费、2:消费撤销、3：充值、4：充值撤销、
                    , db.Parameter("@NetTradeVendor", 1, DbType.Int32)//1:微信
                    , db.Parameter("@NetTradeActionMode", "W5", DbType.String)//W5 公众号支付
                    , db.Parameter("@ProductName", productName, DbType.String)
                    , db.Parameter("@NetTradeAmount", discountPrice * addModel.Qty, DbType.Decimal)
                    , db.Parameter("@SubmitTime", addModel.Time, DbType.DateTime2)
                    , db.Parameter("@RelatedNetTradeNo", DBNull.Value, DbType.String)
                    , db.Parameter("@PointAmount", 0, DbType.Decimal)
                    , db.Parameter("@CouponAmount", 0, DbType.Decimal)
                    , db.Parameter("@MoneyAmount", 0, DbType.Decimal)
                    , db.Parameter("@UserCardNo", "", DbType.String)
                    , db.Parameter("@Participants", "", DbType.String)
                    , db.Parameter("@Remark", addModel.Remark, DbType.String)
                    , db.Parameter("@CreatorID", addModel.CustomerID, DbType.Int32)
                    , db.Parameter("@CreateTime", addModel.Time, DbType.DateTime2)).ExecuteNonQuery();

                if (addControlRes <= 0)
                {
                    db.RollbackTransaction();
                    msg = "该促销不能购买";
                    return 0;
                }
                #endregion

                #region 插入RushOrder表
                string strAddRushOrderSql = @" INSERT INTO TBL_RUSH_ORDER( CompanyID ,BranchID ,CustomerID ,PromotionID ,ProductID ,ProductType ,PaymentStatus ,RushTime ,LimitedPaymentTime ,ReleaseTime ,OrigPrice ,RushPrice ,RushQuantity ,TotalRushPrice ,NetTradeNo ,Remark ,CreatorID ,CreateTime ) 
                                                VALUES  (@CompanyID ,@BranchID ,@CustomerID ,@PromotionID ,@ProductID ,@ProductType ,@PaymentStatus ,@RushTime ,@LimitedPaymentTime ,@ReleaseTime ,@OrigPrice ,@RushPrice ,@RushQuantity ,@TotalRushPrice ,@NetTradeNo ,@Remark ,@CreatorID ,@CreateTime );select @@IDENTITY";

                int rushOrderID = db.SetCommand(strAddRushOrderSql
                    , db.Parameter("@CompanyID", addModel.CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", addModel.BranchID, DbType.Int32)
                    , db.Parameter("@CustomerID", addModel.CustomerID, DbType.Int32)
                    , db.Parameter("@PromotionID", addModel.PromotionID, DbType.String)
                    , db.Parameter("@ProductID", addModel.ProductID, DbType.Int32)
                    , db.Parameter("@ProductType", addModel.ProductType, DbType.Int32)
                    , db.Parameter("@PaymentStatus", 1, DbType.Int32)//1：未支付 2：已支付
                    , db.Parameter("@RushTime", addModel.Time, DbType.DateTime)
                    , db.Parameter("@LimitedPaymentTime", addModel.LimitedPaymentTime, DbType.DateTime)
                    , db.Parameter("@ReleaseTime", addModel.ReleaseTime, DbType.DateTime)
                    , db.Parameter("@OrigPrice", UnitPrice, DbType.Decimal)
                    , db.Parameter("@RushPrice", discountPrice, DbType.Decimal)
                    , db.Parameter("@RushQuantity", addModel.Qty, DbType.Decimal)
                    , db.Parameter("@TotalRushPrice", discountPrice * addModel.Qty, DbType.Decimal)
                    , db.Parameter("@NetTradeNo", netTradeNo, DbType.String)
                    , db.Parameter("@Remark", addModel.Remark, DbType.String)
                    , db.Parameter("@CreatorID", addModel.CustomerID, DbType.Int32)
                    , db.Parameter("@CreateTime", addModel.Time, DbType.DateTime)).ExecuteScalar<int>();

                if (rushOrderID <= 0)
                {
                    db.RollbackTransaction();
                    msg = "促销购买失败";
                    return 0;
                }
                #endregion

                db.CommitTransaction();
                msg = "促销购买成功";
                return rushOrderID;
            }
        }

        public GetRushOrderDetail_Model GetRushOrderDetail(int companyID, int customerID, int rushOrderID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"  SELECT  T1.CompanyID ,
                                        T1.BranchID ,
                                        T2.BranchName ,
                                        T1.RushOrderID ,
                                        T1.RushTime ,
                                        T1.LimitedPaymentTime ,
                                        T1.RushPrice ,
                                        T1.RushQuantity ,
                                        T1.TotalRushPrice ,
                                        T1.Remark ,
                                        T1.PaymentStatus ,
                                        T1.OrigPrice , 
                                        T1.ProductType ,
                                        T1.ProductID ,
                                        T1.PromotionID ,
                                        T1.NetTradeNo ,
                                        T3.ProductName ,
                                        CONVERT(VARCHAR(16), T1.CreateTime, 20) CreateTime  ,ISNULL(T5.ID, T6.ID) OrderID,T7.ProductPromotionName
                                FROM    [TBL_RUSH_ORDER] T1 WITH ( NOLOCK )
                                        LEFT JOIN [BRANCH] T2 ON T1.BranchID = T2.ID 
                                        LEFT JOIN [TBL_NETTRADE_CONTROL] T3 ON T3.NetTradeNo=T1.NetTradeNo 
										LEFT JOIN [TBL_NETTRADE_ORDER] T4  ON T1.NetTradeNo = T4.NetTradeNo
										LEFT JOIN [TBL_ORDER_COMMODITY] T5 ON T4.OrderID = T5.OrderID AND T1.ProductType = 1
										LEFT JOIN [TBL_ORDER_SERVICE] T6 ON T4.OrderID = T6.OrderID AND T1.ProductType = 0
	LEFT JOIN [TBL_PROMOTION_PRODUCT] T7 ON T1.PromotionID = T7.PromotionID AND T1.ProductID = T7.ProductID AND T1.ProductType = T7.ProductType
                                WHERE   T1.RushOrderID = @RushOrderID
                                        AND T1.CompanyID = @CompanyID
                                        AND T1.CustomerID = @CustomerID ";

                GetRushOrderDetail_Model model = db.SetCommand(strSql
                   , db.Parameter("@RushOrderID", rushOrderID, DbType.Int32)
                   , db.Parameter("@CompanyID", companyID, DbType.Int32)
                   , db.Parameter("@CustomerID", customerID, DbType.Int32)).ExecuteObject<GetRushOrderDetail_Model>();

                if (model != null && !string.IsNullOrWhiteSpace(model.NetTradeNo))
                {
                    string strCountSql = @" SELECT COUNT(0) FROM  [TBL_NETTRADE_ORDER] WHERE CompanyID=@CompanyID AND NetTradeNo=@NetTradeNo ";
                    int count = db.SetCommand(strCountSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                , db.Parameter("@NetTradeNo", model.NetTradeNo, DbType.String)).ExecuteScalar<int>();

                    model.HasNetTrade = count > 0 ? true : false;
                }

                return model;
            }
        }

        public List<GetRushOrderList_Model> GetRushOrderList(int companyID, int customerID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT  T1.CompanyID ,
                                        T1.BranchID ,
                                        T2.BranchName ,
                                        T1.RushOrderID ,
                                        T1.RushTime ,
                                        T1.LimitedPaymentTime ,
                                        T1.RushPrice ,
                                        T1.RushQuantity ,
                                        T1.TotalRushPrice ,
                                        T1.Remark ,
                                        T1.PaymentStatus ,
                                        T1.OrigPrice , 
                                        T1.ProductType ,
                                        T1.ProductID ,
                                        T1.PromotionID ,
                                        T1.NetTradeNo ,
                                        T3.ProductName ,
                                        CONVERT(VARCHAR(16), T1.CreateTime, 20) CreateTime   ,T4.ProductPromotionName
                                FROM    [TBL_RUSH_ORDER] T1 WITH ( NOLOCK )
                                        INNER JOIN [BRANCH] T2 ON T1.BranchID = T2.ID 
                                        INNER JOIN [TBL_NETTRADE_CONTROL] T3 ON T3.NetTradeNo=T1.NetTradeNo 
										LEFT JOIN [TBL_PROMOTION_PRODUCT] T4 ON T1.PromotionID = T4.PromotionID AND T1.ProductID = T4.ProductID AND T4.ProductType =T1.ProductType
                                WHERE   ( ( GETDATE() < T1.LimitedPaymentTime
                                            AND T1.PaymentStatus = 1
                                          )
                                          OR T1.PaymentStatus = 2
                                        )
                                        AND T1.CompanyID = @CompanyID
                                        AND T1.CustomerID = @CustomerID 
                               ORDER BY T1.PaymentStatus ASC,T1.CreateTime DESC ";

                List<GetRushOrderList_Model> model = db.SetCommand(strSql
                   , db.Parameter("@CompanyID", companyID, DbType.Int32)
                   , db.Parameter("@CustomerID", customerID, DbType.Int32)).ExecuteList<GetRushOrderList_Model>();

                return model;
            }
        }
    }
}
