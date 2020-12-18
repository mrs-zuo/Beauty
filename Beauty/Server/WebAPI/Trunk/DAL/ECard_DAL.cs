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

namespace WebAPI.DAL
{
    public class ECard_DAL
    {
        #region 构造类实例
        public static ECard_DAL Instance
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
            internal static readonly ECard_DAL instance = new ECard_DAL();
        }
        #endregion

        public List<GetECardList_Model> GetCustomerCardList(int companyID, int branchID, int customerID)
        {
            using (DbManager db = new DbManager())
            {
                List<GetECardList_Model> list = new List<GetECardList_Model>();

                string strSql = @"SELECT  T2.UserCardNo ,
                                        T1.CardTypeID,
                                        T1.CardName ,
                                        cast(T2.Balance as dec(17,2)) AS Balance,
                                        CASE WHEN T4.DefaultCardNo = T2.UserCardNo THEN 1 ELSE 0 END AS IsDefault ,
                                        CAST(T1.Rate AS dec(12,2)) AS Rate ,
                                        CAST(T1.PresentRate AS dec(12,2)) AS PresentRate  
                                FROM    [MST_CARD] T1 WITH ( NOLOCK )
                                        LEFT JOIN [TBL_CUSTOMER_CARD] T2 WITH ( NOLOCK ) ON T1.ID = T2.CardID
                                        LEFT JOIN [MST_CARD_BRANCH] T3 WITH ( NOLOCK ) ON T1.ID = T3.CardID
                                        LEFT JOIN [CUSTOMER] T4 WITH ( NOLOCK ) ON T2.UserID = T4.UserID
                                WHERE   T1.CompanyID = @CompanyID
                                        AND T2.UserID = @CustomerID
                                        AND T1.CardTypeID = 1";
                if (branchID > 0)
                {
                    strSql += " AND T3.BranchID = @BranchID ";
                }
                else
                {
                    strSql += " GROUP BY T2.UserCardNo ,T1.CardTypeID ,T1.CardName ,T2.Balance ,T4.DefaultCardNo ,T1.Rate ,T1.PresentRate  ";
                }

                list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                           , db.Parameter("@BranchID", branchID, DbType.Int32)
                                           , db.Parameter("@CustomerID", customerID, DbType.Int32)).ExecuteList<GetECardList_Model>();

                return list;
            }
        }

        public List<GetECardList_Model> GetCustomerPointCouponList(int companyID, int branchID, int customerID)
        {
            using (DbManager db = new DbManager())
            {
                List<GetECardList_Model> list = new List<GetECardList_Model>();

                string strSql = @"SELECT  T2.UserCardNo ,
                                        T1.CardTypeID,
                                        T1.CardName ,
                                        cast(T2.Balance as dec(17,2)) AS Balance,
                                        0 AS IsDefault ,
                                        CAST(T1.Rate AS dec(12,2)) AS Rate ,
                                        CAST(T1.PresentRate AS dec(12,2)) AS PresentRate  
                                FROM    [MST_CARD] T1 WITH ( NOLOCK )
                                        LEFT JOIN [TBL_CUSTOMER_CARD] T2 WITH ( NOLOCK ) ON T1.ID = T2.CardID
                                WHERE   T1.CompanyID = @CompanyID
                                        AND T2.UserID = @CustomerID
                                        AND T1.CardTypeID != 1 ";
                list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                           , db.Parameter("@BranchID", branchID, DbType.Int32)
                                           , db.Parameter("@CustomerID", customerID, DbType.Int32)).ExecuteList<GetECardList_Model>();

                return list;
            }
        }

        public GetCardInfo_Model GetCardInfo(int companyID, int customerID, string userCardNo)
        {
            using (DbManager db = new DbManager())
            {
                GetCardInfo_Model model = new GetCardInfo_Model();

                string strSql = @"SELECT  T2.ID AS CardID ,T2.CardName ,T1.UserCardNo , cast(T1.Balance as dec(17,2)) AS Balance, T1.Currency ,T1.CardCreatedDate ,T1.CardExpiredDate ,
                                            T2.CardDescription, T2.CardTypeID AS CardType ,T3.CardTypeName ,T1.RealCardNo 
                                    FROM    [TBL_CUSTOMER_CARD] T1 WITH ( NOLOCK )
                                            INNER JOIN [MST_CARD] T2 WITH ( NOLOCK ) ON T1.CardID = T2.ID 
                                            INNER JOIN [SYS_CARDTYPE] T3 WITH(NOLOCK) ON T2.CardTypeID=T3.ID
                                    WHERE   T1.CompanyID = @CompanyID
                                            AND T1.UserID = @CustomerID
                                            AND T1.UserCardNo = @UserCardNo ";
                model = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                           , db.Parameter("@CustomerID", customerID, DbType.Int32)
                                           , db.Parameter("@UserCardNo", userCardNo, DbType.String)).ExecuteObject<GetCardInfo_Model>();

                return model;
            }
        }

        public int UpdateCustomerDefaultCard(int companyID, int accountID, int customerID, string userCardNo)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                DateTime dt = DateTime.Now.ToLocalTime();

                #region 查询卡的种类,只能是类型为1的储值卡类型才能设置默认
                string strCardTypeSelSql = @" SELECT T2.CardTypeID FROM [TBL_CUSTOMER_CARD] T1 WITH(NOLOCK)
                                            INNER JOIN [MST_CARD] T2 WITH(NOLOCK) ON T1.CardID=T2.ID
                                            WHERE T1.CompanyID=@CompanyID AND T1.UserID=@CustomerID AND T1.UserCardNo=@UserCardNo ";

                int cardType = db.SetCommand(strCardTypeSelSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                          , db.Parameter("@CustomerID", customerID, DbType.Int32)
                                                          , db.Parameter("@UserCardNo", userCardNo, DbType.String)).ExecuteScalar<int>();
                if (cardType != 1)
                {
                    return 2;
                }
                #endregion

                #region 查询用户现在默认卡的卡号
                string strSelSql = @" SELECT DefaultCardNo FROM [CUSTOMER] WITH(NOLOCK) WHERE CompanyID=@CompanyID AND UserID=@CustomerID ";
                string defaultCardNo = db.SetCommand(strSelSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                          , db.Parameter("@CustomerID", customerID, DbType.Int32)).ExecuteScalar<string>();
                #endregion

                if (defaultCardNo.Trim() != userCardNo.Trim())
                {
                    string strSqlHistoryUser = " INSERT INTO [HISTORY_CUSTOMER] SELECT * FROM [CUSTOMER] WHERE CompanyID=@CompanyID AND UserID=@CustomerID ";
                    int hisRows = db.SetCommand(strSqlHistoryUser, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                              , db.Parameter("@CustomerID", customerID, DbType.Int32)).ExecuteNonQuery();

                    if (hisRows == 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    string strSql = @"UPDATE  [CUSTOMER]
                                SET     DefaultCardNo = @userCardNo ,
                                        UpdaterID = @UpdaterID ,
                                        UpdateTime = @UpdateTime
                                WHERE   UserID = @CustomerID
                                        AND CompanyID = @CompanyID ";
                    int res = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                               , db.Parameter("@CustomerID", customerID, DbType.Int32)
                                               , db.Parameter("@UserCardNo", userCardNo, DbType.String)
                                               , db.Parameter("@UpdaterID", accountID, DbType.Int32)
                                               , db.Parameter("@UpdateTime", dt, DbType.DateTime)).ExecuteNonQuery();

                    if (res <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                }

                db.CommitTransaction();
                return 1;
            }
        }

        public bool UpdateExpirationDate(int companyID, string userCardNo, DateTime cardExpiredDate)
        {
            using (DbManager db = new DbManager())
            {
                string strSqlHistoryUser = " INSERT INTO [HST_CUSTOMER_CARD] SELECT * FROM [TBL_CUSTOMER_CARD] WHERE CompanyID=@CompanyID AND UserCardNo=@UserCardNo ";
                int hisRows = db.SetCommand(strSqlHistoryUser, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                          , db.Parameter("@UserCardNo", userCardNo, DbType.String)).ExecuteNonQuery();

                if (hisRows == 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                string strSql = @"UPDATE  [TBL_CUSTOMER_CARD]
                                SET     CardExpiredDate = @CardExpiredDate 
                                WHERE   UserCardNo = @UserCardNo
                                        AND CompanyID = @CompanyID ";
                int res = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                           , db.Parameter("@UserCardNo", userCardNo, DbType.String)
                                           , db.Parameter("@CardExpiredDate", cardExpiredDate, DbType.DateTime)).ExecuteNonQuery();

                if (res <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                return true;
            }
        }

        public List<GetCompanyCardList_Model> GetBranchCardList(int companyID, int branchID, bool isShowAll, bool isOnlyMoneyCard = false)
        {
            using (DbManager db = new DbManager())
            {
                List<GetCompanyCardList_Model> list = new List<GetCompanyCardList_Model>();

                string strSql = @"SELECT  T1.ID AS CardID ,
                                        T1.CardCode ,
                                        T1.CardName ,
                                        T1.CardTypeID,
                                        T1.CardDescription,
                                        CASE T1.ValidPeriodUnit
                                          WHEN 1 THEN DATEADD(DD, -1, DATEADD(yy, T1.VaildPeriod, GETDATE())) 
                                          WHEN 2 THEN DATEADD(DD, -1, DATEADD(mm, T1.VaildPeriod, GETDATE())) 
                                          WHEN 3 THEN DATEADD(DD, -1, DATEADD(dd, T1.VaildPeriod, GETDATE())) 
                                          WHEN 4 THEN '2099-12-31' 
                                          ELSE GETDATE()
                                        END AS CardExpiredDate,
                                        CASE WHEN T3.DefaultCardCode=T1.CardCode THEN 1 ELSE 0 END AS IsDefault
                                FROM    [MST_CARD] T1 WITH ( NOLOCK ) 
                                LEFT JOIN [MST_CARD_BRANCH] T2 WITH(NOLOCK)  ON T1.ID=T2.CardID 
                                LEFT JOIN [COMPANY] T3 WITH(NOLOCK) ON T3.DefaultCardCode=T1.CardCode AND T1.Available=1
                                WHERE   T1.CompanyID = @CompanyID ";

                if (branchID > 0)
                {
                    strSql += " AND T2.BranchID=@BranchID ";
                }

                if (!isShowAll)
                {
                    strSql += " AND T1.Available = 1 ";
                }

                if (isOnlyMoneyCard)
                {
                    strSql += " AND CardTypeID=1 ";
                }

                strSql += " GROUP BY T1.ID ,T1.CardCode ,T1.CardName ,T1.CardTypeID ,T1.CardDescription ,T1.ValidPeriodUnit ,T3.DefaultCardCode ,T1.VaildPeriod  ";

                list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                           , db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteList<GetCompanyCardList_Model>();

                return list;
            }
        }

        public List<CardDiscountList_Model> GetCardDisCountListByCardID(int companyID, int cardID)
        {
            using (DbManager db = new DbManager())
            {
                List<CardDiscountList_Model> list = new List<CardDiscountList_Model>();

                string strSql = @"SELECT  T2.DiscountName,T1.Discount
                                FROM    [TBL_CARD_DISCOUNT] T1 WITH(NOLOCK)
                                LEFT JOIN [TBL_DISCOUNT] T2 WITH(NOLOCK) ON T1.DiscountID=T2.ID AND T2.Available=1 AND T2.CompanyID=@CompanyID
                                WHERE T1.CardID=@CardID AND T2.CompanyID=@CompanyID AND T1.Available=1 AND T2.Available=1  ";


                list = db.SetCommand(strSql, db.Parameter("@CardID", cardID, DbType.Int32)
                                           , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<CardDiscountList_Model>();

                return list;
            }
        }

        public int AddCustomerCard(AddCustomerCardOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strCheckSql = " SELECT COUNT(0) FROM [TBL_CUSTOMER_CARD] WHERE CompanyID=@CompanyID AND UserID=@CustomerID AND CardID=@CardID ";
                int count = db.SetCommand(strCheckSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                    , db.Parameter("@CardID", model.CardID, DbType.Int32)).ExecuteScalar<int>();

                if (count > 0)
                {
                    return 2;
                }

                //string strSelSql=""

                db.BeginTransaction();
                object realCardNo = DBNull.Value;
                if (!string.IsNullOrWhiteSpace(model.RealCardNo))
                {
                    realCardNo = model.RealCardNo;
                }

                long userCardNo = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "UserCardNo", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<long>();

                string strSql = @" INSERT	INTO [TBL_CUSTOMER_CARD] ( CompanyID ,BranchID ,UserID ,UserCardNo ,CardID ,Currency ,Balance ,CardCreatedDate ,CardExpiredDate ,RealCardNo ,CreatorID ,CreateTime) 
                                    VALUES  (@CompanyID ,@BranchID ,@UserID ,@UserCardNo ,@CardID ,@Currency ,@Balance ,@CardCreatedDate ,@CardExpiredDate ,@RealCardNo ,@CreatorID ,@CreateTime)";

                int addRes = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                , db.Parameter("@UserCardNo", userCardNo, DbType.Int64)
                                                , db.Parameter("@CardID", model.CardID, DbType.Int32)
                                                , db.Parameter("@Currency", "CNY", DbType.String)
                                                , db.Parameter("@Balance", 0, DbType.Int32)
                                                , db.Parameter("@CardCreatedDate", model.CardCreatedDate, DbType.DateTime)
                                                , db.Parameter("@CardExpiredDate", model.CardExpiredDate, DbType.DateTime)
                                                , db.Parameter("@RealCardNo", realCardNo, DbType.String)
                                                , db.Parameter("@CreatorID", model.AccountID, DbType.Int32)
                                                , db.Parameter("@CreateTime", model.LocalTime, DbType.DateTime)).ExecuteNonQuery();
                if (addRes <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                if (model.IsDefault)
                {
                    string strSqlHistoryUser = " INSERT INTO [HISTORY_CUSTOMER] SELECT * FROM [CUSTOMER] WHERE CompanyID=@CompanyID AND UserID=@UserID ";
                    int hisRows = db.SetCommand(strSqlHistoryUser, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                              , db.Parameter("@UserID", model.CustomerID, DbType.Int32)).ExecuteNonQuery();

                    if (hisRows == 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    string strUpdateSql = @"UPDATE  [CUSTOMER]
                                SET     DefaultCardNo = @userCardNo ,
                                        UpdaterID = @UpdaterID ,
                                        UpdateTime = @UpdateTime
                                WHERE   UserID = @CustomerID
                                        AND CompanyID = @CompanyID ";
                    int res = db.SetCommand(strUpdateSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                               , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                               , db.Parameter("@UserCardNo", userCardNo, DbType.String)
                                               , db.Parameter("@UpdaterID", model.AccountID, DbType.Int32)
                                               , db.Parameter("@UpdateTime", model.LocalTime, DbType.DateTime)).ExecuteNonQuery();

                    if (res <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                }

                db.CommitTransaction();
                return 1;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns>0失败,1成功,2充值类型不对,3金额不够</returns>
        public int CardRecharge(CardRechargeOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                System.Diagnostics.StackTrace st = new System.Diagnostics.StackTrace(1, true);
                string strPgm;  //当前的程序名称及行号等监察信息

                db.BeginTransaction();

                decimal totalMoneyAmount = 0;
                decimal totalPointAmount = 0;
                decimal totalCouponAmount = 0;
                int customerBalanceChangeType = model.ChangeType;
                bool isPush = false;

                if (model.CardType == 1)
                {
                    if (model.ChangeType == 9)
                    {
                        customerBalanceChangeType = 5;
                    }
                }
                decimal BranchProfitRate = model.BranchProfitRate;

                string strAddCustomerBalance = @" INSERT [TBL_CUSTOMER_BALANCE]	( CompanyID ,BranchID ,UserID ,ChangeType ,TargetAccount  ,PaymentID ,Remark , BranchProfitRate, CreatorID ,CreateTime) 
                VALUES(@CompanyID ,@BranchID ,@UserID ,@ChangeType ,@TargetAccount  ,@PaymentID ,@Remark , @BranchProfitRate, @CreatorID ,@CreateTime);select @@IDENTITY";
                int balanceID = db.SetCommand(strAddCustomerBalance,
                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                            db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                            db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                            db.Parameter("@ChangeType", customerBalanceChangeType, DbType.Int32),
                            db.Parameter("@TargetAccount", model.CardType, DbType.Int32),
                    //db.Parameter("@ResponsiblePersonID", model.ResponsiblePersonID, DbType.Int32),
                            db.Parameter("@PaymentID", DBNull.Value, DbType.Int32),
                            db.Parameter("@Remark", model.Remark, DbType.String),
                            db.Parameter("@BranchProfitRate", BranchProfitRate, DbType.Decimal),
                            db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                            db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteScalar<int>();

                if (balanceID <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                //ActionMode 1:消费支出、2:消费支出撤销、3:储值卡充值、4:储值卡充值撤销、5:储值卡直扣、6:储值卡直扣撤销、7:储值卡直充赠送、8:储值卡直充赠送撤销、9:储值卡退款、10:储值卡退款撤销
                //DepositMode 1:现金、2:银行卡、3:余额转入、4:其他
                string strAddMoneyBalance = @" INSERT INTO [TBL_MONEY_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CreatorID ,@CreateTime)";

                //ActionMode 1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                //DepositMode 1:充值、2:余额转入
                string strAddPointBalance = @" INSERT INTO [TBL_POINT_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CreatorID ,@CreateTime)";

                //ActionMode 1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                //DepositMode 1:充值、2:余额转入
                string strAddCouponBalance = @" INSERT INTO [TBL_COUPON_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CouponType ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CouponType ,@CreatorID ,@CreateTime)";

                #region 充值
                #region 获取卡内余额
                string strCardBalanceSql = @"SELECT BALANCE FROM [TBL_CUSTOMER_CARD] WHERE CompanyID=@CompanyID AND UserID=@CustomerID AND UserCardNo=@UserCardNo";
                decimal cardBalance = db.SetCommand(strCardBalanceSql,
                   db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                   db.Parameter("@CustomerID", model.CustomerID, DbType.Int32),
                   db.Parameter("@UserCardNo", model.UserCardNo, DbType.String)).ExecuteScalar<decimal>();
                #endregion

                if (model.CardType == 1)
                {
                    isPush = true;

                    int actionMode = 0;
                    #region ActionMode判断
                    if (model.ChangeType == 3)
                    {
                        actionMode = 3;
                        model.Amount = Math.Abs(model.Amount);
                    }
                    else if (model.ChangeType == 5)
                    {
                        actionMode = 5;
                        model.Amount = Math.Abs(model.Amount) * -1;
                    }
                    else if (model.ChangeType == 9)
                    {
                        model.ChangeType = 5;
                        actionMode = 9;
                        model.Amount = Math.Abs(model.Amount) * -1;
                    }

                    if (actionMode == 0)
                    {
                        db.RollbackTransaction();
                        return 2;
                    }
                    #endregion

                    totalMoneyAmount = cardBalance + model.Amount;
                    if (totalMoneyAmount < 0)
                    {
                        db.RollbackTransaction();
                        return 3;
                    }

                    #region 查询是不是首冲
                    string selIsFstReChargeSql = @"  SELECT COUNT(0) FROM [TBL_MONEY_BALANCE] WHERE UserCardNo=@UserCardNo AND CompanyID=@CompanyID AND ActionMode = 3";
                    bool isFstReCharge = db.SetCommand(selIsFstReChargeSql
                                             , db.Parameter("@UserCardNo", model.UserCardNo, DbType.Int64)
                                             , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>() > 0 ? false : true;
                    #endregion

                    #region 充值储值卡
                    int addres = db.SetCommand(strAddMoneyBalance,
                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                            db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                            db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                            db.Parameter("@CustomerBalanceID", balanceID, DbType.Int32),
                            db.Parameter("@ActionMode", actionMode, DbType.Int32),//1:消费支出、2:消费支出撤销、3:储值卡充值、4:储值卡充值撤销、5:储值卡直扣、6:储值卡直扣撤销、7:储值卡直充赠送、8:储值卡直充赠送撤销、9:储值卡退款、10:储值卡退款撤销
                            db.Parameter("@DepositMode", model.DepositMode, DbType.Int32),//1:现金、2:银行卡、3:余额转入、4:其他
                            db.Parameter("@Remark", model.Remark, DbType.String),
                            db.Parameter("@UserCardNo", model.UserCardNo, DbType.String),
                            db.Parameter("@Amount", model.Amount, DbType.Decimal),
                            db.Parameter("@Balance", totalMoneyAmount, DbType.Decimal),
                            db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                            db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                    if (addres <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    #endregion

                    #region 充值业绩
                    if ((actionMode == 3 && (model.DepositMode == 1 || model.DepositMode == 2))
                        || (actionMode == 5 && model.DepositMode == 0))
                    {
                        string strSelCompanyComissionCalcSql = " SELECT [ComissionCalc] FROM COMPANY WHERE ID=@CompanyID ";
                        bool isComissionCalc = db.SetCommand(strSelCompanyComissionCalcSql
                                             , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<bool>();
                        if (isComissionCalc)
                        {
                            #region 查询卡的业绩RULE
                            string strSelEcardCommissionRuleSql = @"   SELECT T1.ProfitPct ,
                                                                            T1.ProfitPct ,
                                                                            T1.FstChargeCommType ,
                                                                            T1.FstChargeCommValue ,
                                                                            T1.ChargeCommType ,
                                                                            T1.ChargeCommValue ,
                                                                            T1.CardCode 
                                                                     FROM   [TBL_ECARD_COMMISSION_RULE] T1 WITH(NOLOCK)
                                                                             INNER JOIN [MST_CARD] T2 WITH(NOLOCK) ON T1.CardCode=T2.CardCode AND T2.Available = 1
                                                                             INNER JOIN [TBL_CUSTOMER_CARD] T3 WITH(NOLOCK) ON T3.CardID=T2.ID
                                                                     WHERE  T1.CompanyID = @CompanyID
                                                                            AND T3.UserCardNo = @UserCardNo 
                                                                            AND T1.RecordType=1 ";

                            Ecard_Commission_Rule_Model EcardRuleModel = db.SetCommand(strSelEcardCommissionRuleSql
                                                                       , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                       , db.Parameter("@UserCardNo", model.UserCardNo, DbType.Int64)).ExecuteObject<Ecard_Commission_Rule_Model>();

                            #endregion

                            if (EcardRuleModel != null && EcardRuleModel.CardCode > 0)
                            {
                                #region 计算首冲还是续费
                                int ChargeCommType = EcardRuleModel.ChargeCommType;//1:按比例 2:固定值
                                decimal ChargeCommValue = EcardRuleModel.ChargeCommValue;

                                if (isFstReCharge)
                                {
                                    ChargeCommType = EcardRuleModel.FstChargeCommType;
                                    ChargeCommValue = EcardRuleModel.FstChargeCommValue;
                                }

                                decimal Profit = model.Amount * EcardRuleModel.ProfitPct;
                                object CommFlag = DBNull.Value;//1：首充 2：指定
                                if (isFstReCharge)
                                {
                                    CommFlag = 1;
                                }

                                #endregion

                                #region 插入业绩详细表
                                string strAddProfitDetailSql = @" INSERT INTO TBL_PROFIT_COMMISSION_DETAIL ( CompanyID ,BranchID ,SourceType ,SourceID ,SubSourceID ,Income ,ProfitPct ,Profit ,CommType ,CommValue ,AccountID ,AccountProfitPct ,AccountProfit ,AccountComm ,CommFlag , BranchProfitRate, CreatorID ,CreateTime ) 
                                                                    VALUES ( @CompanyID ,@BranchID ,@SourceType ,@SourceID ,@SubSourceID ,@Income ,@ProfitPct ,@Profit ,@CommType ,@CommValue ,@AccountID ,@AccountProfitPct ,@AccountProfit ,@AccountComm ,@CommFlag , @BranchProfitRate, @CreatorID ,@CreateTime ) ";

                                if (model.Slavers != null && model.Slavers.Count > 0)
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

                                        #region 有业绩分享人
                                        decimal AccountProfit = Profit * EveryProfitPct;//员工业绩(=实际业绩 x 员工业绩计算比例)
                                        decimal AccountComm = 0;
                                        if (ChargeCommType == 1)//1:按比例 2:固定值
                                        {
                                            AccountComm = AccountProfit * ChargeCommValue;
                                        }
                                        else
                                        {
                                            if (actionMode == 5 && model.DepositMode == 0)//直扣
                                            {
                                                AccountComm = ChargeCommValue * -1 * EveryProfitPct;
                                            }
                                            else
                                            {
                                                AccountComm = ChargeCommValue * EveryProfitPct;
                                            }
                                        }

                                        int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                            , db.Parameter("@SourceType", 3, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                            , db.Parameter("@SourceID", balanceID, DbType.Int64)
                                            , db.Parameter("@SubSourceID", EcardRuleModel.CardCode, DbType.Int64)
                                            , db.Parameter("@Income", model.Amount, DbType.Decimal)//收入 充值时，为TBL_MONEY_BALANCE的Amount
                                            , db.Parameter("@ProfitPct", EcardRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                            , db.Parameter("@Profit", Profit, DbType.Decimal)//实际业绩
                                            , db.Parameter("@CommType", ChargeCommType, DbType.Int32)//该业绩的提成方式
                                            , db.Parameter("@CommValue", ChargeCommValue, DbType.Decimal)//该业绩的提成数值
                                            , db.Parameter("@AccountID", item.SlaveID, DbType.Int32)//获得该业绩的员工ID
                                            , db.Parameter("@AccountProfitPct", EveryProfitPct, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                            , db.Parameter("@AccountProfit", AccountProfit, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                            , db.Parameter("@AccountComm", AccountComm, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
                                            , db.Parameter("@CommFlag", CommFlag, DbType.Int32)//1：首充 2：指定
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
                                else
                                {
                                    #region 没有业绩分享人
                                    int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                            , db.Parameter("@SourceType", 3, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                            , db.Parameter("@SourceID", balanceID, DbType.Int64)
                                            , db.Parameter("@SubSourceID", EcardRuleModel.CardCode, DbType.Int64)
                                            , db.Parameter("@Income", model.Amount, DbType.Decimal)//收入 充值时，为TBL_MONEY_BALANCE的Amount
                                            , db.Parameter("@ProfitPct", EcardRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                            , db.Parameter("@Profit", Profit, DbType.Decimal)//实际业绩
                                            , db.Parameter("@CommType", ChargeCommType, DbType.Int32)//该业绩的提成方式
                                            , db.Parameter("@CommValue", ChargeCommValue, DbType.Decimal)//该业绩的提成数值
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
                                #endregion
                            }
                        }
                    }
                    #endregion
                }
                else if (model.CardType == 2)
                {
                    int actionMode = 0;

                    #region ActionMode判断
                    if (model.ChangeType == 3)
                    {
                        actionMode = 7;
                        model.Amount = Math.Abs(model.Amount);
                    }
                    else if (model.ChangeType == 5)
                    {
                        actionMode = 9;
                        model.Amount = Math.Abs(model.Amount) * -1;
                    }

                    if (actionMode == 0)
                    {
                        db.RollbackTransaction();
                        return 2;
                    }
                    #endregion

                    totalPointAmount = cardBalance + model.Amount;
                    if (totalPointAmount < 0)
                    {
                        db.RollbackTransaction();
                        return 3;
                    }

                    #region 充值积分卡
                    int addres = db.SetCommand(strAddPointBalance,
                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                            db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                            db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                            db.Parameter("@CustomerBalanceID", balanceID, DbType.Int32),
                            db.Parameter("@ActionMode", actionMode, DbType.Int32),//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                            db.Parameter("@DepositMode", model.DepositMode, DbType.Int32),//1:充值、2:余额转入
                            db.Parameter("@Remark", model.Remark, DbType.String),
                            db.Parameter("@UserCardNo", model.UserCardNo, DbType.String),
                            db.Parameter("@Amount", model.Amount, DbType.Decimal),
                            db.Parameter("@Balance", totalPointAmount, DbType.Decimal),
                            db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                            db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                    if (addres <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    #endregion

                }
                else if (model.CardType == 3)
                {
                    int actionMode = 0;
                    #region ActionMode判断
                    if (model.ChangeType == 3)
                    {
                        actionMode = 7;
                        model.Amount = Math.Abs(model.Amount);
                    }
                    else if (model.ChangeType == 5)
                    {
                        actionMode = 9;
                        model.Amount = Math.Abs(model.Amount) * -1;
                    }

                    if (actionMode == 0)
                    {
                        db.RollbackTransaction();
                        return 2;
                    }
                    #endregion

                    totalCouponAmount = cardBalance + model.Amount;
                    if (totalCouponAmount < 0)
                    {
                        db.RollbackTransaction();
                        return 3;
                    }

                    #region 充现金券卡
                    int addres = db.SetCommand(strAddCouponBalance,
                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                            db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                            db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                            db.Parameter("@CustomerBalanceID", balanceID, DbType.Int32),
                            db.Parameter("@ActionMode", actionMode, DbType.Int32),//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                            db.Parameter("@DepositMode", model.DepositMode, DbType.Int32),//1:充值、2:余额转入
                            db.Parameter("@Remark", model.Remark, DbType.String),
                            db.Parameter("@UserCardNo", model.UserCardNo, DbType.String),
                            db.Parameter("@Amount", model.Amount, DbType.Decimal),
                            db.Parameter("@Balance", totalCouponAmount, DbType.Decimal),
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

                #endregion

                string strAddHis = @" INSERT INTO [HST_CUSTOMER_CARD] SELECT * FROM [TBL_CUSTOMER_CARD] WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo ";
                string strUpdateCustomerCard = @" UPDATE [TBL_CUSTOMER_CARD] SET Balance=@Balance ,UpdaterID = @UpdaterID , UpdateTime = @UpdateTime WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo";

                #region 修改CustomerCard中的Balance
                int hisRows = db.SetCommand(strAddHis, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                     , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                     , db.Parameter("@UserCardNo", model.UserCardNo, DbType.String)).ExecuteNonQuery();

                if (hisRows == 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                int updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", cardBalance + model.Amount, DbType.Decimal)
                                                     , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                     , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                     , db.Parameter("@UserCardNo", model.UserCardNo, DbType.String)
                                                     , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                                                     , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                if (updateRes == 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                if (model.GiveList != null && model.GiveList.Count > 0)
                {
                    #region 赠送
                    foreach (RechargeGiveOperation_Model item in model.GiveList)
                    {
                        if (item.Amount != 0)
                        {
                            if (item.CardType == 1)
                            {
                                isPush = true;

                                #region 赠送储值卡
                                if (totalMoneyAmount <= 0)
                                {
                                    #region 获取卡内余额
                                    totalMoneyAmount = db.SetCommand(strCardBalanceSql,
                                       db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                       db.Parameter("@CustomerID", model.CustomerID, DbType.Int32),
                                       db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteScalar<decimal>();
                                    #endregion
                                }

                                totalMoneyAmount += Math.Abs(item.Amount);

                                #region 充值储值卡
                                int addres = db.SetCommand(strAddMoneyBalance,
                                        db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                        db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                        db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                                        db.Parameter("@CustomerBalanceID", balanceID, DbType.Int32),
                                        db.Parameter("@ActionMode", 7, DbType.Int32),//1:消费支出、2:消费支出撤销、3:储值卡充值、4:储值卡充值撤销、5:储值卡直扣、6:储值卡直扣撤销、7:储值卡直充赠送、8:储值卡直充赠送撤销、9:储值卡退款、10:储值卡退款撤销
                                        db.Parameter("@DepositMode", 0, DbType.Int32),//DepositMode 1:现金、2:银行卡、3:余额转入、4:赠送
                                        db.Parameter("@Remark", model.Remark, DbType.String),
                                        db.Parameter("@UserCardNo", item.UserCardNo, DbType.String),
                                        db.Parameter("@Amount", item.Amount, DbType.Decimal),
                                        db.Parameter("@Balance", totalMoneyAmount, DbType.Decimal),
                                        db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                        db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                                if (addres <= 0)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }
                                #endregion
                                #endregion

                                #region 修改CustomerCard中的Balance
                                hisRows = db.SetCommand(strAddHis, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                     , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                                     , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteNonQuery();

                                if (hisRows == 0)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }

                                updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", totalMoneyAmount, DbType.Decimal)
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
                            }

                            if (item.CardType == 2)
                            {
                                #region 赠送积分卡
                                if (totalPointAmount <= 0)
                                {
                                    #region 获取卡内余额
                                    totalPointAmount = db.SetCommand(strCardBalanceSql,
                                       db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                       db.Parameter("@CustomerID", model.CustomerID, DbType.Int32),
                                       db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteScalar<decimal>();
                                    #endregion
                                }

                                totalPointAmount += Math.Abs(item.Amount);

                                #region 充值积分卡
                                int addres = db.SetCommand(strAddPointBalance,
                                        db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                        db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                        db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                                        db.Parameter("@CustomerBalanceID", balanceID, DbType.Int32),
                                        db.Parameter("@ActionMode", 5, DbType.Int32),//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                        db.Parameter("@DepositMode", 0, DbType.Int32),
                                        db.Parameter("@Remark", model.Remark, DbType.String),
                                        db.Parameter("@UserCardNo", item.UserCardNo, DbType.String),
                                        db.Parameter("@Amount", item.Amount, DbType.Decimal),
                                        db.Parameter("@Balance", totalPointAmount, DbType.Decimal),
                                        db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                        db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                                if (addres <= 0)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }
                                #endregion
                                #endregion

                                #region 修改CustomerCard中的Balance
                                hisRows = db.SetCommand(strAddHis, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                     , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                                     , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteNonQuery();

                                if (hisRows == 0)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }

                                updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", totalPointAmount, DbType.Decimal)
                                                                     , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                     , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                                     , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)
                                                                     , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                                                                     , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                                if (hisRows == 0)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }
                                #endregion
                            }

                            if (item.CardType == 3)
                            {
                                #region 赠送现金券卡
                                if (totalCouponAmount <= 0)
                                {
                                    #region 获取卡内余额
                                    totalCouponAmount = db.SetCommand(strCardBalanceSql,
                                       db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                       db.Parameter("@CustomerID", model.CustomerID, DbType.Int32),
                                       db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteScalar<decimal>();
                                    #endregion
                                }

                                totalCouponAmount += Math.Abs(item.Amount);

                                #region 充现金券卡
                                int addres = db.SetCommand(strAddCouponBalance,
                                        db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                        db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                        db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                                        db.Parameter("@CustomerBalanceID", balanceID, DbType.Int32),
                                        db.Parameter("@ActionMode", 5, DbType.Int32),//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、910:直扣撤销
                                        db.Parameter("@DepositMode", 0, DbType.Int32),
                                        db.Parameter("@Remark", model.Remark, DbType.String),
                                        db.Parameter("@UserCardNo", item.UserCardNo, DbType.String),
                                        db.Parameter("@Amount", item.Amount, DbType.Decimal),
                                        db.Parameter("@Balance", totalCouponAmount, DbType.Decimal),
                                        db.Parameter("@CouponType", 0, DbType.Int32),
                                        db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                        db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                                if (addres <= 0)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }
                                #endregion

                                #endregion

                                #region 修改CustomerCard中的Balance
                                hisRows = db.SetCommand(strAddHis, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                     , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                                     , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteNonQuery();

                                if (hisRows == 0)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }

                                updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", totalCouponAmount, DbType.Decimal)
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
                            }
                        }
                    }
                    #endregion
                }

                if (model.Slavers != null && model.Slavers.Count > 0)
                {
                    #region 业绩分享人
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
                                , db.Parameter("@MasterID", balanceID, DbType.Int64)
                                , db.Parameter("@SlaveID", item.SlaveID, DbType.Int64)
                                , db.Parameter("@Type", 1, DbType.Int32)
                                , db.Parameter("@ProfitPct", EveryProfitPct, DbType.Decimal)
                                , db.Parameter("@Available", true, DbType.Boolean)
                                , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                                , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)).ExecuteNonQuery();

                        if (addProfitres <= 0)
                        {
                            db.RollbackTransaction();
                            LogUtil.Log("插入业绩表出错", "BanlanceID:" + balanceID + "插入业绩表出错。");
                            return 0;
                        }
                    }
                    #endregion
                }

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
                        string strAddConsultant = @" INSERT INTO [TBL_BUSINESS_CONSULTANT]( CompanyID ,BusinessType ,MasterID ,ConsultantType ,ConsultantID ,CreatorID ,CreateTime )
                                                    VALUES ( @CompanyID ,@BusinessType ,@MasterID ,@ConsultantType ,@ConsultantID ,@CreatorID ,@CreateTime )";

                        foreach (int item in SalesPersonIDList)
                        {
                            int addConsultantRes = db.SetCommand(strAddConsultant
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@BusinessType", 3, DbType.Int32)//1：订单，2：支付，3：充值
                            , db.Parameter("@MasterID", balanceID, DbType.Int32)
                            , db.Parameter("@ConsultantType", 2, DbType.Int32)//1:美丽顾问 2:销售顾问
                            , db.Parameter("@ConsultantID", item, DbType.Int32)
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

                db.CommitTransaction();

                #region PUSH
                if (isPush)
                {
                    string selectCustomerDevice = @"SELECT TOP 1 ISNULL(T3.DeviceID, '') AS DeviceID ,T1.Name AS CustomerName ,T3.DeviceType ,T2.smsheading AS CompanyName,ISNULL(T6.BalanceNotice, 0) AS Threshold ,T4.LoginMobile,T2.BalanceRemind ,T1.WeChatOpenID ,T6.CardName  
                                                    FROM    [CUSTOMER] T1 WITH ( NOLOCK )
                                                            LEFT JOIN [COMPANY] T2 WITH ( NOLOCK ) ON T1.CompanyID = T2.ID
                                                            LEFT JOIN [LOGIN] T3 WITH ( NOLOCK ) ON T1.UserID = T3.UserID
                                                            LEFT JOIN [USER] T4 WITH ( NOLOCK ) ON T4.ID = t1.UserID
                                                            LEFT JOIN [TBL_CUSTOMER_CARD] T5 WITH ( NOLOCK ) ON T5.UserID = T4.ID AND T5.UserCardNo=@userCardNo
                                                            LEFT JOIN [MST_CARD] T6 WITH(NOLOCK) ON T5.CardID=T6.ID
                                                    WHERE   T1.UserID = @CustomerID";
                    PushOperation_Model pushmodel = db.SetCommand(selectCustomerDevice, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                                                                      , db.Parameter("@userCardNo", model.UserCardNo, DbType.String)).ExecuteObject<PushOperation_Model>();
                    if (pushmodel != null)
                    {
                        Task.Factory.StartNew(() =>
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
                                        string first = "您有一笔账户直扣\n";
                                        if (model.ChangeType == 3)
                                        {
                                            first = "您有一笔账户充值\n";
                                        }

                                        HS.Framework.Common.WeChat.Entity.MessageTemplate messageModel = new HS.Framework.Common.WeChat.Entity.MessageTemplate();
                                        HS.Framework.Common.WeChat.WXCompanyInfoBase WXCompanyInfoBase = we.GetBaseInfo(model.CompanyID);
                                        messageModel.template_id = WXCompanyInfoBase.AccountChangesTemplate;
                                        messageModel.topcolor = "#000000";
                                        messageModel.touser = pushmodel.WeChatOpenID;
                                        messageModel.data = new HS.Framework.Common.WeChat.Entity.TemplateDetail()
                                        {
                                            first = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#FF0000", value = first },
                                            keyword1 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = model.CreateTime.ToString("yyyy-MM-dd HH:mm") },
                                            keyword2 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = pushmodel.CardName },
                                            keyword3 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#FF0000", value = model.Amount.ToString("C2") },
                                            remark = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = "余额：" + totalMoneyAmount.ToString("C2") + "\n\n您可以在账户交易明细中查看账户变动的详细内容。" }
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
                                        //保存短信发送履历信息
                                        string msg = string.Format(Const.MESSAGE_BALANCE, pushmodel.CompanyName, model.CreateTime.ToString("MM月dd日HH时mm分"));
                                        strPgm = st.GetFrame(0).GetMethod().Name + "(" + st.GetFrame(0).GetFileLineNumber().ToString() + ")";
                                        SMSInfo_DAL.Instance.addSMSHis(model.CompanyID, model.BranchID, pushmodel.LoginMobile, msg, strPgm, model.CreatorID);

                                    }
                                }
                                #endregion
                            }

                            #region 储值卡卡余额低于阀值PUSH提醒
                            if (totalMoneyAmount > 0 && totalMoneyAmount < pushmodel.Threshold && pushmodel.Threshold > 0 && model.ChangeType == 5)
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
                }
                #endregion

                return 1;
            }
        }

        public int CardRechargeByWeChat(WeChatReturn_Model weChatModel, DateTime time)
        {
            using (DbManager db = new DbManager())
            {
                System.Diagnostics.StackTrace st = new System.Diagnostics.StackTrace(1, true);
                string strPgm;  //当前的程序名称及行号等监察信息

                db.BeginTransaction();

                decimal totalMoneyAmount = 0;
                decimal totalPointAmount = 0;
                decimal totalCouponAmount = 0;
                int customerBalanceChangeType = 3;
                bool isPush = false;

                #region 根据NetTradeNo获取数据
                string strSelTradeControlSql = @" SELECT  T1.CompanyID ,
                                                        T1.BranchID ,
                                                        T1.NetTradeNo ,
                                                        T1.NetActionType ,
                                                        T1.NetTradeVendor ,
                                                        T1.NetTradeActionMode ,
                                                        T1.ProductName ,
                                                        T1.NetTradeAmount ,
                                                        T1.PointAmount ,
                                                        T1.CouponAmount ,
                                                        T1.MoneyAmount ,
                                                        T1.Participants ,
                                                        --T1.ResponsiblePersonID ,
                                                        T1.UserCardNo ,
                                                        T1.Remark ,
                                                        T1.CreatorID ,
                                                        T1.CustomerID
                                                FROM    [TBL_NETTRADE_CONTROL] T1 WITH ( NOLOCK )
                                                WHERE   T1.NetTradeNo = @NetTradeNo ";

                NetTrade_Control_Model tradeModel = db.SetCommand(strSelTradeControlSql,
                            db.Parameter("@NetTradeNo", weChatModel.out_trade_no, DbType.String)).ExecuteObject<NetTrade_Control_Model>();

                if (tradeModel == null)
                {
                    return 0;
                }

                #region 获取业绩分享人
                List<Slave_Model> Slavers = new List<Slave_Model>();
                if (!string.IsNullOrEmpty(tradeModel.Participants))
                {
                    string[] strSlavID = tradeModel.Participants.Split(new string[] { "|" }, StringSplitOptions.RemoveEmptyEntries);
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

                string strAddCustomerBalance = @" INSERT [TBL_CUSTOMER_BALANCE]	( CompanyID ,BranchID ,UserID ,ChangeType ,TargetAccount  ,PaymentID ,Remark ,CreatorID ,CreateTime) 
                VALUES(@CompanyID ,@BranchID ,@UserID ,@ChangeType ,@TargetAccount  ,@PaymentID ,@Remark ,@CreatorID ,@CreateTime);select @@IDENTITY";
                int balanceID = db.SetCommand(strAddCustomerBalance,
                            db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32),
                            db.Parameter("@BranchID", tradeModel.BranchID, DbType.Int32),
                            db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32),
                            db.Parameter("@ChangeType", customerBalanceChangeType, DbType.Int32),
                            db.Parameter("@TargetAccount", 1, DbType.Int32),//1:储值卡、2:积分、3:现金券 
                    //db.Parameter("@ResponsiblePersonID", tradeModel.ResponsiblePersonID, DbType.Int32),
                            db.Parameter("@PaymentID", DBNull.Value, DbType.Int32),
                            db.Parameter("@Remark", tradeModel.Remark, DbType.String),
                            db.Parameter("@CreatorID", tradeModel.CreatorID, DbType.Int32),
                            db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteScalar<int>();

                if (balanceID <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                //ActionMode 1:消费支出、2:消费支出撤销、3:储值卡充值、4:储值卡充值撤销、5:储值卡直扣、6:储值卡直扣撤销、7:储值卡直充赠送、8:储值卡直充赠送撤销、9:储值卡退款、10:储值卡退款撤销
                //DepositMode 1:现金、2:银行卡、3:余额转入、4:其他
                string strAddMoneyBalance = @" INSERT INTO [TBL_MONEY_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CreatorID ,@CreateTime)";

                //ActionMode 1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                //DepositMode 1:充值、2:余额转入
                string strAddPointBalance = @" INSERT INTO [TBL_POINT_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CreatorID ,@CreateTime)";

                //ActionMode 1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                //DepositMode 1:充值、2:余额转入
                string strAddCouponBalance = @" INSERT INTO [TBL_COUPON_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CouponType ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CouponType ,@CreatorID ,@CreateTime)";

                #region 充值

                #region 获取卡内余额
                string strCardBalanceSql = @"SELECT BALANCE FROM [TBL_CUSTOMER_CARD] WHERE CompanyID=@CompanyID AND UserID=@CustomerID AND UserCardNo=@UserCardNo";
                decimal cardBalance = db.SetCommand(strCardBalanceSql,
                   db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32),
                   db.Parameter("@CustomerID", tradeModel.CustomerID, DbType.Int32),
                   db.Parameter("@UserCardNo", tradeModel.UserCardNo, DbType.String)).ExecuteScalar<decimal>();
                #endregion

                isPush = true;
                tradeModel.NetTradeAmount = Math.Abs(tradeModel.NetTradeAmount);
                totalMoneyAmount = cardBalance + tradeModel.NetTradeAmount;
                if (totalMoneyAmount < 0)
                {
                    db.RollbackTransaction();
                    return 3;
                }

                #region 查询是不是首冲
                string selIsFstReChargeSql = @"  SELECT COUNT(0) FROM [TBL_MONEY_BALANCE] WHERE UserCardNo=@UserCardNo AND CompanyID=@CompanyID AND ActionMode = 3";
                bool isFstReCharge = db.SetCommand(selIsFstReChargeSql
                                         , db.Parameter("@UserCardNo", tradeModel.UserCardNo, DbType.Int64)
                                         , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)).ExecuteScalar<int>() > 0 ? false : true;
                #endregion

                #region 充值储值卡
                int addres = db.SetCommand(strAddMoneyBalance,
                        db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32),
                        db.Parameter("@BranchID", tradeModel.BranchID, DbType.Int32),
                        db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32),
                        db.Parameter("@CustomerBalanceID", balanceID, DbType.Int32),
                        db.Parameter("@ActionMode", 3, DbType.Int32),//1:消费支出、2:消费支出撤销、3:储值卡充值、4:储值卡充值撤销、5:储值卡直扣、6:储值卡直扣撤销、7:储值卡直充赠送、8:储值卡直充赠送撤销、9:储值卡退款、10:储值卡退款撤销
                        db.Parameter("@DepositMode", 4, DbType.Int32),//1:现金、2:银行卡、3:余额转入、4:微信
                        db.Parameter("@Remark", tradeModel.Remark, DbType.String),
                        db.Parameter("@UserCardNo", tradeModel.UserCardNo, DbType.String),
                        db.Parameter("@Amount", tradeModel.NetTradeAmount, DbType.Decimal),
                        db.Parameter("@Balance", totalMoneyAmount, DbType.Decimal),
                        db.Parameter("@CreatorID", tradeModel.CreatorID, DbType.Int32),
                        db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                if (addres <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                #region 充值业绩
                string strSelCompanyComissionCalcSql = " SELECT [ComissionCalc] FROM COMPANY WHERE ID=@CompanyID ";
                bool isComissionCalc = db.SetCommand(strSelCompanyComissionCalcSql
                                     , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)).ExecuteScalar<bool>();
                if (isComissionCalc)
                {
                    #region 查询卡的业绩RULE
                    string strSelEcardCommissionRuleSql = @"   SELECT T1.ProfitPct ,
                                                                            T1.ProfitPct ,
                                                                            T1.FstChargeCommType ,
                                                                            T1.FstChargeCommValue ,
                                                                            T1.ChargeCommType ,
                                                                            T1.ChargeCommValue ,
                                                                            T1.CardCode 
                                                                     FROM   [TBL_ECARD_COMMISSION_RULE] T1 WITH(NOLOCK)
                                                                             INNER JOIN [MST_CARD] T2 WITH(NOLOCK) ON T1.CardCode=T2.CardCode AND T2.Available = 1
                                                                             INNER JOIN [TBL_CUSTOMER_CARD] T3 WITH(NOLOCK) ON T3.CardID=T2.ID
                                                                     WHERE  T1.CompanyID = @CompanyID
                                                                            AND T3.UserCardNo = @UserCardNo 
                                                                            AND T1.RecordType=1 ";

                    Ecard_Commission_Rule_Model EcardRuleModel = db.SetCommand(strSelEcardCommissionRuleSql
                                                               , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                                               , db.Parameter("@UserCardNo", tradeModel.UserCardNo, DbType.Int64)).ExecuteObject<Ecard_Commission_Rule_Model>();

                    #endregion

                    if (EcardRuleModel != null && EcardRuleModel.CardCode > 0)
                    {
                        #region 计算首冲还是续费
                        int ChargeCommType = isFstReCharge ? EcardRuleModel.FstChargeCommType : EcardRuleModel.ChargeCommType;//1:按比例 2:固定值
                        decimal ChargeCommValue = isFstReCharge ? EcardRuleModel.FstChargeCommValue : EcardRuleModel.ChargeCommValue;
                        decimal Profit = tradeModel.NetTradeAmount * EcardRuleModel.ProfitPct;

                        object CommFlag = DBNull.Value;//1：首充 2：指定
                        if (isFstReCharge)
                        {
                            CommFlag = 1;
                        }

                        #endregion

                        #region 插入业绩详细表
                        string strAddProfitDetailSql = @" INSERT INTO TBL_PROFIT_COMMISSION_DETAIL ( CompanyID ,BranchID ,SourceType ,SourceID ,SubSourceID ,Income ,ProfitPct ,Profit ,CommType ,CommValue ,AccountID ,AccountProfitPct ,AccountProfit ,AccountComm ,CommFlag ,CreatorID ,CreateTime ) 
                                                                    VALUES ( @CompanyID ,@BranchID ,@SourceType ,@SourceID ,@SubSourceID ,@Income ,@ProfitPct ,@Profit ,@CommType ,@CommValue ,@AccountID ,@AccountProfitPct ,@AccountProfit ,@AccountComm ,@CommFlag ,@CreatorID ,@CreateTime ) ";

                        if (Slavers != null && Slavers.Count > 0)
                        {
                            foreach (Slave_Model item in Slavers)
                            {
                                #region 有业绩分享人
                                decimal AccountProfit = Profit * item.ProfitPct;//员工业绩(=实际业绩 x 员工业绩计算比例)
                                decimal AccountComm = ChargeCommValue * item.ProfitPct;
                                if (ChargeCommType == 1)//1:按比例 2:固定值
                                {
                                    AccountComm = AccountProfit * ChargeCommValue;
                                }

                                int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                    , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                    , db.Parameter("@BranchID", tradeModel.BranchID, DbType.Int32)
                                    , db.Parameter("@SourceType", 3, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                    , db.Parameter("@SourceID", balanceID, DbType.Int64)
                                    , db.Parameter("@SubSourceID", EcardRuleModel.CardCode, DbType.Int64)
                                    , db.Parameter("@Income", tradeModel.NetTradeAmount, DbType.Decimal)//收入 充值时，为TBL_MONEY_BALANCE的Amount
                                    , db.Parameter("@ProfitPct", EcardRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                    , db.Parameter("@Profit", Profit, DbType.Decimal)//实际业绩
                                    , db.Parameter("@CommType", ChargeCommType, DbType.Int32)//该业绩的提成方式
                                    , db.Parameter("@CommValue", ChargeCommValue, DbType.Decimal)//该业绩的提成数值
                                    , db.Parameter("@AccountID", item.SlaveID, DbType.Int32)//获得该业绩的员工ID
                                    , db.Parameter("@AccountProfitPct", item.ProfitPct, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                    , db.Parameter("@AccountProfit", AccountProfit, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                    , db.Parameter("@AccountComm", AccountComm, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
                                    , db.Parameter("@CommFlag", CommFlag, DbType.Int32)//1：首充 2：指定 3：E账户
                                    , db.Parameter("@CreatorID", tradeModel.CreatorID, DbType.Int32)
                                    , db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                                if (addProfitDetailRes != 1)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }
                                #endregion
                            }
                        }
                        else
                        {
                            #region 没有业绩分享人
                            int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                    , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                    , db.Parameter("@BranchID", tradeModel.BranchID, DbType.Int32)
                                    , db.Parameter("@SourceType", 3, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                    , db.Parameter("@SourceID", balanceID, DbType.Int64)
                                    , db.Parameter("@Income", tradeModel.NetTradeAmount, DbType.Decimal)//收入 充值时，为TBL_MONEY_BALANCE的Amount
                                    , db.Parameter("@SubSourceID", EcardRuleModel.CardCode, DbType.Int64)
                                    , db.Parameter("@ProfitPct", EcardRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                    , db.Parameter("@Profit", Profit, DbType.Decimal)//实际业绩
                                    , db.Parameter("@CommType", ChargeCommType, DbType.Int32)//该业绩的提成方式
                                    , db.Parameter("@CommValue", ChargeCommValue, DbType.Decimal)//该业绩的提成数值
                                    , db.Parameter("@AccountID", DBNull.Value, DbType.Int32)//获得该业绩的员工ID
                                    , db.Parameter("@AccountProfitPct", DBNull.Value, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                    , db.Parameter("@AccountProfit", DBNull.Value, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                    , db.Parameter("@AccountComm", DBNull.Value, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
                                    , db.Parameter("@CommFlag", CommFlag, DbType.Int32)//1：首充 2：指定 3：E账户
                                    , db.Parameter("@CreatorID", tradeModel.CreatorID, DbType.Int32)
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
                }
                #endregion

                #endregion

                string strAddHis = @" INSERT INTO [HST_CUSTOMER_CARD] SELECT * FROM [TBL_CUSTOMER_CARD] WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo ";
                string strUpdateCustomerCard = @" UPDATE [TBL_CUSTOMER_CARD] SET Balance=@Balance ,UpdaterID = @UpdaterID , UpdateTime = @UpdateTime WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo";

                #region 修改CustomerCard中的Balance
                int hisRows = db.SetCommand(strAddHis, db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                                     , db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32)
                                                     , db.Parameter("@UserCardNo", tradeModel.UserCardNo, DbType.String)).ExecuteNonQuery();

                if (hisRows == 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                int updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", cardBalance + tradeModel.NetTradeAmount, DbType.Decimal)
                                                     , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                                     , db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32)
                                                     , db.Parameter("@UserCardNo", tradeModel.UserCardNo, DbType.String)
                                                     , db.Parameter("@UpdaterID", tradeModel.CreatorID, DbType.Int32)
                                                     , db.Parameter("@UpdateTime", time, DbType.DateTime)).ExecuteNonQuery();

                if (updateRes == 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                if (tradeModel.PointAmount > 0 || tradeModel.CouponAmount > 0 || tradeModel.MoneyAmount > 0)
                {
                    #region 赠送

                    if (tradeModel.MoneyAmount > 0)
                    {
                        isPush = true;

                        #region 赠送储值卡
                        if (totalMoneyAmount <= 0)
                        {
                            #region 获取卡内余额
                            totalMoneyAmount = db.SetCommand(strCardBalanceSql,
                               db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32),
                               db.Parameter("@CustomerID", tradeModel.CustomerID, DbType.Int32),
                               db.Parameter("@UserCardNo", tradeModel.UserCardNo, DbType.String)).ExecuteScalar<decimal>();
                            #endregion
                        }

                        totalMoneyAmount += Math.Abs(tradeModel.MoneyAmount);

                        #region 充值储值卡
                        addres = db.SetCommand(strAddMoneyBalance,
                               db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32),
                               db.Parameter("@BranchID", tradeModel.BranchID, DbType.Int32),
                               db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32),
                               db.Parameter("@CustomerBalanceID", balanceID, DbType.Int32),
                               db.Parameter("@ActionMode", 7, DbType.Int32),//1:消费支出、2:消费支出撤销、3:储值卡充值、4:储值卡充值撤销、5:储值卡直扣、6:储值卡直扣撤销、7:储值卡直充赠送、8:储值卡直充赠送撤销、9:储值卡退款、10:储值卡退款撤销
                               db.Parameter("@DepositMode", 0, DbType.Int32),//DepositMode 1:现金、2:银行卡、3:余额转入、4:赠送
                               db.Parameter("@Remark", tradeModel.Remark, DbType.String),
                               db.Parameter("@UserCardNo", tradeModel.UserCardNo, DbType.String),
                               db.Parameter("@Amount", tradeModel.MoneyAmount, DbType.Decimal),
                               db.Parameter("@Balance", totalMoneyAmount, DbType.Decimal),
                               db.Parameter("@CreatorID", tradeModel.CreatorID, DbType.Int32),
                               db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                        if (addres <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion
                        #endregion

                        #region 修改CustomerCard中的Balance
                        hisRows = db.SetCommand(strAddHis, db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                                             , db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32)
                                                             , db.Parameter("@UserCardNo", tradeModel.UserCardNo, DbType.String)).ExecuteNonQuery();

                        if (hisRows == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", totalMoneyAmount, DbType.Decimal)
                                                             , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                                             , db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32)
                                                             , db.Parameter("@UserCardNo", tradeModel.UserCardNo, DbType.String)
                                                             , db.Parameter("@UpdaterID", tradeModel.CreatorID, DbType.Int32)
                                                             , db.Parameter("@UpdateTime", time, DbType.DateTime)).ExecuteNonQuery();

                        if (hisRows == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion
                    }

                    if (tradeModel.PointAmount > 0)
                    {
                        DataTable dt = new DataTable();
                        #region 赠送积分卡
                        if (totalPointAmount <= 0)
                        {
                            #region 获取卡内余额

                            strCardBalanceSql = @" SELECT TOP 1
                                                                T1.BALANCE ,
                                                                T1.UserCardNo
                                                        FROM    [TBL_CUSTOMER_CARD] T1 WITH ( NOLOCK )
                                                                LEFT JOIN [MST_CARD] T2 WITH ( NOLOCK ) ON T1.CardID = T2.ID
                                                        WHERE   T1.CompanyID = @CompanyID
                                                                AND T1.UserID = @CustomerID
                                                                AND T2.CardTypeID = 2
                                                        ORDER BY T2.ID DESC ";
                            dt = db.SetCommand(strCardBalanceSql,
                               db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32),
                               db.Parameter("@CustomerID", tradeModel.CustomerID, DbType.Int32)).ExecuteDataTable();

                            if (dt == null)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            totalPointAmount = StringUtils.GetDbDecimal(dt.Rows[0]["BALANCE"].ToString());
                            #endregion
                        }

                        totalPointAmount += Math.Abs(tradeModel.PointAmount);

                        #region 充值积分卡
                        addres = db.SetCommand(strAddPointBalance,
                               db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32),
                               db.Parameter("@BranchID", tradeModel.BranchID, DbType.Int32),
                               db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32),
                               db.Parameter("@CustomerBalanceID", balanceID, DbType.Int32),
                               db.Parameter("@ActionMode", 5, DbType.Int32),//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                               db.Parameter("@DepositMode", 0, DbType.Int32),
                               db.Parameter("@Remark", tradeModel.Remark, DbType.String),
                               db.Parameter("@UserCardNo", dt.Rows[0]["UserCardNo"].ToString(), DbType.String),
                               db.Parameter("@Amount", tradeModel.PointAmount, DbType.Decimal),
                               db.Parameter("@Balance", totalPointAmount, DbType.Decimal),
                               db.Parameter("@CreatorID", tradeModel.CreatorID, DbType.Int32),
                               db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                        if (addres <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion
                        #endregion

                        #region 修改CustomerCard中的Balance
                        hisRows = db.SetCommand(strAddHis, db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                                             , db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32)
                                                             , db.Parameter("@UserCardNo", dt.Rows[0]["UserCardNo"].ToString(), DbType.String)).ExecuteNonQuery();

                        if (hisRows == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", totalPointAmount, DbType.Decimal)
                                                             , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                                             , db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32)
                                                             , db.Parameter("@UserCardNo", dt.Rows[0]["UserCardNo"].ToString(), DbType.String)
                                                             , db.Parameter("@UpdaterID", tradeModel.CreatorID, DbType.Int32)
                                                             , db.Parameter("@UpdateTime", time, DbType.DateTime)).ExecuteNonQuery();

                        if (updateRes == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion
                    }

                    if (tradeModel.CouponAmount > 0)
                    {
                        DataTable dt = new DataTable();
                        #region 赠送现金券卡
                        if (totalCouponAmount <= 0)
                        {
                            #region 获取卡内余额

                            strCardBalanceSql = @" SELECT TOP 1
                                                                T1.BALANCE ,
                                                                T1.UserCardNo
                                                        FROM    [TBL_CUSTOMER_CARD] T1 WITH ( NOLOCK )
                                                                LEFT JOIN [MST_CARD] T2 WITH ( NOLOCK ) ON T1.CardID = T2.ID
                                                        WHERE   T1.CompanyID = @CompanyID
                                                                AND T1.UserID = @CustomerID
                                                                AND T2.CardTypeID = 3
                                                        ORDER BY T2.ID DESC ";
                            dt = db.SetCommand(strCardBalanceSql,
                               db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32),
                               db.Parameter("@CustomerID", tradeModel.CustomerID, DbType.Int32)).ExecuteDataTable();

                            if (dt == null)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            totalCouponAmount = StringUtils.GetDbDecimal(dt.Rows[0]["BALANCE"].ToString());
                            #endregion
                        }

                        totalCouponAmount += Math.Abs(tradeModel.CouponAmount);

                        #region 充现金券卡
                        addres = db.SetCommand(strAddCouponBalance,
                               db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32),
                               db.Parameter("@BranchID", tradeModel.BranchID, DbType.Int32),
                               db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32),
                               db.Parameter("@CustomerBalanceID", balanceID, DbType.Int32),
                               db.Parameter("@ActionMode", 5, DbType.Int32),//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、910:直扣撤销
                               db.Parameter("@DepositMode", 0, DbType.Int32),
                               db.Parameter("@Remark", tradeModel.Remark, DbType.String),
                               db.Parameter("@UserCardNo", dt.Rows[0]["UserCardNo"].ToString(), DbType.String),
                               db.Parameter("@Amount", tradeModel.CouponAmount, DbType.Decimal),
                               db.Parameter("@Balance", totalCouponAmount, DbType.Decimal),
                               db.Parameter("@CouponType", 0, DbType.Int32),
                               db.Parameter("@CreatorID", tradeModel.CreatorID, DbType.Int32),
                               db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                        if (addres <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        #endregion

                        #region 修改CustomerCard中的Balance
                        hisRows = db.SetCommand(strAddHis, db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                                             , db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32)
                                                             , db.Parameter("@UserCardNo", dt.Rows[0]["UserCardNo"].ToString(), DbType.String)).ExecuteNonQuery();

                        if (hisRows == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", totalCouponAmount, DbType.Decimal)
                                                             , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                                             , db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32)
                                                             , db.Parameter("@UserCardNo", dt.Rows[0]["UserCardNo"].ToString(), DbType.String)
                                                             , db.Parameter("@UpdaterID", tradeModel.CreatorID, DbType.Int32)
                                                             , db.Parameter("@UpdateTime", time, DbType.DateTime)).ExecuteNonQuery();

                        if (updateRes == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion
                    }
                    #endregion
                }

                #region 业绩分享人
                if (balanceID >= 0 && Slavers != null && Slavers.Count > 0)
                {
                    foreach (Slave_Model item in Slavers)
                    {
                        string strAddProfitSql = @" INSERT	INTO TBL_PROFIT( MasterID ,SlaveID ,Type ,ProfitPct ,Available ,CreateTime ,CreatorID) 
                                                VALUES (@MasterID ,@SlaveID ,@Type ,@ProfitPct ,@Available ,@CreateTime ,@CreatorID)";
                        int addProfitres = db.SetCommand(strAddProfitSql, db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                , db.Parameter("@MasterID", balanceID, DbType.Int64)
                                , db.Parameter("@SlaveID", item.SlaveID, DbType.Int32)
                                , db.Parameter("@Type", 1, DbType.Int32)
                                , db.Parameter("@ProfitPct", item.ProfitPct, DbType.Decimal)
                                , db.Parameter("@Available", true, DbType.Boolean)
                                , db.Parameter("@CreateTime", time, DbType.DateTime2)
                                , db.Parameter("@CreatorID", tradeModel.CreatorID, DbType.Int32)).ExecuteNonQuery();

                        if (addProfitres <= 0)
                        {
                            db.RollbackTransaction();
                            //LogUtil.Log("插入业绩表出错", "PaymentID:" + paymentID + "插入业绩表出错。");
                            return 0;
                        }
                    }
                }
                #endregion

                string advanced = Company_DAL.Instance.getAdvancedByCompanyID(tradeModel.CompanyID);
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
                            db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32),
                            db.Parameter("@BranchID", tradeModel.BranchID, DbType.Int32),
                            db.Parameter("@CustomerID", tradeModel.CustomerID, DbType.Int32)).ExecuteScalarList<int>();

                    if (SalesPersonIDList != null || SalesPersonIDList.Count > 0)
                    {
                        string strAddConsultant = @" INSERT INTO [TBL_BUSINESS_CONSULTANT]( CompanyID ,BusinessType ,MasterID ,ConsultantType ,ConsultantID ,CreatorID ,CreateTime )
                                                    VALUES ( @CompanyID ,@BusinessType ,@MasterID ,@ConsultantType ,@ConsultantID ,@CreatorID ,@CreateTime )";

                        foreach (int item in SalesPersonIDList)
                        {
                            int addConsultantRes = db.SetCommand(strAddConsultant
                            , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                            , db.Parameter("@BusinessType", 3, DbType.Int32)//1：订单，2：支付，3：充值
                            , db.Parameter("@MasterID", balanceID, DbType.Int32)
                            , db.Parameter("@ConsultantType", 2, DbType.Int32)//1:美丽顾问 2:销售顾问
                            , db.Parameter("@ConsultantID", item, DbType.Int32)
                            , db.Parameter("@CreatorID", tradeModel.CreatorID, DbType.Int32)
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

                #region 插入TBL_NETTRADE_RELATION
                string strTradeRelationSql = @" INSERT INTO [TBL_NETTRADE_RELATION]( CompanyID ,NetTradeNo ,NetTradeType ,PaymentID ,PaymentDetailID ,CustomerBalanceID ,MoneyBalanceID ,CreatorID ,CreateTime ) 
                                                VALUES ( @CompanyID ,@NetTradeNo ,@NetTradeType ,@PaymentID ,@PaymentDetailID ,@CustomerBalanceID ,@MoneyBalanceID ,@CreatorID ,@CreateTime ) ";

                int addTradeRelationRes = db.SetCommand(strTradeRelationSql
                                          , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                          , db.Parameter("@NetTradeNo", weChatModel.out_trade_no, DbType.String)
                                          , db.Parameter("@NetTradeType", 2, DbType.Int32)//1:消费 2:充值
                                          , db.Parameter("@PaymentID", 0, DbType.Int32)
                                          , db.Parameter("@PaymentDetailID", 0, DbType.Int32)
                                          , db.Parameter("@CustomerBalanceID", balanceID, DbType.Int32)
                                          , db.Parameter("@MoneyBalanceID", balanceID, DbType.Int32)
                                          , db.Parameter("@CreatorID", tradeModel.CreatorID, DbType.Int32)
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
                                          , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
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
                                          , db.Parameter("@CreatorID", tradeModel.CreatorID, DbType.String)
                                          , db.Parameter("@CreateTime", time, DbType.DateTime2)).ExecuteNonQuery();

                if (addWechatResultRes <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                db.CommitTransaction();

                #region PUSH
                if (isPush)
                {
                    string selectCustomerDevice = @"SELECT TOP 1 ISNULL(T3.DeviceID, '') AS DeviceID ,T1.Name AS CustomerName ,T3.DeviceType ,T2.smsheading AS CompanyName,ISNULL(T6.BalanceNotice, 0) AS Threshold ,T4.LoginMobile,T2.BalanceRemind
                                                    FROM    [CUSTOMER] T1 WITH ( NOLOCK )
                                                            LEFT JOIN [COMPANY] T2 WITH ( NOLOCK ) ON T1.CompanyID = T2.ID
                                                            LEFT JOIN [LOGIN] T3 WITH ( NOLOCK ) ON T1.UserID = T3.UserID
                                                            LEFT JOIN [USER] T4 WITH ( NOLOCK ) ON T4.ID = t1.UserID
                                                            LEFT JOIN [TBL_CUSTOMER_CARD] T5 WITH ( NOLOCK ) ON T5.UserID = T4.ID AND T5.UserCardNo=@userCardNo
                                                            LEFT JOIN [MST_CARD] T6 WITH(NOLOCK) ON T5.CardID=T6.ID
                                                    WHERE   T1.UserID = @CustomerID";
                    PushOperation_Model pushmodel = db.SetCommand(selectCustomerDevice, db.Parameter("@CustomerID", tradeModel.CustomerID, DbType.Int32)
                                                                                      , db.Parameter("@userCardNo", tradeModel.UserCardNo, DbType.String)).ExecuteObject<PushOperation_Model>();
                    if (pushmodel != null)
                    {
                        if (pushmodel.BalanceRemind)
                        {
                            #region 余额变动短信息提醒
                            if (!string.IsNullOrEmpty(pushmodel.LoginMobile))
                            {
                                strPgm = st.GetFrame(0).GetMethod().Name + "(" + st.GetFrame(0).GetFileLineNumber().ToString() + ")";
                                int result = SMSInfo_DAL.Instance.getSMSInfo(tradeModel.CompanyID, pushmodel.LoginMobile, strPgm, tradeModel.CreatorID);
                                if (result == 0)
                                {
                                    Common.SendShortMessage.sendShortMessageForBalance(pushmodel.LoginMobile, pushmodel.CompanyName, time.ToString("MM月dd日HH时mm分"));
                                    //保存短信发送履历信息
                                    string msg = string.Format(Const.MESSAGE_BALANCE, pushmodel.CompanyName, time.ToString("MM月dd日HH时mm分"));
                                    strPgm = st.GetFrame(0).GetMethod().Name + "(" + st.GetFrame(0).GetFileLineNumber().ToString() + ")";
                                    SMSInfo_DAL.Instance.addSMSHis(tradeModel.CompanyID, tradeModel.BranchID, pushmodel.LoginMobile, msg, strPgm, tradeModel.CreatorID);
                                }
                            }
                            #endregion
                        }
                    }
                }
                #endregion

                return 1;
            }
        }

        public int CardRechargeByAliPay(Alipay_trade_pay_response aliPayModel, DateTime time)
        {
            using (DbManager db = new DbManager())
            {
                System.Diagnostics.StackTrace st = new System.Diagnostics.StackTrace(1, true);
                string strPgm;  //当前的程序名称及行号等监察信息

                db.BeginTransaction();

                decimal totalMoneyAmount = 0;
                decimal totalPointAmount = 0;
                decimal totalCouponAmount = 0;
                int customerBalanceChangeType = 3;
                bool isPush = false;

                #region 根据NetTradeNo获取数据
                string strSelTradeControlSql = @" SELECT  T1.CompanyID ,
                                                        T1.BranchID ,
                                                        T1.NetTradeNo ,
                                                        T1.NetActionType ,
                                                        T1.NetTradeVendor ,
                                                        T1.NetTradeActionMode ,
                                                        T1.ProductName ,
                                                        T1.NetTradeAmount ,
                                                        T1.PointAmount ,
                                                        T1.CouponAmount ,
                                                        T1.MoneyAmount ,
                                                        T1.Participants ,
                                                        --T1.ResponsiblePersonID ,
                                                        T1.UserCardNo ,
                                                        T1.Remark ,
                                                        T1.CreatorID ,
                                                        T1.CustomerID
                                                FROM    [TBL_NETTRADE_CONTROL] T1 WITH ( NOLOCK )
                                                WHERE   T1.NetTradeNo = @NetTradeNo ";

                NetTrade_Control_Model tradeModel = db.SetCommand(strSelTradeControlSql,
                            db.Parameter("@NetTradeNo", aliPayModel.out_trade_no, DbType.String)).ExecuteObject<NetTrade_Control_Model>();

                if (tradeModel == null)
                {
                    return 0;
                }

                #region 获取业绩分享人
                List<Slave_Model> Slavers = new List<Slave_Model>();
                if (!string.IsNullOrEmpty(tradeModel.Participants))
                {
                    string[] strSlavID = tradeModel.Participants.Split(new string[] { "|" }, StringSplitOptions.RemoveEmptyEntries);
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

                string strAddCustomerBalance = @" INSERT [TBL_CUSTOMER_BALANCE]	( CompanyID ,BranchID ,UserID ,ChangeType ,TargetAccount  ,PaymentID ,Remark ,CreatorID ,CreateTime) 
                VALUES(@CompanyID ,@BranchID ,@UserID ,@ChangeType ,@TargetAccount  ,@PaymentID ,@Remark ,@CreatorID ,@CreateTime);select @@IDENTITY";
                int balanceID = db.SetCommand(strAddCustomerBalance,
                            db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32),
                            db.Parameter("@BranchID", tradeModel.BranchID, DbType.Int32),
                            db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32),
                            db.Parameter("@ChangeType", customerBalanceChangeType, DbType.Int32),
                            db.Parameter("@TargetAccount", 1, DbType.Int32),//1:储值卡、2:积分、3:现金券 
                    //db.Parameter("@ResponsiblePersonID", tradeModel.ResponsiblePersonID, DbType.Int32),
                            db.Parameter("@PaymentID", DBNull.Value, DbType.Int32),
                            db.Parameter("@Remark", tradeModel.Remark, DbType.String),
                            db.Parameter("@CreatorID", tradeModel.CreatorID, DbType.Int32),
                            db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteScalar<int>();

                if (balanceID <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                //ActionMode 1:消费支出、2:消费支出撤销、3:储值卡充值、4:储值卡充值撤销、5:储值卡直扣、6:储值卡直扣撤销、7:储值卡直充赠送、8:储值卡直充赠送撤销、9:储值卡退款、10:储值卡退款撤销
                //DepositMode 1:现金、2:银行卡、3:余额转入、4:其他
                string strAddMoneyBalance = @" INSERT INTO [TBL_MONEY_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CreatorID ,@CreateTime)";

                //ActionMode 1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                //DepositMode 1:充值、2:余额转入
                string strAddPointBalance = @" INSERT INTO [TBL_POINT_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CreatorID ,@CreateTime)";

                //ActionMode 1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                //DepositMode 1:充值、2:余额转入
                string strAddCouponBalance = @" INSERT INTO [TBL_COUPON_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CouponType ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CouponType ,@CreatorID ,@CreateTime)";

                #region 充值

                #region 获取卡内余额
                string strCardBalanceSql = @"SELECT BALANCE FROM [TBL_CUSTOMER_CARD] WHERE CompanyID=@CompanyID AND UserID=@CustomerID AND UserCardNo=@UserCardNo";
                decimal cardBalance = db.SetCommand(strCardBalanceSql,
                   db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32),
                   db.Parameter("@CustomerID", tradeModel.CustomerID, DbType.Int32),
                   db.Parameter("@UserCardNo", tradeModel.UserCardNo, DbType.String)).ExecuteScalar<decimal>();
                #endregion

                isPush = true;
                tradeModel.NetTradeAmount = Math.Abs(tradeModel.NetTradeAmount);
                totalMoneyAmount = cardBalance + tradeModel.NetTradeAmount;
                if (totalMoneyAmount < 0)
                {
                    db.RollbackTransaction();
                    return 3;
                }

                #region 查询是不是首冲
                string selIsFstReChargeSql = @"  SELECT COUNT(0) FROM [TBL_MONEY_BALANCE] WHERE UserCardNo=@UserCardNo AND CompanyID=@CompanyID AND ActionMode = 3";
                bool isFstReCharge = db.SetCommand(selIsFstReChargeSql
                                         , db.Parameter("@UserCardNo", tradeModel.UserCardNo, DbType.Int64)
                                         , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)).ExecuteScalar<int>() > 0 ? false : true;
                #endregion

                #region 充值储值卡
                int addres = db.SetCommand(strAddMoneyBalance,
                        db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32),
                        db.Parameter("@BranchID", tradeModel.BranchID, DbType.Int32),
                        db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32),
                        db.Parameter("@CustomerBalanceID", balanceID, DbType.Int32),
                        db.Parameter("@ActionMode", 3, DbType.Int32),//1:消费支出、2:消费支出撤销、3:储值卡充值、4:储值卡充值撤销、5:储值卡直扣、6:储值卡直扣撤销、7:储值卡直充赠送、8:储值卡直充赠送撤销、9:储值卡退款、10:储值卡退款撤销
                        db.Parameter("@DepositMode", 5, DbType.Int32),//1:现金、2:银行卡、3:余额转入、4:微信、5:支付宝
                        db.Parameter("@Remark", tradeModel.Remark, DbType.String),
                        db.Parameter("@UserCardNo", tradeModel.UserCardNo, DbType.String),
                        db.Parameter("@Amount", tradeModel.NetTradeAmount, DbType.Decimal),
                        db.Parameter("@Balance", totalMoneyAmount, DbType.Decimal),
                        db.Parameter("@CreatorID", tradeModel.CreatorID, DbType.Int32),
                        db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                if (addres <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                #region 充值业绩
                string strSelCompanyComissionCalcSql = " SELECT [ComissionCalc] FROM COMPANY WHERE ID=@CompanyID ";
                bool isComissionCalc = db.SetCommand(strSelCompanyComissionCalcSql
                                     , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)).ExecuteScalar<bool>();
                if (isComissionCalc)
                {
                    #region 查询卡的业绩RULE
                    string strSelEcardCommissionRuleSql = @"   SELECT T1.ProfitPct ,
                                                                            T1.ProfitPct ,
                                                                            T1.FstChargeCommType ,
                                                                            T1.FstChargeCommValue ,
                                                                            T1.ChargeCommType ,
                                                                            T1.ChargeCommValue ,
                                                                            T1.CardCode 
                                                                     FROM   [TBL_ECARD_COMMISSION_RULE] T1 WITH(NOLOCK)
                                                                             INNER JOIN [MST_CARD] T2 WITH(NOLOCK) ON T1.CardCode=T2.CardCode AND T2.Available = 1
                                                                             INNER JOIN [TBL_CUSTOMER_CARD] T3 WITH(NOLOCK) ON T3.CardID=T2.ID
                                                                     WHERE  T1.CompanyID = @CompanyID
                                                                            AND T3.UserCardNo = @UserCardNo 
                                                                            AND T1.RecordType=1 ";

                    Ecard_Commission_Rule_Model EcardRuleModel = db.SetCommand(strSelEcardCommissionRuleSql
                                                               , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                                               , db.Parameter("@UserCardNo", tradeModel.UserCardNo, DbType.Int64)).ExecuteObject<Ecard_Commission_Rule_Model>();

                    #endregion

                    if (EcardRuleModel != null && EcardRuleModel.CardCode > 0)
                    {
                        #region 计算首冲还是续费
                        int ChargeCommType = isFstReCharge ? EcardRuleModel.FstChargeCommType : EcardRuleModel.ChargeCommType;//1:按比例 2:固定值
                        decimal ChargeCommValue = isFstReCharge ? EcardRuleModel.FstChargeCommValue : EcardRuleModel.ChargeCommValue;
                        decimal Profit = tradeModel.NetTradeAmount * EcardRuleModel.ProfitPct;

                        object CommFlag = DBNull.Value;//1：首充 2：指定
                        if (isFstReCharge)
                        {
                            CommFlag = 1;
                        }

                        #endregion

                        #region 插入业绩详细表
                        string strAddProfitDetailSql = @" INSERT INTO TBL_PROFIT_COMMISSION_DETAIL ( CompanyID ,BranchID ,SourceType ,SourceID ,SubSourceID ,Income ,ProfitPct ,Profit ,CommType ,CommValue ,AccountID ,AccountProfitPct ,AccountProfit ,AccountComm ,CommFlag ,CreatorID ,CreateTime ) 
                                                                    VALUES ( @CompanyID ,@BranchID ,@SourceType ,@SourceID ,@SubSourceID ,@Income ,@ProfitPct ,@Profit ,@CommType ,@CommValue ,@AccountID ,@AccountProfitPct ,@AccountProfit ,@AccountComm ,@CommFlag ,@CreatorID ,@CreateTime ) ";

                        if (Slavers != null && Slavers.Count > 0)
                        {
                            foreach (Slave_Model item in Slavers)
                            {
                                #region 有业绩分享人
                                decimal AccountProfit = Profit * item.ProfitPct;//员工业绩(=实际业绩 x 员工业绩计算比例)
                                decimal AccountComm = ChargeCommValue * item.ProfitPct;
                                if (ChargeCommType == 1)//1:按比例 2:固定值
                                {
                                    AccountComm = AccountProfit * ChargeCommValue;
                                }

                                int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                    , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                    , db.Parameter("@BranchID", tradeModel.BranchID, DbType.Int32)
                                    , db.Parameter("@SourceType", 3, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                    , db.Parameter("@SourceID", balanceID, DbType.Int64)
                                    , db.Parameter("@SubSourceID", EcardRuleModel.CardCode, DbType.Int64)
                                    , db.Parameter("@Income", tradeModel.NetTradeAmount, DbType.Decimal)//收入 充值时，为TBL_MONEY_BALANCE的Amount
                                    , db.Parameter("@ProfitPct", EcardRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                    , db.Parameter("@Profit", Profit, DbType.Decimal)//实际业绩
                                    , db.Parameter("@CommType", ChargeCommType, DbType.Int32)//该业绩的提成方式
                                    , db.Parameter("@CommValue", ChargeCommValue, DbType.Decimal)//该业绩的提成数值
                                    , db.Parameter("@AccountID", item.SlaveID, DbType.Int32)//获得该业绩的员工ID
                                    , db.Parameter("@AccountProfitPct", item.ProfitPct, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                    , db.Parameter("@AccountProfit", AccountProfit, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                    , db.Parameter("@AccountComm", AccountComm, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
                                    , db.Parameter("@CommFlag", CommFlag, DbType.Int32)//1：首充 2：指定 3：E账户
                                    , db.Parameter("@CreatorID", tradeModel.CreatorID, DbType.Int32)
                                    , db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                                if (addProfitDetailRes != 1)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }
                                #endregion
                            }
                        }
                        else
                        {
                            #region 没有业绩分享人
                            int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                    , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                    , db.Parameter("@BranchID", tradeModel.BranchID, DbType.Int32)
                                    , db.Parameter("@SourceType", 3, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                    , db.Parameter("@SourceID", balanceID, DbType.Int64)
                                    , db.Parameter("@SubSourceID", EcardRuleModel.CardCode, DbType.Int64)
                                    , db.Parameter("@Income", tradeModel.NetTradeAmount, DbType.Decimal)//收入 充值时，为TBL_MONEY_BALANCE的Amount
                                    , db.Parameter("@ProfitPct", EcardRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                    , db.Parameter("@Profit", Profit, DbType.Decimal)//实际业绩
                                    , db.Parameter("@CommType", ChargeCommType, DbType.Int32)//该业绩的提成方式
                                    , db.Parameter("@CommValue", ChargeCommValue, DbType.Decimal)//该业绩的提成数值
                                    , db.Parameter("@AccountID", DBNull.Value, DbType.Int32)//获得该业绩的员工ID
                                    , db.Parameter("@AccountProfitPct", DBNull.Value, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                    , db.Parameter("@AccountProfit", DBNull.Value, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                    , db.Parameter("@AccountComm", DBNull.Value, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
                                    , db.Parameter("@CommFlag", CommFlag, DbType.Int32)//1：首充 2：指定 3：E账户
                                    , db.Parameter("@CreatorID", tradeModel.CreatorID, DbType.Int32)
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
                }
                #endregion

                #endregion

                string strAddHis = @" INSERT INTO [HST_CUSTOMER_CARD] SELECT * FROM [TBL_CUSTOMER_CARD] WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo ";
                string strUpdateCustomerCard = @" UPDATE [TBL_CUSTOMER_CARD] SET Balance=@Balance ,UpdaterID = @UpdaterID , UpdateTime = @UpdateTime WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo";

                #region 修改CustomerCard中的Balance
                int hisRows = db.SetCommand(strAddHis, db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                                     , db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32)
                                                     , db.Parameter("@UserCardNo", tradeModel.UserCardNo, DbType.String)).ExecuteNonQuery();

                if (hisRows == 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                int updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", cardBalance + tradeModel.NetTradeAmount, DbType.Decimal)
                                                     , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                                     , db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32)
                                                     , db.Parameter("@UserCardNo", tradeModel.UserCardNo, DbType.String)
                                                     , db.Parameter("@UpdaterID", tradeModel.CreatorID, DbType.Int32)
                                                     , db.Parameter("@UpdateTime", time, DbType.DateTime)).ExecuteNonQuery();

                if (updateRes == 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                if (tradeModel.PointAmount > 0 || tradeModel.CouponAmount > 0 || tradeModel.MoneyAmount > 0)
                {
                    #region 赠送

                    if (tradeModel.MoneyAmount > 0)
                    {
                        isPush = true;

                        #region 赠送储值卡
                        if (totalMoneyAmount <= 0)
                        {
                            #region 获取卡内余额
                            totalMoneyAmount = db.SetCommand(strCardBalanceSql,
                               db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32),
                               db.Parameter("@CustomerID", tradeModel.CustomerID, DbType.Int32),
                               db.Parameter("@UserCardNo", tradeModel.UserCardNo, DbType.String)).ExecuteScalar<decimal>();
                            #endregion
                        }

                        totalMoneyAmount += Math.Abs(tradeModel.MoneyAmount);

                        #region 充值储值卡
                        addres = db.SetCommand(strAddMoneyBalance,
                               db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32),
                               db.Parameter("@BranchID", tradeModel.BranchID, DbType.Int32),
                               db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32),
                               db.Parameter("@CustomerBalanceID", balanceID, DbType.Int32),
                               db.Parameter("@ActionMode", 7, DbType.Int32),//1:消费支出、2:消费支出撤销、3:储值卡充值、4:储值卡充值撤销、5:储值卡直扣、6:储值卡直扣撤销、7:储值卡直充赠送、8:储值卡直充赠送撤销、9:储值卡退款、10:储值卡退款撤销
                               db.Parameter("@DepositMode", 0, DbType.Int32),//DepositMode 1:现金、2:银行卡、3:余额转入、4:赠送
                               db.Parameter("@Remark", tradeModel.Remark, DbType.String),
                               db.Parameter("@UserCardNo", tradeModel.UserCardNo, DbType.String),
                               db.Parameter("@Amount", tradeModel.MoneyAmount, DbType.Decimal),
                               db.Parameter("@Balance", totalMoneyAmount, DbType.Decimal),
                               db.Parameter("@CreatorID", tradeModel.CreatorID, DbType.Int32),
                               db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                        if (addres <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion
                        #endregion

                        #region 修改CustomerCard中的Balance
                        hisRows = db.SetCommand(strAddHis, db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                                             , db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32)
                                                             , db.Parameter("@UserCardNo", tradeModel.UserCardNo, DbType.String)).ExecuteNonQuery();

                        if (hisRows == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", totalMoneyAmount, DbType.Decimal)
                                                             , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                                             , db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32)
                                                             , db.Parameter("@UserCardNo", tradeModel.UserCardNo, DbType.String)
                                                             , db.Parameter("@UpdaterID", tradeModel.CreatorID, DbType.Int32)
                                                             , db.Parameter("@UpdateTime", time, DbType.DateTime)).ExecuteNonQuery();

                        if (updateRes == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion
                    }

                    if (tradeModel.PointAmount > 0)
                    {
                        DataTable dt = new DataTable();
                        #region 赠送积分卡
                        if (totalPointAmount <= 0)
                        {
                            #region 获取卡内余额

                            strCardBalanceSql = @" SELECT TOP 1
                                                                T1.BALANCE ,
                                                                T1.UserCardNo
                                                        FROM    [TBL_CUSTOMER_CARD] T1 WITH ( NOLOCK )
                                                                LEFT JOIN [MST_CARD] T2 WITH ( NOLOCK ) ON T1.CardID = T2.ID
                                                        WHERE   T1.CompanyID = @CompanyID
                                                                AND T1.UserID = @CustomerID
                                                                AND T2.CardTypeID = 2
                                                        ORDER BY T2.ID DESC ";
                            dt = db.SetCommand(strCardBalanceSql,
                               db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32),
                               db.Parameter("@CustomerID", tradeModel.CustomerID, DbType.Int32)).ExecuteDataTable();

                            if (dt == null)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            totalPointAmount = StringUtils.GetDbDecimal(dt.Rows[0]["BALANCE"].ToString());
                            #endregion
                        }

                        totalPointAmount += Math.Abs(tradeModel.PointAmount);

                        #region 充值积分卡
                        addres = db.SetCommand(strAddPointBalance,
                               db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32),
                               db.Parameter("@BranchID", tradeModel.BranchID, DbType.Int32),
                               db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32),
                               db.Parameter("@CustomerBalanceID", balanceID, DbType.Int32),
                               db.Parameter("@ActionMode", 5, DbType.Int32),//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                               db.Parameter("@DepositMode", 0, DbType.Int32),
                               db.Parameter("@Remark", tradeModel.Remark, DbType.String),
                               db.Parameter("@UserCardNo", dt.Rows[0]["UserCardNo"].ToString(), DbType.String),
                               db.Parameter("@Amount", tradeModel.PointAmount, DbType.Decimal),
                               db.Parameter("@Balance", totalPointAmount, DbType.Decimal),
                               db.Parameter("@CreatorID", tradeModel.CreatorID, DbType.Int32),
                               db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                        if (addres <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion
                        #endregion

                        #region 修改CustomerCard中的Balance
                        hisRows = db.SetCommand(strAddHis, db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                                             , db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32)
                                                             , db.Parameter("@UserCardNo", dt.Rows[0]["UserCardNo"].ToString(), DbType.String)).ExecuteNonQuery();

                        if (hisRows == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", totalPointAmount, DbType.Decimal)
                                                             , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                                             , db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32)
                                                             , db.Parameter("@UserCardNo", dt.Rows[0]["UserCardNo"].ToString(), DbType.String)
                                                             , db.Parameter("@UpdaterID", tradeModel.CreatorID, DbType.Int32)
                                                             , db.Parameter("@UpdateTime", time, DbType.DateTime)).ExecuteNonQuery();

                        if (updateRes == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion
                    }

                    if (tradeModel.CouponAmount > 0)
                    {
                        DataTable dt = new DataTable();
                        #region 赠送现金券卡
                        if (totalCouponAmount <= 0)
                        {
                            #region 获取卡内余额

                            strCardBalanceSql = @" SELECT TOP 1
                                                                T1.BALANCE ,
                                                                T1.UserCardNo
                                                        FROM    [TBL_CUSTOMER_CARD] T1 WITH ( NOLOCK )
                                                                LEFT JOIN [MST_CARD] T2 WITH ( NOLOCK ) ON T1.CardID = T2.ID
                                                        WHERE   T1.CompanyID = @CompanyID
                                                                AND T1.UserID = @CustomerID
                                                                AND T2.CardTypeID = 3
                                                        ORDER BY T2.ID DESC ";
                            dt = db.SetCommand(strCardBalanceSql,
                               db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32),
                               db.Parameter("@CustomerID", tradeModel.CustomerID, DbType.Int32)).ExecuteDataTable();

                            if (dt == null)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            totalCouponAmount = StringUtils.GetDbDecimal(dt.Rows[0]["BALANCE"].ToString());
                            #endregion
                        }

                        totalCouponAmount += Math.Abs(tradeModel.CouponAmount);

                        #region 充现金券卡
                        addres = db.SetCommand(strAddCouponBalance,
                               db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32),
                               db.Parameter("@BranchID", tradeModel.BranchID, DbType.Int32),
                               db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32),
                               db.Parameter("@CustomerBalanceID", balanceID, DbType.Int32),
                               db.Parameter("@ActionMode", 5, DbType.Int32),//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、910:直扣撤销
                               db.Parameter("@DepositMode", 0, DbType.Int32),
                               db.Parameter("@Remark", tradeModel.Remark, DbType.String),
                               db.Parameter("@UserCardNo", dt.Rows[0]["UserCardNo"].ToString(), DbType.String),
                               db.Parameter("@Amount", tradeModel.CouponAmount, DbType.Decimal),
                               db.Parameter("@Balance", totalCouponAmount, DbType.Decimal),
                               db.Parameter("@CouponType", 0, DbType.Int32),
                               db.Parameter("@CreatorID", tradeModel.CreatorID, DbType.Int32),
                               db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                        if (addres <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        #endregion

                        #region 修改CustomerCard中的Balance
                        hisRows = db.SetCommand(strAddHis, db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                                             , db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32)
                                                             , db.Parameter("@UserCardNo", dt.Rows[0]["UserCardNo"].ToString(), DbType.String)).ExecuteNonQuery();

                        if (hisRows == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", totalCouponAmount, DbType.Decimal)
                                                             , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                                             , db.Parameter("@UserID", tradeModel.CustomerID, DbType.Int32)
                                                             , db.Parameter("@UserCardNo", dt.Rows[0]["UserCardNo"].ToString(), DbType.String)
                                                             , db.Parameter("@UpdaterID", tradeModel.CreatorID, DbType.Int32)
                                                             , db.Parameter("@UpdateTime", time, DbType.DateTime)).ExecuteNonQuery();

                        if (updateRes == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion
                    }
                    #endregion
                }

                #region 业绩分享人
                if (balanceID >= 0 && Slavers != null && Slavers.Count > 0)
                {
                    foreach (Slave_Model item in Slavers)
                    {
                        string strAddProfitSql = @" INSERT	INTO TBL_PROFIT( MasterID ,SlaveID ,Type ,ProfitPct ,Available ,CreateTime ,CreatorID) 
                                                VALUES (@MasterID ,@SlaveID ,@Type ,@ProfitPct ,@Available ,@CreateTime ,@CreatorID)";
                        int addProfitres = db.SetCommand(strAddProfitSql, db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                , db.Parameter("@MasterID", balanceID, DbType.Int64)
                                , db.Parameter("@SlaveID", item.SlaveID, DbType.Int32)
                                , db.Parameter("@Type", 1, DbType.Int32)
                                , db.Parameter("@ProfitPct", item.ProfitPct, DbType.Decimal)
                                , db.Parameter("@Available", true, DbType.Boolean)
                                , db.Parameter("@CreateTime", time, DbType.DateTime2)
                                , db.Parameter("@CreatorID", tradeModel.CreatorID, DbType.Int32)).ExecuteNonQuery();

                        if (addProfitres <= 0)
                        {
                            db.RollbackTransaction();
                            //LogUtil.Log("插入业绩表出错", "PaymentID:" + paymentID + "插入业绩表出错。");
                            return 0;
                        }
                    }
                }
                #endregion

                string advanced = Company_DAL.Instance.getAdvancedByCompanyID(tradeModel.CompanyID);
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
                            db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32),
                            db.Parameter("@BranchID", tradeModel.BranchID, DbType.Int32),
                            db.Parameter("@CustomerID", tradeModel.CustomerID, DbType.Int32)).ExecuteScalarList<int>();

                    if (SalesPersonIDList != null || SalesPersonIDList.Count > 0)
                    {
                        string strAddConsultant = @" INSERT INTO [TBL_BUSINESS_CONSULTANT]( CompanyID ,BusinessType ,MasterID ,ConsultantType ,ConsultantID ,CreatorID ,CreateTime )
                                                    VALUES ( @CompanyID ,@BusinessType ,@MasterID ,@ConsultantType ,@ConsultantID ,@CreatorID ,@CreateTime )";

                        foreach (int item in SalesPersonIDList)
                        {
                            int addConsultantRes = db.SetCommand(strAddConsultant
                            , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                            , db.Parameter("@BusinessType", 3, DbType.Int32)//1：订单，2：支付，3：充值
                            , db.Parameter("@MasterID", balanceID, DbType.Int32)
                            , db.Parameter("@ConsultantType", 2, DbType.Int32)//1:美丽顾问 2:销售顾问
                            , db.Parameter("@ConsultantID", item, DbType.Int32)
                            , db.Parameter("@CreatorID", tradeModel.CreatorID, DbType.Int32)
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

                #region 插入TBL_NETTRADE_RELATION
                string strTradeRelationSql = @" INSERT INTO [TBL_NETTRADE_RELATION]( CompanyID ,NetTradeNo ,NetTradeType ,PaymentID ,PaymentDetailID ,CustomerBalanceID ,MoneyBalanceID ,CreatorID ,CreateTime ) 
                                                VALUES ( @CompanyID ,@NetTradeNo ,@NetTradeType ,@PaymentID ,@PaymentDetailID ,@CustomerBalanceID ,@MoneyBalanceID ,@CreatorID ,@CreateTime ) ";

                int addTradeRelationRes = db.SetCommand(strTradeRelationSql
                                          , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                          , db.Parameter("@NetTradeNo", aliPayModel.out_trade_no, DbType.String)
                                          , db.Parameter("@NetTradeType", 2, DbType.Int32)//1:消费 2:充值
                                          , db.Parameter("@PaymentID", 0, DbType.Int32)
                                          , db.Parameter("@PaymentDetailID", 0, DbType.Int32)
                                          , db.Parameter("@CustomerBalanceID", balanceID, DbType.Int32)
                                          , db.Parameter("@MoneyBalanceID", balanceID, DbType.Int32)
                                          , db.Parameter("@CreatorID", tradeModel.CreatorID, DbType.Int32)
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
                if (!string.IsNullOrEmpty(aliPayModel.strFundBillList))
                {
                    strFundBillList = aliPayModel.strFundBillList;
                }

                object objSendPayDate = DBNull.Value;
                if (!string.IsNullOrEmpty(aliPayModel.send_pay_date))
                {
                    objSendPayDate = aliPayModel.send_pay_date;
                }

                object objTradeState = DBNull.Value;
                if (!string.IsNullOrEmpty(aliPayModel.trade_status))
                {
                    objTradeState = aliPayModel.trade_status;
                }
                else if (aliPayModel.code == "10000" && aliPayModel.msg.ToUpper() == "SUCCESS")
                {
                    objTradeState = "TRADE_SUCCESS";
                }

                object objDiscountGoodsDetail = DBNull.Value;
                if (!string.IsNullOrEmpty(aliPayModel.strDiscountGoodsDetail))
                {
                    objDiscountGoodsDetail = aliPayModel.strDiscountGoodsDetail;
                }

                int res = db.SetCommand(strSql
                                          , db.Parameter("@CompanyID", tradeModel.CompanyID, DbType.Int32)
                                          , db.Parameter("@NetTradeNo", aliPayModel.out_trade_no, DbType.String)
                                          , db.Parameter("@TradeState", objTradeState, DbType.String)
                                          , db.Parameter("@Code", aliPayModel.code, DbType.String)
                                          , db.Parameter("@Msg", aliPayModel.msg, DbType.String)
                                          , db.Parameter("@SubMsg", aliPayModel.sub_desc, DbType.String)
                                          , db.Parameter("@TradeNo", aliPayModel.trade_no, DbType.String)
                                          , db.Parameter("@BuyerUserId", aliPayModel.buyer_user_id, DbType.String)
                                          , db.Parameter("@BuyerLogonId", aliPayModel.buyer_logon_id, DbType.String)
                                          , db.Parameter("@TotalAmount", StringUtils.GetDbDecimal(aliPayModel.total_amount) * 100, DbType.Int32)
                                          , db.Parameter("@ReceiptAmount", StringUtils.GetDbDecimal(aliPayModel.receipt_amount) * 100, DbType.Int32)
                                          , db.Parameter("@InvoiceAmount", StringUtils.GetDbDecimal(aliPayModel.invoice_amount) * 100, DbType.Int32)
                                          , db.Parameter("@BuyerPayAmount", StringUtils.GetDbDecimal(aliPayModel.buyer_pay_amount) * 100, DbType.Int32)
                                          , db.Parameter("@PointAmount", StringUtils.GetDbDecimal(aliPayModel.point_amount) * 100, DbType.Int32)
                                          , db.Parameter("@SendPayDate", objSendPayDate, DbType.DateTime2)
                                          , db.Parameter("@FundBillList", strFundBillList, DbType.String)
                                          , db.Parameter("@DiscountGoodsDetail", DBNull.Value, DbType.String)
                                          , db.Parameter("@CreatorID", tradeModel.CreatorID, DbType.String)
                                          , db.Parameter("@CreateTime", time, DbType.DateTime2)).ExecuteNonQuery();

                if (res <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                db.CommitTransaction();

                #region PUSH
                if (isPush)
                {
                    string selectCustomerDevice = @"SELECT TOP 1 ISNULL(T3.DeviceID, '') AS DeviceID ,T1.Name AS CustomerName ,T3.DeviceType ,T2.smsheading AS CompanyName,ISNULL(T6.BalanceNotice, 0) AS Threshold ,T4.LoginMobile,T2.BalanceRemind
                                                    FROM    [CUSTOMER] T1 WITH ( NOLOCK )
                                                            LEFT JOIN [COMPANY] T2 WITH ( NOLOCK ) ON T1.CompanyID = T2.ID
                                                            LEFT JOIN [LOGIN] T3 WITH ( NOLOCK ) ON T1.UserID = T3.UserID
                                                            LEFT JOIN [USER] T4 WITH ( NOLOCK ) ON T4.ID = t1.UserID
                                                            LEFT JOIN [TBL_CUSTOMER_CARD] T5 WITH ( NOLOCK ) ON T5.UserID = T4.ID AND T5.UserCardNo=@userCardNo
                                                            LEFT JOIN [MST_CARD] T6 WITH(NOLOCK) ON T5.CardID=T6.ID
                                                    WHERE   T1.UserID = @CustomerID";
                    PushOperation_Model pushmodel = db.SetCommand(selectCustomerDevice, db.Parameter("@CustomerID", tradeModel.CustomerID, DbType.Int32)
                                                                                      , db.Parameter("@userCardNo", tradeModel.UserCardNo, DbType.String)).ExecuteObject<PushOperation_Model>();
                    if (pushmodel != null)
                    {
                        if (pushmodel.BalanceRemind)
                        {
                            #region 余额变动短信息提醒
                            if (!string.IsNullOrEmpty(pushmodel.LoginMobile))
                            {
                                strPgm = st.GetFrame(0).GetMethod().Name + "(" + st.GetFrame(0).GetFileLineNumber().ToString() + ")";
                                int result = SMSInfo_DAL.Instance.getSMSInfo(tradeModel.CompanyID, pushmodel.LoginMobile, strPgm, tradeModel.CreatorID);
                                if (result == 0)
                                {
                                    Common.SendShortMessage.sendShortMessageForBalance(pushmodel.LoginMobile, pushmodel.CompanyName, time.ToString("MM月dd日HH时mm分"));
                                    //保存短信发送履历信息
                                    string msg = string.Format(Const.MESSAGE_BALANCE, pushmodel.CompanyName, time.ToString("MM月dd日HH时mm分"));
                                    strPgm = st.GetFrame(0).GetMethod().Name + "(" + st.GetFrame(0).GetFileLineNumber().ToString() + ")";
                                    SMSInfo_DAL.Instance.addSMSHis(tradeModel.CompanyID, tradeModel.BranchID, pushmodel.LoginMobile, msg, strPgm, tradeModel.CreatorID);
                                }
                            }
                            #endregion
                        }
                    }
                }
                #endregion

                return 1;
            }
        }

        public List<GetCustomerBalanceList_Model> GetBalanceListByCustomerID(int companyID, int branchID, int customerID)
        {
            using (DbManager db = new DbManager())
            {
                List<GetCustomerBalanceList_Model> list = new List<GetCustomerBalanceList_Model>();
                string strSql = @" SELECT  ID AS BalanceID ,CreateTime ,PaymentID ,ChangeType ,TargetAccount ,  
                                        CASE ChangeType
                                          WHEN 1 THEN '账户消费'
                                          WHEN 2 THEN '账户消费撤销'
                                          WHEN 3 THEN '账户充值'
                                          WHEN 4 THEN '账户充值撤销'
                                          WHEN 5 THEN '账户直扣'
                                          WHEN 6 THEN '账户直扣撤销'
                                          WHEN 7 THEN '账户消费退款' 
                                          WHEN 8 THEN '转卡' 
                                        END AS ChangeTypeName 
                                FROM    [TBL_CUSTOMER_BALANCE]
                                WHERE   CompanyID = @CompanyID 
                                        AND UserID = @CustomerID ";
                if (branchID > 0)
                {
                    strSql += " AND BranchID = @BranchID ";
                }
                strSql += " ORDER BY CreateTime DESC ";
                list = db.SetCommand(strSql,
                                   db.Parameter("@CompanyID", companyID, DbType.Int32),
                                   db.Parameter("@BranchID", branchID, DbType.Int32),
                                   db.Parameter("@CustomerID", customerID, DbType.Int32)).ExecuteList<GetCustomerBalanceList_Model>();

                return list;
            }
        }

        public List<GetCardBalanceList_Model> GetCardBalanceByUserCardNo(int companyID, int branchID, int customerID, string userCardNo, int cardType)
        {
            using (DbManager db = new DbManager())
            {
                List<GetCardBalanceList_Model> list = new List<GetCardBalanceList_Model>();
                string strSql = "";
                if (cardType == 1)
                {
                    #region 储值卡
                    strSql = @"SELECT  T1.CustomerBalanceID AS BalanceID,T2.PaymentID , T1.ActionMode ,T1.CreateTime ,cast(T1.Amount as dec(17,2)) AS Amount , cast(T1.Balance as dec(12,2)) AS Balance ,T2.ChangeType , 
                                    CASE T1.ActionMode
                                      WHEN 1 THEN '消费支出'
                                      WHEN 2 THEN '消费支出撤销'
                                      WHEN 3 THEN '储值卡充值'
                                      WHEN 4 THEN '储值卡充值撤销'
                                      WHEN 5 THEN '储值卡直扣'
                                      WHEN 6 THEN '储值卡直扣撤销'
                                      WHEN 7 THEN '储值卡直充赠送'
                                      WHEN 8 THEN '储值卡直充赠送撤销'
                                      WHEN 9 THEN '储值卡退款'
                                      WHEN 10 THEN '储值卡退款撤销'
                                    END AS ActionModeName,
                                    CASE T1.ActionMode
                                      WHEN 1 THEN 1
                                      WHEN 2 THEN 0
                                      WHEN 3 THEN 0
                                      WHEN 4 THEN 1
                                      WHEN 5 THEN 1
                                      WHEN 6 THEN 0
                                      WHEN 7 THEN 0
                                      WHEN 8 THEN 1
                                      WHEN 9 THEN 0
                                      WHEN 10 THEN 1
                                    END AS ActionType
                            FROM    [TBL_MONEY_BALANCE] T1 WITH(NOLOCK)
                            INNER JOIN [TBL_CUSTOMER_BALANCE] T2 WITH(NOLOCK) ON T1.CustomerBalanceID=T2.ID 
                            WHERE   T1.CompanyID = @CompanyID 
                                    --AND T1.BranchID = @BranchID
                                    AND T1.UserID = @CustomerID 
                                    AND T1.UserCardNo = @UserCardNo 
                                    Order BY T1.ID DESC ";
                    #endregion
                }
                else if (cardType == 2)
                {
                    #region 积分卡
                    strSql = @"SELECT  T1.CustomerBalanceID AS BalanceID, T1.ActionMode ,T1.CreateTime ,cast(T1.Amount as dec(17,2)) AS Amount , cast(T1.Balance as dec(12,2)) AS Balance ,T2.ChangeType , 
                                        CASE T1.ActionMode
                                          WHEN 1 THEN '消费支出'
                                          WHEN 2 THEN '消费支出撤销'
                                          WHEN 3 THEN '消费赠送'
                                          WHEN 4 THEN '消费赠送撤销'
                                          WHEN 5 THEN '储值卡直充赠送'
                                          WHEN 6 THEN '储值卡直充赠送撤销'
                                          WHEN 7 THEN '积分直充'
                                          WHEN 8 THEN '积分直充撤销'
                                          WHEN 9 THEN '积分直扣'
                                          WHEN 10 THEN '积分直扣撤销'
                                          WHEN 11 THEN '积分消费返还'
                                          WHEN 12 THEN '积分消费返还撤销'
                                          WHEN 13 THEN '积分消费赠送扣除'
                                          WHEN 14 THEN '积分消费赠送扣除撤销'
                                        END AS ActionModeName ,
                                        CASE T1.ActionMode
                                          WHEN 1 THEN 1
                                          WHEN 2 THEN 0
                                          WHEN 3 THEN 0
                                          WHEN 4 THEN 1
                                          WHEN 5 THEN 0
                                          WHEN 6 THEN 1
                                          WHEN 7 THEN 0
                                          WHEN 8 THEN 1
                                          WHEN 9 THEN 1
                                          WHEN 10 THEN 0
                                          WHEN 11 THEN 0
                                          WHEN 12 THEN 1
                                          WHEN 13 THEN 1
                                          WHEN 14 THEN 0
                                        END AS ActionType
                            FROM    [TBL_Point_BALANCE] T1 WITH(NOLOCK)
                            INNER JOIN [TBL_CUSTOMER_BALANCE] T2 WITH(NOLOCK) ON T1.CustomerBalanceID=T2.ID 
                            WHERE   T1.CompanyID = @CompanyID 
                                    --AND T1.BranchID = @BranchID 
                                    AND T1.UserID = @CustomerID 
                                    AND T1.UserCardNo = @UserCardNo 
                                    Order BY T1.ID DESC";
                    #endregion
                }
                else if (cardType == 3)
                {
                    #region 现金券卡
                    strSql = @"SELECT  T1.CustomerBalanceID AS BalanceID, T1.ActionMode ,T1.CreateTime ,cast(T1.Amount as dec(17,2)) AS Amount , cast(T1.Balance as dec(12,2)) AS Balance ,T2.ChangeType , 
                                        CASE T1.ActionMode
                                          WHEN 1 THEN '消费支出'
                                          WHEN 2 THEN '消费支出撤销'
                                          WHEN 3 THEN '消费赠送'
                                          WHEN 4 THEN '消费赠送撤销'
                                          WHEN 5 THEN '储值卡直充赠送'
                                          WHEN 6 THEN '储值卡直充赠送撤销'
                                          WHEN 7 THEN '现金券直充'
                                          WHEN 8 THEN '现金券直充撤销'
                                          WHEN 9 THEN '现金券直扣'
                                          WHEN 10 THEN '现金券直扣撤销'
                                          WHEN 11 THEN '现金券消费返还'
                                          WHEN 12 THEN '现金券消费返还撤销'
                                          WHEN 13 THEN '现金券消费赠送扣除'
                                          WHEN 14 THEN '现金券消费赠送扣除撤销'
                                        END AS ActionModeName ,
                                        CASE T1.ActionMode
                                          WHEN 1 THEN 1
                                          WHEN 2 THEN 0
                                          WHEN 3 THEN 0
                                          WHEN 4 THEN 1
                                          WHEN 5 THEN 0
                                          WHEN 6 THEN 1
                                          WHEN 7 THEN 0
                                          WHEN 8 THEN 1
                                          WHEN 9 THEN 1
                                          WHEN 10 THEN 0
                                          WHEN 11 THEN 0
                                          WHEN 12 THEN 1
                                          WHEN 13 THEN 1
                                          WHEN 14 THEN 0
                                        END AS ActionType
                            FROM    [TBL_Coupon_BALANCE] T1 WITH(NOLOCK)
                            INNER JOIN [TBL_CUSTOMER_BALANCE] T2 WITH(NOLOCK) ON T1.CustomerBalanceID=T2.ID 
                            WHERE   T1.CompanyID = @CompanyID 
                                    --AND T1.BranchID = @BranchID 
                                    AND T1.UserID = @CustomerID 
                                    AND T1.UserCardNo = @UserCardNo 
                                    Order BY T1.ID DESC";
                    #endregion
                }

                list = db.SetCommand(strSql
                                   , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                   , db.Parameter("@BranchID", branchID, DbType.Int32)
                                   , db.Parameter("@CustomerID", customerID, DbType.Int32)
                                   , db.Parameter("@UserCardNo", userCardNo, DbType.String)).ExecuteList<GetCardBalanceList_Model>();
                return list;
            }
        }

        public GetBalanceDetail_Model GetBalanceDetail(int companyID, int balanceID, int changeType)
        {
            using (DbManager db = new DbManager())
            {
                GetBalanceDetail_Model model = new GetBalanceDetail_Model();

                #region 查询交易主体
                string strSelDetailSql = @"SELECT  T1.ID AS BalanceID ,T1.CreateTime ,T1.PaymentID ,T1.ChangeType ,T1.TargetAccount ,T1.Remark ,T2.Name AS Operator ,T1.PaymentID ,
                                                    CASE T1.ChangeType
                                                      WHEN 1 THEN '账户消费'
                                                      WHEN 2 THEN '账户消费撤销'
                                                      WHEN 3 THEN '账户充值'
                                                      WHEN 4 THEN '账户充值撤销'
                                                      WHEN 5 THEN '账户直扣'
                                                      WHEN 6 THEN '账户直扣撤销'
                                                      WHEN 7 THEN '账户消费退款' 
                                                      WHEN 8 THEN '转卡' 
                                                    END AS ChangeTypeName ,
                                                    T3.BranchName  
                                            FROM    [TBL_CUSTOMER_BALANCE] T1 WITH ( NOLOCK )
                                                    LEFT JOIN [ACCOUNT] T2 WITH ( NOLOCK ) ON T1.CreatorID = T2.UserID
                                                    LEFT JOIN [BRANCH] T3 WITH ( NOLOCK ) ON T1.BranchID=T3.ID
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.ID = @BalanceID  ";

                model = db.SetCommand(strSelDetailSql,
                                   db.Parameter("@CompanyID", companyID, DbType.Int32),
                                   db.Parameter("@BalanceID", balanceID, DbType.Int32)).ExecuteObject<GetBalanceDetail_Model>();
                #endregion

                if (model == null)
                {
                    return null;
                }

                #region 查询储值卡交易记录SQL
                string strSelMoneyBalance = @" SELECT  T1.CustomerBalanceID AS BalanceID ,T1.ActionMode , 1 AS CardType ,T3.CardName ,T2.UserCardNo ,
                                                    CAST(T1.Amount AS dec(12, 2)) AS Amount ,
                                                    CAST(T1.Balance AS dec(12, 2)) AS Balance ,
                                                    CASE T1.ActionMode
                                                      WHEN 1 THEN '消费支出'
                                                      WHEN 2 THEN '消费支出撤销'
                                                      WHEN 3 THEN '储值卡充值'
                                                      WHEN 4 THEN '储值卡充值撤销'
                                                      WHEN 5 THEN '储值卡直扣'
                                                      WHEN 6 THEN '储值卡直扣撤销'
                                                      WHEN 7 THEN '储值卡直充赠送'
                                                      WHEN 8 THEN '储值卡直充赠送撤销'
                                                      WHEN 9 THEN '储值卡退款'
                                                      WHEN 10 THEN '储值卡退款撤销'
                                                    END AS ActionModeName ,
                                                    CAST(T1.Amount AS dec(12, 2)) AS CardPaidAmount ,
                                                    CASE T1.DepositMode 
                                                        WHEN 1 THEN '现金充值'
                                                        WHEN 2 THEN '银行卡充值'
                                                        WHEN 3 THEN '余额转入'
                                                        WHEN 4 THEN '微信充值'
                                                        WHEN 5 THEN '支付宝充值' 
                                                        WHEN 6 THEN '转卡' 
                                                    END AS DepositModeName  ,
                                                    T1.DepositMode 
                                            FROM    [TBL_MONEY_BALANCE] T1 WITH ( NOLOCK ) 
                                                    LEFT JOIN [TBL_Customer_Card] T2 WITH ( NOLOCK ) ON T1.UserCardNo = T2.UserCardNo
                                                    LEFT JOIN [MST_Card] T3 WITH ( NOLOCK ) ON T2.CardID = T3.ID
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.CustomerBalanceID = @BalanceID ";
                #endregion

                #region 查询积分卡交易记录SQL
                string strSelPointBalance = @" SELECT  T1.CustomerBalanceID AS BalanceID ,T1.ActionMode ,2 AS CardType ,T3.CardName ,T2.UserCardNo ,
                                                    CASE T1.ActionMode
                                                      WHEN 1 THEN CAST(ISNULL(T3.Rate, 1) * T1.Amount AS dec(12, 2))
                                                      WHEN 2 THEN CAST(ISNULL(T3.Rate, 1) * T1.Amount AS dec(12, 2))
                                                      WHEN 3 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 4 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 5 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 6 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 7 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 8 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 9 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 10 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 11 THEN CAST(ISNULL(T3.Rate, 1) * T1.Amount AS dec(12, 2))
                                                      WHEN 12 THEN CAST(ISNULL(T3.Rate, 1) * T1.Amount AS dec(12, 2))
                                                      WHEN 13 THEN CAST(ISNULL(T3.PresentRate, 1) * T1.Amount AS dec(12, 2))
                                                      WHEN 14 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                    END AS Amount ,
                                                    CAST(T1.Balance AS dec(12, 2)) AS Balance , 
                                                    CASE T1.ActionMode
                                                      WHEN 1 THEN '消费支出'
                                                      WHEN 2 THEN '消费支出撤销'
                                                      WHEN 3 THEN '消费赠送'
                                                      WHEN 4 THEN '消费赠送撤销'
                                                      WHEN 5 THEN '储值卡直充赠送'
                                                      WHEN 6 THEN '储值卡直充赠送撤销'
                                                      WHEN 7 THEN '积分直充'
                                                      WHEN 8 THEN '积分直充撤销'
                                                      WHEN 9 THEN '积分直扣'
                                                      WHEN 10 THEN '积分直扣撤销' 
                                                      WHEN 11 THEN '积分消费返还'
                                                      WHEN 12 THEN '积分消费返还撤销'
                                                      WHEN 13 THEN '消费赠送扣除'
                                                      WHEN 14 THEN '积分消费赠送扣除撤销'
                                                    END AS ActionModeName  ,
                                                    CASE T1.ActionMode
                                                      WHEN 1 THEN CAST(T1.Amount AS dec(12, 2))
                                                      WHEN 2 THEN CAST(T1.Amount AS dec(12, 2))
                                                      WHEN 3 THEN CAST(ISNULL(T3.PresentRate, 1) * T1.Amount AS dec(12, 2))
                                                      WHEN 4 THEN CAST(ISNULL(T3.PresentRate, 1) * T1.Amount AS dec(12, 2))
                                                      WHEN 5 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 6 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 7 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 8 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 9 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 10 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 11 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 12 THEN CAST(T1.Amount AS dec(12, 2))
                                                      WHEN 13 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 14 THEN CAST(ISNULL(T3.PresentRate, 1) * T1.Amount AS dec(12, 2))
                                                    END AS CardPaidAmount , 
                                                    CASE T1.DepositMode 
                                                        WHEN 1 THEN '直冲'
                                                        WHEN 2 THEN '余额转入'
                                                    END AS DepositModeName ,
                                                    T1.DepositMode 
                                            FROM    [TBL_Point_BALANCE] T1 WITH ( NOLOCK ) 
                                                    LEFT JOIN [TBL_Customer_Card] T2 WITH ( NOLOCK ) ON T1.UserCardNo = T2.UserCardNo
                                                    LEFT JOIN [MST_Card] T3 WITH ( NOLOCK ) ON T2.CardID = T3.ID
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.CustomerBalanceID = @BalanceID ";
                #endregion

                #region 查询现金券卡交易记录SQL
                string strSelCouponBalance = @" SELECT  T1.CustomerBalanceID AS BalanceID ,T1.ActionMode ,3 AS CardType ,T3.CardName ,T2.UserCardNo ,                                                  
                                                    CASE T1.ActionMode
                                                      WHEN 1 THEN CAST(ISNULL(T3.Rate, 1) * T1.Amount AS dec(12, 2))
                                                      WHEN 2 THEN CAST(ISNULL(T3.Rate, 1) * T1.Amount AS dec(12, 2))
                                                      WHEN 3 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 4 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 5 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 6 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 7 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 8 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 9 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 10 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 11 THEN CAST(ISNULL(T3.Rate, 1) * T1.Amount AS dec(12, 2))
                                                      WHEN 12 THEN CAST(ISNULL(T3.Rate, 1) * T1.Amount AS dec(12, 2))
                                                      WHEN 13 THEN CAST(ISNULL(T3.PresentRate, 1) * T1.Amount AS dec(12, 2))
                                                      WHEN 14 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                    END AS Amount ,
                                                    CAST(T1.Balance AS dec(12, 2)) AS Balance ,
                                                    CASE T1.ActionMode
                                                      WHEN 1 THEN '消费支出'
                                                      WHEN 2 THEN '消费支出撤销'
                                                      WHEN 3 THEN '消费赠送'
                                                      WHEN 4 THEN '消费赠送撤销'
                                                      WHEN 5 THEN '储值卡直充赠送'
                                                      WHEN 6 THEN '储值卡直充赠送撤销'
                                                      WHEN 7 THEN '现金券直充'
                                                      WHEN 8 THEN '现金券直充撤销'
                                                      WHEN 9 THEN '现金券直扣'
                                                      WHEN 10 THEN '现金券直扣撤销'
                                                      WHEN 11 THEN '现金券消费返还'
                                                      WHEN 12 THEN '现金券消费返还撤销'
                                                      WHEN 13 THEN '消费赠送扣除'
                                                      WHEN 14 THEN '现金券消费赠送扣除撤销'
                                                    END AS ActionModeName ,
                                                    CASE T1.ActionMode
                                                      WHEN 1 THEN CAST(T1.Amount AS dec(12, 2))
                                                      WHEN 2 THEN CAST(T1.Amount AS dec(12, 2))
                                                      WHEN 3 THEN CAST(ISNULL(T3.PresentRate, 1) * T1.Amount AS dec(12, 2))
                                                      WHEN 4 THEN CAST(ISNULL(T3.PresentRate, 1) * T1.Amount AS dec(12, 2))
                                                      WHEN 5 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 6 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 7 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 8 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 9 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 10 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 11 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 12 THEN CAST(T1.Amount AS dec(12, 2))
                                                      WHEN 13 THEN CAST(1 * T1.Amount AS dec(12, 2))
                                                      WHEN 14 THEN CAST(ISNULL(T3.PresentRate, 1) * T1.Amount AS dec(12, 2))
                                                    END AS CardPaidAmount ,
                                                    CASE T1.DepositMode 
                                                        WHEN 1 THEN '直冲'
                                                        WHEN 2 THEN '余额转入'
                                                    END AS DepositModeName ,
                                                    T1.DepositMode  
                                            FROM    [TBL_Coupon_BALANCE] T1 WITH ( NOLOCK ) 
                                                    LEFT JOIN [TBL_Customer_Card] T2 WITH ( NOLOCK ) ON T1.UserCardNo = T2.UserCardNo
                                                    LEFT JOIN [MST_Card] T3 WITH ( NOLOCK ) ON T2.CardID = T3.ID
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.CustomerBalanceID = @BalanceID ";
                #endregion

                string strPartSql = "";
                string strMoneyActionMode = "";
                string strPointActionMode = "";
                string strCouponActionMode = "";
                List<BalanceCardDetail_Model> CardDetailList = new List<BalanceCardDetail_Model>();

                switch (changeType)
                {
                    case 1://账户消费
                        #region 账户消费ActionMode
                        if (model.TargetAccount == 1)
                        {
                            strMoneyActionMode = " AND T1.ActionMode = 1  ";// 储值卡消费
                        }
                        else if (model.TargetAccount == 2)
                        {
                            strPointActionMode = " AND T1.ActionMode = 1 ";// 积分卡消费
                        }
                        else if (model.TargetAccount == 3)
                        {
                            strCouponActionMode = " AND T1.ActionMode = 1 ";// 现金券卡消费
                        }
                        else if (model.TargetAccount == 0)
                        {
                            strMoneyActionMode = " AND T1.ActionMode = 1  ";// 储值卡消费
                            strPointActionMode = " AND T1.ActionMode = 1 ";// 积分卡消费
                            strCouponActionMode = " AND T1.ActionMode = 1 ";// 现金券卡消费
                        }
                        #endregion
                        break;
                    case 2://账户消费撤销
                        #region 账户消费撤销ActionMode
                        if (model.TargetAccount == 1)
                        {
                            strMoneyActionMode = " AND T1.ActionMode = 2 ";// 储值卡充值
                        }
                        else if (model.TargetAccount == 2)
                        {
                            strPointActionMode = " AND T1.ActionMode = 2 ";// 积分卡充值
                        }
                        else if (model.TargetAccount == 3)
                        {
                            strCouponActionMode = " AND T1.ActionMode = 2 ";// 现金券卡充值
                        }
                        else
                        {
                            strMoneyActionMode = " AND T1.ActionMode = 2  ";// 储值卡消费
                            strPointActionMode = " AND T1.ActionMode = 2 ";// 积分卡消费
                            strCouponActionMode = " AND T1.ActionMode = 2 ";// 现金券卡消费
                        }
                        #endregion
                        break;
                    case 3://账户充值
                        #region 充值判断ActionMode
                        if (model.TargetAccount == 1)
                        {
                            strMoneyActionMode = " AND T1.ActionMode = 3 ";// 储值卡充值
                        }
                        else if (model.TargetAccount == 2)
                        {
                            strPointActionMode = " AND T1.ActionMode = 7 ";// 积分卡充值
                        }
                        else if (model.TargetAccount == 3)
                        {
                            strCouponActionMode = " AND T1.ActionMode = 7 ";// 现金券卡充值
                        }
                        #endregion
                        break;
                    case 4://账户充值撤销
                        #region 账户充值撤销判断ActionMode
                        if (model.TargetAccount == 1)
                        {
                            strMoneyActionMode = " AND T1.ActionMode = 4 ";// 储值卡充值撤销
                        }
                        else if (model.TargetAccount == 2)
                        {
                            strPointActionMode = " AND T1.ActionMode = 8 ";// 积分卡充值撤销
                        }
                        else if (model.TargetAccount == 3)
                        {
                            strCouponActionMode = " AND T1.ActionMode = 8 ";// 现金券卡充值撤销
                        }
                        #endregion
                        break;
                    case 5://账户直扣
                        #region 扣款判断ActionMode
                        if (model.TargetAccount == 1)
                        {
                            strMoneyActionMode = " AND (T1.ActionMode = 5 OR T1.ActionMode=9) ";// 储值卡扣款 或者等于9
                        }
                        else if (model.TargetAccount == 2)
                        {
                            strPointActionMode = " AND T1.ActionMode = 9 ";// 积分卡直扣
                        }
                        else if (model.TargetAccount == 3)
                        {
                            strCouponActionMode = " AND T1.ActionMode = 9 ";// 现金券卡直扣
                        }
                        #endregion
                        break;
                    case 6://账户直扣撤销
                        #region 账户直扣撤销ActionMode
                        if (model.TargetAccount == 1)
                        {
                            strMoneyActionMode = " AND (T1.ActionMode = 6 OR T1.ActionMode=10) ";// 储值卡扣款 或者等于9
                        }
                        else if (model.TargetAccount == 2)
                        {
                            strPointActionMode = " AND T1.ActionMode = 10 ";// 积分卡直扣
                        }
                        else if (model.TargetAccount == 3)
                        {
                            strCouponActionMode = " AND T1.ActionMode = 10 ";// 现金券卡直扣
                        }
                        #endregion
                        break;
                    case 7:
                        #region 账户消费退款
                        strMoneyActionMode = " AND T1.ActionMode = 9 ";// 直冲赠送撤销
                        strPointActionMode = " AND T1.ActionMode = 11 ";// 积分消费返还
                        strCouponActionMode = " AND T1.ActionMode = 11 ";// 现金券消费返还

                        strPartSql = strSelMoneyBalance + strMoneyActionMode
                        + " UNION ALL " + strSelPointBalance + strPointActionMode
                        + " UNION ALL " + strSelCouponBalance + strCouponActionMode;
                        #endregion
                        break;
                    default:
                        break;
                }

                #region 查询第一块内容
                switch (model.TargetAccount) //目标账户
                {
                    case 1:// 储值卡账户
                        strPartSql = strSelMoneyBalance + strMoneyActionMode;
                        break;
                    case 2:// 积分账户
                        strPartSql = strSelPointBalance + strPointActionMode;
                        break;
                    case 3:// 现金券账户
                        strPartSql = strSelCouponBalance + strCouponActionMode;
                        break;
                    case 0:
                        strPartSql = strSelMoneyBalance + strMoneyActionMode
                       + " UNION ALL " + strSelPointBalance + strPointActionMode
                       + " UNION ALL " + strSelCouponBalance + strCouponActionMode;
                        break;
                    default:
                        strPartSql = "";
                        break;
                }


                if (strPartSql != "")
                {
                    CardDetailList = db.SetCommand(strPartSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                , db.Parameter("@BalanceID", balanceID, DbType.Int32)).ExecuteList<BalanceCardDetail_Model>();
                }

                model.BalanceInfoList = new List<BalanceInfo_Model>();

                if (CardDetailList != null && CardDetailList.Count > 0)
                {
                    BalanceInfo_Model BalanceModel = new BalanceInfo_Model();
                    if (CardDetailList[0].ActionMode == 3)
                    {
                        BalanceModel.ActionModeName = CardDetailList[0].ActionModeName + "(" + CardDetailList[0].DepositModeName + ")";
                    }
                    else
                    {
                        BalanceModel.ActionModeName = CardDetailList[0].ActionModeName;
                    }

                    BalanceModel.ActionMode = CardDetailList[0].ActionMode;
                    BalanceModel.BalanceCardList = CardDetailList;
                    foreach (BalanceCardDetail_Model item in CardDetailList)
                    {
                        model.Amount += item.Amount;
                    }
                    model.BalanceInfoList.Add(BalanceModel);
                }
                #endregion

                #region 查询第二块内容
                CardDetailList = new List<BalanceCardDetail_Model>();

                switch (changeType)
                {
                    case 1:// 账户消费
                        #region 消费赠送
                        strPointActionMode = " AND T1.ActionMode = 3 ";// 消费赠送
                        strCouponActionMode = " AND T1.ActionMode = 3 ";// 消费赠送
                        strPartSql = strSelPointBalance + strPointActionMode + " UNION ALL " + strSelCouponBalance + strCouponActionMode;
                        #endregion
                        break;
                    case 2:// 账户消费撤销
                        #region 消费赠送撤销
                        strPointActionMode = " AND T1.ActionMode = 4 ";// 消费赠送撤销
                        strCouponActionMode = " AND T1.ActionMode = 4 ";// 消费赠送撤销

                        strPartSql = strSelPointBalance + strPointActionMode + " UNION ALL " + strSelCouponBalance + strCouponActionMode;
                        #endregion
                        break;
                    case 3:// 账户直冲
                        #region 充值赠送
                        strMoneyActionMode = " AND T1.ActionMode = 7 ";// 储值卡充值赠送
                        strPointActionMode = " AND T1.ActionMode = 5 ";// 储值卡充值赠送
                        strCouponActionMode = " AND T1.ActionMode = 5 ";// 储值卡充值赠送

                        strPartSql = strSelMoneyBalance + strMoneyActionMode
                        + " UNION ALL " + strSelPointBalance + strPointActionMode
                        + " UNION ALL " + strSelCouponBalance + strCouponActionMode;
                        #endregion
                        break;
                    case 4:// 账户直冲撤销
                        #region 充值赠送撤销
                        strMoneyActionMode = " AND T1.ActionMode = 8 ";// 直冲赠送撤销
                        strPointActionMode = " AND T1.ActionMode = 6 ";// 储值卡直充赠送撤销
                        strCouponActionMode = " AND T1.ActionMode = 6 ";// 储值卡直充赠送撤销

                        strPartSql = strSelMoneyBalance + strMoneyActionMode
                        + " UNION ALL " + strSelPointBalance + strPointActionMode
                        + " UNION ALL " + strSelCouponBalance + strCouponActionMode;
                        #endregion
                        break;
                    case 5:// 账户直扣
                        strPartSql = "";
                        break;
                    case 6:// 账户直扣撤销
                        strPartSql = "";
                        break;
                    case 7:// 退款
                        #region 消费赠送撤销
                        strPointActionMode = " AND T1.ActionMode = 13 ";// 积分消费返还
                        strCouponActionMode = " AND T1.ActionMode = 13 ";// 现金券消费返还

                        strPartSql = strSelPointBalance + strPointActionMode
                        + " UNION ALL " + strSelCouponBalance + strCouponActionMode;
                        #endregion
                        break;
                    default:
                        strPartSql = "";
                        break;
                }

                if (strPartSql != "")
                {
                    CardDetailList = db.SetCommand(strPartSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                , db.Parameter("@BalanceID", balanceID, DbType.Int32)).ExecuteList<BalanceCardDetail_Model>();
                }

                if (CardDetailList != null && CardDetailList.Count > 0)
                {
                    BalanceInfo_Model BalanceModel = new BalanceInfo_Model();
                    BalanceModel.ActionModeName = CardDetailList[0].ActionModeName;
                    BalanceModel.ActionMode = CardDetailList[0].ActionMode;
                    BalanceModel.BalanceCardList = CardDetailList;
                    model.BalanceInfoList.Add(BalanceModel);
                }

                //if (model.Amount <= 0 && model.PaymentID > 0)
                //{
                //    if (model.PaymentID > 0)
                //    {
                //        string strSelPaymentAmountSql = "SELECT TotalPrice FROM  [PAYMENT] WHERE ID=@PaymentID";
                //        model.Amount = db.SetCommand(strSelPaymentAmountSql, db.Parameter("@PaymentID", model.PaymentID, DbType.Int32)).ExecuteScalar<decimal>();
                //    }
                //}

                #endregion

                return model;
            }
        }

        public List<BalanceOrderList_Model> GetBalanceOrderListByPaymentID(int companyID, int paymentID)
        {
            using (DbManager db = new DbManager())
            {
                List<BalanceOrderList_Model> list = new List<BalanceOrderList_Model>();
                string strSql = @"SELECT  T2.ID AS OrderID ,
                                        T2.ProductType ,
                                        T2.TotalSalePrice ,
                                        CASE T2.ProductType WHEN 0 THEN T3.ServiceName ELSE T4.CommodityName END AS ProductName,
                                        CASE T2.ProductType WHEN 0 THEN T3.ID ELSE T4.ID END AS OrderObjectID
                                FROM    [TBL_ORDERPAYMENT_RELATIONSHIP] T1 WITH ( NOLOCK )
                                        LEFT JOIN [Order] T2 WITH ( NOLOCK ) ON T1.OrderID = T2.ID
                                        LEFT JOIN [TBL_ORDER_SERVICE] T3 WITH ( NOLOCK ) ON T2.ID = T3.OrderID
                                        LEFT JOIN [TBL_ORDER_COMMODITY] T4 WITH ( NOLOCK ) ON T2.ID = T4.OrderID
                                WHERE   T1.PaymentID = @PaymentID AND T2.CompanyID=@CompanyID";

                list = db.SetCommand(strSql
                        , db.Parameter("@CompanyID", companyID, DbType.Int32)
                        , db.Parameter("@PaymentID", paymentID, DbType.Int32)).ExecuteList<BalanceOrderList_Model>();

                return list;
            }
        }

        public List<CustomerEcardDiscount_Model> GetCardDiscountList(int companyID, int branchID, int customerID, long productCode, int productType)
        {
            using (DbManager db = new DbManager())
            {
                List<CustomerEcardDiscount_Model> list = new List<CustomerEcardDiscount_Model>();

                string strSql = "";
                int MarketingPolicy = 1;
                if (productType == 0)
                {
                    string strSelSql = "SELECT MarketingPolicy FROM  [SERVICE] T1 WHERE T1.CompanyID = @CompanyID AND T1.Code = @ProductCode AND T1.Available=1";

                    MarketingPolicy = db.SetCommand(strSelSql
                            , db.Parameter("@CompanyID", companyID, DbType.Int32)
                            , db.Parameter("@ProductCode", productCode, DbType.Int64)).ExecuteScalar<int>();
                }
                else
                {
                    string strSelSql = "SELECT MarketingPolicy FROM  [COMMODITY] T1 WHERE T1.CompanyID = @CompanyID AND T1.Code = @ProductCode AND T1.Available=1";

                    MarketingPolicy = db.SetCommand(strSelSql
                            , db.Parameter("@CompanyID", companyID, DbType.Int32)
                            , db.Parameter("@ProductCode", productCode, DbType.Int64)).ExecuteScalar<int>();
                }

                if (MarketingPolicy == 1)
                {
                    if (productType == 0)
                    {
                        strSql = @"SELECT  T1.ID AS CardID ,
                                        T1.CardName ,
                                        ISNULL(T4.Discount, 1) AS Discount , 
                                        T2.UserCardNo
                                FROM    [MST_CARD] T1 WITH ( NOLOCK )
                                        LEFT JOIN [TBL_CUSTOMER_CARD] T2 WITH ( NOLOCK ) ON T1.ID = T2.CardID
                                        LEFT JOIN [MST_CARD_BRANCH] T3 WITH ( NOLOCK ) ON T1.ID = T3.CardID
                                        LEFT JOIN [TBL_CARD_DISCOUNT] T4 WITH ( NOLOCK ) ON T4.CardID = T3.CardID 
                                        LEFT JOIN [SERVICE] T5 WITH ( NOLOCK ) ON T4.DiscountID = T5.DiscountID
                                WHERE   T1.CompanyID = @CompanyID
                                        AND T2.UserID = @Customer
                                        AND T1.CardTypeID = 1
                                        AND T3.BranchID = @BranchID
                                        AND T5.Code = @ProductCode
                                        AND T5.Available = 1";
                    }
                    else
                    {
                        strSql = @"SELECT  T1.ID AS CardID ,
                                        T1.CardName ,
                                        ISNULL(T4.Discount, 1) AS Discount , 
                                        T2.UserCardNo
                                FROM    [MST_CARD] T1 WITH ( NOLOCK )
                                        LEFT JOIN [TBL_CUSTOMER_CARD] T2 WITH ( NOLOCK ) ON T1.ID = T2.CardID
                                        LEFT JOIN [MST_CARD_BRANCH] T3 WITH ( NOLOCK ) ON T1.ID = T3.CardID
                                        LEFT JOIN [TBL_CARD_DISCOUNT] T4 WITH ( NOLOCK ) ON T4.CardID = T3.CardID 
                                        LEFT JOIN [COMMODITY] T5 WITH ( NOLOCK ) ON T4.DiscountID = T5.DiscountID
                                WHERE   T1.CompanyID = @CompanyID
                                        AND T2.UserID = @Customer
                                        AND T1.CardTypeID = 1
                                        AND T3.BranchID = @BranchID
                                        AND T5.Code = @ProductCode
                                        AND T5.Available = 1";
                    }
                }
                else
                {
                    strSql = @"SELECT  T1.ID AS CardID ,
                                    T1.CardName ,
                                    1 AS Discount ,
                                    T2.UserCardNo
                            FROM    [MST_CARD] T1 WITH ( NOLOCK )
                                    LEFT JOIN [TBL_CUSTOMER_CARD] T2 WITH ( NOLOCK ) ON T1.ID = T2.CardID
                                    LEFT JOIN [MST_CARD_BRANCH] T3 WITH ( NOLOCK ) ON T1.ID = T3.CardID
                            WHERE   T1.CompanyID = @CompanyID
                                    AND T2.UserID = @Customer
                                    AND T1.CardTypeID = 1
                                    AND T3.BranchID = @BranchID
                                    AND T1.Available=1";
                }

                list = db.SetCommand(strSql
                            , db.Parameter("@CompanyID", companyID, DbType.Int32)
                            , db.Parameter("@Customer", customerID, DbType.Int32)
                            , db.Parameter("@BranchID", branchID, DbType.Int32)
                            , db.Parameter("@ProductCode", productCode, DbType.Int64)).ExecuteList<CustomerEcardDiscount_Model>();

                return list;
            }
        }

        public List<CustomerBenefitList_Model> getCustomerBenefitList(int companyID, int customerID, int branchID, int type)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT  T2.PolicyID ,
                                            T2.PolicyName ,
                                            T2.PolicyDescription ,
                                            T1.BenefitID ,
                                            T2.PRCode ,
                                            T2.PRValue1 ,
                                            T2.PRValue2 ,
                                            T2.PRValue3 ,
                                            T2.PRValue4 
                                    FROM    TBL_CUSTOMER_BENEFIT T1 WITH ( NOLOCK )
                                            LEFT JOIN TBL_BENEFIT_POLICY T2 ON T1.PolicyID = T2.PolicyID ";

                if (branchID > 0)
                {
                    strSql += " LEFT JOIN [TBL_POLICY_BRANCH] T3 ON T1.PolicyID = T3.PolicyID ";
                }

                strSql += @" WHERE   T1.UserID = @UserID AND T1.CompanyID = @CompanyID ";

                if (type == 1)//未使用
                {
                    strSql += " AND T1.BenefitStatus = 1 AND GETDATE() <= T1.ValidDate ";
                }
                else if (type == 2)//已经过期
                {
                    strSql += " AND T1.BenefitStatus = 1 AND GETDATE() > T1.ValidDate ";
                }
                else if (type == 3)//已经使用
                {
                    strSql += " AND T1.BenefitStatus = 2 ";
                }

                if (branchID > 0)
                {
                    strSql += " AND T3.BranchID = @BranchID ";
                }

                List<CustomerBenefitList_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@UserID", customerID, DbType.Int32)
                    , db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteList<CustomerBenefitList_Model>();


                return list;
            }
        }

        public CustomerBenefitDetail_Model getCustomerBenefitDetail(int companyID, int customerID, string benefitID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT  T2.PolicyID ,
                                        T2.PolicyName ,
                                        T2.PolicyDescription ,
                                        T2.PolicyComments ,
                                        T1.GrantDate ,
                                        T1.ValidDate ,
                                        T2.PRCode ,
                                        T2.PRValue1 ,
                                        T2.PRValue2 ,
                                        T2.PRValue3 ,
                                        T2.PRValue4 ,
                                        T1.BenefitStatus  
                                FROM    [TBL_CUSTOMER_BENEFIT] T1 WITH ( NOLOCK )
                                        LEFT JOIN [TBL_BENEFIT_POLICY] T2 ON T1.PolicyID = T2.PolicyID
                                WHERE   T1.UserID = @UserID
                                        AND T1.CompanyID = @CompanyID
                                        AND T1.BenefitID = @BenefitID 
                                        AND T1.UserID = @UserID ";

                CustomerBenefitDetail_Model model = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                  , db.Parameter("@BenefitID", benefitID, DbType.String)
                                                  , db.Parameter("@UserID", customerID, DbType.Int32)).ExecuteObject<CustomerBenefitDetail_Model>();

                if (model != null)
                {
                    string strBranchSql = @" SELECT  T1.BranchID ,
                                                T2.BranchName
                                        FROM    [TBL_POLICY_BRANCH] T1 WITH ( NOLOCK )
                                                INNER JOIN [BRANCH] T2 WITH ( NOLOCK ) ON T1.BranchID = T2.ID
                                        WHERE   T1.CompanyID = @CompanyID
                                                AND T1.PolicyID = @PolicyID ";
                    model.BranchList = db.SetCommand(strBranchSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                     , db.Parameter("@PolicyID", model.PolicyID, DbType.String)
                                     , db.Parameter("@UserID", customerID, DbType.Int32)).ExecuteList<SimpleBranch_Model>();
                }

                return model;
            }
        }

        public int CardOutAndIn(CardOutAndInOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                decimal inBalance = 0;

                #region 查询出卡的Balance
                string strSqlGetBalance = @" SELECT  T1.Balance
                                            FROM    TBL_CUSTOMER_CARD T1 WITH ( TABLOCK, HOLDLOCK )
                                                    INNER JOIN [MST_CARD] T2 WITH ( TABLOCK, HOLDLOCK ) ON T2.ID = T1.CardID
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.UserID = @CustomerID
                                                    AND T1.UserCardNo = @UserCardNo ";

                decimal orgBalance = db.SetCommand(strSqlGetBalance
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                    , db.Parameter("@UserCardNo", model.OutCardNo, DbType.String)).ExecuteScalar<decimal>();

                if (orgBalance <= 0)
                {
                    return -2;
                }
                #endregion

                #region 查询是否已经有这张卡
                string strSelCardSql = @" SELECT  T1.UserCardNo
                                            FROM    TBL_CUSTOMER_CARD T1
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.UserID = @CustomerID
                                                    AND T1.CardID = @CardID ";
                string inCardNo = db.SetCommand(strSelCardSql
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                    , db.Parameter("@CardID", model.CardID, DbType.String)).ExecuteScalar<string>();
                #endregion

                if (string.IsNullOrWhiteSpace(inCardNo))
                {
                    #region 没有卡创建卡,余额直接等于出卡的金额
                    inCardNo = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "UserCardNo", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<string>();

                    object realCardNo = DBNull.Value;
                    if (!string.IsNullOrWhiteSpace(model.RealCardNo))
                    {
                        realCardNo = model.RealCardNo;
                    }

                    string strSql = @" INSERT	INTO [TBL_CUSTOMER_CARD] ( CompanyID ,BranchID ,UserID ,UserCardNo ,CardID ,Currency ,Balance ,CardCreatedDate ,CardExpiredDate ,RealCardNo ,CreatorID ,CreateTime) 
                                    VALUES  (@CompanyID ,@BranchID ,@UserID ,@UserCardNo ,@CardID ,@Currency ,@Balance ,@CardCreatedDate ,@CardExpiredDate ,@RealCardNo ,@CreatorID ,@CreateTime)";

                    int addRes = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                    , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                    , db.Parameter("@UserCardNo", inCardNo, DbType.Int64)
                                                    , db.Parameter("@CardID", model.CardID, DbType.Int32)
                                                    , db.Parameter("@Currency", "CNY", DbType.String)
                                                    , db.Parameter("@Balance", orgBalance, DbType.Decimal)
                                                    , db.Parameter("@CardCreatedDate", model.Time, DbType.DateTime)
                                                    , db.Parameter("@CardExpiredDate", model.CardExpiredDate, DbType.DateTime)
                                                    , db.Parameter("@RealCardNo", realCardNo, DbType.String)
                                                    , db.Parameter("@CreatorID", model.OperaterID, DbType.Int32)
                                                    , db.Parameter("@CreateTime", model.Time, DbType.DateTime)).ExecuteNonQuery();
                    if (addRes <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    inBalance = orgBalance;
                    #endregion
                }
                else
                {
                    if (model.OutCardNo == inCardNo)
                    {
                        return -1;
                    }

                    #region 有进卡直接修改卡余额

                    string inBalanceSql = @" SELECT  Balance  FROM    TBL_CUSTOMER_CARD T1  
                                                    WHERE   CompanyID = @CompanyID
                                                    AND UserID = @CustomerID
                                                    AND UserCardNo = @UserCardNo ";
                    inBalance = db.SetCommand(inBalanceSql
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                    , db.Parameter("@UserCardNo", inCardNo, DbType.String)).ExecuteScalar<decimal>();


                    string strUpdateCardSql = @" UPDATE  TBL_CUSTOMER_CARD
                                            SET     Balance = @Balance ,
                                                    UpdaterID = @UpdaterID ,
                                                    UpdateTime = @UpdateTime
                                            WHERE   CompanyID = @CompanyID
                                                    AND UserID = @CustomerID
                                                    AND UserCardNo = @UserCardNo ";
                    inBalance += orgBalance;
                    int updateRes = db.SetCommand(strUpdateCardSql
                        , db.Parameter("@Balance", inBalance, DbType.Decimal)
                        , db.Parameter("@UpdaterID", model.OperaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", model.Time, DbType.DateTime)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                        , db.Parameter("@UserCardNo", inCardNo, DbType.String)).ExecuteNonQuery();

                    if (updateRes <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    #endregion
                }

                if (model.IsDefault)
                {
                    #region 设置默认卡
                    string strSqlHistoryUser = " INSERT INTO [HISTORY_CUSTOMER] SELECT * FROM [CUSTOMER] WHERE CompanyID=@CompanyID AND UserID=@UserID ";
                    int hisRows = db.SetCommand(strSqlHistoryUser, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                              , db.Parameter("@UserID", model.CustomerID, DbType.Int32)).ExecuteNonQuery();

                    if (hisRows == 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    string strUpdateSql = @"UPDATE  [CUSTOMER]
                                SET     DefaultCardNo = @userCardNo ,
                                        UpdaterID = @UpdaterID ,
                                        UpdateTime = @UpdateTime
                                WHERE   UserID = @CustomerID
                                        AND CompanyID = @CompanyID ";
                    int res = db.SetCommand(strUpdateSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                               , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                               , db.Parameter("@UserCardNo", inCardNo, DbType.String)
                                               , db.Parameter("@UpdaterID", model.OperaterID, DbType.Int32)
                                               , db.Parameter("@UpdateTime", model.Time, DbType.DateTime)).ExecuteNonQuery();

                    if (res <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    #endregion
                }

                #region 修改出卡的余额
                string strUpdateCardOutSql = @" UPDATE  TBL_CUSTOMER_CARD
                                            SET     Balance = @Balance ,
                                                    UpdaterID = @UpdaterID ,
                                                    UpdateTime = @UpdateTime
                                            WHERE   CompanyID = @CompanyID
                                                    AND UserID = @CustomerID
                                                    AND UserCardNo = @UserCardNo ";
                int updateOutRes = db.SetCommand(strUpdateCardOutSql
                    , db.Parameter("@Balance", 0, DbType.Decimal)
                    , db.Parameter("@UpdaterID", model.OperaterID, DbType.Int32)
                    , db.Parameter("@UpdateTime", model.Time, DbType.DateTime)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                    , db.Parameter("@UserCardNo", model.OutCardNo, DbType.String)).ExecuteNonQuery();

                if (updateOutRes <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }


                #endregion

                string strAddCustomerBalance = @" INSERT [TBL_CUSTOMER_BALANCE]	( CompanyID ,BranchID ,UserID ,ChangeType ,TargetAccount  ,PaymentID ,Remark ,CreatorID ,CreateTime) 
                VALUES(@CompanyID ,@BranchID ,@UserID ,@ChangeType ,@TargetAccount  ,@PaymentID ,@Remark ,@CreatorID ,@CreateTime);select @@IDENTITY";

                #region 插入出卡Money_Balance表
                int outBalanceID = db.SetCommand(strAddCustomerBalance,
                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                            db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                            db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                            db.Parameter("@ChangeType", 8, DbType.Int32),//1:帐户消费、2:帐户消费撤销、3：帐户充值、4：帐户充值撤销、5：帐户直扣、6：帐户直扣撤销 7：账户消费退款 8:账户转入转出
                            db.Parameter("@TargetAccount", 1, DbType.Int32),
                            db.Parameter("@PaymentID", DBNull.Value, DbType.Int32),
                            db.Parameter("@Remark", model.Remark, DbType.String),
                            db.Parameter("@CreatorID", model.OperaterID, DbType.Int32),
                            db.Parameter("@CreateTime", model.Time, DbType.DateTime)).ExecuteScalar<int>();

                if (outBalanceID <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                decimal outMoney = orgBalance * -1;
                //ActionMode 1:消费支出、2:消费支出撤销、3:储值卡充值、4:储值卡充值撤销、5:储值卡直扣、6:储值卡直扣撤销、7:储值卡直充赠送、8:储值卡直充赠送撤销、9:储值卡退款、10:储值卡退款撤销
                //DepositMode 1:现金、2:银行卡、3:余额转入、4:其他 6:转出
                string strAddMoneyBalance = @" INSERT INTO [TBL_MONEY_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CreatorID ,@CreateTime)";

                int addres = db.SetCommand(strAddMoneyBalance,
                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                            db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                            db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                            db.Parameter("@CustomerBalanceID", outBalanceID, DbType.Int32),
                            db.Parameter("@ActionMode", 5, DbType.Int32),//1:消费支出、2:消费支出撤销、3:储值卡充值、4:储值卡充值撤销、5:储值卡直扣、6:储值卡直扣撤销、7:储值卡直充赠送、8:储值卡直充赠送撤销、9:储值卡退款、10:储值卡退款撤销
                            db.Parameter("@DepositMode", 6, DbType.Int32),//1:现金、2:银行卡、3:余额转入、4:其他 6:转入转出
                            db.Parameter("@Remark", model.Remark, DbType.String),
                            db.Parameter("@UserCardNo", model.OutCardNo, DbType.String),
                            db.Parameter("@Amount", outMoney, DbType.Decimal),
                            db.Parameter("@Balance", 0, DbType.Decimal),
                            db.Parameter("@CreatorID", model.OperaterID, DbType.Int32),
                            db.Parameter("@CreateTime", model.Time, DbType.DateTime)).ExecuteNonQuery();

                if (addres <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                #region 插入进卡Money_Balance表

                int inBalanceID = db.SetCommand(strAddCustomerBalance,
                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                            db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                            db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                            db.Parameter("@ChangeType", 8, DbType.Int32),//1:帐户消费、2:帐户消费撤销、3：帐户充值、4：帐户充值撤销、5：帐户直扣、6：帐户直扣撤销 7：账户消费退款 8:账户转入转出
                            db.Parameter("@TargetAccount", 1, DbType.Int32),
                            db.Parameter("@PaymentID", DBNull.Value, DbType.Int32),
                            db.Parameter("@Remark", model.Remark, DbType.String),
                            db.Parameter("@CreatorID", model.OperaterID, DbType.Int32),
                            db.Parameter("@CreateTime", model.Time, DbType.DateTime)).ExecuteScalar<int>();

                if (inBalanceID <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                addres = db.SetCommand(strAddMoneyBalance,
                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                            db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                            db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                            db.Parameter("@CustomerBalanceID", inBalanceID, DbType.Int32),
                            db.Parameter("@ActionMode", 3, DbType.Int32),//1:消费支出、2:消费支出撤销、3:储值卡充值、4:储值卡充值撤销、5:储值卡直扣、6:储值卡直扣撤销、7:储值卡直充赠送、8:储值卡直充赠送撤销、9:储值卡退款、10:储值卡退款撤销
                            db.Parameter("@DepositMode", 6, DbType.Int32),//1:现金、2:银行卡、3:余额转入、4:其他 6:转入转出
                            db.Parameter("@Remark", model.Remark, DbType.String),
                            db.Parameter("@UserCardNo", inCardNo, DbType.String),
                            db.Parameter("@Amount", orgBalance, DbType.Decimal),
                            db.Parameter("@Balance", inBalance, DbType.Decimal),
                            db.Parameter("@CreatorID", model.OperaterID, DbType.Int32),
                            db.Parameter("@CreateTime", model.Time, DbType.DateTime)).ExecuteNonQuery();

                if (addres <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                db.CommitTransaction();
                return 1;
            }

        }

        #region Web方法
        public GetBalanceDetailForWeb_Model GetBalanceDetailForWeb(int companyID, int balanceID, int BranchID)
        {
            using (DbManager db = new DbManager())
            {
                GetBalanceDetailForWeb_Model model = new GetBalanceDetailForWeb_Model();
                #region 查询交易主体
                string strSelDetailSql = @"SELECT  T1.ID AS BalanceID,T1.BranchID ,T1.CreateTime ,T1.PaymentID ,T1.ChangeType ,T1.TargetAccount ,T1.Remark ,T2.Name AS Operator ,T1.PaymentID ,
                                                    CASE T1.ChangeType
                                                      WHEN 1 THEN '账户消费'
                                                      WHEN 2 THEN '账户消费撤销'
                                                      WHEN 3 THEN '账户充值'
                                                      WHEN 4 THEN '账户充值撤销'
                                                      WHEN 5 THEN '账户直扣'
                                                      WHEN 6 THEN '账户直扣撤销' 
                                                      WHEN 7 THEN '账户消费退款' 
                                                    END AS ChangeTypeName
                                            FROM    [TBL_CUSTOMER_BALANCE] T1 WITH ( NOLOCK )
                                                    LEFT JOIN [ACCOUNT] T2 WITH ( NOLOCK ) ON T1.CreatorID = T2.UserID
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.ID = @BalanceID 
                                                    AND ( T1.ChangeType = 3 OR T1.ChangeType = 5 ) 
and not exists (select T3.RelatedID from [TBL_CUSTOMER_BALANCE] T3 WHERE T1.ID = RelatedID AND T3.CompanyID=@CompanyID ) 
 ";
                if (BranchID > 0)
                {
                    strSelDetailSql += " AND T1.BranchID =" + BranchID.ToString();
                }

                model = db.SetCommand(strSelDetailSql,
                                   db.Parameter("@CompanyID", companyID, DbType.Int32),
                                   db.Parameter("@BalanceID", balanceID, DbType.Int32)).ExecuteObject<GetBalanceDetailForWeb_Model>();
                #endregion

                if (model == null)
                {
                    return null;
                }

                #region 查询储值卡交易记录SQL
                string strSelMoneyBalance = @" SELECT  T1.CustomerBalanceID AS BalanceID ,T1.ActionMode , 1 AS CardType ,T3.CardName ,T1.UserCardNo ,
                                                    CAST(T1.Amount AS dec(12, 2)) AS Amount ,
                                                    CAST(T1.Balance AS dec(12, 2)) AS Balance ,
                                                    CASE T1.ActionMode
                                                      WHEN 1 THEN '消费支出'
                                                      WHEN 2 THEN '消费支出撤销'
                                                      WHEN 3 THEN '储值卡充值'
                                                      WHEN 4 THEN '储值卡充值撤销'
                                                      WHEN 5 THEN '储值卡直扣'
                                                      WHEN 6 THEN '储值卡直扣撤销'
                                                      WHEN 7 THEN '储值卡直充赠送'
                                                      WHEN 8 THEN '储值卡直充赠送撤销'
                                                      WHEN 9 THEN '储值卡退款'
                                                      WHEN 10 THEN '储值卡退款撤销'
                                                    END AS ActionModeName ,T1.DepositMode
                                            FROM    [TBL_MONEY_BALANCE] T1 WITH ( NOLOCK ) 
                                                    LEFT JOIN [TBL_Customer_Card] T2 WITH ( NOLOCK ) ON T1.UserCardNo = T2.UserCardNo
                                                    LEFT JOIN [MST_Card] T3 WITH ( NOLOCK ) ON T2.CardID = T3.ID
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.CustomerBalanceID = @BalanceID ";
                #endregion

                #region 查询积分卡交易记录SQL
                string strSelPointBalance = @" SELECT  T1.CustomerBalanceID AS BalanceID ,T1.ActionMode ,2 AS CardType ,T3.CardName ,T1.UserCardNo ,
                                                    CAST(T1.Amount AS dec(12, 2)) AS Amount ,
                                                    CAST(T1.Balance AS dec(12, 2)) AS Balance ,
                                                    CASE T1.ActionMode
                                                      WHEN 1 THEN '消费支出'
                                                      WHEN 2 THEN '消费支出撤销'
                                                      WHEN 3 THEN '消费赠送'
                                                      WHEN 4 THEN '消费赠送撤销'
                                                      WHEN 5 THEN '储值卡直充赠送'
                                                      WHEN 6 THEN '储值卡直充赠送撤销'
                                                      WHEN 7 THEN '积分直充'
                                                      WHEN 8 THEN '积分直充撤销'
                                                      WHEN 9 THEN '积分直扣'
                                                      WHEN 10 THEN '积分直扣撤销'
                                                    END AS ActionModeName ,T1.DepositMode
                                            FROM    [TBL_Point_BALANCE] T1 WITH ( NOLOCK ) 
                                                    LEFT JOIN [TBL_Customer_Card] T2 WITH ( NOLOCK ) ON T1.UserCardNo = T2.UserCardNo
                                                    LEFT JOIN [MST_Card] T3 WITH ( NOLOCK ) ON T2.CardID = T3.ID
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.CustomerBalanceID = @BalanceID ";
                #endregion

                #region 查询现金券卡交易记录SQL
                string strSelCouponBalance = @" SELECT  T1.CustomerBalanceID AS BalanceID ,T1.ActionMode ,3 AS CardType ,T3.CardName ,T1.UserCardNo ,
                                                    CAST(T1.Amount AS dec(12, 2)) AS Amount ,
                                                    CAST(T1.Balance AS dec(12, 2)) AS Balance ,
                                                    CASE T1.ActionMode
                                                      WHEN 1 THEN '消费支出'
                                                      WHEN 2 THEN '消费支出撤销'
                                                      WHEN 3 THEN '消费赠送'
                                                      WHEN 4 THEN '消费赠送撤销'
                                                      WHEN 5 THEN '储值卡直充赠送'
                                                      WHEN 6 THEN '储值卡直充赠送撤销'
                                                      WHEN 7 THEN '现金券直充'
                                                      WHEN 8 THEN '现金券直充撤销'
                                                      WHEN 9 THEN '现金券直扣'
                                                      WHEN 10 THEN '现金券直扣撤销'
                                                    END AS ActionModeName ,T1.DepositMode
                                            FROM    [TBL_Coupon_BALANCE] T1 WITH ( NOLOCK ) 
                                                    LEFT JOIN [TBL_Customer_Card] T2 WITH ( NOLOCK ) ON T1.UserCardNo = T2.UserCardNo
                                                    LEFT JOIN [MST_Card] T3 WITH ( NOLOCK ) ON T2.CardID = T3.ID
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.CustomerBalanceID = @BalanceID ";
                #endregion

                string strPartSql = "";
                string strMoneyActionMode = "";
                string strPointActionMode = "";
                string strCouponActionMode = "";
                List<BalanceCardDetail_Model> CardDetailList = new List<BalanceCardDetail_Model>();

                switch (model.ChangeType)
                {
                    case 3://账户充值
                        #region 充值判断ActionMode
                        if (model.TargetAccount == 1)
                        {
                            strMoneyActionMode = " AND T1.ActionMode = 3 ";// 储值卡充值
                        }
                        else if (model.TargetAccount == 2)
                        {
                            strPointActionMode = " AND T1.ActionMode = 7 ";// 积分卡充值
                        }
                        else if (model.TargetAccount == 3)
                        {
                            strCouponActionMode = " AND T1.ActionMode = 7 ";// 现金券卡充值
                        }
                        #endregion
                        break;

                    case 5://账户直扣
                        #region 扣款判断ActionMode
                        if (model.TargetAccount == 1)
                        {
                            strMoneyActionMode = " AND (T1.ActionMode = 5 OR T1.ActionMode=9) ";// 储值卡扣款 或者等于9
                        }
                        else if (model.TargetAccount == 2)
                        {
                            strPointActionMode = " AND T1.ActionMode = 9 ";// 积分卡直扣
                        }
                        else if (model.TargetAccount == 3)
                        {
                            strCouponActionMode = " AND T1.ActionMode = 9 ";// 现金券卡直扣
                        }
                        #endregion
                        break;
                    default:
                        break;
                }

                #region 查询第一块内容
                switch (model.TargetAccount) //目标账户
                {
                    case 1:// 储值卡账户
                        strPartSql = strSelMoneyBalance + strMoneyActionMode;
                        break;
                    case 2:// 积分账户
                        strPartSql = strSelPointBalance + strPointActionMode;
                        break;
                    case 3:// 现金券账户
                        strPartSql = strSelCouponBalance + strCouponActionMode;
                        break;
                    default:
                        strPartSql = "";
                        break;
                }

                if (strPartSql != "")
                {
                    CardDetailList = db.SetCommand(strPartSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                , db.Parameter("@BalanceID", balanceID, DbType.Int32)).ExecuteList<BalanceCardDetail_Model>();
                }

                model.BalanceList = new List<BalanceInfo_Model>();

                if (CardDetailList != null && CardDetailList.Count > 0)
                {
                    BalanceInfo_Model BalanceModel = new BalanceInfo_Model();
                    BalanceModel.ActionModeName = CardDetailList[0].ActionModeName;
                    BalanceModel.ActionMode = CardDetailList[0].ActionMode;
                    BalanceModel.BalanceCardList = CardDetailList;
                    foreach (BalanceCardDetail_Model item in CardDetailList)
                    {
                        model.Amount += item.Amount;
                    }
                    model.BalanceList.Add(BalanceModel);
                }
                #endregion

                #region 查询第二块内容
                CardDetailList = new List<BalanceCardDetail_Model>();

                switch (model.ChangeType)
                {
                    case 1:// 账户消费
                        #region 消费赠送
                        strPointActionMode = " AND T1.ActionMode = 3 ";// 消费赠送
                        strCouponActionMode = " AND T1.ActionMode = 3 ";// 消费赠送
                        strPartSql = strSelPointBalance + strPointActionMode + " UNION ALL " + strSelCouponBalance + strCouponActionMode;
                        #endregion
                        break;
                    case 2:// 账户消费撤销
                        #region 消费赠送撤销
                        strPointActionMode = " AND T1.ActionMode = 4 ";// 消费赠送撤销
                        strCouponActionMode = " AND T1.ActionMode = 4 ";// 消费赠送撤销

                        strPartSql = strSelPointBalance + strPointActionMode + " UNION ALL " + strSelCouponBalance + strCouponActionMode;
                        #endregion
                        break;
                    case 3:// 账户直冲
                        #region 充值赠送
                        strMoneyActionMode = " AND T1.ActionMode = 7 ";// 储值卡充值赠送
                        strPointActionMode = " AND T1.ActionMode = 5 ";// 储值卡充值赠送
                        strCouponActionMode = " AND T1.ActionMode = 5 ";// 储值卡充值赠送

                        strPartSql = strSelMoneyBalance + strMoneyActionMode
                        + " UNION ALL " + strSelPointBalance + strPointActionMode
                        + " UNION ALL " + strSelCouponBalance + strCouponActionMode;
                        #endregion
                        break;
                    case 4:// 账户直冲撤销
                        #region 充值赠送撤销
                        strMoneyActionMode = " AND T1.ActionMode = 8 ";// 直冲赠送撤销
                        strPointActionMode = " AND T1.ActionMode = 6 ";// 储值卡直充赠送撤销
                        strCouponActionMode = " AND T1.ActionMode = 6 ";// 储值卡直充赠送撤销

                        strPartSql = strSelMoneyBalance + strMoneyActionMode
                        + " UNION ALL " + strSelPointBalance + strPointActionMode
                        + " UNION ALL " + strSelCouponBalance + strCouponActionMode;
                        #endregion
                        break;
                    case 5:// 账户直扣
                        strPartSql = "";
                        break;
                    case 6:// 账户直扣撤销
                        strPartSql = "";
                        break;
                    default:
                        strPartSql = "";
                        break;
                }

                if (strPartSql != "")
                {
                    CardDetailList = db.SetCommand(strPartSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                , db.Parameter("@BalanceID", balanceID, DbType.Int32)).ExecuteList<BalanceCardDetail_Model>();
                }

                if (CardDetailList != null && CardDetailList.Count > 0)
                {
                    model.GiveList = new List<BalanceInfo_Model>();
                    BalanceInfo_Model BalanceModel = new BalanceInfo_Model();
                    BalanceModel.ActionModeName = CardDetailList[0].ActionModeName;
                    BalanceModel.ActionMode = CardDetailList[0].ActionMode;
                    BalanceModel.BalanceCardList = CardDetailList;
                    model.GiveList.Add(BalanceModel);
                }
                #endregion

                string strSqlProfit = " select T1.SlaveID AccountID,T2.Name AccountName,T1.ProfitPct from [TBL_PROFIT] T1 LEFT JOIN [ACCOUNT] T2 ON T1.SlaveID = T2.UserID WHERE T1.MasterID =@MasterID AND T1.Type = 1 AND T1.Available = 1 ";
                model.ProfitList = new List<Profit_Model>();
                model.ProfitList = db.SetCommand(strSqlProfit, db.Parameter("@MasterID", balanceID, DbType.Int32)).ExecuteList<Profit_Model>();
                return model;
            }
        }

        public int CancelCharge(int companyID, int branchID, int balanceID, int updaterID)
        {
            DateTime time = DateTime.Now.ToLocalTime();
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                GetBalanceDetailForWeb_Model model = new GetBalanceDetailForWeb_Model();
                #region 查询交易主体
                string strSelDetailSql = @"SELECT  T1.ID AS BalanceID ,T1.BranchID ,T1.CreateTime ,T1.PaymentID ,T1.ChangeType ,T1.TargetAccount ,T1.PaymentID,T1.UserID AS CustomerID  
                                            FROM    [TBL_CUSTOMER_BALANCE] T1 WITH ( NOLOCK )
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.ID = @BalanceID 
                                                    AND ( T1.ChangeType = 3 OR T1.ChangeType = 5 ) ";

                model = db.SetCommand(strSelDetailSql,
                                   db.Parameter("@CompanyID", companyID, DbType.Int32),
                                   db.Parameter("@BalanceID", balanceID, DbType.Int32)).ExecuteObject<GetBalanceDetailForWeb_Model>();
                #endregion

                if (model == null)
                {
                    db.RollbackTransaction();
                    return 2;
                }

                int changeType = model.ChangeType;
                if (model.ChangeType == 3)
                {
                    changeType = 4;
                }

                if (model.ChangeType == 5)
                {
                    changeType = 6;
                }

                #region 插入新的CustomerBalance
                string strAddCustomerBalance = @" INSERT [TBL_CUSTOMER_BALANCE]	( CompanyID ,BranchID ,UserID ,ChangeType ,TargetAccount ,PaymentID ,RelatedID ,Remark ,CreatorID ,CreateTime) 
                VALUES(@CompanyID ,@BranchID ,@UserID ,@ChangeType ,@TargetAccount  ,@PaymentID ,@RelatedID ,@Remark ,@CreatorID ,@CreateTime);select @@IDENTITY";
                int newBalanceID = db.SetCommand(strAddCustomerBalance,
                            db.Parameter("@CompanyID", companyID, DbType.Int32),
                            db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                            db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                            db.Parameter("@ChangeType", changeType, DbType.Int32),
                            db.Parameter("@TargetAccount", model.TargetAccount, DbType.Int32),
                            db.Parameter("@PaymentID", DBNull.Value, DbType.Int32),
                            db.Parameter("@RelatedID", balanceID, DbType.Int32),
                            db.Parameter("@Remark", DBNull.Value, DbType.String),
                            db.Parameter("@CreatorID", updaterID, DbType.Int32),
                            db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteScalar<int>();

                if (newBalanceID <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                #region 查询储值卡交易记录SQL
                string strSelMoneyBalance = @" SELECT  T1.CustomerBalanceID AS BalanceID ,T1.ActionMode , 1 AS CardType ,T3.CardName ,T1.UserCardNo ,T1.DepositMode,
                                                    CAST(T1.Amount AS dec(12, 2)) AS Amount ,
                                                    CAST(T1.Balance AS dec(12, 2)) AS Balance ,
                                                    CASE T1.ActionMode
                                                      WHEN 1 THEN '消费支出'
                                                      WHEN 2 THEN '消费支出撤销'
                                                      WHEN 3 THEN '储值卡充值'
                                                      WHEN 4 THEN '储值卡充值撤销'
                                                      WHEN 5 THEN '储值卡直扣'
                                                      WHEN 6 THEN '储值卡直扣撤销'
                                                      WHEN 7 THEN '储值卡直充赠送'
                                                      WHEN 8 THEN '储值卡直充赠送撤销'
                                                      WHEN 9 THEN '储值卡退款'
                                                      WHEN 10 THEN '储值卡退款撤销'
                                                    END AS ActionModeName 
                                            FROM    [TBL_MONEY_BALANCE] T1 WITH ( NOLOCK ) 
                                                    LEFT JOIN [TBL_Customer_Card] T2 WITH ( NOLOCK ) ON T1.UserCardNo = T2.UserCardNo
                                                    LEFT JOIN [MST_Card] T3 WITH ( NOLOCK ) ON T2.CardID = T3.ID
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.CustomerBalanceID = @BalanceID ";
                #endregion

                #region 查询积分卡交易记录SQL
                string strSelPointBalance = @" SELECT  T1.CustomerBalanceID AS BalanceID ,T1.ActionMode ,2 AS CardType ,T3.CardName ,T1.UserCardNo ,T1.DepositMode,
                                                    CAST(T1.Amount AS dec(12, 2)) AS Amount ,
                                                    CAST(T1.Balance AS dec(12, 2)) AS Balance ,
                                                    CASE T1.ActionMode
                                                      WHEN 1 THEN '消费支出'
                                                      WHEN 2 THEN '消费支出撤销'
                                                      WHEN 3 THEN '消费赠送'
                                                      WHEN 4 THEN '消费赠送撤销'
                                                      WHEN 5 THEN '储值卡直充赠送'
                                                      WHEN 6 THEN '储值卡直充赠送撤销'
                                                      WHEN 7 THEN '积分直充'
                                                      WHEN 8 THEN '积分直充撤销'
                                                      WHEN 9 THEN '积分直扣'
                                                      WHEN 10 THEN '积分直扣撤销'
                                                    END AS ActionModeName 
                                            FROM    [TBL_Point_BALANCE] T1 WITH ( NOLOCK ) 
                                                    LEFT JOIN [TBL_Customer_Card] T2 WITH ( NOLOCK ) ON T1.UserCardNo = T2.UserCardNo
                                                    LEFT JOIN [MST_Card] T3 WITH ( NOLOCK ) ON T2.CardID = T3.ID
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.CustomerBalanceID = @BalanceID ";
                #endregion

                #region 查询现金券卡交易记录SQL
                string strSelCouponBalance = @" SELECT  T1.CustomerBalanceID AS BalanceID ,T1.ActionMode ,3 AS CardType ,T3.CardName ,T1.UserCardNo ,T1.DepositMode,
                                                    CAST(T1.Amount AS dec(12, 2)) AS Amount ,
                                                    CAST(T1.Balance AS dec(12, 2)) AS Balance ,
                                                    CASE T1.ActionMode
                                                      WHEN 1 THEN '消费支出'
                                                      WHEN 2 THEN '消费支出撤销'
                                                      WHEN 3 THEN '消费赠送'
                                                      WHEN 4 THEN '消费赠送撤销'
                                                      WHEN 5 THEN '储值卡直充赠送'
                                                      WHEN 6 THEN '储值卡直充赠送撤销'
                                                      WHEN 7 THEN '现金券直充'
                                                      WHEN 8 THEN '现金券直充撤销'
                                                      WHEN 9 THEN '现金券直扣'
                                                      WHEN 10 THEN '现金券直扣撤销'
                                                    END AS ActionModeName 
                                            FROM    [TBL_Coupon_BALANCE] T1 WITH ( NOLOCK ) 
                                                    LEFT JOIN [TBL_Customer_Card] T2 WITH ( NOLOCK ) ON T1.UserCardNo = T2.UserCardNo
                                                    LEFT JOIN [MST_Card] T3 WITH ( NOLOCK ) ON T2.CardID = T3.ID
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.CustomerBalanceID = @BalanceID ";
                #endregion

                string strPartSql = "";
                string strMoneyActionMode = "";
                string strPointActionMode = "";
                string strCouponActionMode = "";
                List<BalanceCardDetail_Model> CardDetailList = new List<BalanceCardDetail_Model>();

                switch (model.ChangeType)
                {
                    case 3://账户充值
                        #region 充值判断ActionMode
                        if (model.TargetAccount == 1)
                        {
                            strMoneyActionMode = " AND T1.ActionMode = 3 ";// 储值卡充值
                        }
                        else if (model.TargetAccount == 2)
                        {
                            strPointActionMode = " AND T1.ActionMode = 7 ";// 积分卡充值
                        }
                        else if (model.TargetAccount == 3)
                        {
                            strCouponActionMode = " AND T1.ActionMode = 7 ";// 现金券卡充值
                        }
                        #endregion
                        break;
                    case 5://账户直扣
                        #region 扣款判断ActionMode
                        if (model.TargetAccount == 1)
                        {
                            strMoneyActionMode = " AND (T1.ActionMode = 5 OR T1.ActionMode=9) ";// 储值卡扣款 或者等于9
                        }
                        else if (model.TargetAccount == 2)
                        {
                            strPointActionMode = " AND T1.ActionMode = 9 ";// 积分卡直扣
                        }
                        else if (model.TargetAccount == 3)
                        {
                            strCouponActionMode = " AND T1.ActionMode = 9 ";// 现金券卡直扣
                        }
                        #endregion
                        break;
                    default:
                        break;
                }

                #region 查询充值/直扣内容
                switch (model.TargetAccount) //目标账户
                {
                    case 1:// 储值卡账户
                        strPartSql = strSelMoneyBalance + strMoneyActionMode;
                        break;
                    case 2:// 积分账户
                        strPartSql = strSelPointBalance + strPointActionMode;
                        break;
                    case 3:// 现金券账户
                        strPartSql = strSelCouponBalance + strCouponActionMode;
                        break;
                    default:
                        strPartSql = "";
                        break;
                }

                if (strPartSql != "")
                {
                    CardDetailList = db.SetCommand(strPartSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                , db.Parameter("@BalanceID", balanceID, DbType.Int32)).ExecuteList<BalanceCardDetail_Model>();
                }
                #endregion

                if (CardDetailList == null || CardDetailList.Count == 0)
                {
                    db.RollbackTransaction();
                    return 2;
                }

                //ActionMode 1:消费支出、2:消费支出撤销、3:储值卡充值、4:储值卡充值撤销、5:储值卡直扣、6:储值卡直扣撤销、7:储值卡直充赠送、8:储值卡直充赠送撤销、9:储值卡退款、10:储值卡退款撤销
                //DepositMode 1:现金、2:银行卡、3:余额转入、4:其他
                string strAddMoneyBalance = @" INSERT INTO [TBL_MONEY_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CreatorID ,@CreateTime)";

                //ActionMode 1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                //DepositMode 1:充值、2:余额转入
                string strAddPointBalance = @" INSERT INTO [TBL_POINT_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CreatorID ,@CreateTime)";

                //ActionMode 1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                //DepositMode 1:充值、2:余额转入
                string strAddCouponBalance = @" INSERT INTO [TBL_COUPON_BALANCE]( CompanyID ,BranchID ,UserID ,CustomerBalanceID ,ActionMode ,DepositMode ,Remark ,UserCardNo ,Amount ,Balance ,CouponType ,CreatorID ,CreateTime) 
                    VALUES( @CompanyID ,@BranchID ,@UserID ,@CustomerBalanceID ,@ActionMode ,@DepositMode ,@Remark ,@UserCardNo ,@Amount ,@Balance ,@CouponType ,@CreatorID ,@CreateTime)";

                #region 直冲/直扣返还操作
                foreach (BalanceCardDetail_Model item in CardDetailList)
                {
                    string strSelectBalance = "SELECT Balance FROM [TBL_CUSTOMER_CARD] WHERE UserCardNo=@UserCardNo";

                    decimal oldBalance = db.SetCommand(strSelectBalance, db.Parameter("UserCardNo", item.UserCardNo, DbType.String)).ExecuteScalar<decimal>();

                    if (item.CardType == 1)
                    {
                        #region 现金
                        int actionMode = 0;
                        if (item.ActionMode == 3)
                        {
                            actionMode = 4;
                            item.Amount = Math.Abs(item.Amount) * -1;
                        }
                        else if (item.ActionMode == 5)
                        {
                            actionMode = 6;
                            item.Amount = Math.Abs(item.Amount);
                        }
                        else
                        {
                            return 2;
                        }

                        decimal newBalance = oldBalance + item.Amount;
                        if (newBalance < 0)
                        {
                            db.RollbackTransaction();
                            return 3;
                        }

                        int addres = db.SetCommand(strAddMoneyBalance,
                                db.Parameter("@CompanyID", companyID, DbType.Int32),
                                db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                                db.Parameter("@CustomerBalanceID", newBalanceID, DbType.Int32),
                                db.Parameter("@ActionMode", actionMode, DbType.Int32),//1:消费支出、2:消费支出撤销、3:储值卡充值、4:储值卡充值撤销、5:储值卡直扣、6:储值卡直扣撤销、7:储值卡直充赠送、8:储值卡直充赠送撤销、9:储值卡退款、10:储值卡退款撤销
                                db.Parameter("@DepositMode", item.DepositMode, DbType.Int32),//1:现金、2:银行卡、3:余额转入、4:其他
                                db.Parameter("@Remark", DBNull.Value, DbType.String),
                                db.Parameter("@UserCardNo", item.UserCardNo, DbType.String),
                                db.Parameter("@Amount", item.Amount, DbType.Decimal),
                                db.Parameter("@Balance", newBalance, DbType.Decimal),
                                db.Parameter("@CreatorID", updaterID, DbType.Int32),
                                db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                        if (addres <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
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
                        PushOperation_Model pushmodel = db.SetCommand(selectCustomerDevice, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
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
                                            string msg = "";
                                            if (model.ChangeType == 3)
                                            {
                                                msg = "您有一笔账户充值被撤销\n";
                                            }
                                            else if (model.ChangeType == 5)
                                            {
                                                msg = "您有一笔账户直扣被撤销\n";
                                            }

                                            HS.Framework.Common.WeChat.Entity.MessageTemplate messageModel = new HS.Framework.Common.WeChat.Entity.MessageTemplate();
                                            HS.Framework.Common.WeChat.WXCompanyInfoBase WXCompanyInfoBase = we.GetBaseInfo(companyID);
                                            messageModel.template_id = WXCompanyInfoBase.AccountChangesTemplate;
                                            messageModel.topcolor = "#000000";
                                            messageModel.touser = pushmodel.WeChatOpenID;
                                            messageModel.data = new HS.Framework.Common.WeChat.Entity.TemplateDetail()
                                            {

                                                first = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#FF0000", value = msg },
                                                keyword1 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = time.ToString("yyyy-MM-dd HH:mm") },
                                                keyword2 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = pushmodel.CardName },
                                                keyword3 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#FF0000", value = item.Amount.ToString("C2") },
                                                remark = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = "余额：" + newBalance.ToString("C2") + "\n\n您可以在账户交易明细中查看账户变动的详细内容。" }
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
                            LogUtil.Log("余额变动push失败", model.CustomerID + "数据抽取失败");
                        }
                        #endregion
                        #endregion
                    }
                    else if (item.CardType == 2)
                    {
                        #region 积分卡
                        int actionMode = 0;
                        if (item.ActionMode == 7)
                        {
                            actionMode = 8;
                            item.Amount = Math.Abs(item.Amount) * -1;
                        }
                        else if (item.ActionMode == 9)
                        {
                            actionMode = 10;
                            item.Amount = Math.Abs(item.Amount);
                        }
                        else
                        {
                            return 2;
                        }

                        decimal newBalance = oldBalance + item.Amount;
                        //if (newBalance < 0)
                        //{
                        //    db.RollbackTransaction();
                        //    return 3;
                        //}

                        int addres = db.SetCommand(strAddPointBalance,
                                db.Parameter("@CompanyID", companyID, DbType.Int32),
                                db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                                db.Parameter("@CustomerBalanceID", newBalanceID, DbType.Int32),
                                db.Parameter("@ActionMode", actionMode, DbType.Int32),//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                db.Parameter("@DepositMode", 0, DbType.Int32),//1:充值、2:余额转入
                                db.Parameter("@Remark", DBNull.Value, DbType.String),
                                db.Parameter("@UserCardNo", item.UserCardNo, DbType.String),
                                db.Parameter("@Amount", item.Amount, DbType.Decimal),
                                db.Parameter("@Balance", newBalance, DbType.Decimal),
                                db.Parameter("@CreatorID", updaterID, DbType.Int32),
                                db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                        if (addres <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion
                    }
                    else if (item.CardType == 3)
                    {
                        #region 券卡
                        int actionMode = 0;
                        if (item.ActionMode == 7)
                        {
                            actionMode = 8;
                            item.Amount = Math.Abs(item.Amount) * -1;
                        }
                        else if (item.ActionMode == 9)
                        {
                            actionMode = 10;
                            item.Amount = Math.Abs(item.Amount);
                        }
                        else
                        {
                            return 2;
                        }

                        decimal newBalance = oldBalance + item.Amount;
                        //if (newBalance < 0)
                        //{
                        //    db.RollbackTransaction();
                        //    return 3;
                        //}

                        int addres = db.SetCommand(strAddCouponBalance,
                                db.Parameter("@CompanyID", companyID, DbType.Int32),
                                db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                                db.Parameter("@CustomerBalanceID", newBalanceID, DbType.Int32),
                                db.Parameter("@ActionMode", actionMode, DbType.Int32),//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                db.Parameter("@DepositMode", 0, DbType.Int32),//1:充值、2:余额转入
                                db.Parameter("@Remark", DBNull.Value, DbType.String),
                                db.Parameter("@UserCardNo", item.UserCardNo, DbType.String),
                                db.Parameter("@Amount", item.Amount, DbType.Decimal),
                                db.Parameter("@Balance", newBalance, DbType.Decimal),
                                db.Parameter("@CouponType", 0, DbType.Int32),
                                db.Parameter("@CreatorID", updaterID, DbType.Int32),
                                db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                        if (addres <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion
                    }
                    else
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    string strAddHis = @" INSERT INTO [HST_CUSTOMER_CARD] SELECT * FROM [TBL_CUSTOMER_CARD] WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo ";
                    string strUpdateCustomerCard = @" UPDATE [TBL_CUSTOMER_CARD] SET Balance=@Balance WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo";

                    #region 修改CustomerCard中的Balance
                    int hisRows = db.SetCommand(strAddHis, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                         , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                         , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteNonQuery();

                    if (hisRows == 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    int updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", oldBalance + item.Amount, DbType.Decimal)
                                                         , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                         , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                         , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteNonQuery();
                    if (updateRes == 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    #endregion
                }
                #endregion

                #region 查询赠送内容
                List<BalanceCardDetail_Model> giveCardDetailList = new List<BalanceCardDetail_Model>();

                switch (model.ChangeType)
                {
                    case 3:// 账户直冲
                        #region 充值赠送
                        strMoneyActionMode = " AND T1.ActionMode = 7 ";// 储值卡充值赠送
                        strPointActionMode = " AND T1.ActionMode = 5 ";// 储值卡充值赠送
                        strCouponActionMode = " AND T1.ActionMode = 5 ";// 储值卡充值赠送

                        strPartSql = strSelMoneyBalance + strMoneyActionMode
                        + " UNION ALL " + strSelPointBalance + strPointActionMode
                        + " UNION ALL " + strSelCouponBalance + strCouponActionMode;
                        #endregion
                        break;
                    default:
                        strPartSql = "";
                        break;
                }

                if (strPartSql != "")
                {
                    giveCardDetailList = db.SetCommand(strPartSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                , db.Parameter("@BalanceID", balanceID, DbType.Int32)).ExecuteList<BalanceCardDetail_Model>();
                }

                if (giveCardDetailList != null && giveCardDetailList.Count > 0)
                {
                    #region 赠送返还操作
                    foreach (BalanceCardDetail_Model item in giveCardDetailList)
                    {
                        string strSelectBalance = "SELECT Balance FROM [TBL_CUSTOMER_CARD] WHERE UserCardNo=@UserCardNo";

                        decimal oldBalance = db.SetCommand(strSelectBalance, db.Parameter("UserCardNo", item.UserCardNo, DbType.String)).ExecuteScalar<decimal>();

                        if (item.CardType == 1)
                        {
                            #region 现金
                            int actionMode = 8;
                            item.Amount = Math.Abs(item.Amount) * -1;

                            decimal newBalance = oldBalance + item.Amount;
                            if (newBalance < 0)
                            {
                                db.RollbackTransaction();
                                return 3;
                            }

                            int addres = db.SetCommand(strAddMoneyBalance,
                                    db.Parameter("@CompanyID", companyID, DbType.Int32),
                                    db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                    db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                                    db.Parameter("@CustomerBalanceID", newBalanceID, DbType.Int32),
                                    db.Parameter("@ActionMode", actionMode, DbType.Int32),//1:消费支出、2:消费支出撤销、3:储值卡充值、4:储值卡充值撤销、5:储值卡直扣、6:储值卡直扣撤销、7:储值卡直充赠送、8:储值卡直充赠送撤销、9:储值卡退款、10:储值卡退款撤销
                                    db.Parameter("@DepositMode", 0, DbType.Int32),//1:现金、2:银行卡、3:余额转入、4:其他
                                    db.Parameter("@Remark", DBNull.Value, DbType.String),
                                    db.Parameter("@UserCardNo", item.UserCardNo, DbType.String),
                                    db.Parameter("@Amount", item.Amount, DbType.Decimal),
                                    db.Parameter("@Balance", newBalance, DbType.Decimal),
                                    db.Parameter("@CouponType", 0, DbType.Int32),
                                    db.Parameter("@CreatorID", updaterID, DbType.Int32),
                                    db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                            if (addres <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                            #endregion
                        }
                        else if (item.CardType == 2)
                        {
                            #region 积分卡
                            int actionMode = 6;
                            item.Amount = Math.Abs(item.Amount) * -1;
                            decimal newBalance = oldBalance + item.Amount;

                            int addres = db.SetCommand(strAddPointBalance,
                                    db.Parameter("@CompanyID", companyID, DbType.Int32),
                                    db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                    db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                                    db.Parameter("@CustomerBalanceID", newBalanceID, DbType.Int32),
                                    db.Parameter("@ActionMode", actionMode, DbType.Int32),//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                    db.Parameter("@DepositMode", 0, DbType.Int32),//1:充值、2:余额转入
                                    db.Parameter("@Remark", DBNull.Value, DbType.String),
                                    db.Parameter("@UserCardNo", item.UserCardNo, DbType.String),
                                    db.Parameter("@Amount", item.Amount, DbType.Decimal),
                                    db.Parameter("@Balance", newBalance, DbType.Decimal),
                                    db.Parameter("@CreatorID", updaterID, DbType.Int32),
                                    db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                            if (addres <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                            #endregion
                        }
                        else if (item.CardType == 3)
                        {
                            #region 券卡
                            int actionMode = 6;
                            item.Amount = Math.Abs(item.Amount) * -1;
                            decimal newBalance = oldBalance + item.Amount;

                            int addres = db.SetCommand(strAddCouponBalance,
                                    db.Parameter("@CompanyID", companyID, DbType.Int32),
                                    db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                    db.Parameter("@UserID", model.CustomerID, DbType.Int32),
                                    db.Parameter("@CustomerBalanceID", newBalanceID, DbType.Int32),
                                    db.Parameter("@ActionMode", actionMode, DbType.Int32),//1:消费支出、2:消费支出撤销、3:消费赠送、4:消费赠送撤销、5:储值卡直充赠送、6:储值卡直充赠送撤销、7:直冲、8:直冲撤销、9:直扣、10:直扣撤销
                                    db.Parameter("@DepositMode", 0, DbType.Int32),//1:充值、2:余额转入
                                    db.Parameter("@Remark", DBNull.Value, DbType.String),
                                    db.Parameter("@UserCardNo", item.UserCardNo, DbType.String),
                                    db.Parameter("@Amount", item.Amount, DbType.Decimal),
                                    db.Parameter("@Balance", newBalance, DbType.Decimal),
                                    db.Parameter("@CouponType", 0, DbType.Int32),
                                    db.Parameter("@CreatorID", updaterID, DbType.Int32),
                                    db.Parameter("@CreateTime", time, DbType.DateTime)).ExecuteNonQuery();

                            if (addres <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                            #endregion
                        }
                        else
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        string strUpdateCustomerCard = @" UPDATE [TBL_CUSTOMER_CARD] SET Balance=@Balance WHERE CompanyID=@CompanyID AND UserID=@UserID AND UserCardNo=@UserCardNo";

                        #region 修改CustomerCard中的Balance
                        int updateRes = db.SetCommand(strUpdateCustomerCard, db.Parameter("@Balance", oldBalance + item.Amount, DbType.Decimal)
                                                             , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                             , db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                             , db.Parameter("@UserCardNo", item.UserCardNo, DbType.String)).ExecuteNonQuery();
                        if (updateRes == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion
                    }
                    #endregion
                }
                #endregion

                #region 插入原来的参与人
                string strAddProfitSql = @"INSERT INTO dbo.TBL_PROFIT( MasterID ,SlaveID ,Type ,Available ,CreateTime ,CreatorID ,ProfitPct)
                        SELECT @MasterID ,SlaveID,Type,Available,@CreateTime,@CreatorID ,ProfitPct FROM TBL_PROFIT WHERE Type=1 AND Available=1 AND MasterID=@OldBalanceID";

                int addRes = db.SetCommand(strAddProfitSql, db.Parameter("@MasterID", newBalanceID, DbType.Int32)
                                                     , db.Parameter("@CreateTime", time, DbType.DateTime)
                                                     , db.Parameter("@CreatorID", updaterID, DbType.Int32)
                                                     , db.Parameter("@OldBalanceID", balanceID, DbType.Int32)).ExecuteNonQuery();


                #endregion

                #region 删除业绩分享
                string strSqlCheck = @" select Count(*) from TBL_PROFIT_COMMISSION_DETAIL  WHERE   CompanyID = @CompanyID
                                                                        AND SourceID = @SourceID
                                                                        AND SourceType = @SourceType ";
                int checkRows = db.SetCommand(strSqlCheck
                                        , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                        , db.Parameter("@SourceID", balanceID, DbType.Int32)
                                        , db.Parameter("@SourceType", 3, DbType.Int32)).ExecuteScalar<int>();

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
                                            , db.Parameter("@SourceID", balanceID, DbType.Int32)
                                            , db.Parameter("@SourceType", 3, DbType.Int32)
                                            , db.Parameter("@UpdaterID", updaterID, DbType.Int32)
                                            , db.Parameter("@UpdateTime", time, DbType.DateTime)).ExecuteNonQuery();

                    if (CardDetailList.Count > 1 || CardDetailList[0].DepositMode != 3)
                    {
                        if (rows <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                    } 
                }
                #endregion

                db.CommitTransaction();
                return 1;
            }

        }

        public int UpdateChargeProfitForWeb(int companyID, int balanceID, int updaterID, List<Slave_Model> ProfitList)
        {
            DateTime time = DateTime.Now.ToLocalTime();
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                #region 业绩分享人

                string strSql = @" INSERT INTO TBL_HISTORY_PROFIT SELECT * FROM dbo.TBL_PROFIT WHERE MasterID =@MasterID AND Type = 1 ";

                int val = db.SetCommand(strSql, db.Parameter("@MasterID", balanceID, DbType.Int32)).ExecuteNonQuery();

                if (val < 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                strSql = @"delete  dbo.TBL_PROFIT
                               WHERE   MasterID = @MasterID
                                       AND Type = 1";

                val = db.SetCommand(strSql, db.Parameter("@MasterID", balanceID, DbType.Int32)).ExecuteNonQuery();

                if (val < 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                string strSelMoneyBalanceSql = " SELECT  Amount,UserCardNo,DepositMode,BranchID FROM TBL_MONEY_BALANCE WHERE CustomerBalanceID=@BalanceID ";
                DataTable dt = db.SetCommand(strSelMoneyBalanceSql, db.Parameter("@BalanceID", balanceID, DbType.Int32)).ExecuteDataTable();

                if (dt != null && dt.Rows.Count == 1)
                {
                    decimal amount = StringUtils.GetDbDecimal(dt.Rows[0]["Amount"]);
                    string userCardNo = StringUtils.GetDbString(dt.Rows[0]["userCardNo"]);
                    int depositMode = StringUtils.GetDbInt(dt.Rows[0]["DepositMode"]);
                    int branchID = StringUtils.GetDbInt(dt.Rows[0]["BranchID"]);

                    if (depositMode == 1 || depositMode == 2 || depositMode == 4 || depositMode == 5)
                    {
                        #region 删除业绩分享
                        string strUpdateComissionCalcsQL = @" UPDATE  TBL_PROFIT_COMMISSION_DETAIL
                                                                SET     RecordType = @RecordType,UpdaterID = @UpdaterID ,UpdateTime = @UpdateTime 
                                                                WHERE   CompanyID = @CompanyID
                                                                        AND SourceID = @SourceID
                                                                        AND SourceType = @SourceType ";
                        int rows = db.SetCommand(strUpdateComissionCalcsQL
                                                , db.Parameter("@RecordType", 2, DbType.Int32)
                                                , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                , db.Parameter("@SourceID", balanceID, DbType.Int32)
                                                , db.Parameter("@SourceType", 3, DbType.Int32)
                                                , db.Parameter("@UpdaterID", updaterID, DbType.Int32)
                                                , db.Parameter("@UpdateTime", time, DbType.DateTime)).ExecuteNonQuery();

                        if (rows <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        string strSelCompanyComissionCalcSql = " SELECT [ComissionCalc] FROM COMPANY WHERE ID=@CompanyID ";
                        bool isComissionCalc = db.SetCommand(strSelCompanyComissionCalcSql
                                             , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalar<bool>();
                        if (isComissionCalc)
                        {
                            #region 查询卡的业绩RULE
                            string strSelEcardCommissionRuleSql = @"   SELECT T1.ProfitPct ,
                                                                            T1.ProfitPct ,
                                                                            T1.FstChargeCommType ,
                                                                            T1.FstChargeCommValue ,
                                                                            T1.ChargeCommType ,
                                                                            T1.ChargeCommValue ,
                                                                            T1.CardCode 
                                                                     FROM   [TBL_ECARD_COMMISSION_RULE] T1 WITH(NOLOCK)
                                                                             INNER JOIN [MST_CARD] T2 WITH(NOLOCK) ON T1.CardCode=T2.CardCode AND T2.Available = 1
                                                                             INNER JOIN [TBL_CUSTOMER_CARD] T3 WITH(NOLOCK) ON T3.CardID=T2.ID
                                                                     WHERE  T1.CompanyID = @CompanyID
                                                                            AND T3.UserCardNo = @UserCardNo 
                                                                            AND T1.RecordType=1 ";

                            Ecard_Commission_Rule_Model EcardRuleModel = db.SetCommand(strSelEcardCommissionRuleSql
                                                                       , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                                                       , db.Parameter("@UserCardNo", userCardNo, DbType.Int64)).ExecuteObject<Ecard_Commission_Rule_Model>();

                            #endregion

                            if (EcardRuleModel != null && EcardRuleModel.CardCode > 0)
                            {
                                #region 计算首冲还是续费
                                int ChargeCommType = EcardRuleModel.ChargeCommType;//1:按比例 2:固定值
                                decimal ChargeCommValue = EcardRuleModel.ChargeCommValue;

                                decimal Profit = amount * EcardRuleModel.ProfitPct;
                                object CommFlag = DBNull.Value;//1：首充 2：指定
                                #endregion

                                #region 插入业绩详细表
                                string strAddProfitDetailSql = @" INSERT INTO TBL_PROFIT_COMMISSION_DETAIL ( CompanyID ,BranchID ,SourceType ,SourceID ,Income ,ProfitPct ,Profit ,CommType ,CommValue ,AccountID ,AccountProfitPct ,AccountProfit ,AccountComm ,CommFlag ,CreatorID ,CreateTime ) 
                                                                    VALUES ( @CompanyID ,@BranchID ,@SourceType ,@SourceID ,@Income ,@ProfitPct ,@Profit ,@CommType ,@CommValue ,@AccountID ,@AccountProfitPct ,@AccountProfit ,@AccountComm ,@CommFlag ,@CreatorID ,@CreateTime ) ";

                                if (ProfitList != null && ProfitList.Count > 0)
                                {
                                    foreach (Slave_Model item in ProfitList)
                                    {
                                        #region 有业绩分享人
                                        decimal AccountProfit = Profit * item.ProfitPct;//员工业绩(=实际业绩 x 员工业绩计算比例)
                                        decimal AccountComm = ChargeCommValue;
                                        if (ChargeCommType == 1)//1:按比例 2:固定值
                                        {
                                            AccountComm = AccountProfit * ChargeCommValue;
                                        }

                                        int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                            , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                            , db.Parameter("@BranchID", branchID, DbType.Int32)
                                            , db.Parameter("@SourceType", 3, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                            , db.Parameter("@SourceID", balanceID, DbType.Int64)
                                            , db.Parameter("@Income", amount, DbType.Decimal)//收入 充值时，为TBL_MONEY_BALANCE的Amount
                                            , db.Parameter("@ProfitPct", EcardRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                            , db.Parameter("@Profit", Profit, DbType.Decimal)//实际业绩
                                            , db.Parameter("@CommType", ChargeCommType, DbType.Int32)//该业绩的提成方式
                                            , db.Parameter("@CommValue", ChargeCommValue, DbType.Decimal)//该业绩的提成数值
                                            , db.Parameter("@AccountID", item.SlaveID, DbType.Int32)//获得该业绩的员工ID
                                            , db.Parameter("@AccountProfitPct", item.ProfitPct, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                            , db.Parameter("@AccountProfit", AccountProfit, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                            , db.Parameter("@AccountComm", AccountComm, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
                                            , db.Parameter("@CommFlag", CommFlag, DbType.Int32)//1：首充 2：指定
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
                                else
                                {
                                    #region 没有业绩分享人
                                    int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                            , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                            , db.Parameter("@BranchID", branchID, DbType.Int32)
                                            , db.Parameter("@SourceType", 3, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                            , db.Parameter("@SourceID", balanceID, DbType.Int64)
                                            , db.Parameter("@Income", amount, DbType.Decimal)//收入 充值时，为TBL_MONEY_BALANCE的Amount
                                            , db.Parameter("@ProfitPct", EcardRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                            , db.Parameter("@Profit", Profit, DbType.Decimal)//实际业绩
                                            , db.Parameter("@CommType", ChargeCommType, DbType.Int32)//该业绩的提成方式
                                            , db.Parameter("@CommValue", ChargeCommValue, DbType.Decimal)//该业绩的提成数值
                                            , db.Parameter("@AccountID", DBNull.Value, DbType.Int32)//获得该业绩的员工ID
                                            , db.Parameter("@AccountProfitPct", DBNull.Value, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                            , db.Parameter("@AccountProfit", DBNull.Value, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                            , db.Parameter("@AccountComm", DBNull.Value, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
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
                        }
                    }
                }

                foreach (Slave_Model item in ProfitList)
                {
                    string strAddProfitSql = @" INSERT	INTO TBL_PROFIT( MasterID ,SlaveID ,Type ,Available ,CreateTime ,CreatorID,ProfitPct) 
                                                VALUES (@MasterID ,@SlaveID ,@Type ,@Available ,@CreateTime ,@CreatorID,@ProfitPct)";
                    int addProfitres = db.SetCommand(strAddProfitSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                            , db.Parameter("@MasterID", balanceID, DbType.Int64)
                            , db.Parameter("@SlaveID", item.SlaveID, DbType.Int64)
                            , db.Parameter("@Type", 1, DbType.Int32)
                            , db.Parameter("@Available", true, DbType.Boolean)
                            , db.Parameter("@CreateTime", time, DbType.DateTime2)
                            , db.Parameter("@CreatorID", updaterID, DbType.Int32)
                            , db.Parameter("@ProfitPct", item.ProfitPct, DbType.Decimal)).ExecuteNonQuery();

                    if (addProfitres <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                }
                #endregion
                db.CommitTransaction();
                return 1;
            }
        }


        public bool EdtiBalanceProfit(BalanceForWebOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();

                    string strSql = @" INSERT INTO TBL_HISTORY_PROFIT SELECT * FROM dbo.TBL_PROFIT WHERE MasterID =@MasterID AND Type = 1 ";

                    int val = db.SetCommand(strSql, db.Parameter("@MasterID", model.BalanceID, DbType.Int32)).ExecuteNonQuery();

                    if (val < 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    strSql = @"delete  dbo.TBL_PROFIT
                               WHERE   MasterID = @MasterID
                                       AND Type = 1";

                    val = db.SetCommand(strSql, db.Parameter("@MasterID", model.BalanceID, DbType.Int32)).ExecuteNonQuery();

                    if (val < 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    string strSelMoneyBalanceSql = " SELECT  Amount,UserCardNo,DepositMode,BranchID,ActionMode FROM TBL_MONEY_BALANCE WHERE CompanyID=@CompanyID AND CustomerBalanceID=@BalanceID AND ( ActionMode = 3 OR ActionMode = 5 ) ";
                    DataTable dt = db.SetCommand(strSelMoneyBalanceSql
                        , db.Parameter("@BalanceID", model.BalanceID, DbType.Int32)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteDataTable();

                    if (dt != null && dt.Rows.Count == 1)
                    {
                        decimal amount = StringUtils.GetDbDecimal(dt.Rows[0]["Amount"]);
                        string userCardNo = StringUtils.GetDbString(dt.Rows[0]["userCardNo"]);
                        int depositMode = StringUtils.GetDbInt(dt.Rows[0]["DepositMode"]);
                        int branchID = StringUtils.GetDbInt(dt.Rows[0]["BranchID"]);
                        int actionMode = StringUtils.GetDbInt(dt.Rows[0]["ActionMode"]);

                        if (depositMode == 1 || depositMode == 2 || depositMode == 4 || depositMode == 5 || (actionMode == 5 && depositMode == 0))
                        {
                            object CommFlag = DBNull.Value;//1：首充 2：指定

                            #region 删除业绩分享
                            string strSqlCheck = @" select Count(*) from TBL_PROFIT_COMMISSION_DETAIL  WHERE   CompanyID = @CompanyID
                                                                        AND SourceID = @SourceID
                                                                        AND SourceType = @SourceType ";
                            int checkRows = db.SetCommand(strSqlCheck
                                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                    , db.Parameter("@SourceID", model.BalanceID, DbType.Int32)
                                                    , db.Parameter("@SourceType", 3, DbType.Int32)).ExecuteScalar<int>();

                            if (checkRows > 0)
                            {
                                string strSelCommflagSql = @" SELECT CommFlag FROM TBL_PROFIT_COMMISSION_DETAIL 
                                                                 WHERE CompanyID=@CompanyID 
                                                                AND SourceID=@SourceID 
                                                                AND SourceType=@SourceType 
                                                                AND CommFlag IS NOT NULL ";
                                int selCommflag = db.SetCommand(strSelCommflagSql
                                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                    , db.Parameter("@SourceID", model.BalanceID, DbType.Int32)
                                                    , db.Parameter("@SourceType", 3, DbType.Int32)).ExecuteScalar<int>();
                                if (selCommflag == 1)
                                {
                                    CommFlag = 1;
                                }

                                string strUpdateComissionCalcsQL = @" UPDATE  TBL_PROFIT_COMMISSION_DETAIL
                                                                SET     RecordType = @RecordType,UpdaterID = @UpdaterID ,UpdateTime = @UpdateTime 
                                                                WHERE   CompanyID = @CompanyID
                                                                        AND SourceID = @SourceID
                                                                        AND SourceType = @SourceType ";
                                int rows = db.SetCommand(strUpdateComissionCalcsQL
                                                        , db.Parameter("@RecordType", 2, DbType.Int32)
                                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                        , db.Parameter("@SourceID", model.BalanceID, DbType.Int32)
                                                        , db.Parameter("@SourceType", 3, DbType.Int32)
                                                        , db.Parameter("@UpdaterID", model.CreateID, DbType.Int32)
                                                        , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                                if (rows != checkRows)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }
                            }
                            #endregion

                            string strSelCompanyComissionCalcSql = " SELECT [ComissionCalc] FROM COMPANY WHERE ID=@CompanyID ";
                            bool isComissionCalc = db.SetCommand(strSelCompanyComissionCalcSql
                                                 , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<bool>();
                            if (isComissionCalc)
                            {
                                #region 查询卡的业绩RULE
                                string strSelEcardCommissionRuleSql = @"   SELECT T1.ProfitPct ,
                                                                            T1.ProfitPct ,
                                                                            T1.FstChargeCommType ,
                                                                            T1.FstChargeCommValue ,
                                                                            T1.ChargeCommType ,
                                                                            T1.ChargeCommValue ,
                                                                            T1.CardCode 
                                                                     FROM   [TBL_ECARD_COMMISSION_RULE] T1 WITH(NOLOCK)
                                                                             INNER JOIN [MST_CARD] T2 WITH(NOLOCK) ON T1.CardCode=T2.CardCode AND T2.Available = 1
                                                                             INNER JOIN [TBL_CUSTOMER_CARD] T3 WITH(NOLOCK) ON T3.CardID=T2.ID
                                                                     WHERE  T1.CompanyID = @CompanyID
                                                                            AND T3.UserCardNo = @UserCardNo 
                                                                            AND T1.RecordType=1 ";

                                Ecard_Commission_Rule_Model EcardRuleModel = db.SetCommand(strSelEcardCommissionRuleSql
                                                                           , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                           , db.Parameter("@UserCardNo", userCardNo, DbType.Int64)).ExecuteObject<Ecard_Commission_Rule_Model>();

                                #endregion

                                if (EcardRuleModel != null && EcardRuleModel.CardCode > 0)
                                {
                                    #region 计算首冲还是续费
                                    int ChargeCommType = CommFlag != DBNull.Value ? EcardRuleModel.FstChargeCommType : EcardRuleModel.ChargeCommType;//1:按比例 2:固定值
                                    decimal ChargeCommValue = CommFlag != DBNull.Value ? EcardRuleModel.FstChargeCommValue : EcardRuleModel.ChargeCommValue;
                                    decimal Profit = amount * EcardRuleModel.ProfitPct;

                                    #endregion

                                    #region 插入业绩详细表
                                    string strAddProfitDetailSql = @" INSERT INTO TBL_PROFIT_COMMISSION_DETAIL ( CompanyID ,BranchID ,SourceType ,SourceID ,SubSourceID ,Income ,ProfitPct ,Profit ,CommType ,CommValue ,AccountID ,AccountProfitPct ,AccountProfit ,AccountComm ,CommFlag ,CreatorID ,CreateTime ) 
                                                                    VALUES ( @CompanyID ,@BranchID ,@SourceType ,@SourceID ,@SubSourceID ,@Income ,@ProfitPct ,@Profit ,@CommType ,@CommValue ,@AccountID ,@AccountProfitPct ,@AccountProfit ,@AccountComm ,@CommFlag ,@CreatorID ,@CreateTime ) ";

                                    if (model.ProfitList != null && model.ProfitList.Count > 0)
                                    {
                                        foreach (Slave_Model item in model.ProfitList)
                                        {
                                            #region 有业绩分享人
                                            decimal AccountProfit = Profit * item.ProfitPct;//员工业绩(=实际业绩 x 员工业绩计算比例)
                                            decimal AccountComm = ChargeCommValue * item.ProfitPct;
                                            if (ChargeCommType == 1)//1:按比例 2:固定值
                                            {
                                                AccountComm = AccountProfit * ChargeCommValue;
                                            }
                                            else if (ChargeCommType == 2 && actionMode == 5 && depositMode == 0)
                                            {
                                                AccountComm = AccountComm * -1;
                                            }

                                            int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                , db.Parameter("@BranchID", branchID, DbType.Int32)
                                                , db.Parameter("@SourceType", 3, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                                , db.Parameter("@SourceID", model.BalanceID, DbType.Int64)
                                                , db.Parameter("@SubSourceID", EcardRuleModel.CardCode, DbType.Int64)
                                                , db.Parameter("@Income", amount, DbType.Decimal)//收入 充值时，为TBL_MONEY_BALANCE的Amount
                                                , db.Parameter("@ProfitPct", EcardRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                                , db.Parameter("@Profit", Profit, DbType.Decimal)//实际业绩
                                                , db.Parameter("@CommType", ChargeCommType, DbType.Int32)//该业绩的提成方式
                                                , db.Parameter("@CommValue", ChargeCommValue, DbType.Decimal)//该业绩的提成数值
                                                , db.Parameter("@AccountID", item.SlaveID, DbType.Int32)//获得该业绩的员工ID
                                                , db.Parameter("@AccountProfitPct", item.ProfitPct, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                                , db.Parameter("@AccountProfit", AccountProfit, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                                , db.Parameter("@AccountComm", AccountComm, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
                                                , db.Parameter("@CommFlag", CommFlag, DbType.Int32)//1：首充 2：指定
                                                , db.Parameter("@CreatorID", model.CreateID, DbType.Int32)
                                                , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                                            if (addProfitDetailRes != 1)
                                            {
                                                db.RollbackTransaction();
                                                return false;
                                            }
                                            #endregion
                                        }
                                    }
                                    else
                                    {
                                        #region 没有业绩分享人
                                        int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                , db.Parameter("@BranchID", branchID, DbType.Int32)
                                                , db.Parameter("@SourceType", 3, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                                , db.Parameter("@SourceID", model.BalanceID, DbType.Int64)
                                                , db.Parameter("@SubSourceID", EcardRuleModel.CardCode, DbType.Int64)
                                                , db.Parameter("@Income", amount, DbType.Decimal)//收入 充值时，为TBL_MONEY_BALANCE的Amount
                                                , db.Parameter("@ProfitPct", EcardRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                                , db.Parameter("@Profit", Profit, DbType.Decimal)//实际业绩
                                                , db.Parameter("@CommType", ChargeCommType, DbType.Int32)//该业绩的提成方式
                                                , db.Parameter("@CommValue", ChargeCommValue, DbType.Decimal)//该业绩的提成数值
                                                , db.Parameter("@AccountID", DBNull.Value, DbType.Int32)//获得该业绩的员工ID
                                                , db.Parameter("@AccountProfitPct", DBNull.Value, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                                , db.Parameter("@AccountProfit", DBNull.Value, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                                , db.Parameter("@AccountComm", DBNull.Value, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
                                                , db.Parameter("@CommFlag", CommFlag, DbType.Int32)//1：首充 2：指定 3：E账户
                                                , db.Parameter("@CreatorID", model.CreateID, DbType.Int32)
                                                , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                                        if (addProfitDetailRes != 1)
                                        {
                                            db.RollbackTransaction();
                                            return false;
                                        }
                                        #endregion
                                    }
                                    #endregion
                                }
                            }
                        }
                    }

                    if (model.ProfitList != null && model.ProfitList.Count > 0)
                    {
                        foreach (Slave_Model item in model.ProfitList)
                        {
                            string strAddProfitSql = @" INSERT	INTO TBL_PROFIT( MasterID ,SlaveID ,Type ,Available ,CreateTime ,CreatorID,ProfitPct) 
                                                VALUES (@MasterID ,@SlaveID ,@Type ,@Available ,@CreateTime ,@CreatorID,@ProfitPct)";
                            int addProfitres = db.SetCommand(strAddProfitSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@MasterID", model.BalanceID, DbType.Int64)
                                    , db.Parameter("@SlaveID", item.SlaveID, DbType.Int64)
                                    , db.Parameter("@Type", 1, DbType.Int32)
                                    , db.Parameter("@Available", true, DbType.Boolean)
                                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                                    , db.Parameter("@CreatorID", model.CreateID, DbType.Int32)
                                    , db.Parameter("@ProfitPct", item.ProfitPct, DbType.Decimal)).ExecuteNonQuery();

                            if (addProfitres <= 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }
                    }
                    db.CommitTransaction();
                    return true;

                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }
        #endregion
    }
}
