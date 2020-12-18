﻿using BLToolkit.Data;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL.Customer
{
    public class ECard_CDAL
    {
        #region 构造类实例
        public static ECard_CDAL Instance
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
            internal static readonly ECard_CDAL instance = new ECard_CDAL();
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
                                        END AS ChangeTypeName 
                                FROM    [TBL_CUSTOMER_BALANCE]
                                WHERE   CompanyID = @CompanyID
                                        AND BranchID = @BranchID
                                        AND UserID = @CustomerID
                               ORDER BY CreateTime DESC ";
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
                                      WHEN 9 THEN 1
                                      WHEN 10 THEN 0
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
                                                    CAST(T1.Amount AS dec(12, 2)) AS CardPaidAmount 
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
                                                    END AS CardPaidAmount 
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
                                                    END AS CardPaidAmount  
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
                    BalanceModel.ActionModeName = CardDetailList[0].ActionModeName;
                    BalanceModel.ActionMode = CardDetailList[0].ActionMode;
                    BalanceModel.BalanceCardList = CardDetailList;
                    foreach (BalanceCardDetail_Model item in CardDetailList)
                    {
                        model.Amount += item.CardPaidAmount;
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

                        strPartSql =  strSelPointBalance + strPointActionMode
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

                if (model.Amount <= 0 && model.PaymentID > 0)
                {
                    if (model.PaymentID > 0)
                    {
                        string strSelPaymentAmountSql = "SELECT TotalPrice FROM  [PAYMENT] WHERE ID=@PaymentID";
                        model.Amount = db.SetCommand(strSelPaymentAmountSql, db.Parameter("@PaymentID", model.PaymentID, DbType.Int32)).ExecuteScalar<decimal>();
                    }
                }

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

                list = db.SetCommand(strSql
                            , db.Parameter("@CompanyID", companyID, DbType.Int32)
                            , db.Parameter("@Customer", customerID, DbType.Int32)
                            , db.Parameter("@BranchID", branchID, DbType.Int32)
                            , db.Parameter("@ProductCode", productCode, DbType.Int64)).ExecuteList<CustomerEcardDiscount_Model>();

                return list;
            }
        }
    }
}
