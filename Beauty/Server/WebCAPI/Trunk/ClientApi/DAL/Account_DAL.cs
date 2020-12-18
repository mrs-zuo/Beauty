using BLToolkit.Data;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.DAL
{
    public class Account_DAL
    {
        #region 构造类实例
        public static Account_DAL Instance
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
            internal static readonly Account_DAL instance = new Account_DAL();
        }
        #endregion

        public List<AccountList_Model> getAccountListForCustomer(int companyId, int branchId, int customerId, int flag, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                StringBuilder strSql = new StringBuilder();
                strSql.Append(" select T1.UserID AccountID,T1.Name AccountName, T1.Code AccountCode, T1.Department, T1.Title, T1.Expert, ");
                strSql.Append(WebAPI.Common.Const.strHttp);
                strSql.Append(WebAPI.Common.Const.server);
                strSql.Append(WebAPI.Common.Const.strMothod);
                strSql.Append(WebAPI.Common.Const.strSingleMark);
                strSql.Append("  + cast(T1.CompanyID as nvarchar(10)) + ");
                strSql.Append(WebAPI.Common.Const.strSingleMark);
                strSql.Append("/");
                strSql.Append(WebAPI.Common.Const.strImageObjectType1);
                strSql.Append(WebAPI.Common.Const.strSingleMark);
                strSql.Append("  + cast(T1.UserID as nvarchar(10))+ '/' + T1.HeadImageFile + ");
                strSql.Append(WebAPI.Common.Const.strThumb);
                strSql.Append(" HeadImageURL  ");
                strSql.Append(" from ACCOUNT T1 ");
                strSql.Append(" INNER JOIN TBL_ACCOUNTBRANCH_RELATIONSHIP T2 on T1.UserID = T2.UserID AND T2.Available = 1 AND T2.VisibleForCustomer = 1 ");
                strSql.Append(" LEFT JOIN [TBL_ACCOUNTSORT] T3 ON T2.BranchID = T3.BranchID AND T2.UserID = T3.UserID ");
                // strSql.Append(" LEFT JOIN dbo.MESSAGE T3 ON T3.ToUserID = T1.UserID LEFT JOIN dbo.MESSAGE T4 ON T4.FromUserID = T1.UserID ");

                if (flag == 2)
                {
                    strSql.Append(" WHERE  T2.BranchID = @BranchID and T1.CompanyID = @CompanyID  ");
                }
                else
                {
                    strSql.Append(@" WHERE  (T2.BranchID IN (SELECT BranchID FROM dbo.RELATIONSHIP WHERE CustomerID =@CustomerID AND Available = 1)) 
                                          AND T1.CompanyID = @CompanyID ");
                }
                strSql.Append(" AND T1.Available = 1 ");
                strSql.Append(" ORDER BY ISNULL(T3.SortID,10000) ");

                List<AccountList_Model> list = db.SetCommand(strSql.ToString(), db.Parameter("@CompanyID", companyId, DbType.Int32)
                           , db.Parameter("@CustomerID", customerId, DbType.Int32)
                           , db.Parameter("@BranchID", branchId, DbType.Int32)
                           , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                           , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<AccountList_Model>();
                return list;
            }

        }

        public List<ScheduleInAccount> getScheduleListByAccount(int accountID, int branchID, DateTime? date, int CompanyID)
        {
            List<ScheduleInAccount> list = new List<ScheduleInAccount>();
            using (DbManager db = new DbManager())
            {
                //                string strSql = @"SELECT  DATEDIFF(MINUTE, '00:00:00', CONVERT(VARCHAR, T4.ScheduleTime, 108)) AS ScheduleTime ,
                //                                            ISNULL(T5.SpendTime, T6.SpendTime) AS SpendTime ,
                //                                            T6.SubServiceName
                //                                    FROM    [TREATMENT] T1 WITH ( NOLOCK )
                //                                            INNER JOIN [COURSE] T2 WITH ( NOLOCK ) ON T2.ID = T1.CourseID
                //                                            INNER JOIN [Order] T3 WITH ( NOLOCK ) ON T3.ID = T2.OrderID
                //                                            INNER JOIN [SCHEDULE] T4 WITH ( NOLOCK ) ON T4.ID = T1.ScheduleID
                //                                            INNER JOIN [SERVICE] T5 WITH ( NOLOCK ) ON T5.ID = T4.ServiceID
                //                                            LEFT JOIN [TBL_SubService] T6 WITH ( NOLOCK ) ON T6.ID = T4.SubServiceID
                //                                    WHERE   T1.Available = 1
                //                                            AND T2.Available = 1
                //                                            AND T3.Status != 2
                //                                            AND T4.Type = 0
                //                                            AND T1.ExecutorID = @AccountID
                //                                            AND T3.BranchID = @BranchID
                //                                            AND CONVERT(VARCHAR, T4.ScheduleTime, 20) LIKE @Date + '%'";
                string strSql = @"SELECT  ScdlStartTime ,
                                ScdlEndTime        
                        FROM    dbo.TBL_SCHEDULE
                        WHERE   ScheduleType = 1
		                        AND ScheduleStatus=2
                                AND CompanyID = @CompanyID
                                AND BranchID = @BranchID
                                AND UserID = @AccountID
                                AND datediff(day,ScdlStartTime,@Date)=0";

                list = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                                      , db.Parameter("@BranchID", branchID, DbType.Int32)
                                                      , db.Parameter("@AccountID", accountID, DbType.String)
                                                      , db.Parameter("@Date", date, DbType.DateTime)).ExecuteList<ScheduleInAccount>();

                return list;
            }
        }

        public List<AccountList_Model> getAccountListByCompanyID(int companyID, int branchID, List<int> TagIDs, int imageWidth, int imageHeight)
        {
            List<AccountList_Model> list = new List<AccountList_Model>();
            using (DbManager db = new DbManager())
            {
                StringBuilder strSql = new StringBuilder();
                strSql.Append(" SELECT T1.UserID AccountID,T1.Name AccountName, T1.Code AccountCode, T1.Department, T1.Title, T1.Expert, ");
                strSql.Append(WebAPI.Common.Const.strHttp);
                strSql.Append(WebAPI.Common.Const.server);
                strSql.Append(WebAPI.Common.Const.strMothod);
                strSql.Append(WebAPI.Common.Const.strSingleMark);
                strSql.Append("  + cast(T1.CompanyID as nvarchar(10)) + ");
                strSql.Append(WebAPI.Common.Const.strSingleMark);
                strSql.Append("/");
                strSql.Append(WebAPI.Common.Const.strImageObjectType1);
                strSql.Append(WebAPI.Common.Const.strSingleMark);
                strSql.Append("  + cast(T1.UserID as nvarchar(10))+ '/' + T1.HeadImageFile + ");
                strSql.Append(WebAPI.Common.Const.strThumb);
                strSql.Append(" HeadImageURL  ");
                strSql.Append(" FROM ACCOUNT T1 ");
                strSql.Append(" LEFT JOIN [TBL_ACCOUNTBRANCH_RELATIONSHIP] T2 ON T1.UserID=T2.UserID ");
                strSql.Append(" {0} ");
                strSql.Append(" WHERE T1.Available = 1");
                strSql.Append(" And T1.CompanyID = @CompanyID ");
                strSql.Append(" AND T2.BranchID = @BranchID ");
                strSql.Append(" AND T2.Available=1 ");

                strSql.Append(" ORDER BY T1.Name");

                string mainSql = strSql.ToString();
                string strTagSql = "";

                if (TagIDs != null && TagIDs.Count > 0)
                {
                    strTagSql += " INNER JOIN ( SELECT T3.UserID FROM   dbo.TBL_USER_TAGS T3 WHERE  T3.UserType = 1 AND T3.CompanyID = @CompanyID  AND T3.TagID in(";
                    strSql.Append("");
                    for (int i = 0; i < TagIDs.Count; i++)
                    {
                        if (i == 0)
                        {
                            strTagSql += TagIDs[i].ToString();
                        }
                        else
                        {
                            strTagSql += "," + TagIDs[i].ToString();
                        }
                    }
                    strTagSql += ") ";

                    strTagSql += " GROUP BY T3.UserID HAVING COUNT(T3.UserID) = @Count) T4 ON T4.UserID = T1.UserID ";
                }

                mainSql = string.Format(mainSql, strTagSql);

                list = db.SetCommand(mainSql, db.Parameter("CompanyID", companyID, DbType.Int32)
                                                      , db.Parameter("BranchID", branchID, DbType.String)
                                                      , db.Parameter("@Count", TagIDs.Count, DbType.Int32)
                                                      , db.Parameter("ImageHeight", imageHeight, DbType.String)
                                                      , db.Parameter("ImageWidth", imageWidth, DbType.String)).ExecuteList<AccountList_Model>();


                return list;
            }
        }

        /// <summary>
        /// 获取美容师详细信息
        /// </summary>
        /// <param name="customerId"></param>
        /// <returns></returns>
        public AccountDetail_Model getAccountDetail(int accountId, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                StringBuilder strSql = new StringBuilder();
                strSql.Append(" select  T1.Name, T1.Department, T1.Title ,T1.Code, T1.Introduction ,T1.Expert, T1.Mobile, CASE T1.RoleID WHEN - 1 THEN 1 ELSE CASE WHEN charindex('|15|' , T2.Jurisdictions) > 0 THEN 1 ELSE 0 END END Chat_Use ,");
                strSql.Append(WebAPI.Common.Const.strHttp);
                strSql.Append(WebAPI.Common.Const.server);
                strSql.Append(WebAPI.Common.Const.strMothod);
                strSql.Append(WebAPI.Common.Const.strSingleMark);
                strSql.Append("  + cast(T1.CompanyID as nvarchar(10)) + ");
                strSql.Append(WebAPI.Common.Const.strSingleMark);
                strSql.Append("/");
                strSql.Append(WebAPI.Common.Const.strImageObjectType1);
                strSql.Append(WebAPI.Common.Const.strSingleMark);
                strSql.Append("  + cast(T1.UserID as nvarchar(10))+ '/' + T1.HeadImageFile + ");
                strSql.Append(WebAPI.Common.Const.strThumb);
                strSql.Append(" HeadImageURL ");
                strSql.Append(" from ACCOUNT T1 LEFT JOIN [TBL_ROLE] T2 ON T1.RoleID = T2.ID ");

                strSql.Append(" WHERE T1.UserID = @AccountID");

                AccountDetail_Model model = db.SetCommand(strSql.ToString(), db.Parameter("@AccountID", accountId, DbType.Int32)
                    , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                    , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteObject<AccountDetail_Model>();

                return model;
            }

        }

        public int isFavoriteExist(int CompanyID, int branchID, int AccountID, long Code, int ProductType)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT [ID] FROM [TBL_FAVORITE] WHERE AccountID=@AccountID AND CompanyID=@CompanyID AND BranchID=@BranchID AND Code=@Code AND ProductType=@ProductType";
                int rs = db.SetCommand(strSql, db.Parameter("@AccountID", AccountID, DbType.Int32),
                                db.Parameter("@CompanyID", CompanyID, DbType.Int32),
                                db.Parameter("@BranchID", branchID, DbType.Int32),
                                db.Parameter("@Code", Code, DbType.Int64),
                                db.Parameter("@ProductType", ProductType, DbType.Int32)).ExecuteScalar<int>();
                return rs;
            }
        }

        /// <summary>
        /// 获取Account列表
        /// </summary>
        /// <param name="CompanyID"></param>
        /// <param name="BranchID"></param>
        /// <returns></returns>
        public List<AccountList_Model> getAccountList_new(int CompanyID, int accountID, int BranchID, List<int> TagIDs, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                StringBuilder strSql = new StringBuilder();
                if (accountID <= 0)
                {
                    strSql.Append(" select T1.UserID AccountID,T1.Name AccountName, T1.Code AccountCode, T1.Department, T1.Title, T1.Expert, ");
                    strSql.Append(WebAPI.Common.Const.strHttp);
                    strSql.Append(WebAPI.Common.Const.server);
                    strSql.Append(WebAPI.Common.Const.strMothod);
                    strSql.Append(WebAPI.Common.Const.strSingleMark);
                    strSql.Append("  + cast(T1.CompanyID as nvarchar(10)) + ");
                    strSql.Append(WebAPI.Common.Const.strSingleMark);
                    strSql.Append("/");
                    strSql.Append(WebAPI.Common.Const.strImageObjectType1);
                    strSql.Append(WebAPI.Common.Const.strSingleMark);
                    strSql.Append("  + cast(T1.UserID as nvarchar(10))+ '/' + T1.HeadImageFile + ");
                    strSql.Append(WebAPI.Common.Const.strThumb);
                    strSql.Append(" HeadImageURL  ");
                    strSql.Append(" from ACCOUNT T1 ");
                    strSql.Append(" LEFT JOIN TBL_ACCOUNTBRANCH_RELATIONSHIP T2 ON T2.UserID = T1.UserID AND T2.Available = 1 ");
                    strSql.Append(" {0} ");
                    strSql.Append(" where T1.Available = 1");
                    strSql.Append(" And  T1.CompanyID = @CompanyID ");
                    strSql.Append(" AND T2.BranchID = @BranchID ");

                    strSql.Append(" order by T1.Code,T1.Name");
                    string mainSql = strSql.ToString();
                    string strTagSql = "";

                    if (TagIDs != null && TagIDs.Count > 0)
                    {
                        strTagSql += " INNER JOIN ( SELECT T3.UserID FROM   dbo.TBL_USER_TAGS T3 WHERE  T3.UserType = 1 AND T3.CompanyID = @CompanyID  AND T3.TagID in(";
                        strSql.Append("");
                        for (int i = 0; i < TagIDs.Count; i++)
                        {
                            if (i == 0)
                            {
                                strTagSql += TagIDs[i].ToString();
                            }
                            else
                            {
                                strTagSql += "," + TagIDs[i].ToString();
                            }
                        }
                        strTagSql += ") ";

                        strTagSql += " GROUP BY T3.UserID HAVING COUNT(T3.UserID) = @Count) T4 ON T4.UserID = T1.UserID ";
                    }

                    mainSql = string.Format(mainSql, strTagSql);

                    List<AccountList_Model> list = db.SetCommand(mainSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                        , db.Parameter("@BranchID", BranchID, DbType.Int32)
                        , db.Parameter("@Count", TagIDs.Count, DbType.Int32)
                        , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                        , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<AccountList_Model>();
                    return list;
                }
                else
                {
                    strSql.Append(" select T2.UserID AccountID,T2.Name AccountName, T2.Code AccountCode, T2.Department, T2.Title, T2.Expert, ");
                    strSql.Append(WebAPI.Common.Const.strHttp);
                    strSql.Append(WebAPI.Common.Const.server);
                    strSql.Append(WebAPI.Common.Const.strMothod);
                    strSql.Append(WebAPI.Common.Const.strSingleMark);
                    strSql.Append("  + cast(T2.CompanyID as nvarchar(10)) + ");
                    strSql.Append(WebAPI.Common.Const.strSingleMark);
                    strSql.Append("/");
                    strSql.Append(WebAPI.Common.Const.strImageObjectType1);
                    strSql.Append(WebAPI.Common.Const.strSingleMark);
                    strSql.Append("  + cast(T2.UserID as nvarchar(10))+ '/' + T2.HeadImageFile + ");
                    strSql.Append(WebAPI.Common.Const.strThumb);
                    strSql.Append(" HeadImageURL  ");
                    strSql.Append(" FROM fn_CustomerNamesInRegion(@UserID, @BranchID) T1 ");
                    strSql.Append(" LEFT JOIN ACCOUNT T2 ON T1.SubordinateID=T2.UserID ");
                    strSql.Append(" LEFT JOIN TBL_ACCOUNTBRANCH_RELATIONSHIP T3 ON T3.UserID = T1.SubordinateID AND T3.Available = 1 ");
                    strSql.Append(" {0} ");
                    strSql.Append(" where T2.CompanyID = @CompanyID");
                    strSql.Append(" AND T3.BranchID = @BranchID ");
                    strSql.Append(" AND T2.Available=1 ");
                    strSql.Append(" order by T2.Name");

                    string mainSql = strSql.ToString();
                    string strTagSql = "";

                    if (TagIDs != null && TagIDs.Count > 0)
                    {
                        strTagSql += " INNER JOIN ( SELECT T4.UserID FROM   dbo.TBL_USER_TAGS T4 WHERE  T4.UserType = 1 AND T4.CompanyID = @CompanyID  AND T4.TagID in(";
                        strSql.Append("");
                        for (int i = 0; i < TagIDs.Count; i++)
                        {
                            if (i == 0)
                            {
                                strTagSql += TagIDs[i].ToString();
                            }
                            else
                            {
                                strTagSql += "," + TagIDs[i].ToString();
                            }
                        }
                        strTagSql += ") ";

                        strTagSql += " GROUP BY T4.UserID HAVING COUNT(T4.UserID) = @Count) T5 ON T5.UserID = T2.UserID ";
                    }

                    mainSql = string.Format(mainSql, strTagSql);

                    List<AccountList_Model> list = db.SetCommand(mainSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                        , db.Parameter("@UserID", accountID, DbType.Int32)
                        , db.Parameter("@BranchID", BranchID, DbType.Int32)
                        , db.Parameter("@Count", TagIDs.Count, DbType.Int32)
                        , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                        , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<AccountList_Model>();
                    return list;
                }
            }

        }

        /// <summary>
        /// 返回顾客的专属顾问/销售顾问
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="branchID"></param>
        /// <param name="customerID"></param>
        /// <param name="type">1:专属顾问 2:销售顾问</param>
        /// <returns></returns>
        public int GetRelationshipByCustomerID(int companyID, int branchID, int customerID, int type = 1)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  AccountID
                                    FROM    [RELATIONSHIP]
                                    WHERE   CustomerID = @CustomerID
                                            AND BranchID = @BranchID
                                            AND CompanyID = @CompanyID
                                            AND Type = @Type
                                            AND Available = 1";

                int accountID = db.SetCommand(strSql
                    , db.Parameter("CustomerID", customerID, DbType.Int32)
                    , db.Parameter("BranchID", branchID, DbType.Int32)
                    , db.Parameter("CompanyID", companyID, DbType.Int32)
                    , db.Parameter("Type", type, DbType.Int32)).ExecuteScalar<int>();

                return accountID;
            }
        }

        public List<AccountList_Model> getAccountListByBranchID(int companyId, int branchId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = " select T1.UserID AS AccountID, T1.Name AS AccountName, T1.Title,"
                + WebAPI.Common.Const.strHttp 
                            + WebAPI.Common.Const.server 
                            + WebAPI.Common.Const.strMothod
                            + WebAPI.Common.Const.strSingleMark
                            + "  + cast(T1.CompanyID as nvarchar(10)) + "
                            + WebAPI.Common.Const.strSingleMark
                            + "/"
                            + WebAPI.Common.Const.strImageObjectType1
                            + WebAPI.Common.Const.strSingleMark
                            + "  + cast(T1.UserID as nvarchar(10))+ '/' + T1.HeadImageFile + "
                            + WebAPI.Common.Const.strThumb
                            + " HeadImageURL from ACCOUNT T1 INNER JOIN [TBL_ACCOUNTBRANCH_RELATIONSHIP] T2 ON T1.UserID = T2.UserID AND T2.Available = 1 AND T2.BranchID =@BranchID and T2.VisibleForCustomer = 1 WHERE T1.Available = 1 ";

                List<AccountList_Model> list = db.SetCommand(strSql.ToString(), db.Parameter("@CompanyID", companyId, DbType.Int32)
                           , db.Parameter("@BranchID", branchId, DbType.Int32)
                           , db.Parameter("@ImageHeight", "100", DbType.String)
                           , db.Parameter("@ImageWidth", "100", DbType.String)).ExecuteList<AccountList_Model>();

                return list;
            }
        }


    }
}
