using BLToolkit.Data;
using HS.Framework.Common;
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
                                                    ISNULL(T4.AccountID, 0) AS SalesPersonID ,
                                                    ISNULL(T5.Name, '') AS SalesName ,
                                                    T1.PaymentStatus ,
                                                    ISNULL(T8.ID, 0) AS CardID ,
                                                    ISNULL(T8.CardName, '') AS CardName ,
                                                    ISNULL(T7.UserCardNo, '') AS UserCardNo ,
                                                    T8.CardTypeID ,
                                                    T7.Balance ,
													T6.UserCardNo
                                            FROM    [ORDER] T1 WITH ( NOLOCK )
                                                    LEFT JOIN [BRANCH] T2 WITH ( NOLOCK ) ON T2.ID = T1.BranchID
                                                    LEFT JOIN [CUSTOMER] T3 WITH ( NOLOCK ) ON T1.CustomerID = T3.UserID
                                                    LEFT JOIN [RELATIONSHIP] T4 WITH ( NOLOCK ) ON T3.UserID = T4.CustomerID
                                                                                                   AND T4.Type = 2
                                                                                                   AND T4.CompanyID = @CompanyID
                                                                                                   --AND T4.BranchID = @BranchID 
                                                                                                   AND T4.Available=1 
                                                    LEFT JOIN [Account] T5 WITH ( NOLOCK ) ON T4.AccountID = T5.UserID 
                                                    LEFT JOIN [TBL_ORDER_SERVICE] T6 ON T1.ID = T6.OrderID
                                                    LEFT JOIN [TBL_CUSTOMER_CARD] T7 ON T6.UserCardNo = T7.UserCardNo
                                                    LEFT JOIN [MST_CARD] T8 ON T7.CardID = T8.ID
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
                                                    ISNULL(T4.AccountID, 0) AS SalesPersonID ,
                                                    ISNULL(T5.Name, '') AS SalesName ,
                                                    T1.PaymentStatus ,
                                                    ISNULL(T8.ID, 0) AS CardID ,
                                                    ISNULL(T8.CardName, '') AS CardName ,
                                                    T7.Balance ,
													T6.UserCardNo
                                            FROM    [ORDER] T1 WITH ( NOLOCK )
                                                    LEFT JOIN [BRANCH] T2 WITH ( NOLOCK ) ON T2.ID = T1.BranchID
                                                    LEFT JOIN [CUSTOMER] T3 WITH ( NOLOCK ) ON T1.CustomerID = T3.UserID
                                                    LEFT JOIN [RELATIONSHIP] T4 WITH ( NOLOCK ) ON T3.UserID = T4.CustomerID
                                                                                                   AND T4.Type = 2
                                                                                                   AND T4.CompanyID = @CompanyID
                                                                                                   --AND T4.BranchID = @BranchID 
                                                                                                   AND T4.Available=1 
                                                    LEFT JOIN [Account] T5 WITH ( NOLOCK ) ON T4.AccountID = T5.UserID 
                                                    LEFT JOIN [TBL_ORDER_COMMODITY] T6 ON T1.ID = T6.OrderID
                                                    LEFT JOIN [TBL_CUSTOMER_CARD] T7 ON T6.UserCardNo = T7.UserCardNo
                                                    LEFT JOIN [MST_CARD] T8 ON T7.CardID = T8.ID
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

                    if (model.CardID <= 0)
                    {
                        return null;
                    }
                }
                else
                {
                    #region 多笔支付

                    #region 判断是不是一张卡
                    string userCardNo = "";
                    foreach (PaymentInfoDetailOperation_Model item in operationModel.OrderList)
                    {
                        string strCardSql = "";
                        if (item.ProductType == 0)
                        {
                            #region 服务
                            strCardSql = @" SELECT  UserCardNo
                                                            FROM    [TBL_ORDER_SERVICE] T1 WITH ( NOLOCK )
                                                            WHERE   T1.ID = @OrderObjectID
                                                                    AND T1.OrderID = @OrderID
                                                                    AND T1.CompanyID=@CompanyID ";
                            #endregion
                        }
                        else
                        {
                            #region 商品
                            strCardSql = @" SELECT  UserCardNo
                                                            FROM    [TBL_ORDER_COMMODITY] T1 WITH ( NOLOCK )
                                                            WHERE   T1.ID = @OrderObjectID
                                                                    AND T1.OrderID = @OrderID 
                                                                    AND T1.CompanyID=@CompanyID ";
                            #endregion
                        }

                        string eachUserCardNo = db.SetCommand(strCardSql
                                , db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)
                                , db.Parameter("@BranchID", operationModel.BranchID, DbType.Int32)
                                , db.Parameter("@OrderID", item.OrderID, DbType.Int32)
                                , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)).ExecuteScalar<string>();

                        if (string.IsNullOrWhiteSpace(eachUserCardNo))
                        {
                            return null;
                        }

                        if (string.IsNullOrWhiteSpace(userCardNo))
                        {
                            userCardNo = eachUserCardNo;
                        }
                        else
                        {
                            if (userCardNo != eachUserCardNo)
                            {
                                return null;
                            }
                        }
                    }
                    #endregion

                    string strSelSql = @"SELECT 
                                                SUM(T1.TotalOrigPrice) AS TotalOrigPrice ,  
                                                SUM(T1.TotalCalcPrice) AS TotalCalcPrice ,
                                                SUM(T1.TotalSalePrice) AS TotalSalePrice ,
                                                SUM(T1.UnPaidPrice) AS UnPaidPrice ,
                                                T2.IsPay ,
                                                ISNULL(T2.IsPartPay, 0) AS IsPartPay ,
                                                ISNULL(T3.ExpirationDate, '2099-12-31') AS ExpirationDate ,
                                                ISNULL(T4.AccountID, 0) AS SalesPersonID ,
                                                ISNULL(T5.Name, '') AS SalesName ,
                                                T1.PaymentStatus ,
                                                0 AS CardID ,
                                                '' AS CardName
                                        FROM    [ORDER] T1 WITH ( NOLOCK )
                                                LEFT JOIN [BRANCH] T2 WITH ( NOLOCK ) ON T2.ID = T1.BranchID
                                                LEFT JOIN [CUSTOMER] T3 WITH ( NOLOCK ) ON T1.CustomerID = T3.UserID
                                                LEFT JOIN [RELATIONSHIP] T4 WITH ( NOLOCK ) ON T3.UserID = T4.CustomerID
                                                                                               AND T4.Type = 2
                                                                                               AND T4.CompanyID = @CompanyID
                                                                                               --AND T4.BranchID = @BranchID 
                                                                                               AND T4.Available=1 
                                                LEFT JOIN [Account] T5 WITH ( NOLOCK ) ON T4.AccountID = T5.UserID 
                                        WHERE   T1.CompanyID = @CompanyID
                                                --AND T1.BranchID = @BranchID
                                                AND T1.ID IN({0}) GROUP BY T2.IsPay ,T2.IsPartPay ,T3.ExpirationDate ,T4.AccountID ,T5.Name ,T1.PaymentStatus";

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

                    strSelSql = string.Format(strSelSql, strIDs);

                    model = db.SetCommand(strSelSql
                                , db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)
                                , db.Parameter("@BranchID", operationModel.BranchID, DbType.Int32)).ExecuteObject<PaymentInfo_Model>();

                    if (model != null)
                    {
                        #region 获取卡信息
                        string strGetCardInfoSql = @" SELECT TOP 1
                                                                T1.UserCardNo ,
                                                                T1.CardID ,
                                                                T2.CardName ,
                                                                T2.CardTypeID ,
                                                                T1.Balance 
                                                        FROM    [TBL_CUSTOMER_CARD] T1 WITH ( NOLOCK )
                                                                INNER JOIN [MST_CARD] T2 WITH ( NOLOCK ) ON T1.CardID = T2.ID
                                                        WHERE   T1.CompanyID = @CompanyID
                                                                AND T1.UserCardNo = @UserCardNo
                                                                AND T2.Available = 1 ";
                        GetECardList_Model cardInfo = db.SetCommand(strGetCardInfoSql
                                , db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)
                                , db.Parameter("@UserCardNo", userCardNo, DbType.String)).ExecuteObject<GetECardList_Model>();

                        if (cardInfo != null)
                        {
                            model.CardID = cardInfo.CardID;
                            model.CardName = cardInfo.CardName;
                            model.CardTypeID = cardInfo.CardTypeID;
                            model.UserCardNo = userCardNo;
                            model.Balance = cardInfo.Balance;
                        }
                        #endregion
                    }

                    #endregion
                }

                //if (model != null && !model.IsPay)
                //{
                //    string strSqlCheckLogin = @" SELECT T2.LoginMobile  FROM [USER] T2 WHERE T2.ID = @Customer AND T2.UserType = 0";

                //    string loginMobil = db.SetCommand(strSqlCheckLogin, db.Parameter("@Customer", operationModel.CustomerID, DbType.Int32)).ExecuteScalar<string>();
                //    if (string.IsNullOrEmpty(loginMobil))
                //    {
                model.IsPay = true;
                //    }

                //}

                string strPointSql = @" SELECT  T2.PresentRate
                                        FROM    [TBL_CUSTOMER_CARD] T1 WITH ( NOLOCK )
                                                INNER JOIN [MST_CARD] T2 WITH ( NOLOCK ) ON T1.CardID = T2.ID
                                        WHERE   T1.CompanyID = @CompanyID
                                                AND T1.UserID = @UserID
                                                AND T2.Available = 1
                                                AND T2.CardTypeID = 2 ";

                decimal pointPresentRate = db.SetCommand(strPointSql
                                , db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)
                                , db.Parameter("@UserID", operationModel.CustomerID, DbType.Int32)).ExecuteScalar<decimal>();

                model.GivePointAmount = model.UnPaidPrice * pointPresentRate;

                string strCouponSql = @" SELECT  T2.PresentRate
                                        FROM    [TBL_CUSTOMER_CARD] T1 WITH ( NOLOCK )
                                                INNER JOIN [MST_CARD] T2 WITH ( NOLOCK ) ON T1.CardID = T2.ID
                                        WHERE   T1.CompanyID = @CompanyID
                                                AND T1.UserID = @UserID
                                                AND T2.Available = 1
                                                AND T2.CardTypeID = 3 ";

                decimal couponPresentRate = db.SetCommand(strCouponSql
                                , db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)
                                , db.Parameter("@UserID", operationModel.CustomerID, DbType.Int32)).ExecuteScalar<decimal>();

                model.GiveCouponAmount = model.UnPaidPrice * couponPresentRate;

                return model;
            }
        }

        public int PayAdd(PaymentAddOperation_Model model, List<int> orderIDList)
        {
            if (model != null && orderIDList != null && orderIDList.Count > 0)
            {
                using (DbManager db = new DbManager())
                {
                    db.BeginTransaction();

                    bool isBalanceChangePush = true;//余额变动只push一次
                    int customerBalanceID = 0;
                    try
                    {
                        #region 验证支付数据
                        List<int> orderIDListWithout0Price = new List<int>();
                        PaymentCheck_Model paymentCheckModel = new PaymentCheck_Model();
                        foreach (int item in orderIDList)
                        {
                            PaymentStatusCheck_Model paymentStatus = new PaymentStatusCheck_Model();
                            string strSqlCheckIsPaid = @"Select TotalSalePrice,UnPaidPrice, PaymentStatus ,Status ,BranchID 
                                                     FROM [Order] WITH (NOLOCK) 
                                                     WHERE ID=@OrderID";

                            paymentStatus = db.SetCommand(strSqlCheckIsPaid, db.Parameter("@OrderID", item, DbType.Int32)).ExecuteObject<PaymentStatusCheck_Model>();

                            if (paymentStatus == null)
                            {
                                return 0;
                            }

                            if (paymentStatus.Status == 3)
                            {
                                return 6;//已取消订单不能支付
                            }

                            if (paymentStatus.PaymentStatus == 3)
                            {
                                return 2;//已完全支付订单不能支付
                            }

                            if (paymentStatus.TotalSalePrice > 0)
                            {
                                // 新数组排除0元订单
                                orderIDListWithout0Price.Add(item);
                                paymentCheckModel.TotalCount += 1;
                                paymentCheckModel.TotalAmount += paymentStatus.UnPaidPrice;
                            }

                            if (model.BranchID <= 0)
                            {
                                model.BranchID = paymentStatus.BranchID;
                            }
                            else
                            {
                                if (model.BranchID != paymentStatus.BranchID)
                                {
                                    return 0;
                                }

                            }
                        }
                        #endregion

                        if (paymentCheckModel == null || orderIDListWithout0Price.Count == 0)
                        {
                            return 2;
                        }

                        model.TotalPrice = paymentCheckModel.TotalAmount;
                        model.PaymentDetail.CardType = 1;
                        model.PaymentDetail.PaymentAmount = paymentCheckModel.TotalAmount;
                        model.PaymentDetail.PaymentMode = 1;

                        PaymentBranchRole paymentBranchRole = new PaymentBranchRole();
                        paymentBranchRole.IsCustomerConfirm = true;
                        paymentBranchRole.IsAccountEcardPay = false;
                        paymentBranchRole.IsPartPay = false;

                        #region 获取权限
                        string strSqlCommand = @"select IsPay AS IsAccountEcardPay ,IsConfirmed AS IsCustomerConfirm ,IsPartPay ,IsUseRate from [BRANCH] 
                                                where BRANCH.ID = @BranchID ";

                        paymentBranchRole = db.SetCommand(strSqlCommand,
                                                        db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteObject<PaymentBranchRole>();

                        if (paymentBranchRole == null)
                        {
                            return 0;
                        }
                        #endregion


                        #region 插入PayMent表
                        string strSqlPayAdd = @"insert into PAYMENT(CompanyID,OrderNumber,TotalPrice,CreatorID,CreateTime,Remark,PaymentTime,LevelID,Type,Status,BranchID,ClientType,IsUseRate) 
                                              values (@CompanyID,@OrderNumber,@TotalPrice,@CreatorID,@CreateTime,@Remark,@PaymentTime,@LevelID,@Type,@Status,@BranchID,@ClientType,@IsUseRate);select @@IDENTITY";
                        int paymentID = db.SetCommand(strSqlPayAdd,
                                    db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                    db.Parameter("@OrderNumber", model.OrderCount, DbType.Int32),
                                    db.Parameter("@TotalPrice", model.TotalPrice, DbType.Decimal),
                                    db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                    db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime),
                                    db.Parameter("@Remark", model.Remark, DbType.String),
                                    db.Parameter("@PaymentTime", model.CreateTime, DbType.DateTime),
                                    db.Parameter("@LevelID", DBNull.Value, DbType.Int32),
                                    db.Parameter("@Type", 1, DbType.Int32),//1：支付 2：退款
                                    db.Parameter("@Status", 2, DbType.Int32),//1：无效 2：执行 3：撤销
                                    db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                    db.Parameter("@ClientType", model.ClientType, DbType.Int32),
                                    db.Parameter("@IsUseRate", paymentBranchRole.IsUseRate, DbType.Int32)).ExecuteScalar<int>();

                        if (paymentID <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        #region 插入业绩分享表
                        model.SlaveID = new List<int>();
                        foreach (int item in model.SlaveID)
                        {
                            string strAddProfitSql = @" INSERT	INTO TBL_PROFIT( MasterID ,SlaveID ,Type ,Available ,CreateTime ,CreatorID) 
                                                VALUES (@MasterID ,@SlaveID ,@Type ,@Available ,@CreateTime ,@CreatorID)";
                            int addProfitres = db.SetCommand(strAddProfitSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@MasterID", paymentID, DbType.Int64)
                                    , db.Parameter("@SlaveID", item, DbType.Int64)
                                    , db.Parameter("@Type", 2, DbType.Int32)
                                    , db.Parameter("@Available", true, DbType.Boolean)
                                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)).ExecuteNonQuery();

                            if (addProfitres <= 0)
                            {
                                if (DelCustomerLocked(db, model.CustomerID))
                                {
                                    db.RollbackTransaction();
                                }
                                LogUtil.Log("插入业绩表出错", "PaymentID:" + paymentID + "插入业绩表出错。");
                                return 0;
                            }
                        }
                        #endregion

                        #region E卡支付

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
                            , db.Parameter("@UserCardNo", model.PaymentDetail.UserCardNo, DbType.String)).ExecuteScalar<decimal>();

                        if (balance < model.PaymentDetail.PaymentAmount)
                        {
                            // 余额不足
                            db.RollbackTransaction();
                            return 4;
                        }
                        else
                        {
                            model.PaymentDetail.PaymentAmount = Math.Abs(model.PaymentDetail.PaymentAmount) * -1;
                            balance = balance + model.PaymentDetail.PaymentAmount;
                        }

                        #region 消费

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
                                    , db.Parameter("@UserCardNo", model.PaymentDetail.UserCardNo, DbType.String)
                                    , db.Parameter("@Amount", model.PaymentDetail.PaymentAmount, DbType.Decimal)
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
                        string selectCustomerDevice = @" SELECT TOP 1 ISNULL(T3.DeviceID, '') AS DeviceID ,T1.Name AS CustomerName ,T3.DeviceType ,T2.smsheading AS CompanyName,ISNULL(T6.BalanceNotice, 0) AS Threshold ,T4.LoginMobile,T2.BalanceRemind ,T6.CardName ,T1.WeChatOpenID 
                                                    FROM    [CUSTOMER] T1 WITH ( NOLOCK )
                                                            LEFT JOIN [COMPANY] T2 WITH ( NOLOCK ) ON T1.CompanyID = T2.ID
                                                            LEFT JOIN [LOGIN] T3 WITH ( NOLOCK ) ON T1.UserID = T3.UserID
                                                            LEFT JOIN [USER] T4 WITH ( NOLOCK ) ON T4.ID = t1.UserID
                                                            LEFT JOIN [TBL_CUSTOMER_CARD] T5 WITH ( NOLOCK ) ON T5.UserID = T4.ID AND T5.UserCardNo=@userCardNo
                                                            LEFT JOIN [MST_CARD] T6 WITH(NOLOCK) ON T5.CardID=T6.ID
                                                    WHERE   T1.UserID = @CustomerID ";
                        PushOperation_Model pushmodel = db.SetCommand(selectCustomerDevice, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                                                                          , db.Parameter("@userCardNo", model.PaymentDetail.UserCardNo, DbType.String)).ExecuteObject<PushOperation_Model>();
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
                                                    keyword3 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = model.PaymentDetail.PaymentAmount.ToString("C2") },
                                                    remark = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = "余额：" + balance.ToString("C2") + "\n\n您可以在账户交易明细中查看账户变动的详细内容。" }
                                                };
                                                we.TemplateMessageSend(messageModel, model.CompanyID, 1, accessToken);
                                            }

                                        }
                                        #endregion

                                        #region 可发短信情况
                                        GetVSMSINFO_Model vSMSINFO_Model = new GetVSMSINFO_Model();
                                        vSMSINFO_Model = SMSINFO_DAL.Instance.getVSMSINFODetail(model.CompanyID);
                                        #endregion

                                        #region 余额变动短信息提醒   可发送短信件数大于已发送短信件数
                                        if (!string.IsNullOrEmpty(pushmodel.LoginMobile) &&(vSMSINFO_Model.SMSNum > vSMSINFO_Model.SentNum))
                                        {
                                            WebAPI.Common.SendShortMessage.sendShortMessageForBalance(pushmodel.LoginMobile, pushmodel.CompanyName, model.CreateTime.ToString("MM月dd日HH时mm分"));
                                            isBalanceChangePush = false;
                                            //保存短信发送履历信息
                                            string msg = string.Format(Const.MESSAGE_BALANCE, pushmodel.CompanyName, model.CreateTime.ToString("MM月dd日HH时mm分"));
                                            AddSMSHIS_Model addSMSHIS_Model = new AddSMSHIS_Model
                                            {
                                                COMPANYID = model.CompanyID,
                                                RcvNumber = pushmodel.LoginMobile,
                                                CreatorID = model.CreatorID,
                                                CreateTime = model.CreateTime,
                                                SendTime = model.CreateTime,
                                                SMSContent = msg
                                            };
                                            SMSINFO_DAL.Instance.addSMSHIS_Model(addSMSHIS_Model);
                                        }
                                        #endregion
                                    }
                                }

                                #region 储值卡卡余额低于阀值PUSH提醒
                                if (model.PaymentDetail.PaymentAmount != 0 && balance < pushmodel.Threshold && pushmodel.Threshold > 0)
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


                                }
                                #endregion
                            });
                        }
                        else
                        {
                            LogUtil.Log("余额变动push失败", model.CustomerID + "数据抽取失败");
                        }
                        #endregion

                        #region 修改CustomerCard中的Balance

                        string strAddHis = @" INSERT INTO [HST_CUSTOMER_CARD] SELECT * FROM [TBL_CUSTOMER_CARD] WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo ";
                        int hisRows = db.SetCommand(strAddHis, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                             , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                             , db.Parameter("@UserCardNo", model.PaymentDetail.UserCardNo, DbType.String)).ExecuteNonQuery();

                        if (hisRows == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        string strUpdateCustomerCard = @" UPDATE [TBL_CUSTOMER_CARD] SET Balance=@Balance ,UpdaterID = @UpdaterID , UpdateTime = @UpdateTime WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo";
                        int updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", balance, DbType.Decimal)
                                                             , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                             , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                             , db.Parameter("@UserCardNo", model.PaymentDetail.UserCardNo, DbType.String)
                                                             , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                                                             , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                        if (hisRows == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        #endregion

                        #endregion

                        #region 插入PaymentDetail表
                        decimal totalMyCalAmount = 0;

                        if (Math.Abs(model.PaymentDetail.PaymentAmount) > 0)//排除传过来为0的记录
                        {
                            model.PaymentDetail.PaymentAmount = Math.Abs(model.PaymentDetail.PaymentAmount);
                            decimal paymentAmount = model.PaymentDetail.PaymentAmount;
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
                                , db.Parameter("@UserCardNo", model.PaymentDetail.UserCardNo, DbType.String)).ExecuteDataTable();

                            if (table == null || table.Rows.Count < 1)
                            {
                                ProfitRate = 1;
                            }
                            else
                            {
                                ProfitRate = StringUtils.GetDbDecimal(table.Rows[0]["ProfitRate"], 1);
                            }
                            #endregion

                            if (model.PaymentDetail.CardType == 2 || model.PaymentDetail.CardType == 3)
                            {
                                rate = StringUtils.GetDbDecimal(table.Rows[0]["Rate"], 1);
                                paymentAmount = Math.Round(model.PaymentDetail.PaymentAmount * rate, 2, MidpointRounding.AwayFromZero);
                            }

                            string strSqlDetailAdd = @"insert into PAYMENT_DETAIL(CompanyID,PaymentID,PaymentMode,PaymentAmount,CreatorID,CreateTime,UserCardNo,CardPaidAmount ,ProfitRate) 
                                                       values (@CompanyID,@PaymentID,@PaymentMode,@PaymentAmount,@CreatorID,@CreateTime,@UserCardNo,@CardPaidAmount ,@ProfitRate);select @@IDENTITY";

                            int paymentDetailID = db.SetCommand(strSqlDetailAdd
                                             , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                             , db.Parameter("@PaymentID", paymentID, DbType.Int32)
                                             , db.Parameter("@PaymentMode", model.PaymentDetail.PaymentMode, DbType.Int32)
                                             , db.Parameter("@PaymentAmount", paymentAmount, DbType.Decimal)
                                             , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                             , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)
                                             , db.Parameter("@UserCardNo", model.PaymentDetail.UserCardNo, DbType.String)
                                             , db.Parameter("@CardPaidAmount", model.PaymentDetail.PaymentAmount, DbType.Decimal)
                                             , db.Parameter("@ProfitRate", ProfitRate, DbType.Decimal)).ExecuteScalar<int>();

                            if (paymentDetailID <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            object CommFlag = DBNull.Value;//1：首充 2：指定 3：E账户
                            if (model.PaymentDetail.PaymentMode == 1 || model.PaymentDetail.PaymentMode == 6 || model.PaymentDetail.PaymentMode == 7)
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
                                        //decimal Income = paymentAmount * (paymentBranchRole.IsUseRate != 1 ? 1 : ProfitRate);

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

                                        string strAddProfitDetailSql = @" INSERT INTO TBL_PROFIT_COMMISSION_DETAIL ( CompanyID ,BranchID ,SourceType ,SourceID ,SubSourceID,Income ,ProfitPct ,Profit ,CommType ,CommValue ,AccountID ,AccountProfitPct ,AccountProfit ,AccountComm ,CommFlag ,CreatorID ,CreateTime ) 
                                                                    VALUES ( @CompanyID ,@BranchID ,@SourceType ,@SourceID ,@SubSourceID ,@Income ,@ProfitPct ,@Profit ,@CommType ,@CommValue ,@AccountID ,@AccountProfitPct ,@AccountProfit ,@AccountComm ,@CommFlag ,@CreatorID ,@CreateTime ) ";

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
                                                , db.Parameter("@CommType", ProductRuleModel.ECardSACommType, DbType.Int32)//该业绩的提成方式
                                                , db.Parameter("@CommValue", ProductRuleModel.ECardSACommValue, DbType.Decimal)//该业绩的提成数值
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
                                #endregion
                            }
                        }

                        #endregion

                        if (Math.Round(totalMyCalAmount, 2, MidpointRounding.AwayFromZero) != model.TotalPrice)
                        {
                            db.RollbackTransaction();
                            return 7;
                        }

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
                                if (orderUnpaidPrice <= 0 || orderUnpaidPrice < model.TotalPrice)
                                {
                                    return 0;
                                }
                                unpaidPrice = orderUnpaidPrice - model.TotalPrice;
                                if (unpaidPrice == 0)
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

                        #region 消费赠送

                        #region 积分卡
                        string strSqlGetPointBalance = @" SELECT TOP 1
                                                                T1.Balance ,
                                                                T2.PresentRate ,
                                                                UserCardNo
                                                        FROM    [TBL_CUSTOMER_CARD] T1 WITH ( NOLOCK )
                                                                INNER JOIN [MST_CARD] T2 WITH ( NOLOCK ) ON T1.CardID = T2.ID
                                                        WHERE   T1.CompanyID = @CompanyID
                                                                AND T1.UserID = @CustomerID
                                                                AND T2.Available = 1
                                                                AND T2.CardTypeID = 2 ";
                        DataTable pointDT = db.SetCommand(strSqlGetPointBalance
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteDataTable();

                        if (pointDT != null && pointDT.Rows.Count != 1)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        decimal pointPresentRate = HS.Framework.Common.Util.StringUtils.GetDbDecimal(pointDT.Rows[0]["PresentRate"]);
                        decimal pointBalance = HS.Framework.Common.Util.StringUtils.GetDbDecimal(pointDT.Rows[0]["Balance"]);
                        decimal pointUserCardNo = HS.Framework.Common.Util.StringUtils.GetDbDecimal(pointDT.Rows[0]["UserCardNo"]);

                        decimal pointPaymentAmount = Math.Abs(model.TotalPrice * pointPresentRate);
                        pointPaymentAmount = Math.Round(pointPaymentAmount, 2, MidpointRounding.AwayFromZero);
                        pointBalance = pointBalance + pointPaymentAmount;

                        if (pointPaymentAmount > 0)
                        {
                            string strAddPointBalance = @" INSERT INTO [TBL_POINT_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CreatorID ,@CreateTime)";

                            int addPointres = db.SetCommand(strAddPointBalance
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                    , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                    , db.Parameter("@CustomerBalanceID", customerBalanceID, DbType.Int32)
                                    , db.Parameter("@ActionMode", 3, DbType.Int32)//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                    , db.Parameter("@DepositMode", 0, DbType.Int32)//1:充值、2:余额转入
                                    , db.Parameter("@Remark", model.Remark, DbType.String)
                                    , db.Parameter("@UserCardNo", pointUserCardNo, DbType.String)
                                    , db.Parameter("@Amount", pointPaymentAmount, DbType.Decimal)
                                    , db.Parameter("@Balance", pointBalance, DbType.Decimal)
                                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                            if (addPointres <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            #region 修改CustomerCard中的Balance
                            string strUpdatePointCard = @" UPDATE [TBL_CUSTOMER_CARD] SET Balance=@Balance WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo";
                            int updatePointRes = db.SetCommand(strUpdatePointCard, db.Parameter("@Balance", pointBalance, DbType.Decimal)
                                                                 , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                 , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                                 , db.Parameter("@UserCardNo", pointUserCardNo, DbType.String)).ExecuteNonQuery();

                            if (updatePointRes == 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                            #endregion
                        }
                        #endregion

                        #region 现金券
                        string strSqlGetCouponBalance = @" SELECT TOP 1
                                                                T1.Balance ,
                                                                T2.PresentRate ,
                                                                UserCardNo
                                                        FROM    [TBL_CUSTOMER_CARD] T1 WITH ( NOLOCK )
                                                                INNER JOIN [MST_CARD] T2 WITH ( NOLOCK ) ON T1.CardID = T2.ID
                                                        WHERE   T1.CompanyID = @CompanyID
                                                                AND T1.UserID = @CustomerID
                                                                AND T2.Available = 1
                                                                AND T2.CardTypeID = 3 ";
                        DataTable couponDT = db.SetCommand(strSqlGetCouponBalance
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteDataTable();

                        if (couponDT != null && couponDT.Rows.Count != 1)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        decimal couponPresentRate = HS.Framework.Common.Util.StringUtils.GetDbDecimal(couponDT.Rows[0]["PresentRate"]);
                        decimal couponBalance = HS.Framework.Common.Util.StringUtils.GetDbDecimal(couponDT.Rows[0]["Balance"]);
                        decimal couponUserCardNo = HS.Framework.Common.Util.StringUtils.GetDbDecimal(couponDT.Rows[0]["UserCardNo"]);

                        decimal couponPaymentAmount = Math.Abs(model.TotalPrice * couponPresentRate);
                        couponPaymentAmount = Math.Round(couponPaymentAmount, 2, MidpointRounding.AwayFromZero);
                        couponBalance = couponBalance + couponPaymentAmount;

                        if (couponPaymentAmount > 0)
                        {
                            string strAddCouponBalance = @" INSERT INTO [TBL_COUPON_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CouponType ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CouponType ,@CreatorID ,@CreateTime)";

                            int addCouponres = db.SetCommand(strAddCouponBalance,
                                    db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                    db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                    db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                                    db.Parameter("@CustomerBalanceID", customerBalanceID, DbType.Int32),
                                    db.Parameter("@ActionMode", 3, DbType.Int32),// 1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                    db.Parameter("@DepositMode", 0, DbType.Int32),//1:充值、2:余额转入
                                    db.Parameter("@Remark", model.Remark, DbType.String),
                                    db.Parameter("@UserCardNo", couponUserCardNo, DbType.String),
                                    db.Parameter("@Amount", couponPaymentAmount, DbType.Decimal),
                                    db.Parameter("@Balance", couponBalance, DbType.Decimal),
                                    db.Parameter("@CouponType", 0, DbType.Int32),
                                    db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                    db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                            if (addCouponres <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            #region 修改CustomerCard中的Balance
                            string strUpdateCouponCard = @" UPDATE [TBL_CUSTOMER_CARD] SET Balance=@Balance WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo";
                            int updateCouponRes = db.SetCommand(strUpdateCouponCard, db.Parameter("@Balance", couponBalance, DbType.Decimal)
                                                                 , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                 , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                                 , db.Parameter("@UserCardNo", couponUserCardNo, DbType.String)).ExecuteNonQuery();

                            if (updateCouponRes == 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                            #endregion
                        }
                        #endregion

                        #endregion

                        #endregion

                        model.SlaveID = new List<int>();



                        #region 美丽顾问/销售顾问

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
                            model.SlaveID.Add(HS.Framework.Common.Util.StringUtils.GetDbInt(ResponsiblePersonID));
                        }
                        #endregion

                        string advanced = Company_DAL.Instance.getAdvancedByCompanyID(model.CompanyID);
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
                                    model.SlaveID.Add(HS.Framework.Common.Util.StringUtils.GetDbInt(SalesPersonID));
                                }
                            }
                            #endregion
                        }
                        #endregion

                        #region 插入业绩分享表
                        if (model.SlaveID != null && model.SlaveID.Count > 0)
                        {
                            foreach (int item in model.SlaveID)
                            {
                                string strAddProfitSql = @" INSERT	INTO TBL_PROFIT( MasterID ,SlaveID ,Type ,Available ,CreateTime ,CreatorID) 
                                                VALUES (@MasterID ,@SlaveID ,@Type ,@Available ,@CreateTime ,@CreatorID)";
                                int addProfitres = db.SetCommand(strAddProfitSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@MasterID", paymentID, DbType.Int64)
                                        , db.Parameter("@SlaveID", item, DbType.Int64)
                                        , db.Parameter("@Type", 2, DbType.Int32)
                                        , db.Parameter("@Available", true, DbType.Boolean)
                                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)).ExecuteNonQuery();

                                if (addProfitres <= 0)
                                {
                                    if (DelCustomerLocked(db, model.CustomerID))
                                    {
                                        db.RollbackTransaction();
                                    }
                                    LogUtil.Log("插入业绩表出错", "PaymentID:" + paymentID + "插入业绩表出错。");
                                    return 0;
                                }
                            }
                        }
                        #endregion

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
            else
            {
                return 0;
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

        public List<UnPaidListByCustomerID_Model> getUnPaidListByCustomerID(int companyID, int customerID)
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
                                            T1.BranchID ,
                                            T5.BranchName ,
                                            T4.Name AS ResponsiblePersonName ,
                                            CASE T1.ProductType WHEN 0 THEN T2.ServiceName ELSE T3.CommodityName END AS ProductName ,
                                            CASE T1.ProductType WHEN 0 THEN T2.Quantity ELSE T3.Quantity END AS Quantity,
                                            CASE T1.ProductType WHEN 0 THEN T2.ID ELSE T3.ID END AS OrderObjectID,
											CASE T1.ProductType WHEN 0 THEN T7.CardName ELSE T9.CardName END AS CardName ,
                                            CASE T1.ProductType WHEN 0 THEN T7.ID ELSE T9.ID END AS CardID 
                                    FROM    [ORDER] T1 WITH ( NOLOCK )
                                            LEFT JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.ID = T2.OrderID
                                            LEFT JOIN [TBL_ORDER_COMMODITY] T3 WITH ( NOLOCK ) ON T1.ID = T3.OrderID
                                            LEFT JOIN [TBL_BUSINESS_CONSULTANT] T10 WITH(NOLOCK) ON T10.MasterID=T1.ID AND T10.BusinessType=1 AND T10.ConsultantType=1  
                                            LEFT JOIN [ACCOUNT] T4 WITH ( NOLOCK ) ON T10.ConsultantID = T4.UserID
                                            LEFT JOIN [BRANCH] T5 WITH(NOLOCK) ON T1.BranchID=T5.ID 
											LEFT JOIN [TBL_CUSTOMER_CARD] T6 ON T2.UserCardNo = T6.UserCardNo
											LEFT JOIN [MST_CARD] T7 ON T6.CardID = T7.ID 
											LEFT JOIN [TBL_CUSTOMER_CARD] T8 ON T3.UserCardNo = T8.UserCardNo
											LEFT JOIN [MST_CARD] T9 ON T8.CardID = T9.ID
                                   WHERE   T1.CompanyID = @CompanyID 
                                           AND T1.CustomerID = @CustomerID
                                           AND ( T1.PaymentStatus = 1 OR PaymentStatus = 2 )
                                           AND T1.UnPaidPrice > 0
                                           AND T1.RecordType = 1 
                                           AND T1.Status <> 3 AND T1.Status <> 4
                                           AND T1.OrderTime > T5.StartTime";


                strSql += " ORDER BY T1.OrderTime desc ";
                list = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
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
                                            T5.BranchName
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
                                            CASE T1.PaymentMode
                                              WHEN 0 THEN '现金'
                                              WHEN 2 THEN '银行卡'
                                              WHEN 3 THEN '其他'
                                              WHEN 4 THEN '免支付'
                                              WHEN 5 THEN '过去支付' 
                                              WHEN 8 THEN '微信第三方支付' 
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

        public List<Profit_Model> getProfitListByMasterID(int masterID, int type)
        {
            List<Profit_Model> list = new List<Profit_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT  T2.Name AS AccountName,T2.UserID As AccountID
                                    FROM    TBL_PROFIT T1 WITH ( NOLOCK )
                                            LEFT JOIN ACCOUNT T2 WITH ( NOLOCK ) ON T1.SlaveID = T2.UserID
                                    WHERE   T1.Type = @Type
                                            AND T1.MasterID = @MasterID ";

                list = db.SetCommand(strSql, db.Parameter("@Type", type, DbType.Int32)
                                           , db.Parameter("@MasterID", masterID, DbType.Int32)).ExecuteList<Profit_Model>();

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

        private bool IsHasCustomerLocked(DbManager db, int customerID)
        {
            try
            {
                string strCustomerLockerSql = @"INSERT INTO SYS_CustomerLocked ( CustomerID ) VALUES  ( @CustomerID );select @@IDENTITY";
                int lockedID = db.SetCommand(strCustomerLockerSql
                    , db.Parameter("@CustomerID", customerID, DbType.Int32)).ExecuteNonQuery();

                if (lockedID <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }
            }
            catch (Exception ex)
            {
                db.RollbackTransaction();
                return false;
            }

            return true;
        }

        private bool DelCustomerLocked(DbManager db, int customerID)
        {
            try
            {
                string strDelCustomerLockedSql = "DELETE FROM [SYS_CustomerLocked] WHERE CustomerID=@CustomerID";
                int delres = db.SetCommand(strDelCustomerLockedSql
                , db.Parameter("@CustomerID", customerID, DbType.Int32)).ExecuteNonQuery();

                if (delres <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }
            }
            catch (Exception ex)
            {
                db.RollbackTransaction();
                return false;
            }

            return true;
        }


        /// <summary>
        /// 
        /// </summary>
        /// <param name="netTradeNo"></param>
        /// <returns>-1:NetTradeNo不存在 0:没有处理过 1:已经处理过</returns>
        public int HasTradePay(string netTradeNo)
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

                string strSql = @" SELECT  COUNT(0)
                                FROM    [TBL_WEIXINPAY_RESULT] T1 WITH ( NOLOCK )
                                WHERE   T1.NetTradeNo = @NetTradeNo ";

                res = db.SetCommand(strSql
                   , db.Parameter("@NetTradeNo", netTradeNo, DbType.String)).ExecuteScalar<int>();

                if (res <= 0)
                {
                    return 0;
                }

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
                                           T1.NetTradeActionMode , 
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
                                                    END AS DisplayResult ,T4.ProductPromotionName
                                    FROM    [TBL_NETTRADE_CONTROL] T1 WITH ( NOLOCK )
                                            LEFT JOIN [TBL_WEIXINPAY_RESULT] T2 WITH ( NOLOCK ) ON T1.NetTradeNo = T2.NetTradeNo
											LEFT JOIN [TBL_RUSH_ORDER] T3 ON T1.NetTradeNo = T3.NetTradeNo
											LEFT JOIN [TBL_PROMOTION_PRODUCT] T4 ON T3.PromotionID = T4.PromotionID AND T3.ProductID = T4.ProductID AND T3.ProductType = T4.ProductType
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

        public int AddRushTradePay(WeChatReturn_Model weChatModel, DateTime time)
        {
            using (DbManager db = new DbManager())
            {
                string strSelOrderIDs = @" SELECT  T1.CompanyID ,
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
                                        T1.CustomerID ,
                                        T1.RushOrderID ,
                                        CASE T1.ProductType WHEN 0 THEN T3.Code ELSE T4.Code END AS ProductCode ,
                                        CONVERT(VARCHAR(16), T1.CreateTime, 20) CreateTime  
                                FROM    [TBL_RUSH_ORDER] T1 WITH ( NOLOCK )
                                        LEFT JOIN [BRANCH] T2 ON T1.BranchID = T2.ID 
                                        LEFT JOIN [SERVICE] T3 ON T1.ProductID=T3.ID
                                        LEFT JOIN [COMMODITY] T4 ON T1.ProductID=T4.ID
                                WHERE   T1.NetTradeNo = @NetTradeNo ";

                GetRushOrderDetail_Model rushModel = db.SetCommand(strSelOrderIDs
                    , db.Parameter("@NetTradeNo", weChatModel.out_trade_no, DbType.String)).ExecuteObject<GetRushOrderDetail_Model>();

                if (rushModel == null || rushModel.RushOrderID <= 0)
                {
                    return 0;
                }

                PaymentCheck_Model paymentCheckModel = new PaymentCheck_Model();

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
                #endregion

                #region 权限设置
                //PaymentBranchRole paymentBranchRole = new PaymentBranchRole();
                //paymentBranchRole.IsCustomerConfirm = true;
                //paymentBranchRole.IsAccountEcardPay = false;
                //paymentBranchRole.IsPartPay = false;

                string strSqlCommand = @"select IsPay as IsAccountEcardPay,IsConfirmed as IsCustomerConfirm,IsPartPay,IsUseRate from [BRANCH] 
                                                where BRANCH.ID = @BranchID ";

                PaymentBranchRole paymentBranchRole = db.SetCommand(strSqlCommand,
                                                db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteObject<PaymentBranchRole>();

                if (paymentBranchRole == null)
                {
                    return 0;
                }

                #endregion

                db.BeginTransaction();


                int hasRes = HasTradePay(weChatModel.out_trade_no);
                if (hasRes != 0)
                {
                    db.RollbackTransaction();
                    return 1;
                }

                #region 插入PayMent表
                string strSqlPayAdd = @"insert into PAYMENT(CompanyID,OrderNumber,TotalPrice,CreatorID,CreateTime,Remark,PaymentTime,LevelID,Type,Status,BranchID,ClientType) 
                                              values (@CompanyID,@OrderNumber,@TotalPrice,@CreatorID,@CreateTime,@Remark,@PaymentTime,@LevelID,@Type,@Status,@BranchID,@ClientType);select @@IDENTITY";
                int paymentID = db.SetCommand(strSqlPayAdd,
                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                            db.Parameter("@OrderNumber", 1, DbType.Int32),
                            db.Parameter("@TotalPrice", (weChatModel.cash_fee / 100), DbType.Decimal),
                            db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                            db.Parameter("@CreateTime", time, DbType.DateTime),
                            db.Parameter("@Remark", model.Remark, DbType.String),
                            db.Parameter("@PaymentTime", time, DbType.DateTime),
                            db.Parameter("@LevelID", DBNull.Value, DbType.Int32),
                            db.Parameter("@Type", 1, DbType.Int32),//1：支付 2：退款
                            db.Parameter("@Status", 2, DbType.Int32),//1：无效 2：执行 3：撤销
                            db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                            db.Parameter("@ClientType", 1, DbType.Int32)).ExecuteScalar<int>();

                if (paymentID <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
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
                                     , db.Parameter("@PaymentAmount", (weChatModel.cash_fee / 100), DbType.Decimal)
                                     , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                     , db.Parameter("@CreateTime", time, DbType.DateTime)
                                     , db.Parameter("@UserCardNo", "", DbType.String)
                                     , db.Parameter("@CardPaidAmount", (weChatModel.cash_fee / 100), DbType.Decimal)
                                     , db.Parameter("@ProfitRate", 1, DbType.Decimal)).ExecuteScalar<int>();

                    if (paymentDetailID <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                }

                #endregion

                #region 获取一商品一些属性
                int OrderSource = 5;//0:普通下单 1:需求转换订单 2:购物车转换订单 3:预约转换订单 4：订单导入 5：促销（抢购）
                string SourceID = rushModel.PromotionID;
                Commodity_Model com_model = new Commodity_Model();
                string subServiceIDs = "";
                string[] arrSubServiceCodes = null;
                List<int> arrSubServiceID = new List<int>();
                if (rushModel.ProductType == 0)
                {
                    string strSqlSelectProId = @"select T1.ID ,T1.MarketingPolicy ,T1.UnitPrice ,T1.PromotionPrice,T1.SubServiceCodes ,T1.DiscountID ,T1.ServiceName AS CommodityName ,T1.CourseFrequency ,T1.ExpirationDate    
                                                            FROM [SERVICE] T1 WITH(NOLOCK) 
                                                            WHERE T1.CompanyID=@CompanyID AND T1.ID=@ProductID 
                                                            ORDER BY T1.CreateTime DESC";
                    com_model = db.SetCommand(strSqlSelectProId,
                    db.Parameter("@CompanyID", rushModel.CompanyID, DbType.Int32),
                    db.Parameter("@ProductID", rushModel.ProductID, DbType.Int64),
                    db.Parameter("@BranchID", rushModel.BranchID, DbType.Int32)).ExecuteObject<Commodity_Model>();

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
                                return 0;
                            }
                            subServiceIDs += "|" + subServiceID.ToString();
                            arrSubServiceID.Add(subServiceID);
                        }

                        #endregion

                        subServiceIDs += "|";
                    }

                    #endregion
                }
                else
                {
                    string strSqlSelectProId = @"select T1.ID ,T1.MarketingPolicy ,T1.UnitPrice ,T1.PromotionPrice,'' AS SubServiceCodes ,T1.DiscountID ,T1.CommodityName 
                                                            FROM [COMMODITY] T1 WITH(NOLOCK) 
                                                            WHERE T1.CompanyID=@CompanyID AND T1.ID=@ProductID 
                                                            ORDER BY T1.CreateTime DESC";
                    com_model = db.SetCommand(strSqlSelectProId,
                    db.Parameter("@CompanyID", rushModel.CompanyID, DbType.Int32),
                    db.Parameter("@ProductID", rushModel.ProductID, DbType.Int64),
                    db.Parameter("@BranchID", rushModel.BranchID, DbType.Int32)).ExecuteObject<Commodity_Model>();
                }
                #endregion

                #region 修改RushOrderPaymentStatus
                string strUpdatePaymentStatusSql = @" update TBL_RUSH_ORDER set PaymentStatus=2,UpdaterID=@UpdaterID, UpdateTime=@UpdateTime
where CustomerID=@CustomerID and PromotionID=@PromotionID and ProductID=@ProductID and ProductType=@ProductType and RushOrderID=@RushOrderID ";
                int updatePaymentStatusRes = db.SetCommand(strUpdatePaymentStatusSql
                            , db.Parameter("@UpdaterID", rushModel.CustomerID, DbType.Int32)
                            , db.Parameter("@UpdateTime", time, DbType.DateTime)
                            , db.Parameter("@CustomerID", rushModel.CustomerID, DbType.Int32)
                            , db.Parameter("@PromotionID", rushModel.PromotionID, DbType.String)
                            , db.Parameter("@ProductID", rushModel.ProductID, DbType.Int32)
                            , db.Parameter("@ProductType", rushModel.ProductType, DbType.Int32)
                            , db.Parameter("@RushOrderID", rushModel.RushOrderID, DbType.Int32)).ExecuteNonQuery();

                if (updatePaymentStatusRes <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                #region 插入Order表
                string strSqlInsertOrder = @"insert into [ORDER] (CompanyID,BranchID,CustomerID,OrderTime,ProductType,Quantity,TotalOrigPrice,TotalCalcPrice,TotalSalePrice,Status,OrderSource,SourceID,CreatorID,CreateTime,UnPaidPrice,PaymentStatus)
                            values (@CompanyID,@BranchID,@CustomerID,@OrderTime,@ProductType,@Quantity,@TotalOrigPrice,@TotalCalcPrice,@TotalSalePrice,@Status,@OrderSource,@SourceID,@CreatorID,@CreateTime,@UnPaidPrice,@PaymentStatus);select @@IDENTITY";

                object objIDs = DBNull.Value;
                if (!string.IsNullOrEmpty(subServiceIDs) && subServiceIDs != "")
                {
                    objIDs = subServiceIDs;
                }

                int PaymentStatus = 1;
                decimal UnPaidPrice = rushModel.TotalRushPrice;

                if (weChatModel.total_fee / 100 >= rushModel.TotalRushPrice)
                {
                    PaymentStatus = 3;
                    UnPaidPrice = 0;
                }
                else if (weChatModel.total_fee / 100 > 0 && weChatModel.total_fee / 100 < rushModel.TotalRushPrice)
                {
                    PaymentStatus = 2;
                    UnPaidPrice = rushModel.TotalRushPrice - weChatModel.total_fee / 100;
                }

                int orderID = db.SetCommand(strSqlInsertOrder
                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                , db.Parameter("@CustomerID", rushModel.CustomerID, DbType.Int32)
                , db.Parameter("@OrderTime", time, DbType.DateTime2)
                , db.Parameter("@ProductType", rushModel.ProductType, DbType.Int32)
                , db.Parameter("@Quantity", rushModel.RushQuantity, DbType.Int32)
                , db.Parameter("@TotalOrigPrice", (rushModel.OrigPrice * rushModel.RushQuantity), DbType.Decimal)
                , db.Parameter("@TotalCalcPrice", rushModel.TotalRushPrice, DbType.Decimal)
                , db.Parameter("@TotalSalePrice", rushModel.TotalRushPrice, DbType.Decimal)
                , db.Parameter("@Status", 1, DbType.Int32)// 订单状态：1:未完成、2：已完成 、3：已取消、4:已终止
                , db.Parameter("@OrderSource", OrderSource, DbType.Int32)
                , db.Parameter("@SourceID", SourceID, DbType.String)
                , db.Parameter("@CreateTime", time, DbType.DateTime2)
                , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                , db.Parameter("@UnPaidPrice", UnPaidPrice, DbType.Decimal)
                , db.Parameter("@PaymentStatus", PaymentStatus, DbType.Int32) // 支付状态 1：未支付 2：部分付 3：已支付
                ).ExecuteScalar<int>();

                if (orderID <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion             

                #region 插入OrderPayment关系表
                string strSqlOrderPayAdd = @"insert into TBL_OrderPayment_RelationShip(OrderID,PaymentID) 
                                                                values (@OrderID,@PaymentID);select @@IDENTITY";
                int orderPaymentRes = db.SetCommand(strSqlOrderPayAdd
                                      , db.Parameter("@OrderID", orderID, DbType.Int32)
                                      , db.Parameter("@PaymentID", paymentID, DbType.Int32)).ExecuteNonQuery();

                if (orderPaymentRes <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                if (rushModel.ProductType == 1)
                {
                    #region 插入商品订单表
                    string strAddOrderCommodity = @"INSERT INTO dbo.TBL_ORDER_COMMODITY( CompanyID ,BranchID ,CustomerID ,OrderID ,UserCardNo ,CommodityCode ,CommodityID ,CommodityName ,Quantity ,SumOrigPrice ,SumCalcPrice ,SumSalePrice ,Remark ,Status ,DeliveredAmount ,UndeliveredAmount ,ReturnedAmount ,CreatorID ,CreateTime ) 
VALUES ( @CompanyID ,@BranchID ,@CustomerID ,@OrderID ,@UserCardNo ,@CommodityCode ,@CommodityID ,@CommodityName ,@Quantity ,@SumOrigPrice ,@SumCalcPrice ,@SumSalePrice ,@Remark ,@Status ,@DeliveredAmount ,@UndeliveredAmount ,@ReturnedAmount ,@CreatorID ,@CreateTime ) ;select @@IDENTITY";

                    int orderObjectID = db.SetCommand(strAddOrderCommodity
                                         , db.Parameter("@CompanyID", rushModel.CompanyID, DbType.Int32)
                                         , db.Parameter("@BranchID", rushModel.BranchID, DbType.Int32)
                                         , db.Parameter("@CustomerID", rushModel.CustomerID, DbType.Int32)
                                         , db.Parameter("@OrderID", orderID, DbType.Int32)
                                         , db.Parameter("@UserCardNo", "", DbType.String)
                                         , db.Parameter("@CommodityCode", rushModel.ProductCode, DbType.Int64)
                                         , db.Parameter("@CommodityID", rushModel.ProductID, DbType.Int32)
                                         , db.Parameter("@CommodityName", com_model.CommodityName, DbType.String)
                                         , db.Parameter("@Quantity", rushModel.RushQuantity, DbType.Int32)
                                         , db.Parameter("@SumOrigPrice", (rushModel.OrigPrice * rushModel.RushQuantity), DbType.Decimal)
                                         , db.Parameter("@SumCalcPrice", rushModel.TotalRushPrice, DbType.Decimal)
                                         , db.Parameter("@SumSalePrice", rushModel.TotalRushPrice, DbType.Decimal)
                                         , db.Parameter("@Remark", rushModel.Remark, DbType.String)
                                         , db.Parameter("@Status", 1, DbType.Int32)// 状态：1:未完成、2：已完成 、3：已取消、4:已终止
                                         , db.Parameter("@DeliveredAmount", 0, DbType.Int32)// 已交付数量
                                         , db.Parameter("@UndeliveredAmount", 0, DbType.Int32)
                                         , db.Parameter("@ReturnedAmount", 0, DbType.Int32)// 退货数量
                                         , db.Parameter("@CreateTime", time, DbType.DateTime2)
                                         , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)).ExecuteScalar<int>();

                    if (orderObjectID <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    #endregion

                    #region 查询库存
                    string strSqlSelectQty = @" SELECT TOP 1 * FROM [TBL_PRODUCT_STOCK] WHERE ProductCode=@ProductCode AND CompanyID=@CompanyID AND BranchID=@BranchID ORDER BY ID DESC ";
                    ProductStockOperation_Model stockModel = db.SetCommand(strSqlSelectQty,
                    db.Parameter("@ProductCode", rushModel.ProductCode, DbType.Int64),
                    db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                    db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteObject<ProductStockOperation_Model>();

                    if (stockModel == null)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    #endregion

                    #region 修改库存
                    string strSqlUpdateStock = @" UPDATE TBL_PRODUCT_STOCK SET ProductQty=ProductQty-@ProductQty,OperatorID=@OperatorID,OperateTime=@OperateTime WHERE ProductCode=@ProductCode AND CompanyID=@CompanyID AND BranchID=@BranchID ";
                    int updatestockrs = db.SetCommand(strSqlUpdateStock,
                    db.Parameter("@ProductQty", rushModel.RushQuantity, DbType.Int32),
                    db.Parameter("@OperatorID", model.CreatorID, DbType.Int32),
                    db.Parameter("@OperateTime", time, DbType.DateTime2),
                    db.Parameter("@ProductCode", rushModel.ProductCode, DbType.Int64),
                    db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                    db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteNonQuery();

                    if (updatestockrs <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    #endregion

                    #region 插入库存操作记录表
                    string strSqlInsertStockLog = @"INSERT INTO [TBL_PRODUCT_STOCK_OPERATELOG](CompanyID,BranchID,ProductType,ProductCode,OperateType,OperateQty,OperateSign,OrderID,ProductQty,OperatorID,OperateTime)
VALUES(@CompanyID,@BranchID,@ProductType,@ProductCode,@OperateType,@OperateQty,@OperateSign,@OrderID,@ProductQty,@OperatorID,@OperateTime)";
                    int insertStocklogRs = db.SetCommand(strSqlInsertStockLog,
                    db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                    db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                    db.Parameter("@ProductType", 1, DbType.Int32),
                    db.Parameter("@ProductCode", rushModel.ProductCode, DbType.Int64),
                    db.Parameter("@OperateType", 4, DbType.Int32),//售出 
                    db.Parameter("@OperateQty", rushModel.RushQuantity, DbType.Int32),
                    db.Parameter("@OperateSign", "-", DbType.String),
                    db.Parameter("@OrderID", orderID, DbType.Int32),
                    db.Parameter("@ProductQty", stockModel.ProductQty - rushModel.RushQuantity, DbType.Int32),
                    db.Parameter("@OperatorID", model.CreatorID, DbType.Int32),
                    db.Parameter("@OperateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)).ExecuteNonQuery();

                    if (insertStocklogRs <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    #endregion
                }
                else
                {
                    #region 服务操作
                    string strAddOrderServiceSql = @"INSERT INTO [TBL_ORDER_SERVICE]( CompanyID ,BranchID  ,CustomerID ,OrderID ,UserCardNo ,ServiceCode ,ServiceID ,ServiceName ,Quantity ,SumOrigPrice ,SumCalcPrice ,SumSalePrice ,Remark ,Status ,SubServiceIDs ,IsPast ,TGPastCount ,TGExecutingCount ,TGFinishedCount ,TGLastTime ,TGTotalCount ,Available ,CreatorID ,CreateTime ,Expirationtime ) 
VALUES ( @CompanyID ,@BranchID  ,@CustomerID ,@OrderID ,@UserCardNo ,@ServiceCode ,@ServiceID ,@ServiceName ,@Quantity ,@SumOrigPrice ,@SumCalcPrice ,@SumSalePrice ,@Remark ,@Status ,@SubServiceIDs ,@IsPast ,@TGPastCount ,@TGExecutingCount ,@TGFinishedCount ,@TGLastTime ,@TGTotalCount ,@Available ,@CreatorID ,@CreateTime ,@Expirationtime ) ;select @@IDENTITY";

                    int orderObjectID = db.SetCommand(strAddOrderServiceSql
                                         , db.Parameter("@CompanyID", rushModel.CompanyID, DbType.Int32)
                                         , db.Parameter("@BranchID", rushModel.BranchID, DbType.Int32)
                                         , db.Parameter("@CustomerID", rushModel.CustomerID, DbType.Int32)
                                         , db.Parameter("@OrderID", orderID, DbType.Int32)
                                         , db.Parameter("@UserCardNo", "", DbType.String)
                                         , db.Parameter("@ServiceCode", rushModel.ProductCode, DbType.Int64)
                                         , db.Parameter("@ServiceID", rushModel.ProductID, DbType.Int32)
                                         , db.Parameter("@ServiceName", com_model.CommodityName, DbType.String)
                                         , db.Parameter("@Quantity", rushModel.RushQuantity, DbType.Int32)
                                         , db.Parameter("@SumOrigPrice", (rushModel.OrigPrice * rushModel.RushQuantity), DbType.Decimal)
                                         , db.Parameter("@SumCalcPrice", rushModel.TotalRushPrice, DbType.Decimal)
                                         , db.Parameter("@SumSalePrice", rushModel.TotalRushPrice, DbType.Decimal)
                                         , db.Parameter("@Remark", rushModel.Remark, DbType.String)
                                         , db.Parameter("@Status", 1, DbType.Int32)// 状态：1:未完成、2：已完成 、3：已取消、4:已终止
                                         , db.Parameter("@SubServiceIDs", objIDs, DbType.String)
                                         , db.Parameter("@IsPast", false, DbType.Boolean)
                                         , db.Parameter("@TGExecutingCount", 0, DbType.Int32)
                                         , db.Parameter("@TGFinishedCount", 0, DbType.Int32)
                                         , db.Parameter("@TGTotalCount", com_model.CourseFrequency * rushModel.RushQuantity, DbType.Int32)
                                         , db.Parameter("@TGPastCount", 0, DbType.Int32)
                                         , db.Parameter("@TGLastTime", null, DbType.DateTime2)
                                         , db.Parameter("@Available", true, DbType.Boolean)
                                         , db.Parameter("@Expirationtime", time.AddDays(com_model.ExpirationDate), DbType.DateTime2)
                                         , db.Parameter("@CreateTime", time, DbType.DateTime2)
                                         , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)).ExecuteScalar<int>();

                    if (orderObjectID <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    #endregion
                }

                string strAddNetTradeOrderSql = @" INSERT INTO TBL_NETTRADE_ORDER( CompanyID ,NetTradeNo ,OrderID ,CreatorID ,CreateTime ) 
                                                    VALUES ( @CompanyID ,@NetTradeNo ,@OrderID ,@CreatorID ,@CreateTime ) ";


                int addNetTradeOrderRes = db.SetCommand(strAddNetTradeOrderSql
                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                , db.Parameter("@NetTradeNo", weChatModel.out_trade_no, DbType.String)
                , db.Parameter("@OrderID", orderID, DbType.Int32)
                , db.Parameter("@CreatorID", rushModel.CustomerID, DbType.Int32)
                , db.Parameter("@CreateTime", time, DbType.DateTime2)).ExecuteNonQuery();

                if (addNetTradeOrderRes <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                #region 美丽顾问/销售顾问
                string strAddConsultant = @" INSERT INTO [TBL_BUSINESS_CONSULTANT]( CompanyID ,BusinessType ,MasterID ,ConsultantType ,ConsultantID ,CreatorID ,CreateTime )
                                                    VALUES ( @CompanyID ,@BusinessType ,@MasterID ,@ConsultantType ,@ConsultantID ,@CreatorID ,@CreateTime )";

                #region 美丽顾问
                string strSqlGetResponsiblePersonID = @"SELECT AccountID FROM RELATIONSHIP WHERE CustomerID=@CustomerID AND BranchID=@BranchID AND Available=1 AND Type=1 ";
                int customerResponsiblePersonID = db.SetCommand(strSqlGetResponsiblePersonID, db.Parameter("@CustomerID", rushModel.CustomerID, DbType.Int32), db.Parameter("@BranchID", rushModel.BranchID, DbType.Int32)).ExecuteScalar<int>();

                if (customerResponsiblePersonID > 0)
                {
                    int addConsultantRes = db.SetCommand(strAddConsultant
                           , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                           , db.Parameter("@BusinessType", 1, DbType.Int32)//1：订单，2：支付，3：充值
                           , db.Parameter("@MasterID", orderID, DbType.Int32)
                           , db.Parameter("@ConsultantType", 1, DbType.Int32)//1:美丽顾问 2:销售顾问
                           , db.Parameter("@ConsultantID", customerResponsiblePersonID, DbType.Int32)
                           , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                           , db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                    if (addConsultantRes <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
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
                            db.Parameter("@CompanyID", rushModel.CompanyID, DbType.Int32),
                            db.Parameter("@BranchID", rushModel.BranchID, DbType.Int32),
                            db.Parameter("@CustomerID", rushModel.CustomerID, DbType.Int32)).ExecuteScalarList<int>();

                    if (SalesPersonIDList != null || SalesPersonIDList.Count > 0)
                    {
                        foreach (int SalesPersonID in SalesPersonIDList)
                        {
                            int addConsultantRes = db.SetCommand(strAddConsultant
                            , db.Parameter("@CompanyID", rushModel.CompanyID, DbType.Int32)
                            , db.Parameter("@BusinessType", 1, DbType.Int32)//1：订单，2：支付，3：充值
                            , db.Parameter("@MasterID", orderID, DbType.Int32)
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
                }
                #endregion
                #endregion

                #region 修改TBL_PROMOTION_PRODUCT的SoldQuantity
                string strUpdateSoldSql = @" UPDATE  [TBL_PROMOTION_PRODUCT]
                                            SET     SoldQuantity = SoldQuantity + @Qty ,
                                                    UpdaterID = @UpdaterID ,
                                                    UpdateTime = @UpdateTime
                                            WHERE   PromotionID = @PromotionID
                                                    AND ProductID = @ProductID
                                                    AND ProductType = @ProductType ";
                int updateRes = db.SetCommand(strUpdateSoldSql
                    , db.Parameter("@Qty", rushModel.RushQuantity, DbType.Int32)
                    , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                    , db.Parameter("@UpdateTime", time, DbType.DateTime2)
                    , db.Parameter("@PromotionID", rushModel.PromotionID, DbType.String)
                    , db.Parameter("@ProductID", rushModel.ProductID, DbType.Int32)
                    , db.Parameter("@ProductType", rushModel.ProductType, DbType.Int32)).ExecuteNonQuery();

                if (updateRes <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
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
                                            T1.PointAmount ,
                                            T1.CouponAmount ,
                                            T1.ProductName ,
                                            T1.ChangeType ,
                                            CASE ChangeType
                                              WHEN 1 THEN '消费'
                                              WHEN 2 THEN '消费撤销'
                                              WHEN 3 THEN '账户充值'
                                              ELSE '充值撤销'
                                            END AS ChangeTypeName ,
                                            ISNULL(T2.CreateTime, T1.CreateTime) AS CreateTime ,
                                            T2.BankName ,
                                            T2.TransactionID ,
                                            ISNULL(T2.TradeState, '') AS TradeState , 
                                            ISNULL(T2.ResultCode, '') AS ResultCode , 
                                            T2.ErrCode , 
                                            T2.ErrCodeDes
                                    FROM    [TBL_NETTRADE_CONTROL] T1 WITH ( NOLOCK )
                                            LEFT JOIN [TBL_WEIXINPAY_RESULT] T2 WITH ( NOLOCK ) ON T1.NetTradeNo = T2.NetTradeNo
                                            LEFT JOIN [TBL_NETTRADE_ORDER] T3 WITH ( NOLOCK ) ON T1.NetTradeNo = T3.NetTradeNo
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
    }
}
