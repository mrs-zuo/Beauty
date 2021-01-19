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

namespace WebAPI.DAL
{
    public class Payment_DAL
    {
        #region 构造类实例
        public static Payment_DAL Instance
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
            internal static readonly Payment_DAL instance = new Payment_DAL();
        }
        #endregion

        public List<PaymentList_Model> getPaymentList(UtilityOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSqlCommand = @"  SELECT  T1.ID ,
                                                        '支付' + CONVERT(VARCHAR, T1.OrderNumber) + '笔订单' Describe ,
                                                        CASE WHEN ISNULL(T1.Remark, '') = '' THEN 0
                                                             ELSE 1
                                                        END IsRemark ,
                                                        T1.TotalPrice ,
                                                        CONVERT(VARCHAR(19), T1.PaymentTime, 20) PaymentTime ,
                                                        T2.PaymentModes
                                                FROM    dbo.PAYMENT T1
                                                        INNER JOIN ( SELECT T7.ID ,
                                                                            ( SELECT    '|' + CONVERT(VARCHAR, T8.PaymentMode)
                                                                                        + '|'
                                                                              FROM      dbo.PAYMENT_DETAIL T8
                                                                              WHERE     T8.PaymentID = T7.ID
                                                                            FOR
                                                                              XML PATH('')
                                                                            ) PaymentModes
                                                                     FROM   dbo.PAYMENT T7
                                                                     GROUP BY T7.ID
                                                                   ) T2 ON T1.ID = T2.ID
                                                        INNER JOIN ( SELECT DISTINCT
                                                                            PaymentID ,
                                                                            ( SELECT    MAX(OrderID)
                                                                              FROM      TBL_OrderPayment_RelationShip T6
                                                                              WHERE     t6.PaymentID = t5.PaymentID
                                                                            ) OrderID
                                                                     FROM   TBL_OrderPayment_RelationShip T5
                                                                   ) T3 ON T3.PaymentID = T2.ID
                                                        INNER JOIN dbo.[ORDER] T4 ON T4.ID = T3.OrderID
                                                        LEFT JOIN [BRANCH] T8 ON T1.BranchID = T8.ID
                                                WHERE   T4.CustomerID = @CustomerID
                                                        AND ((T1.Type = 1 AND (T1.Status = 2 OR t1.Status=4)) OR (T1.Type = 2 AND T1.Status = 7)) 
                                                        AND T4.BranchID = @BranchID AND T1.PaymentTime > T8.StartTime
                                                ORDER BY T1.CreateTime DESC";

                List<PaymentList_Model> list = db.SetCommand(strSqlCommand, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                                                          , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                                           ).ExecuteList<PaymentList_Model>();

                return list;
            }
        }

        /// <summary>
        /// GetPaymentDetailModeAmount
        /// </summary>
        /// <param name="paymentID"></param>
        /// <param name="mode">0:现金 1:E卡 2:银行卡 3:其他</param>
        /// <returns></returns>
        public decimal GetPaymentDetailModeAmount(int paymentID, int mode)
        {
            decimal amount = 0;
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  PaymentAmount
                                      FROM    [PAYMENT_DETAIL] T1 WITH ( NOLOCK )
                                      WHERE   T1.PaymentID = @PaymentID
                                              AND PaymentMode = @mode";

                amount = db.SetCommand(strSql, db.Parameter("@PaymentID", paymentID, DbType.Int32)
                                             , db.Parameter("@mode", mode, DbType.Int32)).ExecuteScalar<decimal>();

                return amount;
            }
        }

        public List<GetBalanceList_Model> getBalanceList(int customerId)
        {
            List<GetBalanceList_Model> list = new List<GetBalanceList_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = @"  SELECT T1.ID ,
        T1.Type ,
        T1.Mode ,
        T1.Amount ,
        T1.Balance ,
        T5.CommodityName AS ProductName ,
        CONVERT(VARCHAR(19), T1.CreateTime, 20) Time ,
        ISNULL(T1.Remark, '') AS Remark ,
        T1.PaymentID ,
        T2.OrderCount
 FROM   [BALANCE] T1
        LEFT JOIN ( SELECT DISTINCT PaymentID ,
                            ( SELECT MAX(OrderID) FROM TBL_OrderPayment_RelationShip T6 WHERE t6.PaymentID = t5.PaymentID) ID ,
                            ( SELECT COUNT(PaymentID) FROM TBL_OrderPayment_RelationShip T6 WHERE t6.PaymentID = t5.PaymentID GROUP BY  PaymentID ) OrderCount
                    FROM    TBL_OrderPayment_RelationShip T5
                  ) T2 ON T2.PaymentID = T1.PaymentID
        LEFT JOIN [ORDER] T4 WITH ( NOLOCK ) ON T4.ID = T2.ID
        LEFT JOIN [COMMODITY] T5 WITH ( NOLOCK ) ON T4.ProductID = T5.ID
 WHERE  ( T1.CusTomerID = @CustomerID AND T4.ProductType = 1 AND T1.Available = 1)
        OR ( T1.CusTomerID = @CustomerID AND T1.PaymentID IS NULL AND T1.Available = 1)
 UNION
 SELECT T1.ID ,
        T1.Type ,
        T1.Mode ,
        T1.Amount ,
        T1.Balance ,
        T5.ServiceName AS ProductName ,
        CONVERT(VARCHAR(19), T1.CreateTime, 20) Time ,
        ISNULL(T1.Remark, '') AS Remark ,
        T1.PaymentID ,
        T2.OrderCount
 FROM   [BALANCE] T1
        LEFT JOIN ( SELECT DISTINCT PaymentID ,
                            ( SELECT MAX(OrderID) FROM TBL_OrderPayment_RelationShip T6 WHERE t6.PaymentID = t5.PaymentID ) ID ,
                            ( SELECT  COUNT(PaymentID) FROM TBL_OrderPayment_RelationShip T6 WHERE t6.PaymentID = t5.PaymentID GROUP BY  PaymentID ) OrderCount
                    FROM    TBL_OrderPayment_RelationShip T5
                  ) T2 ON T2.PaymentID = T1.PaymentID
        LEFT JOIN [ORDER] T4 WITH ( NOLOCK ) ON T4.ID = T2.ID
        LEFT JOIN [SERVICE] T5 WITH ( NOLOCK ) ON T4.ProductID = T5.ID
 WHERE  ( T1.CusTomerID = @CustomerID AND T4.ProductType = 0 AND T1.Available = 1 )
        OR ( T1.CusTomerID = @CustomerID AND T1.PaymentID IS NULL AND T1.Available = 1 )
 ORDER BY Time DESC , [ID] DESC  ";

                list = db.SetCommand(strSql, db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteList<GetBalanceList_Model>();

                return list;
            }
        }

        public bool rechargeBanlance(RechargeOperation_Model model)
        {
            System.Diagnostics.StackTrace st = new System.Diagnostics.StackTrace(1, true);
            string strPgm;  //当前的程序名称及行号等监察信息

            decimal balance = 0;
            using (DbManager db = new DbManager())
            {
                try
                {
                    string strSqlGetBalance = @"select top 1 Balance from BALANCE With(TABLOCK,HOLDLOCK) where CustomerID =@CustomerID and Available = 1 order by ID desc";
                    decimal orgBalance = db.SetCommand(strSqlGetBalance, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteScalar<decimal>();
                    balance = model.Amount + orgBalance;
                    if (balance < 0)
                    {
                        return false;
                    }

                    db.BeginTransaction();
                    string strSql = @"insert into BALANCE(CompanyID,BranchID,CustomerID,Type,Mode, ResponsiblePersonID,Remark,Amount,Balance,CreatorID,CreateTime,Available) 
                                        values (@CompanyID,@BranchID,@CustomerID,@Type,@Mode,@ResponsiblePersonID,@Remark,@Amount,@Balance,@CreatorID,@CreateTime,@Available);select @@IDENTITY";

                    int addRes = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                    , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                                    , db.Parameter("@Type", model.Type, DbType.Int32)
                                                    , db.Parameter("@Mode", model.Mode, DbType.Int32)
                                                    , db.Parameter("@ResponsiblePersonID", model.ResponsiblePersonID, DbType.Int32)
                                                    , db.Parameter("@Remark", model.Remark, DbType.String)
                                                    , db.Parameter("@Amount", model.Amount, DbType.Decimal)
                                                    , db.Parameter("@Balance", balance, DbType.Decimal)
                                                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)
                                                    , db.Parameter("@Available", true, DbType.Boolean)).ExecuteScalar<int>();

                    if (addRes <= 0)
                    {
                        db.RollbackTransaction();
                        LogUtil.Log("插入充值金额出错", "用户ID:" + model.CustomerID + "插入充值金额出错。");
                        return false;
                    }

                    if (model.Amount >= 0 && model.SlaveID != null && model.SlaveID.Count > 0 && (model.Mode == 0 || model.Mode == 1))
                    {
                        foreach (int item in model.SlaveID)
                        {
                            string strAddProfitSql = @" INSERT	INTO TBL_PROFIT( MasterID ,SlaveID ,Type ,Available ,CreateTime ,CreatorID) 
                                                VALUES (@MasterID ,@SlaveID ,@Type ,@Available ,@CreateTime ,@CreatorID)";
                            int addProfitres = db.SetCommand(strAddProfitSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@MasterID", addRes, DbType.Int64)
                                    , db.Parameter("@SlaveID", item, DbType.Int64)
                                    , db.Parameter("@Type", 1, DbType.Int32)
                                    , db.Parameter("@Available", true, DbType.Boolean)
                                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)).ExecuteNonQuery();

                            if (addProfitres <= 0)
                            {
                                db.RollbackTransaction();
                                LogUtil.Log("插入业绩表出错", "BanlanceID:" + addRes + "插入业绩表出错。");
                                return false;
                            }
                        }
                    }


                    if (model.GiveAmount > 0 && model.Mode != 3)
                    {
                        #region 赠送金额操作
                        // balance为原有金额加上赠送金额
                        balance = balance + model.GiveAmount;
                        // Mode改为赠送Mode
                        model.Mode = 2;
                        // Remark默认为 充?送?
                        model.Remark = "充" + model.Amount.ToString("F2") + "送" + model.GiveAmount.ToString("F2") + "";

                        string strGiveSql = @"insert into BALANCE(CompanyID,BranchID,CustomerID,Type,Mode, ResponsiblePersonID,Remark,Amount,Balance,CreatorID,CreateTime,Available) 
                                        values (@CompanyID,@BranchID,@CustomerID,@Type,@Mode,@ResponsiblePersonID,@Remark,@Amount,@Balance,@CreatorID,@CreateTime,@Available)";

                        int giveRes = db.SetCommand(strGiveSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                        , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                        , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                                        , db.Parameter("@Type", model.Type, DbType.Int32)
                                                        , db.Parameter("@Mode", model.Mode, DbType.Int32)
                                                        , db.Parameter("@ResponsiblePersonID", model.ResponsiblePersonID, DbType.Int32)
                                                        , db.Parameter("@Remark", model.Remark, DbType.String)
                                                        , db.Parameter("@Amount", model.GiveAmount, DbType.Decimal)
                                                        , db.Parameter("@Balance", balance, DbType.Decimal)
                                                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)
                                                        , db.Parameter("@Available", true, DbType.Boolean)).ExecuteNonQuery();
                        if (giveRes <= 0)
                        {
                            db.RollbackTransaction();
                            LogUtil.Log("插入赠送金额出错", "用户ID:" + model.CustomerID + "插入赠送金额出错。");
                            return false;
                        }
                        #endregion
                    }

                    ///GPB-2037 陈 2014/12/22 Start

                    if (model.PeopleCount > 0)
                    {
                        string strSqlAdvanced = " select Advanced  from COMPANY with (nolock) where ID =@CompanyID ";

                        object objAdvanced = db.SetCommand(strSqlAdvanced, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar();
                        if (objAdvanced.ToString().Contains("|5|"))
                        {

                            string strSqlstatistics = @" INSERT INTO [TBL_STATISTICS] 
                                                    (CompanyID,BranchID,CustomerID,Type,Count,Available,CreatorID,CreateTime)
                                                         VALUES 
                                                    (@CompanyID,@BranchID,@CustomerID,@Type,@Count,@Available,@CreatorID,@CreateTime) ";

                            int statisticsrow = db.SetCommand(strSqlstatistics, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                , db.Parameter("@Type", 2, DbType.Int32)
                                , db.Parameter("@Count", model.PeopleCount, DbType.Int32)
                                , db.Parameter("@Available", true, DbType.Int32)
                                , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                            if (statisticsrow == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }
                    }
                    ///end

                    db.CommitTransaction();

                    #region PUSH
                    string selectCustomerDevice = @"SELECT TOP 1 ISNULL(T3.DeviceID, '') AS DeviceID ,T1.Name AS CustomerName ,T3.DeviceType ,T2.smsheading AS CompanyName,ISNULL(T5.Threshold, 0) AS Threshold ,T4.LoginMobile,T2.BalanceRemind
                                                    FROM    [CUSTOMER] T1 WITH ( NOLOCK )
                                                            LEFT JOIN [COMPANY] T2 WITH ( NOLOCK ) ON T1.CompanyID = T2.ID
                                                            LEFT JOIN [LOGIN] T3 WITH ( NOLOCK ) ON T1.UserID = T3.UserID
                                                            LEFT JOIN [USER] T4 WITH ( NOLOCK ) ON T4.ID = t1.UserID
                                                            LEFT JOIN [LEVEL] T5 WITH ( NOLOCK ) ON T5.ID = T1.LevelID
                                                    WHERE   T1.UserID = @CustomerID";
                    PushOperation_Model pushmodel = db.SetCommand(selectCustomerDevice, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteObject<PushOperation_Model>();
                    if (pushmodel != null)
                    {
                        if (pushmodel.BalanceRemind)
                        {
                            #region 余额变动短信息提醒
                            if (!string.IsNullOrEmpty(pushmodel.LoginMobile))
                            {
                                strPgm = st.GetFrame(0).GetMethod().Name + "(" + st.GetFrame(0).GetFileLineNumber().ToString() + ")";
                                int result = SMSInfo_DAL.Instance.getSMSInfo(model.CompanyID, pushmodel.LoginMobile, strPgm, model.CreatorID);
                                if (result == 0)
                                {
                                    Common.SendShortMessage.sendShortMessageForBalance(pushmodel.LoginMobile, pushmodel.CompanyName, model.CreateTime.ToString("MM月dd日HH时mm分"));
                                    //保存短信发送履历信息
                                    string msg = string.Format(Const.MESSAGE_BALANCE, pushmodel.CompanyName, model.CreateTime.ToString("MM月dd日HH时mm分"));
                                    strPgm = st.GetFrame(0).GetMethod().Name + "(" + st.GetFrame(0).GetFileLineNumber().ToString() + ")";
                                    SMSInfo_DAL.Instance.addSMSHis(model.CompanyID, model.BranchID, pushmodel.LoginMobile, msg, strPgm, model.CreatorID);
                                }
                            }
                            #endregion
                        }

                        #region e卡余额低于阀值PUSH提醒
                        if (balance < pushmodel.Threshold && model.Type != 0)
                        {
                            Task.Factory.StartNew(() =>
                            {
                                if (!string.IsNullOrWhiteSpace(pushmodel.DeviceID))
                                {
                                    try
                                    {
                                        HS.Framework.Common.Push.HSPush.pushMsg(pushmodel.DeviceID, pushmodel.DeviceType, 0, "尊敬的" + pushmodel.CustomerName + "，您在" + pushmodel.CompanyName + "的e卡余额即将用完，请及时充值。", Convert.ToBoolean(System.Configuration.ConfigurationManager.AppSettings["IsProduction"]), "2");
                                    }
                                    catch (Exception)
                                    {
                                        LogUtil.Log("余额变动push失败", model.CustomerID + "push订单失败,时间:" + model.CreateTime);
                                    }
                                }
                                else
                                {
                                    LogUtil.Log("余额变动push失败", model.CustomerID + "的DeviceID为空");
                                }

                            });
                        }

                        #endregion
                    }
                    #endregion

                    return true;
                }
                catch (Exception ex)
                {
                    db.RollbackTransaction();
                    throw ex;
                }
            }
        }

        public BalanceDetailInfo_Model getBalanceDetail(int balanceId)
        {
            BalanceDetailInfo_Model resModel = new BalanceDetailInfo_Model();
            using (DbManager db = new DbManager())
            {
                string strSqlCommand = @"SELECT  ABS(T1.Amount) Amount ,
                                                 CASE ( T1.Mode )
                                                   WHEN 0 THEN '现金'
                                                   WHEN 1 THEN '银行卡'
                                                   WHEN 2 THEN '赠送'
                                                   WHEN 3 THEN '转入'
                                                   ELSE NULL
                                                 END Mode ,
                                                 T1.Remark ,
                                                 T2.Name Operator ,Balance,
                                                 CONVERT(varchar(19), T1.CreateTime, 20) CreateTime
                                            FROM    dbo.BALANCE T1
                                                    INNER JOIN dbo.ACCOUNT T2 ON T1.CreatorID = T2.UserID
                                            WHERE   T1.ID = @ID ";

                BalanceDetailInfo_Model balModel = db.SetCommand(strSqlCommand, db.Parameter("@ID", balanceId, DbType.Int32)).ExecuteObject<BalanceDetailInfo_Model>();
                return balModel;
            }
        }


        //////////////////////////////////////////////////////////////////////////////////////////

        public PaymentInfo_Model getPaymentInfo(GetPaymentInfoOperation_Model operationModel)
        {
            using (DbManager db = new DbManager())
            {
                PaymentInfo_Model model = new PaymentInfo_Model();

                if (operationModel.OrderList != null && operationModel.OrderList.Count == 1)
                {
                    #region 单个订单
                    if (operationModel.OrderList[0].ProductType == 0)
                    {
                        #region 服务
                        string strSelSql = @"SELECT T6.ServiceCode AS ProductCode ,
                                                    T1.TotalOrigPrice,
                                                    T1.TotalCalcPrice,
                                                    T1.TotalSalePrice ,
                                                    T1.UnPaidPrice ,
                                                    T2.IsPay ,
                                                    ISNULL(T2.IsPartPay, 0) AS IsPartPay ,
                                                    ISNULL(T7.CardExpiredDate, '2099-12-31') AS ExpirationDate ,
                                                    T1.PaymentStatus ,
                                                    ISNULL(T8.ID, 0) AS CardID ,
                                                    ISNULL(T8.CardName, '') AS CardName ,
                                                    ISNULL(T7.UserCardNo, '') AS UserCardNo ,
                                                    T8.CardTypeID, 
                                                    T9.PromotionPrice,T9.UnitPrice,T9.MarketingPolicy,T6.Quantity 
                                            FROM    [ORDER] T1 WITH ( NOLOCK )
                                                    LEFT JOIN [BRANCH] T2 WITH ( NOLOCK ) ON T2.ID = T1.BranchID
                                                    LEFT JOIN [CUSTOMER] T3 WITH ( NOLOCK ) ON T1.CustomerID = T3.UserID
                                                    LEFT JOIN [TBL_ORDER_SERVICE] T6 ON T1.ID = T6.OrderID
                                                    LEFT JOIN [TBL_CUSTOMER_CARD] T7 ON T6.UserCardNo = T7.UserCardNo
                                                    LEFT JOIN [MST_CARD] T8 ON T7.CardID = T8.ID 
                                                    LEFT JOIN [SERVICE] T9 WITH ( NOLOCK ) ON T6.ServiceID = T9.ID 
                                            WHERE   T1.CompanyID = @CompanyID
                                                    --AND T1.BranchID = @BranchID
                                                    AND T1.ID = @OrderID
                                                    AND T6.ID = @OrderObjectID";

                        model = db.SetCommand(strSelSql
                                , db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)
                                , db.Parameter("@BranchID", operationModel.BranchID, DbType.Int32)
                                , db.Parameter("@OrderID", operationModel.OrderList[0].OrderID, DbType.Int32)
                                , db.Parameter("@OrderObjectID", operationModel.OrderList[0].OrderObjectID, DbType.Int32)).ExecuteObject<PaymentInfo_Model>();


                        #endregion
                    }
                    else
                    {
                        #region 商品
                        string strSelSql = @"SELECT T6.CommodityCode AS ProductCode ,
                                                    T1.TotalOrigPrice,
                                                    T1.TotalCalcPrice,
                                                    T1.TotalSalePrice ,
                                                    T1.UnPaidPrice ,
                                                    T2.IsPay ,
                                                    ISNULL(T2.IsPartPay, 0) AS IsPartPay ,
                                                    ISNULL(T7.CardExpiredDate, '2099-12-31') AS ExpirationDate ,
                                                    T1.PaymentStatus ,
                                                    ISNULL(T8.ID, 0) AS CardID ,
                                                    ISNULL(T8.CardName, '') AS CardName ,
                                                    ISNULL(T7.UserCardNo, '') AS UserCardNo ,
                                                    T8.CardTypeID, 
                                                    T9.PromotionPrice,T9.UnitPrice,T9.MarketingPolicy,T6.Quantity 
                                            FROM    [ORDER] T1 WITH ( NOLOCK )
                                                    LEFT JOIN [BRANCH] T2 WITH ( NOLOCK ) ON T2.ID = T1.BranchID
                                                    LEFT JOIN [CUSTOMER] T3 WITH ( NOLOCK ) ON T1.CustomerID = T3.UserID
                                                    LEFT JOIN [TBL_ORDER_COMMODITY] T6 ON T1.ID = T6.OrderID
                                                    LEFT JOIN [TBL_CUSTOMER_CARD] T7 ON T6.UserCardNo = T7.UserCardNo
                                                    LEFT JOIN [MST_CARD] T8 ON T7.CardID = T8.ID 
                                                    LEFT JOIN [COMMODITY] T9 WITH ( NOLOCK ) ON T6.CommodityID = T9.ID 
                                            WHERE   T1.CompanyID = @CompanyID
                                                    --AND T1.BranchID = @BranchID
                                                    AND T1.ID = @OrderID
                                                    AND T6.ID = @OrderObjectID";

                        model = db.SetCommand(strSelSql
                                , db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)
                                , db.Parameter("@BranchID", operationModel.BranchID, DbType.Int32)
                                , db.Parameter("@OrderID", operationModel.OrderList[0].OrderID, DbType.Int32)
                                , db.Parameter("@OrderObjectID", operationModel.OrderList[0].OrderObjectID, DbType.Int32)).ExecuteObject<PaymentInfo_Model>();
                        #endregion
                    }
                    #endregion
                }
                else
                {
                    #region 多笔支付
                    string strSelSql = @"SELECT 
                                                SUM(T1.TotalOrigPrice) AS TotalOrigPrice ,  
                                                SUM(T1.TotalCalcPrice) AS TotalCalcPrice ,
                                                SUM(T1.TotalSalePrice) AS TotalSalePrice ,
                                                SUM(T1.UnPaidPrice) AS UnPaidPrice ,
                                                T2.IsPay ,
                                                ISNULL(T2.IsPartPay, 0) AS IsPartPay ,
                                                ISNULL(T3.ExpirationDate, '2099-12-31') AS ExpirationDate ,
                                                T1.PaymentStatus ,
                                                0 AS CardID ,
                                                '' AS CardName
                                        FROM    [ORDER] T1 WITH ( NOLOCK )
                                                LEFT JOIN [BRANCH] T2 WITH ( NOLOCK ) ON T2.ID = T1.BranchID
                                                LEFT JOIN [CUSTOMER] T3 WITH ( NOLOCK ) ON T1.CustomerID = T3.UserID
                                        WHERE   T1.CompanyID = @CompanyID
                                                --AND T1.BranchID = @BranchID
                                                AND T1.ID IN(";

                    string strIDs = "";
                    for (int i = 0; i < operationModel.OrderList.Count; i++)
                    {
                        if (i == 0)
                        {
                            strIDs += operationModel.OrderList[i].OrderID.ToString();
                        }
                        else
                        {
                            strIDs += "," + operationModel.OrderList[i].OrderID;
                        }

                    }

                    strSelSql += strIDs;

                    strSelSql += @") GROUP BY T2.IsPay ,T2.IsPartPay ,T3.ExpirationDate ,T1.PaymentStatus";

                    model = db.SetCommand(strSelSql
                                , db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)
                                , db.Parameter("@BranchID", operationModel.BranchID, DbType.Int32)).ExecuteObject<PaymentInfo_Model>();
                    #endregion
                }

                if (model != null)
                {
                    string advanced = Company_DAL.Instance.getAdvancedByCompanyID(operationModel.CompanyID);
                    if (advanced.Contains("|4|"))
                    {
                        if (!model.IsPay)
                        {
                            string strSqlCheckLogin = @" SELECT T2.LoginMobile  FROM [USER] T2 WHERE T2.ID = @Customer AND T2.UserType = 0";

                            string loginMobil = db.SetCommand(strSqlCheckLogin, db.Parameter("@Customer", operationModel.CustomerID, DbType.Int32)).ExecuteScalar<string>();
                            if (string.IsNullOrEmpty(loginMobil))
                            {
                                model.IsPay = true;
                            }
                        }

                        #region 销售顾问业绩提成
                        string strSelSalesSql = @" SELECT  T1.AccountID AS SalesPersonID ,
                                                            T2.Name AS SalesName
                                                    FROM    [RELATIONSHIP] T1 WITH ( NOLOCK )
                                                            INNER JOIN [ACCOUNT] T2 WITH ( NOLOCK ) ON T1.AccountID = T2.UserID
                                                    WHERE   T1.CompanyID = @CompanyID
                                                            AND T1.BranchID = @BranchID
                                                            AND T1.CustomerID = @CustomerID
                                                            AND T1.Available = 1
                                                            AND T1.Type = 2 ";

                        model.SalesList = db.SetCommand(strSelSalesSql,
                                db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32),
                                db.Parameter("@BranchID", operationModel.BranchID, DbType.Int32),
                                db.Parameter("@CustomerID", operationModel.CustomerID, DbType.Int32)).ExecuteList<Sales_Model>();
                        #endregion
                        #region  销售顾问默认提成率
                        List<PaymentInfoDetailOperation_Model> OrderList = operationModel.OrderList;
                        StringBuilder sb = new StringBuilder();
                        if (OrderList != null)
                        {
                            int orderCount = OrderList.Count;
                            if (orderCount > 0)
                            {
                                for (int i = 0; i < orderCount; i++)
                                {
                                    if (i == orderCount - 1)
                                    {
                                        sb.Append(OrderList[i].OrderID + "");
                                    }
                                    else
                                    {
                                        sb.Append(OrderList[i].OrderID + ",");
                                    }
                                }
                            }

                        }

                        string sbOrderIds = sb.ToString();
                        if (sbOrderIds.Length > 0)
                        {
                            String salesConsultantRateSql = @" SELECT SalesConsultantID,SalesConsultantName,CommissionRate FROM getCommissionRate (@OrderID) ";
                            model.SalesConsultantRates = db.SetCommand(salesConsultantRateSql, db.Parameter("@OrderID", sbOrderIds, DbType.String)).ExecuteList<SalesConsultantRate_model>();
                        }
                        #endregion
                    }

                }
                return model;
            }
        }

        //private bool IsHasCustomerLocked(DbManager db, int customerID)
        //{
        //    //string strSelCustomerLock = "SELECT CustomerID FROM  [SYS_CustomerLocked] WHERE CustomerID=@CustomerID";
        //    //int customerRes = db.SetCommand(strSelCustomerLock
        //    //    , db.Parameter("@CustomerID", customerID, DbType.Int32)).ExecuteScalar<int>();
        //    //if (customerRes > 0)
        //    //{
        //    //    db.RollbackTransaction();
        //    //    return false;
        //    //}

        //    try
        //    {
        //        string strCustomerLockerSql = @"INSERT INTO SYS_CustomerLocked ( CustomerID ) VALUES  ( @CustomerID );select @@IDENTITY";
        //        int lockedID = db.SetCommand(strCustomerLockerSql
        //            , db.Parameter("@CustomerID", customerID, DbType.Int32)).ExecuteNonQuery();

        //        if (lockedID <= 0)
        //        {
        //            db.RollbackTransaction();
        //            return false;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        db.RollbackTransaction();
        //        return false;
        //    }

        //    return true;
        //}

        //private bool DelCustomerLocked(DbManager db, int customerID)
        //{
        //    try
        //    {
        //        string strDelCustomerLockedSql = "DELETE FROM [SYS_CustomerLocked] WHERE CustomerID=@CustomerID";
        //        int delres = db.SetCommand(strDelCustomerLockedSql
        //        , db.Parameter("@CustomerID", customerID, DbType.Int32)).ExecuteNonQuery();

        //        if (delres <= 0)
        //        {
        //            db.RollbackTransaction();
        //            return false;
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        db.RollbackTransaction();
        //        return false;
        //    }

        //    return true;
        //}

        public int PayAdd(PaymentAddOperationList_Model md)
        {
            List<PaymentAddOperation_Model> modelList = md.PaymentAddOperationList;
            foreach (PaymentAddOperation_Model model in modelList) {
                if (model.PaymentDetailList == null) {
                    return 0;
                }
            }
            using (DbManager db = new DbManager())
            {
                System.Diagnostics.StackTrace st = new System.Diagnostics.StackTrace(1, true);
                string strPgm;  //当前的程序名称及行号等监察信息

                try {
                    db.BeginTransaction();
                    foreach (PaymentAddOperation_Model model in modelList) {
                        bool isBalanceChangePush = true;//余额变动只push一次
                        int customerBalanceID = 0;
 
                        #region 验证支付数据
                        List<int> orderIDListWithout0Price = new List<int>();
                        PaymentCheck_Model paymentCheckModel = new PaymentCheck_Model();
                        int canPayRes = Order_DAL.Instance.CanOrderCanPay(model.OrderIDList, out orderIDListWithout0Price, out paymentCheckModel);
                        if (canPayRes != 1)
                        {
                            return canPayRes;
                        }
                        #endregion

                        // 无论是多订单完全支付 还是单比订单支付(分期支付),前台所传价格不能大于数据库查出来的应支付金额
                        if (model.TotalPrice > paymentCheckModel.TotalAmount)
                        {
                            return 5;
                        }

                        if (paymentCheckModel == null || orderIDListWithout0Price.Count == 0)
                        {
                            return 2;
                        }

                        PaymentBranchRole paymentBranchRole = new PaymentBranchRole();
                        paymentBranchRole.IsCustomerConfirm = true;
                        paymentBranchRole.IsAccountEcardPay = false;
                        paymentBranchRole.IsPartPay = false;
                        paymentBranchRole.IsUseRate = 3;

                        if (!model.IsCustomer)
                        {
                            #region 获取权限
                            string strSqlCommand = @"select IsPay AS IsAccountEcardPay ,IsConfirmed AS IsCustomerConfirm ,IsPartPay ,IsUseRate from [BRANCH] 
                                            where BRANCH.ID = @BranchID ";

                            paymentBranchRole = db.SetCommand(strSqlCommand,
                                                            db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteObject<PaymentBranchRole>();
                            #endregion

                            if (paymentBranchRole == null)
                            {
                                return 0;
                            }
                        }

                        #region 没有分期支付权限或者多张订单,必须全额支付
                        if (!paymentBranchRole.IsPartPay || orderIDListWithout0Price.Count > 1)
                        {
                            if (paymentCheckModel.TotalAmount != model.TotalPrice)
                            {
                                return 5;
                            }
                        }
                        #endregion


                        #region 插入PayMent表
                        string strSqlPayAdd = @"insert into PAYMENT(CompanyID,OrderNumber,TotalPrice,CreatorID,CreateTime,Remark,PaymentTime,LevelID,Type,Status,BranchID,ClientType,IsUseRate) 
                                            values (@CompanyID,@OrderNumber,@TotalPrice,@CreatorID,@CreateTime,@Remark,@PaymentTime,@LevelID,@Type,@Status,@BranchID,@ClientType,@IsUseRate);select @@IDENTITY";
                        int paymentID = db.SetCommand(strSqlPayAdd
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@OrderNumber", model.OrderCount, DbType.Int32)
                                    , db.Parameter("@TotalPrice", model.TotalPrice, DbType.Decimal)
                                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)
                                    , db.Parameter("@Remark", model.Remark, DbType.String)
                                    , db.Parameter("@PaymentTime", model.CreateTime, DbType.DateTime)
                                    , db.Parameter("@LevelID", DBNull.Value, DbType.Int32)
                                    , db.Parameter("@Type", 1, DbType.Int32)//1：支付 2：退款
                                    , db.Parameter("@Status", 2, DbType.Int32)//1：无效 2：执行 3：撤销
                                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                    , db.Parameter("@ClientType", model.ClientType, DbType.Int32)
                                    , db.Parameter("@IsUseRate", paymentBranchRole.IsUseRate, DbType.Int32)
                                    ).ExecuteScalar<int>();

                        if (paymentID <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        #region 插入业绩人
                        if (paymentID >= 0 && model.Slavers != null && model.Slavers.Count > 0)
                        {
                            foreach (Slave_Model item in model.Slavers)
                            {
                                decimal EveryProfitPct = 0;
                                //业绩均分flag
                                if (model.AverageFlag == 1)
                                {
                                    EveryProfitPct = Math.Round((decimal)1 / model.Slavers.Count, 2);
                                }
                                else
                                {
                                    EveryProfitPct = item.ProfitPct;
                                }
                                string strAddProfitSql = @" INSERT	INTO TBL_PROFIT( MasterID ,SlaveID ,Type ,ProfitPct ,Available ,CreateTime ,CreatorID) 
                                            VALUES (@MasterID ,@SlaveID ,@Type ,@ProfitPct ,@Available ,@CreateTime ,@CreatorID)";
                                int addProfitres = db.SetCommand(strAddProfitSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@MasterID", paymentID, DbType.Int64)
                                        , db.Parameter("@SlaveID", item.SlaveID, DbType.Int64)
                                        , db.Parameter("@Type", 2, DbType.Int32)
                                        , db.Parameter("@ProfitPct", EveryProfitPct, DbType.Decimal)
                                        , db.Parameter("@Available", 1, DbType.Boolean)
                                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)).ExecuteNonQuery();

                                if (addProfitres <= 0)
                                {
                                    db.RollbackTransaction();
                                    LogUtil.Log("插入业绩表出错", "PaymentID:" + paymentID + "插入业绩表出错。");
                                    return 0;
                                }
                            }
                        }
                        #endregion

                        #region 判断E卡是否能够支付
                        foreach (PaymentDetail_Model item in model.PaymentDetailList)
                        {
                            if (item.PaymentMode == 1 || item.PaymentMode == 6 || item.PaymentMode == 7)
                            {
                                if (!model.IsCustomer && !paymentBranchRole.IsAccountEcardPay)
                                {
                                    // 没有Ecard支付权限
                                    db.RollbackTransaction();
                                    return 3;
                                }

                                #region 插入CUSTOMER_BALANCE
                                if (customerBalanceID <= 0)
                                {
                                    string strAddCustomerBalance = @" INSERT [TBL_CUSTOMER_BALANCE]	( CompanyID ,BranchID ,UserID ,ChangeType ,TargetAccount ,PaymentID ,Remark ,CreatorID ,CreateTime) 
                                    VALUES(@CompanyID ,@BranchID ,@UserID ,@ChangeType ,@TargetAccount  ,@PaymentID ,@Remark ,@CreatorID ,@CreateTime);select @@IDENTITY";
                                    customerBalanceID = db.SetCommand(strAddCustomerBalance,
                                                db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                                db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                                db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                                                db.Parameter("@ChangeType", 1, DbType.Int32),//1:账户消费、2:账户消费撤销、3：账户充值、4：账户充值撤销、5：账户直扣、6：账户直扣撤销(9:退款 也属于账户直扣)
                                                db.Parameter("@TargetAccount", 0, DbType.Int32),//目标账户：1:储值卡、2:积分、3:现金券  账户消费和消费撤销时，设默认值0
                                                                                                //db.Parameter("@ResponsiblePersonID", model.CreatorID, DbType.Int32),
                                                db.Parameter("@PaymentID", paymentID, DbType.Int32),
                                                db.Parameter("@Remark", model.Remark, DbType.String),
                                                db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                                db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteScalar<int>();

                                    if (customerBalanceID <= 0)
                                    {
                                        db.RollbackTransaction();
                                        return 0;
                                    }
                                }
                                #endregion


                                string strSqlGetBalance = @"SELECT  T1.Balance  
                                                        FROM    [TBL_CUSTOMER_CARD] T1 WITH ( NOLOCK )
                                                        WHERE   T1.CompanyID = @CompanyID
                                                                AND T1.UserID = @CustomerID
                                                                AND T1.UserCardNo = @UserCardNo";
                                decimal balance = db.SetCommand(strSqlGetBalance
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                    , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteScalar<decimal>();

                                if (balance < item.PaymentAmount)
                                {
                                    // 余额不足
                                    db.RollbackTransaction();
                                    return 4;
                                }
                                else
                                {
                                    item.PaymentAmount = Math.Abs(item.PaymentAmount) * -1;
                                    balance = balance + item.PaymentAmount;
                                }

                                #region 消费
                                if (item.CardType == 1)
                                {
                                    #region 储值卡
                                    string strAddMoneyBalance = @" INSERT INTO [TBL_MONEY_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CreatorID ,CreateTime) 
                VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CreatorID ,@CreateTime)";

                                    int addres = db.SetCommand(strAddMoneyBalance
                                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                , db.Parameter("@CustomerBalanceID", customerBalanceID, DbType.Int32)
                                                , db.Parameter("@ActionMode", 1, DbType.Int32)//1:消费支出、2:消费支出撤销、3:储值卡充值、4:储值卡充值撤销、5:储值卡直扣、6:储值卡直扣撤销、7:储值卡直充赠送、8:储值卡直充赠送撤销、9:储值卡退款、10:储值卡退款撤销
                                                , db.Parameter("@DepositMode", 0, DbType.Int32)//1:现金、2:银行卡、3:余额转入、4:其他
                                                , db.Parameter("@Remark", model.Remark, DbType.String)
                                                , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)
                                                , db.Parameter("@Amount", item.PaymentAmount, DbType.Decimal)
                                                , db.Parameter("@Balance", balance, DbType.Decimal)
                                                , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                                    if (addres <= 0)
                                    {
                                        db.RollbackTransaction();
                                        return 0;
                                    }
                                    #endregion

                                    #region PUSH
                                    string selectCustomerDevice = @"SELECT TOP 1 ISNULL(T3.DeviceID, '') AS DeviceID ,T1.Name AS CustomerName ,T3.DeviceType ,T2.smsheading AS CompanyName,ISNULL(T6.BalanceNotice, 0) AS Threshold ,T4.LoginMobile,T2.BalanceRemind ,T6.CardName ,T1.WeChatOpenID 
                                                FROM    [CUSTOMER] T1 WITH ( NOLOCK )
                                                        LEFT JOIN [COMPANY] T2 WITH ( NOLOCK ) ON T1.CompanyID = T2.ID
                                                        LEFT JOIN [LOGIN] T3 WITH ( NOLOCK ) ON T1.UserID = T3.UserID
                                                        LEFT JOIN [USER] T4 WITH ( NOLOCK ) ON T4.ID = t1.UserID
                                                        LEFT JOIN [TBL_CUSTOMER_CARD] T5 WITH ( NOLOCK ) ON T5.UserID = T4.ID AND T5.UserCardNo=@userCardNo
                                                        LEFT JOIN [MST_CARD] T6 WITH(NOLOCK) ON T5.CardID=T6.ID
                                                WHERE   T1.UserID = @CustomerID";
                                    PushOperation_Model pushmodel = db.SetCommand(selectCustomerDevice, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                                                                                        , db.Parameter("@userCardNo", item.UserCardNo, DbType.String)).ExecuteObject<PushOperation_Model>();
                                    if (pushmodel != null)
                                    {
                                        Task.Factory.StartNew(() =>
                                        {
                                            if (isBalanceChangePush)
                                            {
                                                if (pushmodel.BalanceRemind)
                                                {
                                                    #region 微信push
                                                    if (!string.IsNullOrWhiteSpace(pushmodel.WeChatOpenID))
                                                    {
                                                        HS.Framework.Common.WeChat.WeChat we = new HS.Framework.Common.WeChat.WeChat();
                                                        string accessToken = we.GetWeChatToken(model.CompanyID);
                                                        if (!string.IsNullOrWhiteSpace(accessToken))
                                                        {
                                                            HS.Framework.Common.WeChat.Entity.MessageTemplate messageModel = new HS.Framework.Common.WeChat.Entity.MessageTemplate();
                                                            HS.Framework.Common.WeChat.WXCompanyInfoBase WXCompanyInfoBase = we.GetBaseInfo(model.CompanyID);
                                                            messageModel.template_id = WXCompanyInfoBase.AccountChangesTemplate;
                                                            messageModel.topcolor = "#000000";
                                                            messageModel.touser = pushmodel.WeChatOpenID;
                                                            messageModel.data = new HS.Framework.Common.WeChat.Entity.TemplateDetail()
                                                            {
                                                                first = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#FF0000", value = "您有一笔账户消费支出\n" },
                                                                keyword1 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = model.CreateTime.ToString("yyyy-MM-dd HH:mm") },
                                                                keyword2 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = pushmodel.CardName },
                                                                keyword3 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#FF0000", value = item.PaymentAmount.ToString("C2") },
                                                                remark = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = "余额：" + balance.ToString("C2") + "\n\n您可以在账户交易明细中查看账户变动的详细内容。" }
                                                            };
                                                            we.TemplateMessageSend(messageModel, model.CompanyID, 1, accessToken);
                                                        }

                                                    }
                                                    #endregion

                                                    #region 余额变动短信息提醒
                                                    if (!string.IsNullOrEmpty(pushmodel.LoginMobile))
                                                    {
                                                        strPgm = st.GetFrame(0).GetMethod().Name + "(" + st.GetFrame(0).GetFileLineNumber().ToString() + ")";
                                                        int result = SMSInfo_DAL.Instance.getSMSInfo(model.CompanyID, pushmodel.LoginMobile, strPgm, model.CreatorID);
                                                        if (result == 0) {
                                                            Common.SendShortMessage.sendShortMessageForBalance(pushmodel.LoginMobile, pushmodel.CompanyName, model.CreateTime.ToString("MM月dd日HH时mm分"));
                                                            isBalanceChangePush = false;
                                                            //保存短信发送履历信息
                                                            string msg = string.Format(Const.MESSAGE_BALANCE, pushmodel.CompanyName, model.CreateTime.ToString("MM月dd日HH时mm分"));
                                                            strPgm = st.GetFrame(0).GetMethod().Name + "(" + st.GetFrame(0).GetFileLineNumber().ToString() + ")";
                                                            SMSInfo_DAL.Instance.addSMSHis(model.CompanyID, model.BranchID, pushmodel.LoginMobile, msg, strPgm, model.CreatorID);
                                                    }
                                                    }
                                                    #endregion
                                                }
                                            }

                                            #region 储值卡卡余额低于阀值PUSH提醒
                                            if (item.PaymentAmount != 0 && balance < pushmodel.Threshold && pushmodel.Threshold > 0)
                                            {

                                                if (!string.IsNullOrWhiteSpace(pushmodel.DeviceID))
                                                {
                                                    try
                                                    {
                                                        HS.Framework.Common.Push.HSPush.pushMsg(pushmodel.DeviceID, pushmodel.DeviceType, 0, "尊敬的" + pushmodel.CustomerName + "，您在" + pushmodel.CompanyName + "的" + pushmodel.CardName + "余额即将用完，请及时充值。", Convert.ToBoolean(System.Configuration.ConfigurationManager.AppSettings["IsProduction"]), "2");
                                                    }
                                                    catch (Exception)
                                                    {
                                                        LogUtil.Log("余额变动push失败", model.CustomerID + "push订单失败,时间:" + model.CreateTime);
                                                    }
                                                }
                                                else
                                                {
                                                    LogUtil.Log("余额变动push失败", model.CustomerID + "的DeviceID为空");
                                                }


                                            }
                                            #endregion
                                        });
                                    }
                                    else
                                    {
                                        LogUtil.Log("余额变动push失败", model.CustomerID + "数据抽取失败");
                                    }
                                    #endregion
                                }
                                else if (item.CardType == 2)
                                {
                                    #region 积分卡
                                    string strAddPointBalance = @" INSERT INTO [TBL_POINT_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CreatorID ,CreateTime) 
                VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CreatorID ,@CreateTime)";

                                    int addres = db.SetCommand(strAddPointBalance
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                            , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                            , db.Parameter("@CustomerBalanceID", customerBalanceID, DbType.Int32)
                                            , db.Parameter("@ActionMode", 1, DbType.Int32)//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                            , db.Parameter("@DepositMode", 0, DbType.Int32)//1:充值、2:余额转入
                                            , db.Parameter("@Remark", model.Remark, DbType.String)
                                            , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)
                                            , db.Parameter("@Amount", item.PaymentAmount, DbType.Decimal)
                                            , db.Parameter("@Balance", balance, DbType.Decimal)
                                            , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                            , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                                    if (addres <= 0)
                                    {
                                        db.RollbackTransaction();
                                        return 0;
                                    }
                                    #endregion
                                }
                                else if (item.CardType == 3)
                                {
                                    #region 现金券
                                    string strAddCouponBalance = @" INSERT INTO [TBL_COUPON_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CouponType ,CreatorID ,CreateTime) 
                VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CouponType ,@CreatorID ,@CreateTime)";

                                    int addres = db.SetCommand(strAddCouponBalance,
                                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                            db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                            db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                                            db.Parameter("@CustomerBalanceID", customerBalanceID, DbType.Int32),
                                            db.Parameter("@ActionMode", 1, DbType.Int32),// 1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                            db.Parameter("@DepositMode", 0, DbType.Int32),//1:充值、2:余额转入
                                            db.Parameter("@Remark", model.Remark, DbType.String),
                                            db.Parameter("@UserCardNo", item.UserCardNo, DbType.String),
                                            db.Parameter("@Amount", item.PaymentAmount, DbType.Decimal),
                                            db.Parameter("@Balance", balance, DbType.Decimal),
                                            db.Parameter("@CouponType", 0, DbType.Int32),
                                            db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                            db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                                    if (addres <= 0)
                                    {
                                        db.RollbackTransaction();
                                        return 0;
                                    }

                                    #endregion
                                }

                                #region 修改CustomerCard中的Balance

                                string strAddHis = @" INSERT INTO [HST_CUSTOMER_CARD] SELECT * FROM [TBL_CUSTOMER_CARD] WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo ";
                                int hisRows = db.SetCommand(strAddHis, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                        , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                                        , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteNonQuery();

                                if (hisRows == 0)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }

                                string strUpdateCustomerCard = @" UPDATE [TBL_CUSTOMER_CARD] SET Balance=@Balance ,UpdaterID = @UpdaterID , UpdateTime = @UpdateTime WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo";
                                int updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", balance, DbType.Decimal)
                                                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                        , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                                        , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)
                                                                        , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                                                                        , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                                if (updateRes == 0)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }
                                #endregion

                                #endregion
                            }
                        }
                        #endregion

                        #region 插入PaymentDetail表
                        decimal totalMyCalAmount = 0;
                        foreach (PaymentDetail_Model item in model.PaymentDetailList)
                        {
                            #region 插入表
                            if (Math.Abs(item.PaymentAmount) > 0)//排除传过来为0的记录
                            {
                                item.PaymentAmount = Math.Abs(item.PaymentAmount);
                                decimal paymentAmount = item.PaymentAmount;
                                decimal rate = 1;
                                decimal ProfitRate = 1;

                                #region 查询积分/现金券的抵扣额度
                                string selRateSql = @" SELECT  ISNULL(T2.Rate, 1) AS Rate,ISNULL(T2.ProfitRate, 1) AS ProfitRate
                                                        FROM    [TBL_CUSTOMER_CARD] T1 WITH ( NOLOCK )
                                                                LEFT JOIN [MST_CARD] T2 ON T1.CardID = T2.ID
                                                        WHERE   T1.CompanyID = @CompanyID
                                                                AND T1.UserCardNo = @UserCardNo ";
                                DataTable table = db.SetCommand(selRateSql
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteDataTable();

                                if (table == null || table.Rows.Count < 1)
                                {
                                    ProfitRate = 1;
                                }
                                else
                                {
                                    ProfitRate = StringUtils.GetDbDecimal(table.Rows[0]["ProfitRate"]);
                                }
                                #endregion

                                if (item.CardType == 2 || item.CardType == 3)
                                {
                                    rate = StringUtils.GetDbDecimal(table.Rows[0]["Rate"]);
                                    paymentAmount = Math.Round(item.PaymentAmount * rate, 2, MidpointRounding.AwayFromZero);
                                }

                                string strSqlDetailAdd = @"insert into PAYMENT_DETAIL(CompanyID,PaymentID,PaymentMode,PaymentAmount,CreatorID,CreateTime,UserCardNo,CardPaidAmount ,ProfitRate) 
                                                    values (@CompanyID,@PaymentID,@PaymentMode,@PaymentAmount,@CreatorID,@CreateTime,@UserCardNo,@CardPaidAmount ,@ProfitRate);select @@IDENTITY";

                                int paymentDetailID = db.SetCommand(strSqlDetailAdd
                                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                    , db.Parameter("@PaymentID", paymentID, DbType.Int32)
                                                    , db.Parameter("@PaymentMode", item.PaymentMode, DbType.Int32)
                                                    , db.Parameter("@PaymentAmount", paymentAmount, DbType.Decimal)
                                                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)
                                                    , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)
                                                    , db.Parameter("@CardPaidAmount", item.PaymentAmount, DbType.Decimal)
                                                    , db.Parameter("@ProfitRate", ProfitRate, DbType.Decimal)).ExecuteScalar<int>();

                                if (paymentDetailID <= 0)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }

                                object CommFlag = DBNull.Value;//1：首充 2：指定 3：E账户
                                if (item.PaymentMode == 1 || item.PaymentMode == 6 || item.PaymentMode == 7)
                                {
                                    CommFlag = 3;
                                }

                                totalMyCalAmount += paymentAmount;

                                string strSelCompanyComissionCalcSql = " SELECT [ComissionCalc] FROM COMPANY WHERE ID=@CompanyID ";
                                bool isComissionCalc = db.SetCommand(strSelCompanyComissionCalcSql
                                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<bool>();

                                if (isComissionCalc)
                                {
                                    #region 计算销售业绩
                                    foreach (int orderID in orderIDListWithout0Price)
                                    {
                                        #region 取出Product基本数据
                                        string strSelProductSql = @" SELECT CASE T1.ProductType
                                                                        WHEN 0 THEN T2.ServiceCode
                                                                        ELSE T3.CommodityCode
                                                                    END AS ProductCode ,
                                                                    T1.ProductType ,T1.TotalSalePrice 
                                                                FROM   [ORDER] T1 WITH ( NOLOCK )
                                                                    LEFT JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.ID = T2.OrderID
                                                                    LEFT JOIN [TBL_ORDER_COMMODITY] T3 WITH ( NOLOCK ) ON T1.ID = T3.OrderID
                                                                WHERE  T1.CompanyID = @CompanyID
                                                                    AND T1.ID = @OrderID; ";
                                        DataTable dt = db.SetCommand(strSelProductSql
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteDataTable();

                                        if (dt == null || dt.Rows.Count < 1)
                                        {
                                            db.RollbackTransaction();
                                            return 0;
                                        }

                                        int productType = StringUtils.GetDbInt(dt.Rows[0]["ProductType"]);
                                        long productCode = StringUtils.GetDbLong(dt.Rows[0]["ProductCode"]);
                                        decimal TotalSalePrice = StringUtils.GetDbDecimal(dt.Rows[0]["TotalSalePrice"]);
                                        #endregion

                                        #region 取出TBL_PRODUCT_COMMISSION_RULE数据
                                        string strSelProductCommissionRuleSql = @" SELECT ProductType ,
                                                                                    ProductCode ,
                                                                                    ProfitPct ,
                                                                                    ECardSACommType ,
                                                                                    ECardSACommValue ,
                                                                                    NECardSACommType ,
                                                                                    NECardSACommValue
                                                                                FROM   TBL_PRODUCT_COMMISSION_RULE
                                                                                WHERE  CompanyID = @CompanyID
                                                                                    AND ProductType = @ProductType
                                                                                    AND ProductCode = @ProductCode ";

                                        Product_Commission_Rule_Model ProductRuleModel = db.SetCommand(strSelProductCommissionRuleSql
                                                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                            , db.Parameter("@ProductType", productType, DbType.Int32)
                                                                            , db.Parameter("@ProductCode", productCode, DbType.Int64)).ExecuteObject<Product_Commission_Rule_Model>();
                                        #endregion

                                        if (ProductRuleModel != null && ProductRuleModel.ProductCode > 0)
                                        {
                                            decimal Income = 0;
                                            if (model.OrderCount > 1)
                                            {
                                                Income = TotalSalePrice * (paymentBranchRole.IsUseRate != 1 ? 1 : ProfitRate);
                                            }
                                            else
                                            {
                                                Income = paymentAmount * (paymentBranchRole.IsUseRate != 1 ? 1 : ProfitRate);
                                            }
                                            decimal Profit = Income * ProductRuleModel.ProfitPct;
                                            int CommType = 0;
                                            decimal CommValue = 0;
                                            if (CommFlag != DBNull.Value)
                                            {
                                                #region E账户
                                                CommType = ProductRuleModel.ECardSACommType;
                                                CommValue = ProductRuleModel.ECardSACommValue;
                                                #endregion
                                            }
                                            else
                                            {
                                                #region 非E账户
                                                CommType = ProductRuleModel.NECardSACommType;
                                                CommValue = ProductRuleModel.NECardSACommValue;
                                                #endregion
                                            }

                                            string strAddProfitDetailSql = @" INSERT INTO TBL_PROFIT_COMMISSION_DETAIL ( CompanyID ,BranchID ,SourceType ,SourceID ,SubSourceID ,Income ,ProfitPct ,Profit ,CommType ,CommValue ,AccountID ,AccountProfitPct ,AccountProfit ,AccountComm ,CommFlag , CreatorID ,CreateTime ) 
                                                                VALUES ( @CompanyID ,@BranchID ,@SourceType ,@SourceID ,@SubSourceID ,@Income ,@ProfitPct ,@Profit ,@CommType ,@CommValue ,@AccountID ,@AccountProfitPct ,@AccountProfit ,@AccountComm ,@CommFlag , @CreatorID ,@CreateTime ) ";
                                            if (paymentID >= 0 && model.Slavers != null && model.Slavers.Count > 0)
                                            {
                                                #region 有业绩分享人
                                                foreach (Slave_Model slaveItem in model.Slavers)
                                                {
                                                    decimal EveryProfitPct = 0;
                                                    //业绩均分flag
                                                    if (model.AverageFlag == 1)
                                                    {
                                                        EveryProfitPct = Math.Round((decimal)1 / model.Slavers.Count, 2);
                                                    }
                                                    else
                                                    {
                                                        EveryProfitPct = slaveItem.ProfitPct;
                                                    }

                                                    #region 有业绩分享人
                                                    //员工业绩(=实际业绩 x 员工业绩计算比例)
                                                    decimal AccountProfit = Profit * EveryProfitPct;
                                                    decimal AccountComm = 0;
                                                    if (model.OrderCount > 1)
                                                    {
                                                        AccountComm = Math.Round(CommValue * 1 * EveryProfitPct, 2, MidpointRounding.AwayFromZero);
                                                    }
                                                    else
                                                    {
                                                        AccountComm = Math.Round(CommValue * (paymentAmount / TotalSalePrice) * EveryProfitPct, 2, MidpointRounding.AwayFromZero);
                                                    }
                                                    //1:按比例 2:固定值
                                                    if (CommType == 1)
                                                    {
                                                        AccountComm = AccountProfit * CommValue;
                                                    }

                                                    int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                        , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                        , db.Parameter("@SourceType", 1, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                                        , db.Parameter("@SourceID", paymentDetailID, DbType.Int64)
                                                        , db.Parameter("@SubSourceID", orderID, DbType.Int64)
                                                        , db.Parameter("@Income", Income, DbType.Decimal)//收入 充值时，为TBL_MONEY_BALANCE的Amount
                                                        , db.Parameter("@ProfitPct", ProductRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                                        , db.Parameter("@Profit", Profit, DbType.Decimal)//实际业绩
                                                        , db.Parameter("@CommType", CommType, DbType.Int32)//该业绩的提成方式
                                                        , db.Parameter("@CommValue", CommValue, DbType.Decimal)//该业绩的提成数值
                                                        , db.Parameter("@AccountID", slaveItem.SlaveID, DbType.Int32)//获得该业绩的员工ID
                                                        , db.Parameter("@AccountProfitPct", EveryProfitPct, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                                        , db.Parameter("@AccountProfit", AccountProfit, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                                        , db.Parameter("@AccountComm", AccountComm, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
                                                        , db.Parameter("@CommFlag", CommFlag, DbType.Int32)//1：首充 2：指定 3：E账户
                                                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                                                    if (addProfitDetailRes != 1)
                                                    {
                                                        db.RollbackTransaction();
                                                        return 0;
                                                    }
                                                    #endregion
                                                }
                                                #endregion
                                            }
                                            else
                                            {
                                                #region 没有业绩分享人
                                                int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                        , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                        , db.Parameter("@SourceType", 1, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                                        , db.Parameter("@SourceID", paymentDetailID, DbType.Int64)
                                                        , db.Parameter("@SubSourceID", orderID, DbType.Int64)
                                                        , db.Parameter("@Income", Income, DbType.Decimal)//收入 充值时，为TBL_MONEY_BALANCE的Amount
                                                        , db.Parameter("@ProfitPct", ProductRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                                        , db.Parameter("@Profit", Profit, DbType.Decimal)//实际业绩
                                                        , db.Parameter("@CommType", CommType, DbType.Int32)//该业绩的提成方式
                                                        , db.Parameter("@CommValue", CommValue, DbType.Decimal)//该业绩的提成数值
                                                        , db.Parameter("@AccountID", DBNull.Value, DbType.Int32)//获得该业绩的员工ID
                                                        , db.Parameter("@AccountProfitPct", DBNull.Value, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                                        , db.Parameter("@AccountProfit", DBNull.Value, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                                        , db.Parameter("@AccountComm", DBNull.Value, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
                                                        , db.Parameter("@CommFlag", CommFlag, DbType.Int32)//1：首充 2：指定 3：E账户
                                                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                                                if (addProfitDetailRes != 1)
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
                            }
                            #endregion
                        }
                        #endregion


                        if (Math.Round(totalMyCalAmount, 2, MidpointRounding.AwayFromZero) != model.TotalPrice)
                        {
                            db.RollbackTransaction();
                            return 7;
                        }

                        #region 抽取专属顾问数据
                        string strSelOrderInfoSql = @" SELECT  T1.AccountID
                                                        FROM    RELATIONSHIP T1 WITH ( NOLOCK )
                                                        WHERE   CustomerID = @CustomerID
                                                                AND T1.Type = 1 
                                                                AND T1.Available = 1
                                                                AND T1.BranchID = @BranchID";

                        int ResponsiblePersonID = db.SetCommand(strSelOrderInfoSql
                            , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                            , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteScalar<int>();

                        #endregion

                        foreach (int orderID in orderIDListWithout0Price)
                        {
                            #region 插入OrderPayment关系表
                            string strSqlOrderPayAdd = @"insert into TBL_OrderPayment_RelationShip(OrderID,PaymentID) 
                                                            values (@OrderID,@PaymentID);select @@IDENTITY";
                            int orderPaymentRes = db.SetCommand(strSqlOrderPayAdd
                                                    , db.Parameter("@OrderID", orderID, DbType.Int32)
                                                    , db.Parameter("@PaymentID", paymentID, DbType.Int32)
                                                    //,db.Parameter("@ResponsiblePersonID", responsiblePersonID, DbType.Int32),
                                                    //,db.Parameter("@SalesID", salesID, DbType.Int32)
                                                    ).ExecuteNonQuery();

                            if (orderPaymentRes <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                            #endregion

                            #region 支付状态判断
                            decimal unpaidPrice = 0;
                            int paymentStatus = 1;
                            if (orderIDListWithout0Price.Count == 1 && paymentBranchRole.IsPartPay)
                            {
                                //可以分期支付 查询未支付金额
                                string strSqlSelectUnpaidPrice = @"SELECT UnPaidPrice FROM  [ORDER] WHERE ID=@OrderID";
                                decimal orderUnpaidPrice = db.SetCommand(strSqlSelectUnpaidPrice, db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteScalar<decimal>();
                                if (orderUnpaidPrice <= 0 || orderUnpaidPrice < model.TotalPrice)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }
                                unpaidPrice = orderUnpaidPrice - model.TotalPrice;
                                if (unpaidPrice <=0.01M)
                                {
                                    paymentStatus = 3; // 完全支付
                                    unpaidPrice = 0;
                                }
                                else
                                {
                                    paymentStatus = 2; // 部分支付
                                }
                            }
                            else
                            {
                                unpaidPrice = 0;
                                paymentStatus = 3;
                            }
                            #endregion

                            #region 更新订单状态和PaymentID
                            string strSqlOrderUpt = @"update [ORDER] set UnPaidPrice=@UnPaidPrice, PaymentStatus=@PaymentStatus,UpdaterID = @UpdaterID, UpdateTime = @UpdateTime where ID =@OrderID";

                            int orderuptRes = db.SetCommand(strSqlOrderUpt,
                                db.Parameter("@UnPaidPrice", unpaidPrice, DbType.Decimal),// 未支付金额
                                db.Parameter("@PaymentStatus", paymentStatus, DbType.Int32),// 1:未支付 2:部分支付 3:完全支付
                                db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32),
                                db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime),
                                db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteNonQuery();

                            if (orderuptRes <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            #endregion
                        }

                        #region 赠送
                        if (model.GiveDetailList != null && model.GiveDetailList.Count > 0)
                        {

                            #region 插入CUSTOMER_BALANCE
                            if (customerBalanceID <= 0)
                            {
                                string strAddCustomerBalance = @" INSERT [TBL_CUSTOMER_BALANCE]	( CompanyID ,BranchID ,UserID ,ChangeType ,TargetAccount  ,PaymentID ,Remark ,CreatorID ,CreateTime) 
                            VALUES(@CompanyID ,@BranchID ,@UserID ,@ChangeType ,@TargetAccount  ,@PaymentID ,@Remark ,@CreatorID ,@CreateTime);select @@IDENTITY";
                                customerBalanceID = db.SetCommand(strAddCustomerBalance,
                                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                            db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                            db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                                            db.Parameter("@ChangeType", 1, DbType.Int32),//1:账户消费、2:账户消费撤销、3：账户充值、4：账户充值撤销、5：账户直扣、6：账户直扣撤销(9:退款 也属于账户直扣)
                                            db.Parameter("@TargetAccount", 0, DbType.Int32),//目标账户：1:储值卡、2:积分、3:现金券  账户消费和消费撤销时，设默认值0
                                            db.Parameter("@ResponsiblePersonID", model.CreatorID, DbType.Int32),
                                            db.Parameter("@PaymentID", paymentID, DbType.Int32),
                                            db.Parameter("@Remark", model.Remark, DbType.String),
                                            db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                            db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteScalar<int>();

                                if (customerBalanceID <= 0)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }
                            }
                            #endregion

                            foreach (PaymentDetail_Model item in model.GiveDetailList)
                            {
                                if (item.PaymentAmount != 0)
                                {
                                    string strSqlGetBalance = @"SELECT  T1.Balance  
                                                        FROM    [TBL_CUSTOMER_CARD] T1 WITH ( NOLOCK )
                                                        WHERE   T1.CompanyID = @CompanyID
                                                                AND T1.UserID = @CustomerID
                                                                AND T1.UserCardNo = @UserCardNo";
                                    decimal balance = db.SetCommand(strSqlGetBalance
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                        , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteScalar<decimal>();

                                    item.PaymentAmount = Math.Abs(item.PaymentAmount);
                                    balance = balance + item.PaymentAmount;

                                    #region 消费赠送
                                    if (item.CardType == 2 && item.PaymentAmount > 0)
                                    {
                                        #region 积分卡
                                        string strAddPointBalance = @" INSERT INTO [TBL_POINT_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CreatorID ,CreateTime) 
                VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CreatorID ,@CreateTime)";

                                        int addres = db.SetCommand(strAddPointBalance
                                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                , db.Parameter("@CustomerBalanceID", customerBalanceID, DbType.Int32)
                                                , db.Parameter("@ActionMode", 3, DbType.Int32)//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                                , db.Parameter("@DepositMode", 0, DbType.Int32)//1:充值、2:余额转入
                                                , db.Parameter("@Remark", model.Remark, DbType.String)
                                                , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)
                                                , db.Parameter("@Amount", item.PaymentAmount, DbType.Decimal)
                                                , db.Parameter("@Balance", balance, DbType.Decimal)
                                                , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                                        if (addres <= 0)
                                        {
                                            db.RollbackTransaction();
                                            return 0;
                                        }
                                        #endregion
                                    }
                                    else if (item.CardType == 3 && item.PaymentAmount > 0)
                                    {
                                        #region 现金券
                                        string strAddCouponBalance = @" INSERT INTO [TBL_COUPON_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CouponType ,CreatorID ,CreateTime) 
                VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CouponType ,@CreatorID ,@CreateTime)";

                                        int addres = db.SetCommand(strAddCouponBalance,
                                                db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                                db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                                db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                                                db.Parameter("@CustomerBalanceID", customerBalanceID, DbType.Int32),
                                                db.Parameter("@ActionMode", 3, DbType.Int32),// 1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                                db.Parameter("@DepositMode", 0, DbType.Int32),//1:充值、2:余额转入
                                                db.Parameter("@Remark", model.Remark, DbType.String),
                                                db.Parameter("@UserCardNo", item.UserCardNo, DbType.String),
                                                db.Parameter("@Amount", item.PaymentAmount, DbType.Decimal),
                                                db.Parameter("@Balance", balance, DbType.Decimal),
                                                db.Parameter("@CouponType", 0, DbType.Int32),
                                                db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                                db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                                        if (addres <= 0)
                                        {
                                            db.RollbackTransaction();
                                            return 0;
                                        }

                                        #endregion
                                    }

                                    #region 修改CustomerCard中的Balance
                                    string strUpdateCustomerCard = @" UPDATE [TBL_CUSTOMER_CARD] SET Balance=@Balance WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo";
                                    int updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", balance, DbType.Decimal)
                                                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                            , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                                            , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteNonQuery();

                                    if (updateRes == 0)
                                    {
                                        db.RollbackTransaction();
                                        return 0;
                                    }
                                    #endregion
                                    #endregion
                                }
                            }
                        }
                        #endregion

                        #region 美丽顾问/销售顾问
                        string strAddConsultant = @" INSERT INTO [TBL_BUSINESS_CONSULTANT]( CompanyID ,BusinessType ,MasterID ,ConsultantType ,ConsultantID ,CreatorID ,CreateTime )
                                                VALUES ( @CompanyID ,@BusinessType ,@MasterID ,@ConsultantType ,@ConsultantID ,@CreatorID ,@CreateTime )";

                        #region 美丽顾问
                        if (ResponsiblePersonID > 0)
                        {
                            int addConsultantRes = db.SetCommand(strAddConsultant
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@BusinessType", 2, DbType.Int32)//1：订单，2：支付，3：充值
                                    , db.Parameter("@MasterID", paymentID, DbType.Int32)
                                    , db.Parameter("@ConsultantType", 1, DbType.Int32)//1:美丽顾问 2:销售顾问
                                    , db.Parameter("@ConsultantID", ResponsiblePersonID, DbType.Int32)
                                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                            if (addConsultantRes <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                        }
                        #endregion

                        string advanced = WebAPI.DAL.Company_DAL.Instance.getAdvancedByCompanyID(model.CompanyID);
                        if (advanced.Contains("|4|"))
                        {
                            #region 销售顾问
                            string strSelSalesSql = @"SELECT  AccountID
                                        FROM    [RELATIONSHIP]
                                        WHERE   companyID = @CompanyID
                                                AND BranchID = @BranchID
                                                AND CustomerID = @CustomerID
                                                AND Available = 1
                                                AND Type = 2";

                            List<int> SalesPersonIDList = db.SetCommand(strSelSalesSql,
                                    db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                    db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                    db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteScalarList<int>();

                            if (SalesPersonIDList != null || SalesPersonIDList.Count > 0)
                            {
                                foreach (int SalesPersonID in SalesPersonIDList)
                                {
                                    int addConsultantRes = db.SetCommand(strAddConsultant
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@BusinessType", 2, DbType.Int32)//1：订单，2：支付，3：充值
                                    , db.Parameter("@MasterID", paymentID, DbType.Int32)
                                    , db.Parameter("@ConsultantType", 2, DbType.Int32)//1:美丽顾问 2:销售顾问
                                    , db.Parameter("@ConsultantID", SalesPersonID, DbType.Int32)
                                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                                    if (addConsultantRes <= 0)
                                    {
                                        db.RollbackTransaction();
                                        return 0;
                                    }
                                }
                            }
                            #endregion
                        }
                        #endregion
                    }
                    db.CommitTransaction();
                    return 1;
                }
                catch (Exception ex)
                {
                    db.RollbackTransaction();
                    throw ex;
                }
            }
        }

        public RefundOrderInfo_Model getRefundOrderInfo(int companyID, int branchID, int customerID, int orderID, int productType, out int res)
        {
            using (DbManager db = new DbManager())
            {
                res = 1;
                RefundOrderInfo_Model model = new RefundOrderInfo_Model();

                #region 是否有支付过的信息
                //string strSelPaymentIDSql = @" SELECT PaymentID FROM  [TBL_ORDERPAYMENT_RELATIONSHIP] WITH(NOLOCK) WHERE OrderID=@OrderID ";
                //List<int> paymentIDList = db.SetCommand(strSelPaymentIDSql
                //            , db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteScalarList<int>();

                //if (paymentIDList == null || paymentIDList.Count <= 0)
                //{
                //    res = -1;
                //    return null;
                //}
                #endregion

                #region 合并支付的订单不能退款
                //foreach (int paymentID in paymentIDList)
                //{
                //    string strSelOrderCountSql = " SELECT COUNT(0) FROM  [TBL_ORDERPAYMENT_RELATIONSHIP] WITH(NOLOCK) WHERE PaymentID=@PaymentID ";
                //    int orderCount = db.SetCommand(strSelOrderCountSql
                //            , db.Parameter("@PaymentID", paymentID, DbType.Int32)).ExecuteScalar<int>();

                //    if (orderCount > 1)
                //    {
                //        res = -2;
                //        return null;
                //    }
                //}
                #endregion

                #region 查询应退金额
                string strSelRefundAmount = "";
                if (productType == 0)
                {
                    strSelRefundAmount = @" SELECT  CASE T2.TGTotalCount
                                                              WHEN 0 THEN 0
                                                              ELSE ( T1.TotalSalePrice - T1.UnPaidPrice - T1.RefundSumAmount) * ( T2.TGTotalCount - T2.TGFinishedCount ) / T2.TGTotalCount  
                                                            END AS RefundAmount ,
                                                    CASE T2.TGTotalCount
                                                              WHEN 0 THEN 0
                                                              ELSE ( T2.TGTotalCount - T2.TGFinishedCount) / CAST(T2.TGTotalCount AS dec(12,2))
                                                            END AS Rate
                                                    FROM    [ORDER] T1
                                                            INNER JOIN [TBL_ORDER_SERVICE] T2 ON T1.ID = T2.OrderID
                                                    WHERE   OrderID = @OrderID ";
                }
                else
                {
                    strSelRefundAmount = @" SELECT  CASE T2.Quantity
                                                      WHEN 0 THEN 0
                                                      ELSE ( T1.TotalSalePrice - T1.UnPaidPrice - T1.RefundSumAmount) * ( T2.Quantity - T2.DeliveredAmount ) / T2.Quantity 
                                                    END AS RefundAmount ,
                                                    CASE T2.Quantity
                                                              WHEN 0 THEN 0
                                                              ELSE ( T2.Quantity - T2.DeliveredAmount) / CAST(T2.Quantity AS dec(12,2)) 
                                                            END AS Rate
                                            FROM    [ORDER] T1
                                                    INNER JOIN [TBL_ORDER_COMMODITY] T2 ON T1.ID = T2.OrderID
                                            WHERE   OrderID = @OrderID ";
                }

                DataTable dt = db.SetCommand(strSelRefundAmount, db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteDataTable();
                if (dt == null || dt.Rows.Count != 1)
                {
                    return null;
                }
                decimal refundAmount = StringUtils.GetDbDecimal(dt.Rows[0]["RefundAmount"]);
                model.RefundAmount = Math.Round(refundAmount, 2);
                decimal rate = StringUtils.GetDbDecimal(dt.Rows[0]["Rate"]);
                model.Rate = rate;
                #endregion

                #region 查询Payment信息
                string strSql = @"SELECT  T2.PaymentTime ,
                                            ISNULL(T3.Name, T4.Name) AS Operator ,
                                            T2.TotalPrice ,
                                            T2.ID AS PaymentID ,
                                            T2.OrderNumber ,
                                            T2.Type ,
                                            T2.CreateTime ,
                                            T5.BranchName ,
                                            T2.ID AS PaymentID ,
                                            T2.Remark ,
                                            CASE T2.Type WHEN 1 THEN '消费' ELSE '消费退款' END AS TypeName  
                                    FROM    [TBL_OrderPayment_RelationShip] T1 WITH ( NOLOCK )
                                            LEFT JOIN [PAYMENT] T2 WITH ( NOLOCK ) ON T2.ID = T1.PaymentID
                                            LEFT JOIN [ACCOUNT] T3 WITH ( NOLOCK ) ON T2.CreatorID = T3.UserID
                                            LEFT JOIN [CUSTOMER] T4 WITH ( NOLOCK ) ON T2.CreatorID = T4.UserID
                                            LEFT JOIN [BRANCH] T5 WITH ( NOLOCK ) ON T5.ID=T2.BranchID  
                                    WHERE   T2.CompanyID = @CompanyID
                                            AND ((T2.Status = 2 AND T2.Type = 1) OR (T2.Status = 7 AND T2.Type = 2)) 
                                            AND T1.OrderID = @OrderID 
                                            ORDER BY T2.CreateTime DESC ";

                model.PaymentList = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteList<RefundOrderPaymentList>();

                if (model.PaymentList != null && model.PaymentList.Count > 0)
                {
                    foreach (RefundOrderPaymentList item in model.PaymentList)
                    {
                        #region 获取赠送积分
                        string SelGivePointSql = @" SELECT  SUM(T2.Amount)
                                                    FROM    [TBL_CUSTOMER_BALANCE] T1 WITH ( NOLOCK )
                                                            INNER JOIN [TBL_POINT_BALANCE] T2 ON T1.ID = T2.CustomerBalanceID
                                                    WHERE   T1.CompanyID = @CompanyID
                                                            AND T1.PaymentID = @PaymentID
                                                            AND T2.ActionMode = 3
                                                            AND DepositMode = 0 ";
                        decimal givePointAmount = db.SetCommand(SelGivePointSql
                                                , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                , db.Parameter("@PaymentID", item.PaymentID, DbType.Int32)).ExecuteScalar<decimal>();

                        model.GivePointAmount += givePointAmount;
                        #endregion

                        #region 获取赠送现金券
                        string SelGiveCouponSql = @" SELECT  SUM(T2.Amount)
                                                    FROM    [TBL_CUSTOMER_BALANCE] T1 WITH ( NOLOCK )
                                                            INNER JOIN [TBL_COUPON_BALANCE] T2 ON T1.ID = T2.CustomerBalanceID
                                                    WHERE   T1.CompanyID = @CompanyID
                                                            AND T1.PaymentID = @PaymentID
                                                            AND T2.ActionMode = 3
                                                            AND DepositMode = 0 ";
                        decimal giveCouponAmount = db.SetCommand(SelGiveCouponSql
                                                , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                , db.Parameter("@PaymentID", item.PaymentID, DbType.Int32)).ExecuteScalar<decimal>();

                        model.GiveCouponAmount += giveCouponAmount;
                        #endregion

                        // 支付详情
                        List<PaymentDetailList_Model> paymentDetailList = Payment_DAL.Instance.GetPayDetailListByPaymentID(companyID, item.PaymentID);
                        item.PaymentDetailList = paymentDetailList;

                        //业绩参与人
                        List<Profit_Model> profitList = Payment_DAL.Instance.getProfitListByMasterID(item.PaymentID, 2);
                        item.ProfitList = profitList;

                        //销售顾问
                        String salesConsultantRateSql = @" SELECT SalesConsultantID,SalesConsultantName,CommissionRate FROM getCommissionRatebyPaymentID (@PaymentID) ";
                        item.SalesConsultantRates = db.SetCommand(salesConsultantRateSql, db.Parameter("@PaymentID", item.PaymentID, DbType.String)).ExecuteList<SalesConsultantRate_model>();

                        //PaymentCode
                        DateTime paymenttime = Convert.ToDateTime(item.PaymentTime);
                        item.PaymentCode = paymenttime.Month.ToString().PadLeft(2, '0') + paymenttime.Day.ToString().PadLeft(2, '0') + item.PaymentID.ToString().PadLeft(6, '0') + paymenttime.Year.ToString().Substring(paymenttime.Year.ToString().Length - 2, 2);
                    }

                    model.GivePointAmount = Math.Round(model.GivePointAmount * rate, 2);
                    model.GiveCouponAmount = Math.Round(model.GiveCouponAmount * rate, 2);
                }

                #endregion

                #region 获取用户卡信息
                List<GetECardList_Model> list = new List<GetECardList_Model>();
                List<GetECardList_Model> Cardlist = ECard_DAL.Instance.GetCustomerCardList(companyID, branchID, customerID);
                List<GetECardList_Model> PointCouponlist = ECard_DAL.Instance.GetCustomerPointCouponList(companyID, branchID, customerID);
                list.AddRange(Cardlist);
                list.AddRange(PointCouponlist);
                model.CardList = list;
                #endregion

                return model;
            }
        }

        public int PayRefund(PaymentRefundOperation_Modelcs model)
        {
            System.Diagnostics.StackTrace st = new System.Diagnostics.StackTrace(1, true);
            string strPgm;  //当前的程序名称及行号等监察信息

            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                //前端已经算过比例了
                /*
                // 查询应退金额和比例
                string strSelRefundAmount = "";
                if (model.ProductType == 0)
                {
                    strSelRefundAmount = @" SELECT  CASE T2.TGTotalCount
                                                              WHEN 0 THEN 0
                                                              ELSE ( T1.TotalSalePrice - T1.UnPaidPrice - T1.RefundSumAmount) * ( T2.TGTotalCount - T2.TGFinishedCount ) / T2.TGTotalCount  
                                                            END AS RefundAmount ,
                                                    CASE T2.TGTotalCount
                                                              WHEN 0 THEN 0
                                                              ELSE ( T2.TGTotalCount - T2.TGFinishedCount) / CAST(T2.TGTotalCount AS dec(12,2))
                                                            END AS Rate
                                                    FROM    [ORDER] T1
                                                            INNER JOIN [TBL_ORDER_SERVICE] T2 ON T1.ID = T2.OrderID
                                                    WHERE   OrderID = @OrderID ";
                }
                else
                {
                    strSelRefundAmount = @" SELECT  CASE T2.Quantity
                                                      WHEN 0 THEN 0
                                                      ELSE ( T1.TotalSalePrice - T1.UnPaidPrice - T1.RefundSumAmount) * ( T2.Quantity - T2.DeliveredAmount ) / T2.Quantity 
                                                    END AS RefundAmount ,
                                                    CASE T2.Quantity
                                                              WHEN 0 THEN 0
                                                              ELSE ( T2.Quantity - T2.DeliveredAmount) / CAST(T2.Quantity AS dec(12,2)) 
                                                            END AS Rate
                                            FROM    [ORDER] T1
                                                    INNER JOIN [TBL_ORDER_COMMODITY] T2 ON T1.ID = T2.OrderID
                                            WHERE   OrderID = @OrderID ";
                }

                DataTable dtRefundRate = db.SetCommand(strSelRefundAmount, db.Parameter("@OrderID", model.OrderID, DbType.Int32)).ExecuteDataTable();
                decimal refundRate = 1;
                if (dtRefundRate != null)
                {
                    refundRate = StringUtils.GetDbDecimal(dtRefundRate.Rows[0]["Rate"]);
                }*/


                int customerBalanceID = 0;
                bool isBalanceChangePush = true;//余额变动只push一次

                PaymentBranchRole paymentBranchRole = new PaymentBranchRole();
                paymentBranchRole.IsCustomerConfirm = true;
                paymentBranchRole.IsAccountEcardPay = false;
                paymentBranchRole.IsPartPay = false;
                //paymentBranchRole.IsUseRate = 2;

                #region 获取权限
                string strSqlCommand = @"select IsPay as IsAccountEcardPay,IsConfirmed as IsCustomerConfirm,IsPartPay ,IsUseRate from [BRANCH] 
                                                where BRANCH.ID = @BranchID ";

                paymentBranchRole = db.SetCommand(strSqlCommand,
                                                db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteObject<PaymentBranchRole>();
                #endregion

                if (paymentBranchRole == null)
                {
                    return 0;
                }

                decimal BranchProfitRate = model.BranchProfitRate;

                #region 插入PayMent表
                string strSqlPayAdd = @"insert into PAYMENT(CompanyID,OrderNumber,TotalPrice,CreatorID,CreateTime,Remark,PaymentTime,LevelID,Type,Status,BranchID,BranchProfitRate) 
                                              values (@CompanyID,@OrderNumber,@TotalPrice,@CreatorID,@CreateTime,@Remark,@PaymentTime,@LevelID,@Type,@Status,@BranchID,@BranchProfitRate);select @@IDENTITY";
                int paymentID = db.SetCommand(strSqlPayAdd,
                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                            db.Parameter("@OrderNumber", 1, DbType.Int32),
                            //db.Parameter("@TotalPrice", Math.Round(model.TotalPrice * refundRate, 2), DbType.Decimal),
                            db.Parameter("@TotalPrice", model.TotalPrice, DbType.Decimal),
                            db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                            db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime),
                            db.Parameter("@Remark", model.Remark, DbType.String),
                            db.Parameter("@PaymentTime", model.CreateTime, DbType.DateTime),
                            db.Parameter("@LevelID", DBNull.Value, DbType.Int32),
                            db.Parameter("@Type", 2, DbType.Int32),//1：支付 2：退款
                            db.Parameter("@Status", 7, DbType.Int32),//1：无效 2：支付执行 3：支付撤销 4:过去支付执行 5:过去支付撤消 6：支付撤销退款 7：订单终止退款
                            db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                            db.Parameter("@BranchProfitRate", BranchProfitRate, DbType.Decimal)).ExecuteScalar<int>();

                if (paymentID <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                #region 插入业绩分享人
                //退款 因为有可能会发生多次支付,而且比例可能都不一样,退款这不能区分到底退哪次,所以这边还是由画面录入业绩比例

                if (paymentID >= 0 && model.Slavers != null && model.Slavers.Count > 0)
                {
                    foreach (Slave_Model item in model.Slavers)
                    {
                        decimal EveryProfitPct = 0;
                        //业绩均分flag
                        if (model.AverageFlag == 1)
                        {
                            EveryProfitPct = Math.Round((decimal)1 / model.Slavers.Count, 2);
                        }
                        else
                        {
                            EveryProfitPct = item.ProfitPct;
                        }
                        string strAddProfitSql = @" INSERT	INTO TBL_PROFIT( MasterID ,SlaveID ,Type ,ProfitPct ,Available ,CreateTime ,CreatorID) 
                                                VALUES (@MasterID ,@SlaveID ,@Type ,@ProfitPct ,@Available ,@CreateTime ,@CreatorID)";
                        int addProfitres = db.SetCommand(strAddProfitSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@MasterID", paymentID, DbType.Int64)
                                        , db.Parameter("@SlaveID", item.SlaveID, DbType.Int64)
                                        , db.Parameter("@Type", 2, DbType.Int32)
                                        , db.Parameter("@ProfitPct", EveryProfitPct, DbType.Decimal)
                                        , db.Parameter("@Available", true, DbType.Boolean)
                                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)).ExecuteNonQuery();

                        if (addProfitres <= 0)
                        {
                            db.RollbackTransaction();
                            LogUtil.Log("插入业绩表出错", "PaymentID:" + paymentID + "插入业绩表出错。");
                            return 0;
                        }
                    }
                }
                #endregion

                #region 判断E卡是否能够支付
                foreach (PaymentDetail_Model item in model.PaymentDetailList)
                {
                    if (item.PaymentMode == 1 || item.PaymentMode == 6 || item.PaymentMode == 7)
                    {
                        if (!paymentBranchRole.IsAccountEcardPay)
                        {
                            // 没有Ecard支付权限
                            db.RollbackTransaction();
                            return 3;
                        }

                        #region 插入CUSTOMER_BALANCE
                        if (customerBalanceID <= 0)
                        {
                            string strAddCustomerBalance = @" INSERT [TBL_CUSTOMER_BALANCE]	( CompanyID ,BranchID ,UserID ,ChangeType ,TargetAccount  ,PaymentID ,Remark ,CreatorID ,CreateTime) 
                                        VALUES(@CompanyID ,@BranchID ,@UserID ,@ChangeType ,@TargetAccount  ,@PaymentID ,@Remark ,@CreatorID ,@CreateTime);select @@IDENTITY";
                            customerBalanceID = db.SetCommand(strAddCustomerBalance,
                                        db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                        db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                        db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                                        db.Parameter("@ChangeType", 7, DbType.Int32),//分类：1:帐户消费、2:帐户消费撤销、3：帐户充值、4：帐户充值撤销、5：帐户直扣、6：帐户直扣撤销 7：账户消费退款
                                        db.Parameter("@TargetAccount", 0, DbType.Int32),//目标账户：1:储值卡、2:积分、3:现金券  账户消费和消费撤销时，设默认值0
                                                                                        //db.Parameter("@ResponsiblePersonID", model.CreatorID, DbType.Int32),
                                        db.Parameter("@PaymentID", paymentID, DbType.Int32),
                                        db.Parameter("@Remark", model.Remark, DbType.String),
                                        db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                        db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteScalar<int>();

                            if (customerBalanceID <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                        }
                        #endregion

                        string strSqlGetBalance = @"SELECT  T1.Balance  
                                                            FROM    [TBL_CUSTOMER_CARD] T1 WITH ( NOLOCK )
                                                            WHERE   T1.CompanyID = @CompanyID
                                                                    AND T1.UserID = @CustomerID
                                                                    AND T1.UserCardNo = @UserCardNo";
                        decimal balance = db.SetCommand(strSqlGetBalance
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                            , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteScalar<decimal>();


                        //item.PaymentAmount = Math.Round(Math.Abs(item.PaymentAmount) * refundRate,2);
                        //decimal PaymentAmountMid = Math.Round(Math.Abs(item.PaymentAmount) * refundRate, 2);
                        decimal PaymentAmountMid = item.PaymentAmount;
                        balance = balance + PaymentAmountMid;

                        #region 消费
                        if (item.CardType == 1)
                        {
                            #region 储值卡
                            string strAddMoneyBalance = @" INSERT INTO [TBL_MONEY_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CreatorID ,@CreateTime)";

                            int addres = db.SetCommand(strAddMoneyBalance
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                        , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                        , db.Parameter("@CustomerBalanceID", customerBalanceID, DbType.Int32)
                                        , db.Parameter("@ActionMode", 9, DbType.Int32)//1:消费支出、2:消费支出撤销、3:储值卡充值、4:储值卡充值撤销、5:储值卡直扣、6:储值卡直扣撤销、7:储值卡直充赠送、8:储值卡直充赠送撤销、9:储值卡退款、10:储值卡退款撤销
                                        , db.Parameter("@DepositMode", 0, DbType.Int32)//1:现金、2:银行卡、3:余额转入、4:其他
                                        , db.Parameter("@Remark", model.Remark, DbType.String)
                                        , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)
                                        , db.Parameter("@Amount", PaymentAmountMid, DbType.Decimal)
                                        , db.Parameter("@Balance", balance, DbType.Decimal)
                                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                            if (addres <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                            #endregion

                            #region PUSH
                            string selectCustomerDevice = @"SELECT TOP 1 ISNULL(T3.DeviceID, '') AS DeviceID ,T1.Name AS CustomerName ,T3.DeviceType ,T2.smsheading AS CompanyName,ISNULL(T6.BalanceNotice, 0) AS Threshold ,T4.LoginMobile,T2.BalanceRemind ,T6.CardName ,T1.WeChatOpenID 
                                                    FROM    [CUSTOMER] T1 WITH ( NOLOCK )
                                                            LEFT JOIN [COMPANY] T2 WITH ( NOLOCK ) ON T1.CompanyID = T2.ID
                                                            LEFT JOIN [LOGIN] T3 WITH ( NOLOCK ) ON T1.UserID = T3.UserID
                                                            LEFT JOIN [USER] T4 WITH ( NOLOCK ) ON T4.ID = t1.UserID
                                                            LEFT JOIN [TBL_CUSTOMER_CARD] T5 WITH ( NOLOCK ) ON T5.UserID = T4.ID AND T5.UserCardNo=@userCardNo
                                                            LEFT JOIN [MST_CARD] T6 WITH(NOLOCK) ON T5.CardID=T6.ID
                                                    WHERE   T1.UserID = @CustomerID";
                            PushOperation_Model pushmodel = db.SetCommand(selectCustomerDevice, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                                                                              , db.Parameter("@userCardNo", item.UserCardNo, DbType.String)).ExecuteObject<PushOperation_Model>();
                            if (pushmodel != null)
                            {
                                if (isBalanceChangePush)
                                {
                                    if (pushmodel.BalanceRemind)
                                    {
                                        Task.Factory.StartNew(() =>
                                        {
                                            #region 微信push
                                            if (!string.IsNullOrWhiteSpace(pushmodel.WeChatOpenID))
                                            {
                                                HS.Framework.Common.WeChat.WeChat we = new HS.Framework.Common.WeChat.WeChat();
                                                string accessToken = we.GetWeChatToken(model.CompanyID);
                                                if (!string.IsNullOrWhiteSpace(accessToken))
                                                {
                                                    HS.Framework.Common.WeChat.Entity.MessageTemplate messageModel = new HS.Framework.Common.WeChat.Entity.MessageTemplate();
                                                    HS.Framework.Common.WeChat.WXCompanyInfoBase WXCompanyInfoBase = we.GetBaseInfo(model.CompanyID);
                                                    messageModel.template_id = WXCompanyInfoBase.AccountChangesTemplate;
                                                    messageModel.topcolor = "#000000";
                                                    messageModel.touser = pushmodel.WeChatOpenID;
                                                    messageModel.data = new HS.Framework.Common.WeChat.Entity.TemplateDetail()
                                                    {
                                                        first = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#FF0000", value = "您有一笔账户消费退款\n" },
                                                        keyword1 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = model.CreateTime.ToString("yyyy-MM-dd HH:mm") },
                                                        keyword2 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = pushmodel.CardName },
                                                        keyword3 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#FF0000", value = item.PaymentAmount.ToString("C2") },
                                                        remark = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = "余额：" + balance.ToString("C2") + "\n\n您可以在账户交易明细中查看账户变动的详细内容。" }
                                                    };
                                                    we.TemplateMessageSend(messageModel, model.CompanyID, 1, accessToken);
                                                }
                                            }
                                            #endregion

                                            #region 余额变动短信息提醒
                                            if (!string.IsNullOrEmpty(pushmodel.LoginMobile))
                                            {
                                                strPgm = st.GetFrame(0).GetMethod().Name + "(" + st.GetFrame(0).GetFileLineNumber().ToString() + ")";
                                                int result = SMSInfo_DAL.Instance.getSMSInfo(model.CompanyID, pushmodel.LoginMobile, strPgm, model.CreatorID);
                                                if (result == 0)
                                                {
                                                    Common.SendShortMessage.sendShortMessageForBalance(pushmodel.LoginMobile, pushmodel.CompanyName, model.CreateTime.ToString("MM月dd日HH时mm分"));
                                                    isBalanceChangePush = false;
                                                    //保存短信发送履历信息
                                                    string msg = string.Format(Const.MESSAGE_BALANCE, pushmodel.CompanyName, model.CreateTime.ToString("MM月dd日HH时mm分"));
                                                    strPgm = st.GetFrame(0).GetMethod().Name + "(" + st.GetFrame(0).GetFileLineNumber().ToString() + ")";
                                                    SMSInfo_DAL.Instance.addSMSHis(model.CompanyID, model.BranchID, pushmodel.LoginMobile, msg, strPgm, model.CreatorID);
                                                }
                                            }
                                            #endregion
                                        });
                                    }
                                }
                            }
                            else
                            {
                                LogUtil.Log("余额变动push失败", model.CustomerID + "数据抽取失败");
                            }
                            #endregion
                        }
                        else if (item.CardType == 2)
                        {
                            #region 积分卡
                            string strAddPointBalance = @" INSERT INTO [TBL_POINT_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CreatorID ,@CreateTime)";

                            int addres = db.SetCommand(strAddPointBalance
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                    , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                    , db.Parameter("@CustomerBalanceID", customerBalanceID, DbType.Int32)
                                    , db.Parameter("@ActionMode", 11, DbType.Int32)//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销 11:积分消费返还 12:积分消费返还撤销 13:积分赠送退款 14:积分赠送退款撤销
                                    , db.Parameter("@DepositMode", 0, DbType.Int32)//1:充值、2:余额转入
                                    , db.Parameter("@Remark", model.Remark, DbType.String)
                                    , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)
                                    , db.Parameter("@Amount", PaymentAmountMid, DbType.Decimal)
                                    , db.Parameter("@Balance", balance, DbType.Decimal)
                                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                            if (addres <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                            #endregion
                        }
                        else if (item.CardType == 3)
                        {
                            #region 现金券
                            string strAddCouponBalance = @" INSERT INTO [TBL_COUPON_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CouponType ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CouponType ,@CreatorID ,@CreateTime)";

                            int addres = db.SetCommand(strAddCouponBalance,
                                    db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                    db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                    db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                                    db.Parameter("@CustomerBalanceID", customerBalanceID, DbType.Int32),
                                    db.Parameter("@ActionMode", 11, DbType.Int32),// 1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                    db.Parameter("@DepositMode", 0, DbType.Int32),//1:充值、2:余额转入
                                    db.Parameter("@Remark", model.Remark, DbType.String),
                                    db.Parameter("@UserCardNo", item.UserCardNo, DbType.String),
                                    db.Parameter("@Amount", PaymentAmountMid, DbType.Decimal),
                                    db.Parameter("@Balance", balance, DbType.Decimal),
                                    db.Parameter("@CouponType", 0, DbType.Int32),
                                    db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                    db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                            if (addres <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            #endregion
                        }

                        #region 修改CustomerCard中的Balance
                        string strAddHis = @" INSERT INTO [HST_CUSTOMER_CARD] SELECT * FROM [TBL_CUSTOMER_CARD] WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo ";
                        int hisRows = db.SetCommand(strAddHis, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                             , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                             , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteNonQuery();

                        if (hisRows == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        string strUpdateCustomerCard = @" UPDATE [TBL_CUSTOMER_CARD] SET Balance=@Balance WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo";
                        int updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", balance, DbType.Decimal)
                                                             , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                             , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                             , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteNonQuery();

                        if (updateRes == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        #endregion
                    }
                }
                #endregion

                #region 插入PaymentDetail表
                decimal totalMyCalAmount = 0;
                decimal totallMyCalAmountMid = 0;
                foreach (PaymentDetail_Model item in model.PaymentDetailList)
                {
                    if (Math.Abs(item.PaymentAmount) > 0)//排除传过来为0的记录
                    {
                        totallMyCalAmountMid += Math.Abs(item.PaymentAmount);
                        //item.PaymentAmount = Math.Round(Math.Abs(item.PaymentAmount) * refundRate, 2);
                        decimal paymentAmount = item.PaymentAmount;
                        decimal rate = 1;
                        decimal ProfitRate = 1;

                        #region 查询积分/现金券的抵扣额度
                        string selRateSql = @" SELECT  ISNULL(T2.Rate, 1) AS Rate,ISNULL(T2.ProfitRate, 1) AS ProfitRate
                                                            FROM    [TBL_CUSTOMER_CARD] T1 WITH ( NOLOCK )
                                                                    LEFT JOIN [MST_CARD] T2 ON T1.CardID = T2.ID
                                                            WHERE   T1.CompanyID = @CompanyID
                                                                    AND T1.UserCardNo = @UserCardNo ";
                        DataTable table = db.SetCommand(selRateSql
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteDataTable();

                        if (table == null || table.Rows.Count < 1)
                        {
                            ProfitRate = 1;
                        }
                        else
                        {
                            ProfitRate = StringUtils.GetDbDecimal(table.Rows[0]["ProfitRate"], 1);
                        }
                        #endregion

                        if (item.CardType == 2 || item.CardType == 3)
                        {
                            rate = StringUtils.GetDbDecimal(table.Rows[0]["Rate"], 1);
                            paymentAmount = Math.Round(item.PaymentAmount * rate, 2, MidpointRounding.AwayFromZero);
                        }

                        string strSqlDetailAdd = @"insert into PAYMENT_DETAIL(CompanyID,PaymentID,PaymentMode,PaymentAmount,CreatorID,CreateTime,UserCardNo,CardPaidAmount ,ProfitRate) 
                                                       values (@CompanyID,@PaymentID,@PaymentMode,@PaymentAmount,@CreatorID,@CreateTime,@UserCardNo,@CardPaidAmount ,@ProfitRate);select @@IDENTITY";

                        int paymentDetailID = db.SetCommand(strSqlDetailAdd
                                         , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                         , db.Parameter("@PaymentID", paymentID, DbType.Int32)
                                         , db.Parameter("@PaymentMode", item.PaymentMode, DbType.Int32)
                                         , db.Parameter("@PaymentAmount", paymentAmount, DbType.Decimal)
                                         , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                         , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)
                                         , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)
                                         , db.Parameter("@CardPaidAmount", item.PaymentAmount, DbType.Decimal)
                                         , db.Parameter("@ProfitRate", ProfitRate, DbType.Decimal)).ExecuteScalar<int>();

                        if (paymentDetailID <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        object CommFlag = DBNull.Value;//1：首充 2：指定 3：E账户
                        if (item.PaymentMode == 1 || item.PaymentMode == 6 || item.PaymentMode == 7)
                        {
                            CommFlag = 3;
                        }

                        totalMyCalAmount += paymentAmount;
                        string strSelCompanyComissionCalcSql = " SELECT [ComissionCalc] FROM COMPANY WHERE ID=@CompanyID ";
                        bool isComissionCalc = db.SetCommand(strSelCompanyComissionCalcSql
                                             , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<bool>();

                        if (isComissionCalc)
                        {
                            #region 计算销售业绩

                            #region 取出Product基本数据
                            string strSelProductSql = @" SELECT CASE T1.ProductType
                                                                          WHEN 0 THEN T2.ServiceCode
                                                                          ELSE T3.CommodityCode
                                                                        END AS ProductCode ,
                                                                        T1.ProductType ,T1.TotalSalePrice 
                                                                 FROM   [ORDER] T1 WITH ( NOLOCK )
                                                                        LEFT JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.ID = T2.OrderID
                                                                        LEFT JOIN [TBL_ORDER_COMMODITY] T3 WITH ( NOLOCK ) ON T1.ID = T3.OrderID
                                                                 WHERE  T1.CompanyID = @CompanyID
                                                                        AND T1.ID = @OrderID; ";
                            DataTable dt = db.SetCommand(strSelProductSql
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@OrderID", model.OrderID, DbType.Int32)).ExecuteDataTable();

                            if (dt == null || dt.Rows.Count < 1)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            int productType = StringUtils.GetDbInt(dt.Rows[0]["ProductType"]);
                            long productCode = StringUtils.GetDbLong(dt.Rows[0]["ProductCode"]);
                            decimal totalSalePrice = StringUtils.GetDbDecimal(dt.Rows[0]["TotalSalePrice"]);
                            #endregion

                            #region 取出TBL_PRODUCT_COMMISSION_RULE数据
                            string strSelProductCommissionRuleSql = @" SELECT ProductType ,
                                                                                        ProductCode ,
                                                                                        ProfitPct ,
                                                                                        ECardSACommType ,
                                                                                        ECardSACommValue ,
                                                                                        NECardSACommType ,
                                                                                        NECardSACommValue
                                                                                 FROM   TBL_PRODUCT_COMMISSION_RULE
                                                                                 WHERE  CompanyID = @CompanyID
                                                                                        AND ProductType = @ProductType
                                                                                        AND ProductCode = @ProductCode ";

                            Product_Commission_Rule_Model ProductRuleModel = db.SetCommand(strSelProductCommissionRuleSql
                                                               , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                               , db.Parameter("@ProductType", productType, DbType.Int32)
                                                               , db.Parameter("@ProductCode", productCode, DbType.Int64)).ExecuteObject<Product_Commission_Rule_Model>();
                            #endregion

                            if (ProductRuleModel != null && ProductRuleModel.ProductCode > 0)
                            {
                                int CommType = 0;
                                decimal CommValue = 0;
                                if (CommFlag != DBNull.Value)
                                {
                                    #region E账户
                                    CommType = ProductRuleModel.ECardSACommType;
                                    CommValue = ProductRuleModel.ECardSACommValue;
                                    #endregion
                                }
                                else
                                {
                                    #region 非E账户
                                    CommType = ProductRuleModel.NECardSACommType;
                                    CommValue = ProductRuleModel.NECardSACommValue;
                                    #endregion
                                }

                                //decimal Income = (Math.Abs(paymentAmount) * ProfitRate) * -1;
                                decimal Income = Math.Abs(paymentAmount) * -1 * (paymentBranchRole.IsUseRate != 1 ? 1 : ProfitRate);
                                decimal Profit = Income * ProductRuleModel.ProfitPct;

                                string strAddProfitDetailSql = @" INSERT INTO TBL_PROFIT_COMMISSION_DETAIL ( CompanyID ,BranchID ,SourceType ,SourceID ,SubSourceID ,Income ,ProfitPct ,Profit ,CommType ,CommValue ,AccountID ,AccountProfitPct ,AccountProfit ,AccountComm ,CommFlag , BranchProfitRate,CreatorID ,CreateTime ) 
                                                                    VALUES ( @CompanyID ,@BranchID ,@SourceType ,@SourceID ,@SubSourceID ,@Income ,@ProfitPct ,@Profit ,@CommType ,@CommValue ,@AccountID ,@AccountProfitPct ,@AccountProfit ,@AccountComm ,@CommFlag , @BranchProfitRate, @CreatorID ,@CreateTime ) ";

                                //if (ProfitList.Count > 0)
                                if (paymentID >= 0 && model.Slavers != null && model.Slavers.Count > 0)
                                {
                                    #region 有业绩分享人
                                    //foreach (Slave_Model slaveItem in ProfitList)
                                    foreach (Slave_Model slaveItem in model.Slavers)
                                    {
                                        decimal EveryProfitPct = 0;
                                        //业绩均分flag
                                        if (model.AverageFlag == 1)
                                        {
                                            EveryProfitPct = Math.Round((decimal)1 / model.Slavers.Count, 2);
                                        }
                                        else
                                        {
                                            EveryProfitPct = slaveItem.ProfitPct;
                                        }

                                        #region 有业绩分享人
                                        //员工业绩(=实际业绩 x 员工业绩计算比例)
                                        decimal AccountProfit = Profit * EveryProfitPct;

                                        //1:按比例 2:固定值
                                        decimal AccountComm = Math.Round(CommValue * (paymentAmount / totalSalePrice) * EveryProfitPct * (-1), 2, MidpointRounding.AwayFromZero);
                                        if (CommType == 1)
                                        {
                                            AccountComm = AccountProfit * CommValue;
                                        }

                                        int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                            , db.Parameter("@SourceType", 1, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                            , db.Parameter("@SourceID", paymentDetailID, DbType.Int64)
                                            , db.Parameter("@SubSourceID", model.OrderID, DbType.Int64)
                                            , db.Parameter("@Income", Income, DbType.Decimal)//收入 充值时，为TBL_MONEY_BALANCE的Amount
                                            , db.Parameter("@ProfitPct", ProductRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                            , db.Parameter("@Profit", Profit, DbType.Decimal)//实际业绩
                                            , db.Parameter("@CommType", CommType, DbType.Int32)//该业绩的提成方式
                                            , db.Parameter("@CommValue", CommValue, DbType.Decimal)//该业绩的提成数值
                                            , db.Parameter("@AccountID", slaveItem.SlaveID, DbType.Int32)//获得该业绩的员工ID
                                            , db.Parameter("@AccountProfitPct", EveryProfitPct, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                            , db.Parameter("@AccountProfit", AccountProfit, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                            , db.Parameter("@AccountComm", AccountComm, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
                                            , db.Parameter("@CommFlag", CommFlag, DbType.Int32)//1：首充 2：指定 3：E账户
                                            , db.Parameter("@BranchProfitRate", BranchProfitRate, DbType.Decimal)//业绩比例
                                            , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                            , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                                        if (addProfitDetailRes != 1)
                                        {
                                            db.RollbackTransaction();
                                            return 0;
                                        }
                                        #endregion
                                    }
                                    #endregion
                                }
                                else
                                {
                                    #region 没有业绩分享人
                                    int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                            , db.Parameter("@SourceType", 1, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                            , db.Parameter("@SourceID", paymentDetailID, DbType.Int64)
                                            , db.Parameter("@SubSourceID", model.OrderID, DbType.Int64)
                                            , db.Parameter("@Income", Income, DbType.Decimal)//收入 充值时，为TBL_MONEY_BALANCE的Amount
                                            , db.Parameter("@ProfitPct", ProductRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                            , db.Parameter("@Profit", Profit, DbType.Decimal)//实际业绩
                                            , db.Parameter("@CommType", CommType, DbType.Int32)//该业绩的提成方式
                                            , db.Parameter("@CommValue", CommValue, DbType.Decimal)//该业绩的提成数值
                                            , db.Parameter("@AccountID", DBNull.Value, DbType.Int32)//获得该业绩的员工ID
                                            , db.Parameter("@AccountProfitPct", DBNull.Value, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                            , db.Parameter("@AccountProfit", DBNull.Value, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                            , db.Parameter("@AccountComm", DBNull.Value, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
                                            , db.Parameter("@CommFlag", CommFlag, DbType.Int32)//1：首充 2：指定 3：E账户
                                            , db.Parameter("@BranchProfitRate", BranchProfitRate, DbType.Decimal)//业绩比例
                                            , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                            , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                                    if (addProfitDetailRes != 1)
                                    {
                                        db.RollbackTransaction();
                                        return 0;
                                    }
                                    #endregion
                                }
                            }

                            #endregion
                        }
                    }
                }
                #endregion

                if (Math.Round(totallMyCalAmountMid, 2, MidpointRounding.AwayFromZero) != model.TotalPrice)
                {
                    db.RollbackTransaction();
                    return 7;
                }

                #region 抽取专属顾问数据
                string strSelOrderInfoSql = @" SELECT  T1.AccountID
                                                            FROM    RELATIONSHIP T1 WITH ( NOLOCK )
                                                            WHERE   CustomerID = @CustomerID
                                                                    AND T1.Type = 1 
                                                                    AND T1.Available = 1
                                                                    AND T1.BranchID = @BranchID";

                int ResponsiblePersonID = db.SetCommand(strSelOrderInfoSql
                    , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteScalar<int>();
                #endregion

                #region 插入OrderPayment关系表
                string strSqlOrderPayAdd = @"insert into TBL_OrderPayment_RelationShip(OrderID,PaymentID) 
                                                                values (@OrderID,@PaymentID);select @@IDENTITY";
                int orderPaymentRes = db.SetCommand(strSqlOrderPayAdd
                                      , db.Parameter("@OrderID", model.OrderID, DbType.Int32)
                                      , db.Parameter("@PaymentID", paymentID, DbType.Int32)).ExecuteNonQuery();
                //db.Parameter("@ResponsiblePersonID", responsiblePersonID, DbType.Int32)


                if (orderPaymentRes <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                #region 更新订单状态和PaymentID
                string strSqlOrderUpt = @"update [ORDER] set RefundSumAmount = RefundSumAmount + @RefundSumAmount, PaymentStatus=@PaymentStatus,UpdaterID = @UpdaterID, UpdateTime = @UpdateTime where ID =@OrderID";

                int orderuptRes = db.SetCommand(strSqlOrderUpt,
                    //db.Parameter("@RefundSumAmount", Math.Round(model.TotalPrice * refundRate, 2), DbType.Decimal),
                    db.Parameter("@RefundSumAmount", model.TotalPrice, DbType.Decimal),
                    db.Parameter("@PaymentStatus", 4, DbType.Int32),// 1:未支付 2:部分支付 3:完全支付 4:退款
                    db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32),
                    db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime),
                    db.Parameter("@OrderID", model.OrderID, DbType.Int32)).ExecuteNonQuery();

                if (orderuptRes <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                #endregion

                #region 赠送
                if (model.GiveDetailList != null && model.GiveDetailList.Count > 0)
                {
                    #region 插入CUSTOMER_BALANCE
                    if (customerBalanceID <= 0)
                    {
                        string strAddCustomerBalance = @" INSERT [TBL_CUSTOMER_BALANCE]	( CompanyID ,BranchID ,UserID ,ChangeType ,TargetAccount ,PaymentID ,Remark ,CreatorID ,CreateTime) 
                                VALUES(@CompanyID ,@BranchID ,@UserID ,@ChangeType ,@TargetAccount  ,@PaymentID ,@Remark ,@CreatorID ,@CreateTime);select @@IDENTITY";
                        customerBalanceID = db.SetCommand(strAddCustomerBalance,
                                    db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                    db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                    db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                                    db.Parameter("@ChangeType", 7, DbType.Int32),//1:账户消费、2:账户消费撤销、3：账户充值、4：账户充值撤销、5：账户直扣、6：账户直扣撤销 7:账户消费退款
                                    db.Parameter("@TargetAccount", 0, DbType.Int32),//目标账户：1:储值卡、2:积分、3:现金券  账户消费和消费撤销时，设默认值0
                                                                                    //db.Parameter("@ResponsiblePersonID", model.CreatorID, DbType.Int32),
                                    db.Parameter("@PaymentID", paymentID, DbType.Int32),
                                    db.Parameter("@Remark", model.Remark, DbType.String),
                                    db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                    db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteScalar<int>();

                        if (customerBalanceID <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                    }
                    #endregion

                    foreach (PaymentDetail_Model item in model.GiveDetailList)
                    {
                        if (item.PaymentAmount != 0)
                        {
                            string strSqlGetBalance = @"SELECT  T1.Balance  
                                                            FROM    [TBL_CUSTOMER_CARD] T1 WITH ( NOLOCK )
                                                            WHERE   T1.CompanyID = @CompanyID
                                                                    AND T1.UserID = @CustomerID
                                                                    AND T1.UserCardNo = @UserCardNo";
                            decimal balance = db.SetCommand(strSqlGetBalance
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteScalar<decimal>();

                            //item.PaymentAmount = Math.Round(Math.Abs(item.PaymentAmount) * refundRate * -1, 2);
                            item.PaymentAmount = item.PaymentAmount * -1;
                            balance = balance + item.PaymentAmount;

                            #region 消费赠送
                            if (item.CardType == 2 && item.PaymentAmount < 0)
                            {
                                #region 积分卡
                                string strAddPointBalance = @" INSERT INTO [TBL_POINT_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CreatorID ,@CreateTime)";

                                int addres = db.SetCommand(strAddPointBalance
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                        , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                        , db.Parameter("@CustomerBalanceID", customerBalanceID, DbType.Int32)
                                        , db.Parameter("@ActionMode", 13, DbType.Int32)//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                        , db.Parameter("@DepositMode", 0, DbType.Int32)//1:充值、2:余额转入
                                        , db.Parameter("@Remark", model.Remark, DbType.String)
                                        , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)
                                        , db.Parameter("@Amount", item.PaymentAmount, DbType.Decimal)
                                        , db.Parameter("@Balance", balance, DbType.Decimal)
                                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                                if (addres <= 0)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }
                                #endregion
                            }
                            else if (item.CardType == 3 && item.PaymentAmount < 0)
                            {
                                #region 现金券
                                string strAddCouponBalance = @" INSERT INTO [TBL_COUPON_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CouponType ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CouponType ,@CreatorID ,@CreateTime)";

                                int addres = db.SetCommand(strAddCouponBalance,
                                        db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                        db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                        db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                                        db.Parameter("@CustomerBalanceID", customerBalanceID, DbType.Int32),
                                        db.Parameter("@ActionMode", 13, DbType.Int32),// 1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                        db.Parameter("@DepositMode", 0, DbType.Int32),//1:充值、2:余额转入
                                        db.Parameter("@Remark", model.Remark, DbType.String),
                                        db.Parameter("@UserCardNo", item.UserCardNo, DbType.String),
                                        db.Parameter("@Amount", item.PaymentAmount, DbType.Decimal),
                                        db.Parameter("@Balance", balance, DbType.Decimal),
                                        db.Parameter("@CouponType", 0, DbType.Int32),
                                        db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                        db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                                if (addres <= 0)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }

                                #endregion
                            }

                            #region 修改CustomerCard中的Balance
                            string strUpdateCustomerCard = @" UPDATE [TBL_CUSTOMER_CARD] SET Balance=@Balance ,UpdaterID = @UpdaterID , UpdateTime = @UpdateTime WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo";
                            int updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", balance, DbType.Decimal)
                                                                 , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                 , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                                 , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)
                                                                 , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                                                                 , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                            if (updateRes == 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                            #endregion
                            #endregion
                        }
                    }
                }
                #endregion

                #region 美丽顾问/销售顾问
                string strAddConsultant = @" INSERT INTO [TBL_BUSINESS_CONSULTANT]( CompanyID ,BusinessType ,MasterID ,ConsultantType ,ConsultantID ,CreatorID ,CreateTime )
                                                    VALUES ( @CompanyID ,@BusinessType ,@MasterID ,@ConsultantType ,@ConsultantID ,@CreatorID ,@CreateTime )";

                #region 美丽顾问
                if (ResponsiblePersonID > 0)
                {


                    int addConsultantRes = db.SetCommand(strAddConsultant
                           , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                           , db.Parameter("@BusinessType", 2, DbType.Int32)//1：订单，2：支付，3：充值
                           , db.Parameter("@MasterID", paymentID, DbType.Int32)
                           , db.Parameter("@ConsultantType", 1, DbType.Int32)//1:美丽顾问 2:销售顾问
                           , db.Parameter("@ConsultantID", ResponsiblePersonID, DbType.Int32)
                           , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                           , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                    if (addConsultantRes <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                }
                #endregion

                string advanced = WebAPI.DAL.Company_DAL.Instance.getAdvancedByCompanyID(model.CompanyID);
                if (advanced.Contains("|4|"))
                {
                    #region 销售顾问
                    string strSelSalesSql = @"SELECT  AccountID
                                            FROM    [RELATIONSHIP]
                                            WHERE   companyID = @CompanyID
                                                    AND BranchID = @BranchID
                                                    AND CustomerID = @CustomerID
                                                    AND Available = 1
                                                    AND Type = 2";

                    List<int> SalesPersonIDList = db.SetCommand(strSelSalesSql,
                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                            db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                            db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteScalarList<int>();

                    if (SalesPersonIDList != null || SalesPersonIDList.Count > 0)
                    {
                        foreach (int SalesPersonID in SalesPersonIDList)
                        {
                            int addConsultantRes = db.SetCommand(strAddConsultant
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@BusinessType", 2, DbType.Int32)//1：订单，2：支付，3：充值
                            , db.Parameter("@MasterID", paymentID, DbType.Int32)
                            , db.Parameter("@ConsultantType", 2, DbType.Int32)//1:美丽顾问 2:销售顾问
                            , db.Parameter("@ConsultantID", SalesPersonID, DbType.Int32)
                            , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                            , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                            if (addConsultantRes <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                        }
                    }
                    #endregion
                }
                #endregion


                db.CommitTransaction();
                return 1;
            }
        }

        public List<Profit_Model> getProfitListByMasterID(int masterID, int type)
        {
            List<Profit_Model> list = new List<Profit_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT  T2.Name AS AccountName,T2.UserID As AccountID, ProfitPct  
                                    FROM    TBL_PROFIT T1 WITH ( NOLOCK )
                                            LEFT JOIN ACCOUNT T2 WITH ( NOLOCK ) ON T1.SlaveID = T2.UserID
                                    WHERE   T1.Type = @Type
                                            AND T1.MasterID = @MasterID ";

                list = db.SetCommand(strSql, db.Parameter("@Type", type, DbType.Int32)
                                           , db.Parameter("@MasterID", masterID, DbType.Int32)).ExecuteList<Profit_Model>();

                return list;
            }
        }
        //查询销售顾问提成详情 订单支付
        public List<SalesConsultantRate_model> getSalesConsultantRateListByOrderID(string OrderID)
        {
            List<SalesConsultantRate_model> list = new List<SalesConsultantRate_model>();
            using (DbManager db = new DbManager())
            {
                String salesConsultantRateSql = @" SELECT SalesConsultantID,SalesConsultantName,CommissionRate FROM getCommissionRate (@OrderID) ";
                list = db.SetCommand(salesConsultantRateSql, db.Parameter("@OrderID", OrderID, DbType.Int32)).ExecuteList<SalesConsultantRate_model>();
                return list;
            }
        }
        //查询销售顾问提成详情 支付详情
        public List<SalesConsultantRate_model> getSalesConsultantRateListByPaymentID(string paymentID)
        {
            List<SalesConsultantRate_model> list = new List<SalesConsultantRate_model>();
            using (DbManager db = new DbManager())
            {
                String salesConsultantRateSql = @" SELECT SalesConsultantID,SalesConsultantName,CommissionRate FROM getCommissionRatebyPaymentID (@paymentID) ";
                list = db.SetCommand(salesConsultantRateSql, db.Parameter("@paymentID", paymentID, DbType.Int32)).ExecuteList<SalesConsultantRate_model>();
                return list;
            }
        }
        public List<PaymentDetailByOrderID_Model> GetPaymentListByOrderID(int companyID, int orderID, int paymentID)
        {
            List<PaymentDetailByOrderID_Model> list = new List<PaymentDetailByOrderID_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  T2.PaymentTime ,
                                            ISNULL(T3.Name, T4.Name) AS Operator ,
                                            T2.TotalPrice ,
                                            T2.Remark ,
                                            T2.ID AS PaymentID ,
                                            T2.OrderNumber ,
                                            T2.Type ,
                                            T2.CreateTime ,
                                            T2.Remark ,
                                            T5.BranchName ,
                                            CASE T2.Type WHEN 1 THEN '消费' ELSE '消费退款' END AS TypeName 
                                    FROM    [TBL_OrderPayment_RelationShip] T1 WITH ( NOLOCK )
                                            LEFT JOIN [PAYMENT] T2 WITH ( NOLOCK ) ON T2.ID = T1.PaymentID
                                            LEFT JOIN [ACCOUNT] T3 WITH ( NOLOCK ) ON T2.CreatorID = T3.UserID
                                            LEFT JOIN [CUSTOMER] T4 WITH ( NOLOCK ) ON T2.CreatorID = T4.UserID
                                            LEFT JOIN [BRANCH] T5 WITH ( NOLOCK ) ON T5.ID=T2.BranchID  
                                    WHERE   T2.CompanyID = @CompanyID
                                            AND ((( T2.Status = 2 OR T2.Status = 4 ) AND T2.Type = 1) OR (T2.Type = 2 AND T2.Status = 7))";
                if (paymentID > 0)
                {
                    strSql += " AND T2.ID = @PaymentID ";
                }

                if (orderID > 0)
                {
                    strSql += " AND T1.OrderID = @OrderID ";
                }

                strSql += " ORDER BY T2.CreateTime DESC ";

                list = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@OrderID", orderID, DbType.Int32)
                    , db.Parameter("@PaymentID", paymentID, DbType.Int32)).ExecuteList<PaymentDetailByOrderID_Model>();

                return list;
            }
        }

        public List<PaymentDetailList_Model> GetPayDetailListByPaymentID(int companyID, int paymentID)
        {
            List<PaymentDetailList_Model> list = new List<PaymentDetailList_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  T1.PaymentMode ,
                                            T1.PaymentAmount ,
                                            T1.CardPaidAmount ,
                                            T3.CardTypeID AS CardType ,
                                            T1.ID AS PaymentDetailID ,
                                            T2.UserCardNo,
                                            CASE T1.PaymentMode
                                              WHEN 0 THEN '现金'
                                              WHEN 2 THEN '银行卡'
                                              WHEN 3 THEN '其他'
                                              WHEN 4 THEN '免支付'
                                              WHEN 5 THEN '过去支付' 
                                              WHEN 8 THEN '微信' 
                                              WHEN 9 THEN '支付宝' 
                                              WHEN 100 THEN '消费贷款' 
                                              WHEN 101 THEN '第三方收款' 
                                              ELSE T3.CardName
                                            END AS CardName
                                    FROM    [PAYMENT_DETAIL] T1 WITH ( NOLOCK )
                                            LEFT JOIN [TBL_CUSTOMER_CARD] T2 WITH ( NOLOCK ) ON T2.UserCardNo = T1.UserCardNo
                                            LEFT JOIN [MST_CARD] T3 WITH ( NOLOCK ) ON T2.CardID = T3.ID
                                    WHERE   T1.CompanyID = @CompanyID
                                            AND T1.PaymentID = @PaymentID
                                    ORDER BY T3.CardTypeID";

                list = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@PaymentID", paymentID, DbType.Int32)).ExecuteList<PaymentDetailList_Model>();

                return list;
            }
        }

        public List<PaymentOrderList_Model> getOrderListByPaymentID(int companyID, int paymentID)
        {
            List<PaymentOrderList_Model> list = new List<PaymentOrderList_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  T2.ID AS OrderID ,
                                        T2.ProductType ,
                                        T2.TotalSalePrice ,
                                        T2.OrderTime ,
                                        CASE T2.ProductType WHEN 0 THEN T3.ServiceName ELSE T4.CommodityName END AS ProductName,
                                        CASE T2.ProductType WHEN 0 THEN T3.ID ELSE T4.ID END AS OrderObjectID
                                FROM    [TBL_ORDERPAYMENT_RELATIONSHIP] T1 WITH ( NOLOCK )
                                        LEFT JOIN [Order] T2 WITH ( NOLOCK ) ON T1.OrderID = T2.ID
                                        LEFT JOIN [TBL_ORDER_SERVICE] T3 WITH ( NOLOCK ) ON T2.ID = T3.OrderID
                                        LEFT JOIN [TBL_ORDER_COMMODITY] T4 WITH ( NOLOCK ) ON T2.ID = T4.OrderID
                                WHERE   T1.PaymentID = @PaymentID AND T2.CompanyID=@CompanyID";

                list = db.SetCommand(strSql
                        , db.Parameter("@CompanyID", companyID, DbType.Int32)
                        , db.Parameter("@PaymentID", paymentID, DbType.Int32)).ExecuteList<PaymentOrderList_Model>();

                return list;
            }
        }


        public List<UnPaidList_Model> getUnPaidList(int companyID, int branchID)
        {
            List<UnPaidList_Model> list = new List<UnPaidList_Model>();

            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  T1.CustomerID ,
                                            CONVERT(VARCHAR(16), MAX(T1.OrderTime), 120) LastTime ,
                                            T2.Name AS CustomerName ,
                                            '*******' + SUBSTRING(T3.LoginMobile, LEN(T3.LoginMobile) - 3, 4) LoginMobileShow ,
                                            T3.LoginMobile AS LoginMobileSearch ,
                                            COUNT(T1.ID) OrderCount
                                    FROM    [ORDER] T1 WITH ( NOLOCK )
                                            LEFT JOIN [CUSTOMER] T2 WITH ( NOLOCK ) ON T1.CustomerID = T2.UserID
                                            LEFT JOIN [USER] T3 WITH ( NOLOCK ) ON T1.CustomerID = T3.ID
                                            LEFT JOIN [BRANCH] T4 ON T1.BranchID = T4.ID
                                    WHERE   ( T1.PaymentStatus = 2
                                              OR T1.PaymentStatus = 1
                                            )
                                            AND T1.CompanyID=@CompanyID
                                            AND T1.BranchID = @BranchID
                                            AND T1.UnPaidPrice > 0
                                            AND T1.OrderTime > T4.StartTime 
                                            AND T1.Status <> 3 AND T1.Status <> 4 
                                            AND T1.RecordType = 1
                                    GROUP BY T1.CustomerID ,
                                            T2.Name ,
                                            T3.LoginMobile
                                    ORDER BY T2.Name ASC  ";
                list = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteList<UnPaidList_Model>();


                return list;
            }
        }

        public List<UnPaidListByCustomerID_Model> getUnPaidListByCustomerID(int companyID, int branchID, int customerID)
        {
            List<UnPaidListByCustomerID_Model> list = new List<UnPaidListByCustomerID_Model>();

            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  T1.ID AS OrderID ,
                                            T1.ProductType ,
                                            T1.TotalSalePrice ,
                                            T1.UnPaidPrice ,
                                            T1.PaymentStatus ,
                                            T1.OrderTime ,
                                            T4.Name AS ResponsiblePersonName ,
                                            CASE T1.ProductType WHEN 0 THEN T2.ServiceName ELSE T3.CommodityName END AS ProductName ,
                                            CASE T1.ProductType WHEN 0 THEN T2.Quantity ELSE T3.Quantity END AS Quantity,
                                            CASE T1.ProductType WHEN 0 THEN T2.ID ELSE T3.ID END AS OrderObjectID
                                    FROM    [ORDER] T1 WITH ( NOLOCK )
                                            LEFT JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.ID = T2.OrderID
                                            LEFT JOIN [TBL_ORDER_COMMODITY] T3 WITH ( NOLOCK ) ON T1.ID = T3.OrderID
                                            LEFT JOIN [TBL_BUSINESS_CONSULTANT] T6 WITH ( NOLOCK ) ON T6.MasterID = T1.ID AND T6.BusinessType = 1 AND T6.ConsultantType = 1
                                            LEFT JOIN [ACCOUNT] T4 WITH ( NOLOCK ) ON T6.ConsultantID = T4.UserID 
                                            LEFT JOIN [BRANCH] T5 WITH(NOLOCK) ON T1.BranchID=T5.ID 
                                   WHERE   T1.CompanyID = @CompanyID 
                                           AND T1.CustomerID = @CustomerID
                                           AND ( T1.PaymentStatus = 1 OR PaymentStatus = 2 )
                                           AND T1.UnPaidPrice > 0
                                           AND T1.RecordType = 1 
                                           AND T1.Status <> 3 AND T1.Status <> 4
                                           AND T1.OrderTime > T5.StartTime";
                if (branchID > 0)
                {
                    strSql += " AND T1.BranchID = @BranchID ";
                }

                strSql += " ORDER BY T1.OrderTime ";
                list = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@BranchID", branchID, DbType.Int32)
                    , db.Parameter("@CustomerID", customerID, DbType.Int32)).ExecuteList<UnPaidListByCustomerID_Model>();

                return list;
            }
        }

        public List<UnPaidListTG_Model> getUnPaidTGList(int companyID, int orderObjectID, int productType)
        {
            List<UnPaidListTG_Model> list = new List<UnPaidListTG_Model>();
            string strSql = "";
            using (DbManager db = new DbManager())
            {
                if (productType == 0)
                {
                    strSql = @"SELECT  T2.Name AS ServicePICName ,
                                        T1.TGStatus AS [Status] ,
                                        T1.TGStartTime AS StartTime
                                FROM    [TBL_TREATGROUP] T1 WITH ( NOLOCK )
                                        LEFT JOIN [ACCOUNT] T2 WITH ( NOLOCK ) ON T1.ServicePIC = T2.UserID
                                WHERE   T1.CompanyID = @CompanyID
                                        AND T1.OrderServiceID = @OrderObjectID 
                                        AND T1.TGStatus <> 3 AND T1.TGStatus <> 5 
                                        AND T1.TGStartTime >= CAST(CONVERT(CHAR(10), GETDATE(), 102) + ' 00:00:00' AS VARCHAR(20))
                                        AND T1.TGStartTime <= CAST(CONVERT(CHAR(10), GETDATE(), 102) + ' 23:59:59' AS VARCHAR(20)) ";
                }
                else
                {
                    strSql = @"SELECT  T2.Name AS ServicePICName ,
                                        T1.Status AS [Status] ,
                                        T1.CreateTime AS StartTime
                                FROM    [TBL_COMMODITY_DELIVERY] T1 WITH ( NOLOCK )
                                        LEFT JOIN [ACCOUNT] T2 WITH ( NOLOCK ) ON T1.ServicePIC = T2.UserID
                                WHERE   T1.CompanyID = @CompanyID 
                                        AND T1.OrderObjectID = @OrderObjectID 
                                        AND T1.Status <> 3 AND T1.Status <> 5 
                                        AND T1.CreateTime >= CAST(CONVERT(CHAR(10), GETDATE(), 102) + ' 00:00:00' AS VARCHAR(20))
                                        AND T1.CreateTime <= CAST(CONVERT(CHAR(10), GETDATE(), 102) + ' 23:59:59' AS VARCHAR(20)) ";
                }

                list = db.SetCommand(strSql
                       , db.Parameter("@CompanyID", companyID, DbType.Int32)
                       , db.Parameter("@OrderObjectID", orderObjectID, DbType.Int32)).ExecuteList<UnPaidListTG_Model>();

                return list;
            }
        }

        public string GetNetTradeQRCode(GetNetTradeQRCodeOperation_Model model, string strOrderIDs, string strSlaveIDs, string productName)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string netTradeNo = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "NetTradeNo", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<string>();

                string strAddControlSql = @" INSERT INTO TBL_NETTRADE_CONTROL( CompanyID ,BranchID ,CustomerID ,NetTradeNo ,NetActionType ,ChangeType ,NetTradeVendor ,NetTradeActionMode ,ProductName ,NetTradeAmount ,SubmitTime ,RelatedNetTradeNo ,PointAmount ,CouponAmount ,MoneyAmount ,UserCardNo ,Participants ,Remark ,CreatorID ,CreateTime ) 
                                            VALUES ( @CompanyID ,@BranchID ,@CustomerID ,@NetTradeNo ,@NetActionType ,@ChangeType ,@NetTradeVendor ,@NetTradeActionMode ,@ProductName ,@NetTradeAmount ,@SubmitTime ,@RelatedNetTradeNo ,@PointAmount ,@CouponAmount ,@MoneyAmount ,@UserCardNo ,@Participants ,@Remark ,@CreatorID ,@CreateTime ) ";

                int addControlRes = db.SetCommand(strAddControlSql
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                    , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                    , db.Parameter("@NetTradeNo", netTradeNo, DbType.String)
                    , db.Parameter("@NetActionType", model.NetActionType, DbType.Int32)
                    , db.Parameter("@ChangeType", model.ChangeType, DbType.Int32)
                    , db.Parameter("@NetTradeVendor", model.NetTradeVendor, DbType.Int32)
                    , db.Parameter("@NetTradeActionMode", model.NetTradeActionMode, DbType.String)
                    , db.Parameter("@ProductName", productName, DbType.String)
                    , db.Parameter("@NetTradeAmount", model.TotalAmount, DbType.Decimal)
                    , db.Parameter("@SubmitTime", model.Time, DbType.DateTime2)
                    , db.Parameter("@RelatedNetTradeNo", DBNull.Value, DbType.String)
                    , db.Parameter("@PointAmount", model.PointAmount, DbType.Decimal)
                    , db.Parameter("@CouponAmount", model.CouponAmount, DbType.Decimal)
                    , db.Parameter("@MoneyAmount", model.MoneyAmount, DbType.Decimal)
                    , db.Parameter("@UserCardNo", model.UserCardNo, DbType.String)
                    // , db.Parameter("@ResponsiblePersonID", model.ResponsiblePersonID, DbType.Int32)
                    , db.Parameter("@Participants", strSlaveIDs, DbType.String)
                    , db.Parameter("@Remark", model.Remark, DbType.String)
                    , db.Parameter("@CreatorID", model.AccountID, DbType.Int32)
                    , db.Parameter("@CreateTime", model.Time, DbType.DateTime2)).ExecuteNonQuery();

                if (addControlRes <= 0)
                {
                    db.RollbackTransaction();
                    return "";
                }

                // 只有在支付的时候才记录这张表
                if (string.IsNullOrWhiteSpace(model.UserCardNo) && !string.IsNullOrWhiteSpace(strOrderIDs))
                {
                    string strAddNetTradeOrderSql = @" INSERT INTO TBL_NETTRADE_ORDER( CompanyID ,NetTradeNo ,OrderID ,CreatorID ,CreateTime ) 
                                                    VALUES ( @CompanyID ,@NetTradeNo ,@OrderID ,@CreatorID ,@CreateTime ) ";

                    foreach (int item in model.OrderID)
                    {
                        int addNetTradeOrderRes = db.SetCommand(strAddNetTradeOrderSql
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@NetTradeNo", netTradeNo, DbType.String)
                        , db.Parameter("@OrderID", item, DbType.Int32)
                        , db.Parameter("@CreatorID", model.AccountID, DbType.Int32)
                        , db.Parameter("@CreateTime", model.Time, DbType.DateTime2)).ExecuteNonQuery();

                        if (addNetTradeOrderRes <= 0)
                        {
                            db.RollbackTransaction();
                            return "";
                        }
                    }

                }

                db.CommitTransaction();
                return netTradeNo;
            }
        }

        public GetWeChatPayInfo_Model GetWeChatPayInfo(int companyId, string netTradeNo)
        {
            using (DbManager db = new DbManager())
            {
                GetWeChatPayInfo_Model model = new GetWeChatPayInfo_Model();
                string strSql = @" SELECT   T1.CompanyID ,
                                            T1.NetTradeNo ,
                                            T2.Name AS CompanyName ,
                                            T1.ProductName ,
                                            T1.NetTradeAmount ,
                                            T3.CurrencySymbol AS Currency
                                    FROM    TBL_NETTRADE_CONTROL T1 WITH ( NOLOCK )
                                            LEFT JOIN [COMPANY] T2 WITH ( NOLOCK ) ON T1.CompanyID = T2.ID
                                            LEFT JOIN [SYS_CURRENCY] T3 WITH ( NOLOCK ) ON T2.SettlementCurrency = T3.ID
                                    WHERE   T1.NetTradeNo = @NetTradeNo ";

                if (companyId > 0)
                {
                    strSql += " AND T1.CompanyID = @CompanyID ";
                }
                model = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@NetTradeNo", netTradeNo, DbType.String)).ExecuteObject<GetWeChatPayInfo_Model>();

                return model;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="netTradeNo"></param>
        /// <returns>-1:NetTradeNo不存在 0:没有处理过 1:已经处理过</returns>
        public int HasTradePay(string netTradeNo, int netTradeVendor = 1)
        {
            using (DbManager db = new DbManager())
            {
                string strSelControlSql = @" SELECT  COUNT(0)
                                            FROM    TBL_NETTRADE_CONTROL
                                            WHERE   NetTradeNo = @NetTradeNo ";

                int res = db.SetCommand(strSelControlSql
                   , db.Parameter("@NetTradeNo", netTradeNo, DbType.String)).ExecuteScalar<int>();

                if (res <= 0)
                {
                    return -1;
                }

                if (netTradeVendor == 1)//微信支付
                {
                    string strSql = @" SELECT  COUNT(0)
                                FROM    [TBL_WEIXINPAY_RESULT] T1 WITH ( NOLOCK )
                                WHERE   T1.NetTradeNo = @NetTradeNo ";

                    res = db.SetCommand(strSql
                       , db.Parameter("@NetTradeNo", netTradeNo, DbType.String)).ExecuteScalar<int>();

                    if (res <= 0)
                    {
                        return 0;
                    }
                }
                else if (netTradeVendor == 2)//支付宝支付
                {
                    string strSql = @" SELECT  COUNT(0)
                                FROM    [TBL_ALIPAY_RESULT] T1 WITH ( NOLOCK )
                                WHERE   T1.NetTradeNo = @NetTradeNo ";

                    res = db.SetCommand(strSql
                       , db.Parameter("@NetTradeNo", netTradeNo, DbType.String)).ExecuteScalar<int>();

                    if (res <= 0)
                    {
                        return 0;
                    }
                }

                return 1;
            }
        }

        public bool AddWeiXinResult(WeChatReturn_Model weChatModel, int CompanyID, DateTime time, int userID)
        {
            using (DbManager db = new DbManager())
            {

                string addWechatResultSql = @" INSERT INTO dbo.TBL_WEIXINPAY_RESULT( CompanyID ,NetTradeNo ,TradeState ,ResultCode ,ErrCode ,ErrCodeDes ,TransactionID ,OpenID ,TradeType ,TotalFee ,CashFee ,AppID ,BankType ,BankName ,TimeEnd ,TradeStateDesc ,CreatorID ,CreateTime ) 
                VALUES ( @CompanyID ,@NetTradeNo ,@TradeState ,@ResultCode ,@ErrCode ,@ErrCodeDes ,@TransactionID ,@OpenID ,@TradeType ,@TotalFee ,@CashFee ,@AppID ,@BankType ,@BankName ,@TimeEnd ,@TradeStateDesc ,@CreatorID ,@CreateTime ) ";

                int addWechatResultRes = db.SetCommand(addWechatResultSql
                                          , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                          , db.Parameter("@NetTradeNo", weChatModel.out_trade_no, DbType.String)
                                          , db.Parameter("@TradeState", weChatModel.trade_state, DbType.String)
                                          , db.Parameter("@ResultCode", weChatModel.result_code, DbType.String)
                                          , db.Parameter("@ErrCode", weChatModel.err_code, DbType.String)
                                          , db.Parameter("@ErrCodeDes", weChatModel.err_code_des, DbType.String)
                                          , db.Parameter("@TransactionID", DBNull.Value, DbType.String)
                                          , db.Parameter("@OpenID", DBNull.Value, DbType.String)
                                          , db.Parameter("@TradeType", DBNull.Value, DbType.String)
                                          , db.Parameter("@TotalFee", DBNull.Value, DbType.Decimal)
                                          , db.Parameter("@CashFee", DBNull.Value, DbType.Decimal)
                                          , db.Parameter("@AppID", weChatModel.appid, DbType.String)
                                          , db.Parameter("@BankType", DBNull.Value, DbType.String)
                                          , db.Parameter("@BankName", DBNull.Value, DbType.String)
                                          , db.Parameter("@TimeEnd", time, DbType.DateTime2)
                                          , db.Parameter("@TradeStateDesc", weChatModel.trade_state_desc, DbType.String)
                                          , db.Parameter("@CreatorID", userID, DbType.String)
                                          , db.Parameter("@CreateTime", time, DbType.DateTime2)).ExecuteNonQuery();

                if (addWechatResultRes <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                return true;
            }
        }

        public bool AddAliPayFailResult(Alipay_trade_pay_response aliPayModel, int CompanyID, DateTime time, int userID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" INSERT INTO dbo.TBL_ALIPAY_RESULT( CompanyID ,NetTradeNo ,TradeState ,Code ,Msg ,SubMsg ,TradeNo ,BuyerUserId ,BuyerLogonId ,TotalAmount ,ReceiptAmount ,InvoiceAmount ,BuyerPayAmount ,PointAmount ,SendPayDate ,FundBillList ,DiscountGoodsDetail ,CreatorID ,CreateTime ) 
VALUES (@CompanyID ,@NetTradeNo ,@TradeState ,@Code ,@Msg ,@SubMsg ,@TradeNo ,@BuyerUserId ,@BuyerLogonId ,@TotalAmount ,@ReceiptAmount ,@InvoiceAmount ,@BuyerPayAmount ,@PointAmount ,@SendPayDate ,@FundBillList ,@DiscountGoodsDetail ,@CreatorID ,@CreateTime)";

                int res = db.SetCommand(strSql
                                          , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                          , db.Parameter("@NetTradeNo", aliPayModel.out_trade_no, DbType.String)
                                          , db.Parameter("@TradeState", DBNull.Value, DbType.String)
                                          , db.Parameter("@Code", aliPayModel.code, DbType.String)
                                          , db.Parameter("@Msg", aliPayModel.msg, DbType.String)
                                          , db.Parameter("@SubMsg", aliPayModel.sub_desc, DbType.String)
                                          , db.Parameter("@TradeNo", DBNull.Value, DbType.String)
                                          , db.Parameter("@BuyerUserId", DBNull.Value, DbType.String)
                                          , db.Parameter("@BuyerLogonId", DBNull.Value, DbType.String)
                                          , db.Parameter("@TotalAmount", DBNull.Value, DbType.Int32)
                                          , db.Parameter("@ReceiptAmount", DBNull.Value, DbType.Int32)
                                          , db.Parameter("@InvoiceAmount", DBNull.Value, DbType.Int32)
                                          , db.Parameter("@BuyerPayAmount", DBNull.Value, DbType.Int32)
                                          , db.Parameter("@PointAmount", DBNull.Value, DbType.Int32)
                                          , db.Parameter("@SendPayDate", DBNull.Value, DbType.DateTime2)
                                          , db.Parameter("@FundBillList", DBNull.Value, DbType.String)
                                          , db.Parameter("@DiscountGoodsDetail", DBNull.Value, DbType.String)
                                          , db.Parameter("@CreatorID", userID, DbType.String)
                                          , db.Parameter("@CreateTime", time, DbType.DateTime2)).ExecuteNonQuery();

                if (res <= 0)
                {
                    return false;
                }

                return true;
            }
        }

        public int AddTradePay(WeChatReturn_Model weChatModel, DateTime time)
        {
            using (DbManager db = new DbManager())
            {
                string strSelOrderIDs = @" SELECT  OrderID
                                        FROM    [TBL_NETTRADE_ORDER] T1 WITH ( NOLOCK )
                                        WHERE   T1.NetTradeNo = @NetTradeNo ";

                List<int> orderIDList = db.SetCommand(strSelOrderIDs
                    , db.Parameter("@NetTradeNo", weChatModel.out_trade_no, DbType.String)).ExecuteScalarList<int>();

                if (orderIDList == null || orderIDList.Count <= 0)
                {
                    return 0;
                }

                List<int> orderIDListWithout0Price = new List<int>();
                PaymentCheck_Model paymentCheckModel = new PaymentCheck_Model();
                int canPayRes = Order_DAL.Instance.CanOrderCanPay(orderIDList, out orderIDListWithout0Price, out paymentCheckModel);
                //if (canPayRes != 1)
                //{
                //    return canPayRes;
                //}

                #region 根据NetTradeNo获取数据
                string strSelTradeControlSql = @" SELECT  T1.CompanyID ,
                                                        T1.BranchID ,
                                                        T1.NetTradeNo ,
                                                        T1.NetActionType ,
                                                        T1.NetTradeVendor ,
                                                        T1.NetTradeActionMode ,
                                                        ProductName ,
                                                        NetTradeAmount ,
                                                        PointAmount ,
                                                        CouponAmount ,
                                                        Participants,
                                                        Remark ,
                                                        CreatorID 
                                                FROM    [TBL_NETTRADE_CONTROL] T1
                                                WHERE   T1.NetTradeNo = @NetTradeNo ";

                NetTrade_Control_Model model = db.SetCommand(strSelTradeControlSql,
                            db.Parameter("@NetTradeNo", weChatModel.out_trade_no, DbType.String)).ExecuteObject<NetTrade_Control_Model>();

                if (model == null)
                {
                    return 0;
                }

                #region 获取业绩分享人
                List<Slave_Model> Slavers = new List<Slave_Model>();
                if (!string.IsNullOrEmpty(model.Participants))
                {
                    string[] strSlavID = model.Participants.Split(new string[] { "|" }, StringSplitOptions.RemoveEmptyEntries);
                    if (strSlavID.Length > 0)
                    {
                        for (int i = 0; i < strSlavID.Length; i++)
                        {
                            Slave_Model slaver = new Slave_Model();
                            string[] slaverTemp = strSlavID[i].Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                            if (slaverTemp.Length > 0)
                            {
                                slaver.SlaveID = StringUtils.GetDbInt(slaverTemp[0]);
                                slaver.ProfitPct = StringUtils.GetDbDecimal(slaverTemp[1]);
                                Slavers.Add(slaver);
                            }
                        }
                    }
                }
                #endregion

                #endregion

                #region 权限设置
                PaymentBranchRole paymentBranchRole = new PaymentBranchRole();
                paymentBranchRole.IsCustomerConfirm = true;
                paymentBranchRole.IsAccountEcardPay = false;
                paymentBranchRole.IsPartPay = false;
                paymentBranchRole.IsUseRate = 3;

                string strSqlCommand = @"select IsPay as IsAccountEcardPay,IsConfirmed as IsCustomerConfirm,IsPartPay,IsUseRate from [BRANCH] 
                                                where BRANCH.ID = @BranchID ";

                paymentBranchRole = db.SetCommand(strSqlCommand,
                                                db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteObject<PaymentBranchRole>();

                if (paymentBranchRole == null)
                {
                    return 0;
                }
                #endregion

                db.BeginTransaction();

                #region 插入PayMent表

                decimal paymentAmount = (weChatModel.cash_fee / 100);

                string strSqlPayAdd = @"insert into PAYMENT(CompanyID,OrderNumber,TotalPrice,CreatorID,CreateTime,Remark,PaymentTime,LevelID,Type,Status,BranchID,ClientType,IsUseRate) 
                                              values (@CompanyID,@OrderNumber,@TotalPrice,@CreatorID,@CreateTime,@Remark,@PaymentTime,@LevelID,@Type,@Status,@BranchID,@ClientType,@IsUseRate);select @@IDENTITY";
                int paymentID = db.SetCommand(strSqlPayAdd,
                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@OrderNumber", orderIDList.Count, DbType.Int32)
                            , db.Parameter("@TotalPrice", paymentAmount, DbType.Decimal)
                            , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                            , db.Parameter("@CreateTime", time, DbType.DateTime)
                            , db.Parameter("@Remark", model.Remark, DbType.String)
                            , db.Parameter("@PaymentTime", time, DbType.DateTime)
                            , db.Parameter("@LevelID", DBNull.Value, DbType.Int32)
                            , db.Parameter("@Type", 1, DbType.Int32)//1：支付 2：退款
                            , db.Parameter("@Status", 2, DbType.Int32)//1：无效 2：执行 3：撤销
                            , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                            , db.Parameter("@ClientType", 1, DbType.Int32)
                            , db.Parameter("@IsUseRate", paymentBranchRole.IsUseRate, DbType.Int32)).ExecuteScalar<int>();

                if (paymentID <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                #region 插入业绩分享人
                if (paymentID >= 0 && Slavers != null && Slavers.Count > 0)
                {
                    foreach (Slave_Model item in Slavers)
                    {
                        string strAddProfitSql = @" INSERT	INTO TBL_PROFIT( MasterID ,SlaveID ,Type ,ProfitPct ,Available ,CreateTime ,CreatorID) 
                                                VALUES (@MasterID ,@SlaveID ,@Type ,@ProfitPct ,@Available ,@CreateTime ,@CreatorID)";
                        int addProfitres = db.SetCommand(strAddProfitSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@MasterID", paymentID, DbType.Int64)
                                , db.Parameter("@SlaveID", item.SlaveID, DbType.Int32)
                                , db.Parameter("@Type", 2, DbType.Int32)
                                , db.Parameter("@ProfitPct", item.ProfitPct, DbType.Decimal)
                                , db.Parameter("@Available", true, DbType.Boolean)
                                , db.Parameter("@CreateTime", time, DbType.DateTime2)
                                , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)).ExecuteNonQuery();

                        if (addProfitres <= 0)
                        {
                            db.RollbackTransaction();
                            //LogUtil.Log("插入业绩表出错", "PaymentID:" + paymentID + "插入业绩表出错。");
                            return 0;
                        }
                    }
                }
                #endregion

                #region 插入PaymentDetail表
                int paymentDetailID = 0;
                if (Math.Abs(weChatModel.cash_fee) > 0)//排除传过来为0的记录
                {
                    weChatModel.cash_fee = Math.Abs(weChatModel.cash_fee);
                    string strSqlDetailAdd = @"insert into PAYMENT_DETAIL(CompanyID,PaymentID,PaymentMode,PaymentAmount,CreatorID,CreateTime,UserCardNo,CardPaidAmount,ProfitRate) 
                                                       values (@CompanyID,@PaymentID,@PaymentMode,@PaymentAmount,@CreatorID,@CreateTime,@UserCardNo,@CardPaidAmount,@ProfitRate);select @@IDENTITY";

                    paymentDetailID = db.SetCommand(strSqlDetailAdd
                                     , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                     , db.Parameter("@PaymentID", paymentID, DbType.Int32)
                                     , db.Parameter("@PaymentMode", 8, DbType.Int32)//0:现金、1:储值卡、2:银行卡。3:其他 4:免支付 5：过去支付 6:积分 7：现金券 8：微信第三方支付
                                     , db.Parameter("@PaymentAmount", paymentAmount, DbType.Decimal)
                                     , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                     , db.Parameter("@CreateTime", time, DbType.DateTime)
                                     , db.Parameter("@UserCardNo", "", DbType.String)
                                     , db.Parameter("@CardPaidAmount", paymentAmount, DbType.Decimal)
                                     , db.Parameter("@ProfitRate", 1, DbType.Decimal)).ExecuteScalar<int>();

                    if (paymentDetailID <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    string strSelCompanyComissionCalcSql = " SELECT [ComissionCalc] FROM COMPANY WHERE ID=@CompanyID ";
                    bool isComissionCalc = db.SetCommand(strSelCompanyComissionCalcSql
                                         , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<bool>();

                    if (isComissionCalc)
                    {
                        #region 计算销售业绩
                        foreach (int orderID in orderIDListWithout0Price)
                        {
                            #region 取出Product基本数据
                            string strSelProductSql = @" SELECT CASE T1.ProductType
                                                                          WHEN 0 THEN T2.ServiceCode
                                                                          ELSE T3.CommodityCode
                                                                        END AS ProductCode ,
                                                                        T1.ProductType ,T1.TotalSalePrice 
                                                                 FROM   [ORDER] T1 WITH ( NOLOCK )
                                                                        LEFT JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.ID = T2.OrderID
                                                                        LEFT JOIN [TBL_ORDER_COMMODITY] T3 WITH ( NOLOCK ) ON T1.ID = T3.OrderID
                                                                 WHERE  T1.CompanyID = @CompanyID
                                                                        AND T1.ID = @OrderID; ";
                            DataTable dt = db.SetCommand(strSelProductSql
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteDataTable();

                            if (dt == null || dt.Rows.Count < 1)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            int productType = StringUtils.GetDbInt(dt.Rows[0]["ProductType"]);
                            long productCode = StringUtils.GetDbLong(dt.Rows[0]["ProductCode"]);
                            decimal totalSalePrice = StringUtils.GetDbDecimal(dt.Rows[0]["TotalSalePrice"]);
                            #endregion

                            #region 取出TBL_PRODUCT_COMMISSION_RULE数据
                            string strSelProductCommissionRuleSql = @" SELECT ProductType ,
                                                                                        ProductCode ,
                                                                                        ProfitPct ,
                                                                                        ECardSACommType ,
                                                                                        ECardSACommValue ,
                                                                                        NECardSACommType ,
                                                                                        NECardSACommValue
                                                                                 FROM   TBL_PRODUCT_COMMISSION_RULE
                                                                                 WHERE  CompanyID = @CompanyID
                                                                                        AND ProductType = @ProductType
                                                                                        AND ProductCode = @ProductCode ";

                            Product_Commission_Rule_Model ProductRuleModel = db.SetCommand(strSelProductCommissionRuleSql
                                                               , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                               , db.Parameter("@ProductType", productType, DbType.Int32)
                                                               , db.Parameter("@ProductCode", productCode, DbType.Int64)).ExecuteObject<Product_Commission_Rule_Model>();
                            #endregion

                            if (ProductRuleModel != null && ProductRuleModel.ProductCode > 0)
                            {
                                //decimal Income = paymentAmount * 1;
                                decimal Income = orderIDList.Count > 1 ? (totalSalePrice * 1) : (paymentAmount * 1);
                                //if (orderIDList.Count > 1)
                                //{
                                //    Income = (totalSalePrice * 1);
                                //}
                                //else
                                //{
                                //    Income = (paymentAmount * 1);
                                //}
                                decimal Profit = Income * ProductRuleModel.ProfitPct;

                                string strAddProfitDetailSql = @" INSERT INTO TBL_PROFIT_COMMISSION_DETAIL ( CompanyID ,BranchID ,SourceType ,SourceID ,SubSourceID ,Income ,ProfitPct ,Profit ,CommType ,CommValue ,AccountID ,AccountProfitPct ,AccountProfit ,AccountComm ,CommFlag ,CreatorID ,CreateTime ) 
                                                                    VALUES ( @CompanyID ,@BranchID ,@SourceType ,@SourceID ,@SubSourceID ,@Income ,@ProfitPct ,@Profit ,@CommType ,@CommValue ,@AccountID ,@AccountProfitPct ,@AccountProfit ,@AccountComm ,@CommFlag ,@CreatorID ,@CreateTime ) ";

                                if (paymentID >= 0 && Slavers != null && Slavers.Count > 0)
                                {
                                    #region 有业绩分享人
                                    foreach (Slave_Model slaveItem in Slavers)
                                    {
                                        #region 有业绩分享人
                                        //员工业绩(=实际业绩 x 员工业绩计算比例)
                                        decimal AccountProfit = Profit * slaveItem.ProfitPct;
                                        decimal AccountComm = 0;
                                        //1:按比例 2:固定值
                                        if (orderIDList.Count > 1)
                                        {
                                            AccountComm = Math.Round(ProductRuleModel.NECardSACommValue * 1 * slaveItem.ProfitPct, 2, MidpointRounding.AwayFromZero);
                                        }
                                        else
                                        {
                                            AccountComm = Math.Round(ProductRuleModel.NECardSACommValue * (paymentAmount / totalSalePrice) * slaveItem.ProfitPct, 2, MidpointRounding.AwayFromZero);
                                        }

                                        if (ProductRuleModel.NECardSACommType == 1)
                                        {
                                            AccountComm = AccountProfit * ProductRuleModel.NECardSACommValue;
                                        }

                                        int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                            , db.Parameter("@SourceType", 1, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                            , db.Parameter("@SourceID", paymentDetailID, DbType.Int64)
                                            , db.Parameter("@SubSourceID", orderID, DbType.Int64)
                                            , db.Parameter("@Income", Income, DbType.Decimal)//收入 充值时，为TBL_MONEY_BALANCE的Amount
                                            , db.Parameter("@ProfitPct", ProductRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                            , db.Parameter("@Profit", Profit, DbType.Decimal)//实际业绩
                                            , db.Parameter("@CommType", ProductRuleModel.NECardSACommType, DbType.Int32)//该业绩的提成方式
                                            , db.Parameter("@CommValue", ProductRuleModel.NECardSACommValue, DbType.Decimal)//该业绩的提成数值
                                            , db.Parameter("@AccountID", slaveItem.SlaveID, DbType.Int32)//获得该业绩的员工ID
                                            , db.Parameter("@AccountProfitPct", slaveItem.ProfitPct, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                            , db.Parameter("@AccountProfit", AccountProfit, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                            , db.Parameter("@AccountComm", AccountComm, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
                                            , db.Parameter("@CommFlag", DBNull.Value, DbType.Int32)//1：首充 2：指定 3：E账户
                                            , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                            , db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                                        if (addProfitDetailRes != 1)
                                        {
                                            db.RollbackTransaction();
                                            return 0;
                                        }
                                        #endregion
                                    }
                                    #endregion
                                }
                                else
                                {
                                    #region 没有业绩分享人
                                    int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                            , db.Parameter("@SourceType", 1, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                            , db.Parameter("@SourceID", paymentDetailID, DbType.Int64)
                                            , db.Parameter("@SubSourceID", orderID, DbType.Int64)
                                            , db.Parameter("@Income", Income, DbType.Decimal)//收入 充值时，为TBL_MONEY_BALANCE的Amount
                                            , db.Parameter("@ProfitPct", ProductRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                            , db.Parameter("@Profit", Profit, DbType.Decimal)//实际业绩
                                            , db.Parameter("@CommType", ProductRuleModel.NECardSACommType, DbType.Int32)//该业绩的提成方式
                                            , db.Parameter("@CommValue", ProductRuleModel.NECardSACommValue, DbType.Decimal)//该业绩的提成数值
                                            , db.Parameter("@AccountID", DBNull.Value, DbType.Int32)//获得该业绩的员工ID
                                            , db.Parameter("@AccountProfitPct", DBNull.Value, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                            , db.Parameter("@AccountProfit", DBNull.Value, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                            , db.Parameter("@AccountComm", DBNull.Value, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
                                            , db.Parameter("@CommFlag", DBNull.Value, DbType.Int32)//1：首充 2：指定 3：E账户
                                            , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                            , db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                                    if (addProfitDetailRes != 1)
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
                }

                #endregion

                #region 抽取专属顾问数据
                GetOrderDetail_Model orderModel = new GetOrderDetail_Model();

                string strSelOrderInfoSql = @" SELECT  T1.AccountID
                                                            FROM    RELATIONSHIP T1 WITH ( NOLOCK )
                                                            WHERE   CustomerID = @CustomerID
                                                                    AND T1.Type = 1 
                                                                    AND T1.Available = 1
                                                                    AND T1.BranchID = @BranchID";

                int ResponsiblePersonID = db.SetCommand(strSelOrderInfoSql
                    , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteScalar<int>();
                #endregion

                foreach (int orderID in orderIDListWithout0Price)
                {
                    #region 插入OrderPayment关系表
                    string strSqlOrderPayAdd = @"insert into TBL_OrderPayment_RelationShip(OrderID,PaymentID) 
                                                                values (@OrderID,@PaymentID);select @@IDENTITY";
                    int orderPaymentRes = db.SetCommand(strSqlOrderPayAdd
                                          , db.Parameter("@OrderID", orderID, DbType.Int32)
                                          , db.Parameter("@PaymentID", paymentID, DbType.Int32)
                        //db.Parameter("@ResponsiblePersonID", responsiblePersonID, DbType.Int32),
                        //db.Parameter("@SalesID", salesID, DbType.Int32)
                                          ).ExecuteNonQuery();

                    if (orderPaymentRes <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    #endregion

                    #region 支付状态判断
                    decimal unpaidPrice = 0;
                    int paymentStatus = 1;
                    if (orderIDListWithout0Price.Count == 1 && paymentBranchRole.IsPartPay)
                    {
                        //可以分期支付 查询未支付金额
                        string strSqlSelectUnpaidPrice = @"SELECT UnPaidPrice FROM  [ORDER] WHERE ID=@OrderID";
                        decimal orderUnpaidPrice = db.SetCommand(strSqlSelectUnpaidPrice, db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteScalar<decimal>();
                        //if (orderUnpaidPrice <= 0 || orderUnpaidPrice < weChatModel.cash_fee)
                        //{
                        //    return 0;
                        //}
                        unpaidPrice = orderUnpaidPrice - (weChatModel.cash_fee / 100);
                        if (unpaidPrice <= 0)
                        {
                            paymentStatus = 3; // 完全支付
                        }
                        else
                        {
                            paymentStatus = 2; // 部分支付
                        }
                    }
                    else
                    {
                        unpaidPrice = 0;
                        paymentStatus = 3;
                    }
                    #endregion

                    #region 更新订单状态和PaymentID
                    string strSqlOrderUpt = @"update [ORDER] set UnPaidPrice=@UnPaidPrice, PaymentStatus=@PaymentStatus,UpdaterID = @UpdaterID, UpdateTime = @UpdateTime where ID =@OrderID";

                    int orderuptRes = db.SetCommand(strSqlOrderUpt,
                        db.Parameter("@UnPaidPrice", unpaidPrice, DbType.Decimal),// 未支付金额
                        db.Parameter("@PaymentStatus", paymentStatus, DbType.Int32),// 1:未支付 2:部分支付 3:完全支付
                        db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32),
                        db.Parameter("@UpdateTime", time, DbType.DateTime),
                        db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteNonQuery();

                    if (orderuptRes <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    #endregion
                }

                #region 赠送
                if (model.PointAmount > 0 || model.CouponAmount > 0)
                {
                    #region 插入CUSTOMER_BALANCE
                    string strAddCustomerBalance = @" INSERT [TBL_CUSTOMER_BALANCE]	( CompanyID ,BranchID ,UserID ,ChangeType ,TargetAccount ,PaymentID ,Remark ,CreatorID ,CreateTime) 
                                VALUES(@CompanyID ,@BranchID ,@UserID ,@ChangeType ,@TargetAccount ,@PaymentID ,@Remark ,@CreatorID ,@CreateTime);select @@IDENTITY";
                    int customerBalanceID = db.SetCommand(strAddCustomerBalance,
                                db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                db.Parameter("@UserID", paymentCheckModel.CustomerID, DbType.Int32),
                                db.Parameter("@ChangeType", 1, DbType.Int32),//1:账户消费、2:账户消费撤销、3：账户充值、4：账户充值撤销、5：账户直扣、6：账户直扣撤销(9:退款 也属于账户直扣)
                                db.Parameter("@TargetAccount", 0, DbType.Int32),//目标账户：1:储值卡、2:积分、3:现金券  账户消费和消费撤销时，设默认值0
                        //db.Parameter("@ResponsiblePersonID", model.CreatorID, DbType.Int32),
                                db.Parameter("@PaymentID", paymentID, DbType.Int32),
                                db.Parameter("@Remark", "", DbType.String),
                                db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteScalar<int>();

                    if (customerBalanceID <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    #endregion

                    if (model.PointAmount > 0)
                    {
                        #region 获取积分卡
                        string strSqlGetBalance = @"SELECT  T1.Balance ,T1.UserCardNo 
                                                    FROM    [TBL_CUSTOMER_CARD] T1 WITH ( NOLOCK )
                                                    INNER JOIN [MST_CARD] T2 WITH(NOLOCK) ON T1.CardID=T2.ID
                                                    WHERE   T1.CompanyID = @CompanyID
                                                            AND T1.UserID = @CustomerID
                                                            AND T2.CardTypeID=2";

                        DataTable dt = db.SetCommand(strSqlGetBalance
                                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                    , db.Parameter("@CustomerID", paymentCheckModel.CustomerID, DbType.Int32)).ExecuteDataTable();

                        if (dt == null || dt.Rows.Count <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        #region 插入pointBalance
                        string userCardNo = StringUtils.GetDbString(dt.Rows[0]["UserCardNo"]);
                        decimal balance = StringUtils.GetDbDecimal(dt.Rows[0]["Balance"]);

                        model.PointAmount = Math.Abs(model.PointAmount);
                        balance = balance + model.PointAmount;
                        if (!string.IsNullOrWhiteSpace(userCardNo))
                        {
                            string strAddPointBalance = @" INSERT INTO [TBL_POINT_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CreatorID ,CreateTime) 
                                VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CreatorID ,@CreateTime)";

                            int addres = db.SetCommand(strAddPointBalance
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                    , db.Parameter("@UserID", paymentCheckModel.CustomerID, DbType.Int32)
                                    , db.Parameter("@CustomerBalanceID", customerBalanceID, DbType.Int32)
                                    , db.Parameter("@ActionMode", 3, DbType.Int32)//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                    , db.Parameter("@DepositMode", 0, DbType.Int32)//1:充值、2:余额转入
                                    , db.Parameter("@Remark", "", DbType.String)
                                    , db.Parameter("@UserCardNo", userCardNo, DbType.String)
                                    , db.Parameter("@Amount", model.PointAmount, DbType.Decimal)
                                    , db.Parameter("@Balance", balance, DbType.Decimal)
                                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                    , db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                            if (addres <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                        }

                        #endregion

                        #region 修改CustomerCard中的Balance
                        string strUpdateCustomerCard = @" UPDATE [TBL_CUSTOMER_CARD] SET Balance=@Balance WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo";
                        int updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", balance, DbType.Decimal)
                                                             , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                             , db.Parameter("@UserID", paymentCheckModel.CustomerID, DbType.Int32)
                                                             , db.Parameter("@UserCardNo", userCardNo, DbType.String)).ExecuteNonQuery();

                        if (updateRes == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion
                    }

                    if (model.CouponAmount > 0)
                    {
                        #region 获取现金券卡
                        string strSqlGetBalance = @"SELECT  T1.Balance ,T1.UserCardNo 
                                                    FROM    [TBL_CUSTOMER_CARD] T1 WITH ( NOLOCK )
                                                    INNER JOIN [MST_CARD] T2 WITH(NOLOCK) ON T1.CardID=T2.ID
                                                    WHERE   T1.CompanyID = @CompanyID
                                                            AND T1.UserID = @CustomerID
                                                            AND T2.CardTypeID = 3";

                        DataTable dt = db.SetCommand(strSqlGetBalance
                                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                    , db.Parameter("@CustomerID", paymentCheckModel.CustomerID, DbType.Int32)).ExecuteDataTable();

                        if (dt == null || dt.Rows.Count <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        #region 插入TBL_COUPON_BALANCE
                        string userCardNo = StringUtils.GetDbString(dt.Rows[0]["UserCardNo"]);
                        decimal balance = StringUtils.GetDbDecimal(dt.Rows[0]["Balance"]);

                        model.CouponAmount = Math.Abs(model.CouponAmount);
                        balance = balance + model.CouponAmount;
                        if (!string.IsNullOrWhiteSpace(userCardNo))
                        {
                            string strAddCouponBalance = @" INSERT INTO [TBL_COUPON_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CouponType ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CouponType ,@CreatorID ,@CreateTime)";

                            int addres = db.SetCommand(strAddCouponBalance,
                                    db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                    db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                    db.Parameter("@UserID", paymentCheckModel.CustomerID, DbType.Int32),
                                    db.Parameter("@CustomerBalanceID", customerBalanceID, DbType.Int32),
                                    db.Parameter("@ActionMode", 3, DbType.Int32),// 1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                    db.Parameter("@DepositMode", 0, DbType.Int32),//1:充值、2:余额转入
                                    db.Parameter("@Remark", "", DbType.String),
                                    db.Parameter("@UserCardNo", userCardNo, DbType.String),
                                    db.Parameter("@Amount", model.CouponAmount, DbType.Decimal),
                                    db.Parameter("@Balance", balance, DbType.Decimal),
                                    db.Parameter("@CouponType", 0, DbType.Int32),
                                    db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                    db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                            if (addres <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                        }

                        #endregion

                        #region 修改CustomerCard中的Balance
                        string strUpdateCustomerCard = @" UPDATE [TBL_CUSTOMER_CARD] SET Balance=@Balance WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo";
                        int updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", balance, DbType.Decimal)
                                                             , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                             , db.Parameter("@UserID", paymentCheckModel.CustomerID, DbType.Int32)
                                                             , db.Parameter("@UserCardNo", userCardNo, DbType.String)).ExecuteNonQuery();

                        if (updateRes == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion
                    }
                }
                #endregion

                #region 美丽顾问/销售顾问
                string strAddConsultant = @" INSERT INTO [TBL_BUSINESS_CONSULTANT]( CompanyID ,BusinessType ,MasterID ,ConsultantType ,ConsultantID ,CreatorID ,CreateTime )
                                                    VALUES ( @CompanyID ,@BusinessType ,@MasterID ,@ConsultantType ,@ConsultantID ,@CreatorID ,@CreateTime )";

                #region 美丽顾问
                if (ResponsiblePersonID > 0)
                {
                    int addConsultantRes = db.SetCommand(strAddConsultant
                           , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                           , db.Parameter("@BusinessType", 2, DbType.Int32)//1：订单，2：支付，3：充值
                           , db.Parameter("@MasterID", paymentID, DbType.Int32)
                           , db.Parameter("@ConsultantType", 1, DbType.Int32)//1:美丽顾问 2:销售顾问
                           , db.Parameter("@ConsultantID", ResponsiblePersonID, DbType.Int32)
                           , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                           , db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                    if (addConsultantRes <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                }
                #endregion

                string advanced = WebAPI.DAL.Company_DAL.Instance.getAdvancedByCompanyID(model.CompanyID);
                if (advanced.Contains("|4|"))
                {
                    #region 销售顾问
                    string strSelSalesSql = @"SELECT  AccountID
                                            FROM    [RELATIONSHIP]
                                            WHERE   companyID = @CompanyID
                                                    AND BranchID = @BranchID
                                                    AND CustomerID = @CustomerID
                                                    AND Available = 1
                                                    AND Type = 2";

                    List<int> SalesPersonIDList = db.SetCommand(strSelSalesSql,
                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                            db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                            db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteScalarList<int>();

                    if (SalesPersonIDList != null || SalesPersonIDList.Count > 0)
                    {
                        foreach (int SalesPersonID in SalesPersonIDList)
                        {
                            int addConsultantRes = db.SetCommand(strAddConsultant
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@BusinessType", 3, DbType.Int32)//1：订单，2：支付，3：充值
                            , db.Parameter("@MasterID", paymentID, DbType.Int32)
                            , db.Parameter("@ConsultantType", 2, DbType.Int32)//1:美丽顾问 2:销售顾问
                            , db.Parameter("@ConsultantID", SalesPersonID, DbType.Int32)
                            , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                            , db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                            if (addConsultantRes <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                        }
                    }
                    #endregion
                }
                #endregion

                #region 插入TBL_NETTRADE_RELATION
                string strTradeRelationSql = @" INSERT INTO [TBL_NETTRADE_RELATION]( CompanyID ,NetTradeNo ,NetTradeType ,PaymentID ,PaymentDetailID ,CustomerBalanceID ,MoneyBalanceID ,CreatorID ,CreateTime ) 
                                                VALUES ( @CompanyID ,@NetTradeNo ,@NetTradeType ,@PaymentID ,@PaymentDetailID ,@CustomerBalanceID ,@MoneyBalanceID ,@CreatorID ,@CreateTime ) ";

                int addTradeRelationRes = db.SetCommand(strTradeRelationSql
                                          , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                          , db.Parameter("@NetTradeNo", weChatModel.out_trade_no, DbType.String)
                                          , db.Parameter("@NetTradeType", 1, DbType.Int32)//1:消费 2:充值
                                          , db.Parameter("@PaymentID", paymentID, DbType.Int32)
                                          , db.Parameter("@PaymentDetailID", paymentDetailID, DbType.Int32)
                                          , db.Parameter("@CustomerBalanceID", 0, DbType.Int32)
                                          , db.Parameter("@MoneyBalanceID", 0, DbType.Int32)
                                          , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                          , db.Parameter("@CreateTime", time, DbType.DateTime2)).ExecuteNonQuery();

                if (addTradeRelationRes <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                #region 插入TBL_WEIXINPAY_RESULT

                string strSelBankSql = @"SELECT  BankName
                                        FROM    [SYS_BANK_NAME]
                                        WHERE   NetTradeVendor = 1
                                                AND RecordType = 1
                                                AND BankType = @BankType";

                string bankName = db.SetCommand(strSelBankSql
                                  , db.Parameter("@BankType", weChatModel.bank_type, DbType.String)).ExecuteScalar<string>();

                string addWechatResultSql = @" INSERT INTO dbo.TBL_WEIXINPAY_RESULT( CompanyID ,NetTradeNo ,TradeState ,ResultCode ,TransactionID ,OpenID ,TradeType ,TotalFee ,CashFee ,AppID ,BankType ,BankName ,TimeEnd ,TradeStateDesc ,CreatorID ,CreateTime ) 
                VALUES ( @CompanyID ,@NetTradeNo ,@TradeState ,@ResultCode ,@TransactionID ,@OpenID ,@TradeType ,@TotalFee ,@CashFee ,@AppID ,@BankType ,@BankName ,@TimeEnd ,@TradeStateDesc ,@CreatorID ,@CreateTime ) ";

                int addWechatResultRes = db.SetCommand(addWechatResultSql
                                          , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                          , db.Parameter("@NetTradeNo", weChatModel.out_trade_no, DbType.String)
                                          , db.Parameter("@TradeState", "SUCCESS", DbType.String)
                                          , db.Parameter("@ResultCode", weChatModel.result_code, DbType.String)
                                          , db.Parameter("@TransactionID", weChatModel.transaction_id, DbType.String)
                                          , db.Parameter("@OpenID", weChatModel.openid, DbType.String)
                                          , db.Parameter("@TradeType", weChatModel.trade_type, DbType.String)
                                          , db.Parameter("@TotalFee", weChatModel.total_fee, DbType.Decimal)
                                          , db.Parameter("@CashFee", weChatModel.cash_fee, DbType.Decimal)
                                          , db.Parameter("@AppID", weChatModel.appid, DbType.String)
                                          , db.Parameter("@BankType", weChatModel.bank_type, DbType.String)
                                          , db.Parameter("@BankName", bankName, DbType.String)
                                          , db.Parameter("@TimeEnd", time, DbType.DateTime2)
                                          , db.Parameter("@TradeStateDesc", weChatModel.attach, DbType.String)
                                          , db.Parameter("@CreatorID", model.CreatorID, DbType.String)
                                          , db.Parameter("@CreateTime", time, DbType.DateTime2)).ExecuteNonQuery();

                if (addWechatResultRes <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                db.CommitTransaction();
                return 1;
            }
        }

        public int AddAliTradePay(Alipay_trade_pay_response AliModel, DateTime time)
        {
            using (DbManager db = new DbManager())
            {
                string strSelOrderIDs = @" SELECT  OrderID
                                        FROM    [TBL_NETTRADE_ORDER] T1 WITH ( NOLOCK )
                                        WHERE   T1.NetTradeNo = @NetTradeNo ";

                List<int> orderIDList = db.SetCommand(strSelOrderIDs
                    , db.Parameter("@NetTradeNo", AliModel.out_trade_no, DbType.String)).ExecuteScalarList<int>();

                if (orderIDList == null || orderIDList.Count <= 0)
                {
                    return 0;
                }

                List<int> orderIDListWithout0Price = new List<int>();
                PaymentCheck_Model paymentCheckModel = new PaymentCheck_Model();
                int canPayRes = Order_DAL.Instance.CanOrderCanPay(orderIDList, out orderIDListWithout0Price, out paymentCheckModel);
                //if (canPayRes != 1)
                //{
                //    return canPayRes;
                //}

                #region 根据NetTradeNo获取数据
                string strSelTradeControlSql = @" SELECT  T1.CompanyID ,
                                                        T1.BranchID ,
                                                        T1.NetTradeNo ,
                                                        T1.NetActionType ,
                                                        T1.NetTradeVendor ,
                                                        T1.NetTradeActionMode ,
                                                        ProductName ,
                                                        NetTradeAmount ,
                                                        PointAmount ,
                                                        CouponAmount ,
                                                        Participants,
                                                        Remark ,
                                                        CreatorID 
                                                FROM    [TBL_NETTRADE_CONTROL] T1
                                                WHERE   T1.NetTradeNo = @NetTradeNo ";

                NetTrade_Control_Model model = db.SetCommand(strSelTradeControlSql,
                            db.Parameter("@NetTradeNo", AliModel.out_trade_no, DbType.String)).ExecuteObject<NetTrade_Control_Model>();

                if (model == null)
                {
                    return 0;
                }

                #region 获取业绩分享人
                List<Slave_Model> Slavers = new List<Slave_Model>();
                if (!string.IsNullOrEmpty(model.Participants))
                {
                    string[] strSlavID = model.Participants.Split(new string[] { "|" }, StringSplitOptions.RemoveEmptyEntries);
                    if (strSlavID.Length > 0)
                    {
                        for (int i = 0; i < strSlavID.Length; i++)
                        {
                            Slave_Model slaver = new Slave_Model();
                            string[] slaverTemp = strSlavID[i].Split(new string[] { "," }, StringSplitOptions.RemoveEmptyEntries);
                            if (slaverTemp.Length > 0)
                            {
                                slaver.SlaveID = StringUtils.GetDbInt(slaverTemp[0]);
                                slaver.ProfitPct = StringUtils.GetDbDecimal(slaverTemp[1]);
                                Slavers.Add(slaver);
                            }
                        }
                    }
                }
                #endregion

                #endregion

                #region 权限设置
                PaymentBranchRole paymentBranchRole = new PaymentBranchRole();
                paymentBranchRole.IsCustomerConfirm = true;
                paymentBranchRole.IsAccountEcardPay = false;
                paymentBranchRole.IsPartPay = false;
                paymentBranchRole.IsUseRate = 3;

                string strSqlCommand = @"select IsPay as IsAccountEcardPay,IsConfirmed as IsCustomerConfirm,IsPartPay,IsUseRate from [BRANCH] 
                                                where BRANCH.ID = @BranchID ";

                paymentBranchRole = db.SetCommand(strSqlCommand,
                                                db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteObject<PaymentBranchRole>();

                if (paymentBranchRole == null)
                {
                    return 0;
                }
                #endregion

                db.BeginTransaction();

                #region 插入PayMent表
                string strSqlPayAdd = @"insert into PAYMENT(CompanyID,OrderNumber,TotalPrice,CreatorID,CreateTime,Remark,PaymentTime,LevelID,Type,Status,BranchID,ClientType,IsUseRate) 
                                              values (@CompanyID,@OrderNumber,@TotalPrice,@CreatorID,@CreateTime,@Remark,@PaymentTime,@LevelID,@Type,@Status,@BranchID,@ClientType,@IsUseRate);select @@IDENTITY";
                int paymentID = db.SetCommand(strSqlPayAdd
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@OrderNumber", orderIDList.Count, DbType.Int32)
                            , db.Parameter("@TotalPrice", StringUtils.GetDbDecimal(AliModel.total_amount), DbType.Decimal)
                            , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                            , db.Parameter("@CreateTime", time, DbType.DateTime)
                            , db.Parameter("@Remark", model.Remark, DbType.String)
                            , db.Parameter("@PaymentTime", time, DbType.DateTime)
                            , db.Parameter("@LevelID", DBNull.Value, DbType.Int32)
                            , db.Parameter("@Type", 1, DbType.Int32)//1：支付 2：退款
                            , db.Parameter("@Status", 2, DbType.Int32)//1：无效 2：执行 3：撤销
                            , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                            , db.Parameter("@ClientType", 1, DbType.Int32)
                            , db.Parameter("@IsUseRate", paymentBranchRole.IsUseRate, DbType.Int32)).ExecuteScalar<int>();

                if (paymentID <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                #region 插入业绩分享人
                if (paymentID >= 0 && Slavers != null && Slavers.Count > 0)
                {
                    foreach (Slave_Model item in Slavers)
                    {
                        string strAddProfitSql = @" INSERT	INTO TBL_PROFIT( MasterID ,SlaveID ,Type ,ProfitPct ,Available ,CreateTime ,CreatorID) 
                                                VALUES (@MasterID ,@SlaveID ,@Type ,@ProfitPct ,@Available ,@CreateTime ,@CreatorID)";
                        int addProfitres = db.SetCommand(strAddProfitSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@MasterID", paymentID, DbType.Int64)
                                , db.Parameter("@SlaveID", item.SlaveID, DbType.Int32)
                                , db.Parameter("@Type", 2, DbType.Int32)
                                , db.Parameter("@ProfitPct", item.ProfitPct, DbType.Decimal)
                                , db.Parameter("@Available", true, DbType.Boolean)
                                , db.Parameter("@CreateTime", time, DbType.DateTime2)
                                , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)).ExecuteNonQuery();

                        if (addProfitres <= 0)
                        {
                            db.RollbackTransaction();
                            //LogUtil.Log("插入业绩表出错", "PaymentID:" + paymentID + "插入业绩表出错。");
                            return 0;
                        }
                    }
                }
                #endregion

                #region 插入PaymentDetail表
                int paymentDetailID = 0;
                if (StringUtils.GetDbDecimal(AliModel.total_amount) > 0)//排除传过来为0的记录
                {
                    string strSqlDetailAdd = @"insert into PAYMENT_DETAIL(CompanyID,PaymentID,PaymentMode,PaymentAmount,CreatorID,CreateTime,UserCardNo,CardPaidAmount,ProfitRate) 
                                                       values (@CompanyID,@PaymentID,@PaymentMode,@PaymentAmount,@CreatorID,@CreateTime,@UserCardNo,@CardPaidAmount,@ProfitRate);select @@IDENTITY";

                    paymentDetailID = db.SetCommand(strSqlDetailAdd
                                     , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                     , db.Parameter("@PaymentID", paymentID, DbType.Int32)
                                     , db.Parameter("@PaymentMode", 9, DbType.Int32)//0:现金、1:储值卡、2:银行卡。3:其他 4:免支付 5：过去支付 6:积分 7：现金券 8：微信第三方支付 9:支付宝第三方支付
                                     , db.Parameter("@PaymentAmount", StringUtils.GetDbDecimal(AliModel.total_amount), DbType.Decimal)
                                     , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                     , db.Parameter("@CreateTime", time, DbType.DateTime)
                                     , db.Parameter("@UserCardNo", "", DbType.String)
                                     , db.Parameter("@CardPaidAmount", StringUtils.GetDbDecimal(AliModel.total_amount), DbType.Decimal)
                                     , db.Parameter("@ProfitRate", 1, DbType.Decimal)).ExecuteScalar<int>();

                    if (paymentDetailID <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    string strSelCompanyComissionCalcSql = " SELECT [ComissionCalc] FROM COMPANY WHERE ID=@CompanyID ";
                    bool isComissionCalc = db.SetCommand(strSelCompanyComissionCalcSql
                                         , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<bool>();

                    if (isComissionCalc)
                    {
                        #region 计算销售业绩
                        foreach (int orderID in orderIDListWithout0Price)
                        {
                            #region 取出Product基本数据
                            string strSelProductSql = @" SELECT CASE T1.ProductType
                                                                          WHEN 0 THEN T2.ServiceCode
                                                                          ELSE T3.CommodityCode
                                                                        END AS ProductCode ,
                                                                        T1.ProductType,T1.TotalSalePrice 
                                                                 FROM   [ORDER] T1 WITH ( NOLOCK )
                                                                        LEFT JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.ID = T2.OrderID
                                                                        LEFT JOIN [TBL_ORDER_COMMODITY] T3 WITH ( NOLOCK ) ON T1.ID = T3.OrderID
                                                                 WHERE  T1.CompanyID = @CompanyID
                                                                        AND T1.ID = @OrderID; ";
                            DataTable dt = db.SetCommand(strSelProductSql
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteDataTable();

                            if (dt == null || dt.Rows.Count < 1)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            int productType = StringUtils.GetDbInt(dt.Rows[0]["ProductType"]);
                            long productCode = StringUtils.GetDbLong(dt.Rows[0]["ProductCode"]);
                            decimal totalSalePrice = StringUtils.GetDbDecimal(dt.Rows[0]["TotalSalePrice"]);
                            #endregion

                            #region 取出TBL_PRODUCT_COMMISSION_RULE数据
                            string strSelProductCommissionRuleSql = @" SELECT ProductType ,
                                                                                        ProductCode ,
                                                                                        ProfitPct ,
                                                                                        ECardSACommType ,
                                                                                        ECardSACommValue ,
                                                                                        NECardSACommType ,
                                                                                        NECardSACommValue
                                                                                 FROM   TBL_PRODUCT_COMMISSION_RULE
                                                                                 WHERE  CompanyID = @CompanyID
                                                                                        AND ProductType = @ProductType
                                                                                        AND ProductCode = @ProductCode ";

                            Product_Commission_Rule_Model ProductRuleModel = db.SetCommand(strSelProductCommissionRuleSql
                                                               , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                               , db.Parameter("@ProductType", productType, DbType.Int32)
                                                               , db.Parameter("@ProductCode", productCode)).ExecuteObject<Product_Commission_Rule_Model>();
                            #endregion

                            if (ProductRuleModel != null && ProductRuleModel.ProductCode > 0)
                            {
                                decimal Income = 0; ;
                                if (orderIDList.Count > 1)
                                {
                                    Income = (totalSalePrice * 1);
                                }
                                else
                                {
                                    Income = (StringUtils.GetDbDecimal(AliModel.total_amount) * 1);
                                }

                                decimal Profit = Income * ProductRuleModel.ProfitPct;

                                string strAddProfitDetailSql = @" INSERT INTO TBL_PROFIT_COMMISSION_DETAIL ( CompanyID ,BranchID ,SourceType ,SourceID ,SubSourceID ,Income ,ProfitPct ,Profit ,CommType ,CommValue ,AccountID ,AccountProfitPct ,AccountProfit ,AccountComm ,CommFlag ,CreatorID ,CreateTime ) 
                                                                    VALUES ( @CompanyID ,@BranchID ,@SourceType ,@SourceID ,@SubSourceID ,@Income ,@ProfitPct ,@Profit ,@CommType ,@CommValue ,@AccountID ,@AccountProfitPct ,@AccountProfit ,@AccountComm ,@CommFlag ,@CreatorID ,@CreateTime ) ";

                                if (paymentID >= 0 && Slavers != null && Slavers.Count > 0)
                                {
                                    #region 有业绩分享人
                                    foreach (Slave_Model slaveItem in Slavers)
                                    {
                                        #region 有业绩分享人
                                        //员工业绩(=实际业绩 x 员工业绩计算比例)
                                        decimal AccountProfit = Profit * slaveItem.ProfitPct;
                                        //1:按比例 2:固定值
                                        decimal AccountComm = 0;
                                        if (orderIDList.Count > 1)
                                        {
                                            AccountComm = Math.Round((ProductRuleModel.NECardSACommValue * 1 * slaveItem.ProfitPct), 2, MidpointRounding.AwayFromZero);
                                        }
                                        else
                                        {
                                            AccountComm = Math.Round(ProductRuleModel.NECardSACommValue * (StringUtils.GetDbDecimal(AliModel.total_amount) / totalSalePrice) * slaveItem.ProfitPct, 2, MidpointRounding.AwayFromZero);
                                        }

                                        if (ProductRuleModel.NECardSACommType == 1)
                                        {
                                            AccountComm = AccountProfit * ProductRuleModel.NECardSACommValue;
                                        }

                                        int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                            , db.Parameter("@SourceType", 1, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                            , db.Parameter("@SourceID", paymentDetailID, DbType.Int64)
                                            , db.Parameter("@SubSourceID", orderID, DbType.Int64)
                                            , db.Parameter("@Income", Income, DbType.Decimal)//收入 充值时，为TBL_MONEY_BALANCE的Amount
                                            , db.Parameter("@ProfitPct", ProductRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                            , db.Parameter("@Profit", Profit, DbType.Decimal)//实际业绩
                                            , db.Parameter("@CommType", ProductRuleModel.NECardSACommType, DbType.Int32)//该业绩的提成方式
                                            , db.Parameter("@CommValue", ProductRuleModel.NECardSACommValue, DbType.Decimal)//该业绩的提成数值
                                            , db.Parameter("@AccountID", slaveItem.SlaveID, DbType.Int32)//获得该业绩的员工ID
                                            , db.Parameter("@AccountProfitPct", slaveItem.ProfitPct, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                            , db.Parameter("@AccountProfit", AccountProfit, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                            , db.Parameter("@AccountComm", AccountComm, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
                                            , db.Parameter("@CommFlag", DBNull.Value, DbType.Int32)//1：首充 2：指定 3：E账户
                                            , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                            , db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                                        if (addProfitDetailRes != 1)
                                        {
                                            db.RollbackTransaction();
                                            return 0;
                                        }
                                        #endregion
                                    }
                                    #endregion
                                }
                                else
                                {
                                    #region 没有业绩分享人
                                    int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                            , db.Parameter("@SourceType", 1, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                            , db.Parameter("@SourceID", paymentDetailID, DbType.Int64)
                                            , db.Parameter("@SubSourceID", orderID, DbType.Int64)
                                            , db.Parameter("@Income", Income, DbType.Decimal)//收入 充值时，为TBL_MONEY_BALANCE的Amount
                                            , db.Parameter("@ProfitPct", ProductRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                            , db.Parameter("@Profit", Profit, DbType.Decimal)//实际业绩
                                            , db.Parameter("@CommType", ProductRuleModel.NECardSACommType, DbType.Int32)//该业绩的提成方式
                                            , db.Parameter("@CommValue", ProductRuleModel.NECardSACommValue, DbType.Decimal)//该业绩的提成数值
                                            , db.Parameter("@AccountID", DBNull.Value, DbType.Int32)//获得该业绩的员工ID
                                            , db.Parameter("@AccountProfitPct", DBNull.Value, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                            , db.Parameter("@AccountProfit", DBNull.Value, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                            , db.Parameter("@AccountComm", DBNull.Value, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
                                            , db.Parameter("@CommFlag", DBNull.Value, DbType.Int32)//1：首充 2：指定 3：E账户
                                            , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                            , db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                                    if (addProfitDetailRes != 1)
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
                }

                #endregion

                #region 抽取专属顾问数据
                GetOrderDetail_Model orderModel = new GetOrderDetail_Model();

                string strSelOrderInfoSql = @" SELECT  T1.AccountID
                                                            FROM    RELATIONSHIP T1 WITH ( NOLOCK )
                                                            WHERE   CustomerID = @CustomerID
                                                                    AND T1.Type = 1 
                                                                    AND T1.Available = 1
                                                                    AND T1.BranchID = @BranchID";

                int ResponsiblePersonID = db.SetCommand(strSelOrderInfoSql
                    , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteScalar<int>();
                #endregion

                foreach (int orderID in orderIDListWithout0Price)
                {
                    #region 插入OrderPayment关系表
                    string strSqlOrderPayAdd = @"insert into TBL_OrderPayment_RelationShip(OrderID,PaymentID) 
                                                                values (@OrderID,@PaymentID);select @@IDENTITY";
                    int orderPaymentRes = db.SetCommand(strSqlOrderPayAdd
                                          , db.Parameter("@OrderID", orderID, DbType.Int32)
                                          , db.Parameter("@PaymentID", paymentID, DbType.Int32)
                        //db.Parameter("@ResponsiblePersonID", responsiblePersonID, DbType.Int32),
                        //db.Parameter("@SalesID", salesID, DbType.Int32)
                                          ).ExecuteNonQuery();

                    if (orderPaymentRes <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    #endregion

                    #region 支付状态判断
                    decimal unpaidPrice = 0;
                    int paymentStatus = 1;
                    if (orderIDListWithout0Price.Count == 1 && paymentBranchRole.IsPartPay)
                    {
                        //可以分期支付 查询未支付金额
                        string strSqlSelectUnpaidPrice = @"SELECT UnPaidPrice FROM  [ORDER] WHERE ID=@OrderID";
                        decimal orderUnpaidPrice = db.SetCommand(strSqlSelectUnpaidPrice, db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteScalar<decimal>();
                        //if (orderUnpaidPrice <= 0 || orderUnpaidPrice < weChatModel.cash_fee)
                        //{
                        //    return 0;
                        //}
                        unpaidPrice = orderUnpaidPrice - StringUtils.GetDbDecimal(AliModel.total_amount);
                        if (unpaidPrice <= 0)
                        {
                            paymentStatus = 3; // 完全支付
                        }
                        else
                        {
                            paymentStatus = 2; // 部分支付
                        }
                    }
                    else
                    {
                        unpaidPrice = 0;
                        paymentStatus = 3;
                    }
                    #endregion

                    #region 更新订单状态和PaymentID
                    string strSqlOrderUpt = @"update [ORDER] set UnPaidPrice=@UnPaidPrice, PaymentStatus=@PaymentStatus,UpdaterID = @UpdaterID, UpdateTime = @UpdateTime where ID =@OrderID";

                    int orderuptRes = db.SetCommand(strSqlOrderUpt,
                        db.Parameter("@UnPaidPrice", unpaidPrice, DbType.Decimal),// 未支付金额
                        db.Parameter("@PaymentStatus", paymentStatus, DbType.Int32),// 1:未支付 2:部分支付 3:完全支付
                        db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32),
                        db.Parameter("@UpdateTime", time, DbType.DateTime),
                        db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteNonQuery();

                    if (orderuptRes <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    #endregion
                }

                #region 赠送
                if (model.PointAmount > 0 || model.CouponAmount > 0)
                {
                    #region 插入CUSTOMER_BALANCE
                    string strAddCustomerBalance = @" INSERT [TBL_CUSTOMER_BALANCE]	( CompanyID ,BranchID ,UserID ,ChangeType ,TargetAccount ,PaymentID ,Remark ,CreatorID ,CreateTime) 
                                VALUES(@CompanyID ,@BranchID ,@UserID ,@ChangeType ,@TargetAccount ,@PaymentID ,@Remark ,@CreatorID ,@CreateTime);select @@IDENTITY";
                    int customerBalanceID = db.SetCommand(strAddCustomerBalance,
                                db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                db.Parameter("@UserID", paymentCheckModel.CustomerID, DbType.Int32),
                                db.Parameter("@ChangeType", 1, DbType.Int32),//1:账户消费、2:账户消费撤销、3：账户充值、4：账户充值撤销、5：账户直扣、6：账户直扣撤销(9:退款 也属于账户直扣)
                                db.Parameter("@TargetAccount", 0, DbType.Int32),//目标账户：1:储值卡、2:积分、3:现金券  账户消费和消费撤销时，设默认值0
                        //db.Parameter("@ResponsiblePersonID", model.CreatorID, DbType.Int32),
                                db.Parameter("@PaymentID", paymentID, DbType.Int32),
                                db.Parameter("@Remark", "", DbType.String),
                                db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteScalar<int>();

                    if (customerBalanceID <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    #endregion

                    if (model.PointAmount > 0)
                    {
                        #region 获取积分卡
                        string strSqlGetBalance = @"SELECT  T1.Balance ,T1.UserCardNo 
                                                    FROM    [TBL_CUSTOMER_CARD] T1 WITH ( NOLOCK )
                                                    INNER JOIN [MST_CARD] T2 WITH(NOLOCK) ON T1.CardID=T2.ID
                                                    WHERE   T1.CompanyID = @CompanyID
                                                            AND T1.UserID = @CustomerID
                                                            AND T2.CardTypeID=2";

                        DataTable dt = db.SetCommand(strSqlGetBalance
                                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                    , db.Parameter("@CustomerID", paymentCheckModel.CustomerID, DbType.Int32)).ExecuteDataTable();

                        if (dt == null || dt.Rows.Count <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        #region 插入pointBalance
                        string userCardNo = StringUtils.GetDbString(dt.Rows[0]["UserCardNo"]);
                        decimal balance = StringUtils.GetDbDecimal(dt.Rows[0]["Balance"]);

                        model.PointAmount = Math.Abs(model.PointAmount);
                        balance = balance + model.PointAmount;
                        if (!string.IsNullOrWhiteSpace(userCardNo))
                        {
                            string strAddPointBalance = @" INSERT INTO [TBL_POINT_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CreatorID ,CreateTime) 
                                VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CreatorID ,@CreateTime)";

                            int addres = db.SetCommand(strAddPointBalance
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                    , db.Parameter("@UserID", paymentCheckModel.CustomerID, DbType.Int32)
                                    , db.Parameter("@CustomerBalanceID", customerBalanceID, DbType.Int32)
                                    , db.Parameter("@ActionMode", 3, DbType.Int32)//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                    , db.Parameter("@DepositMode", 0, DbType.Int32)//1:充值、2:余额转入
                                    , db.Parameter("@Remark", "", DbType.String)
                                    , db.Parameter("@UserCardNo", userCardNo, DbType.String)
                                    , db.Parameter("@Amount", model.PointAmount, DbType.Decimal)
                                    , db.Parameter("@Balance", balance, DbType.Decimal)
                                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                    , db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                            if (addres <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                        }

                        #endregion

                        #region 修改CustomerCard中的Balance
                        string strUpdateCustomerCard = @" UPDATE [TBL_CUSTOMER_CARD] SET Balance=@Balance WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo";
                        int updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", balance, DbType.Decimal)
                                                             , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                             , db.Parameter("@UserID", paymentCheckModel.CustomerID, DbType.Int32)
                                                             , db.Parameter("@UserCardNo", userCardNo, DbType.String)).ExecuteNonQuery();

                        if (updateRes == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion
                    }

                    if (model.CouponAmount > 0)
                    {
                        #region 获取现金券卡
                        string strSqlGetBalance = @"SELECT  T1.Balance ,T1.UserCardNo 
                                                    FROM    [TBL_CUSTOMER_CARD] T1 WITH ( NOLOCK )
                                                    INNER JOIN [MST_CARD] T2 WITH(NOLOCK) ON T1.CardID=T2.ID
                                                    WHERE   T1.CompanyID = @CompanyID
                                                            AND T1.UserID = @CustomerID
                                                            AND T2.CardTypeID = 3";

                        DataTable dt = db.SetCommand(strSqlGetBalance
                                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                    , db.Parameter("@CustomerID", paymentCheckModel.CustomerID, DbType.Int32)).ExecuteDataTable();

                        if (dt == null || dt.Rows.Count <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        #region 插入TBL_COUPON_BALANCE
                        string userCardNo = StringUtils.GetDbString(dt.Rows[0]["UserCardNo"]);
                        decimal balance = StringUtils.GetDbDecimal(dt.Rows[0]["Balance"]);

                        model.CouponAmount = Math.Abs(model.CouponAmount);
                        balance = balance + model.CouponAmount;
                        if (!string.IsNullOrWhiteSpace(userCardNo))
                        {
                            string strAddCouponBalance = @" INSERT INTO [TBL_COUPON_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CouponType ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CouponType ,@CreatorID ,@CreateTime)";

                            int addres = db.SetCommand(strAddCouponBalance,
                                    db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                    db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                    db.Parameter("@UserID", paymentCheckModel.CustomerID, DbType.Int32),
                                    db.Parameter("@CustomerBalanceID", customerBalanceID, DbType.Int32),
                                    db.Parameter("@ActionMode", 3, DbType.Int32),// 1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                    db.Parameter("@DepositMode", 0, DbType.Int32),//1:充值、2:余额转入
                                    db.Parameter("@Remark", "", DbType.String),
                                    db.Parameter("@UserCardNo", userCardNo, DbType.String),
                                    db.Parameter("@Amount", model.CouponAmount, DbType.Decimal),
                                    db.Parameter("@Balance", balance, DbType.Decimal),
                                    db.Parameter("@CouponType", 0, DbType.Int32),
                                    db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                    db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                            if (addres <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                        }

                        #endregion

                        #region 修改CustomerCard中的Balance
                        string strUpdateCustomerCard = @" UPDATE [TBL_CUSTOMER_CARD] SET Balance=@Balance WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo";
                        int updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", balance, DbType.Decimal)
                                                             , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                             , db.Parameter("@UserID", paymentCheckModel.CustomerID, DbType.Int32)
                                                             , db.Parameter("@UserCardNo", userCardNo, DbType.String)).ExecuteNonQuery();

                        if (updateRes == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion
                    }
                }
                #endregion

                #region 美丽顾问/销售顾问
                string strAddConsultant = @" INSERT INTO [TBL_BUSINESS_CONSULTANT]( CompanyID ,BusinessType ,MasterID ,ConsultantType ,ConsultantID ,CreatorID ,CreateTime )
                                                    VALUES ( @CompanyID ,@BusinessType ,@MasterID ,@ConsultantType ,@ConsultantID ,@CreatorID ,@CreateTime )";

                #region 美丽顾问
                if (ResponsiblePersonID > 0)
                {
                    int addConsultantRes = db.SetCommand(strAddConsultant
                           , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                           , db.Parameter("@BusinessType", 2, DbType.Int32)//1：订单，2：支付，3：充值
                           , db.Parameter("@MasterID", paymentID, DbType.Int32)
                           , db.Parameter("@ConsultantType", 1, DbType.Int32)//1:美丽顾问 2:销售顾问
                           , db.Parameter("@ConsultantID", ResponsiblePersonID, DbType.Int32)
                           , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                           , db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                    if (addConsultantRes <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                }
                #endregion

                string advanced = WebAPI.DAL.Company_DAL.Instance.getAdvancedByCompanyID(model.CompanyID);
                if (advanced.Contains("|4|"))
                {
                    #region 销售顾问
                    string strSelSalesSql = @"SELECT  AccountID
                                            FROM    [RELATIONSHIP]
                                            WHERE   companyID = @CompanyID
                                                    AND BranchID = @BranchID
                                                    AND CustomerID = @CustomerID
                                                    AND Available = 1
                                                    AND Type = 2";

                    List<int> SalesPersonIDList = db.SetCommand(strSelSalesSql,
                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                            db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                            db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteScalarList<int>();

                    if (SalesPersonIDList != null || SalesPersonIDList.Count > 0)
                    {
                        foreach (int SalesPersonID in SalesPersonIDList)
                        {
                            int addConsultantRes = db.SetCommand(strAddConsultant
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@BusinessType", 3, DbType.Int32)//1：订单，2：支付，3：充值
                            , db.Parameter("@MasterID", paymentID, DbType.Int32)
                            , db.Parameter("@ConsultantType", 2, DbType.Int32)//1:美丽顾问 2:销售顾问
                            , db.Parameter("@ConsultantID", SalesPersonID, DbType.Int32)
                            , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                            , db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                            if (addConsultantRes <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                        }
                    }
                    #endregion
                }
                #endregion

                #region 插入TBL_NETTRADE_RELATION
                string strTradeRelationSql = @" INSERT INTO [TBL_NETTRADE_RELATION]( CompanyID ,NetTradeNo ,NetTradeType ,PaymentID ,PaymentDetailID ,CustomerBalanceID ,MoneyBalanceID ,CreatorID ,CreateTime ) 
                                                VALUES ( @CompanyID ,@NetTradeNo ,@NetTradeType ,@PaymentID ,@PaymentDetailID ,@CustomerBalanceID ,@MoneyBalanceID ,@CreatorID ,@CreateTime ) ";

                int addTradeRelationRes = db.SetCommand(strTradeRelationSql
                                          , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                          , db.Parameter("@NetTradeNo", AliModel.out_trade_no, DbType.String)
                                          , db.Parameter("@NetTradeType", 1, DbType.Int32)//1:消费 2:充值
                                          , db.Parameter("@PaymentID", paymentID, DbType.Int32)
                                          , db.Parameter("@PaymentDetailID", paymentDetailID, DbType.Int32)
                                          , db.Parameter("@CustomerBalanceID", 0, DbType.Int32)
                                          , db.Parameter("@MoneyBalanceID", 0, DbType.Int32)
                                          , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                          , db.Parameter("@CreateTime", time, DbType.DateTime2)).ExecuteNonQuery();

                if (addTradeRelationRes <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                #region 插入TBL_ALIPAY_RESULT

                string strSql = @" INSERT INTO dbo.TBL_ALIPAY_RESULT( CompanyID ,NetTradeNo ,TradeState ,Code ,Msg ,SubMsg ,TradeNo ,BuyerUserId ,BuyerLogonId ,TotalAmount ,ReceiptAmount ,InvoiceAmount ,BuyerPayAmount ,PointAmount ,SendPayDate ,FundBillList ,DiscountGoodsDetail ,CreatorID ,CreateTime ) 
VALUES (@CompanyID ,@NetTradeNo ,@TradeState ,@Code ,@Msg ,@SubMsg ,@TradeNo ,@BuyerUserId ,@BuyerLogonId ,@TotalAmount ,@ReceiptAmount ,@InvoiceAmount ,@BuyerPayAmount ,@PointAmount ,@SendPayDate ,@FundBillList ,@DiscountGoodsDetail ,@CreatorID ,@CreateTime)";

                object strFundBillList = DBNull.Value;
                if (!string.IsNullOrEmpty(AliModel.strFundBillList))
                {
                    strFundBillList = AliModel.strFundBillList;
                }

                object objSendPayDate = DBNull.Value;
                if (!string.IsNullOrEmpty(AliModel.send_pay_date))
                {
                    objSendPayDate = AliModel.send_pay_date;
                }

                object objTradeState = DBNull.Value;
                if (!string.IsNullOrEmpty(AliModel.trade_status))
                {
                    objTradeState = AliModel.trade_status;
                }
                else if (AliModel.code == "10000" && AliModel.msg.ToUpper() == "SUCCESS")
                {
                    objTradeState = "TRADE_SUCCESS";
                }

                object objDiscountGoodsDetail = DBNull.Value;
                if (!string.IsNullOrEmpty(AliModel.strDiscountGoodsDetail))
                {
                    objDiscountGoodsDetail = AliModel.strDiscountGoodsDetail;
                }

                int res = db.SetCommand(strSql
                                          , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                          , db.Parameter("@NetTradeNo", AliModel.out_trade_no, DbType.String)
                                          , db.Parameter("@TradeState", objTradeState, DbType.String)
                                          , db.Parameter("@Code", AliModel.code, DbType.String)
                                          , db.Parameter("@Msg", AliModel.msg, DbType.String)
                                          , db.Parameter("@SubMsg", AliModel.sub_desc, DbType.String)
                                          , db.Parameter("@TradeNo", AliModel.trade_no, DbType.String)
                                          , db.Parameter("@BuyerUserId", AliModel.buyer_user_id, DbType.String)
                                          , db.Parameter("@BuyerLogonId", AliModel.buyer_logon_id, DbType.String)
                                          , db.Parameter("@TotalAmount", StringUtils.GetDbDecimal(AliModel.total_amount) * 100, DbType.Int32)
                                          , db.Parameter("@ReceiptAmount", StringUtils.GetDbDecimal(AliModel.receipt_amount) * 100, DbType.Int32)
                                          , db.Parameter("@InvoiceAmount", StringUtils.GetDbDecimal(AliModel.invoice_amount) * 100, DbType.Int32)
                                          , db.Parameter("@BuyerPayAmount", StringUtils.GetDbDecimal(AliModel.buyer_pay_amount) * 100, DbType.Int32)
                                          , db.Parameter("@PointAmount", StringUtils.GetDbDecimal(AliModel.point_amount) * 100, DbType.Int32)
                                          , db.Parameter("@SendPayDate", objSendPayDate, DbType.DateTime2)
                                          , db.Parameter("@FundBillList", strFundBillList, DbType.String)
                                          , db.Parameter("@DiscountGoodsDetail", DBNull.Value, DbType.String)
                                          , db.Parameter("@CreatorID", model.CreatorID, DbType.String)
                                          , db.Parameter("@CreateTime", time, DbType.DateTime2)).ExecuteNonQuery();

                if (res <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                db.CommitTransaction();
                return 1;
            }
        }

        public WeChatPayResault_Model GetWeChatPayResault(string netTradeNo, int companyID = 0)
        {
            using (DbManager db = new DbManager())
            {
                WeChatPayResault_Model model = new WeChatPayResault_Model();
                string strSql = @" SELECT  T1.NetTradeNo ,
                                           T1.ChangeType ,
                                            CASE ISNULL(T2.CashFee, 0)
                                              WHEN 0 THEN T1.NetTradeAmount
                                              ELSE T2.CashFee /100
                                            END AS CashFee ,
                                            T1.PointAmount ,
                                            T1.CouponAmount ,
                                            T1.ProductName ,
                                            ISNULL(T2.CreateTime, T1.CreateTime) AS CreateTime ,
                                            T2.BankName ,
                                            T2.TransactionID ,
                                            T2.TradeState ,
                                            T2.ResultCode ,
                                            T2.ErrCode ,
                                            T2.ErrCodeDes ,
                                            T2.TradeState , 
                                            CASE T2.TradeState
                                                      WHEN 'SUCCESS' THEN '支付成功'
                                                      WHEN 'CLOSED' THEN '已关闭'
                                                      WHEN 'REVOKED' THEN '已撤销'
                                                      WHEN 'PAYERROR' THEN '支付失败'
                                                      ELSE T2.TradeState
                                                    END AS DisplayResult 
                                    FROM    [TBL_NETTRADE_CONTROL] T1 WITH ( NOLOCK )
                                            LEFT JOIN [TBL_WEIXINPAY_RESULT] T2 WITH ( NOLOCK ) ON T1.NetTradeNo = T2.NetTradeNo
                                    WHERE   T1.NetTradeNo = @NetTradeNo ";

                if (companyID > 0)
                {
                    strSql += " AND T1.CompanyID = @CompanyID ";
                }

                model = db.SetCommand(strSql
                    , db.Parameter("@NetTradeNo", netTradeNo, DbType.String)
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteObject<WeChatPayResault_Model>();

                return model;
            }
        }

        public AliPayResault_Model GetAliPayResault(string netTradeNo, int companyID = 0)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT  T1.NetTradeNo ,
                                        T1.ChangeType ,
                                        CASE ISNULL(T2.TotalAmount, 0)
                                            WHEN 0 THEN T1.NetTradeAmount
                                            ELSE CAST(CAST(T2.TotalAmount AS DECIMAL) / 100 AS DECIMAL(17, 2))
                                        END AS TotalAmount ,
                                        CASE ISNULL(T2.ReceiptAmount, 0)
                                            WHEN 0 THEN 0
                                            ELSE CAST(CAST(T2.ReceiptAmount AS DECIMAL) / 100 AS DECIMAL(17, 2))
                                        END AS ReceiptAmount ,
                                        CASE ISNULL(T2.InvoiceAmount, 0)
                                            WHEN 0 THEN 0
                                            ELSE CAST(CAST(T2.InvoiceAmount AS DECIMAL) / 100 AS DECIMAL(17, 2))
                                        END AS InvoiceAmount ,
                                        CASE ISNULL(T2.BuyerPayAmount, 0)
                                            WHEN 0 THEN 0
                                            ELSE CAST(CAST(T2.BuyerPayAmount AS DECIMAL) / 100 AS DECIMAL(17, 2))
                                        END AS BuyerPayAmount ,
                                        CASE ISNULL(T2.PointAmount, 0)
                                            WHEN 0 THEN 0
                                            ELSE CAST(CAST(T2.PointAmount AS DECIMAL) / 100 AS DECIMAL(17, 2))
                                        END AS BuyerPayAmount ,
                                        T1.PointAmount ,
                                        T1.CouponAmount ,
                                        T1.ProductName ,
                                        ISNULL(T2.CreateTime, T1.CreateTime) AS CreateTime ,
                                        T2.TradeNo ,
                                        T2.TradeState ,
                                        T2.Code ,
                                        T2.Msg ,
                                        T2.SubMsg ,
                                        CASE T2.TradeState
                                            WHEN 'WAIT_BUYER_PAY' THEN '交易创建，等待买家付款'
                                            WHEN 'TRADE_CLOSED' THEN '未付款交易超时关闭，或支付完成后全额退款'
                                            WHEN 'TRADE_SUCCESS' THEN '交易支付成功'
                                            WHEN 'TRADE_FINISHED' THEN '交易结束，不可退款'
                                            ELSE T2.TradeState
                                        END AS DisplayResult
                                FROM    [TBL_NETTRADE_CONTROL] T1 WITH ( NOLOCK )
                                        LEFT JOIN [TBL_ALIPAY_RESULT] T2 WITH ( NOLOCK ) ON T1.NetTradeNo = T2.NetTradeNo
                                WHERE   T1.NetTradeNo = @NetTradeNo ";

                if (companyID > 0)
                {
                    strSql += " AND T1.CompanyID = @CompanyID ";
                }

                AliPayResault_Model model = db.SetCommand(strSql
                    , db.Parameter("@NetTradeNo", netTradeNo, DbType.String)
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteObject<AliPayResault_Model>();
                return model;
            }
        }

        public List<WeChatPayResault_Model> GetWeChatPayResaultByID(int companyID, string netTradeNo = "", int orderID = 0, int customerID = 0, string userCardNo = "")
        {
            using (DbManager db = new DbManager())
            {
                List<WeChatPayResault_Model> list = new List<WeChatPayResault_Model>();
                string strSql = @"SELECT  T1.NetTradeNo ,
                                            CASE ISNULL(T2.CashFee, 0)
                                              WHEN 0 THEN T1.NetTradeAmount
                                              ELSE T2.CashFee / 100
                                            END AS CashFee ,
                                            CAST(CAST(T4.TotalAmount AS DECIMAL) / 100 AS DECIMAL(17,2))  AS TotalAmount,
                                            T1.PointAmount ,
                                            T1.CouponAmount ,
                                            T1.ProductName ,
                                            T1.ChangeType ,
                                            T1.NetTradeVendor ,
                                            CASE ChangeType
                                              WHEN 1 THEN '消费'
                                              WHEN 2 THEN '消费撤销'
                                              WHEN 3 THEN '账户充值'
                                              ELSE '充值撤销'
                                            END AS ChangeTypeName ,
                                            CASE T1.NetTradeVendor WHEN 2 THEN ISNULL(T4.CreateTime, T1.CreateTime) ELSE ISNULL(T2.CreateTime, T1.CreateTime) END AS CreateTime ,
                                            CASE T1.NetTradeVendor WHEN 2 THEN T4.TradeNo ELSE T2.TransactionID END AS TransactionID ,
                                            CASE T1.NetTradeVendor WHEN 2 THEN ISNULL(T4.TradeState, '') ELSE ISNULL(T2.TradeState, '') END AS TradeState ,
                                            CASE T1.NetTradeVendor WHEN 2 THEN  '' ELSE ISNULL(T2.ResultCode, '') END AS ResultCode  
                                    FROM    [TBL_NETTRADE_CONTROL] T1 WITH ( NOLOCK )
                                            LEFT JOIN [TBL_WEIXINPAY_RESULT] T2 WITH ( NOLOCK ) ON T1.NetTradeNo = T2.NetTradeNo
                                            LEFT JOIN [TBL_NETTRADE_ORDER] T3 WITH ( NOLOCK ) ON T1.NetTradeNo = T3.NetTradeNo
                                            LEFT JOIN [TBL_ALIPAY_RESULT] T4 WITH ( NOLOCK ) ON T1.NetTradeNo = T4.NetTradeNo
                                    WHERE   T1.CompanyID = @CompanyID  ";

                if (!string.IsNullOrWhiteSpace(netTradeNo))
                {
                    strSql += " AND T1.NetTradeNo = @NetTradeNo ";
                }

                if (orderID > 0)
                {
                    strSql += @" AND T3.OrderID = @OrderID 
                                 AND ( T1.ChangeType = 1 OR ChangeType = 2 ) ";
                }

                if (customerID > 0)
                {
                    strSql += @" AND T1.CustomerID = @CustomerID AND ( T1.ChangeType = 3 OR ChangeType = 4 ) ";
                }

                if (!string.IsNullOrWhiteSpace(userCardNo))
                {
                    strSql += @" AND ( T1.ChangeType = 3 OR ChangeType = 4 ) AND T1.UserCardNo=@UserCardNo ";
                }

                strSql += " ORDER BY T1.CreateTime DESC ";
                list = db.SetCommand(strSql
                    , db.Parameter("@NetTradeNo", netTradeNo, DbType.String)
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@OrderID", orderID, DbType.Int32)
                    , db.Parameter("@CustomerID", customerID, DbType.Int32)
                    , db.Parameter("@UserCardNo", userCardNo, DbType.String)).ExecuteList<WeChatPayResault_Model>();

                return list;
            }
        }

        public bool DeleteNetTradeControl(string netTradeNo)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" DELETE  FROM TBL_NETTRADE_CONTROL WHERE   NetTradeNo = @NetTradeNo ";
                int res = db.SetCommand(strSql, db.Parameter("@NetTradeNo", netTradeNo, DbType.String)).ExecuteNonQuery();

                if (res <= 0)
                {
                    return false;
                }

                return true;
            }
        }

        #region WEB方法
        public ObjectResult<List<CancelPaymentMsgForWeb>> cancelPayment(int paymentID, int updaterID, int companyID, int branchID)
        {
            ObjectResult<List<CancelPaymentMsgForWeb>> res = new ObjectResult<List<CancelPaymentMsgForWeb>>();
            List<CancelPaymentMsgForWeb> list = new List<CancelPaymentMsgForWeb>();
            DateTime time = DateTime.Now.ToLocalTime();
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();

                    string strCheckStatusSql = @"SELECT ID,TotalPrice,Type,Status,  IsUseRate FROM PAYMENT WHERE ID=@PaymentID AND CompanyID=@CompanyID";
                    GetPaymentInfo_Model model = db.SetCommand(strCheckStatusSql, db.Parameter("@PaymentID", paymentID, DbType.Int32)
                                                                                , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteObject<GetPaymentInfo_Model>();

                    if (model == null)
                    {
                        res.Code = "0";
                        res.Message = "没有该支付信息";
                        res.Data = null;
                        return res;
                    }

                    if (model.TotalPrice == 0)
                    {
                        res.Code = "0";
                        res.Message = "免支付不能退款";
                        res.Data = null;
                        return res;

                    }

                    if (model.Type == 1 && (model.Status == 3 || model.Status == 5))
                    {
                        res.Code = "0";
                        res.Message = "已退款,不能取消";
                        res.Data = null;
                        return res;
                    }

                    if (model.Type == 2)
                    {
                        res.Code = "0";
                        res.Message = "退款明细不能取消";
                        res.Data = null;
                        return res;
                    }

                    #region 获取相关的Order
                    string strSelectOrderSql = @"SELECT T2.CustomerID ,T2.ID AS OrderID, T2.TotalSalePrice,T2.UnPaidPrice,T2.PaymentStatus,T3.ConsultantID  ResponsiblePersonID FROM [TBL_ORDERPAYMENT_RELATIONSHIP] T1 WITH(NOLOCK)
                                                LEFT JOIN [ORDER] T2 WITH(NOLOCK) ON T1.OrderID=T2.ID 
												LEFT JOIN [TBL_BUSINESS_CONSULTANT] T3 ON T1.OrderID = T3.MasterID AND T3.BusinessType = 1 AND T3.ConsultantType = 1
                                                 WHERE T1.PaymentID=@PaymentID";
                    List<GetPaymentOrderInfo_Model> orderList = db.SetCommand(strSelectOrderSql, db.Parameter("@PaymentID", paymentID, DbType.Int32)).ExecuteList<GetPaymentOrderInfo_Model>();
                    #endregion

                    if (orderList == null)
                    {
                        res.Code = "0";
                        res.Message = "支付信息错误";
                        res.Data = null;
                        return res;
                    }

                    foreach (GetPaymentOrderInfo_Model item in orderList)
                    {
                        string strSqlinsertHis = @"insert into HISTORY_ORDER select * from [ORDER] where ID = @ID ";
                        int inserthisrs = db.SetCommand(strSqlinsertHis, db.Parameter("@ID", item.OrderID, DbType.Int32)).ExecuteNonQuery();

                        if (inserthisrs <= 0)
                        {
                            db.RollbackTransaction();
                            res.Code = "0";
                            res.Message = "退款失败!";
                            res.Data = null;
                            return res;
                        }

                        if (item.PaymentStatus == 0)
                        {
                            db.RollbackTransaction();
                            res.Code = "0";
                            res.Message = "有未支付的订单,数据错误!";
                            res.Data = null;
                            return res;
                        }

                        decimal orderUnpaidAmount = 0;
                        int orderPaymentStatus = 1;
                        if (orderList.Count > 1)
                        {
                            //多笔订单一起支付 全部退
                            orderUnpaidAmount = item.TotalSalePrice;
                            orderPaymentStatus = 1;
                        }
                        else
                        {
                            if (model.TotalPrice + item.UnPaidPrice == item.TotalSalePrice)
                            {
                                //全部退
                                orderUnpaidAmount = item.TotalSalePrice;
                                orderPaymentStatus = 1;
                            }
                            else
                            {
                                //部分退
                                orderUnpaidAmount = item.UnPaidPrice + model.TotalPrice;
                                orderPaymentStatus = 2;
                            }
                        }

                        #region 更改订单
                        string strUpdateOrderSql = @"UPDATE  dbo.[ORDER]
                                                    SET     UnPaidPrice = @UnPaidPrice ,
                                                            PaymentStatus = @PaymentStatus ,
                                                            UpdaterID = @UpdaterID ,
                                                            UpdateTime = @UpdateTime
                                                    WHERE   ID = @OrderID ";
                        int rows = db.SetCommand(strUpdateOrderSql, db.Parameter("@UnPaidPrice", orderUnpaidAmount, DbType.Decimal)
                                                                   , db.Parameter("@PaymentStatus", orderPaymentStatus, DbType.Int32)
                                                                   , db.Parameter("@UpdaterID", updaterID, DbType.Int32)
                                                                   , db.Parameter("@UpdateTime", time, DbType.DateTime)
                                                                   , db.Parameter("@OrderID", item.OrderID, DbType.Int32)).ExecuteNonQuery();

                        if (rows != 1)
                        {
                            db.RollbackTransaction();
                            res.Code = "0";
                            res.Message = "退款失败!";
                            res.Data = null;
                            return res;
                        }
                        #endregion
                    }


                    #region 修改原来的Payment状态
                    string strSqlPaymentStatus = @"
                                                    UPDATE  dbo.PAYMENT
                                                    SET     Status =@Status,
                                                    UpdaterID = @UpdaterID,
                                                    UpdateTime =@UpdateTime
                                                    WHERE   ID = @PaymentID AND Type=1 AND (Status=2 or Status=4)";

                    int newStatus;
                    if (model.Status == 2)
                    {
                        newStatus = 3;
                    }
                    else if (model.Status == 4)
                    {
                        newStatus = 5;
                    }
                    else
                    {
                        newStatus = 1;
                    }
                    int rws = db.SetCommand(strSqlPaymentStatus, db.Parameter("@PaymentID", paymentID, DbType.Int32)
                        , db.Parameter("@Status", newStatus, DbType.Int32)
                         , db.Parameter("@UpdateTime", time, DbType.DateTime2)
                         , db.Parameter("@UpdaterID", updaterID, DbType.Int32)).ExecuteNonQuery();

                    if (rws != 1)
                    {
                        db.RollbackTransaction();
                        res.Code = "0";
                        res.Message = "退款失败!";
                        res.Data = null;
                        return res;
                    }
                    #endregion

                    #region 插入一条新的退款记录
                    string strInsertNewPayment = @"INSERT  INTO PAYMENT( CompanyID ,OrderNumber ,TotalPrice ,CreatorID ,CreateTime ,Remark ,PaymentTime ,LevelID ,Type ,Status ,TargetPaymentID ,BranchID,ClientType,IsUseRate)
                                                    SELECT  CompanyID ,OrderNumber ,TotalPrice,@CreatorID ,@CreateTime ,Remark ,@CreateTime ,LevelID ,2 ,@Status,@TargetPaymentID ,BranchID,3,IsUseRate
                                                    FROM    [PAYMENT]
                                                    WHERE   ID = @TargetPaymentID;select @@IDENTITY";

                    int addRes = db.SetCommand(strInsertNewPayment
                        , db.Parameter("@TargetPaymentID", paymentID, DbType.Int32)
                        , db.Parameter("@Status", 6, DbType.Int32)
                        , db.Parameter("@CreatorID", updaterID, DbType.Int32)
                        , db.Parameter("@CreateTime", time, DbType.DateTime2)).ExecuteScalar<int>();

                    if (addRes == 0)
                    {
                        db.RollbackTransaction();
                        res.Code = "0";
                        res.Message = "退款失败!";
                        res.Data = null;
                        return res;
                    }
                    #endregion

                    #region 插入新的PaymentID与Order关系表
                    foreach (GetPaymentOrderInfo_Model item in orderList)
                    {
                        string insertTBL_ORDERPAYMENT_RELATIONSHIP = @"INSERT INTO dbo.TBL_ORDERPAYMENT_RELATIONSHIP
                                                                        ( OrderID ,
                                                                          PaymentID 
                                                                        )
                                                                VALUES  ( @OrderID , 
                                                                          @PaymentID 
                                                                        )";
                        int insertTBL_ORDERPAYMENT_RELATIONSHIPRes = db.SetCommand(insertTBL_ORDERPAYMENT_RELATIONSHIP,
                                    db.Parameter("@OrderID", item.OrderID, DbType.Int32),
                                    db.Parameter("@PaymentID", addRes, DbType.Int32),
                                    db.Parameter("@ResponsiblePersonID", item.ResponsiblePersonID, DbType.Int32)
                                    ).ExecuteNonQuery();

                        if (insertTBL_ORDERPAYMENT_RELATIONSHIPRes <= 0)
                        {
                            db.RollbackTransaction();
                            res.Code = "0";
                            res.Message = "订单支付表插入失败!";
                            res.Data = null;
                            return res;
                        }



                    }
                    #endregion

                    #region 修改业绩参与人
                    string strSqlTBL_PROFIT = @"select SlaveID from TBL_PROFIT where MasterID =@PaymentID and Type = 2";
                    List<int> listSlaveID = db.SetCommand(strSqlTBL_PROFIT, db.Parameter("@PaymentID", paymentID, DbType.Int32)).ExecuteScalarList<int>();
                    if (listSlaveID != null && listSlaveID.Count > 0)
                    {
                        string strSqlInsertProfit = @" INSERT INTO [TBL_PROFIT]
                                                   (MasterID,SlaveID,Type,Available,CreateTime,CreatorID)
                                                    VALUES
                                                   (@MasterID,@SlaveID,@Type,@Available,@CreateTime,@CreatorID) ";
                        foreach (int itemSlaveID in listSlaveID)
                        {
                            int rows = db.SetCommand(strSqlInsertProfit
                                                , db.Parameter("@MasterID", addRes, DbType.Int32)
                                                , db.Parameter("@SlaveID", itemSlaveID, DbType.Int32)
                                                , db.Parameter("@Type", 2, DbType.Int32)
                                                , db.Parameter("@Available", true, DbType.Boolean)
                                                , db.Parameter("@CreatorID", updaterID, DbType.Int32)
                                                , db.Parameter("@CreateTime", time, DbType.DateTime2)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                res.Code = "0";
                                res.Message = "业绩参与人表插入失败!";
                                res.Data = null;
                                return res;
                            }
                        }
                    }

                    #endregion

                    #region 获取PaymentDetail
                    string strSelectSql = "SELECT ID ,CompanyID ,PaymentID ,PaymentMode ,PaymentAmount ,UserCardNo ,CardPaidAmount,ProfitRate FROM [PAYMENT_DETAIL] WHERE PaymentID=@PaymentID";
                    List<GetPaymentDetailInfo_Model> paymentDetailList = db.SetCommand(strSelectSql, db.Parameter("@PaymentID", paymentID, DbType.Int32)).ExecuteList<GetPaymentDetailInfo_Model>();
                    #endregion

                    if (paymentDetailList != null)
                    {
                        #region 插入退款详细记录
                        bool isNeedAddCustomerBalance = true;
                        int customerBalanceID = 0;
                        int oldBalanceID = 0;
                        int oldBranchID = 0;
                        int oldCompanyID = 0;


                        string strAddHis = @" INSERT INTO [HST_CUSTOMER_CARD] SELECT * FROM [TBL_CUSTOMER_CARD] WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo ";
                        string strUpdateCustomerCard = @" UPDATE [TBL_CUSTOMER_CARD] SET Balance=@Balance WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo";
                        foreach (GetPaymentDetailInfo_Model item in paymentDetailList)
                        {
                            #region 删除业绩分享
                            string strSqlCheck = @" select Count(*) from TBL_PROFIT_COMMISSION_DETAIL  WHERE   CompanyID = @CompanyID
                                                                        AND SourceID = @SourceID
                                                                        AND SourceType = @SourceType ";
                            int checkRows = db.SetCommand(strSqlCheck
                                                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                    , db.Parameter("@SourceID", item.ID, DbType.Int32)
                                                    , db.Parameter("@SourceType", 1, DbType.Int32)).ExecuteScalar<int>();
 
                            if (checkRows > 0)
                            {
                                string strUpdateComissionCalcsQL = @" UPDATE  TBL_PROFIT_COMMISSION_DETAIL
                                                                SET     RecordType = @RecordType ,UpdaterID = @UpdaterID ,UpdateTime = @UpdateTime 
                                                                WHERE   CompanyID = @CompanyID
                                                                        AND SourceID = @SourceID
                                                                        AND SourceType = @SourceType ";
                                int rows = db.SetCommand(strUpdateComissionCalcsQL
                                                        , db.Parameter("@RecordType", 2, DbType.Int32)
                                                        , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                        , db.Parameter("@SourceID", item.ID, DbType.Int32)
                                                        , db.Parameter("@SourceType", 1, DbType.Int32)
                                                        , db.Parameter("@UpdaterID", updaterID, DbType.Int32)
                                                        , db.Parameter("@UpdateTime", time, DbType.DateTime)).ExecuteNonQuery();

                                if (rows <= 0)
                                {
                                    db.RollbackTransaction();
                                    res.Code = "0";
                                    res.Message = "退款失败!";
                                    res.Data = null;
                                    return res;
                                }
                            }

                            #endregion

                            string strSqlDetailAdd = @"INSERT  INTO [PAYMENT_DETAIL]( CompanyID ,PaymentID ,PaymentMode ,PaymentAmount ,CreatorID ,CreateTime ,UserCardNo ,CardPaidAmount,ProfitRate) 
                                                       VALUES (@CompanyID ,@PaymentID ,@PaymentMode ,@PaymentAmount ,@CreatorID ,@CreateTime ,@UserCardNo ,@CardPaidAmount,@ProfitRate)";

                            int detailAddRes = db.SetCommand(strSqlDetailAdd
                                                        , db.Parameter("@CompanyID", item.CompanyID, DbType.Int32)
                                                        , db.Parameter("@PaymentID", addRes, DbType.Int32)
                                                        , db.Parameter("@PaymentMode", item.PaymentMode, DbType.Int32)
                                                        , db.Parameter("@PaymentAmount", item.PaymentAmount, DbType.Decimal)
                                                        , db.Parameter("@CreatorID", updaterID, DbType.Int32)
                                                        , db.Parameter("@CreateTime", time, DbType.DateTime)
                                                        , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)
                                                        , db.Parameter("@CardPaidAmount", item.CardPaidAmount, DbType.Decimal)
                                                        , db.Parameter("@ProfitRate", item.ProfitRate, DbType.Decimal)).ExecuteNonQuery();

                            if (detailAddRes <= 0)
                            {
                                db.RollbackTransaction();
                                res.Code = "0";
                                res.Message = "退款失败!";
                                res.Data = null;
                                return res;
                            }

                            string strSelOldBalanceId = @"SELECT  ID ,BranchID,CompanyID 
                                                                FROM    [TBL_CUSTOMER_BALANCE]
                                                                WHERE   PaymentID = @PaymentID";

                            DataTable customerBalanceDT = db.SetCommand(strSelOldBalanceId, db.Parameter("@PaymentID", paymentID, DbType.Int32)).ExecuteDataTable();
                            if (customerBalanceDT == null || customerBalanceDT.Rows.Count <= 0)
                            {

                            }
                            else
                            {

                                oldBalanceID = StringUtils.GetDbInt(customerBalanceDT.Rows[0]["ID"].ToString());
                                oldBranchID = StringUtils.GetDbInt(customerBalanceDT.Rows[0]["BranchID"].ToString());
                                oldCompanyID = StringUtils.GetDbInt(customerBalanceDT.Rows[0]["CompanyID"].ToString());


                                if (isNeedAddCustomerBalance)
                                {
                                    #region 插入CustomerBalance表

                                    string strAddCustomerBalance = @" INSERT [TBL_CUSTOMER_BALANCE]	( CompanyID ,BranchID ,UserID ,ChangeType ,TargetAccount ,PaymentID ,Remark ,RelatedID ,CreatorID ,CreateTime) 
                                                                    VALUES(@CompanyID ,@BranchID ,@UserID ,@ChangeType ,@TargetAccount  ,@PaymentID ,@Remark ,@RelatedID ,@CreatorID ,@CreateTime);select @@IDENTITY";
                                    customerBalanceID = db.SetCommand(strAddCustomerBalance
                                                , db.Parameter("@CompanyID", item.CompanyID, DbType.Int32)
                                                , db.Parameter("@BranchID", oldBranchID, DbType.Int32)
                                                , db.Parameter("@UserID", orderList[0].CustomerID, DbType.Int32)
                                                , db.Parameter("@ChangeType", 2, DbType.Int32)//分类：1:账户消费、2:账户消费撤销、3：账户充值、4：账户充值撤销、5：账户直扣、6：账户直扣撤销
                                                , db.Parameter("@TargetAccount", 0, DbType.Int32)
                                                , db.Parameter("@PaymentID", addRes, DbType.Int32)
                                                , db.Parameter("@RelatedID", oldBalanceID, DbType.Int32)
                                                , db.Parameter("@Remark", DBNull.Value, DbType.String)
                                                , db.Parameter("@CreatorID", updaterID, DbType.Int32)
                                                , db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteScalar<int>();

                                    if (customerBalanceID <= 0)
                                    {
                                        db.RollbackTransaction();
                                        res.Code = "0";
                                        res.Message = "退款失败!";
                                        res.Data = null;
                                        return res;
                                    }
                                    #endregion

                                    // 插入一条CustomerBalance后不插入第二条
                                    isNeedAddCustomerBalance = false;

                                }


                                #region 获取卡内余额
                                string strCardBalanceSql = @"SELECT BALANCE FROM [TBL_CUSTOMER_CARD] WHERE CompanyID=@CompanyID AND UserID=@CustomerID AND UserCardNo=@UserCardNo";
                                decimal cardBalance = db.SetCommand(strCardBalanceSql,
                                   db.Parameter("@CompanyID", companyID, DbType.Int32),
                                   db.Parameter("@CustomerID", orderList[0].CustomerID, DbType.Int32),
                                   db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteScalar<decimal>();
                                #endregion


                                //ActionMode 1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                //DepositMode 1:充值、2:余额转入
                                string strAddPointBalance = @" INSERT INTO [TBL_POINT_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CreatorID ,@CreateTime)";

                                //ActionMode 1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                //DepositMode 1:充值、2:余额转入
                                string strAddCouponBalance = @" INSERT INTO [TBL_COUPON_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CouponType ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CouponType ,@CreatorID ,@CreateTime)";

                                decimal totalPointAmount = -1;
                                decimal totalMoneyAmount = -1;
                                decimal totalCouponAmount = -1;
                                decimal pushBalance = 0;


                                if (item.PaymentMode == 1)
                                {
                                    totalMoneyAmount = cardBalance + Math.Abs(item.CardPaidAmount);
                                    #region 储值卡
                                    //ActionMode 1:消费支出、2:消费支出撤销、3:储值卡充值、4:储值卡充值撤销、5:储值卡直扣、6:储值卡直扣撤销、7:储值卡直充赠送、8:储值卡直充赠送撤销、9:储值卡退款、10:储值卡退款撤销
                                    //DepositMode 1:现金、2:银行卡、3:余额转入、4:其他
                                    string strAddMoneyBalance = @" INSERT INTO [TBL_MONEY_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CreatorID ,@CreateTime)";

                                    int addres = db.SetCommand(strAddMoneyBalance
                                               , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                               , db.Parameter("@BranchID", oldBranchID, DbType.Int32)
                                               , db.Parameter("@UserID", orderList[0].CustomerID, DbType.Int32)
                                               , db.Parameter("@CustomerBalanceID", customerBalanceID, DbType.Int32)
                                               , db.Parameter("@ActionMode", 2, DbType.Int32)//1:消费支出、2:消费支出撤销、3:储值卡充值、4:储值卡充值撤销、5:储值卡直扣、6:储值卡直扣撤销、7:储值卡直充赠送、8:储值卡直充赠送撤销、9:储值卡退款、10:储值卡退款撤销
                                               , db.Parameter("@DepositMode", 0, DbType.Int32)//1:现金、2:银行卡、3:余额转入、4:其他
                                               , db.Parameter("@Remark", DBNull.Value, DbType.String)
                                               , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)
                                               , db.Parameter("@Amount", item.CardPaidAmount, DbType.Decimal)
                                               , db.Parameter("@Balance", totalMoneyAmount, DbType.Decimal)
                                               , db.Parameter("@CreatorID", updaterID, DbType.Int32)
                                               , db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                                    if (addres <= 0)
                                    {
                                        db.RollbackTransaction();
                                        res.Code = "0";
                                        res.Message = "退款失败!";
                                        res.Data = null;
                                        return res;
                                    }

                                    int hisRows = db.SetCommand(strAddHis, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                                         , db.Parameter("@UserID", orderList[0].CustomerID, DbType.Int32)
                                                                         , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteNonQuery();

                                    if (hisRows == 0)
                                    {
                                        db.RollbackTransaction();
                                        res.Code = "0";
                                        res.Message = "退款失败!";
                                        res.Data = null;
                                        return res;
                                    }

                                    int updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", totalMoneyAmount, DbType.Decimal)
                                                                         , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                                         , db.Parameter("@UserID", orderList[0].CustomerID, DbType.Int32)
                                                                         , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteNonQuery();

                                    if (updateRes == 0)
                                    {
                                        db.RollbackTransaction();
                                        res.Code = "0";
                                        res.Message = "退款失败!";
                                        res.Data = null;
                                        return res;
                                    }



                                    #region PUSH
                                    string selectCustomerDevice = @"SELECT TOP 1 ISNULL(T3.DeviceID, '') AS DeviceID ,T1.Name AS CustomerName ,T3.DeviceType ,T2.Abbreviation AS CompanyName,ISNULL(T6.BalanceNotice, 0) AS Threshold ,T4.LoginMobile,T2.BalanceRemind ,T6.CardName ,T1.WeChatOpenID 
                                                    FROM    [CUSTOMER] T1 WITH ( NOLOCK )
                                                            LEFT JOIN [COMPANY] T2 WITH ( NOLOCK ) ON T1.CompanyID = T2.ID
                                                            LEFT JOIN [LOGIN] T3 WITH ( NOLOCK ) ON T1.UserID = T3.UserID
                                                            LEFT JOIN [USER] T4 WITH ( NOLOCK ) ON T4.ID = t1.UserID
                                                            LEFT JOIN [TBL_CUSTOMER_CARD] T5 WITH ( NOLOCK ) ON T5.UserID = T4.ID AND T5.UserCardNo=@userCardNo
                                                            LEFT JOIN [MST_CARD] T6 WITH(NOLOCK) ON T5.CardID=T6.ID
                                                    WHERE   T1.UserID = @CustomerID";
                                    PushOperation_Model pushmodel = db.SetCommand(selectCustomerDevice, db.Parameter("@CustomerID", orderList[0].CustomerID, DbType.Int32)
                                                                                                      , db.Parameter("@userCardNo", item.UserCardNo, DbType.String)).ExecuteObject<PushOperation_Model>();
                                    if (pushmodel != null)
                                    {

                                        if (pushmodel.BalanceRemind)
                                        {
                                            Task.Factory.StartNew(() =>
                                            {
                                                #region 微信push
                                                if (!string.IsNullOrWhiteSpace(pushmodel.WeChatOpenID))
                                                {
                                                    HS.Framework.Common.WeChat.WeChat we = new HS.Framework.Common.WeChat.WeChat();
                                                    string accessToken = we.GetWeChatToken(companyID);
                                                    if (!string.IsNullOrWhiteSpace(accessToken))
                                                    {
                                                        HS.Framework.Common.WeChat.Entity.MessageTemplate messageModel = new HS.Framework.Common.WeChat.Entity.MessageTemplate();
                                                        HS.Framework.Common.WeChat.WXCompanyInfoBase WXCompanyInfoBase = we.GetBaseInfo(companyID);
                                                        messageModel.template_id = WXCompanyInfoBase.AccountChangesTemplate;
                                                        messageModel.topcolor = "#000000";
                                                        messageModel.touser = pushmodel.WeChatOpenID;
                                                        messageModel.data = new HS.Framework.Common.WeChat.Entity.TemplateDetail()
                                                        {
                                                            first = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#FF0000", value = "您有一笔账户消费退款\n" },
                                                            keyword1 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = time.ToString("yyyy-MM-dd HH:mm") },
                                                            keyword2 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = pushmodel.CardName },
                                                            keyword3 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#FF0000", value = item.PaymentAmount.ToString("C2") },
                                                            remark = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = "余额：" + totalMoneyAmount.ToString("C2") + "\n\n您可以在账户交易明细中查看账户变动的详细内容。" }
                                                        };
                                                        we.TemplateMessageSend(messageModel, companyID, 1, accessToken);
                                                    }
                                                }
                                                #endregion

                                            });
                                        }
                                    }
                                    else
                                    {
                                        LogUtil.Log("余额变动push失败", orderList[0].CustomerID + "数据抽取失败");
                                    }
                                    #endregion
                                    #endregion
                                }
                                else if (item.PaymentMode == 6)
                                {
                                    totalPointAmount = cardBalance + Math.Abs(item.CardPaidAmount);

                                    #region 积分返还
                                    int addres = db.SetCommand(strAddPointBalance
                                               , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                               , db.Parameter("@BranchID", oldBranchID, DbType.Int32)
                                               , db.Parameter("@UserID", orderList[0].CustomerID, DbType.Int32)
                                               , db.Parameter("@CustomerBalanceID", customerBalanceID, DbType.Int32)
                                               , db.Parameter("@ActionMode", 2, DbType.Int32)//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                               , db.Parameter("@DepositMode", 0, DbType.Int32)//1:充值、2:余额转入
                                               , db.Parameter("@Remark", DBNull.Value, DbType.String)
                                               , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)
                                               , db.Parameter("@Amount", item.CardPaidAmount, DbType.Decimal)
                                               , db.Parameter("@Balance", totalPointAmount, DbType.Decimal)
                                               , db.Parameter("@CreatorID", updaterID, DbType.Int32)
                                               , db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                                    if (addres <= 0)
                                    {
                                        db.RollbackTransaction();
                                        res.Code = "0";
                                        res.Message = "退款失败!";
                                        res.Data = null;
                                        return res;
                                    }

                                    int hisRows = db.SetCommand(strAddHis, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                                         , db.Parameter("@UserID", orderList[0].CustomerID, DbType.Int32)
                                                                         , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteNonQuery();

                                    if (hisRows == 0)
                                    {
                                        db.RollbackTransaction();
                                        res.Code = "0";
                                        res.Message = "退款失败!";
                                        res.Data = null;
                                        return res;
                                    }

                                    int updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", totalPointAmount, DbType.Decimal)
                                                                         , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                                         , db.Parameter("@UserID", orderList[0].CustomerID, DbType.Int32)
                                                                         , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteNonQuery();

                                    if (updateRes == 0)
                                    {
                                        db.RollbackTransaction();
                                        res.Code = "0";
                                        res.Message = "退款失败!";
                                        res.Data = null;
                                        return res;
                                    }
                                    #endregion

                                }
                                else if (item.PaymentMode == 7)
                                {
                                    totalCouponAmount = cardBalance + Math.Abs(item.CardPaidAmount);
                                    #region 现金券

                                    int addres = db.SetCommand(strAddCouponBalance
                                               , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                               , db.Parameter("@BranchID", oldBranchID, DbType.Int32)
                                               , db.Parameter("@UserID", orderList[0].CustomerID, DbType.Int32)
                                               , db.Parameter("@CustomerBalanceID", customerBalanceID, DbType.Int32)
                                               , db.Parameter("@ActionMode", 2, DbType.Int32)//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                               , db.Parameter("@DepositMode", 0, DbType.Int32)//1:充值、2:余额转入
                                               , db.Parameter("@Remark", DBNull.Value, DbType.String)
                                               , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)
                                               , db.Parameter("@Amount", item.CardPaidAmount, DbType.Decimal)
                                               , db.Parameter("@Balance", totalCouponAmount, DbType.Decimal)
                                               , db.Parameter("@CouponType", 0, DbType.Int32)
                                               , db.Parameter("@CreatorID", updaterID, DbType.Int32)
                                               , db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                                    if (addres <= 0)
                                    {
                                        db.RollbackTransaction();
                                        res.Code = "0";
                                        res.Message = "退款失败!";
                                        res.Data = null;
                                        return res;
                                    }


                                    int hisRows = db.SetCommand(strAddHis, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                                         , db.Parameter("@UserID", orderList[0].CustomerID, DbType.Int32)
                                                                         , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteNonQuery();

                                    if (hisRows == 0)
                                    {
                                        db.RollbackTransaction();
                                        res.Code = "0";
                                        res.Message = "退款失败!";
                                        res.Data = null;
                                        return res;
                                    }

                                    int updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", totalCouponAmount, DbType.Decimal)
                                                                         , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                                         , db.Parameter("@UserID", orderList[0].CustomerID, DbType.Int32)
                                                                         , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteNonQuery();

                                    if (updateRes == 0)
                                    {
                                        db.RollbackTransaction();
                                        res.Code = "0";
                                        res.Message = "退款失败!";
                                        res.Data = null;
                                        return res;
                                    }

                                    #endregion
                                }


                            }
                        }
                        #endregion

                        #region 扣除积分赠送
                        string strSelGiveAmount = @"SELECT  Amount,UserCardNo 
                                                                FROM    [TBL_POINT_BALANCE]
                                                                WHERE   CustomerBalanceID = @CustomerBalanceID
                                                                        AND ActionMode = 3";

                        DataTable pointDt = db.SetCommand(strSelGiveAmount, db.Parameter("@CustomerBalanceID", oldBalanceID, DbType.Int32)).ExecuteDataTable();

                        decimal giveAmount = 0;
                        object userCardNo = DBNull.Value;
                        if (pointDt != null && pointDt.Rows.Count == 1)
                        {
                            giveAmount = StringUtils.GetDbDecimal(pointDt.Rows[0]["Amount"].ToString());
                            userCardNo = StringUtils.GetDbString(pointDt.Rows[0]["UserCardNo"].ToString());
                            giveAmount = Math.Abs(giveAmount) * -1;

                            string strCardBalanceSql = @"SELECT BALANCE FROM [TBL_CUSTOMER_CARD] WHERE CompanyID=@CompanyID AND UserID=@CustomerID AND UserCardNo=@UserCardNo";
                            decimal totalPointAmount = db.SetCommand(strCardBalanceSql,
                                  db.Parameter("@CompanyID", companyID, DbType.Int32),
                                  db.Parameter("@CustomerID", orderList[0].CustomerID, DbType.Int32),
                                  db.Parameter("@UserCardNo", userCardNo, DbType.String)).ExecuteScalar<decimal>();



                            if (giveAmount != 0 && userCardNo != DBNull.Value)
                            {

                                //ActionMode 1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                //DepositMode 1:充值、2:余额转入
                                string strAddPointBalance = @" INSERT INTO [TBL_POINT_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CreatorID ,@CreateTime)";


                                int addres = db.SetCommand(strAddPointBalance
                                       , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                       , db.Parameter("@BranchID", oldBranchID, DbType.Int32)
                                       , db.Parameter("@UserID", orderList[0].CustomerID, DbType.Int32)
                                       , db.Parameter("@CustomerBalanceID", customerBalanceID, DbType.Int32)
                                       , db.Parameter("@ActionMode", 4, DbType.Int32)//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                       , db.Parameter("@DepositMode", 0, DbType.Int32)//1:充值、2:余额转入
                                       , db.Parameter("@Remark", DBNull.Value, DbType.String)
                                       , db.Parameter("@UserCardNo", userCardNo, DbType.String)
                                       , db.Parameter("@Amount", giveAmount, DbType.Decimal)
                                       , db.Parameter("@Balance", totalPointAmount + giveAmount, DbType.Decimal)
                                       , db.Parameter("@CreatorID", updaterID, DbType.Int32)
                                       , db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                                if (addres <= 0)
                                {
                                    db.RollbackTransaction();
                                    res.Code = "0";
                                    res.Message = "退款失败!";
                                    res.Data = null;
                                    return res;
                                }

                                #region 修改CustomerCard中的Balance

                                int hisRows = db.SetCommand(strAddHis, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                                     , db.Parameter("@UserID", orderList[0].CustomerID, DbType.Int32)
                                                                     , db.Parameter("@UserCardNo", userCardNo, DbType.String)).ExecuteNonQuery();

                                if (hisRows == 0)
                                {
                                    db.RollbackTransaction();
                                    res.Code = "0";
                                    res.Message = "退款失败!";
                                    res.Data = null;
                                    return res;
                                }

                                int updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", totalPointAmount + giveAmount, DbType.Decimal)
                                                                     , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                                     , db.Parameter("@UserID", orderList[0].CustomerID, DbType.Int32)
                                                                     , db.Parameter("@UserCardNo", userCardNo, DbType.String)).ExecuteNonQuery();

                                if (updateRes == 0)
                                {
                                    db.RollbackTransaction();
                                    res.Code = "0";
                                    res.Message = "退款失败!";
                                    res.Data = null;
                                    return res;
                                }
                                #endregion
                            }
                        }



                        #endregion

                        #region 扣除现金券赠送
                        strSelGiveAmount = @"SELECT  Amount,UserCardNo 
                                                                FROM    [TBL_COUPON_BALANCE]
                                                                WHERE   CustomerBalanceID = @CustomerBalanceID
                                                                        AND ActionMode = 3";

                        DataTable couponDt = db.SetCommand(strSelGiveAmount, db.Parameter("@CustomerBalanceID", oldBalanceID, DbType.Int32)).ExecuteDataTable();

                        giveAmount = 0;
                        userCardNo = DBNull.Value;
                        if (couponDt != null && couponDt.Rows.Count == 1)
                        {
                            giveAmount = StringUtils.GetDbDecimal(couponDt.Rows[0]["Amount"].ToString());
                            userCardNo = StringUtils.GetDbString(couponDt.Rows[0]["UserCardNo"].ToString());
                            giveAmount = Math.Abs(giveAmount) * -1;

                            string strCardBalanceSql = @"SELECT BALANCE FROM [TBL_CUSTOMER_CARD] WHERE CompanyID=@CompanyID AND UserID=@CustomerID AND UserCardNo=@UserCardNo";
                            decimal totalCouponAmount = db.SetCommand(strCardBalanceSql,
                                db.Parameter("@CompanyID", companyID, DbType.Int32),
                                db.Parameter("@CustomerID", orderList[0].CustomerID, DbType.Int32),
                                db.Parameter("@UserCardNo", userCardNo, DbType.String)).ExecuteScalar<decimal>();


                            if (giveAmount != 0 && userCardNo != DBNull.Value)
                            {

                                //ActionMode 1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                //DepositMode 1:充值、2:余额转入
                                string strAddCouponBalance = @" INSERT INTO [TBL_COUPON_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CouponType ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CouponType ,@CreatorID ,@CreateTime)";


                                int addres = db.SetCommand(strAddCouponBalance
                                       , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                       , db.Parameter("@BranchID", oldBranchID, DbType.Int32)
                                       , db.Parameter("@UserID", orderList[0].CustomerID, DbType.Int32)
                                       , db.Parameter("@CustomerBalanceID", customerBalanceID, DbType.Int32)
                                       , db.Parameter("@ActionMode", 4, DbType.Int32)//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                       , db.Parameter("@DepositMode", 0, DbType.Int32)//1:充值、2:余额转入
                                       , db.Parameter("@Remark", DBNull.Value, DbType.String)
                                       , db.Parameter("@UserCardNo", userCardNo, DbType.String)
                                       , db.Parameter("@Amount", giveAmount, DbType.Decimal)
                                       , db.Parameter("@Balance", totalCouponAmount + giveAmount, DbType.Decimal)
                                       , db.Parameter("@CouponType", 0, DbType.Int32)
                                       , db.Parameter("@CreatorID", updaterID, DbType.Int32)
                                       , db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                                if (addres <= 0)
                                {
                                    db.RollbackTransaction();
                                    res.Code = "0";
                                    res.Message = "退款失败!";
                                    res.Data = null;
                                    return res;
                                }

                                #region 修改CustomerCard中的Balance

                                int hisRows = db.SetCommand(strAddHis, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                                     , db.Parameter("@UserID", orderList[0].CustomerID, DbType.Int32)
                                                                     , db.Parameter("@UserCardNo", userCardNo, DbType.String)).ExecuteNonQuery();

                                if (hisRows == 0)
                                {
                                    db.RollbackTransaction();
                                    res.Code = "0";
                                    res.Message = "退款失败!";
                                    res.Data = null;
                                    return res;
                                }

                                int updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", totalCouponAmount + giveAmount, DbType.Decimal)
                                                                     , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                                     , db.Parameter("@UserID", orderList[0].CustomerID, DbType.Int32)
                                                                     , db.Parameter("@UserCardNo", userCardNo, DbType.String)).ExecuteNonQuery();

                                if (updateRes == 0)
                                {
                                    db.RollbackTransaction();
                                    res.Code = "0";
                                    res.Message = "退款失败!";
                                    res.Data = null;
                                    return res;
                                }
                                #endregion
                            }

                        }

                        #endregion

                    }

                    string strSelMessage = @"SELECT  T2.CardName,T1.Balance
                                            FROM    [TBL_CUSTOMER_CARD] T1
                                                    INNER JOIN [MST_CARD] T2 ON T1.CardID = T2.ID
                                            WHERE   T1.UserID = @CustomerID";

                    list = db.SetCommand(strSelMessage, db.Parameter("@CustomerID", orderList[0].CustomerID, DbType.Int32)).ExecuteList<CancelPaymentMsgForWeb>();




                    db.CommitTransaction();
                    res.Code = "1";
                    res.Data = list;
                    res.Message = "取消成功";
                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
                return res;
            }
        }
    

        public int updatePaymentDetailMode(int companyID, List<UpdatePaymentDetailForWeb> detailList, int PaymentID, DateTime PaymentTime, int updaterID, List<Slave_Model> listSalesID, bool changeSalesID, int IsUseRate, out string message)
        {
            message = "操作成功!";
            DateTime time = DateTime.Now.ToLocalTime();
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                #region CHECK 支付号是否满足条件
                string strCheckSql = @"SELECT  COUNT(0)
                                        FROM    dbo.TBL_ORDERPAYMENT_RELATIONSHIP T1
                                                LEFT JOIN dbo.[ORDER] T2 ON T1.OrderID = T2.ID
                                        WHERE   T1.PaymentID = @PaymentID
                                        AND CONVERT(varchar(20), T2.OrderTime,120) > CONVERT(varchar(20), @PaymentTime,120)   ";

                int checkCount = db.SetCommand(strCheckSql, db.Parameter("@PaymentID", PaymentID, DbType.Int32)
                                               , db.Parameter("@PaymentTime", PaymentTime, DbType.DateTime2)).ExecuteScalar<int>();
                if (checkCount > 0)
                {
                    message = "支付时间不允许在订单时间之前";
                    return 2;
                }
                #endregion

                #region 更改支付

                if (detailList != null && detailList.Count > 0)
                {
                    foreach (UpdatePaymentDetailForWeb item in detailList)
                    {
                        string strSql = @"UPDATE dbo.PAYMENT_DETAIL SET PaymentMode=@PaymentMode,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime,ProfitRate=@ProfitRate
                                  WHERE ID = @PaymentDetailID ";

                        int rows = db.SetCommand(strSql, db.Parameter("@PaymentMode", item.PaymentMode, DbType.Int32)
                                                       , db.Parameter("@PaymentDetailID", item.PaymentDetailID, DbType.Int32)
                                                       , db.Parameter("@UpdaterID", updaterID, DbType.Int32)
                                                       , db.Parameter("@UpdateTime", time, DbType.DateTime2)
                                                       , db.Parameter("@ProfitRate", item.ProfitRate, DbType.Decimal)).ExecuteNonQuery();

                        if (rows != 1)
                        {
                            db.RollbackTransaction();
                            message = "操作失败";
                            return 0;
                        }
                    }

                }


                string strUpdatePaymentSql = @"UPDATE dbo.PAYMENT SET PaymentTime =@PaymentTime 
                          ,IsUseRate=@IsUseRate 
                          ,UpdaterID =@UpdaterID
                          ,UpdateTime =@UpdateTime
                           WHERE ID =@PaymentID ";

                int count = db.SetCommand(strUpdatePaymentSql, db.Parameter("@PaymentTime", PaymentTime, DbType.DateTime2)
                                              , db.Parameter("@UpdaterID", updaterID, DbType.Int32)
                                              , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                                              , db.Parameter("@PaymentID", PaymentID, DbType.Int32)
                                              , db.Parameter("@IsUseRate", IsUseRate, DbType.Int32)).ExecuteNonQuery();

                if (count != 1)
                {
                    db.RollbackTransaction();
                    message = "操作失败";
                    return 0;
                }

                #endregion

                #region 业绩参与更改
                string strSqlProfit = @" INSERT INTO TBL_HISTORY_PROFIT SELECT * FROM dbo.TBL_PROFIT WHERE MasterID =@PaymentID AND Type = 2 ";

                int valHistory = db.SetCommand(strSqlProfit, db.Parameter("@PaymentID", PaymentID, DbType.Int32)).ExecuteNonQuery();

                strSqlProfit = @"delete  dbo.TBL_PROFIT
                               WHERE   MasterID = @PaymentID
                                       AND Type = 2";

                int valDelete = db.SetCommand(strSqlProfit, db.Parameter("@PaymentID", PaymentID, DbType.Int32)).ExecuteNonQuery();

                if (valHistory != valDelete)
                {
                    db.RollbackTransaction();
                    message = "更改业绩参与失败!";
                    return 0;
                }


                if (listSalesID != null && listSalesID.Count > 0)
                {
                    string strSql = @"INSERT INTO dbo.TBL_PROFIT( MasterID ,SlaveID ,Type ,Available ,CreateTime ,CreatorID,ProfitPct) 
                               VALUES  ( @PaymentID,@SlaveID ,2 ,1 , @CreateTime, @CreatorID,@ProfitPct  )";

                    foreach (Slave_Model item in listSalesID)
                    {
                        int val = db.SetCommand(strSql, db.Parameter("@PaymentID", PaymentID, DbType.Int32)
                               , db.Parameter("@SlaveID", item.SlaveID, DbType.Int32)
                               , db.Parameter("@CreateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                               , db.Parameter("@CreatorID", updaterID, DbType.Int32)
                               , db.Parameter("@ProfitPct", item.ProfitPct, DbType.Decimal)).ExecuteNonQuery();

                        if (val <= 0)
                        {
                            db.RollbackTransaction();
                            message = "更改业绩参与失败!";
                            return 0;
                        }
                    }
                }

                #endregion

                string strSelCompanyComissionCalcSql = " SELECT [ComissionCalc] FROM COMPANY WHERE ID=@CompanyID ";
                bool isComissionCalc = db.SetCommand(strSelCompanyComissionCalcSql
                                     , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalar<bool>();

                if (isComissionCalc)
                {
                    string strSelPaymentInfoSql = " SELECT CompanyID,BranchID,TotalPrice FROM [PAYMENT] WHERE CompanyID=@CompanyID AND ID=@PaymentID ;";
                    DataTable dt = db.SetCommand(strSelPaymentInfoSql, db.Parameter("@PaymentID", PaymentID, DbType.Int32)
                               , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteDataTable();

                    if (dt == null || dt.Rows.Count < 1)
                    {
                        db.RollbackTransaction();
                        message = "更改业绩参与失败!";
                        return 0;
                    }

                    int branchID = StringUtils.GetDbInt(dt.Rows[0]["BranchID"]);
                    //decimal paymentAmount = StringUtils.GetDbDecimal(dt.Rows[0]["TotalPrice"]);



                    if (detailList != null && detailList.Count > 0)
                    {
                        foreach (UpdatePaymentDetailForWeb item in detailList)
                        {
                            #region 删除业绩分享
                            string strSelCountDetailSql = @"select count(0) from TBL_PROFIT_COMMISSION_DETAIL where CompanyID = @CompanyID
                                                                        AND SourceID = @SourceID
                                                                        AND SourceType = @SourceType";
                            int detailCount = db.SetCommand(strSelCountDetailSql
                                                    , db.Parameter("@RecordType", 2, DbType.Int32)
                                                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                    , db.Parameter("@SourceID", item.PaymentDetailID, DbType.Int32)
                                                    , db.Parameter("@SourceType", 1, DbType.Int32)
                                                    , db.Parameter("@UpdaterID", updaterID, DbType.Int32)
                                                    , db.Parameter("@UpdateTime", time, DbType.DateTime)).ExecuteScalar<int>();
                            if (detailCount > 0)
                            {
                                string strUpdateComissionCalcsQL = @" UPDATE  TBL_PROFIT_COMMISSION_DETAIL
                                                                SET     RecordType = @RecordType ,UpdaterID = @UpdaterID ,UpdateTime = @UpdateTime 
                                                                WHERE   CompanyID = @CompanyID
                                                                        AND SourceID = @SourceID
                                                                        AND SourceType = @SourceType ";
                                int rows = db.SetCommand(strUpdateComissionCalcsQL
                                                        , db.Parameter("@RecordType", 2, DbType.Int32)
                                                        , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                        , db.Parameter("@SourceID", item.PaymentDetailID, DbType.Int32)
                                                        , db.Parameter("@SourceType", 1, DbType.Int32)
                                                        , db.Parameter("@UpdaterID", updaterID, DbType.Int32)
                                                        , db.Parameter("@UpdateTime", time, DbType.DateTime)).ExecuteNonQuery();

                                if (rows != detailCount)
                                {
                                    db.RollbackTransaction();
                                    message = "更改业绩参与失败!";
                                    return 0;
                                }
                            }
                            #endregion

                            string strselpaymentamountsql = @"SELECT PaymentAmount FROM  dbo.PAYMENT_DETAIL WHERE ID=@PaymentdetailID";
                            decimal paymentAmount = db.SetCommand(strselpaymentamountsql
                                            , db.Parameter("@PaymentdetailID", item.PaymentDetailID, DbType.Int32)).ExecuteScalar<decimal>();

                            object CommFlag = DBNull.Value;//1：首充 2：指定 3：E账户
                            if (item.PaymentMode == 1 || item.PaymentMode == 6 || item.PaymentMode == 7)
                            {
                                CommFlag = 3;
                            }

                            string strSelOrderIDListSql = "SELECT OrderID FROM  dbo.TBL_ORDERPAYMENT_RELATIONSHIP WHERE PaymentID=@PaymentID ";
                            List<int> OrderList = db.SetCommand(strSelOrderIDListSql
                                            , db.Parameter("@PaymentID", PaymentID, DbType.Int32)).ExecuteScalarList<int>();

                            #region 计算销售业绩
                            foreach (int orderID in OrderList)
                            {
                                #region 取出Product基本数据
                                string strSelProductSql = @" SELECT CASE T1.ProductType
                                                                          WHEN 0 THEN T2.ServiceCode
                                                                          ELSE T3.CommodityCode
                                                                        END AS ProductCode ,
                                                                        T1.ProductType ,T1.TotalSalePrice 
                                                                 FROM   [ORDER] T1 WITH ( NOLOCK )
                                                                        LEFT JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.ID = T2.OrderID
                                                                        LEFT JOIN [TBL_ORDER_COMMODITY] T3 WITH ( NOLOCK ) ON T1.ID = T3.OrderID
                                                                 WHERE  T1.CompanyID = @CompanyID
                                                                        AND T1.ID = @OrderID; ";
                                DataTable paymentDT = db.SetCommand(strSelProductSql
                                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                    , db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteDataTable();

                                if (paymentDT == null || paymentDT.Rows.Count < 1)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }

                                int productType = StringUtils.GetDbInt(paymentDT.Rows[0]["ProductType"]);
                                long productCode = StringUtils.GetDbLong(paymentDT.Rows[0]["ProductCode"]);
                                decimal totalSalePrice = StringUtils.GetDbDecimal(paymentDT.Rows[0]["TotalSalePrice"]);
                                #endregion

                                #region 取出TBL_PRODUCT_COMMISSION_RULE数据
                                string strSelProductCommissionRuleSql = @" SELECT ProductType ,
                                                                                        ProductCode ,
                                                                                        ProfitPct ,
                                                                                        ECardSACommType ,
                                                                                        ECardSACommValue ,
                                                                                        NECardSACommType ,
                                                                                        NECardSACommValue
                                                                                 FROM   TBL_PRODUCT_COMMISSION_RULE
                                                                                 WHERE  CompanyID = @CompanyID
                                                                                        AND ProductType = @ProductType
                                                                                        AND ProductCode = @ProductCode ";

                                Product_Commission_Rule_Model ProductRuleModel = db.SetCommand(strSelProductCommissionRuleSql
                                                                   , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                                   , db.Parameter("@ProductType", productType, DbType.Int32)
                                                                   , db.Parameter("@ProductCode", productCode, DbType.Int64)).ExecuteObject<Product_Commission_Rule_Model>();
                                #endregion

                                if (ProductRuleModel != null && ProductRuleModel.ProductCode > 0)
                                {
                                    //decimal Income = paymentAmount * (IsUseRate != 1 ? 1 : item.ProfitRate);
                                    decimal Income = 0;
                                    if (OrderList.Count > 1)
                                    {
                                        Income = totalSalePrice * (IsUseRate != 1 ? 1 : item.ProfitRate);
                                    }
                                    else
                                    {
                                        Income = paymentAmount * (IsUseRate != 1 ? 1 : item.ProfitRate);
                                    }

                                    decimal Profit = Income * ProductRuleModel.ProfitPct;

                                    int CommType = 0;
                                    decimal CommValue = 0;
                                    if (CommFlag != DBNull.Value)
                                    {
                                        #region E账户
                                        CommType = ProductRuleModel.ECardSACommType;
                                        CommValue = ProductRuleModel.ECardSACommValue;
                                        #endregion
                                    }
                                    else
                                    {
                                        #region 非E账户
                                        CommType = ProductRuleModel.NECardSACommType;
                                        CommValue = ProductRuleModel.NECardSACommValue;
                                        #endregion
                                    }

                                    string strAddProfitDetailSql = @" INSERT INTO TBL_PROFIT_COMMISSION_DETAIL ( CompanyID ,BranchID ,SourceType ,SourceID ,SubSourceID ,Income ,ProfitPct ,Profit ,CommType ,CommValue ,AccountID ,AccountProfitPct ,AccountProfit ,AccountComm ,CommFlag ,CreatorID ,CreateTime ) 
                                                                    VALUES ( @CompanyID ,@BranchID ,@SourceType ,@SourceID ,@SubSourceID ,@Income ,@ProfitPct ,@Profit ,@CommType ,@CommValue ,@AccountID ,@AccountProfitPct ,@AccountProfit ,@AccountComm ,@CommFlag ,@CreatorID ,@CreateTime ) ";
                                    if (PaymentID >= 0 && listSalesID != null && listSalesID.Count > 0)
                                    {
                                        #region 有业绩分享人
                                        foreach (Slave_Model slaveItem in listSalesID)
                                        {
                                            #region 有业绩分享人
                                            //员工业绩(=实际业绩 x 员工业绩计算比例)
                                            decimal AccountProfit = Profit * slaveItem.ProfitPct;
                                            //1:按比例 2:固定值
                                            decimal AccountComm = 0;
                                            if (OrderList.Count > 1)
                                            {
                                                AccountComm = Math.Round(CommValue * 1 * slaveItem.ProfitPct, 2, MidpointRounding.AwayFromZero);
                                            }
                                            else
                                            {
                                                AccountComm = Math.Round(CommValue * (paymentAmount / totalSalePrice) * slaveItem.ProfitPct, 2, MidpointRounding.AwayFromZero);
                                            }

                                            //1:按比例 2:固定值
                                            if (CommType == 1)
                                            {
                                                AccountComm = AccountProfit * CommValue;
                                            }

                                            int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                                , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                , db.Parameter("@BranchID", branchID, DbType.Int32)
                                                , db.Parameter("@SourceType", 1, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                                , db.Parameter("@SourceID", item.PaymentDetailID, DbType.Int64)
                                                , db.Parameter("@SubSourceID", orderID, DbType.Int64)
                                                , db.Parameter("@Income", Income, DbType.Decimal)//收入 充值时，为TBL_MONEY_BALANCE的Amount
                                                , db.Parameter("@ProfitPct", ProductRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                                , db.Parameter("@Profit", Profit, DbType.Decimal)//实际业绩
                                                , db.Parameter("@CommType", CommType, DbType.Int32)//该业绩的提成方式
                                                , db.Parameter("@CommValue", CommValue, DbType.Decimal)//该业绩的提成数值
                                                , db.Parameter("@AccountID", slaveItem.SlaveID, DbType.Int32)//获得该业绩的员工ID
                                                , db.Parameter("@AccountProfitPct", slaveItem.ProfitPct, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                                , db.Parameter("@AccountProfit", AccountProfit, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                                , db.Parameter("@AccountComm", AccountComm, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
                                                , db.Parameter("@CommFlag", CommFlag, DbType.Int32)//1：首充 2：指定 3：E账户
                                                , db.Parameter("@CreatorID", updaterID, DbType.Int32)
                                                , db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                                            if (addProfitDetailRes != 1)
                                            {
                                                db.RollbackTransaction();
                                                return 0;
                                            }
                                            #endregion
                                        }
                                        #endregion
                                    }
                                    else
                                    {
                                        #region 没有业绩分享人
                                        int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                                , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                , db.Parameter("@BranchID", branchID, DbType.Int32)
                                                , db.Parameter("@SourceType", 1, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                                , db.Parameter("@SourceID", item.PaymentDetailID, DbType.Int64)
                                                , db.Parameter("@SubSourceID", orderID, DbType.Int64)
                                                , db.Parameter("@Income", Income, DbType.Decimal)//收入 充值时，为TBL_MONEY_BALANCE的Amount
                                                , db.Parameter("@ProfitPct", ProductRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                                , db.Parameter("@Profit", Profit, DbType.Decimal)//实际业绩
                                                , db.Parameter("@CommType", CommType, DbType.Int32)//该业绩的提成方式
                                                , db.Parameter("@CommValue", CommValue, DbType.Decimal)//该业绩的提成数值
                                                , db.Parameter("@AccountID", DBNull.Value, DbType.Int32)//获得该业绩的员工ID
                                                , db.Parameter("@AccountProfitPct", DBNull.Value, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                                , db.Parameter("@AccountProfit", DBNull.Value, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                                , db.Parameter("@AccountComm", DBNull.Value, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
                                                , db.Parameter("@CommFlag", DBNull.Value, DbType.Int32)//1：首充 2：指定 3：E账户
                                                , db.Parameter("@CreatorID", updaterID, DbType.Int32)
                                                , db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                                        if (addProfitDetailRes != 1)
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

                    }

                }

                db.CommitTransaction();
                return 1;
            }
        }

        public PaymentDetailInfo_Model getPaymentDetailForWeb(int companyID, int paymentID, int branchID)
        {
            PaymentDetailInfo_Model paymodel = new PaymentDetailInfo_Model();
            try
            {
                using (DbManager db = new DbManager())
                {
                    string strSqlCommand = @"SELECT  T2.PaymentTime ,
                                            ISNULL(T3.Name, T4.Name) AS Operator ,
                                            T2.TotalPrice ,
                                            T2.Remark ,
                                            T2.ID AS PaymentID ,
                                            T2.OrderNumber ,
                                            T2.Type ,
                                            T2.Status ,
                                            T2.CreateTime,
                                            T2.IsUseRate
                                    FROM    [TBL_OrderPayment_RelationShip] T1 WITH ( NOLOCK )
                                            LEFT JOIN [PAYMENT] T2 WITH ( NOLOCK ) ON T2.ID = T1.PaymentID
                                            LEFT JOIN [ACCOUNT] T3 ON T2.CreatorID = T3.UserID
                                            LEFT JOIN [CUSTOMER] T4 ON T2.CreatorID = T4.UserID
											INNER JOIN [ORDER] T5 ON T1.OrderID = T5.ID 
                                    WHERE   T2.CompanyID = @CompanyID
                                            AND T2.Type = 1 AND (T2.Status = 2 or T2.Status = 4)  AND T2.ID = @PaymentID AND T5.PaymentStatus <> 4";

                    if (branchID > 0)
                    {
                        strSqlCommand += " and T2.BranchID = " + branchID.ToString();
                    }

                    paymodel = db.SetCommand(strSqlCommand, db.Parameter("@CompanyID", companyID, DbType.Int32), db.Parameter("@PaymentID", paymentID, DbType.Int32)).ExecuteObject<PaymentDetailInfo_Model>();


                    if (paymodel != null)
                    {
                        paymodel.PaymentDetailList = new List<PaymentDetailList_Model>();
                        string strSql = @"SELECT  T1.PaymentMode ,T1.ID AS PaymentDetailID ,
                                            T1.PaymentAmount ,
                                            T1.CardPaidAmount ,
                                            CASE T1.PaymentMode
                                              WHEN 0 THEN '现金'
                                              WHEN 2 THEN '银行卡'
                                              WHEN 3 THEN '其他'
                                              WHEN 4 THEN '免支付'
                                              WHEN 5 THEN '过去支付'
                                              WHEN 8 THEN '微信'
                                              ELSE T3.CardName
                                            END AS CardName,ISNULL(T1.ProfitRate,1) ProfitRate
                                    FROM    [PAYMENT_DETAIL] T1 WITH ( NOLOCK )
                                            LEFT JOIN [TBL_CUSTOMER_CARD] T2 WITH ( NOLOCK ) ON T2.UserCardNo = T1.UserCardNo
                                            LEFT JOIN [MST_CARD] T3 WITH ( NOLOCK ) ON T2.CardID = T3.ID
                                    WHERE   T1.CompanyID = @CompanyID
                                            AND T1.PaymentID = @PaymentID
                                    ORDER BY T1.PaymentMode , T3.CardTypeID";

                        paymodel.PaymentDetailList = db.SetCommand(strSql
                            , db.Parameter("@CompanyID", companyID, DbType.Int32)
                            , db.Parameter("@PaymentID", paymentID, DbType.Int32)).ExecuteList<PaymentDetailList_Model>();


                        paymodel.ProfitList = new List<Profit_Model>();
                        paymodel.ProfitList = getProfitListByMasterID(paymentID, 2);


                        strSql = @"SELECT  T2.ID ,T2.CreateTime ,
                                        T2.ProductType ,
                                        T2.TotalSalePrice ,
                                        CASE T2.ProductType WHEN 0 THEN T3.ServiceName ELSE T4.CommodityName END AS ProductName,
                                        CASE T2.ProductType WHEN 0 THEN T3.ID ELSE T4.ID END AS OrderObjectID
                                FROM    [TBL_ORDERPAYMENT_RELATIONSHIP] T1 WITH ( NOLOCK )
                                        LEFT JOIN [Order] T2 WITH ( NOLOCK ) ON T1.OrderID = T2.ID
                                        LEFT JOIN [TBL_ORDER_SERVICE] T3 WITH ( NOLOCK ) ON T2.ID = T3.OrderID
                                        LEFT JOIN [TBL_ORDER_COMMODITY] T4 WITH ( NOLOCK ) ON T2.ID = T4.OrderID
                                WHERE   T1.PaymentID = @PaymentID AND T2.CompanyID=@CompanyID";

                        paymodel.OrderList = new List<PaymentDetailOrderInfo_Model>();
                        paymodel.OrderList = db.SetCommand(strSql
                                , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                , db.Parameter("@PaymentID", paymentID, DbType.Int32)).ExecuteList<PaymentDetailOrderInfo_Model>();

                        if (paymodel.OrderList != null)
                        {
                            foreach (PaymentDetailOrderInfo_Model item in paymodel.OrderList)
                            {
                                DateTime dt = Convert.ToDateTime(item.CreateTime);
                                item.OrderNumber = dt.Month.ToString().PadLeft(2, '0') + dt.Day.ToString().PadLeft(2, '0') + item.ID.ToString().PadLeft(6, '0') + dt.Year.ToString().Substring(dt.Year.ToString().Length - 2, 2);
                            }
                        }
                    }

                    return paymodel;
                }
            }
            catch (Exception ex)
            {
                LogUtil.Error(ex);
                return null;
            }
        }
        #endregion
    }
}
