using BLToolkit.Data;
using HS.Framework.Common;
using HS.Framework.Common.Util;
using Model.View_Model;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL
{
    public class Report_DAL
    {
        #region 构造类实例
        public static Report_DAL Instance
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
            internal static readonly Report_DAL instance = new Report_DAL();
        }
        #endregion

        public List<GetReportList_Model> getAccountReportList(int accountId, int cycleType, string startTime, string endtime, int branchId)
        {
            using (DbManager db = new DbManager("Report"))
            {
                //报表-员工报表一览
                string strSql = @"getAccountReportList";
                List<GetReportList_Model> list = db.SetSpCommand(strSql, db.Parameter("@SuperiorID", accountId, DbType.Int32)).ExecuteList<GetReportList_Model>();

                return list;
            }
        }


        public GetReportDetail_Model getServiceCountDeatail(int accountId, int branchId, int objectType, int cycleType, string startTime, string endtime, int companyId, int StatementCategoryID)
        {
            using (DbManager db = new DbManager("Report"))
            {
                //一个订单时间内完成的服务数

                //服务操作次数-服务次数分析详情
                List<GetTreatmentTimesDetail_Model> list = new List<GetTreatmentTimesDetail_Model>();
                string strSqlTreatmentComplete = "";

                switch (objectType)
                {
                    case 0:
                        strSqlTreatmentComplete = @"getServiceCountDeatail";
                        list = db.SetSpCommand(strSqlTreatmentComplete
                            , db.Parameter("@BranchID", branchId, DbType.Int32)
                            , db.Parameter("@SlaveID", accountId, DbType.Int32)
                            , db.Parameter("@cycleType", cycleType, DbType.Int32)
                            , db.Parameter("@startTime", startTime, DbType.String)
                            , db.Parameter("@endtime", endtime, DbType.String)).ExecuteList<GetTreatmentTimesDetail_Model>();
                        break;
                    case 3:
                        strSqlTreatmentComplete = @"getServiceCountDeatailGroup";
                        list = db.SetSpCommand(strSqlTreatmentComplete
                            , db.Parameter("@CompanyID", companyId, DbType.Int32)
                            , db.Parameter("@BranchID", branchId, DbType.Int32)
                            , db.Parameter("@SlaveID", accountId, DbType.Int32)
                            , db.Parameter("@cycleType", cycleType, DbType.Int32)
                            , db.Parameter("@startTime", startTime, DbType.String)
                            , db.Parameter("@endtime", endtime, DbType.String)).ExecuteList<GetTreatmentTimesDetail_Model>();
                        break;
                    default:
                        strSqlTreatmentComplete = @"getServiceCountDeatailDefault";
                        list = db.SetSpCommand(strSqlTreatmentComplete
                            , db.Parameter("@BranchID", branchId, DbType.Int32)
                            , db.Parameter("@cycleType", cycleType, DbType.Int32)
                            , db.Parameter("@startTime", startTime, DbType.String)
                            , db.Parameter("@endtime", endtime, DbType.String)).ExecuteList<GetTreatmentTimesDetail_Model>();
                        break;
                }

                if (list == null || list.Count == 0)
                {
                    return null;
                }
                foreach (GetTreatmentTimesDetail_Model item in list)
                {
                    if (item.IsDesignated == 1)
                    {
                        item.ObjectName = item.ObjectName + " 指定 ";
                    }
                }

                GetReportDetail_Model model = new GetReportDetail_Model();
                model.TreatmentTimesDetail = list;
                return model;
            }
        }

        public GetReportDetail_Model getCustomerReportDetail(int accountId, int branchId, int cycleType, string startTime, string endtime, int productType, int objectType, int sortType, int companyId, int StatementCategoryID)
        {
            using (DbManager db = new DbManager("Report"))
            {
                #region 抽取顾客信息

                string strSqlFinal = "";
                List<GetProductDetailList_Model> list = new List<GetProductDetailList_Model>();
                if (cycleType == 4)
                {
                    startTime += " 0:00:00";
                    endtime += " 23:59:59";
                }
                sortType = 2;

                if (productType == 0)
                {
                    switch (objectType)
                    {
                        case 0:
                            strSqlFinal = @"getCustomerDetailListService";
                            list = db.SetSpCommand(strSqlFinal
                            , db.Parameter("@BranchID", branchId, DbType.Int32)
                            , db.Parameter("@SlaveID", accountId, DbType.Int32)
                            , db.Parameter("@productType", productType, DbType.Int32)
                            , db.Parameter("@cycleType", cycleType, DbType.Int32)
                            , db.Parameter("@startTime", startTime, DbType.String)
                            , db.Parameter("@endtime", endtime, DbType.String)
                            , db.Parameter("@sortType", sortType, DbType.Int32)).ExecuteList<GetProductDetailList_Model>();
                            break;
                        case 3:
                            strSqlFinal = @"getCustomerDetailListServiceGroup";
                            list = db.SetSpCommand(strSqlFinal
                            , db.Parameter("@CompanyID", companyId, DbType.Int32)
                            , db.Parameter("@BranchID", branchId, DbType.Int32)
                            , db.Parameter("@SlaveID", accountId, DbType.Int32)
                            , db.Parameter("@productType", productType, DbType.Int32)
                            , db.Parameter("@cycleType", cycleType, DbType.Int32)
                            , db.Parameter("@startTime", startTime, DbType.String)
                            , db.Parameter("@endtime", endtime, DbType.String)
                            , db.Parameter("@sortType", sortType, DbType.Int32)).ExecuteList<GetProductDetailList_Model>();
                            break;
                        default:
                            strSqlFinal = @"getCustomerDetailListServiceDefault";
                            list = db.SetSpCommand(strSqlFinal
                            , db.Parameter("@BranchID", branchId, DbType.Int32)
                            , db.Parameter("@productType", productType, DbType.Int32)
                            , db.Parameter("@cycleType", cycleType, DbType.Int32)
                            , db.Parameter("@startTime", startTime, DbType.String)
                            , db.Parameter("@endtime", endtime, DbType.String)
                            , db.Parameter("@sortType", sortType, DbType.Int32)).ExecuteList<GetProductDetailList_Model>();
                            break;
                    }
                }
                else
                {
                    switch (objectType)
                    {
                        case 0:
                            strSqlFinal = @"getCustomerDetailListCommodity";
                            list = db.SetSpCommand(strSqlFinal
                            , db.Parameter("@BranchID", branchId, DbType.Int32)
                            , db.Parameter("@SlaveID", accountId, DbType.Int32)
                            , db.Parameter("@productType", productType, DbType.Int32)
                            , db.Parameter("@cycleType", cycleType, DbType.Int32)
                            , db.Parameter("@startTime", startTime, DbType.String)
                            , db.Parameter("@endtime", endtime, DbType.String)
                            , db.Parameter("@sortType", sortType, DbType.Int32)).ExecuteList<GetProductDetailList_Model>();
                            break;
                        case 3:
                            strSqlFinal = @"getCustomerDetailListCommodityGroup";
                            list = db.SetSpCommand(strSqlFinal
                            , db.Parameter("@CompanyID", companyId, DbType.Int32)
                            , db.Parameter("@BranchID", branchId, DbType.Int32)
                            , db.Parameter("@SlaveID", accountId, DbType.Int32)
                            , db.Parameter("@productType", productType, DbType.Int32)
                            , db.Parameter("@cycleType", cycleType, DbType.Int32)
                            , db.Parameter("@startTime", startTime, DbType.String)
                            , db.Parameter("@endtime", endtime, DbType.String)
                            , db.Parameter("@sortType", sortType, DbType.Int32)).ExecuteList<GetProductDetailList_Model>();
                            break;
                        default:
                            strSqlFinal = @"getCustomerDetailListCommodityDefault";
                            list = db.SetSpCommand(strSqlFinal
                            , db.Parameter("@BranchID", branchId, DbType.Int32)
                            , db.Parameter("@productType", productType, DbType.Int32)
                            , db.Parameter("@cycleType", cycleType, DbType.Int32)
                            , db.Parameter("@startTime", startTime, DbType.String)
                            , db.Parameter("@endtime", endtime, DbType.String)
                            , db.Parameter("@sortType", sortType, DbType.Int32)).ExecuteList<GetProductDetailList_Model>();
                            break;
                    }
                }

                #endregion

                GetProductReportDetail_Model model = new GetProductReportDetail_Model();

                foreach (GetProductDetailList_Model item in list)
                {
                    model.AllQuantity = item.TotalQuantity;
                    model.AllTotalPrice = item.Total;
                    item.QuantityScale = Math.Round(StringUtils.GetDbDecimal(item.Quantity / model.AllQuantity) * 100, 2).ToString() + " %";
                    if (model.AllTotalPrice == 0)
                    {
                        item.TotalPriceScale = item.QuantityScale;
                    }
                    else
                    {
                        item.TotalPriceScale = Math.Round(StringUtils.GetDbDecimal(item.TotalPrice / model.AllTotalPrice) * 100, 2).ToString() + " %";
                    }
                }

                model.ProductDetail = new List<GetProductDetailList_Model>();
                model.ProductDetail = list;

                GetReportDetail_Model res = new GetReportDetail_Model();
                res.ProductDetail = model;

                return res;
            }
        }

        public GetReportDetail_Model getOrderReportDetail(int accountId, int branchId, int companyId, int cycleType, string startTime, string endtime, int productType, int extractItemType, int objectType, int sortType, int StatementCategoryID)
        {
            using (DbManager db = new DbManager("Report"))
            {
                #region 抽取服务销售分析
                string strSqlFinal = "";
                List<GetProductDetailList_Model> list = new List<GetProductDetailList_Model>();
                if (cycleType == 4)
                {
                    startTime += " 0:00:00";
                    endtime += " 23:59:59";
                }

                if (productType == 0)
                {
                    //服务
                    switch (objectType)
                    {
                        //objectType 0:个人 1：分店 2：公司 3:分组
                        case 0:
                            strSqlFinal = @"getProductDetailListService";
                            list = db.SetSpCommand(strSqlFinal
                            , db.Parameter("@BranchID", branchId, DbType.Int32)
                            , db.Parameter("@SlaveID", accountId, DbType.Int32)
                            , db.Parameter("@productType", productType, DbType.Int32)
                            , db.Parameter("@cycleType", cycleType, DbType.Int32)
                            , db.Parameter("@startTime", startTime, DbType.String)
                            , db.Parameter("@endtime", endtime, DbType.String)
                            , db.Parameter("@sortType", sortType, DbType.Int32)).ExecuteList<GetProductDetailList_Model>();
                            break;
                        case 3:
                            strSqlFinal = @"getProductDetailListServiceGroup";
                            list = db.SetSpCommand(strSqlFinal
                            , db.Parameter("@CompanyID", companyId, DbType.Int32)
                            , db.Parameter("@BranchID", branchId, DbType.Int32)
                            , db.Parameter("@SlaveID", accountId, DbType.Int32)
                            , db.Parameter("@productType", productType, DbType.Int32)
                            , db.Parameter("@cycleType", cycleType, DbType.Int32)
                            , db.Parameter("@startTime", startTime, DbType.String)
                            , db.Parameter("@endtime", endtime, DbType.String)
                            , db.Parameter("@sortType", sortType, DbType.Int32)).ExecuteList<GetProductDetailList_Model>();
                            break;
                        default:
                            strSqlFinal = @"getProductDetailListServiceDefault";
                            list = db.SetSpCommand(strSqlFinal
                            , db.Parameter("@BranchID", branchId, DbType.Int32)
                            , db.Parameter("@productType", productType, DbType.Int32)
                            , db.Parameter("@cycleType", cycleType, DbType.Int32)
                            , db.Parameter("@startTime", startTime, DbType.String)
                            , db.Parameter("@endtime", endtime, DbType.String)
                            , db.Parameter("@sortType", sortType, DbType.Int32)).ExecuteList<GetProductDetailList_Model>();
                            break;
                    }
                }
                else
                {
                    //除服务以外（商品）
                    switch (objectType)
                    {
                        case 0:
                            strSqlFinal = @"getProductDetailListCommodity";
                            list = db.SetSpCommand(strSqlFinal
                            , db.Parameter("@BranchID", branchId, DbType.Int32)
                            , db.Parameter("@SlaveID", accountId, DbType.Int32)
                            , db.Parameter("@productType", productType, DbType.Int32)
                            , db.Parameter("@cycleType", cycleType, DbType.Int32)
                            , db.Parameter("@startTime", startTime, DbType.String)
                            , db.Parameter("@endtime", endtime, DbType.String)
                            , db.Parameter("@sortType", sortType, DbType.Int32)).ExecuteList<GetProductDetailList_Model>();
                            break;
                        case 3:
                            strSqlFinal = @"getProductDetailListCommodityGroup";
                            list = db.SetSpCommand(strSqlFinal
                            , db.Parameter("@CompanyID", companyId, DbType.Int32)
                            , db.Parameter("@BranchID", branchId, DbType.Int32)
                            , db.Parameter("@SlaveID", accountId, DbType.Int32)
                            , db.Parameter("@productType", productType, DbType.Int32)
                            , db.Parameter("@cycleType", cycleType, DbType.Int32)
                            , db.Parameter("@startTime", startTime, DbType.String)
                            , db.Parameter("@endtime", endtime, DbType.String)
                            , db.Parameter("@sortType", sortType, DbType.Int32)).ExecuteList<GetProductDetailList_Model>();
                            break;
                        default:
                            strSqlFinal = @"getProductDetailListCommodityDefault";
                            list = db.SetSpCommand(strSqlFinal
                            , db.Parameter("@BranchID", branchId, DbType.Int32)
                            , db.Parameter("@productType", productType, DbType.Int32)
                            , db.Parameter("@cycleType", cycleType, DbType.Int32)
                            , db.Parameter("@startTime", startTime, DbType.String)
                            , db.Parameter("@endtime", endtime, DbType.String)
                            , db.Parameter("@sortType", sortType, DbType.Int32)).ExecuteList<GetProductDetailList_Model>();
                            break;
                    }
                }

                if (list == null || list.Count == 0)
                {
                    return null;
                }
                #endregion

                #region 后处理 比例,总价格,总业绩额
                GetProductReportDetail_Model model = new GetProductReportDetail_Model();

                foreach (GetProductDetailList_Model item in list)
                {
                    model.AllTotalPrice = item.Total;
                    model.AllTotalProfitRatePrice = item.AllDetailTotalPrice;
                    item.QuantityScale = "";
                    item.TotalPriceScale = "";
                }
                model.ProductDetail = new List<GetProductDetailList_Model>();
                model.ProductDetail = list;

                GetReportDetail_Model res = new GetReportDetail_Model();
                res.ProductDetail = model;
                #endregion

                return res;
            }
        }

        public ReportBranchCount_Model getTotalCountReport(int companyId, int branchId)
        {
            using (DbManager db = new DbManager("Report"))
            {
                ReportBranchCount_Model model = new ReportBranchCount_Model();
                string strSqlCustomerCount = @"select COUNT (T1.userID) from CUSTOMER T1 INNER JOIN [RELATIONSHIP] T2 on T1.UserID = T2.CustomerID AND T2.BranchID = @BranchID AND T2.Available = 1 where T1.CompanyID =@CompanyID and  T1.Available = 1";
                object obj = db.SetCommand(strSqlCustomerCount, db.Parameter("@CompanyID", companyId, DbType.Int32)
                                            , db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteScalar();
                model.AllCustomerCount = StringUtils.GetDbInt(obj);

                string strSqlAllAccountCount = "select COUNT(T1.UserID) from ACCOUNT T1 INNER JOIN [TBL_ACCOUNTBRANCH_RELATIONSHIP] T2 ON T1.UserID = T2.UserID where T1.Available = 1 and T1.CompanyID =@CompanyID and T2.BranchID=@BranchID AND T2.Available  =1";
                obj = db.SetCommand(strSqlAllAccountCount, db.Parameter("@CompanyID", companyId, DbType.Int32)
                                            , db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteScalar();
                model.AllAccountCount = StringUtils.GetDbInt(obj);


                model.AllBranchCount = 0;

                string strSqlAllECardRechargeCount = "select SUM(T2.Amount) from [TBL_CUSTOMER_BALANCE] T1 INNER JOIN [TBL_MONEY_BALANCE] T2 ON T1.ID = T2.CustomerBalanceID AND T1.TargetAccount = 1   WHERE T1.CompanyID =@CompanyID AND T1.BranchID=@BranchID  AND (T1.ChangeType = 3 OR T1.ChangeType = 4)    ";
                obj = db.SetCommand(strSqlAllECardRechargeCount, db.Parameter("@CompanyID", companyId, DbType.Int32)
                                            , db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteScalar();
                model.AllECardRechargeCount = StringUtils.GetDbDecimal(obj);

                string strSqlAllECardBalanceCount = @" select SUM(T2.Balance) from [TBL_MONEY_BALANCE] T2 WHERE EXISTS (SELECT * FROM(
                                                    select MAX(ID) MaxID from [TBL_MONEY_BALANCE] T1 WHERE T1.CompanyID =@CompanyID AND T1.BranchID =@BranchID  GROUP BY T1.UserCardNo) T3 where T2.ID = T3.MaxID) ";
                obj = db.SetCommand(strSqlAllECardBalanceCount, db.Parameter("@CompanyID", companyId, DbType.Int32)
                                            , db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteScalar();
                model.AllECardBalanceCount = StringUtils.GetDbDecimal(obj);

                string strSqlEffectOrderCount = @"select COUNT( [ORDER].ID) from [ORDER] 
                                                    inner join (
                                                    select [TBL_OrderPayment_RelationShip].OrderID  
                                                    from [TBL_OrderPayment_RelationShip]   
                                                    inner join  [PAYMENT] 
                                                    on [TBL_OrderPayment_RelationShip].PaymentID = [PAYMENT].ID  and [PAYMENT].Status = 2 AND [PAYMENT].Type = 1
                                                    group by  [TBL_OrderPayment_RelationShip].OrderID ) T1
                                                    ON [ORDER].ID = T1.OrderID 
                                                    LEFT JOIN [BRANCH] ON [ORDER].BranchID = [BRANCH].ID 
                                                    where  [ORDER].RecordType = 1 and [ORDER].PaymentStatus > 0  and  [ORDER].CompanyID =@CompanyID and [ORDER].BranchID=@BranchID AND [ORDER].OrderTime > [BRANCH].StartTime ";
                obj = db.SetCommand(strSqlEffectOrderCount, db.Parameter("@CompanyID", companyId, DbType.Int32)
                                            , db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteScalar();
                model.EffectOrderCount = StringUtils.GetDbInt(obj);

                string strSqlCompleteOrderCount = @"select COUNT(0) from [ORDER] T1 
                                                    LEFT JOIN [TBL_ORDER_SERVICE] T3 ON T1.ID = T3.OrderID AND T1.ProductType = 0 AND T3.Status = 2
                                                    LEFT JOIN [TBL_ORDER_COMMODITY] T4 ON T1.ID = T4.OrderID AND T1.ProductType = 1 AND T4.Status = 2
                                                    LEFT JOIN [BRANCH] T2 ON T1.BranchID = T2.ID  where T1.RecordType = 1 and T1.CompanyID =@CompanyID and T1.BranchID=@BranchID AND T1.OrderTime > T2.StartTime AND ((T3.Status = 2 AND T4.Status IS NULL) OR (T3.Status IS NULL AND T4.Status = 2))";
                model.CompleteOrderCount = db.SetCommand(strSqlCompleteOrderCount, db.Parameter("@CompanyID", companyId, DbType.Int32)
                                            , db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteScalar<int>();
                //model.CompleteOrderCount = StringUtils.GetDbInt(obj);

                string strSqlOrderTotalSalePrice = @"select  SUM(T1.TotalPrice) from [ORDER] T2
                                                    inner join (
                                                     select T4.OrderID  ,SUM(CASE T5.Type WHEN 1 THEN    T5.TotalPrice WHEN 2 THEN T5.TotalPrice * -1 END) TotalPrice
                                                    from [TBL_OrderPayment_RelationShip] T4  
                                                    inner join  [PAYMENT] T5
                                                    on T4.PaymentID = T5.ID  and T5.OrderNumber = 1
                                                    where (T5.Type = 1 AND (T5.Status = 2 OR T5.Status = 3)) OR (T5.Type = 2 AND (T5.Status = 6 OR T5.Status = 7))
                                                    group by  T4.OrderID
													UNION ALL  select T6.OrderID  ,SUM(ISNULL(CASE T7.Type WHEN 1 THEN T9.SumSalePrice WHEN 2 THEN T9.SumSalePrice * - 1 END,0) ) + SUM( ISNULL(CASE T7.Type WHEN 1 THEN T10.SumSalePrice WHEN 2 THEN T10.SumSalePrice * - 1 END,0) ) TotalPrice
                                                    from [TBL_OrderPayment_RelationShip]  T6 
                                                    inner join  [PAYMENT] T7
                                                    on T6.PaymentID = T7.ID  and  T7.OrderNumber > 1
													INNER JOIN [ORDER] T8 ON T8.ID = T6.OrderID
													LEFT JOIN [TBL_ORDER_SERVICE] T9 ON T8.ID = T9.OrderID AND T8.ProductType = 0 AND T9.Status <> 3 
													LEFT JOIN [TBL_ORDER_COMMODITY] T10 ON T8.ID = T10.OrderID AND T8.ProductType = 1 AND T10.Status <> 3 
													where (T7.Type = 1 AND (T7.Status = 2 OR T7.Status = 3)) OR (T7.Type = 2 AND (T7.Status = 6 OR T7.Status = 7))
                                                    group by  T6.OrderID ) T1
                                                    ON T2.ID = T1.OrderID 
                                                    LEFT JOIN [BRANCH] T3 ON T2.BranchID = T3.ID
                                                    where  T2.RecordType = 1 and  T2.PaymentStatus > 0  and  T2.CompanyID =@CompanyID and T2.BranchID=@BranchID AND T2.OrderTime > T3.StartTime ";
                obj = db.SetCommand(strSqlOrderTotalSalePrice, db.Parameter("@CompanyID", companyId, DbType.Int32)
                                            , db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteScalar();
                model.OrderTotalSalePrice = StringUtils.GetDbDecimal(obj);

                string strSqlClientCount = @"select COUNT (T1.userID) from CUSTOMER T1 INNER JOIN [RELATIONSHIP] T2 on T1.UserID = T2.CustomerID AND T2.BranchID = @BranchID AND T2.Available = 1 INNER JOIN [USER] T3 ON T1.UserID = T3.ID AND T3.UserType = 0 AND T3.LoginMobile IS NOT NULL where T1.CompanyID =@CompanyID and  T1.Available = 1";
                obj = db.SetCommand(strSqlClientCount, db.Parameter("@CompanyID", companyId, DbType.Int32)
                                            , db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteScalar();
                model.ClientCount = StringUtils.GetDbInt(obj);

                string strSqlWeChatCount = @"select COUNT (T1.userID) from CUSTOMER T1 INNER JOIN [RELATIONSHIP] T2 on T1.UserID = T2.CustomerID AND T2.BranchID = @BranchID AND T2.Available = 1 INNER JOIN [USER] T3 ON T1.UserID = T3.ID AND T3.UserType = 0 AND T3.LoginMobile IS NOT NULL where T1.CompanyID =@CompanyID and  T1.Available = 1 AND T1.WeChatOpenID IS NOT NULL";
                obj = db.SetCommand(strSqlWeChatCount, db.Parameter("@CompanyID", companyId, DbType.Int32)
                                            , db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteScalar();
                model.WeChatCount = StringUtils.GetDbInt(obj);

                string strSqlCardCount = "SELECT Count(T1.UserCardNo) FROM [TBL_CUSTOMER_CARD] T1 INNER JOIN [MST_CARD_BRANCH] T2 ON T1.CardID = T2.CardID AND T2.BranchID=@BranchID  WHERE T1.CompanyID=@CompanyID";
                obj = db.SetCommand(strSqlCardCount, db.Parameter("@CompanyID", companyId, DbType.Int32)
                                            , db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteScalar();
                model.AllCardCount = StringUtils.GetDbInt(obj);




                return model;
            }
        }

        public GetReportBasic_Model getReportBasic(int accountId, int branchId, int objectType, int cycleType, string startTime, string endtime, int companyId, int StatementCategoryID)
        {
            using (DbManager db = new DbManager("Report"))
            {
                GetReportBasic_Model model = new GetReportBasic_Model();
                string strSqlServiceRevenue = "";
                DataTable dt = new DataTable();
                if (cycleType == 4)
                {
                    startTime += " 0:00:00";
                    endtime += " 23:59:59";
                }

                #region 服务销售额
                switch (objectType)
                {
                    case 0:
                        strSqlServiceRevenue = @"getServiceRevenue";
                        dt = db.SetSpCommand(strSqlServiceRevenue, db.Parameter("@BranchID", branchId, DbType.Int32)
                        , db.Parameter("@SlaveID", accountId, DbType.Int32)
                        , db.Parameter("@cycleType", cycleType, DbType.Int32)
                        , db.Parameter("@startTime", startTime, DbType.String)
                        , db.Parameter("@endtime", endtime, DbType.String)).ExecuteDataTable();
                        break;
                    case 3:
                        strSqlServiceRevenue = @"getServiceRevenueGroup";
                        dt = db.SetSpCommand(strSqlServiceRevenue, db.Parameter("@CompanyID", companyId, DbType.Int32)
                        , db.Parameter("@BranchID", branchId, DbType.Int32)
                        , db.Parameter("@SlaveID", accountId, DbType.Int32)
                        , db.Parameter("@cycleType", cycleType, DbType.Int32)
                        , db.Parameter("@startTime", startTime, DbType.String)
                        , db.Parameter("@endtime", endtime, DbType.String)).ExecuteDataTable();
                        break;
                    default:
                        strSqlServiceRevenue = @"getServiceRevenueDefault";
                        dt = db.SetSpCommand(strSqlServiceRevenue, db.Parameter("@BranchID", branchId, DbType.Int32)
                        , db.Parameter("@cycleType", cycleType, DbType.Int32)
                        , db.Parameter("@startTime", startTime, DbType.String)
                        , db.Parameter("@endtime", endtime, DbType.String)).ExecuteDataTable();
                        break;
                }

                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    int paymentMode = StringUtils.GetDbInt(dt.Rows[i]["PaymentMode"]);
                    decimal paymentAmout = StringUtils.GetDbDecimal(dt.Rows[i]["SalesAmount"]);
                    switch (paymentMode)
                    {
                        case 0:
                            model.ServiceRevenueCash = paymentAmout;
                            break;
                        case 1:
                            model.ServiceRevenueECard = paymentAmout;
                            break;
                        case 2:
                            model.ServiceRevenueBank = paymentAmout;
                            break;
                        case 3:
                            model.ServiceRevenueOther = paymentAmout;
                            break;
                        case 6:
                            model.ServiceRevenuePoint = paymentAmout;
                            break;
                        case 7:
                            model.ServiceRevenueCoupon = paymentAmout;
                            break;
                        case 8:
                            model.ServiceRevenueWeChat = paymentAmout;
                            break;
                        case 9:
                            model.ServiceRevenueAlipay = paymentAmout;
                            break;
                        case 100:
                            model.ServiceRevenueLoan = paymentAmout;
                            break;
                        case 101:
                            model.ServiceRevenueThird = paymentAmout;
                            break;
                    }
                    model.ServiceRevenueAll = StringUtils.GetDbDecimal(dt.Rows[0]["TotalAmount"]);
                }
                #endregion

                #region 商品销售额
                string strSqlCommodityRevenue = "";
                switch (objectType)
                {
                    case 0:
                        strSqlCommodityRevenue = @"getCommodityRevenue";
                        dt = db.SetSpCommand(strSqlCommodityRevenue, db.Parameter("@BranchID", branchId, DbType.Int32)
                        , db.Parameter("@SlaveID", accountId, DbType.Int32)
                        , db.Parameter("@cycleType", cycleType, DbType.Int32)
                        , db.Parameter("@startTime", startTime, DbType.String)
                        , db.Parameter("@endtime", endtime, DbType.String)).ExecuteDataTable();
                        break;
                    case 3:
                        strSqlCommodityRevenue = @"getCommodityRevenueGroup";
                        dt = db.SetSpCommand(strSqlCommodityRevenue, db.Parameter("@CompanyID", companyId, DbType.Int32)
                        , db.Parameter("@BranchID", branchId, DbType.Int32)
                        , db.Parameter("@SlaveID", accountId, DbType.Int32)
                        , db.Parameter("@cycleType", cycleType, DbType.Int32)
                        , db.Parameter("@startTime", startTime, DbType.String)
                        , db.Parameter("@endtime", endtime, DbType.String)).ExecuteDataTable();
                        break;
                    default:
                        strSqlCommodityRevenue = @"getCommodityRevenueDefault";
                        dt = db.SetSpCommand(strSqlCommodityRevenue, db.Parameter("@BranchID", branchId, DbType.Int32)
                        , db.Parameter("@cycleType", cycleType, DbType.Int32)
                        , db.Parameter("@startTime", startTime, DbType.String)
                        , db.Parameter("@endtime", endtime, DbType.String)).ExecuteDataTable();
                        break;
                }

                for (int i = 0; i < dt.Rows.Count; i++)
                {
                    int paymentMode = StringUtils.GetDbInt(dt.Rows[i]["PaymentMode"]);
                    decimal paymentAmout = StringUtils.GetDbDecimal(dt.Rows[i]["SalesAmount"]);
                    switch (paymentMode)
                    {
                        case 0:
                            model.CommodityRevenueCash = paymentAmout;
                            break;
                        case 1:
                            model.CommodityRevenueECard = paymentAmout;
                            break;
                        case 2:
                            model.CommodityRevenueBank = paymentAmout;
                            break;
                        case 3:
                            model.CommodityRevenueOther = paymentAmout;
                            break;
                        case 6:
                            model.CommodityRevenuePoint = paymentAmout;
                            break;
                        case 7:
                            model.CommodityRevenueCoupon = paymentAmout;
                            break;
                        case 8:
                            model.CommodityRevenueWeChat = paymentAmout;
                            break;
                        case 9:
                            model.CommodityRevenueAlipay = paymentAmout;
                            break;
                        case 100:
                            model.CommodityRevenueLoan = paymentAmout;
                            break;
                        case 101:
                            model.CommodityRevenueThird = paymentAmout;
                            break;
                    }
                    model.CommodityRevenueAll = StringUtils.GetDbDecimal(dt.Rows[0]["TotalAmount"]);
                }
                #endregion

                #region 服务商品销售
                //服务商品销售
                List<SalesIncome_Model> list = new List<SalesIncome_Model>();

                model.SalesCashIncome = model.ServiceRevenueCash + model.CommodityRevenueCash;
                model.SalesBankIncome = model.ServiceRevenueBank + model.CommodityRevenueBank;
                model.SalesWeChatIncome = model.ServiceRevenueWeChat + model.CommodityRevenueWeChat;
                model.SalesAlipayIncome = model.ServiceRevenueAlipay + model.CommodityRevenueAlipay;
                model.SalesRevenueLoan = model.ServiceRevenueLoan + model.CommodityRevenueLoan;
                model.SalesRevenueThird = model.ServiceRevenueThird + model.CommodityRevenueThird;
                model.SalesAllIncome = model.SalesCashIncome + model.SalesBankIncome + model.SalesWeChatIncome + model.SalesAlipayIncome + model.SalesRevenueLoan + model.SalesRevenueThird;
                #endregion

                #region 服务操作次数 指定次数 非指定次数
                //一个订单时间内完成的服务数
                string strSqlTreatmentComplete = "";
                switch (objectType)
                {
                    case 0:
                        strSqlTreatmentComplete = @"getTreatmentComplete";
                        list = db.SetSpCommand(strSqlTreatmentComplete, db.Parameter("@BranchID", branchId, DbType.Int32)
                        , db.Parameter("@SlaveID", accountId, DbType.Int32)
                        , db.Parameter("@cycleType", cycleType, DbType.Int32)
                        , db.Parameter("@startTime", startTime, DbType.String)
                        , db.Parameter("@endtime", endtime, DbType.String)).ExecuteList<SalesIncome_Model>();
                        break;
                    case 3:
                        strSqlTreatmentComplete = @"getTreatmentCompleteGroup";
                        list = db.SetSpCommand(strSqlTreatmentComplete, db.Parameter("@CompanyID", companyId, DbType.Int32)
                        , db.Parameter("@BranchID", branchId, DbType.Int32)
                        , db.Parameter("@SlaveID", accountId, DbType.Int32)
                        , db.Parameter("@cycleType", cycleType, DbType.Int32)
                        , db.Parameter("@startTime", startTime, DbType.String)
                        , db.Parameter("@endtime", endtime, DbType.String)).ExecuteList<SalesIncome_Model>();
                        break;
                    default:
                        strSqlTreatmentComplete = @"getTreatmentCompleteDefault";
                        list = db.SetSpCommand(strSqlTreatmentComplete, db.Parameter("@BranchID", branchId, DbType.Int32)
                        , db.Parameter("@cycleType", cycleType, DbType.Int32)
                        , db.Parameter("@startTime", startTime, DbType.String)
                        , db.Parameter("@endtime", endtime, DbType.String)).ExecuteList<SalesIncome_Model>();
                        break;
                }

                //服务操作次数 指定次数 非指定次数
                if (list == null || list.Count == 0)
                {
                    model.TreatmentTimesDesigned = 0;
                    model.TreatmentTimesNotDesigned = 0;
                }
                else
                {
                    foreach (SalesIncome_Model item in list)
                    {
                        switch (item.Type)
                        {
                            case 0:
                                model.TreatmentTimesNotDesigned = StringUtils.GetDbInt(item.Amount);
                                break;
                            case 1:
                                model.TreatmentTimesDesigned = StringUtils.GetDbInt(item.Amount);
                                break;
                        }
                    }
                    model.TreatmentTimesAll = model.TreatmentTimesNotDesigned + model.TreatmentTimesDesigned;
                }
                #endregion

                #region 服务操作业绩  指定业绩  非指定业绩
                list = new List<SalesIncome_Model>();
                string strSqlTreatmentAchievement = "";
                switch (objectType)
                {
                    case 0:
                        strSqlTreatmentAchievement = @"getTreatmentAchievement";
                        list = db.SetSpCommand(strSqlTreatmentAchievement,
                               db.Parameter("@BranchID", branchId, DbType.Int32),
                               db.Parameter("@SlaveID", accountId, DbType.Int32),
                               db.Parameter("@cycleType", cycleType, DbType.Int32),
                               db.Parameter("@startTime", startTime, DbType.String),
                               db.Parameter("@endtime", endtime, DbType.String)).ExecuteList<SalesIncome_Model>();
                        break;
                    case 3:
                        strSqlTreatmentAchievement = @"getTreatmentAchievementGroup";
                        list = db.SetSpCommand(strSqlTreatmentAchievement,
                               db.Parameter("@CompanyID", companyId, DbType.Int32),
                               db.Parameter("@BranchID", branchId, DbType.Int32),
                               db.Parameter("@SlaveID", accountId, DbType.Int32),
                               db.Parameter("@cycleType", cycleType, DbType.Int32),
                               db.Parameter("@startTime", startTime, DbType.String),
                               db.Parameter("@endtime", endtime, DbType.String)).ExecuteList<SalesIncome_Model>();
                        break;
                    default:
                        strSqlTreatmentAchievement = @"getTreatmentAchievementDefault";
                        list = db.SetSpCommand(strSqlTreatmentAchievement,
                               db.Parameter("@BranchID", branchId, DbType.Int32),
                               db.Parameter("@cycleType", cycleType, DbType.Int32),
                               db.Parameter("@startTime", startTime, DbType.String),
                               db.Parameter("@endtime", endtime, DbType.String)).ExecuteList<SalesIncome_Model>();
                        break;
                }

                //服务操作业绩  指定业绩 非指定业绩
                if (list == null || list.Count == 0)
                {
                    model.ServiceAchievementDesigned = 0;
                    model.ServiceAchievementNotDesigned = 0;
                }
                else
                {
                    foreach (SalesIncome_Model item in list)
                    {
                        switch (item.Type)
                        {
                            case 0:
                                model.ServiceAchievementNotDesigned = StringUtils.GetDbDecimal(item.Amount);
                                break;
                            case 1:
                                model.ServiceAchievementDesigned = StringUtils.GetDbDecimal(item.Amount);
                                break;
                        }
                    }
                    model.ServiceAchievementAll = model.ServiceAchievementDesigned + model.ServiceAchievementNotDesigned;
                }
                #endregion

                return model;
            }
        }

        public GetReportDetail_Model getBalanceReportDetail(int accountId, int cycleType, string startTime, string endtime, int branchId, int objectType)
        {

            using (DbManager db = new DbManager("Report"))
            {
                string strSql = @" SELECT T11.Name CustomerName, ISNULL(T9.RechargeAmount,0) RechargeAmount ,ISNULL(T10.PayAmount,0) PayAmount ,ISNULL(T9.RechargeAmount,0)- ISNULL(T10.PayAmount,0) BalanceAmount  
                                FROM [CUSTOMER] T11 with (NOLOCK) 
                                 LEFT JOIN ( 
                                select T1.UserID,SUM(T1.Amount) RechargeAmount from 
                                [TBL_MONEY_BALANCE] T1 with (NOLOCK)
                                {0}
                                 WHERE ((T1.ActionMode = 3 AND (T1.DepositMode = 1 OR T1.DepositMode = 2  OR T1.DepositMode = 4 OR T1.DepositMode = 5 )) OR (T1.ActionMode = 4 AND (T1.DepositMode = 1 OR T1.DepositMode = 2 OR T1.DepositMode = 4  OR T1.DepositMode = 5))) AND T1.BranchID=@BranchID
                                {1}
                                group by T1.UserID ) T9 
                                on T9.UserID = T11.UserID
                                LEFT JOIN  (
                               SELECT T12.CustomerID,SUM(T12.PayAmount) PayAmount FROM (
                                select T6.CustomerID, CASE T4.IsUseRate WHEN 1 THEN SUM( CASE T4.Type WHEN 1 THEN T3.PaymentAmount * T3.ProfitRate ELSE T3.PaymentAmount * -1  * T3.ProfitRate  END) ELSE SUM( CASE T4.Type WHEN 1 THEN T3.PaymentAmount  ELSE T3.PaymentAmount * -1   END) END  PayAmount from [PAYMENT_DETAIL] T3 with (NOLOCK)
                                INNER JOIN [PAYMENT] T4 with (NOLOCK) 
                                ON T3.PaymentID = T4.ID AND  T4.OrderNumber = 1
                                INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T5  with (NOLOCK) 
                                ON T3.PaymentID = T5.PaymentID 
                                INNER JOIN [ORDER] T6 with (NOLOCK) 
                                ON T5.OrderID = T6.ID  AND T6.PaymentStatus > 0 
                                {2}
                                 LEFT JOIN [BRANCH] T8 with (NOLOCK) 
                                ON T4.BranchID = T8.ID   
                                WHERE T3.PaymentMode = 1  AND T4.PaymentTime > T8.StartTime AND T4.BranchID = @BranchID AND ((T4.Type = 1 AND (T4.Status = 2 OR T4.Status = 3)) OR (T4.Type = 2 AND (T4.Status = 6 OR T4.Status = 7)))
                                {3}
                                group by T6.CustomerID ,T4.IsUseRate

UNION ALL 

select T6.CustomerID,CASE T4.IsUseRate WHEN 1 THEN SUM( CASE T4.Type WHEN 1 THEN T6.TotalSalePrice * T3.ProfitRate ELSE T6.TotalSalePrice * -1  * T3.ProfitRate  END) ELSE SUM( CASE T4.Type WHEN 1 THEN T6.TotalSalePrice  ELSE T6.TotalSalePrice * -1   END) END  PayAmount from [PAYMENT_DETAIL] T3 with (NOLOCK)
                                INNER JOIN [PAYMENT] T4 with (NOLOCK) 
                                ON T3.PaymentID = T4.ID AND  T4.OrderNumber > 1
                                INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T5  with (NOLOCK) 
                                ON T3.PaymentID = T5.PaymentID 
                                INNER JOIN [ORDER] T6 with (NOLOCK) 
                                ON T5.OrderID = T6.ID  AND T6.PaymentStatus > 0 
                                {4}
                                 LEFT JOIN [BRANCH] T8 with (NOLOCK) 
                                ON T4.BranchID = T8.ID   
                                WHERE T3.PaymentMode = 1  AND T4.PaymentTime > T8.StartTime AND T4.BranchID = @BranchID AND ((T4.Type = 1 AND (T4.Status = 2 OR T4.Status = 3)) OR (T4.Type = 2 AND (T4.Status = 6 OR T4.Status = 7)))
                                {5}
                                group by T6.CustomerID ,T4.IsUseRate ) T12 GROUP BY T12.CustomerID
) T10 
                                ON T11.UserID = T10.CustomerID 
                                where T9.RechargeAmount is not null or T10.PayAmount is not null
                                order by ISNULL(T9.RechargeAmount,0)- ISNULL(T10.PayAmount,0) desc";

                string strRechargeProfit = "";
                if (objectType == 0)
                {
                    strRechargeProfit = " INNER JOIN [TBL_PROFIT] T2 with (NOLOCK) ON T1.ID = T2.MasterID AND T2.Available = 1 AND T2.Type = 1 AND T2.SlaveID = @SlaveID ";
                }
                string strRechargeTime = Common.SqlCommon.getSqlWhereData(cycleType, startTime, endtime, "T1.CreateTime");
                string strPayProfit = "";

                if (objectType == 0)
                {
                    strPayProfit = " INNER JOIN [TBL_PROFIT] T7 with (NOLOCK) ON T7.MasterID = T3.PaymentID AND T7.Available = 1 AND T7.Type = 2 AND T7.SlaveID = @SlaveID ";
                }
                string strPayTime = Common.SqlCommon.getSqlWhereData(cycleType, startTime, endtime, "T4.PaymentTime");
                string strSqlFinal = string.Format(strSql, strRechargeProfit, strRechargeTime, strPayProfit, strPayTime, strPayProfit, strPayTime);

                List<GetBalanceReportDetail_Model> list = db.SetCommand(strSqlFinal, db.Parameter("@BranchID", branchId, DbType.Int32)
                    , db.Parameter("@SlaveID", accountId, DbType.Int32)).ExecuteList<GetBalanceReportDetail_Model>();

                GetReportDetail_Model model = new GetReportDetail_Model();
                model.BalanceDetail = list;

                return model;
            }
        }



        public GetReportDetail_Model getServiceExecuteDetail(int accountId, int cycleType, string startTime, string endtime, int branchId, int objectType, int sortType, int companyId, int StatementCategoryID)
        {
            using (DbManager db = new DbManager("Report"))
            {
                GetProductReportDetail_Model model = new GetProductReportDetail_Model();
                List<GetProductDetailList_Model> list = new List<GetProductDetailList_Model>();
                string strSqlFinal = "";

                #region 服务操作金额/次数分析（服务操作分析）
                if (cycleType == 4)
                {
                    startTime += " 0:00:00";
                    endtime += " 23:59:59";
                }
                switch (objectType)
                {
                    case 0:
                        strSqlFinal = @"getServiceExecuteDetail";
                        list = db.SetSpCommand(strSqlFinal
                            , db.Parameter("@BranchID", branchId, DbType.Int32)
                            , db.Parameter("@SlaveID", accountId, DbType.Int32)
                            , db.Parameter("@cycleType", cycleType, DbType.Int32)
                            , db.Parameter("@startTime", startTime, DbType.String)
                            , db.Parameter("@endtime", endtime, DbType.String)
                            , db.Parameter("@sortType", sortType, DbType.Int32)).ExecuteList<GetProductDetailList_Model>();
                        break;
                    case 3:
                        strSqlFinal = @"getServiceExecuteDetailGroup";
                        list = db.SetSpCommand(strSqlFinal
                            , db.Parameter("@CompanyID", companyId, DbType.Int32)
                            , db.Parameter("@BranchID", branchId, DbType.Int32)
                            , db.Parameter("@SlaveID", accountId, DbType.Int32)
                            , db.Parameter("@cycleType", cycleType, DbType.Int32)
                            , db.Parameter("@startTime", startTime, DbType.String)
                            , db.Parameter("@endtime", endtime, DbType.String)
                            , db.Parameter("@sortType", sortType, DbType.Int32)).ExecuteList<GetProductDetailList_Model>();
                        break;
                    default:
                        strSqlFinal = @"getServiceExecuteDetailDefault";
                        list = db.SetSpCommand(strSqlFinal
                            , db.Parameter("@BranchID", branchId, DbType.Int32)
                            , db.Parameter("@cycleType", cycleType, DbType.Int32)
                            , db.Parameter("@startTime", startTime, DbType.String)
                            , db.Parameter("@endtime", endtime, DbType.String)
                            , db.Parameter("@sortType", sortType, DbType.Int32)).ExecuteList<GetProductDetailList_Model>();
                        break;
                }


                foreach (GetProductDetailList_Model item in list)
                {
                    model.AllQuantity = item.TotalQuantity;
                    model.AllTotalPrice = item.Total;
                    item.QuantityScale = Math.Round(StringUtils.GetDbDecimal(item.Quantity / model.AllQuantity) * 100, 2).ToString() + " %";
                    if (model.AllTotalPrice == 0)
                    {
                        item.TotalPriceScale = item.QuantityScale;
                    }
                    else
                    {
                        item.TotalPriceScale = Math.Round(StringUtils.GetDbDecimal(item.TotalPrice / model.AllTotalPrice) * 100, 2).ToString() + " %";
                    }
                }

                model.ProductDetail = new List<GetProductDetailList_Model>();
                model.ProductDetail = list;

                GetReportDetail_Model res = new GetReportDetail_Model();
                res.ProductDetail = model;
                #endregion

                return res;
            }
        }

        public GetReportDetail_Model getCustomerTreatmentDetail(int accountId, int cycleType, string startTime, string endtime, int branchId, int objectType, int companyId, int StatementCategoryID)
        {
            using (DbManager db = new DbManager("Report"))
            {
                GetProductReportDetail_Model model = new GetProductReportDetail_Model();
                List<GetProductDetailList_Model> list = new List<GetProductDetailList_Model>();
                string strSqlFinal = "";
                #region 服务操作金额/次数分析（顾客消费分析）
                if (cycleType == 4)
                {
                    startTime += " 0:00:00";
                    endtime += " 23:59:59";
                }
                switch (objectType)
                {
                    case 0:
                        strSqlFinal = @"getCustomerTreatmentDetail";
                        list = db.SetSpCommand(strSqlFinal
                            , db.Parameter("@BranchID", branchId, DbType.Int32)
                            , db.Parameter("@SlaveID", accountId, DbType.Int32)
                            , db.Parameter("@cycleType", cycleType, DbType.Int32)
                            , db.Parameter("@startTime", startTime, DbType.String)
                            , db.Parameter("@endtime", endtime, DbType.String)).ExecuteList<GetProductDetailList_Model>();
                        break;
                    case 3:
                        strSqlFinal = @"getCustomerTreatmentDetailGroup";
                        list = db.SetSpCommand(strSqlFinal
                            , db.Parameter("@CompanyID", companyId, DbType.Int32)
                            , db.Parameter("@BranchID", branchId, DbType.Int32)
                            , db.Parameter("@SlaveID", accountId, DbType.Int32)
                            , db.Parameter("@cycleType", cycleType, DbType.Int32)
                            , db.Parameter("@startTime", startTime, DbType.String)
                            , db.Parameter("@endtime", endtime, DbType.String)).ExecuteList<GetProductDetailList_Model>();
                        break;
                    default:
                        strSqlFinal = @"getCustomerTreatmentDetailDefault";
                        list = db.SetSpCommand(strSqlFinal
                            , db.Parameter("@BranchID", branchId, DbType.Int32)
                            , db.Parameter("@cycleType", cycleType, DbType.Int32)
                            , db.Parameter("@startTime", startTime, DbType.String)
                            , db.Parameter("@endtime", endtime, DbType.String)).ExecuteList<GetProductDetailList_Model>();
                        break;
                }

                foreach (GetProductDetailList_Model item in list)
                {
                    model.AllQuantity = item.TotalQuantity;
                    model.AllTotalPrice = item.Total;
                    item.QuantityScale = Math.Round(StringUtils.GetDbDecimal(item.Quantity / model.AllQuantity) * 100, 2).ToString() + " %";
                    if (model.AllTotalPrice == 0)
                    {
                        item.TotalPriceScale = item.QuantityScale;
                    }
                    else
                    {
                        item.TotalPriceScale = Math.Round(StringUtils.GetDbDecimal(item.TotalPrice / model.AllTotalPrice) * 100, 2).ToString() + " %";
                    }
                }

                model.ProductDetail = new List<GetProductDetailList_Model>();
                model.ProductDetail = list;

                GetReportDetail_Model res = new GetReportDetail_Model();
                res.ProductDetail = model;
                #endregion

                return res;
            }
        }

        public GetBranchBusinessDetail_Model getBranchBusinessDetail(int cycleType, string startTime, string endtime, int branchId, int companyId)
        {
            using (DbManager db = new DbManager("Report"))
            {
                GetBranchBusinessDetail_Model model = new GetBranchBusinessDetail_Model();

                #region 顾客数量
                string strSqlCustomerCount = @"  select count(0) from (SELECT distinct T2.CustomerID FROM [TBL_TREATGROUP] T1 INNER JOIN [TBL_ORDER_SERVICE] T2 ON T1.OrderID = T2.OrderID AND T2.Status <> 3
                                                INNER JOIN [ORDER] T4 ON T2.OrderID = T4.ID AND T4.RecordType = 1
                                                LEFT JOIN [BRANCH] T5 ON T4.BranchID = T5.ID
                                                WHERE T1.CompanyID=@CompanyID AND T1.BranchID =@BranchID and  T1.TGStatus <> 3  AND T4.OrderTime > T5.StartTime {0} ) T3  ";

                string strData = Common.SqlCommon.getSqlWhereData(cycleType, startTime, endtime, "T1.TGStartTime");

                strSqlCustomerCount = string.Format(strSqlCustomerCount, strData);

                model.CustomerCount = db.SetCommand(strSqlCustomerCount
                    , db.Parameter("@BranchID", branchId, DbType.Int32)
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteScalar<int>();

                #endregion

                #region 各种服务
                //进行中
                string strSqlExecutingCount = @" SELECT COUNT(0) TGCount  FROM [TBL_TREATGROUP] T1 INNER JOIN [TBL_ORDER_SERVICE] T2 ON T1.OrderID = T2.OrderID 
                                            INNER JOIN [ORDER] T4 ON T2.OrderID = T4.ID AND T4.RecordType = 1
                                            LEFT JOIN [BRANCH] T5 ON T4.BranchID = T5.ID
                                            WHERE T1.CompanyID=@CompanyID AND T1.BranchID =@BranchID  AND T4.OrderTime > T5.StartTime AND  T1.TGStatus = 1 and (T2.Status = 1 OR T2.Status = 2 OR T2.Status = 5) {0}  ";


                strSqlExecutingCount = string.Format(strSqlExecutingCount, strData);

                model.TGExecutingCount = db.SetCommand(strSqlExecutingCount
                    , db.Parameter("@BranchID", branchId, DbType.Int32)
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteScalar<int>();



                string strSqlTGAllKindsCount = @"  SELECT COUNT(0) TGCount,T1.TGStatus FROM [TBL_TREATGROUP] T1 INNER JOIN [TBL_ORDER_SERVICE] T2 ON T1.OrderID = T2.OrderID 
                                            INNER JOIN [ORDER] T4 ON T2.OrderID = T4.ID AND T4.RecordType = 1
                                            LEFT JOIN [BRANCH] T5 ON T4.BranchID = T5.ID
                                            WHERE T1.CompanyID=@CompanyID AND T1.BranchID =@BranchID  AND T4.OrderTime > T5.StartTime AND  (T1.TGStatus = 2 or T1.TGStatus =5)  {0} Group by T1.TGStatus  ";

                strData = Common.SqlCommon.getSqlWhereData(cycleType, startTime, endtime, "T1.TGEndTime");
                strSqlTGAllKindsCount = string.Format(strSqlTGAllKindsCount, strData);
                List<GetAllKindsTG> listTG = db.SetCommand(strSqlTGAllKindsCount
                    , db.Parameter("@BranchID", branchId, DbType.Int32)
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteList<GetAllKindsTG>();

                if (listTG != null && listTG.Count > 0)
                {
                    int finishCount = 0;
                    foreach (GetAllKindsTG item in listTG)
                    {
                        switch (item.TGStatus)
                        {
                            case 2:
                                model.TGFinishedCount = item.TGCount;
                                break;
                            case 5:
                                model.TGUnConfirmed = item.TGCount;
                                break;
                        }
                        model.TGFinishedCount += model.TGUnConfirmed;
                    }

                }
                else
                {
                    model.TGFinishedCount = 0;
                    model.TGUnConfirmed = 0;
                }

                #endregion

                #region 服务订单数量
                string strSqlServiceOrder = @" select Count(0) from [ORDER] T1 INNER JOIN [TBL_ORDER_SERVICE] T2 ON T1.ID = T2.OrderID AND T1.ProductType = 0 AND T2.Status <> 3 
 left join [BRANCH] T3 ON T1.BranchID = T3.ID  WHERE T1.CompanyID=@CompanyID AND T1.BranchID = @BranchID AND T1.RecordType = 1 AND T1.OrderTime > T3.StartTime  {0} ";

                strData = Common.SqlCommon.getSqlWhereData(cycleType, startTime, endtime, "T1.OrderTime");

                strSqlServiceOrder = string.Format(strSqlServiceOrder, strData);

                model.ServiceOrder = db.SetCommand(strSqlServiceOrder
                    , db.Parameter("@BranchID", branchId, DbType.Int32)
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteScalar<int>();

                #endregion


                #region 商品订单数量
                string strSqlCommodityOrder = @" select Count(0) from [ORDER] T1 INNER JOIN [TBL_ORDER_COMMODITY] T2 ON T1.ID = T2.OrderID AND T1.ProductType = 1 AND T2.Status <> 3  left join [BRANCH] T3 ON T1.BranchID = T3.ID WHERE T1.CompanyID=@CompanyID AND T1.BranchID = @BranchID AND T1.RecordType = 1 AND T1.OrderTime > T3.StartTime   {0} ";


                strSqlCommodityOrder = string.Format(strSqlCommodityOrder, strData);

                model.CommodityOrder = db.SetCommand(strSqlCommodityOrder
                    , db.Parameter("@BranchID", branchId, DbType.Int32)
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteScalar<int>();

                #endregion


                #region 总营业额
                string strSqlSalesProduct = @"SELECT SUM(T6.PaymentAmount) FROM
                                            ( select SUM( CASE T2.Type WHEN 1 THEN T1.PaymentAmount ELSE T1.PaymentAmount * -1 END) PaymentAmount 
                                            from [PAYMENT_DETAIL] T1 
                                            INNER JOIN [PAYMENT] T2 
                                            ON T1.PaymentID= T2.ID AND T2.CompanyID=@CompanyID AND T2.BranchID=@BranchID AND T2.OrderNumber = 1 
                                            INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T3 
                                            ON T1.PaymentID = T3.PaymentID 
                                            INNER JOIN [ORDER] T4 
                                            ON T3.OrderID = T4.ID 
                                            LEFT JOIN [BRANCH] T5  
                                            ON T2.BranchID = T5.ID  
                                            WHERE (T1.PaymentMode = 0 OR T1.PaymentMode = 2  OR T1.PaymentMode = 8  OR T1.PaymentMode = 9 OR T1.PaymentMode = 100 OR T1.PaymentMode = 101) AND T2.PaymentTime > T5.StartTime AND ((T2.Type = 1 AND (T2.Status = 2 OR T2.Status = 3)) OR (T2.Type = 2 AND (T2.Status = 6 OR T2.Status = 7))) {0}
                                            UNION ALL 
                                            select SUM(CASE T2.Type WHEN 1 THEN T4.TotalSalePrice  ELSE T4.TotalSalePrice  * -1 END) PaymentAmount 
                                            from [PAYMENT_DETAIL] T1 
                                            INNER JOIN [PAYMENT] T2 
                                            ON T1.PaymentID= T2.ID AND T2.CompanyID=@CompanyID AND T2.BranchID=@BranchID AND T2.OrderNumber > 1 
                                            INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T3 
                                            ON T1.PaymentID = T3.PaymentID 
                                            INNER JOIN [ORDER] T4 
                                            ON T3.OrderID = T4.ID 
                                            LEFT JOIN [BRANCH] T5  ON T2.BranchID = T5.ID  
                                            WHERE (T1.PaymentMode = 0 OR T1.PaymentMode = 2 OR T1.PaymentMode = 8  OR T1.PaymentMode = 9 OR T1.PaymentMode = 100 OR T1.PaymentMode = 101) AND T2.PaymentTime > T5.StartTime 
											AND ((T2.Type = 1 AND (T2.Status = 2 OR T2.Status = 3)) OR (T2.Type = 2 AND (T2.Status = 6 OR T2.Status = 7))) {0} ) T6";

                strData = Common.SqlCommon.getSqlWhereData(cycleType, startTime, endtime, "T2.PaymentTime");

                strSqlSalesProduct = string.Format(strSqlSalesProduct, strData);

                decimal salesProduct = db.SetCommand(strSqlSalesProduct
                    , db.Parameter("@BranchID", branchId, DbType.Int32)
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteScalar<decimal>();


                string strSqlSalesRecharge = @" select SUM(T2.Amount) from [TBL_CUSTOMER_BALANCE] T1 INNER JOIN [TBL_MONEY_BALANCE] T2 ON T1.ID = T2.CustomerBalanceID AND T1.TargetAccount = 1   WHERE T1.CompanyID =@CompanyID AND T1.BranchID=@BranchID  AND ((T2.ActionMode = 3 AND (T2.DepositMode = 1 OR T2.DepositMode = 2 OR T2.DepositMode = 4  OR T2.DepositMode = 5)) OR (T2.ActionMode = 4 AND (T2.DepositMode = 1 OR T2.DepositMode = 2)))    {0} ";

                strData = Common.SqlCommon.getSqlWhereData(cycleType, startTime, endtime, "T1.CreateTime");

                strSqlSalesRecharge = string.Format(strSqlSalesRecharge, strData);

                decimal salesRecharge = db.SetCommand(strSqlSalesRecharge
                    , db.Parameter("@BranchID", branchId, DbType.Int32)
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteScalar<decimal>();

                model.SalesAmount = salesProduct + salesRecharge;

                #endregion

                #region 取消的订单
                string strSqlServiceCancel = @" select count(0) from [TBL_ORDER_SERVICE] T1 
                                            INNER JOIN [ORDER] T2 ON T1.OrderID = T2.ID 
                                            LEFT JOIN [BRANCH] T3 ON T1.BranchID = T3.ID
                                            where T1.Status = 3 and T1.CompanyID=@CompanyID and T1.BranchID=@BranchID AND T2.OrderTime > T3.StartTime {0} ";

                strData = Common.SqlCommon.getSqlWhereData(cycleType, startTime, endtime, "T2.OrderTime");

                strSqlServiceCancel = string.Format(strSqlServiceCancel, strData);

                model.ServiceCancelCount = db.SetCommand(strSqlServiceCancel
                    , db.Parameter("@BranchID", branchId, DbType.Int32)
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteScalar<int>();

                string strSqlCommodityCancel = @" select count(0) from [TBL_ORDER_COMMODITY] T1 
                                            INNER JOIN [ORDER] T2 ON T1.OrderID = T2.ID 
                                            LEFT JOIN [BRANCH] T3 ON T1.BranchID = T3.ID
                                            where T1.Status = 3 and T1.CompanyID=@CompanyID and T1.BranchID=@BranchID AND T2.OrderTime > T3.StartTime {0} ";

                strData = Common.SqlCommon.getSqlWhereData(cycleType, startTime, endtime, "T2.OrderTime");

                strSqlCommodityCancel = string.Format(strSqlCommodityCancel, strData);

                model.CommodityCancelCount = db.SetCommand(strSqlCommodityCancel
                    , db.Parameter("@BranchID", branchId, DbType.Int32)
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteScalar<int>();

                #endregion


                return model;
            }
        }

        public GetReportBasic_Model getCustomerBasic(int accountId, int branchId, int objectType, int cycleType, string startTime, string endtime, int companyId)
        {
            using (DbManager db = new DbManager("Report"))
            {
                GetReportBasic_Model model = new GetReportBasic_Model();

                string StartTime = startTime;
                string EndTime = endtime;
                if (cycleType == 4)
                {
                    StartTime = startTime + " 0:00:00";
                    EndTime = endtime + " 23:59:59";
                }

                #region 新增顾客
                string strSqlNewAddCustomer = "";
                object obj = new Object();
                switch (objectType)
                {
                    case 0:
                        strSqlNewAddCustomer = @"NewAddCustomer";
                        obj = db.SetSpCommand(strSqlNewAddCustomer, db.Parameter("@BranchID", branchId, DbType.Int32)
                        , db.Parameter("@accountId", accountId, DbType.Int32)
                        , db.Parameter("@cycleType", cycleType, DbType.Int32)
                        , db.Parameter("@startTime", StartTime, DbType.String)
                        , db.Parameter("@endtime", EndTime, DbType.String)).ExecuteScalar();
                        break;
                    case 3:
                        strSqlNewAddCustomer = @"NewAddCustomerGroup";
                        obj = db.SetSpCommand(strSqlNewAddCustomer, db.Parameter("@CompanyID", companyId, DbType.Int32)
                        , db.Parameter("@BranchID", branchId, DbType.Int32)
                        , db.Parameter("@accountId", accountId, DbType.Int32)
                        , db.Parameter("@cycleType", cycleType, DbType.Int32)
                        , db.Parameter("@startTime", StartTime, DbType.String)
                        , db.Parameter("@endtime", EndTime, DbType.String)).ExecuteScalar();
                        break;
                    default:
                        strSqlNewAddCustomer = @"NewAddCustomerDefault";
                        obj = db.SetSpCommand(strSqlNewAddCustomer, db.Parameter("@BranchID", branchId, DbType.Int32)
                        , db.Parameter("@cycleType", cycleType, DbType.Int32)
                        , db.Parameter("@startTime", StartTime, DbType.String)
                        , db.Parameter("@endtime", EndTime, DbType.String)).ExecuteScalar();
                        break;
                }
                model.NewAddCustomer = StringUtils.GetDbInt(obj);
                #endregion

                #region 新增顾客
                string strSqlNewAddEffectCustomer = "";
                switch (objectType)
                {
                    case 0:
                        strSqlNewAddEffectCustomer = @"NewAddEffectCustomer";
                        obj = db.SetSpCommand(strSqlNewAddEffectCustomer, db.Parameter("@BranchID", branchId, DbType.Int32)
                        , db.Parameter("@accountId", accountId, DbType.Int32)
                        , db.Parameter("@cycleType", cycleType, DbType.Int32)
                        , db.Parameter("@startTime", StartTime, DbType.String)
                        , db.Parameter("@endtime", EndTime, DbType.String)).ExecuteScalar();
                        break;
                    case 3:
                        strSqlNewAddEffectCustomer = @"NewAddEffectCustomerGroup";
                        obj = db.SetSpCommand(strSqlNewAddEffectCustomer, db.Parameter("@CompanyID", companyId, DbType.Int32)
                        , db.Parameter("@BranchID", branchId, DbType.Int32)
                        , db.Parameter("@accountId", accountId, DbType.Int32)
                        , db.Parameter("@cycleType", cycleType, DbType.Int32)
                        , db.Parameter("@startTime", StartTime, DbType.String)
                        , db.Parameter("@endtime", EndTime, DbType.String)).ExecuteScalar();
                        break;
                    default:
                        strSqlNewAddEffectCustomer = @"NewAddEffectCustomerDefault";
                        obj = db.SetSpCommand(strSqlNewAddEffectCustomer, db.Parameter("@BranchID", branchId, DbType.Int32)
                        , db.Parameter("@cycleType", cycleType, DbType.Int32)
                        , db.Parameter("@startTime", StartTime, DbType.String)
                        , db.Parameter("@endtime", EndTime, DbType.String)).ExecuteScalar();
                        break;
                }
                model.NewAddEffectCustomer = StringUtils.GetDbInt(obj);
                #endregion

                #region 老顾客
                string strSqlOldEffectCustomer = "";
                DateTime start = Common.SqlCommon.getStartTime(cycleType, startTime);
                switch (objectType)
                {
                    case 0:
                        strSqlOldEffectCustomer = @"OldEffectCustomer";
                        obj = db.SetSpCommand(strSqlOldEffectCustomer, db.Parameter("@BranchID", branchId, DbType.Int32)
                        , db.Parameter("@accountId", accountId, DbType.Int32)
                        , db.Parameter("@cycleType", cycleType, DbType.Int32)
                        , db.Parameter("@startTime", StartTime, DbType.String)
                        , db.Parameter("@endtime", EndTime, DbType.String)
                        , db.Parameter("@StartDate", start, DbType.DateTime)).ExecuteScalar();
                        break;
                    case 3:
                        strSqlOldEffectCustomer = @"OldEffectCustomerGroup";
                        obj = db.SetSpCommand(strSqlOldEffectCustomer, db.Parameter("@CompanyID", companyId, DbType.Int32)
                        , db.Parameter("@BranchID", branchId, DbType.Int32)
                        , db.Parameter("@accountId", accountId, DbType.Int32)
                        , db.Parameter("@cycleType", cycleType, DbType.Int32)
                        , db.Parameter("@startTime", StartTime, DbType.String)
                        , db.Parameter("@endtime", EndTime, DbType.String)
                        , db.Parameter("@StartDate", start, DbType.DateTime)).ExecuteScalar();
                        break;
                    default:
                        strSqlOldEffectCustomer = @"OldEffectCustomerDefault";
                        obj = db.SetSpCommand(strSqlOldEffectCustomer, db.Parameter("@BranchID", branchId, DbType.Int32)
                        , db.Parameter("@cycleType", cycleType, DbType.Int32)
                        , db.Parameter("@startTime", StartTime, DbType.String)
                        , db.Parameter("@endtime", EndTime, DbType.String)
                        , db.Parameter("@StartDate", start, DbType.DateTime)).ExecuteScalar();
                        break;
                }
                model.OldEffectCustomer = StringUtils.GetDbInt(obj);
                #endregion

                #region 服务客数
                List<SalesIncome_Model> list = new List<SalesIncome_Model>();
                string strSqlCustomerGenderFinal = "";
                switch (objectType)
                {
                    case 0:
                        strSqlCustomerGenderFinal = @"CustomerGender";
                        list = db.SetSpCommand(strSqlCustomerGenderFinal, db.Parameter("@BranchID", branchId, DbType.Int32)
                        , db.Parameter("@accountId", accountId, DbType.Int32)
                        , db.Parameter("@cycleType", cycleType, DbType.Int32)
                        , db.Parameter("@startTime", StartTime, DbType.String)
                        , db.Parameter("@endtime", EndTime, DbType.String)).ExecuteList<SalesIncome_Model>();
                        break;
                    case 3:
                        strSqlCustomerGenderFinal = @"CustomerGenderGroup";
                        list = db.SetSpCommand(strSqlCustomerGenderFinal, db.Parameter("@CompanyID", companyId, DbType.Int32)
                        , db.Parameter("@BranchID", branchId, DbType.Int32)
                        , db.Parameter("@accountId", accountId, DbType.Int32)
                        , db.Parameter("@cycleType", cycleType, DbType.Int32)
                        , db.Parameter("@startTime", StartTime, DbType.String)
                        , db.Parameter("@endtime", EndTime, DbType.String)).ExecuteList<SalesIncome_Model>();
                        break;
                    default:
                        strSqlCustomerGenderFinal = @"CustomerGenderDefault";
                        list = db.SetSpCommand(strSqlCustomerGenderFinal, db.Parameter("@BranchID", branchId, DbType.Int32)
                        , db.Parameter("@cycleType", cycleType, DbType.Int32)
                        , db.Parameter("@startTime", StartTime, DbType.String)
                        , db.Parameter("@endtime", EndTime, DbType.String)).ExecuteList<SalesIncome_Model>();
                        break;
                }
                #endregion

                if (list == null || list.Count == 0)
                {
                    model.ServiceCustomerCountFemale = 0;
                    model.ServiceCustomerCountMale = 0;
                    model.ServiceCustomerCountUnknow = 0;
                }
                else
                {
                    foreach (SalesIncome_Model item in list)
                    {
                        switch (item.Type)
                        {
                            case 0:
                                model.ServiceCustomerCountFemale = StringUtils.GetDbInt(item.Amount);
                                break;
                            case 1:
                                model.ServiceCustomerCountMale = StringUtils.GetDbInt(item.Amount);
                                break;
                            case 2:
                                model.ServiceCustomerCountUnknow = StringUtils.GetDbInt(item.Amount);
                                break;
                        }
                    }
                }
                model.ServiceCustomerCountAll = model.ServiceCustomerCountFemale + model.ServiceCustomerCountMale + model.ServiceCustomerCountUnknow;

                return model;
            }
        }

        public GetReportBasic_Model getEcardBasic(int accountId, int branchId, int objectType, int cycleType, string startTime, string endtime, int companyId)
        {
            using (DbManager db = new DbManager("Report"))
            {
                GetReportBasic_Model model = new GetReportBasic_Model();
                string strResponsible = "";
                if (objectType == 1)
                {
                    string strSqlEcardConsume = @" SELECT SUM(T6.PaymentAmount) FROM (
                                            select  CASE T2.IsUseRate WHEN 1 THEN  SUM( CASE T2.Type WHEN 1 THEN T1.PaymentAmount * T1.ProfitRate ELSE T1.PaymentAmount * -1  * T1.ProfitRate END) ELSE SUM( CASE T2.Type WHEN 1 THEN T1.PaymentAmount  ELSE T1.PaymentAmount * -1  END) END  PaymentAmount from 
                                            [PAYMENT_DETAIL] T1 INNER JOIN [PAYMENT] T2 
                                            ON T1.PaymentID = T2.ID AND   T2.OrderNumber = 1 
                                            INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T3 
                                            ON T1.PaymentID = T3.PaymentID 
                                            INNER JOIN [ORDER] T4 
                                            ON T3.OrderID = T4.ID AND T4.PaymentStatus > 0 
                                             {0}
                                            LEFT JOIN [BRANCH] T5 
                                            ON T2.BranchID = T5.ID 
                                            WHERE  T1.PaymentMode = 1  AND T2.BranchID=@BranchID  AND  ((T2.Type = 1 AND (T2.Status = 2 OR T2.Status = 3)) OR (T2.Type = 2 AND (T2.Status = 6 OR T2.Status = 7)))  
                                            {1}
                                             GROUP BY T2.IsUseRate
                                            UNION ALL
                                            select CASE T2.IsUseRate WHEN 1 THEN  SUM( CASE T2.Type WHEN 1 THEN T4.TotalSalePrice  * T1.ProfitRate  ELSE T4.TotalSalePrice  * -1  * T1.ProfitRate END) ELSE SUM( CASE T2.Type WHEN 1 THEN T4.TotalSalePrice   ELSE T4.TotalSalePrice  * -1  END) END PaymentAmount from 
                                            [PAYMENT_DETAIL] T1 INNER JOIN [PAYMENT] T2 
                                            ON T1.PaymentID = T2.ID  AND T2.OrderNumber > 1 
                                            INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T3 
                                            ON T1.PaymentID = T3.PaymentID 
                                            INNER JOIN [ORDER] T4 
                                            ON T3.OrderID = T4.ID AND T4.PaymentStatus > 0 
                                             {2}
                                            LEFT JOIN [BRANCH] T5 
                                            ON T2.BranchID = T5.ID 
                                            WHERE  T1.PaymentMode = 1 AND T4.OrderTime > T5.StartTime AND T2.BranchID=@BranchID AND  ((T2.Type = 1 AND (T2.Status = 2 OR T2.Status = 3)) OR (T2.Type = 2 AND (T2.Status = 6 OR T2.Status = 7)))   
                                            {3} 
                                             GROUP BY T2.IsUseRate) T6 ";

                    string strData = Common.SqlCommon.getSqlWhereData(cycleType, startTime, endtime, "T2.PaymentTime");

                    string strSqlEcardConsumeFinal = string.Format(strSqlEcardConsume, strResponsible, strData, strResponsible, strData);

                    model.ECardConsume = db.SetCommand(strSqlEcardConsumeFinal,
                        db.Parameter("@BranchID", branchId, DbType.Int32),
                        db.Parameter("@SlaveID", accountId, DbType.Int32)).ExecuteScalar<decimal>();


                    string strSqlEcard = @" SELECT SUM(T2.Amount) FROM [TBL_CUSTOMER_BALANCE] T1 INNER JOIN [TBL_MONEY_BALANCE] T2 ON T1.ID = T2.CustomerBalanceID ";
                    strSqlEcard += @" RIGHT JOIN [BRANCH] T4 WITH(NOLOCK) 
                                      ON T1.BranchID=T4.ID WHERE T1.TargetAccount = 1 AND T1.BranchID=@BranchID AND (T2.ActionMode = 3 OR T2.ActionMode = 4) and T2.DepositMode <> 3
                                        ";
                    strData = Common.SqlCommon.getSqlWhereData(cycleType, startTime, endtime, "T1.CreateTime");
                    if (strData != "")
                    {
                        strSqlEcard += strData;
                    }
                    model.ECardSales = db.SetCommand(strSqlEcard, db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteScalar<decimal>();


                    model.ECardBalance = model.ECardSales - model.ECardConsume;


                    string strSqlEcardIncome = @" SELECT SUM(T1.Amount) Amount,T1.DepositMode Type FROM [TBL_MONEY_BALANCE] T1 WITH (NOLOCK) where (T1.ActionMode = 3 OR T1.ActionMode = 4) AND (T1.DepositMode = 1 OR T1.DepositMode = 2 OR T1.DepositMode = 4 OR T1.DepositMode = 5) and T1.BranchID=@BranchID {0} GROUP BY T1.DepositMode ";
                    string strSqlEcardIncomeFinal = string.Format(strSqlEcardIncome, strData);
                    List<SalesIncome_Model> list = new List<SalesIncome_Model>();
                    list = db.SetCommand(strSqlEcardIncomeFinal, db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteList<SalesIncome_Model>();

                    if (list != null && list.Count > 0)
                    {
                        foreach (SalesIncome_Model item in list)
                        {
                            switch (item.Type)
                            {
                                case 1:
                                    model.EcardSalesCashIncome = item.Amount;
                                    break;
                                case 2:
                                    model.EcardSalesBankIncome = item.Amount;
                                    break;
                                case 4:
                                    model.EcardWeChatIncome = item.Amount;
                                    break;
                                case 5:
                                    model.EcardAlipayIncome = item.Amount;
                                    break;
                            }
                        }
                        model.EcardSalesAllIncome = model.EcardSalesCashIncome + model.EcardSalesBankIncome + model.EcardWeChatIncome + model.EcardAlipayIncome;
                    }

                }
                return model;
            }
        }

        public List<CardInfo_Model> getCardInfo(int CompanyID, int BranchID)
        {
            using (DbManager db = new DbManager("Report"))
            {
                string strSql = @" SELECT T1.ID CardID ,T1.CardName,ISNULL(T4.AllCount,0) AllCount,ISNULL(T6.HaveBalance,0) HaveBalance,ISNULL(T8.Balance,0) Balance FROM [MST_CARD] T1 INNER JOIN [MST_CARD_BRANCH] T2 ON T1.ID = T2.CardID AND T2.BranchID=@BranchID 
                                    LEFT JOIN (SELECT T3.CardID,COUNT(T3.UserCardNo) AllCount FROM [TBL_CUSTOMER_CARD] T3 WHERE T3.CompanyID=@CompanyID GROUP BY T3.CardID ) T4 ON T1.ID= T4.CardID
                                    
                                    LEFT JOIN (SELECT T5.CardID,COUNT(T5.UserCardNo) HaveBalance FROM [TBL_CUSTOMER_CARD] T5 WHERE T5.CompanyID=@CompanyID AND T5.Balance > 0 GROUP BY T5.CardID ) T6 ON T1.ID= T6.CardID
                                    
                                    LEFT JOIN (SELECT T7.CardID,SUM(T7.Balance) Balance FROM [TBL_CUSTOMER_CARD] T7 WHERE T7.CompanyID=@CompanyID AND T7.Balance > 0 GROUP BY T7.CardID ) T8 ON T1.ID= T8.CardID
                                    
                                    WHERE T1.CompanyID=@CompanyID ";

                List<CardInfo_Model> list = new List<CardInfo_Model>();
                list = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32), db.Parameter("@BranchID", BranchID, DbType.Int32)).ExecuteList<CardInfo_Model>();

                return list;
            }
        }



        public GetCommissionProfit_Model GetAccountCommProfit(int CompanyID, int AccountID, string startTime, string endtime, int BranchID)
        {
            using (DbManager db = new DbManager("Report"))
            {
                #region 取提成信息
                string strSql = @"GetAccountCommProfit";
                List<GetAccountCommissionProfit_Model> list = new List<GetAccountCommissionProfit_Model>();
                list = db.SetSpCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                     , db.Parameter("@BranchID", BranchID, DbType.Int32)
                     , db.Parameter("@AccountID", AccountID, DbType.Int32)
                     , db.Parameter("@startTime", startTime + " 0:00:00", DbType.Int32)
                     , db.Parameter("@endtime", endtime + " 23:59:59", DbType.String)).ExecuteList<GetAccountCommissionProfit_Model>();
                #endregion

                #region 取得员工提成规则信息
                string strSqlRule = @"GetAccountCommProfitRule";
                DataTable dtRule = db.SetSpCommand(strSqlRule, db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteDataTable();
                #endregion

                #region 取得明细数量
                string strSqlOpCount = @"GetAccountCommProfitOpCount";
                DataTable dtOpCount = db.SetSpCommand(strSqlOpCount, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                    , db.Parameter("@BranchID", BranchID, DbType.Int32)
                                    , db.Parameter("@BeginDay", startTime + " 0:00:00", DbType.Int32)
                                    , db.Parameter("@EndDay", endtime + " 23:59:59", DbType.String)).ExecuteDataTable();
                #endregion

                GetCommissionProfit_Model model = new GetCommissionProfit_Model();
                if (list != null && list.Count > 0)
                {
                    model.ObjectName = list[0].AccountName;
                    foreach (GetAccountCommissionProfit_Model item in list)
                    {
                        switch (item.SourceType)
                        {
                            #region 销售提成
                            case 1:
                                model.SalesProfit = item.AccountProfit;
                                if (dtRule != null && dtRule.Rows.Count > 0)
                                {
                                    DataRow[] drRule = dtRule.Select("AccountID=" + AccountID + " AND CommType = 1 ");
                                    if (drRule != null && drRule.Length > 0)
                                    {
                                        if (StringUtils.GetDbInt(drRule[0]["CommPattern"]) == 2)
                                        {
                                            #region 按业绩目标提成
                                            if (model.SalesProfit > 0)
                                            {
                                                DataRow[] dtRuleMin = dtRule.Select("AccountID=" + AccountID + " AND CommType = 1 AND ProfitMinRange <=" + model.SalesProfit + " and ProfitMaxRange >= " + model.SalesProfit);
                                                if (dtRuleMin != null && dtRuleMin.Length == 1)
                                                {
                                                    model.SalesComm = model.SalesProfit * StringUtils.GetDbDecimal(dtRuleMin[0]["ProfitPct"]);
                                                }
                                            }
                                            else
                                            {
                                                model.SalesComm = 0;
                                            }
                                            #endregion
                                        }
                                        else if (StringUtils.GetDbInt(drRule[0]["CommPattern"]) == 1)
                                        {
                                            //为按基础项目
                                            model.SalesComm = item.AccountComm;
                                        }
                                    }
                                    else
                                    {
                                        //为按基础项目
                                        model.SalesComm = item.AccountComm;
                                    }
                                }
                                break;
                            #endregion
                            #region 服务提成
                            case 2:
                                model.OptProfit = item.AccountProfit;
                                if (dtRule != null && dtRule.Rows.Count > 0)
                                {
                                    DataRow[] drRule = dtRule.Select("AccountID=" + AccountID + " AND CommType = 2 ");
                                    if (drRule != null && drRule.Length > 0)
                                    {
                                        if (StringUtils.GetDbInt(drRule[0]["CommPattern"]) == 2)
                                        {
                                            #region 按业绩目标提成
                                            if (model.OptProfit > 0)
                                            {
                                                if (StringUtils.GetDbInt(drRule[0]["ProfitRangeUnit"]) == 1)
                                                {
                                                    #region 提成的业绩目标单位为元
                                                    DataRow[] dtRuleMin = dtRule.Select("AccountID=" + AccountID + " AND CommType = 2 AND ProfitMinRange <=" + model.OptProfit + " and ProfitMaxRange >= " + model.OptProfit);
                                                    if (dtRuleMin != null && dtRuleMin.Length == 1)
                                                    {
                                                        model.OptComm = model.OptProfit * StringUtils.GetDbDecimal(dtRuleMin[0]["ProfitPct"]);
                                                    }
                                                    #endregion
                                                }
                                                else if (StringUtils.GetDbInt(drRule[0]["ProfitRangeUnit"]) == 2)
                                                {
                                                    #region 提成的业绩目标单位为次
                                                    DataRow[] drOpCount = dtOpCount.Select("AccountID=" + AccountID);
                                                    if (drOpCount != null && drOpCount.Length == 1)
                                                    {
                                                        DataRow[] dtRuleMin = dtRule.Select("AccountID=" + AccountID + " AND CommType = 2 AND ProfitMinRange <=" + model.OptProfit + " and ProfitMaxRange >= " + model.OptProfit);
                                                        if (dtRuleMin != null && dtRuleMin.Length == 1)
                                                        {
                                                            model.OptComm = model.OptProfit * StringUtils.GetDbDecimal(dtRuleMin[0]["ProfitPct"]);
                                                        }
                                                    }
                                                    #endregion
                                                }
                                            }
                                            else
                                            {
                                                model.OptComm = 0;
                                            }
                                            #endregion
                                        }
                                        else if (StringUtils.GetDbInt(drRule[0]["CommPattern"]) == 1)
                                        {
                                            //为按基础项目
                                            model.OptComm = item.AccountComm;
                                        }

                                    }
                                }
                                break;

                            #endregion
                            #region Ecard提成
                            case 3:
                                model.ECardProfit = item.AccountProfit;
                                if (dtRule != null && dtRule.Rows.Count > 0)
                                {
                                    DataRow[] drRule = dtRule.Select("AccountID=" + AccountID + " AND CommType = 3 ");
                                    if (drRule != null && drRule.Length > 0)
                                    {
                                        if (StringUtils.GetDbInt(drRule[0]["CommPattern"]) == 2)
                                        {
                                            #region 按业绩目标提成
                                            if (model.ECardProfit > 0)
                                            {
                                                DataRow[] dtRuleMin = dtRule.Select("AccountID=" + AccountID + " AND CommType = 3 AND ProfitMinRange <=" + model.ECardProfit + " and ProfitMaxRange >= " + model.ECardProfit);
                                                if (dtRuleMin != null && dtRuleMin.Length == 1)
                                                {
                                                    model.ECardComm = model.ECardProfit * StringUtils.GetDbDecimal(dtRuleMin[0]["ProfitPct"]);
                                                }
                                            }
                                            else
                                            {
                                                model.ECardComm = 0;
                                            }
                                            #endregion
                                        }
                                        else if (StringUtils.GetDbInt(drRule[0]["CommPattern"]) == 1)
                                        {
                                            //为按基础项目
                                            model.ECardComm = item.AccountComm;
                                        }
                                    }
                                }
                                break;
                            #endregion
                        }
                    }
                }

                return model;
            }
        }

        public JournalInfo_Model GetJournalInfo(int CompanyID, string startTime, string endtime, int BranchID, int CycleType)
        {
            using (DbManager db = new DbManager("Report"))
            {
                JournalInfo_Model model = new JournalInfo_Model();
                //服务
                string strSqlService = @" SELECT SUM(T13.Amount) AS Amount FROM (
                                            select ISNULL(SUM(CASE T2.Type WHEN 1 THEN CASE T2.IsUseRate  WHEN 1 THEN T1.PaymentAmount * T1.ProfitRate ELSE T1.PaymentAmount END  WHEN 2 THEN CASE T2.IsUseRate WHEN 1 THEN T1.PaymentAmount * T1.ProfitRate * - 1 ELSE T1.PaymentAmount * -1 END END),0) AS Amount from [PAYMENT_DETAIL] T1 WITH (NOLOCK) 
                                            INNER JOIN [PAYMENT] T2 WITH (NOLOCK)  ON T1.PaymentID = T2.ID AND T2.OrderNumber = 1
                                            INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T3 WITH (NOLOCK)  ON T1.PaymentID = T3.PaymentID
                                            INNER JOIN [ORDER] T4 WITH (NOLOCK)  ON T3.OrderID = T4.ID AND T4.Status<> 3
                                            INNER JOIN [TBL_ORDER_SERVICE] T5 WITH (NOLOCK)  ON T4.ID = T5.OrderID
                                            LEFT JOIN [BRANCH] T6 WITH (NOLOCK)  ON T2.BranchID = T6.ID
                                            WHERE (T1.PaymentMode = 0  OR T1.PaymentMode = 2 OR T1.PaymentMode = 8 OR T1.PaymentMode = 9   OR T1.PaymentMode = 100  OR T1.PaymentMode = 101 ) AND T1.CompanyID =@CompanyID AND T2.BranchID =@BranchID AND T2.PaymentTime > T6.StartTime AND ((T2.Type = 1 AND (T2.Status = 2 OR T2.Status = 3)) OR (T2.Type =2 AND (T2.Status = 6 OR T2.Status = 7)))  
                                            {0}
                                            UNION ALL
                                            select ISNULL(SUM(CASE T8.Type WHEN 1 THEN CASE T8.IsUseRate WHEN 1 THEN T10.TotalSalePrice * T7.ProfitRate ELSE T10.TotalSalePrice END WHEN 2 THEN CASE T8.IsUseRate WHEN 1 THEN T10.TotalSalePrice * T7.ProfitRate * - 1 ELSE T10.TotalSalePrice * -1 END END ),0) AS Amount  from [PAYMENT_DETAIL] T7 WITH (NOLOCK) 
                                            INNER JOIN [PAYMENT] T8 WITH (NOLOCK)  ON T7.PaymentID = T8.ID AND T8.OrderNumber > 1
                                            INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T9 WITH (NOLOCK)  ON T7.PaymentID = T9.PaymentID
                                            INNER JOIN [ORDER] T10 WITH (NOLOCK)  ON T9.OrderID = T10.ID AND T10.Status<> 3
                                            INNER JOIN [TBL_ORDER_SERVICE] T11 WITH (NOLOCK)  ON T10.ID = T11.OrderID
                                            LEFT JOIN [BRANCH] T12 WITH (NOLOCK)  ON T8.BranchID = T12.ID
                                            WHERE (T7.PaymentMode = 0  OR T7.PaymentMode = 2 OR T7.PaymentMode = 8 OR T7.PaymentMode = 9 OR T7.PaymentMode = 100 OR T7.PaymentMode = 101 ) AND T7.CompanyID =@CompanyID AND T8.BranchID =@BranchID AND T8.PaymentTime > T12.StartTime AND ((T8.Type = 1 AND (T8.Status = 2 OR T8.Status = 3)) OR (T8.Type =2 AND (T8.Status = 6 OR T8.Status = 7))) 
                                            {1} ) T13 ";
                string strSqlServiceData0 = Common.SqlCommon.getSqlWhereData(CycleType, startTime, endtime, "T2.PaymentTime");
                string strSqlServiceData1 = Common.SqlCommon.getSqlWhereData(CycleType, startTime, endtime, "T8.PaymentTime");

                strSqlService = string.Format(strSqlService, strSqlServiceData0, strSqlServiceData1);

                model.SalesService = db.SetCommand(strSqlService
                    , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", BranchID, DbType.Int32)
                    ).ExecuteScalar<decimal>();


                //商品
                string strSqlCommodity = @" SELECT SUM(T13.Amount) AS Amount FROM (
                                            select ISNULL(SUM(CASE T2.Type WHEN 1 THEN CASE T2.IsUseRate  WHEN 1 THEN T1.PaymentAmount * T1.ProfitRate ELSE T1.PaymentAmount END  WHEN 2 THEN CASE T2.IsUseRate WHEN 1 THEN T1.PaymentAmount * T1.ProfitRate * - 1 ELSE T1.PaymentAmount * -1 END END),0) AS Amount from [PAYMENT_DETAIL] T1 WITH (NOLOCK) 
                                            INNER JOIN [PAYMENT] T2 WITH (NOLOCK)  ON T1.PaymentID = T2.ID AND T2.OrderNumber = 1
                                            INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T3 WITH (NOLOCK)  ON T1.PaymentID = T3.PaymentID
                                            INNER JOIN [ORDER] T4 WITH (NOLOCK)  ON T3.OrderID = T4.ID AND T4.Status<> 3
                                            INNER JOIN [TBL_ORDER_COMMODITY] T5 WITH (NOLOCK)  ON T4.ID = T5.OrderID
                                            LEFT JOIN [BRANCH] T6 WITH (NOLOCK)  ON T2.BranchID = T6.ID
                                            WHERE (T1.PaymentMode = 0  OR T1.PaymentMode = 2 OR T1.PaymentMode = 8 OR T1.PaymentMode = 9   OR T1.PaymentMode = 100  OR T1.PaymentMode = 101) AND T1.CompanyID =@CompanyID AND T2.BranchID =@BranchID AND T2.PaymentTime > T6.StartTime AND ((T2.Type = 1 AND (T2.Status = 2 OR T2.Status = 3)) OR (T2.Type =2 AND (T2.Status = 6 OR T2.Status = 7))) 
                                            {0}
                                            UNION ALL
                                            select ISNULL(SUM(CASE T8.Type WHEN 1 THEN CASE T8.IsUseRate WHEN 1 THEN T10.TotalSalePrice * T7.ProfitRate ELSE T10.TotalSalePrice END WHEN 2 THEN CASE T8.IsUseRate WHEN 1 THEN T10.TotalSalePrice * T7.ProfitRate * - 1 ELSE T10.TotalSalePrice * -1 END END ),0) AS Amount  from [PAYMENT_DETAIL] T7 WITH (NOLOCK) 
                                            INNER JOIN [PAYMENT] T8 WITH (NOLOCK)  ON T7.PaymentID = T8.ID AND T8.OrderNumber > 1
                                            INNER JOIN [TBL_ORDERPAYMENT_RELATIONSHIP] T9 WITH (NOLOCK)  ON T7.PaymentID = T9.PaymentID
                                            INNER JOIN [ORDER] T10 WITH (NOLOCK)  ON T9.OrderID = T10.ID AND T10.Status<> 3
                                            INNER JOIN [TBL_ORDER_COMMODITY] T11 WITH (NOLOCK)  ON T10.ID = T11.OrderID
                                            LEFT JOIN [BRANCH] T12 WITH (NOLOCK)  ON T8.BranchID = T12.ID
                                            WHERE (T7.PaymentMode = 0  OR T7.PaymentMode = 2 OR T7.PaymentMode = 8 OR T7.PaymentMode = 9  OR T7.PaymentMode = 100  OR T7.PaymentMode = 101 ) AND T7.CompanyID =@CompanyID AND T8.BranchID =@BranchID AND T8.PaymentTime > T12.StartTime AND ((T8.Type = 1 AND (T8.Status = 2 OR T8.Status = 3)) OR (T8.Type =2 AND (T8.Status = 6 OR T8.Status = 7))) 
                                            {1}
                                            ) T13  ";
                string strSqlCommodityData0 = Common.SqlCommon.getSqlWhereData(CycleType, startTime, endtime, "T2.PaymentTime");
                string strSqlCommodityData1 = Common.SqlCommon.getSqlWhereData(CycleType, startTime, endtime, "T8.PaymentTime");

                strSqlCommodity = string.Format(strSqlCommodity, strSqlCommodityData0, strSqlCommodityData1);
                model.SalesCommodity = db.SetCommand(strSqlCommodity
                    , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", BranchID, DbType.Int32)
                    ).ExecuteScalar<decimal>();

                //储值卡
                string strSqlEcard = @" SELECT ISNULL(SUM(Amount),0) as Amount FROM [TBL_MONEY_BALANCE] T1 WITH (NOLOCK) 
                                        LEFT JOIN [BRANCH] T2 ON T1.BranchID = T2.ID
                                        WHERE T1.CompanyID =@CompanyID AND T1.BranchID =@BranchID 
                                        {0}
                                        AND  (T1.ActionMode = 3 OR T1.ActionMode = 4) and T1.DepositMode <> 3 ";
                string strSqlEcardData0 = Common.SqlCommon.getSqlWhereData(CycleType, startTime, endtime, "T1.CreateTime");

                strSqlEcard = string.Format(strSqlEcard, strSqlEcardData0);
                model.SalesEcard = db.SetCommand(strSqlEcard
                                        , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                        , db.Parameter("@BranchID", BranchID, DbType.Int32)
                                        ).ExecuteScalar<decimal>();
                //总销售
                model.SalesAll = model.SalesService + model.SalesCommodity + model.SalesEcard;

                string strSqlInComeOthers = @" select ISNULL(SUM(T1.Amount),0) AS Amount from [TBL_JOURNAL_ACCOUNT] T1 WITH (NOLOCK) WHERE T1.CompanyID =@CompanyID AND T1.BranchID = @BranchID AND T1.InOutType = 2  
                                               {0}  ";
                string strSqlInComeOthersData0 = Common.SqlCommon.getSqlWhereData(CycleType, startTime, endtime, "T1.InOutDate");

                strSqlInComeOthers = string.Format(strSqlInComeOthers, strSqlInComeOthersData0);
                //其他
                model.IncomeOthers = db.SetCommand(strSqlInComeOthers
                                        , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                        , db.Parameter("@BranchID", BranchID, DbType.Int32)
                                        ).ExecuteScalar<decimal>();
                //总收入
                model.IncomeAmount = model.IncomeOthers + model.SalesAll;
                decimal sao = 0, sso = 0, sco = 0, seo = 0, ioo = 0;
                //计算收入中各部分比例
                if (model.IncomeAmount > 0)
                {
                    //销售比例
                    sao = Math.Round((model.SalesAll * 100) / model.IncomeAmount, 0);
                    //服务比例
                    sso = Math.Round((model.SalesService * 100) / model.IncomeAmount, 0);
                    //商品比例
                    sco = Math.Round((model.SalesCommodity * 100) / model.IncomeAmount, 0);
                    //储值卡比例
                    seo = Math.Round((model.SalesEcard * 100) / model.IncomeAmount, 0);
                    //其他比例
                    ioo = Math.Round((model.IncomeOthers * 100) / model.IncomeAmount, 0);
                }
                model.SalesAll = Decimal.Parse(model.SalesAll.ToString("#0.00"));
                model.SalesAllRatio = sao.ToString("#0") + "%";
                model.SalesService = Decimal.Parse(model.SalesService.ToString("#0.00"));
                model.SalesServiceRatio = sso.ToString("#0") + "%";
                model.SalesCommodity = Decimal.Parse(model.SalesCommodity.ToString("#0.00"));
                model.SalesCommodityRatio = sco.ToString("#0") + "%";
                model.SalesEcard = Decimal.Parse(model.SalesEcard.ToString("#0.00"));
                model.SalesEcardRatio = seo.ToString("#0") + "%";
                model.IncomeOthers = Decimal.Parse(model.IncomeOthers.ToString("#0.00"));
                model.IncomeOthersRatio = ioo.ToString("#0") + "%";
                model.IncomeAmount = Decimal.Parse(model.IncomeAmount.ToString("#0.00"));
                //支出明细
                model.listOutInfo = new List<OutInfo_Model>();
                string strSqlListOut = @" SELECT ItemAName OutItemName,Total OutItemAmountTotal,TotalItemA OutItemAmount,ItemARatio OutItemAmountRatio
                                                from fgetInOutRecord(@CompanyID,@BranchID,@CycleType,@StartTime,@EndTime,1) ";

                model.listOutInfo = db.SetCommand(strSqlListOut
                                       , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                       , db.Parameter("@BranchID", BranchID, DbType.Int32)
                                       , db.Parameter("@CycleType", CycleType, DbType.Int32)
                                       , db.Parameter("@StartTime", startTime, DbType.String)
                                       , db.Parameter("@EndTime", endtime, DbType.String)).ExecuteList<OutInfo_Model>();

                if (model.listOutInfo != null && model.listOutInfo.Count > 0)
                {
                    int num = model.listOutInfo.Count;
                    //model.OutAmout = model.listOutInfo.Sum(c => c.OutItemAmount);
                    for (int i = 0; i < num; i++)
                    {
                        model.listOutInfo[i].OutItemAmount = Decimal.Parse(model.listOutInfo[i].OutItemAmount.ToString("#0.00"));
                        model.listOutInfo[i].OutItemAmountRatio = model.listOutInfo[i].OutItemAmountRatio + "%";
                    }
                    model.OutAmout = Decimal.Parse(model.listOutInfo[0].OutItemAmountTotal.ToString("#0.00"));
                }
                //结余
                model.BalanceAmount = Decimal.Parse((model.IncomeAmount - model.OutAmout).ToString("#0.00"));
                return model;
            }
        }


    }
}
