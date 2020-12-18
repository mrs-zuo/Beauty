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
using WebAPI.Common;

namespace WebAPI.DAL
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

        /// <summary>
        /// 获取公司下面所有员工
        /// </summary>
        /// <param name="companyID">公司ID</param>
        /// <param name="width">头像宽</param>
        /// <param name="hight">头像高</param>
        /// <param name="pageIndex">当前页数</param>
        /// <param name="pageSize">分页大小</param>
        /// <param name="type">0:抽取全部 1:抽取首页标志</param>
        /// <param name="recordCount">共有多少条</param>
        /// <returns></returns>
        public List<GetAccountList_Model> getAccountList(int companyID, int width, int hight, int pageIndex, int pageSize, int type, out int recordCount)
        {
            recordCount = 0;
            List<GetAccountList_Model> list = new List<GetAccountList_Model>();
            using (DbManager db = new DbManager())
            {
                string strHeadImg = string.Format(WebAPI.Common.Const.getUserHeadImg, "T1.CompanyID", "T1.UserID", "T1.HeadImageFile", hight, width);
                string fileds = @" ROW_NUMBER() OVER ( ORDER BY T1.IsRecommend DESC, T1.UserID ) AS rowNum ,
                                                  T1.UserID AS AccountID,T1.Name AS AccountName,T1.Department,T1.Title,T1.Expert,T1.Introduction," + strHeadImg;

                string strSql = " SELECT {0} FROM [ACCOUNT] T1 WITH(NOLOCK) WHERE CompanyID=@CompanyID  AND Available = 1 ";

                if (type == 1)
                {
                    strSql += " AND T1.IsRecommend = 1 ";
                }

                string strCountSql = string.Format(strSql, " count(0) ");

                recordCount = db.SetCommand(strCountSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalar<int>();

                if (recordCount < 0)
                {
                    return null;
                }
                if (type == 0)
                {
                    string strgetListSql = "select * from( " + string.Format(strSql, fileds) + " ) a where  rowNum between  " + ((pageIndex - 1) * pageSize + 1) + " and " + pageIndex * pageSize;
                    list = db.SetCommand(strgetListSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<GetAccountList_Model>();
                }
                else if (type == 1)
                {
                    string strgetListSql = string.Format(strSql, fileds);
                    list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<GetAccountList_Model>();

                }
                return list;
            }
        }

        public GetAccountList_Model getAccountDetail(int companyID, int accountID, int hight, int width)
        {
            GetAccountList_Model model;
            using (DbManager db = new DbManager())
            {
                string strHeadImg = string.Format(WebAPI.Common.Const.getUserHeadImg, "T1.CompanyID", "T1.UserID", "T1.HeadImageFile", hight, width);
                string fileds = @"Select T1.UserID AS AccountID,T1.Name AS AccountName,T1.Department,T1.Title,T1.Expert,T1.Introduction,ISNull(T1.UpdateTime,T1.CreateTime) UpdateTime," + strHeadImg;

                fileds += @" from Account T1 
                                        where T1.UserID =@UserID and CompanyID =@CompanyID";
                model = db.SetCommand(fileds, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                             , db.Parameter("@UserID", accountID, DbType.Int32)).ExecuteObject<GetAccountList_Model>();
                return model;
            }
        }

        public List<SubQuery_Model> GetHierarchySubQuery_2_2(int accountID, int branchID)
        {
            List<SubQuery_Model> list = new List<SubQuery_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT * FROM fn_CustomerNamesInRegion(@AccountID,@BranchID) ";

                list = db.SetCommand(strSql, db.Parameter("@AccountID", accountID)
                                           , db.Parameter("@BranchID", branchID)).ExecuteList<SubQuery_Model>();

                return list;
            }
        }

        public UserRole_Model getUserRole_2_2(int userId)
        {
            UserRole_Model model = new UserRole_Model();
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT [ACCOUNT].RoleID,[BRANCH].IsPay,[BRANCH].IsPartPay,[TBL_ROLE].Jurisdictions from [ACCOUNT] 
                                      LEFT JOIN [TBL_ROLE] on [TBL_ROLE].ID = [ACCOUNT].RoleID
                                      LEFT JOIN [BRANCH] on [BRANCH].ID = [ACCOUNT].BranchID 
                                      WHERE [ACCOUNT].UserID = @UserID";
                model = db.SetCommand(strSql, db.Parameter("@UserID", userId, DbType.Int32)).ExecuteObject<UserRole_Model>();
                return model;
            }
        }

        /// <summary>
        /// 是否已经收藏过了
        /// </summary>
        /// <param name="CompanyID"></param>
        /// <param name="AccountID"></param>
        /// <param name="Code"></param>
        /// <param name="ProductType"></param>
        /// <returns>0:没有收藏 >0:收藏过</returns>
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
                    strSql.Append(Common.Const.strHttp);
                    strSql.Append(Common.Const.server);
                    strSql.Append(Common.Const.strMothod);
                    strSql.Append(Common.Const.strSingleMark);
                    strSql.Append("  + cast(T1.CompanyID as nvarchar(10)) + ");
                    strSql.Append(Common.Const.strSingleMark);
                    strSql.Append("/");
                    strSql.Append(Common.Const.strImageObjectType1);
                    strSql.Append(Common.Const.strSingleMark);
                    strSql.Append("  + cast(T1.UserID as nvarchar(10))+ '/' + T1.HeadImageFile + ");
                    strSql.Append(Common.Const.strThumb);
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

                        //strTagSql += " GROUP BY T3.UserID HAVING COUNT(T3.UserID) = @Count) T4 ON T4.UserID = T1.UserID ";
                        strTagSql += " GROUP BY T3.UserID ) T4 ON T4.UserID = T1.UserID ";
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
                    strSql.Append(Common.Const.strHttp);
                    strSql.Append(Common.Const.server);
                    strSql.Append(Common.Const.strMothod);
                    strSql.Append(Common.Const.strSingleMark);
                    strSql.Append("  + cast(T2.CompanyID as nvarchar(10)) + ");
                    strSql.Append(Common.Const.strSingleMark);
                    strSql.Append("/");
                    strSql.Append(Common.Const.strImageObjectType1);
                    strSql.Append(Common.Const.strSingleMark);
                    strSql.Append("  + cast(T2.UserID as nvarchar(10))+ '/' + T2.HeadImageFile + ");
                    strSql.Append(Common.Const.strThumb);
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

                        // strTagSql += " GROUP BY T4.UserID HAVING COUNT(T4.UserID) = @Count) T5 ON T5.UserID = T2.UserID ";
                        strTagSql += " GROUP BY T4.UserID ) T5 ON T5.UserID = T2.UserID ";
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
        public List<int> GetRelationshipByCustomerID(int companyID, int branchID, int customerID, int type = 1)
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

                List<int> accountID = db.SetCommand(strSql
                    , db.Parameter("CustomerID", customerID, DbType.Int32)
                    , db.Parameter("BranchID", branchID, DbType.Int32)
                    , db.Parameter("CompanyID", companyID, DbType.Int32)
                    , db.Parameter("Type", type, DbType.Int32)).ExecuteScalarList<int>();

                return accountID;
            }
        }

        /// <summary>
        /// 获取Account列表
        /// </summary>
        /// <param name="customerId"></param>
        /// <param name="branchId"></param>
        /// <param name="customerId"></param>
        /// <param name="flag">0: 公司所有 1：总店 2：分店</param>
        /// <returns></returns>
        /// 2013/8/1 添加取得头像链接 By SCS陈
        public List<AccountList_Model> getAccountListForCustomer(int companyId, int branchId, int customerId, int flag, int imageWidth, int imageHeight, string strTagIDs)
        {
            using (DbManager db = new DbManager())
            {
                StringBuilder strSql = new StringBuilder();
                strSql.Append(" select T1.UserID AccountID,T1.Name AccountName, T1.Code AccountCode, T1.Department, T1.Title, T1.Expert, ");
                strSql.Append(Common.Const.strHttp);
                strSql.Append(Common.Const.server);
                strSql.Append(Common.Const.strMothod);
                strSql.Append(Common.Const.strSingleMark);
                strSql.Append("  + cast(T1.CompanyID as nvarchar(10)) + ");
                strSql.Append(Common.Const.strSingleMark);
                strSql.Append("/");
                strSql.Append(Common.Const.strImageObjectType1);
                strSql.Append(Common.Const.strSingleMark);
                strSql.Append("  + cast(T1.UserID as nvarchar(10))+ '/' + T1.HeadImageFile + ");
                strSql.Append(Common.Const.strThumb);
                strSql.Append(" HeadImageURL  ");
                strSql.Append(" from ACCOUNT T1 ");
                strSql.Append(" INNER JOIN TBL_ACCOUNTBRANCH_RELATIONSHIP T2 on T1.UserID = T2.UserID AND T2.Available = 1  ");
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
                if (!string.IsNullOrWhiteSpace(strTagIDs))
                {
                    string[] arrayTagIDs = strTagIDs.Split(new string[] { "|" }, StringSplitOptions.RemoveEmptyEntries);
                    if (arrayTagIDs != null && arrayTagIDs.Length > 0)
                    {
                        string strWhereTag = "";
                        foreach (string item in arrayTagIDs)
                        {
                            if (strWhereTag != "")
                            {
                                strWhereTag += " OR ";
                            }
                            strWhereTag += " T4.TagID= " + item;
                        }
                        if (strWhereTag != "")
                        {
                            strWhereTag = @" SELECT UserID FROM [TBL_USER_TAGS] T4 WHERE T4.CompanyID=@CompanyID AND (" + strWhereTag + ") group by T4.UserID HAVING COUNT(T4.ID) =  " + arrayTagIDs.Length;
                            strSql.Append(" AND T1.UserID in ( ");
                            strSql.Append(strWhereTag);
                            strSql.Append(" )");
                        }
                    }
                }

                strSql.Append(" ORDER BY ISNULL(T3.SortID,10000) ");

                List<AccountList_Model> list = db.SetCommand(strSql.ToString(), db.Parameter("@CompanyID", companyId, DbType.Int32)
                           , db.Parameter("@CustomerID", customerId, DbType.Int32)
                           , db.Parameter("@BranchID", branchId, DbType.Int32)
                           , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                           , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<AccountList_Model>();
                return list;
            }

        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="branchID"></param>
        /// <param name="imageWidth"></param>
        /// <param name="imageHeight"></param>
        /// <returns></returns>
        public List<AccountList_Model> getAccountListByCompanyID(int companyID, int branchID, List<int> TagIDs, int imageWidth, int imageHeight)
        {
            List<AccountList_Model> list = new List<AccountList_Model>();
            using (DbManager db = new DbManager())
            {
                StringBuilder strSql = new StringBuilder();
                strSql.Append(" SELECT T1.UserID AccountID,T1.Name AccountName, T1.Code AccountCode, T1.Department, T1.Title, T1.Expert, ");
                strSql.Append(Common.Const.strHttp);
                strSql.Append(Common.Const.server);
                strSql.Append(Common.Const.strMothod);
                strSql.Append(Common.Const.strSingleMark);
                strSql.Append("  + cast(T1.CompanyID as nvarchar(10)) + ");
                strSql.Append(Common.Const.strSingleMark);
                strSql.Append("/");
                strSql.Append(Common.Const.strImageObjectType1);
                strSql.Append(Common.Const.strSingleMark);
                strSql.Append("  + cast(T1.UserID as nvarchar(10))+ '/' + T1.HeadImageFile + ");
                strSql.Append(Common.Const.strThumb);
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
        /// 
        /// </summary>
        /// <param name="accountID"></param>
        /// <param name="branchID"></param>
        /// <param name="date"></param>
        /// <returns></returns>
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
                strSql.Append(" select  T1.Name, T6.BranchName, T1.Department, T1.Title ,T1.Code, T1.Introduction ,T1.Expert, T1.Mobile,CASE WHEN (CHARINDEX('|15|',T2.Jurisdictions)>0 OR T1.RoleID = -1 ) THEN 1 ELSE 0 END Chat_Use,");
                strSql.Append(Common.Const.strHttp);
                strSql.Append(Common.Const.server);
                strSql.Append(Common.Const.strMothod);
                strSql.Append(Common.Const.strSingleMark);
                strSql.Append("  + cast(T1.CompanyID as nvarchar(10)) + ");
                strSql.Append(Common.Const.strSingleMark);
                strSql.Append("/");
                strSql.Append(Common.Const.strImageObjectType1);
                strSql.Append(Common.Const.strSingleMark);
                strSql.Append("  + cast(T1.UserID as nvarchar(10))+ '/' + T1.HeadImageFile + ");
                strSql.Append(Common.Const.strThumb);
                strSql.Append(" HeadImageURL ");
                strSql.Append(" from ACCOUNT T1 ");
                strSql.Append(" LEFT JOIN BRANCH T6 ");
                strSql.Append(" on T6.ID = T1.BranchID");
                strSql.Append(" LEFT JOIN dbo.TBL_ROLE T2 WITH(NOLOCK) ON T1.RoleID = T2.ID ");

                strSql.Append(" WHERE T1.UserID = @AccountID");

                AccountDetail_Model model = db.SetCommand(strSql.ToString(), db.Parameter("@AccountID", accountId, DbType.Int32)
                    , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                    , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteObject<AccountDetail_Model>();

                return model;
            }

        }

        /// <summary>
        /// 改变美容师状态
        /// </summary>
        /// <param name="customerId"></param>
        /// <returns></returns>
        public bool changeAccState(int companyId, int accountId, int available)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"update ACCOUNT set 
                             Available=@Available
                              where UserID=@ID and CompanyID=@CompanyID";

                int rows = db.SetCommand(strSql, db.Parameter("@Available", available == 1 ? true : false, DbType.Boolean)
                                               , db.Parameter("@ID", accountId, DbType.Int32)
                                               , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteNonQuery();
                if (rows > 0)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }

        /// <summary>
        /// 修改美容师信息
        /// </summary>
        /// <param name="customerId"></param>
        /// <returns></returns>
        public bool updateAccDetail(UpdateAccountDetailOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                try
                {
                    string strSql =
                    @"update [USER] set 
                     LoginMobile = @LoginMobile 
                     where ID=@UserID";

                    int rows = db.SetCommand(strSql, db.Parameter("@LoginMobile", model.LoginMobile, DbType.String)
                        , db.Parameter("@UserID", model.AccountID, DbType.Int32)).ExecuteNonQuery();

                    if (rows > 0)
                    {
                        StringBuilder strSqlCommand = new StringBuilder();
                        strSqlCommand.Append("update ACCOUNT set ");
                        strSqlCommand.Append("UpdaterID=@UpdaterID,");
                        strSqlCommand.Append("UpdateTime=@UpdateTime");
                        if (model.HeadFlag == 1)
                        {
                            strSqlCommand.Append(",HeadImageFile=@HeadImageFile");
                        }
                        strSqlCommand.Append(" where UserID=@UserID");
                        rows = db.SetCommand(strSql.ToString()
                            , db.Parameter("UpdaterID", model.UpdaterID, DbType.Int32)
                            , db.Parameter("UpdateTime", DateTime.Now.ToLocalTime(), DbType.Int32)
                            , db.Parameter("HeadImageFile", model.HeadImageFile, DbType.Int32)
                            , db.Parameter("UserID", model.AccountID, DbType.Int32)).ExecuteNonQuery();
                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                            return false;
                        }
                        else
                        {
                            db.CommitTransaction();
                            return true;
                        }
                    }
                    else
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                }
                catch(Exception ex)
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }



        /// <summary>
        /// 获取收藏列表
        /// </summary>
        /// <param name="CompanyID">公司ID</param>
        /// <param name="AccountID">员工ID</param>
        /// <param name="ProductType">-1:全部 0:服务 1:商品</param>
        /// <param name="imageWidth">图片宽度</param>
        /// <param name="imageHeight">图片高度</param>
        /// <returns></returns>
        public List<FavoriteList_Model> getFavoriteByAccountID(int CompanyID, int AccountID, int BranchID, int ProductType, int imageWidth, int imageHeight, int customerId)
        {
            using (DbManager db = new DbManager())
            {
                int levelId = 0;
                if (customerId > 0)
                {
                    string strSqlLevelId = @" select  T2.CardID from [CUSTOMER] T1 with (nolock)
                                       INNER JOIN [TBL_CUSTOMER_CARD] T2 with (nolock) ON T1.DefaultCardNo=T2.UserCardNo 
									   INNER JOIN [MST_CARD_BRANCH] T3 ON T2.CardID = T3.CardID AND T3.BranchID = @BranchID
                                        where T1.UserID =@UserID and T1.Available = 1";

                    Object obj = db.SetCommand(strSqlLevelId, db.Parameter("@UserID", customerId, DbType.Int32)
                                    , db.Parameter("@BranchID", BranchID, DbType.Int32)).ExecuteScalar();
                    if (!(Object.Equals(obj, null)) && !(Object.Equals(obj, System.DBNull.Value)))
                    {
                        levelId = StringUtils.GetDbInt(obj);
                    }
                }

                StringBuilder strSqlCommodity = new StringBuilder();
                strSqlCommodity.Append(" SELECT T1.ID,T2.ID AS ProductID,T1.Code AS ProductCode,T2.CommodityName AS ProductName,T2.Specification, T1.ProductType,T1.SortID,T2.MarketingPolicy ,T2.UnitPrice, CASE WHEN T2.MarketingPolicy = 2 THEN CASE WHEN @CardID = 0 THEN T2.UnitPrice ELSE T2.PromotionPrice END WHEN T2.MarketingPolicy = 1 THEN T2.UnitPrice * ISNULL(T8.Discount,1) END PromotionPrice,T1.CreateTime,case  when T2.Available = 1 and T6.Available = 1 and T7.Available =1 then 1 else 0 end Available,ExpirationDate='',");
                strSqlCommodity.Append(Common.Const.strHttp);
                strSqlCommodity.Append(Common.Const.server);
                strSqlCommodity.Append(Common.Const.strMothod);
                strSqlCommodity.Append(Common.Const.strSingleMark);
                strSqlCommodity.Append("  + cast(T3.CompanyID as nvarchar(10)) + ");
                strSqlCommodity.Append(Common.Const.strSingleMark);
                strSqlCommodity.Append("/");
                strSqlCommodity.Append(Common.Const.strImageObjectType6);
                strSqlCommodity.Append(Common.Const.strSingleMark);
                strSqlCommodity.Append("  + cast(T3.CommodityCode as nvarchar(16))+ '/' + T3.FileName + ");
                strSqlCommodity.Append(Common.Const.strThumb);
                strSqlCommodity.Append(" FileUrl ");
                strSqlCommodity.Append(" FROM [TBL_FAVORITE] T1 ");
                strSqlCommodity.Append(" LEFT JOIN [COMMODITY] T2 WITH(NOLOCK) ON T1.Code=T2.Code AND T2.ID =(SELECT MAX(ID) FROM [COMMODITY] T4 WHERE T4.Code=T1.Code) ");
                strSqlCommodity.Append(" LEFT JOIN IMAGE_COMMODITY T3 WITH ( NOLOCK ) ON T2.ID = T3.CommodityID AND T3.ImageType = 0 ");
                strSqlCommodity.Append(@"LEFT JOIN
                                            (SELECT ID ,
                                            CompanyID ,
                                            BranchID ,
                                            Code ,
                                            Available
                                            FROM   dbo.TBL_MARKET_RELATIONSHIP
                                            WHERE  ID IN (SELECT  MAX(ID)
                                                           FROM    TBL_MARKET_RELATIONSHIP T1 
                                                           WHERE   T1.Type = 1 AND T1.BranchID =@BranchID AND T1.Available = 1 
                                                           GROUP BY T1.Code)
                                                                   ) T6 ON T2.Code = T6.Code ");
                strSqlCommodity.Append(@"LEFT JOIN(SELECT ProductCode Code,CASE WHEN StockCalcType = 1 AND ProductQty<=0 THEN 0 ELSE 1 END Available FROM  dbo.TBL_PRODUCT_STOCK T1
                                             WHERE  ProductType = 1 AND T1.BranchID =@BranchID  )T7 on T2.Code = T7.Code  ");
                strSqlCommodity.Append(" LEFT JOIN  (select CardID,DiscountID,Discount from [TBL_CARD_DISCOUNT] T9 WITH(NOLOCK) INNER JOIN [TBL_DISCOUNT] T10 ON T9.DiscountID = T10.ID ) T8  ON T8.CardID=@CardID AND T2.DiscountID = T8.DiscountID ");
                strSqlCommodity.Append(" WHERE T1.ProductType=1 ");
                strSqlCommodity.Append(" AND T1.CompanyID=@CompanyID ");
                strSqlCommodity.Append(" AND T1.AccountID=@AccountID ");
                strSqlCommodity.Append(" AND T1.BranchID=@BranchID ");

                StringBuilder strSqlService = new StringBuilder();
                strSqlService.Append(" SELECT T1.ID,T2.ID AS ProductID,T1.Code AS ProductCode,T2.ServiceName AS ProductName,Specification='',T1.ProductType,T1.SortID,T2.MarketingPolicy ,T2.UnitPrice,  CASE WHEN T2.MarketingPolicy = 2 THEN CASE WHEN @CardID = 0 THEN T2.UnitPrice ELSE T2.PromotionPrice END WHEN T2.MarketingPolicy = 1 THEN T2.UnitPrice * ISNULL(T8.Discount,1) END PromotionPrice,T1.CreateTime,case  when T2.Available = 1 and T6.Available = 1 then 1 else 0 end Available, (CASE when T2.ExpirationDate=0 THEN '2099-12-31' when T2.ExpirationDate IS NULL THEN '2099-12-31' ELSE  ISNULL(CONVERT(VARCHAR(10), DATEADD(DAY, T2.ExpirationDate, GETDATE()),25),'') END) AS ExpirationTime, ");
                strSqlService.Append(Common.Const.strHttp);
                strSqlService.Append(Common.Const.server);
                strSqlService.Append(Common.Const.strMothod);
                strSqlService.Append(Common.Const.strSingleMark);
                strSqlService.Append("  + cast(T3.CompanyID as nvarchar(10)) + ");
                strSqlService.Append(Common.Const.strSingleMark);
                strSqlService.Append("/");
                strSqlService.Append(Common.Const.strImageObjectType8);
                strSqlService.Append(Common.Const.strSingleMark);
                strSqlService.Append("  + cast(T3.ServiceCode as nvarchar(16))+ '/' + T3.FileName + ");
                strSqlService.Append(Common.Const.strThumb);
                strSqlService.Append(" FileUrl ");
                strSqlService.Append(" FROM [TBL_FAVORITE] T1 ");
                strSqlService.Append(" LEFT JOIN [SERVICE] T2 WITH(NOLOCK) ON T1.Code=T2.Code AND T2.ID =(SELECT MAX(ID) FROM [SERVICE] T4 WHERE T4.Code=T1.Code)");
                strSqlService.Append(" LEFT JOIN [IMAGE_SERVICE] T3 WITH ( NOLOCK ) ON T2.ID = T3.ServiceID AND T3.ImageType = 0 ");
                strSqlService.Append(@" LEFT JOIN
                            (  SELECT ID ,
                            CompanyID ,
                            BranchID ,
                            Code ,
                            Available
                            FROM   dbo.TBL_MARKET_RELATIONSHIP
                            WHERE  ID IN (SELECT  MAX(ID)
                                           FROM    TBL_MARKET_RELATIONSHIP T1 
                                           WHERE   T1.Type = 0 AND T1.BranchID =@BranchID AND T1.Available = 1 
                                           GROUP BY T1.Code)
                                                   ) T6 ON T2.Code = T6.Code ");
                strSqlService.Append(@"");
                strSqlService.Append("  LEFT JOIN  (select CardID,DiscountID,Discount from [TBL_CARD_DISCOUNT] T9 WITH(NOLOCK) INNER JOIN [TBL_DISCOUNT] T10 ON T9.DiscountID = T10.ID ) T8  ON T8.CardID=@CardID AND T2.DiscountID = T8.DiscountID ");
                strSqlService.Append(" WHERE T1.ProductType=0 ");
                strSqlService.Append(" AND T1.CompanyID=@CompanyID ");
                strSqlService.Append(" AND T1.AccountID=@AccountID ");
                strSqlService.Append(" AND T1.BranchID=@BranchID ");
                string finalSql = "";
                if (ProductType == -1)
                {
                    finalSql = strSqlCommodity.ToString() + " UNION ALL " + strSqlService.ToString();
                }
                else if (ProductType == 0)
                {
                    finalSql = strSqlService.ToString();
                }
                else
                {
                    finalSql = strSqlCommodity.ToString();
                }

                finalSql += " ORDER BY T1.CreateTime DESC ";

                List<FavoriteList_Model> list = db.SetCommand(finalSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32),
                               db.Parameter("@AccountID", AccountID, DbType.Int32),
                               db.Parameter("@BranchID", BranchID, DbType.Int32),
                               db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String),
                               db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String),
                               db.Parameter("@CardID", levelId, DbType.Int32)).ExecuteList<FavoriteList_Model>();
                return list;
            }
        }

        /// <summary>
        /// 添加收藏
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public int addFavorite(Favorite_Model model)
        {
            try
            {
                using (DbManager db = new DbManager())
                {
                    string strSql = @"INSERT INTO [TBL_FAVORITE] ([CompanyID],[AccountID],[ProductType],[Code],[SortID],[CreateTime],[BranchID])
                                    VALUES(@CompanyID,@AccountID,@ProductType,@Code,(SELECT ISNULL(MAX(SortID),0) + 1 FROM TBL_FAVORITE WHERE AccountID=@AccountID AND CompanyID=@CompanyID AND BranchID=@BranchID AND ProductType=@ProductType),@CreateTime,@BranchID);select @@IDENTITY";
                    int rs = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                    db.Parameter("@AccountID", model.AccountID, DbType.Int32),
                                    db.Parameter("@ProductType", model.ProductType, DbType.Int32),
                                    db.Parameter("@Code", model.ProductCode, DbType.Int64),
                                    db.Parameter("@SortID", model.SortID, DbType.Int32),
                                    db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2),
                                    db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteScalar<int>();
                    return rs;
                }
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        /// <summary>
        /// 删除收藏
        /// </summary>
        /// <param name="ID"></param>
        /// <returns>-1:没有收藏过改商品 0: 失败 1:成功</returns>
        public int deleteFavorite(int ID)
        {

            using (DbManager db = new DbManager())
            {
                try
                {
                    string selectSql = @"SELECT * FROM [TBL_FAVORITE] WHERE ID=@ID";
                    Favorite_Model model = db.SetCommand(selectSql, db.Parameter("@ID", ID, DbType.Int32)).ExecuteObject<Favorite_Model>();
                    if (model != null)
                    {
                        db.BeginTransaction();
                        string insertSql = @"INSERT INTO [TBL_HISTORY_FAVORITE] ([ID] ,[CompanyID],[AccountID],[ProductType],[Code],[SortID],[CreateTime],[UpdateTime],[BranchID])
                                                     VALUES(@ID,@CompanyID,@AccountID,@ProductType,@Code,@SortID,@CreateTime,@UpdateTime,@BranchID);select @@IDENTITY";
                        int rs = db.SetCommand(insertSql, db.Parameter("@ID", model.ID, DbType.Int32),
                                        db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                        db.Parameter("@AccountID", model.AccountID, DbType.Int32),
                                        db.Parameter("@ProductType", model.ProductType, DbType.Int32),
                                        db.Parameter("@Code", model.ProductCode, DbType.Int64),
                                        db.Parameter("@SortID", model.SortID, DbType.Int32),
                                        db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2),
                                        db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2),
                                        db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteNonQuery();
                        if (rs > 0)
                        {
                            string delSql = @"DELETE TBL_FAVORITE WHERE ID=@ID";
                            rs = db.SetCommand(delSql, db.Parameter("@ID", ID, DbType.Int32)).ExecuteNonQuery();
                            if (rs > 0)
                            {
                                db.CommitTransaction();
                                return 1;
                            }
                            else
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                        }
                        else
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                    }
                    else
                    {
                        return -1;
                    }
                }
                catch(Exception ex)
                {
                    db.RollbackTransaction();
                    throw;
                }
            }

        }

        public List<AccountList_Model> getAccountListByTagID(int companyID, int branchID, int tagID, int hight, int width)
        {
            List<AccountList_Model> list = new List<AccountList_Model>();
            using (DbManager db = new DbManager())
            {
                string strHeadImg = string.Format(WebAPI.Common.Const.getUserHeadImg, "T1.CompanyID", "T1.UserID", "T1.HeadImageFile", hight, width);
                string strSql = @"SELECT T1.UserID AS AccountID,T1.Name AS AccountName,T1.Code AS AccountCode," + strHeadImg;
                strSql += @" FROM  ACCOUNT T1 WITH(NOLOCK)
                                    RIGHT JOIN [TBL_ACCOUNTBRANCH_RELATIONSHIP] T2 WITH(NOLOCK) ON T1.UserID=T2.UserID AND T2.BranchID=@BranchID AND T2.CompanyID=@CompanyID
                                    RIGHT JOIN [TBL_USER_TAGS] T3 WITH(NOLOCK) ON T3.UserID=T2.UserID AND T3.UserType=1 AND T2.CompanyID=@CompanyID
                                    WHERE T1.CompanyID=@CompanyID AND T3.TagID=@TagID";

                list = db.SetCommand(strSql, db.Parameter("@BranchID", branchID, DbType.Int32)
                      , db.Parameter("@CompanyID", companyID, DbType.Int32)
                      , db.Parameter("@TagID", tagID, DbType.Int32)).ExecuteList<AccountList_Model>();

                return list;
            }
        }

        public int AttendanceByAccount(int companyID, int branchID, int accountID, DateTime nowTime, int CheckOnAccID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" INSERT INTO TBL_ACCOUNT_ATTENDANCE( CompanyID ,BranchID ,AccountID ,Today ,CheckOnTime ,CheckOnAccID ,CreatorID ,CreateTime ) 
                                VALUES ( @CompanyID ,@BranchID ,@AccountID ,@Today ,@CheckOnTime ,@CheckOnAccID ,@CreatorID ,@CreateTime ) ";

                int addRes = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@BranchID", branchID, DbType.Int32)
                    , db.Parameter("@AccountID", accountID, DbType.Int32)
                    , db.Parameter("@Today", nowTime, DbType.Date)
                    , db.Parameter("@CheckOnTime", nowTime, DbType.DateTime2)
                    , db.Parameter("@CheckOnAccID", CheckOnAccID, DbType.Int32)
                    , db.Parameter("@CreatorID", CheckOnAccID, DbType.Int32)
                    , db.Parameter("@CreateTime", nowTime, DbType.DateTime2)).ExecuteNonQuery();

                if (addRes != 1)
                {
                    return 0;
                }

                return 1;
            }
        }

        #region
        public List<AccountListForWeb_Model> getAccountListForWeb(int userId, int branchId, int companyId, int available, string strInput)
        {

            using (DbManager db = new DbManager())
            {
                string strSql = @" select T1.UserID ,T1.Name , T1.Code ,T1.Mobile, T1.Department, T1.Expert,T1.Available,T1.RoleID,T1.Introduction,T1.Title,T3.RoleName,ISNULL(T8.BranchCount,0) BranchCount,T1.IsRecommend ,"
                                + Const.getAccountImgForManagerList
                                 + @"from ACCOUNT T1 
                                 LEFT JOIN 
                                 TBL_ROLE T3 
                                 ON T1.RoleID = T3.ID 
                                 AND T1.CompanyID = T3.CompanyID 
                                 AND T3.Available = 1 
                                 LEFT JOIN  
                                 (select T7.UserID,COUNT(T7.BranchID) BranchCount from [TBL_ACCOUNTBRANCH_RELATIONSHIP] T7 left JOIN [BRANCH] T9 ON T7.BranchID = T9.ID WHERE T7.Available  = 1 and ((T7.BranchID> 0 AND T9.Available = 1) OR T7.BranchID = 0) GROUP BY T7.UserID ) T8  
                                 ON T1.UserID = T8.UserID  ";
                if (branchId > -1)
                {
                    strSql += @"  Where ( T1.UserID in (SELECT fn_CustomerNamesInRegion.SubordinateID FROM fn_CustomerNamesInRegion(@AccountID,@BranchID))";
                }
                else
                {
                    strSql += "  Where ( T1.UserID in (SELECT fn_SubordinateAccountAll.SubordinateID FROM fn_SubordinateAccountAll(@AccountID)";
                    if (branchId == -2)
                    {
                        strSql += @" where SubordinateID not in (select T5.UserID from [TBL_ACCOUNTBRANCH_RELATIONSHIP] T5 with (nolock) where T5.Available = 1 AND T5.CompanyID =@CompanyID group by UserID  ) ) ";
                    } if (branchId == -1)
                    {
                        strSql += @"  ) OR  T1.UserID=@AccountID ";
                    }
                }
                strSql += @"  ) ";
                
                if (available > -1)
                {
                    strSql += "and T1.Available = @Available ";
                }
                else 
                { 
                    strSql += @" and T1.Available <> 2 "; // 2:删除
                }

                if (strInput != "")
                {
                    strSql += " AND '|' + ISNULL(T1.Name,'') +'|' + ISNULL(T1.Mobile,'') +'|' + ISNULL(T1.Code,'') + '|' LIKE '%" + strInput + "%'";
                }
                strSql += " order by T1.IsRecommend desc, T1.Available desc ,T1.Code ASC, T1.Name Asc";


                //Common.WriteLOG.WriteLog("@AccountID int = " + userId.ToString());
                //Common.WriteLOG.WriteLog("@BranchID int = " + branchId.ToString());
                //Common.WriteLOG.WriteLog("@Available int = " + available.ToString());
                //Common.WriteLOG.WriteLog("@CompanyID int = " + companyId.ToString());
                //Common.WriteLOG.WriteLog(strSql);

                List<AccountListForWeb_Model> list = new List<AccountListForWeb_Model>();
                list = db.SetCommand(strSql, db.Parameter("@AccountID", userId, DbType.Int32)
                    , db.Parameter("@BranchID", branchId, DbType.Int32)
                    , db.Parameter("@Available", available, DbType.Int32)
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteList<AccountListForWeb_Model>();

                return list;

            }

        }

        public Account_Model getAccountDetailForWeb(int userId, int companyId)
        {

            using (DbManager db = new DbManager())
            {
                string strSql = @" select T1.UserID, T1.Name , T1.Code ,T1.Mobile, T1.Department, T1.Expert,T1.Available,T1.RoleID,T1.BranchID,T1.Introduction,T1.Title,T1.IsRecommend, "
                                 + Const.getAccountImgForManager
                                 + @"from ACCOUNT T1 where   T1.CompanyID =@CompanyID and T1.UserID=@UserID";


                Account_Model model = new Account_Model();
                model = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32), db.Parameter("@UserID", userId, DbType.Int32)).ExecuteObject<Account_Model>();


                //查询员工提成率
                string strSqlStaffRate = " SELECT Top 1 * FROM COMMISSION_RATE_STAFF T2 where T2.userId = @userId AND T2.IssuedDate <=@IssuedDate ORDER BY T2.IssuedDate DESC ";
                Company_Model modelStaffRate = db.SetCommand(strSqlStaffRate,
                                           db.Parameter("@userId", userId, DbType.Int32)
                                          , db.Parameter("@IssuedDate", DateTime.Now.ToString("yyyy-MM-dd"), DbType.String)).ExecuteObject<Company_Model>();
                if (modelStaffRate != null)
                {
                    model.IssuedDate = modelStaffRate.IssuedDate;
                    model.CommissionRate = modelStaffRate.CommissionRate * 100;
                }

                return model;

            }

        }

        public List<BranchSelection_Model> getBranchIDListForWeb(int companyID, int userID, int branchID)
        {
            List<BranchSelection_Model> list = new List<BranchSelection_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT DISTINCT T1.ID AS BranchID, T1.BranchName,T2.VisibleForCustomer,
                                CASE WHEN T2.BranchID=T1.ID THEN 1 ELSE 0 END AS IsExist
                                FROM    BRANCH T1
                                        LEFT JOIN TBL_ACCOUNTBRANCH_RELATIONSHIP T2 ON T1.ID = T2.BranchID AND T2.UserID=@UserID AND T2.Available=1 
                                WHERE   T1.CompanyID =@CompanyID  AND T1.Available=1 {0}";
                string strPlus = "";
                if (branchID > 0)
                {
                    strPlus = " AND  T1.ID =@BranchID ";
                }

                string strSqlFinal = string.Format(strSql, strPlus);
                list = db.SetCommand(strSqlFinal, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                           , db.Parameter("@UserID", userID, DbType.Int32)
                                           , db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteList<BranchSelection_Model>();

                if (branchID == 0)
                {
                    string strSqlBranch0 = @" SELECT T1.Available FROM [TBL_ACCOUNTBRANCH_RELATIONSHIP] T1 WHERE T1.CompanyID =@CompanyID AND T1.UserID=@UserID AND T1.Available=1 AND T1.BranchID = 0  ";

                    bool Available = db.SetCommand(strSqlBranch0, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                               , db.Parameter("@UserID", userID, DbType.Int32)).ExecuteScalar<bool>();

                    BranchSelection_Model model = new BranchSelection_Model();
                    model.BranchID = 0;
                    model.BranchName = "总店";
                    model.IsExist = Available;
                    list.Insert(0, model);
                }

                return list;
            }
        }

        public List<AccountTag_Model> getTagsIDListForWeb(int companyID, int userID, int branchID = 0)
        {
            List<AccountTag_Model> list = new List<AccountTag_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = @"  SELECT DISTINCT
                                    T1.ID AS TagID ,
                                    T1.Name AS TagName ,
                                    CASE WHEN T2.TagID = T1.ID THEN 1
                                         ELSE 0
                                    END AS IsExist
                             FROM   [TBL_TAG] T1
                                    LEFT JOIN [TBL_User_TAGS] T2 ON T1.ID = T2.TagID
                                                                                   AND T2.UserID = @UserID
                                                                                   AND T2.Available = 1 AND T2.UserType=1
                             WHERE  T1.CompanyID = @CompanyID
                                    AND T1.Available = 1
                                    AND T1.Type=2  ";
                string strPlus = "";
                if (branchID > 0)
                {
                    strPlus = " AND  T2.BranchID =@BranchID ";
                }

                string strSqlFinal = string.Format(strSql, strPlus);
                list = db.SetCommand(strSqlFinal, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                           , db.Parameter("@UserID", userID, DbType.Int32)
                                           , db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteList<AccountTag_Model>();

                return list;
            }
        }

        public int AddAccount(Account_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();
                    string strSqlUser = @" insert into [USER](
                                    CompanyID,UserType,Password,LoginMobile)
                                     values (
                                    @CompanyID,@UserType,@Password,@LoginMobile)
                                    ;select @@IDENTITY";

                    int userId = db.SetCommand(strSqlUser, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@UserType", 1, DbType.Int32)
                        , db.Parameter("@Password", Common.DEncrypt.DEncrypt.Encrypt(model.Password), DbType.String)
                        , db.Parameter("@LoginMobile", model.Mobile, DbType.String)).ExecuteScalar<int>();
                    //Common.WriteLOG.WriteLog(@"user inserted");
                    if (userId <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    string strSqlAccount = @" insert into ACCOUNT(
                           CompanyID,BranchID,UserID,Code,RoleID,Name,Department,Title,Expert,Introduction,Mobile,Available,CreatorID,CreateTime,HeadImageFile,IsRecommend)
                            values (
                           @CompanyID,@BranchID,@UserID,@Code,@RoleID,@Name,@Department,@Title,@Expert,@Introduction,@Mobile,@Available,@CreatorID,@CreateTime,@HeadImageFile,@IsRecommend)";

                    int rows = db.SetCommand(strSqlAccount, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@BranchID", 0, DbType.Int32)
                        , db.Parameter("@UserID", userId, DbType.Int32)
                        , db.Parameter("@Code", model.Code, DbType.String)
                        , db.Parameter("@RoleID", model.RoleID == -2 ? (object)DBNull.Value : model.RoleID, DbType.Int32)
                        , db.Parameter("@Name", model.Name, DbType.String)
                        , db.Parameter("@Department", model.Department, DbType.String)
                        , db.Parameter("@Title", model.Title, DbType.String)
                        , db.Parameter("@Expert", model.Expert, DbType.String)
                        , db.Parameter("@Introduction", model.Introduction, DbType.String)
                        , db.Parameter("@Mobile", model.Mobile, DbType.String)
                        , db.Parameter("@Available", model.Available, DbType.Int32)
                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                        , db.Parameter("@HeadImageFile", model.HeadImageFile, DbType.String)
                        , db.Parameter("@IsRecommend", model.IsRecommend, DbType.Boolean)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    //Common.WriteLOG.WriteLog(@"account inserted");

                    string strSqlHierarchy = @" insert into HIERARCHY( 
                                            CompanyID,SuperiorID,SubordinateID,CreatorID,CreateTime)
                                            values (
                                            @CompanyID,@SuperiorID,@SubordinateID,@CreatorID,@CreateTime) ";

                    rows = db.SetCommand(strSqlHierarchy, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@SuperiorID", model.CreatorID, DbType.Int32)
                        , db.Parameter("@SubordinateID", userId, DbType.Int32)
                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    if (model.BranchID > 0)
                    {
                        string strSqlBranch = @" insert into [TBL_ACCOUNTBRANCH_RELATIONSHIP]
                                                                    (CompanyID,BranchID,UserID,Available,CreatorID,CreateTime)
                                                                    values 
                                                                    (@CompanyID,@BranchID,@UserID,@Available,@CreatorID,@CreateTime) ";


                        rows = db.SetCommand(strSqlBranch, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                            , db.Parameter("@UserID", userId, DbType.Int32)
                            , db.Parameter("@Available", true, DbType.Boolean)
                            , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                            , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();


                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                    }

                    if (model.TagsList != null && model.TagsList.Count > 0)
                    {
                        foreach (AccountTag_Model item in model.TagsList)
                        {
                            string addTagsSql = @"INSERT [TBL_USER_TAGS] (CompanyID,BranchID,UserType,UserID,TagID,Available,CreatorID,CreateTime )
                                              VALUES (@CompanyID,@BranchID,@UserType,@UserID,@TagID,@Available,@CreatorID,@CreateTime )";

                            int addRes = db.SetCommand(addTagsSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                               , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                               , db.Parameter("@UserType", 1, DbType.Int32)//0:customer 1:business
                               , db.Parameter("@UserID", userId, DbType.Int32)
                               , db.Parameter("@TagID", item.TagID, DbType.Int32)
                               , db.Parameter("@Available", true, DbType.Boolean)
                               , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                               , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                        }
                    }
                    if (userId >0 && model.IssuedDate !=null) {
                        //删除大于生效日的销售顾问提成率数据
                        string strSqlStaffRateDelete = @"DELETE FROM COMMISSION_RATE_STAFF WHERE UserID = @UserID AND IssuedDate >= @IssuedDate";
                        rows = db.SetCommand(strSqlStaffRateDelete,
                             db.Parameter("@UserID", userId, DbType.Int32)
                           , db.Parameter("@IssuedDate", model.IssuedDate, DbType.Date)
                           ).ExecuteNonQuery();

                        //插入销售顾问默认提成率
                        string strSqlStaffRateInsert = @"INSERT INTO COMMISSION_RATE_STAFF (UserID,IssuedDate,CommissionRate,CreatorID,CreateTime,UpdaterID,UpdateTime) VALUES (@UserID,@IssuedDate,@CommissionRate,@CreatorID,@CreateTime,@UpdaterID,@UpdateTime)";
                        rows = db.SetCommand(strSqlStaffRateInsert,
                              db.Parameter("@UserID", userId, DbType.Int32)
                            , db.Parameter("@IssuedDate", model.IssuedDate, DbType.Date)
                            , db.Parameter("@CommissionRate", model.CommissionRate / 100, DbType.Decimal)
                            , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                            , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                            , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                            , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime2)
                            ).ExecuteNonQuery();
                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                        }
                    }
                    db.CommitTransaction();
                    return userId;
                }
                catch (Exception ex)
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }


        public bool UpdateAccount(Account_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();
                    string strSqlHistory = @" Insert Into HISTORY_USER 
                                            select * from [USER] 
                                            where ID =@ID";

                    int rows = db.SetCommand(strSqlHistory, db.Parameter("@ID", model.UserID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    string strSqlUpdate = @" update [USER] set 
                                            LoginMobile=@LoginMobile
                                             where ID=@ID ";

                    rows = db.SetCommand(strSqlUpdate
                        , db.Parameter("@LoginMobile", model.Mobile, DbType.String)
                        , db.Parameter("@ID", model.UserID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    string strSqlHistoryAccount = @" INSERT INTO HISTORY_ACCOUNT SELECT * FROM ACCOUNT WHERE USERID=@USERID ";

                    rows = db.SetCommand(strSqlHistoryAccount
                        , db.Parameter("@USERID", model.UserID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    string strSqlUpdateAccount = @" update ACCOUNT set 
                                                Code=@Code, 
                                                Name=@Name,
                                                Department=@Department,
                                                Title=@Title, 
                                                Expert=@Expert, 
                                                Introduction=@Introduction, 
                                                Mobile=@Mobile,
                                                Available=@Available, 
                                                UpdaterID=@UpdaterID,
                                                UpdateTime=@UpdateTime, 
                                                IsRecommend=@IsRecommend {0} {1} 
                                                where UserID=@UserID ";

                    string strSqlPlus0 = "";
                    string strSqlPlus1 = "";
                    if (model.RoleID > -1)
                    {
                        strSqlPlus0 = "  ,RoleID=@RoleID";
                    }
                    if (model.HeadImageFile != null)
                    {
                        strSqlPlus1 = "  ,HeadImageFile =@HeadImageFile ";
                    }
                    string strSqlUpdateFinal = string.Format(strSqlUpdateAccount, strSqlPlus0, strSqlPlus1);

                    rows = db.SetCommand(strSqlUpdateFinal
                        , db.Parameter("@Code", model.Code, DbType.String)
                        , db.Parameter("@RoleID", model.RoleID, DbType.Int32)
                        , db.Parameter("@Name", model.Name, DbType.String)
                        , db.Parameter("@Department", model.Department, DbType.String)
                        , db.Parameter("@Title", model.Title, DbType.String)
                        , db.Parameter("@Expert", model.Expert, DbType.String)
                        , db.Parameter("@Introduction", model.Introduction, DbType.String)
                        , db.Parameter("@Mobile", model.Mobile, DbType.String)
                        , db.Parameter("@Available", model.Available, DbType.Int32)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                        , db.Parameter("@HeadImageFile", model.HeadImageFile, DbType.String)
                        , db.Parameter("@IsRecommend", model.IsRecommend, DbType.Boolean)
                        , db.Parameter("@UserID", model.UserID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    if (model.TagsList != null && model.TagsList.Count > 0)
                    {
                        #region 查询原有标签数量
                        string strSelCountSql = "select COUNT(0) from [TBL_USER_TAGS] WHERE UserID=@UserID AND CompanyID=@CompanyID";
                        int selCount = db.SetCommand(strSelCountSql, db.Parameter("@UserID", model.UserID, DbType.Int32)
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();
                        #endregion

                        if (selCount > 0)
                        {
                            #region 修改原数据的修改人及修改时间
                            string strUpdateSql = @"UPDATE [TBL_USER_TAGS] SET UpdaterID=@UpdaterID,UpdateTime=@UpdateTime 
                                                WHERE UserID=@UserID AND CompanyID=@CompanyID";
                            int updateRes = db.SetCommand(strUpdateSql, db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                   , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                                   , db.Parameter("@UserID", model.UserID, DbType.Int32)
                                   , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                            #endregion


                            if (updateRes <= 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }

                            #region 插入历史表
                            string strAddHisSql = "INSERT INTO [TBL_HISTORY_USER_TAGS] select * from [TBL_USER_TAGS] WHERE UserID=@UserID AND CompanyID=@CompanyID ";
                            int addHisRes = db.SetCommand(strAddHisSql, db.Parameter("@UserID", model.UserID, DbType.Int32)
                                                     , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                            #endregion

                            if (addHisRes <= 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }

                            #region 一刀切删除所有数据
                            string strDelSql = "DELETE FROM TBL_USER_TAGS WHERE UserID=@UserID AND CompanyID=@CompanyID";
                            int delRes = db.SetCommand(strDelSql, db.Parameter("@UserID", model.UserID, DbType.Int32)
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                            #endregion

                            if (delRes <= 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }

                        #region 循环插入数据
                        foreach (AccountTag_Model item in model.TagsList)
                        {
                            string addTagsSql = @"INSERT [TBL_USER_TAGS] (CompanyID,BranchID,UserType,UserID,TagID,Available,CreatorID,CreateTime )
                                              VALUES ( @CompanyID,@BranchID,@UserType,@UserID,@TagID,@Available,@CreatorID,@CreateTime )";

                            int addRes = db.SetCommand(addTagsSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                               , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                               , db.Parameter("@UserType", 1, DbType.Int32)//0:customer 1:business
                               , db.Parameter("@UserID", model.UserID, DbType.Int32)
                               , db.Parameter("@TagID", item.TagID, DbType.Int32)
                               , db.Parameter("@Available", true, DbType.Boolean)
                               , db.Parameter("@CreatorID", model.UpdaterID, DbType.Int32)
                               , db.Parameter("@CreateTime", model.UpdateTime, DbType.DateTime2)
                               , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                               , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }
                        #endregion

                    }
                    if (model.UserID > 0 && model.IssuedDate != null) {
                        //删除大于生效日的销售顾问提成率数据
                        string strSqlStaffRateDelete = @"DELETE FROM COMMISSION_RATE_STAFF WHERE UserID = @UserID AND IssuedDate >= @IssuedDate";
                        rows = db.SetCommand(strSqlStaffRateDelete,
                             db.Parameter("@UserID", model.UserID, DbType.Int32)
                           , db.Parameter("@IssuedDate", model.IssuedDate, DbType.Date)
                           ).ExecuteNonQuery();

                        //插入销售顾问默认提成率
                        string strSqlStaffRateInsert = @"INSERT INTO COMMISSION_RATE_STAFF (UserID,IssuedDate,CommissionRate,CreatorID,CreateTime,UpdaterID,UpdateTime) VALUES (@UserID,@IssuedDate,@CommissionRate,@CreatorID,@CreateTime,@UpdaterID,@UpdateTime)";
                        rows = db.SetCommand(strSqlStaffRateInsert,
                              db.Parameter("@UserID", model.UserID, DbType.Int32)
                            , db.Parameter("@IssuedDate", model.IssuedDate, DbType.Date)
                            , db.Parameter("@CommissionRate", model.CommissionRate / 100, DbType.Decimal)
                            , db.Parameter("@CreatorID", model.UpdaterID, DbType.Int32)
                            , db.Parameter("@CreateTime", model.UpdateTime, DbType.DateTime2)
                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                            , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                            ).ExecuteNonQuery();
                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                        }
                    }
                    db.CommitTransaction();
                    return true;


                }
                catch (Exception ex)
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }

        public bool IsExsitAccountMobileInCompany(Account_Model model)
        {

            using (DbManager db = new DbManager())
            {
                string strSql = " SELECT UserID FROM [ACCOUNT] WITH(NOLOCK) WHERE CompanyID=@CompanyID AND Mobile=@Mobile and UserID <>@UserID and Available = 1 ";

                int userId = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                     , db.Parameter("@Mobile", model.Mobile, DbType.String)
                     , db.Parameter("@UserID", model.UserID, DbType.Int32)).ExecuteScalar<int>();
                //Common.WriteLOG.WriteLog("@Mobile varchar(max) = " + model.Mobile);
                //Common.WriteLOG.WriteLog("@UserID int = " + model.UserID.ToString());
                //Common.WriteLOG.WriteLog(strSql);
                if (userId > 0)
                {
                    return true;
                }
                else
                {
                    return false;
                }

            }

        }

        public bool IsExsitAccountNameInCompany(Account_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = " SELECT UserID FROM [ACCOUNT] WITH(NOLOCK) WHERE CompanyID=@CompanyID AND Name=@Name AND UserID<>@UserID ";
                //Common.WriteLOG.WriteLog("@Name varchar(max) = " + model.Name);
                //Common.WriteLOG.WriteLog("@UserID int = " + model.UserID.ToString());
                //Common.WriteLOG.WriteLog(strSql);
                int userId = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                     , db.Parameter("@Name", model.Name, DbType.String)
                     , db.Parameter("@UserID", model.UserID, DbType.Int32)).ExecuteScalar<int>();

                if (userId > 0)
                {
                    return true;
                }
                else
                {
                    return false;
                }

            }
        }

        public List<Hierarchy_Model> getHierarchyList(int userId, int type)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT T1.ID,T1.SuperiorID,T1.SubordinateID,T1.Level,CASE T2.Available WHEN 1 then T2.Name ELSE T2.Name + ' (停用)' END  SubordinateName FROM 
                                 fn_SubordinateAccountAll(@UserID) T1 
                                LEFT JOIN [ACCOUNT] T2 ON T1.SubordinateID = T2.UserID {0} order by T1.Level ";

                string strType = "";

                if (type == 1)
                {
                    strType = " where T2.Available = 1 ";
                }
                else { 
                    strType = " where T2.Available <> 2 ";
                }

                string strSqlFinal = string.Format(strSql, strType);

                List<Hierarchy_Model> list = new List<Hierarchy_Model>();
                list = db.SetCommand(strSqlFinal
                     , db.Parameter("@UserID", userId, DbType.Int32)).ExecuteList<Hierarchy_Model>();

                return list;
            }
        }

        public Hierarchy_Model getTopAccount(int userId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"  SELECT T1.ID ,T1.SuperiorID,T1.SubordinateID ,0 as Level,T2.Name SubordinateName from   [HIERARCHY] T1 LEFT JOIN [ACCOUNT] T2 ON T1.SubordinateID = T2.UserID
								where T1.SubordinateID =@UserID ";

                Hierarchy_Model model = new Hierarchy_Model();
                model = db.SetCommand(strSql
                     , db.Parameter("@UserID", userId, DbType.Int32)).ExecuteObject<Hierarchy_Model>();

                return model;
            }
        }

        public Hierarchy_Model getLoginAccount(int userId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"  SELECT 0 as ID ,0 as SuperiorID,T1.UserID as SubordinateID,0 as Level,T1.Name SubordinateName from   [ACCOUNT] T1
								where T1.UserID =@UserID ";

                Hierarchy_Model model = new Hierarchy_Model();
                model = db.SetCommand(strSql
                     , db.Parameter("@UserID", userId, DbType.Int32)).ExecuteObject<Hierarchy_Model>();

                return model;
            }
        }

        public Hierarchy_Model getHierarchyDetail(int hierarchyId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT T1.ID , T1.SuperiorID,T1.SubordinateID,T2.Name SubordinateName FROM 
                                 HIERARCHY T1 
                                LEFT JOIN [ACCOUNT] T2 ON T1.SubordinateID = T2.UserID 
								where T1.ID =@ID ";

                Hierarchy_Model model = new Hierarchy_Model();
                model = db.SetCommand(strSql
                     , db.Parameter("@ID", hierarchyId, DbType.Int32)).ExecuteObject<Hierarchy_Model>();

                return model;
            }
        }

        public int UpdateHierarchy(Hierarchy_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSqlCheck = @" select Count(*) from fn_SubordinateAccountAll(@SubordinateID) T1 where T1.SubordinateID =@SubordinateID ";

                int cnt = db.SetCommand(strSqlCheck, db.Parameter("@SubordinateID", model.SubordinateID, DbType.Int32)).ExecuteScalar<int>();

                if (cnt > 0)
                {
                    return -2;
                }
                else if (cnt < 0)
                {
                    return -1;
                }
                else
                {
                    string strSqlHier = @"  update HIERARCHY set 
                                            SuperiorID =@SuperiorID,
                                            UpdaterID=@UpdaterID,
                                            UpdateTime=@UpdateTime
                                             where  ID=@ID ";

                    int rows = db.SetCommand(strSqlHier
                        , db.Parameter("@SuperiorID", model.SuperiorID, DbType.Int32)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                        , db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery();

                    if (rows > 0)
                    {
                        return 1;
                    }
                    else
                    {
                        return 0;
                    }
                }
            }
        }

        public bool resetPassword(Account_Model model)
        {

            using (DbManager db = new DbManager())
            {
                string strSql = @" update [USER] set 
                                Password=@Password
                                 where ID=@userId ";
                int rows = db.SetCommand(strSql, db.Parameter("@Password", Common.DEncrypt.DEncrypt.Encrypt(model.Password), DbType.String)
                    , db.Parameter("@userId", model.UserID, DbType.Int32)).ExecuteNonQuery();

                if (rows > 0)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }

        public bool OperateBranch(AccountBranchOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                string strSqlCount = @" select Count(*) from [TBL_ACCOUNTBRANCH_RELATIONSHIP] where UserID =@UserID  ";

                int count = db.SetCommand(strSqlCount
                         , db.Parameter("@UserID", model.UserID, DbType.Int32)).ExecuteScalar<int>();

                if (count > 0)
                {

                    //                    string strSqlAvailableBranch = @" update  [TBL_ACCOUNTBRANCH_RELATIONSHIP]
                    //                                                        set Available=@Available,
                    //                                                        UpdaterID = @UpdaterID,
                    //                                                        UpdateTime = @UpdateTime
                    //                                                        where UserID=@UserID ";
                    //                    int rows = db.SetCommand(strSqlAvailableBranch
                    //                             , db.Parameter("@UserID", model.UserID, DbType.Int32)
                    //                             , db.Parameter("@Available", false, DbType.Int32)
                    //                             , db.Parameter("@UpdaterID", model.OperatorID, DbType.Int32)
                    //                             , db.Parameter("@UpdateTime", model.OperatorTime, DbType.DateTime2)).ExecuteNonQuery();

                    //                    string strSqlHistoryBranch = @" INSERT INTO [TBL_HISTORY_ACCOUNTBRANCH_RELATIONSHIP]
                    //                                                            select * from [TBL_ACCOUNTBRANCH_RELATIONSHIP] where UserID =@UserID ";

                    //                    int effRows = db.SetCommand(strSqlHistoryBranch,
                    //                             db.Parameter("@UserID", model.UserID, DbType.Int32)).ExecuteNonQuery();

                    //                    if (effRows != rows)
                    //                    {
                    //                        db.RollbackTransaction();
                    //                        return false;
                    //                    }

                    string strSqlDeleteBranch = @" delete [TBL_ACCOUNTBRANCH_RELATIONSHIP] where UserID =@UserID ";
                    int effRows = 0;
                    effRows = db.SetCommand(strSqlDeleteBranch,
                             db.Parameter("@UserID", model.UserID, DbType.Int32)).ExecuteNonQuery();

                    if (effRows != count)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                }

                string strSqlBranch = @" insert into [TBL_ACCOUNTBRANCH_RELATIONSHIP]
                                                (CompanyID,BranchID,UserID,Available,CreatorID,CreateTime,VisibleForCustomer)
                                                values 
                                                (@CompanyID,@BranchID,@UserID,@Available,@CreatorID,@CreateTime,@VisibleForCustomer) ";

                //                string strSqlSort = @" INSERT INTO [TBL_ACCOUNTSORT]
                //                                        (CompanyID,BranchID,UserID,SortID,CreatorID,CreateTime,RecordType)
                //                                              VALUES
                //                                        (@CompanyID,@BranchID,@UserID,@SortID,@CreatorID,@CreateTime,1) ";



                if (model.BranchList != null)
                {
                    foreach (BranchSelection_Model item in model.BranchList)
                    {

                        int rows = db.SetCommand(strSqlBranch, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                             , db.Parameter("@BranchID", item.BranchID, DbType.Int32)
                             , db.Parameter("@UserID", model.UserID, DbType.Int32)
                             , db.Parameter("@Available", true, DbType.Boolean)
                             , db.Parameter("@CreatorID", model.OperatorID, DbType.Int32)
                             , db.Parameter("@CreateTime", model.OperatorTime, DbType.DateTime2)
                             , db.Parameter("@VisibleForCustomer", item.VisibleForCustomer, DbType.Boolean)).ExecuteNonQuery();


                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                            return false;
                        }

                        //rows = db.SetCommand(strSqlSort, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        //     , db.Parameter("@BranchID", item.BranchID, DbType.Int32)
                        //     , db.Parameter("@UserID", model.UserID, DbType.Int32)
                        //     , db.Parameter("@SortID", 10000, DbType.Int32)
                        //     , db.Parameter("@CreatorID", model.OperatorID, DbType.Int32)
                        //     , db.Parameter("@CreateTime", model.OperatorTime, DbType.DateTime2)).ExecuteNonQuery();


                        //if (rows == 0)
                        //{
                        //    db.RollbackTransaction();
                        //    return false;
                        //}
                    }
                }

                db.CommitTransaction();
                return true;

            }
        }

        public List<AccountList_Model> getAccountListForOrderEdit(int OrderID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"
                                SELECT  t1.UserID AccountID,
                                        Name AccountName 
                                FROM    dbo.ACCOUNT t1
                                        INNER JOIN dbo.TBL_ACCOUNTBRANCH_RELATIONSHIP T2 ON t1.UserID = T2.UserID
                                        INNER JOIN [order] t3 on t3.CompanyID=t1.CompanyID and t3.BranchID=t2.BranchID
                                                                                           where t3.id=@OrderID
                                                                                            AND T2.Available = 1 
                                                                                            AND t1.Available = 1 ";

                List<AccountList_Model> list = db.SetCommand(strSql, db.Parameter("@OrderID", OrderID, DbType.Int32)
                                                                   ).ExecuteList<AccountList_Model>();
                return list;
            }
        }

        public List<AccountList_Model> getAccountListForPaymentEdit(int OrderID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"
                                SELECT distinct T6.AccountID,T6.AccountName,T7.ProfitPct FROM (
                                 SELECT  T1.UserID AccountID,
                                        Name AccountName 
                                FROM    dbo.ACCOUNT T1
                                        INNER JOIN dbo.TBL_ACCOUNTBRANCH_RELATIONSHIP T2 ON T1.UserID = T2.UserID
                                        INNER JOIN PAYMENT T3 on T3.CompanyID=T1.CompanyID and T3.BranchID=T2.BranchID
                                                                                           where T3.id=@PaymentID
                                                                                            AND T2.Available = 1 
                                                                                            AND T1.Available = 1  
                                                                                                UNION  ALL  
                                                                                            SELECT T4.SlaveID AccountID ,T5.Name AccountName 
                                                                                            FROM [TBL_PROFIT] T4
                                                                                            LEFT JOIN [ACCOUNT] T5 
                                                                                            ON T4.SlaveID = T5.UserID 
                                                                                            WHERE T4.Type = 2 AND T4.Available = 1 AND T4.MasterID=@PaymentID) T6 
                                                                                            LEFT JOIN [TBL_PROFIT] T7 
                                                                                            ON T6.AccountID = T7.SlaveID AND T7.Type = 2 AND T7.Available = 1 AND T7.MasterID = @PaymentID ";

                List<AccountList_Model> list = db.SetCommand(strSql, db.Parameter("@PaymentID", OrderID, DbType.Int32)
                                                                   ).ExecuteList<AccountList_Model>();
                return list;
            }
        }


        public List<AccountList_Model> getAccountListForBalanceEdit(int BranchID, int BalanceID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"
                              SELECT distinct T6.AccountID,T6.AccountName,T7.ProfitPct FROM (
                                 SELECT  T1.UserID AccountID,
                                        Name AccountName 
                                FROM    dbo.ACCOUNT T1
                                        INNER JOIN dbo.TBL_ACCOUNTBRANCH_RELATIONSHIP T2 ON T1.UserID = T2.UserID where T2.BranchID=@BranchID
                                                                                            AND T2.Available = 1 
                                                                                            AND T1.Available = 1  UNION ALL  
                                                                                            SELECT T4.SlaveID AccountID ,T5.Name AccountName 
                                                                                            FROM [TBL_PROFIT] T4
                                                                                            LEFT JOIN [ACCOUNT] T5 
                                                                                            ON T4.SlaveID = T5.UserID 
                                                                                            WHERE T4.Type =1 AND T4.Available = 1 AND T4.MasterID=@BalanceID) T6 LEFT JOIN [TBL_PROFIT] T7 ON T6.AccountID = T7.SlaveID AND T7.Type = 1 AND T7.Available = 1 AND T7.MasterID=@BalanceID ";

                List<AccountList_Model> list = db.SetCommand(strSql
                    , db.Parameter("@BranchID", BranchID, DbType.Int32)
                    , db.Parameter("@BalanceID", BalanceID, DbType.Int32)
                                                                   ).ExecuteList<AccountList_Model>();
                return list;
            }
        }


        public int checkAccountBranchCancel(int accountId, int branchId)
        {
            using (DbManager db = new DbManager())
            {
                string strSqlAccount = @" select Count(T1.ID) from [HIERARCHY] T1 INNER JOIN [TBL_ACCOUNTBRANCH_RELATIONSHIP] T2 ON T1.SubordinateID = T2.UserID AND T2.Available = 1 where T1.SuperiorID= @AccountID ";
                if (branchId > 0)
                {
                    strSqlAccount += " AND T2.BranchID=@BranchID  ";
                }
                int accountNumber = db.SetCommand(strSqlAccount, db.Parameter("@AccountID", accountId, DbType.Int32)
                                                                    , db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteScalar<int>();

                string strSqlCustomer = @" select COUNT(T1.ID) from [RELATIONSHIP] T1 WHERE T1.AccountID=@AccountID  AND T1.Available = 1 ";

                if (branchId > 0)
                {
                    strSqlCustomer += " AND T1.BranchID=@BranchID  ";
                }

                int customerNumber = db.SetCommand(strSqlCustomer, db.Parameter("@AccountID", accountId, DbType.Int32)
                                                    , db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteScalar<int>();

                if (accountNumber > 0)
                {
                    return 2;
                }
                else if (customerNumber > 0)
                {
                    return 3;
                }
                else
                {
                    return 1;
                }

            }
        }

        public List<GetAccountListByGroupFroWeb_Model> getAccountListUsedByGroupForWeb(int companyID, int tagID = 0)
        {
            List<GetAccountListByGroupFroWeb_Model> list = new List<GetAccountListByGroupFroWeb_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = "";
                if (tagID > 0)
                {
                    strSql = @" SELECT  T1.UserID AS AccountID ,
                                        T1.Name AS AccountName ,
                                        '|' + ISNULL(T1.Name, '') + '|' + ISNULL(T1.Code, '') + '|'
                                        + ISNULL(T1.Mobile, '') AS SearchOut,
                                        CASE WHEN ISNULL(T2.UserID,0)=0 THEN 0 ELSE 1 END AS isExist
                                FROM    ACCOUNT T1
                                LEFT JOIN TBL_USER_TAGS T2 ON T1.UserID=T2.UserID AND T2.UserType=1 AND T2.Available=1 AND T2.TagID=@TagID
                                WHERE   T1.CompanyID = @CompanyID
                                        AND T1.Available = 1
                                        ORDER BY T1.Name";
                    list = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@TagID", tagID, DbType.Int32)).ExecuteList<GetAccountListByGroupFroWeb_Model>();
                }
                else
                {
                    strSql = @" SELECT T1.UserID AS AccountID, T1.Name AS AccountName, '|' + ISNULL(T1.Name,'') +  '|' + ISNULL(T1.Code,'') + '|' + ISNULL(T1.Mobile,'') AS SearchOut 
                                   FROM ACCOUNT T1 WHERE CompanyID=@CompanyID AND Available=1 ORDER BY T1.Name";
                    list = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<GetAccountListByGroupFroWeb_Model>();
                }

            }
            return list;
        }


        public bool isCanAddAccount(int companyId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select CASE WHEN T1.AccountNumber > ISNULL(T2.AccountCount,0) THEN 1 ELSE 0 END isCan 
                                    from [COMPANY] T1 
                                    LEFT JOIN (
                                    select Count(T3.UserID) AccountCount,T3.CompanyID 
                                    from [ACCOUNT] T3 
                                    WHERE T3.CompanyID=@CompanyID AND T3.Available = 1 
                                    group by T3.CompanyID) T2 
                                    on T1.ID = T2.CompanyID 
                                    where T1.ID =@CompanyID";

                //Common.WriteLOG.WriteLog("@CompanyID int = " + companyId);
                //Common.WriteLOG.WriteLog(strSql);
                int isCan = db.SetCommand(strSql
                     , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteScalar<int>();

                if (isCan == 1)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }


        public int CanDeleteAccount(int accountId, int companyId)
        {
            using (DbManager db = new DbManager())
            {
                string strSqlAccount = @"select Count(T1.ID) from [HIERARCHY] T1
                                    INNER JOIN [TBL_ACCOUNTBRANCH_RELATIONSHIP] T2
                                    ON T1.SubordinateID = T2.UserID AND T2.Available = 1 
                                    INNER JOIN [ACCOUNT] T3 
                                    ON T1.SubordinateID = T3.UserID AND T3.Available=1
                                    where T1.SuperiorID=@UserID and T1.CompanyID=@CompanyID ";


                int isCan = db.SetCommand(strSqlAccount
                     , db.Parameter("@UserID", accountId, DbType.Int32)
                     , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteScalar<int>();

                if (isCan > 0)
                {
                    return -1;
                }


                string strSqlCustomer = @" select COUNT(T1.ID) from [RELATIONSHIP] T1 
                                        INNER JOIN [CUSTOMER] T2 
                                        ON T1.CustomerID = T2.UserID AND T2.Available = 1 
                                        WHERE T1.AccountID =@UserID AND T1.Available = 1 AND T1.CompanyID=@CompanyID ";

                isCan = db.SetCommand(strSqlCustomer
                     , db.Parameter("@UserID", accountId, DbType.Int32)
                     , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteScalar<int>();

                if (isCan > 0)
                {
                    return -2;
                }

                return 1;
            }

        }




        public bool EditAccountSort(Branch_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSqlCheck = @" select count(0) from [TBL_ACCOUNTSORT] WHERE BranchID=@BranchID  ";
                int checkRows = db.SetCommand(strSqlCheck
                     , db.Parameter("@BranchID", model.ID, DbType.Int32)).ExecuteScalar<int>();

                string strSql = @" DELETE [TBL_ACCOUNTSORT] WHERE BranchID=@BranchID ";


                int rows = db.SetCommand(strSql
                     , db.Parameter("@BranchID", model.ID, DbType.Int32)).ExecuteNonQuery();

                if (checkRows != rows)
                {
                    return false;
                }

                foreach (AccountSort_Model item in model.ListAccountSort)
                {
                    string strSqlInsert = @" INSERT INTO [TBL_ACCOUNTSORT]
                                           (CompanyID,BranchID,UserID,SortID,CreatorID,CreateTime,RecordType)
                                            VALUES
                                           (@CompanyID,@BranchID,@UserID,@SortID,@CreatorID,@CreateTime,1) ";

                    rows = db.SetCommand(strSqlInsert
                     , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                     , db.Parameter("@BranchID", model.ID, DbType.Int32)
                     , db.Parameter("@UserID", item.UserID, DbType.Int32)
                     , db.Parameter("@SortID", item.SortID, DbType.Int32)
                     , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                     , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        return false;
                    }
                }
                return true;
            }
        }

        public AccountInfo_Model getAccountCountInfo(int companyID)
        {
            AccountInfo_Model model = new AccountInfo_Model();
            using (DbManager db = new DbManager())
            {
                string strSql = @"select count(0) from [ACCOUNT] where CompanyID=@CompanyID and Available = 1 ";

                model.UsedCount = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalar<int>();

                string strSqlMax = " select AccountNumber from COMPANY where id =@CompanyID ";
                model.MaxCount = db.SetCommand(strSqlMax, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalar<int>();
                return model;
            }
        }

        #endregion

    }
}
