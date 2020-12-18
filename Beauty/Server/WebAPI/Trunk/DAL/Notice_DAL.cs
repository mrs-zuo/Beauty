using BLToolkit.Data;
using HS.Framework.Common;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL
{
    public class Notice_DAL
    {
        #region 构造类实例
        public static Notice_DAL Instance
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
            internal static readonly Notice_DAL instance = new Notice_DAL();
        }
        #endregion

        public int getRemindNumberByCustomer(int userId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"  select count(*) 
                                    from [SCHEDULE] T1 
                                    INNER JOIN  [SERVICE] T2 ON T1.ServiceID = T2.ID 
                                    INNER JOIN  [ORDER] T3  ON T1.OrderID = T3.ID 
                                    INNER JOIN  [TREATMENT] T4  ON T1.ID = T4.ScheduleID
                                    LEFT JOIN [ACCOUNT] T6 on T6.UserID = T4.ExecutorID 
                                    LEFT JOIN [USER] T7 on T6.UserID = T7.ID 
                                    LEFT JOIN [ACCOUNT] T8 on T8.UserID = T3.ResponsiblePersonID 
                                    LEFT JOIN [USER] T9 on T8.UserID = T9.ID 
                                    where T3.CustomerID =  @userId and T1.type = 0 and T3.Status != 2  
                                    and T3.ProductType = 0 and T4.Available = 1 
                                    and DATEDIFF(MINUTE,getdate(),T1.ScheduleTime)<1440 and DATEDIFF(MINUTE,getdate(),T1.ScheduleTime) >0";

                int cnt = db.SetCommand(strSql, db.Parameter("@userId", userId, DbType.Int32)).ExecuteScalar<int>();

                return cnt;

            }
        }

        public List<RemindList_Model> getRemindListByAccountID(int accountId, int branchID)
        {
            using (DbManager db = new DbManager())
            {
                List<RemindList_Model> list = new List<RemindList_Model>();
                string strSql = @" 
                                        ( SELECT T1.OrderID ,
                                            '顾客:' + T5.Name 
                                            + ',美丽顾问:' + T10.Name 
                                            + ',服务人员:' + T8.Name
                                            + ',服务名称:' + T6.ServiceName AS RemindContent ,
                                            T1.ScheduleTime AS ScheduleTime ,
                                            T1.Type AS ScheduleType
                               FROM     SCHEDULE T1
                                        INNER JOIN [ORDER] T2 ON T1.OrderID = T2.ID
                                        INNER JOIN [TREATMENT] T4 ON T1.ID = T4.ScheduleID
                                        INNER JOIN [CUSTOMER] T5 ON T2.CustomerID = T5.UserID
                                        LEFT JOIN [SERVICE] T6 ON T1.ServiceID = T6.ID
                                        LEFT JOIN [BRANCH] T7 WITH ( NOLOCK ) ON T2.BranchID = T7.ID
                                        LEFT JOIN [ACCOUNT] T8 WITH ( NOLOCK ) ON T4.ExecutorID = T8.UserID
                                        LEFT JOIN [ACCOUNT] T10 WITH ( NOLOCK ) ON T2.ResponsiblePersonID = T10.UserID
                                        LEFT JOIN [HIERARCHY] T9 WITH (NOLOCK) ON T2.ResponsiblePersonID=T9.SubordinateID
                               WHERE    ( T2.ResponsiblePersonID = @AccountID
                                          OR T4.ExecutorID = @AccountID
                                          OR ( T2.ResponsiblePersonID IN ( SELECT subordinateid FROM [fn_CustomerNamesInRegion](@AccountID, @BranchID) ) )
                                        )
                                        AND T2.ProductType = 0
                                        AND T2.Status = 0
                                        AND DATEDIFF(MINUTE, GETDATE(), T1.ScheduleTime) < T7.RemindTime * 60
                                        AND T4.Available = 1
                                        AND T2.BranchID = @BranchID
                                        AND T1.Status = 0
                                        AND T2.CreateTime > T7.StartTime
                                        AND T1.ScheduleTime IS NOT NULL
                             )
                             
                             ORDER BY ScheduleTime DESC ";

                //UNION ALL
                //             ( SELECT DISTINCT
                //                        T1.OrderID ,
                //                         '顾客:' + T5.Name 
                //                         + ',美丽顾问:' + T10.Name 
                //                         + ',服务人员:' + T8.Name
                //                         + ',服务名称:' + T6.ServiceName AS RemindContent ,
                //                         T1.ScheduleTime AS ScheduleTime ,
                //                         T1.Type AS ScheduleType
                //               FROM     SCHEDULE T1
                //                        LEFT JOIN [ORDER] T2 ON T1.OrderID = T2.ID
                //                        LEFT JOIN [CONTACT] T3 ON T1.ID = T3.ScheduleID
                //                        LEFT JOIN [CUSTOMER] T5 ON T2.CustomerID = T5.UserID
                //                        LEFT JOIN [SERVICE] T6 ON T1.ServiceID = T6.ID
                //                        LEFT JOIN [BRANCH] T7 WITH ( NOLOCK ) ON T2.BranchID = T7.ID
                //                        LEFT JOIN [ACCOUNT] T8 WITH ( NOLOCK ) ON T3.CreatorID = T8.UserID
                //                        LEFT JOIN [ACCOUNT] T10 WITH ( NOLOCK ) ON T2.ResponsiblePersonID = T10.UserID
                //               WHERE    T3.CreatorID = @AccountID
                //                        AND T2.BranchID = @BranchID
                //                        AND T2.ProductType = 0
                //                        AND T2.Status = 0
                //                        AND DATEDIFF(MINUTE, GETDATE(), T1.ScheduleTime) < T7.RemindTime * 60
                //                        AND T3.Available = 1
                //                        AND T1.Status = 0                    
                //                        AND ScheduleTime IS NOT NULL
                //             )

                list = db.SetCommand(strSql, db.Parameter("@AccountID", accountId, DbType.Int32)
                                           , db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteList<RemindList_Model>();

                return list;

            }
        }

        public int getRemindCountByAccountID(int accountId, int branchID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" 
                                        ( SELECT COUNT(0)
                               FROM     SCHEDULE T1
                                        INNER JOIN [ORDER] T2 ON T1.OrderID = T2.ID
                                        INNER JOIN [TREATMENT] T4 ON T1.ID = T4.ScheduleID
                                        INNER JOIN [CUSTOMER] T5 ON T2.CustomerID = T5.UserID
                                        LEFT JOIN [SERVICE] T6 ON T1.ServiceID = T6.ID
                                        LEFT JOIN [BRANCH] T7 WITH ( NOLOCK ) ON T2.BranchID = T7.ID
                                        LEFT JOIN [ACCOUNT] T8 WITH ( NOLOCK ) ON T4.ExecutorID = T8.UserID
                                        LEFT JOIN [ACCOUNT] T10 WITH ( NOLOCK ) ON T2.ResponsiblePersonID = T10.UserID
                                        LEFT JOIN [HIERARCHY] T9 WITH (NOLOCK) ON T2.ResponsiblePersonID=T9.SubordinateID
                               WHERE    ( T2.ResponsiblePersonID = @AccountID
                                          OR T4.ExecutorID = @AccountID
                                          OR ( T2.ResponsiblePersonID IN ( SELECT subordinateid FROM [fn_CustomerNamesInRegion](@AccountID, @BranchID) ) )
                                        )
                                        AND T2.ProductType = 0
                                        AND T2.Status = 0
                                        AND DATEDIFF(MINUTE, GETDATE(), T1.ScheduleTime) < T7.RemindTime * 60
                                        AND T4.Available = 1
                                        AND T2.BranchID = @BranchID
                                        AND T1.Status = 0
                                        AND T2.CreateTime > T7.StartTime
                                        AND T1.ScheduleTime IS NOT NULL
                             )";

                int res = db.SetCommand(strSql, db.Parameter("@AccountID", accountId, DbType.Int32)
                                           , db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteScalar<int>();

                return res;

            }
        }

        public List<BirthdayList_Model> getBirthdayListByAccountID(int accountId, int branchID)
        {
            using (DbManager db = new DbManager())
            {
                List<BirthdayList_Model> list = new List<BirthdayList_Model>();
                string strSql = @" SELECT '顾客:'+Name AS RemindContent, 
                                         CONVERT(varchar(16),T1.BirthDay ,20) AS BirthDay 
                                   FROM [CUSTOMER] T1 WITH(NOLOCK)
                            LEFT JOIN [RELATIONSHIP] T2 WITH(NOLOCK) ON T1.UserID = T2.CUSTOMERID
                            left join [BRANCH] T3  WITH(NOLOCK) ON T1.BranchID = T3.ID 
                            WHERE T2.Available=1 AND T2.AccountID=@AccountID AND T1.birthday IS NOT NULL AND T1.BranchID = @BranchID 
                            AND ((MONTH(T1.birthday) = MONTH(GetDate())
                            AND DAY(T1.birthday) = DAY(GetDate()) ) 
                            AND T3.ID=@BranchID
                            OR (DATEDIFF(DD,GETDATE(),CONVERT(DATETIME,CAST(year(GETDATE()) AS varchar(4))+'-'+CAST(MONTH(T1.BirthDay)AS VARCHAR(2))+'-'+CAST(DAY(T1.BirthDay)AS VARCHAR(2)))) = t3.BirthdayRemindTime))
                            ORDER BY T1.Name ";

                list = db.SetCommand(strSql, db.Parameter("@AccountID", accountId, DbType.Int32)
                                           , db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteList<BirthdayList_Model>();

                return list;
            }
        }

        public int getBirthdayCountByAccountID(int accountId, int branchID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT COUNT(0) 
                                   FROM [CUSTOMER] T1 WITH(NOLOCK)
                            LEFT JOIN [RELATIONSHIP] T2 WITH(NOLOCK) ON T1.UserID = T2.CUSTOMERID
                            left join [BRANCH] T3  WITH(NOLOCK) ON T1.BranchID = T3.ID 
                            WHERE T2.Available=1 AND T2.AccountID=@AccountID AND T1.birthday IS NOT NULL AND T1.BranchID = @BranchID 
                            AND ((MONTH(T1.birthday) = MONTH(GetDate())
                            AND DAY(T1.birthday) = DAY(GetDate()) ) 
                            AND T3.ID=@BranchID
                            OR (DATEDIFF(DD,GETDATE(),CONVERT(DATETIME,CAST(year(GETDATE()) AS varchar(4))+'-'+CAST(MONTH(T1.BirthDay)AS VARCHAR(2))+'-'+CAST(DAY(T1.BirthDay)AS VARCHAR(2)))) = t3.BirthdayRemindTime)) ";

                int res = db.SetCommand(strSql, db.Parameter("@AccountID", accountId, DbType.Int32)
                                           , db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteScalar<int>();

                return res;
            }
        }

        public List<VistList_Model> getVisitListByAccountID(int accountId, int branchID)
        {
            using (DbManager db = new DbManager())
            {
                List<VistList_Model> list = new List<VistList_Model>();
                string strSql = @" SELECT  T2.ID AS OrderID, 
                                                '顾客:'+T1.Name
                                                + ',美丽顾问:'+T8.Name
                                                +',服务人员:'+T6.Name
                                                +',服务名称:'+T3.ServiceName AS RemindContent, 
                                                T4.UpdateTime AS UpdateTime 
                    FROM    [CUSTOMER] T1 WITH ( NOLOCK )
                    LEFT JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.UserID = T2.CUSTOMERID 
                    LEFT JOIN [Service] T3 WITH ( NOLOCK ) ON T2.ServiceID = T3.ID 
                    RIGHT JOIN ( SELECT OrderID,UpdateTime,ID,SubServiceID,[Status]
                    FROM   SCHEDULE a WITH ( NOLOCK )
                    WHERE  ID IN ( SELECT  MAX(id)
                                    FROM    [SCHEDULE]
                                    WHERE   [Status] = 1
                                            AND UpdaterID IS NOT NULL
                                            AND UpdateTime IS NOT NULL
                                    GROUP BY OrderId )
                   ) T4 ON T2.ID = T4.OrderID
                   LEFT JOIN [TREATMENT] T5 WITH (NOLOCK) ON T4.ID=T5.ScheduleID 
                   LEFT JOIN [ACCOUNT] T6  WITH (NOLOCK) ON T5.ExecutorID=T6.UserID 
                   LEFT JOIN [ACCOUNT] T8  WITH (NOLOCK) ON T2.ResponsiblePersonID=T8.UserID 
                   LEFT JOIN [HIERARCHY] T7 WITH (NOLOCK) ON T2.ResponsiblePersonID=T7.SubordinateID 
                   LEFT JOIN [TBL_SubService] T9 WITH ( NOLOCK ) ON T4.SubServiceID=T9.ID 
                   LEFT JOIN [BRANCH] T10 WITH(NOLOCK) ON T2.BranchID=T10.ID
                   WHERE   (T2.ResponsiblePersonID IN ( SELECT subordinateid FROM [fn_CustomerNamesInRegion](@AccountID, @BranchID) ) OR T2.ResponsiblePersonID=@AccountID)
		                    AND T4.Status=1 
		                    AND T2.BranchID=@BranchID
                            AND (T3.NeedVisit = 1 OR T9.NeedVisit=1) 
                            AND T2.CreateTime>T10.StartTime
                            AND DATEDIFF(dd, T4.UpdateTime, GETDATE()) = ISNULL(T3.VisitTime,T9.VisitTime)
                    ORDER BY T4.UpdateTime DESC ";

                list = db.SetCommand(strSql, db.Parameter("@AccountID", accountId, DbType.Int32)
                                           , db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteList<VistList_Model>();

                return list;
            }
        }

        public int getVisitCountByAccountID(int accountId, int branchID)
        {
            using (DbManager db = new DbManager())
            {
                List<VistList_Model> list = new List<VistList_Model>();
                string strSql = @" SELECT  COUNT(0) 
                    FROM    [CUSTOMER] T1 WITH ( NOLOCK )
                    LEFT JOIN [Order] T2 WITH ( NOLOCK ) ON T1.UserID = T2.CUSTOMERID AND ProductType = 0 
                    LEFT JOIN dbo.TBL_ORDER_SERVICE T11 ON T2.ID=T11.OrderID
                    LEFT JOIN [SERVICE] T3 WITH ( NOLOCK ) ON T11.ServiceID = T3.ID
                    RIGHT JOIN ( SELECT OrderID,UpdateTime,ID,SubServiceID,[Status]
                    FROM   SCHEDULE a WITH ( NOLOCK )
                    WHERE  ID IN ( SELECT  MAX(id)
                                    FROM    [SCHEDULE]
                                    WHERE   [Status] = 1
                                            AND UpdaterID IS NOT NULL
                                            AND UpdateTime IS NOT NULL
                                    GROUP BY OrderId )
                   ) T4 ON T2.ID = T4.OrderID
                   LEFT JOIN [TREATMENT] T5 WITH (NOLOCK) ON T4.ID=T5.ScheduleID 
                   LEFT JOIN [ACCOUNT] T6  WITH (NOLOCK) ON T5.ExecutorID=T6.UserID 
                   LEFT JOIN [ACCOUNT] T8  WITH (NOLOCK) ON T2.ResponsiblePersonID=T8.UserID 
                   LEFT JOIN [HIERARCHY] T7 WITH (NOLOCK) ON T2.ResponsiblePersonID=T7.SubordinateID 
                   LEFT JOIN [TBL_SubService] T9 WITH ( NOLOCK ) ON T4.SubServiceID=T9.ID 
                   LEFT JOIN [BRANCH] T10 WITH(NOLOCK) ON T2.BranchID=T10.ID
                   WHERE   (T2.ResponsiblePersonID IN ( SELECT subordinateid FROM [fn_CustomerNamesInRegion](@AccountID, @BranchID) ) OR T2.ResponsiblePersonID=@AccountID)
		                    AND T4.Status=1 
		                    AND T2.BranchID=@BranchID
                            AND (T3.NeedVisit = 1 OR T9.NeedVisit=1) 
                            AND T2.CreateTime>T10.StartTime
                            AND DATEDIFF(dd, T4.UpdateTime, GETDATE()) = ISNULL(T3.VisitTime,T9.VisitTime)";

                int res = db.SetCommand(strSql, db.Parameter("@AccountID", accountId, DbType.Int32)
                                           , db.Parameter("@BranchID", branchID, DbType.Int32)).ExecuteScalar<int>();

                return res;
            }
        }

        public List<GetRemindListByCustomerID_Model> getRemindListByCustomerID(int CustomerID, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                List<GetRemindListByCustomerID_Model> list = new List<GetRemindListByCustomerID_Model>();


                string strHeadImg = string.Format(WebAPI.Common.Const.getUserHeadImg, "T8.CompanyID", "T4.ExecutorID", "T6.HeadImageFile", imageWidth, imageHeight);

                string strSql = @" select distinct CONVERT(varchar(16),T1.ScheduleTime ,20) ScheduleTime, T2.ServiceName,T6.Name AS Excutor,T7.LoginMobile AS ExcutorMobile , T8.Name AS ResponserPerson, T9.LoginMobile AS ResponserPersonMobile ,T4.ExecutorID,T3.ResponsiblePersonID,T10.Phone, case when CHARINDEX('|15|',T11.Jurisdictions)>0 then 1 else 0 end AS ExecutorChat_Use,case when CHARINDEX('|15|',T12.Jurisdictions)>0 then 1 else 0 end AS ResponsiblePersonChat_Use ";
                strSql += "," + strHeadImg;
                strSql += @" FROM [SCHEDULE] T1
                                      INNER JOIN  [SERVICE] T2 ON T1.ServiceID = T2.ID 
                                      INNER JOIN  [ORDER] T3  ON T1.OrderID = T3.ID 
                                      INNER JOIN  [TREATMENT] T4  ON T1.ID = T4.ScheduleID 
                                      LEFT JOIN [ACCOUNT] T6 on T6.UserID = T4.ExecutorID 
                                      LEFT JOIN [USER] T7 on T6.UserID = T7.ID 
                                      LEFT JOIN [ACCOUNT] T8 on T8.UserID = T3.ResponsiblePersonID 
                                      LEFT JOIN [USER] T9 on T8.UserID = T9.ID 
                                      LEFT JOIN [BRANCH] T10 on T10.ID = T3.BranchID 
                                      LEFT JOIN [TBL_ROLE] T11 ON T6.CompanyID=T11.CompanyID AND T6.RoleID=T11.ID 
                                      LEFT JOIN [TBL_ROLE] T12 ON T8.CompanyID=T12.CompanyID AND T8.RoleID=T12.ID 
                                      WHERE T3.CustomerID =  @CustomerID 
                                      AND T1.type = 0  
                                      AND DATEDIFF(MINUTE, GETDATE(), T1.ScheduleTime) < 1440 
                                      AND T3.ProductType = 0 
                                      AND T4.Available = 1 
                                      AND T3.CreateTime>T10.StartTime 
                                      AND T3.Status=0 
                                      AND T1.Status=0 
                                      AND T1.ScheduleTime IS NOT NULL 
                                      ORDER BY ScheduleTime ";

                list = db.SetCommand(strSql, db.Parameter("@CustomerID", CustomerID, DbType.Int32)).ExecuteList<GetRemindListByCustomerID_Model>();

                return list;
            }
        }

        public int getRemindListCountByCustomerID(int CustomerID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"
                                SELECT COUNT(0)
                                        
                                FROM    [SCHEDULE] T1
                                        --INNER JOIN [SERVICE] T2 ON T1.ServiceID = T2.ID
                                        INNER JOIN [ORDER] T3 ON T1.OrderID = T3.ID
                                        INNER JOIN [TREATMENT] T4 ON T1.ID = T4.ScheduleID
                                        LEFT JOIN [BRANCH] T10 ON T10.ID = T3.BranchID
                                WHERE   T3.CustomerID = @CustomerID
                                        AND T1.type = 0
                                        AND DATEDIFF(MINUTE, GETDATE(), T1.ScheduleTime) < 1440
                                        AND T3.ProductType = 0
                                        AND T4.Available = 1
                                        AND T3.CreateTime > T10.StartTime
                                        AND T3.Status = 0
                                        AND T1.Status = 0
                                        AND T1.ScheduleTime IS NOT NULL";
                int count = db.SetCommand(strSql, db.Parameter("@CustomerID", CustomerID, DbType.Int32)).ExecuteScalar<int>();
                return count;
            }
        }

        public List<Notice_Model> getNoticeList(int companyId, int flag, int type, int pageIndex, int pageSize, out int recordCount)
        {
            using (DbManager db = new DbManager())
            {
                List<Notice_Model> list = new List<Notice_Model>();


                string fileds = @" ROW_NUMBER() OVER ( ORDER BY ID ASC ) AS rowNum ,
                                                  ID, NoticeTitle, NoticeContent, CONVERT(varchar(19),StartDate,20) StartDate, CONVERT(varchar(19),EndDate,20) EndDate, CONVERT(varchar(19),CreateTime,20) CreateTime ";

                string strSql = "";

                strSql = @"SELECT  {0} from NOTICE where Available = 1  and CompanyID = @CompanyID and Type = @Type ";

                //strSql += @" WHERE  T5.Available = 1 AND T1.CreateTime >= T6.StartTime ";

//                string strSql = @" select ID, NoticeTitle, NoticeContent, CONVERT(varchar(19),StartDate,20) StartDate, CONVERT(varchar(19),EndDate,20) EndDate, CONVERT(varchar(19),CreateTime,20) CreateTime 
//                                        from NOTICE where Available = 1  and CompanyID = @CompanyID and Type = @Type";

                if (type == 0)
                {
                    switch (flag)
                    {
                        case 0:
                            strSql += " and DATEDIFF(DD,CONVERT(varchar(19),getdate(),20),EndDate) < 0 ";
                            break;
                        case 1:
                            strSql += " and DATEDIFF(DD,CONVERT(varchar(19),getdate(),20),StartDate) <=0  and DATEDIFF(DD,CONVERT(varchar(19),getdate(),20),EndDate) >= 0 ";
                            break;
                        case 2:
                            strSql += " and DATEDIFF(DD,CONVERT(varchar(19),getdate(),20),StartDate) > 0 ";
                            break;
                    }
                }

                string strCountSql = string.Format(strSql, " count(0) ");

                string strgetListSql = "select * from( " + string.Format(strSql, fileds) + " ) a where  rowNum between  " + ((pageIndex - 1) * pageSize + 1) + " and " + pageIndex * pageSize;

                recordCount = db.SetCommand(strCountSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                                                , db.Parameter("@DateNow", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                                                , db.Parameter("@Type", type, DbType.Int32)).ExecuteScalar<int>();

                if (recordCount < 0)
                {
                    return null;
                }

                list = db.SetCommand(strgetListSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@DateNow", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                    , db.Parameter("@Type", type, DbType.Int32)).ExecuteList<Notice_Model>();

                return list;

            }
        }


        public int getNoticeNumber(int companyId)
        {
            using (DbManager db = new DbManager())
            {
                List<Notice_Model> list = new List<Notice_Model>();

                string strSql = @" select count(*) 
                                    from NOTICE 
                                    where CompanyID = @CompanyID and Available =1 
                                    and StartDate <= CONVERT(varchar(10),GETDATE(),20) 
                                    and EndDate >= CONVERT(varchar(10),GETDATE(),20) ";


                int cnt = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteScalar<int>();

                return cnt;
            }
        }

        public bool deleteNotice(int companyId, int noticeId)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strAddHisSql = "insert into HISTORY_NOTICE select * from NOTICE [with rowlock] where ID =@ID and CompanyID=@CompanyID";

                int addRes = db.SetCommand(strAddHisSql, db.Parameter("@ID", noticeId, DbType.Int32)
                                                 , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteNonQuery();

                if (addRes <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                string strSql = @" UPDATE NOTICE SET Available=0 WHERE ID =@ID and CompanyID=@CompanyID";


                int updateRes = db.SetCommand(strSql, db.Parameter("@ID", noticeId, DbType.Int32)
                                                 , db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteNonQuery();
                if (updateRes <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                db.CommitTransaction();
                return true;
            }
        }

        public bool insertNotice(Notice_Model model)
        {
            using (DbManager db = new DbManager())
            {
                object StartDate = DBNull.Value;
                object EndDate = DBNull.Value;
                if (model.TYPE == 0)//新闻没有开始时间,结束时间
                {
                    StartDate = model.StartDate;
                    EndDate = model.EndDate;
                }

                string strAddSql = @"INSERT INTO NOTICE ( CompanyID ,BranchID ,NoticeTitle ,NoticeContent ,StartDate ,EndDate ,Available ,CreatorID ,CreateTime ,TYPE) 
                                        VALUES (@CompanyID ,@BranchID ,@NoticeTitle ,@NoticeContent ,@StartDate ,@EndDate ,@Available ,@CreatorID ,@CreateTime ,@TYPE);select @@IDENTITY ";

                int addRes = db.SetCommand(strAddSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                    , db.Parameter("@NoticeTitle", model.NoticeTitle, DbType.String)
                                                    , db.Parameter("@NoticeContent", model.NoticeContent, DbType.String)
                                                    , db.Parameter("@StartDate", StartDate, DbType.DateTime)
                                                    , db.Parameter("@EndDate", EndDate, DbType.DateTime)
                                                    , db.Parameter("@Available", 1, DbType.Boolean)
                                                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)
                                                    , db.Parameter("@TYPE", model.TYPE, DbType.Int32)).ExecuteScalar<int>();

                if (addRes <= 0)
                {
                    return false;
                }
                return true;
            }
        }

        public bool updateNotice(Notice_Model model)
        {
            using (DbManager db = new DbManager())
            {
                object StartDate = DBNull.Value;
                object EndDate = DBNull.Value;
                if (model.TYPE == 0)//新闻没有开始时间,结束时间
                {
                    StartDate = model.StartDate;
                    EndDate = model.EndDate;
                }

                db.BeginTransaction();
                string strAddHisSql = "insert into HISTORY_NOTICE select * from NOTICE [with rowlock] where ID =@ID and CompanyID=@CompanyID";

                int addRes = db.SetCommand(strAddHisSql, db.Parameter("@ID", model.ID, DbType.Int32)
                                                 , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                if (addRes <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                string strSql = @" UPDATE NOTICE SET UpdaterID=@UpdaterID
                                                    ,UpdateTime=@UpdateTime
                                                    ,NoticeTitle=@NoticeTitle
                                                    ,NoticeContent=@NoticeContent
                                                    ,StartDate=@StartDate
                                                    ,EndDate=@EndDate 
                                                    WHERE ID =@ID and CompanyID=@CompanyID";

                int updateRes = db.SetCommand(strSql, db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                                   , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
                                                   , db.Parameter("@NoticeTitle", model.NoticeTitle, DbType.String)
                                                   , db.Parameter("@NoticeContent", model.NoticeContent, DbType.String)
                                                   , db.Parameter("@StartDate", StartDate, DbType.DateTime)
                                                   , db.Parameter("@EndDate", EndDate, DbType.DateTime)
                                                   , db.Parameter("@ID", model.ID, DbType.Int32)
                                                   , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                if (updateRes <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                db.CommitTransaction();
                return true;
            }
        }

        public Notice_Model getNoticeDetail(int companyId, int noticeId)
        {
            using (DbManager db = new DbManager())
            {
                Notice_Model model = new Notice_Model();

                string strSql = @"SELECT CompanyID,BranchID,ID,NoticeTitle,NoticeContent,StartDate,EndDate,TYPE FROM dbo.NOTICE WHERE ID=@ID AND CompanyID=@CompanyID";

                model = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                                            , db.Parameter("@ID", noticeId, DbType.Int32)).ExecuteObject<Notice_Model>();

                return model;

            }
        }
    }
}
