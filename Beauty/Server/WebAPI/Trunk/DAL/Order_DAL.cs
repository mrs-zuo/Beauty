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


        //public List<Course> getCourseListByOrderID(int orderID)
        //{
        //    List<Course> list = new List<Course>();
        //    using (DbManager db = new DbManager())
        //    {
        //        string strSql = @"SELECT ID AS CourseID,CreatorID FROM COURSE WHERE Available=1 and OrderID=@OrderID";
        //        list = db.SetCommand(strSql, db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteList<Course>();
        //        return list;
        //    }
        //}

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

        public List<GetUnconfirmedOrderList_Model> getUnconfirmedOrderList(int customerId)
        {
            List<GetUnconfirmedOrderList_Model> list = new List<GetUnconfirmedOrderList_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = @"  SELECT [order].ID OrderID ,
                                                    TREATMENT.ID TreatmentID ,
                                                    0 ProductType ,
                                                    CONVERT(VARCHAR(16), SCHEDULE.ScheduleTime, 20) Time ,
                                                    ACCOUNT.Name AccountName ,
                                                    [order].Quantity ,
                                                    SERVICE.ServiceName ProductName ,
                                                    T4.ID AS BranchID ,
                                                    T4.BranchName
                                             FROM   TREATMENT
                                                    INNER JOIN ( SELECT *
                                                                 FROM   SCHEDULE
                                                                 WHERE  Type = 0
                                                                        AND Status = 2
                                                               ) SCHEDULE ON TREATMENT.SCHEDULEID = SCHEDULE.ID
                                                    LEFT JOIN ( SELECT  *
                                                                FROM    [ORDER]
                                                                WHERE   Status != 2
                                                                        AND CustomerID = @CustomerID
                                                                        AND ProductType = 0
                                                              ) [order] ON SCHEDULE.OrderID = [order].ID
                                                    LEFT JOIN ( SELECT  *
                                                                FROM    ACCOUNT
                                                                WHERE   Available = 1
                                                              ) ACCOUNT ON ACCOUNT.UserID = TREATMENT.ExecutorID
                                                    INNER JOIN SERVICE ON SERVICE.ID = [order].ProductID
                                                    RIGHT JOIN [BRANCH] T4 WITH ( NOLOCK ) ON [order].BranchID = T4.ID
                                             WHERE  [order].CreateTime >= T4.StartTime
                                             UNION ALL
                                             SELECT [order].ID OrderID ,
                                                    0 TreatmentID ,
                                                    1 ProductType ,
                                                    CONVERT(VARCHAR(16), [ORDER].CreateTime, 20) Time ,
                                                    NULL AccountName ,
                                                    [ORDER].Quantity ,
                                                    COMMODITY.CommodityName ProductName ,
                                                    T4.ID AS BranchID ,
                                                    T4.BranchName
                                             FROM   ( SELECT    *
                                                      FROM      [ORDER]
                                                      WHERE     CustomerID = @CustomerID
                                                                AND Status = 3
                                                                AND ProductType = 1
                                                    ) [ORDER]
                                                    INNER JOIN COMMODITY ON [ORDER].ProductID = COMMODITY.ID
                                                    RIGHT JOIN [BRANCH] T4 WITH ( NOLOCK ) ON [ORDER].BranchID = T4.ID
                                             WHERE  [ORDER].CreateTime >= T4.StartTime
                                             ORDER BY ProductType , Time DESC  ";

                list = db.SetCommand(strSql, db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteList<GetUnconfirmedOrderList_Model>();

                return list;
            }
        }

        public int getUnconfirmedOrderCount(int companyID, int customerId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  SUM(cnt)
                                    FROM    ( SELECT    COUNT(0) cnt
                                              FROM      [TBL_TREATGROUP] T1 WITH ( NOLOCK )
                                                        INNER JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T2.ID = T1.OrderServiceID
                                              WHERE     T2.CompanyID = @CompanyID
                                                        AND T2.CustomerID = @CustomerID
                                                        AND T1.TGStatus = 5
                                              UNION ALL
                                              SELECT    COUNT(0) cnt
                                              FROM      [TBL_COMMODITY_DELIVERY] T1 WITH ( NOLOCK )
                                                        INNER JOIN [TBL_ORDER_COMMODITY] T2 WITH ( NOLOCK ) ON T2.ID = T1.OrderObjectID
                                              WHERE     T2.CompanyID = @CompanyID
                                                        AND T2.CustomerID = @CustomerID
                                                        AND T1.Status = 5
                                            ) a
                                                             ";

                int count = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteScalar<int>();
                return count;
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
                                               OR T1.PaymentStatus = 0
                                             )
                                         AND T1.Status != 2
                                         AND T1.CustomerID = @CustomerID";

                int count = db.SetCommand(strSql, db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteScalar<int>();
                return count;
            }
        }

        public GetCourseAndTreatmentNumber_Model getCourseAndTreatmentNumber(int treatmentId)
        {
            GetCourseAndTreatmentNumber_Model model = new GetCourseAndTreatmentNumber_Model();
            using (DbManager db = new DbManager())
            {
                string strSql = @" select CourseCurrent.CourseNumber,TreatmentCurrent.TreatmentNumber,case( case(TreatmentTotal.TotalNumber - TreatmentCurrent.TreatmentNumber)when 0 then 1 else 0 END +case(CourseTotal.TotalNumber -CourseCurrent.CourseNumber) when 0 then 1 else 0 END ) when 2 then 1 else 0 END IsLast 
                                            from(select TreatmentTemp.TreatmentNumber from( select ROW_NUMBER() over(order by TREATMENT.ID) TreatmentNumber,TREATMENT.ID TreatmentID,TREATMENT.CourseID    from (select * from  TREATMENT where TREATMENT.Available = 1) TREATMENT  inner join SCHEDULE on TREATMENT.ScheduleID = SCHEDULE.ID   inner join (select * from  COURSE where COURSE.Available = 1) COURSE   on COURSE.ID = TREATMENT.CourseID   where TREATMENT.CourseID =(select TREATMENT.CourseID from TREATMENT where TREATMENT.ID = @TreatmentID)) TreatmentTemp where TreatmentTemp.TreatmentID = @TreatmentID )TreatmentCurrent 
                                            ,(select COUNT(*) TotalNumber,TREATMENT.CourseID from TREATMENT where TREATMENT.CourseID =(select TREATMENT.CourseID from TREATMENT where TREATMENT.ID = @TreatmentID )and TREATMENT.Available =1 group by CourseID )  TreatmentTotal  
                                            ,(select CourseTemp.CourseNumber from( select ROW_NUMBER() over(ORDER by COURSE.ID) CourseNumber,COURSE.ID CourseID,COURSE.OrderID from (SELECT * FROM COURSE    where OrderID = (select SCHEDULE.OrderID from SCHEDULE where SCHEDULE.ID = (select ScheduleID from TREATMENT where ID = @TreatmentID))) COURSE  WHERE COURSE.OrderID =(SELECT SCHEDULE.OrderID FROM SCHEDULE WHERE SCHEDULE.ID = (select  TREATMENT.ScheduleID from TREATMENT where TREATMENT.ID = @TreatmentID ))) CourseTemp where CourseTemp.CourseID =(select TREATMENT.CourseID from TREATMENT where TREATMENT.ID = @TreatmentID)) CourseCurrent 
                                            ,(select COUNT(*) TotalNumber,COURSE.OrderID from (SELECT * FROM COURSE WHERE COURSE.Available = 1 ) COURSE where COURSE.OrderID = (select SCHEDULE.OrderID from SCHEDULE where SCHEDULE.ID = (select TREATMENT.ScheduleID from TREATMENT where TREATMENT.ID = @TreatmentID)) group by OrderID ) CourseTotal    ";

                model = db.SetCommand(strSql, db.Parameter("@TreatmentID", treatmentId, DbType.Int32)).ExecuteObject<GetCourseAndTreatmentNumber_Model>();

                return model;
            }
        }

        public int selectOrderStatus(int orderId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"select Status from [ORDER] WHERE ID = @ID ";

                int status = db.SetCommand(strSql, db.Parameter("@ID", orderId, DbType.Int32)).ExecuteScalar<int>();

                if (status != 2)
                {
                    return 1;
                }
                else
                {
                    return 0;
                }
            }
        }

        public int selectTreatmentStatusForConfirm(int treatmentId)
        {

            using (DbManager db = new DbManager())
            {
                string strSql = @"select [ORDER].Status from [ORDER]
                                    inner join [SCHEDULE] on [ORDER].ID = [SCHEDULE].OrderID
                                    inner join [TREATMENT] on [SCHEDULE].ID =[TREATMENT].ScheduleID
                                    WHERE [TREATMENT].ID = @ID ";

                int status = db.SetCommand(strSql, db.Parameter("@ID", treatmentId, DbType.Int32)).ExecuteScalar<int>();

                if (status == 2)
                {
                    return 0;
                }

                string strSql2 = @"select [TREATMENT].Available,[SCHEDULE].Status
                                      from [TREATMENT] with (nolock)
                                      inner join [SCHEDULE] on [TREATMENT].ScheduleID = [SCHEDULE].ID
                                      WHERE [TREATMENT].ID =@ID";
                DataSet ds = db.SetCommand(strSql2, db.Parameter("@ID", treatmentId, DbType.Int32)).ExecuteDataSet();
                if (ds != null && ds.Tables[0].Rows.Count != 0)
                {
                    bool treatmentAvailable = StringUtils.GetDbBool(ds.Tables[0].Rows[0]["Available"]);
                    int scheduleStatus = StringUtils.GetDbInt(ds.Tables[0].Rows[0]["Status"]);
                    if (treatmentAvailable && scheduleStatus == 2)
                    {
                        return 1;
                    }
                    else
                    {
                        return 0;
                    }
                }

                return 0;
            }
        }

        public int confirmOrder(ConfirmOrderOperation_Model model)
        {

            using (DbManager db = new DbManager())
            {
                try
                {
                    string strSql = @"select count(*) from [USER] where ID =@UserID and Password =@PassWord ";

                    int count = db.SetCommand(strSql, db.Parameter("@UserID", model.CustomerID, DbType.Int32)
                                                    , db.Parameter("@Password", APICommon.Encrypt(model.Password), DbType.String)).ExecuteScalar<int>();

                    if (count == 0)
                    {
                        return 2;
                    }

                    db.BeginTransaction();
                    foreach (ConfirmOrderList item in model.OrderList)
                    {
                        if (item.ProductType == 1)
                        {
                            #region 完成商品订单
                            string strSqlUpdateOrder = @" update [ORDER] set Status=@Status,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime where ID=@ID AND Status = 3 ";

                            int updateRes = db.SetCommand(strSqlUpdateOrder, db.Parameter("@Status", 1, DbType.Int32)
                                                                           , db.Parameter("@UpdaterID", model.CustomerID, DbType.Int32)
                                                                           , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime)
                                                                           , db.Parameter("@ID", item.ID, DbType.Int32)).ExecuteNonQuery();
                            #endregion

                            if (updateRes <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                        }
                        else
                        {
                            #region 完成服务
                            string strSqlUpdateSchedule = @"update SCHEDULE set Status=@Status,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime where ID= (select ScheduleID from TREATMENT where ID = @ID)";
                            int updateScheduleRes = db.SetCommand(strSqlUpdateSchedule, db.Parameter("@Status", 1, DbType.Int32)
                                                                           , db.Parameter("@UpdaterID", model.CustomerID, DbType.Int32)
                                                                           , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime)
                                                                           , db.Parameter("@ID", item.TreatmentID, DbType.Int32)).ExecuteNonQuery();
                            #endregion

                            if (updateScheduleRes <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            #region 服务订单下所有服务都完成的情况下 订单也变成完成
                            string strSql2 = @" SELECT DISTINCT
                                                        CASE WHEN ( T4.CNT IS NULL
                                                                    OR T4.cnt = 0
                                                                  )
                                                                  AND T2.Status = 3 THEN 1
                                                             ELSE 0
                                                        END ChangeOrderStatus
                                                FROM    dbo.SCHEDULE T1
                                                        INNER JOIN dbo.[ORDER] T2 ON T1.OrderID = T2.ID
                                                                                     AND T2.ProductType = 0
                                                        LEFT JOIN ( SELECT  OrderID ,
                                                                            COUNT(*) cnt
                                                                    FROM    dbo.SCHEDULE
                                                                    WHERE   Status = 0 or status = 2 
                                                                    GROUP BY OrderID
                                                                  ) T4 ON T4.OrderID = T1.OrderID
                                                WHERE   T1.OrderID = @OrderID";
                            bool res = db.SetCommand(strSql2, db.Parameter("@OrderID", item.ID, DbType.Int32)).ExecuteScalar<bool>();
                            #endregion

                            if (res)
                            {
                                string strSqlUpdateOrder = @" update [ORDER] set Status=@Status,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime where ID=@ID AND Status = 3 ";

                                int updateRes = db.SetCommand(strSqlUpdateOrder, db.Parameter("@Status", 1, DbType.Int32)
                                                                               , db.Parameter("@UpdaterID", model.CustomerID, DbType.Int32)
                                                                               , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime)
                                                                               , db.Parameter("@ID", item.ID, DbType.Int32)).ExecuteNonQuery();
                                if (updateRes <= 0)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }
                            }
                        }

                    }

                    db.CommitTransaction();
                    return 1;
                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }

        }

        public bool addTreatment(TreatmentAddOperation_Model model)
        {
            bool res = false;
            using (DbManager db = new DbManager())
            {

                try
                {
                    string strOrderIdSql = @"select ID from [ORDER] where CustomerID =@CustomerID and ID = @OrderID  and Status =0";

                    int orderID = db.SetCommand(strOrderIdSql, db.Parameter("CustomerID", model.CustomerID, DbType.Int32)
                                                             , db.Parameter("OrderID", model.OrderID, DbType.Int32)).ExecuteScalar<int>();

                    if (orderID <= 0)
                    {
                        return res;
                    }

                    int forCount = 1;
                    string[] arrSubserviceIds = null;
                    if (!string.IsNullOrEmpty(model.SubServiceIDs))
                    {
                        //子服务
                        arrSubserviceIds = model.SubServiceIDs.Split(new string[] { "|" }, StringSplitOptions.RemoveEmptyEntries);
                        forCount = arrSubserviceIds.Length;
                    }
                    else
                    {
                        //套盒
                        forCount = 1;
                    }

                    long groupNo = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "TreatGroupCode", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<long>();

                    db.BeginTransaction();
                    for (int i = 0; i < forCount; i++)
                    {
                        object subServiceID = DBNull.Value;
                        if (arrSubserviceIds != null)
                        {
                            subServiceID = StringUtils.GetDbInt(arrSubserviceIds[i]);
                        }


                        string strAddSchedule = @"insert into SCHEDULE(CompanyID,OrderID,ServiceID,Type,Reminded,Status,CreatorID,CreateTime,SubServiceID)
                                              values ( @CompanyID,@OrderID,(select ProductID from [Order] where ID = @OrderID),(select ProductType from [Order] where ID = @OrderID),@Reminded,@Status,@CreatorID,@CreateTime,@SubServiceID);select @@IDENTITY";

                        int scheduleID = db.SetCommand(strAddSchedule, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                     , db.Parameter("@OrderID", model.OrderID, DbType.Int32)
                                                                     , db.Parameter("@Reminded", model.Reminded, DbType.Boolean)
                                                                     , db.Parameter("@Status", model.Status, DbType.Int32)
                                                                     , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                                     , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)
                                                                     , db.Parameter("@SubServiceID", subServiceID, DbType.Int32)).ExecuteScalar<int>();

                        if (scheduleID <= 0)
                        {
                            db.RollbackTransaction();
                            return res;
                        }

                        string strAddTreatment = @"insert into TREATMENT(CompanyID,CourseID,ScheduleID,Available,CreatorID,CreateTime,IsDesignated,GroupNo,BranchID)
                                                values (@CompanyID,@CourseID,@ScheduleID,@Available,@CreatorID,@CreateTime,@IsDesignated,@GroupNo,@BranchID);select @@IDENTITY";
                        int treatmentRes = db.SetCommand(strAddTreatment, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                     , db.Parameter("@CourseID", model.CourseID, DbType.Int32)
                                                                     , db.Parameter("@ScheduleID", scheduleID, DbType.Int32)
                                                                     , db.Parameter("@Available", true, DbType.Boolean)
                                                                     , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                                     , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)
                                                                     , db.Parameter("@IsDesignated", model.IsDesignated, DbType.Boolean)
                                                                     , db.Parameter("@GroupNo", groupNo, DbType.Int64)
                                                                     , db.Parameter("@BranchID", model.BranchID, DbType.Int64)).ExecuteNonQuery();
                        if (treatmentRes <= 0)
                        {
                            db.RollbackTransaction();
                            return res;
                        }
                    }

                    res = true;
                    db.CommitTransaction();
                    return res;
                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }

        //        public int deleteTreatment(TreatmentDelOperation_Model model)
        //        {
        //            int res = 0;
        //            using (DbManager db = new DbManager())
        //            {
        //                try
        //                {
        //                    if (model.Group == null)
        //                    {
        //                        return 0;
        //                    }

        //                    db.BeginTransaction();


        //                    if (model.Group.TreatmentList == null || model.Group.TreatmentList.Count <= 0)
        //                    {
        //                        db.RollbackTransaction();
        //                        return 0;
        //                    }

        //                    #region Check
        //                    int result = ChenckTreatment(model.Group, false);
        //                    if (result == 0)
        //                    {
        //                        db.RollbackTransaction();
        //                        return 0;
        //                    }
        //                    else if (result == -2)
        //                    {
        //                        db.RollbackTransaction();
        //                        return -2;
        //                    }
        //                    else if (result == -1)
        //                    {
        //                        db.RollbackTransaction();
        //                        return 0;
        //                    }
        //                    #endregion

        //                    List<Treatment> TreatmentList = new List<Treatment>();
        //                    TreatmentList = model.Group.TreatmentList;
        //                    if (TreatmentList == null && TreatmentList.Count <= 0)
        //                    {
        //                        db.RollbackTransaction();
        //                        return 0;
        //                    }

        //                    foreach (Treatment item in TreatmentList)
        //                    {
        //                        string strAddScheduleHis = @"insert into HISTORY_SCHEDULE 
        //                                                        select * from SCHEDULE [with rowlock]
        //                                                        where ID =@ID";

        //                        int scheduleHisRes = db.SetCommand(strAddScheduleHis, db.Parameter("@ID", item.ScheduleID, DbType.Int32)
        //                            , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteNonQuery();

        //                        if (scheduleHisRes <= 0)
        //                        {
        //                            db.RollbackTransaction();
        //                            return -1;
        //                        }

        //                        string strDelSchedule = "update SCHEDULE set Status=3,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime where ID=@ID";
        //                        int updateScheduleRes = db.SetCommand(strDelSchedule, db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
        //                                                                            , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
        //                                                                            , db.Parameter("@ID", item.ScheduleID, DbType.Int32)).ExecuteNonQuery();

        //                        if (updateScheduleRes <= 0)
        //                        {
        //                            db.RollbackTransaction();
        //                            return -1;
        //                        }

        //                        string strAddTreatmentHis = "insert into HISTORY_TREATMENT select * from TREATMENT [with rowlock] where ID =@ID";
        //                        int treatmentHisRes = db.SetCommand(strAddTreatmentHis, db.Parameter("@ID", item.TreatmentID, DbType.Int32)).ExecuteNonQuery();

        //                        if (treatmentHisRes <= 0)
        //                        {
        //                            db.RollbackTransaction();
        //                            return -1;
        //                        }

        //                        string strDelTreatment = @"update TREATMENT set  Available=0, UpdaterID=@UpdaterID, UpdateTime=@UpdateTime where ID=@ID";
        //                        int updateTreatmentRes = db.SetCommand(strDelTreatment, db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
        //                                                                              , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
        //                                                                              , db.Parameter("@ID", item.TreatmentID, DbType.Int32)).ExecuteNonQuery();

        //                        if (updateTreatmentRes <= 0)
        //                        {
        //                            db.RollbackTransaction();
        //                            return -1;
        //                        }
        //                    }


        //                    res = 1;
        //                    db.CommitTransaction();
        //                    return res;
        //                }
        //                catch
        //                {
        //                    db.RollbackTransaction();
        //                    throw;
        //                }
        //            }
        //        }

        //        public int ChenckTreatment(Group model, bool isNeedCheck = false)
        //        {
        //            using (DbManager db = new DbManager())
        //            {
        //                string strCheckOrderSql = @"SELECT  TOP 1 T3.Status
        //                                                  FROM    [TREATMENT] T1 WITH ( NOLOCK )
        //                                                            RIGHT JOIN [SCHEDULE] T2 WITH ( NOLOCK ) ON T1.ScheduleID = T2.ID
        //                                                            RIGHT JOIN [ORDER] T3 WITH ( NOLOCK ) ON T2.OrderID = T3.ID
        //                                                            WHERE T1.Available=1  AND T1.GroupNo=@GroupNo";

        //                GetOrderDetail_Model orderModel = db.SetCommand(strCheckOrderSql, db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)).ExecuteObject<GetOrderDetail_Model>();
        //                if (orderModel == null || orderModel.Status != 0)
        //                {
        //                    return -2;
        //                }

        //                int checkCount = 0;
        //                if (model.TreatmentList.Count > 1)
        //                {
        //                    #region 整组check
        //                    string strCheckSql = @"SELECT COUNT(0)
        //                                               FROM [TREATMENT] T1 WITH ( NOLOCK )
        //                                                    RIGHT JOIN [SCHEDULE] T2 WITH ( NOLOCK ) ON T1.ScheduleID = T2.ID
        //                                               WHERE T1.Available=1 AND T2.Status=0 AND T1.GroupNo=@GroupNo";
        //                    if (isNeedCheck)
        //                    {
        //                        strCheckSql += " AND ISNULL(T2.ScheduleTime,'')='' ";
        //                    }

        //                    checkCount = db.SetCommand(strCheckSql, db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)).ExecuteScalar<int>();
        //                    #endregion
        //                }
        //                else
        //                {
        //                    #region 单个check
        //                    string strCheckSql = @"SELECT  COUNT(0)
        //                                                    FROM    [TREATMENT] T1 WITH ( NOLOCK )
        //                                                            RIGHT JOIN [SCHEDULE] T2 WITH ( NOLOCK ) ON T1.ScheduleID = T2.ID
        //                                                    WHERE   T1.Available = 1
        //                                                            AND T2.Status = 0
        //                                                            AND T1.ScheduleID = @ScheduleID";

        //                    if (isNeedCheck)
        //                    {
        //                        strCheckSql += " AND ISNULL(T2.ScheduleTime,'')='' ";
        //                    }

        //                    checkCount = db.SetCommand(strCheckSql, db.Parameter("@ScheduleID", model.TreatmentList[0].ScheduleID, DbType.Int32)).ExecuteScalar<int>();
        //                    #endregion
        //                }

        //                if (checkCount <= 0)
        //                {
        //                    return -2;
        //                }

        //                if (checkCount != model.TreatmentList.Count)
        //                {
        //                    return -2;
        //                }

        //                return 1;

        //            }
        //        }

        public int selectScheduleStatus(int scheduleId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"select [TREATMENT].Available,[SCHEDULE].Status
                                      from [TREATMENT] with (nolock)
                                      inner join [SCHEDULE] on [TREATMENT].ScheduleID = [SCHEDULE].ID
                                      WHERE [TREATMENT].ScheduleID = @ID ";

                DataSet ds = db.SetCommand(strSql, db.Parameter("@ID", scheduleId, DbType.Int32)).ExecuteDataSet();

                if (ds != null && ds.Tables[0].Rows.Count != 0)
                {
                    bool treatmentAvailable = Convert.ToBoolean(ds.Tables[0].Rows[0]["Available"]);
                    int scheduleStatus = Convert.ToInt32(ds.Tables[0].Rows[0]["Status"]);
                    if (treatmentAvailable && scheduleStatus == 0)
                    {
                        return 1;
                    }
                    else
                    {
                        return 0;
                    }
                }
                else
                {
                    return 0;
                }
            }
        }

        public int CanCancelScheduleStatus(int scheduleId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"select Status from [ORDER] WHERE ID =( select OrderID from [SCHEDULE] where ID = @ID )";

                int status = db.SetCommand(strSql, db.Parameter("@ID", scheduleId, DbType.Int32)).ExecuteScalar<int>();

                if (status == 2)
                {
                    return 0;
                }

                string strSql2 = @"select [TREATMENT].ExecutorID,[SCHEDULE].ScheduleTime
                                      from [TREATMENT] with (nolock)
                                      inner join [SCHEDULE] on [TREATMENT].ScheduleID = [SCHEDULE].ID
                                      WHERE [TREATMENT].ScheduleID = @ID ";
                DataSet ds = db.SetCommand(strSql2, db.Parameter("@ID", scheduleId, DbType.Int32)).ExecuteDataSet();
                if (ds != null && ds.Tables[0].Rows.Count != 0)
                {
                    string ScheduleTime = StringUtils.GetDbString(ds.Tables[0].Rows[0]["ScheduleTime"]);
                    string ExecutorID = StringUtils.GetDbString(ds.Tables[0].Rows[0]["ExecutorID"]);
                    if (!string.IsNullOrEmpty(ScheduleTime) && !string.IsNullOrEmpty(ExecutorID))
                    {
                        return 1;
                    }
                    else
                    {
                        return 0;
                    }
                }
                else
                {
                    return 0;
                }
            }
        }

        //        public bool cancelTreatment(UtilityOperation_Model model)
        //        {
        //            using (DbManager db = new DbManager())
        //            {
        //                try
        //                {
        //                    db.BeginTransaction();

        //                    string strSqlCommond = @"insert into [HISTORY_SCHEDULE] 
        //                            select * from [SCHEDULE] [with rowlock]
        //                            where ID =@ID
        //                            and OrderID in(select ID from [ORDER] where CustomerID =@CustomerID and Status != 2) ;select @@IDENTITY";

        //                    int insertRes = db.SetCommand(strSqlCommond, db.Parameter("@ID", model.ScheduleID, DbType.Int32)
        //                        , db.Parameter("@UpdateTime", model.Time, DbType.DateTime)
        //                        , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteScalar<int>();

        //                    if (insertRes <= 0)
        //                    {
        //                        db.RollbackTransaction();
        //                        return false;
        //                    }

        //                    string strUpdateSql = "UPDATE [SCHEDULE] SET ScheduleTime=NULL,UpdaterID=@UpdaterID, UpdateTime=@UpdateTime WHERE ID=@ID AND Status=0";
        //                    int updateRes = db.SetCommand(strUpdateSql, db.Parameter("@ID", model.ScheduleID, DbType.Int32)
        //                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
        //                        , db.Parameter("@UpdateTime", model.Time, DbType.DateTime)).ExecuteNonQuery();

        //                    if (updateRes <= 0)
        //                    {
        //                        db.RollbackTransaction();
        //                        return false;
        //                    }

        //                    string strAddTreatmentSql = @"insert into [HISTORY_TREATMENT]
        //                                select * from [TREATMENT] [with rowlock]
        //                                where ID =@ID";
        //                    int addRes = db.SetCommand(strAddTreatmentSql, db.Parameter("@ID", model.TreatmentID, DbType.Int32)).ExecuteNonQuery();
        //                    if (addRes <= 0)
        //                    {
        //                        db.RollbackTransaction();
        //                        return false;
        //                    }

        //                    string strUpdateTreatmentSql = @"update [TREATMENT] set  ExecutorID=Null,IsDesignated=0, UpdaterID=@UpdaterID, UpdateTime=@UpdateTime 
        //                                                    where ID=@ID";
        //                    int updateTreatmentRes = db.SetCommand(strUpdateTreatmentSql, db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
        //                                                                                , db.Parameter("@UpdateTime", model.Time, DbType.DateTime)
        //                                                                                , db.Parameter("@ID", model.TreatmentID, DbType.Int32)).ExecuteNonQuery();

        //                    if (updateTreatmentRes <= 0)
        //                    {
        //                        db.RollbackTransaction();
        //                        return false;
        //                    }

        //                    db.CommitTransaction();
        //                    return true;

        //                }
        //                catch
        //                {
        //                    db.RollbackTransaction();
        //                    throw;
        //                }
        //            }

        //        }

        public bool updateTreatmentDetail(UtilityOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();

                    string strSqlCommond = @"update SCHEDULE set 
                        ScheduleTime=@ScheduleTime,
                        UpdaterID=@UpdaterID,
                        UpdateTime=@UpdateTime
                        where ID=@ID 
                        and OrderID in(select ID from [ORDER] where CustomerID =@CustomerID and Status != 2 )";

                    int res = db.SetCommand(strSqlCommond, db.Parameter("@ScheduleTime", model.ScheduleTime, DbType.DateTime)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", model.Time, DbType.DateTime)
                        , db.Parameter("@ID", model.ScheduleID, DbType.Int32)
                        , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteNonQuery();

                    if (res <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    string strUpdateSql = @"update TREATMENT set
                            ExecutorID=@ExecuotrID, 
                            UpdaterID=@UpdaterID, 
                            UpdateTime=@UpdateTime
                            where ID=@ID ";

                    int updateRes = db.SetCommand(strUpdateSql, db.Parameter("@ExecuotrID", model.ExecutorID, DbType.Int32)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", model.Time, DbType.DateTime)
                        , db.Parameter("@ID", model.TreatmentID, DbType.Int32)).ExecuteNonQuery();

                    if (updateRes <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
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


        public bool completeOrder(UtilityOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                try
                {
                    bool isPush = false;
                    #region 根据订单获取LoginMobile 散客没有登陆手机
                    string strSqlSelectCustomerLoginMobile = @"select [USER].LoginMobile  from [ORDER] 
                                                                   inner join [USER] on [ORDER].CustomerID =[user].ID 
                                                                   where [ORDER].ID = @OrderID";
                    string loginMobile = db.SetCommand(strSqlSelectCustomerLoginMobile, db.Parameter("@OrderID", model.OrderID, DbType.Int32)).ExecuteScalar<string>();
                    #endregion

                    bool isLoginMobileExist = false;
                    if (!string.IsNullOrEmpty(loginMobile))
                    {
                        isLoginMobileExist = true;
                    }

                    PaymentBranchRole paymentBranchRole = new PaymentBranchRole();
                    paymentBranchRole.IsCustomerConfirm = true;
                    paymentBranchRole.IsAccountEcardPay = false;

                    #region 获取权限
                    string strSqlCommand = @"select IsPay as IsAccountEcardPay,IsConfirmed as IsCustomerConfirm from [BRANCH] 
                                               where BRANCH.ID = @BranchID";

                    paymentBranchRole = db.SetCommand(strSqlCommand,
                                                    db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteObject<PaymentBranchRole>();
                    #endregion

                    if (paymentBranchRole == null)
                    {
                        return false;
                    }

                    PaymentProductType productTypeModel = new PaymentProductType();
                    productTypeModel.IsCommodityOrder = false;
                    productTypeModel.OnlyOneCourse = true;

                    #region 判断是否是商品订单,是不是只有一次服务
                    string strSqlProductType = @"select ProductType AS IsCommodityOrder ,Quantity from [ORDER] where ID =@OrderID";

                    productTypeModel = db.SetCommand(strSqlProductType, db.Parameter("@OrderID", model.OrderID, DbType.Int32)).ExecuteObject<PaymentProductType>();
                    #endregion

                    productTypeModel.OnlyOneCourse = productTypeModel.Quantity == 1 ? true : false;



                    int status = 0;//订单进行中
                    if (isLoginMobileExist)
                    {
                        #region 会员单
                        if (paymentBranchRole.IsCustomerConfirm)
                        {
                            #region 需要会员 确认订单的操作
                            if (productTypeModel.IsCommodityOrder)
                            {
                                #region 商品单
                                if (model.IsComplete)
                                {
                                    status = 3;//待客户确认
                                    isPush = true;//推送消息
                                }
                                else
                                {
                                    status = 0;
                                }
                                #endregion
                            }
                            else
                            {
                                #region 服务单
                                if (model.IsComplete)
                                {
                                    status = 1;//完成订单

                                    #region 订单下的SCHEDULE是否全部完成
                                    string strSqlScheduieStatus = @"SELECT COUNT(0) FROM [ORDER] T1
                                                                    LEFT JOIN [COURSE] T2 ON T2.OrderID=T1.ID AND T2.Available=1
                                                                    LEFT JOIN [TREATMENT] T3 ON T3.CourseID=T2.ID AND T3.Available=1
                                                                    LEFT JOIN [SCHEDULE] T4 ON T3.ScheduleID=T4.ID
                                                                    WHERE T1.ID=@OrderID AND (T4.Status=0 OR T4.Status=2)";
                                    int completeScheduieCount = db.SetCommand(strSqlScheduieStatus, db.Parameter("@OrderID", model.OrderID, DbType.Int32)).ExecuteScalar<int>();
                                    #endregion

                                    if (completeScheduieCount > 0)
                                    {
                                        // 还有SCHEDULE的状态为0:进行中 或 2:待客户确认
                                        status = 3;//待客户确认
                                    }
                                }
                                else
                                {
                                    status = 0;
                                }
                                #endregion
                            }

                            #endregion
                        }
                        else
                        {
                            #region 不需要确认
                            if (model.IsComplete)
                            {
                                status = 1;
                            }
                            else
                            {
                                status = 0;
                            }
                            #endregion
                        }
                        #endregion

                    }
                    else
                    {
                        #region 散客单
                        if (model.IsComplete)
                        {
                            status = 1;
                        }
                        else
                        {
                            status = 0;
                        }
                        #endregion
                    }

                    if (!productTypeModel.IsCommodityOrder)
                    {
                        #region 获取未完成服务的次数
                        string strSqlSelStatus = @"SELECT  COUNT(0)
                                                   FROM    SCHEDULE T1
                                                           INNER JOIN TREATMENT T2 ON T2.ScheduleID = T1.ID
                                                                                       AND T2.Available = 1
                                                           INNER JOIN COURSE T3 ON T3.ID = T2.CourseID
                                                   WHERE   T1.OrderID = @OrderID
                                                            AND T2.Available = 1
                                                            AND T3.Available = 1
                                                            AND T1.Status = 0 ";

                        int statusRes = db.SetCommand(strSqlSelStatus, db.Parameter("@OrderID", model.OrderID, DbType.Int32)).ExecuteScalar<int>();
                        if (statusRes > 0)
                        {
                            db.RollbackTransaction();
                            return false;
                        }
                        #endregion

                    }

                    #region 更新订单状态
                    string strSqlOrderUpt = @"update [ORDER] set UpdaterID = @UpdaterID, UpdateTime = @UpdateTime, Status = @Status where ID =@OrderID and CustomerID = @CustomerID  and Status != 2";
                    int orderuptRes = db.SetCommand(strSqlOrderUpt,
                        db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32),
                        db.Parameter("@Status", status, DbType.Int32),
                        db.Parameter("@UpdateTime", model.Time, DbType.DateTime),
                        db.Parameter("@OrderID", model.OrderID, DbType.Int32),
                        db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteNonQuery();
                    #endregion

                    #region 推送消息
                    //                    if (isPush)
                    //                    {
                    //                        Task.Factory.StartNew(() =>
                    //                        {

                    //                            string selectCustomerDevice = @"
                    //                                                            SELECT  T3.CommodityName,ISNULL(T2.DeviceID, '') AS DeviceID ,
                    //                                                                    T2.DeviceType
                    //                                                            FROM    dbo.[ORDER] T1 WITH ( NOLOCK )
                    //                                                                    LEFT JOIN dbo.LOGIN T2 WITH ( NOLOCK ) ON T1.CustomerID = T2.UserID
                    //                                                                    LEFT JOIN dbo.COMMODITY T3 WITH (NOLOCK) ON T3.ID = T1.ProductID  AND T1.ProductType = 1
                    //                                                            WHERE   T1.ID = @OrderID";

                    //                            PushOperation_Model pushmodel = db.SetCommand(selectCustomerDevice, db.Parameter("@OrderID", model.OrderID, DbType.Int32)).ExecuteObject<PushOperation_Model>();
                    //                            if (pushmodel != null)
                    //                            {
                    //                                if (!string.IsNullOrEmpty(pushmodel.DeviceID))
                    //                                {
                    //                                    try
                    //                                    {
                    //                                        HS.Framework.Common.Push.HSPush.pushMsg(pushmodel.DeviceID, pushmodel.DeviceType, 1, "您有一条商品订单需要确认!", Convert.ToBoolean(System.Configuration.ConfigurationManager.AppSettings["IsProduction"]), "1");
                    //                                    }
                    //                                    catch (Exception)
                    //                                    {
                    //                                        LogUtil.Log("push失败", "push确认商品订单失败,时间:" + DateTime.Now.ToLocalTime() + "订单ID:" + model.OrderID + ",DeviceID:" + pushmodel.DeviceID);
                    //                                    }
                    //                                }
                    //                                else
                    //                                {
                    //                                    LogUtil.Log("push失败", "订单ID为 " + model.OrderID + "的顾客DeviceID为空");
                    //                                }
                    //                            }
                    //                        });
                    //                    }
                    #endregion

                    if (orderuptRes <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
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

        public ObjectResult<bool> UpdateOrderIsAddUp(int orderID, bool isAddUp, int updaterID)
        {
            ObjectResult<bool> listres = new ObjectResult<bool>();
            listres.Code = "0";
            listres.Message = "";
            listres.Data = false;

            using (DbManager db = new DbManager())
            {
                try
                {
                    #region 查询订单详情
                    string strSqlCheckOrder = @"SELECT  T1.CompanyID,T1.BranchID,T1.ProductType ,T1.ProductType ,T1.Status ,T1.PaymentStatus ,[SCHEDULE].CNT,T1.Quantity,T2.Code AS ProductCode, T1.TotalSalePrice,T3.PaymentID
                                                FROM    [ORDER] T1 WITH ( NOLOCK )
                                                LEFT JOIN [COMMODITY] T2 ON T1.ProductID=T2.ID
                                                LEFT JOIN ( SELECT  COUNT(*) CNT , OrderID FROM    [SCHEDULE] WHERE   [SCHEDULE].Status != 0 and [SCHEDULE].Status != 3 GROUP BY OrderID ) [SCHEDULE] ON T1.ID = [SCHEDULE].OrderID
                                                LEFT JOIN dbo.TBL_OrderPayment_RelationShip T3 ON T3.OrderID = T1.ID
                                                WHERE   T1.ID = @ID";
                    OrderDelOperation_Model model = db.SetCommand(strSqlCheckOrder, db.Parameter("@ID", orderID, DbType.Int32)).ExecuteObject<OrderDelOperation_Model>();
                    #endregion

                    if (model == null)
                    {
                        listres.Code = "0";
                        listres.Message = "strSqlCheckOrder为空";
                        listres.Data = false;
                        return listres;
                    }

                    if (model.Status == 2 || model.Status == 3)
                    {
                        listres.Code = "2";
                        listres.Message = "订单已完成或已取消";
                        listres.Data = false;
                        return listres;
                    }
                    else if (model.PaymentStatus != 1 && model.PaymentStatus != 5)
                    {
                        listres.Code = "2";
                        listres.Message = "订单已支付不能修改";
                        listres.Data = false;
                        return listres;
                    }
                    else if (model.CNT > 0)
                    {
                        listres.Code = "3";
                        listres.Message = "服务订单有课程已完成或待客户确认";
                        listres.Data = false;
                        return listres;
                    }
                    else
                    {
                        db.BeginTransaction();

                        string strSqlInsertHis = @"Insert into [HISTORY_ORDER] select * from [ORDER] where ID = @OrderID";
                        int inserthisrs = db.SetCommand(strSqlInsertHis, db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteNonQuery();
                        if (inserthisrs <= 0)
                        {
                            db.RollbackTransaction();
                            listres.Code = "0";
                            listres.Message = "strSqlCheckOrder为空";
                            listres.Data = false;
                            return listres;
                        }

                        string strSqlUpdate = @"update [ORDER] set UpdaterID=@UpdaterID, IsAddUp=@IsAddUp where ID=@OrderID ";
                        int updaters = db.SetCommand(strSqlUpdate, db.Parameter("@UpdaterID", updaterID, DbType.Int32),
                                                                   db.Parameter("@IsAddUp", isAddUp, DbType.Boolean),
                                                                   db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteNonQuery();
                        if (updaters <= 0)
                        {
                            db.RollbackTransaction();
                            listres.Code = "0";
                            listres.Message = "strSqlUpdate失败";
                            listres.Data = false;
                            return listres;
                        }
                        db.CommitTransaction();
                        listres.Code = "1";
                        listres.Message = "success";
                        listres.Data = true;
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

        public bool completeTrearmentsByCourseID(CompleteTrearmentsByCourseIDOperation_Model model)
        {
            bool result = false;
            bool isPush = false;
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();
                    string strSqlCommand =
                                @"select [USER].LoginMobile ,( select [BRANCH].IsConfirmed 
                                  from BRANCH Where ID =@BranchID ) IsConfirmed
                                  from [USER] Where ID =@CustomerID";

                    DataTable dt = db.SetCommand(strSqlCommand, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32),
                                                               db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteDataTable();
                    if (dt != null)
                    {
                        #region 更新当前课程下未完成、未取消、没有预约时间的服务状态
                        strSqlCommand = @"UPDATE  T1
                                            SET     T1.Status = @Status,
                                            		T1.UpdaterID = @UpdaterID,
                                            		T1.UpdateTime = @UpdateTime,
                                            		T1.FinishTime = @FinishTime
                                            FROM    dbo.SCHEDULE T1
                                                    INNER JOIN dbo.TREATMENT T2 ON T1.ID = T2.ScheduleID AND T2.Available = 1
                                                    INNER JOIN dbo.COURSE T3 ON T3.ID = T2.CourseID AND T3.Available = 1
                                            WHERE   T3.ID = @CourseID
                                                    AND T3.Available = 1
                                                    AND T1.ScheduleTime IS NOT NULL
                                                    AND T1.Status <> 1 AND T1.Status <> 3";

                        bool isComplete = (Object.Equals(dt.Rows[0]["LoginMobile"], DBNull.Value))
                           || (!Object.Equals(dt.Rows[0]["LoginMobile"], DBNull.Value) && !Convert.ToBoolean(dt.Rows[0]["IsConfirmed"]));
                        // 如果顾客是散客 或分店已被授权 则将服务改为已完成
                        if (isComplete)
                        {
                            model.Status = 1;
                            model.FinishTime = DateTime.Now.ToLocalTime();
                        }
                        // 如果顾客不是散客且分店未被授权 则将服务改为待确认
                        else
                        {
                            isPush = true;
                            model.Status = 2;
                            model.FinishTime = null;
                        }
                        int rows = db.SetCommand(strSqlCommand, db.Parameter("@Status", model.Status, DbType.Int32)
                               , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                               , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                               , db.Parameter("@FinishTime", model.FinishTime, DbType.DateTime2)
                               , db.Parameter("@CourseID", model.CourseID, DbType.Int32)).ExecuteNonQuery();
                        #endregion
                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                        }
                        else
                        {
                            //                            string strSqlGetCourseCount = @"SELECT COUNT(*) cnt 
                            //                                                                    FROM dbo.COURSE 
                            //                                                                    WHERE OrderID = @OrderID 
                            //                                                                    AND Available = 1 
                            //                                                                    GROUP BY OrderID";

                            //                            int courseCount = db.SetCommand(strSqlGetCourseCount, db.Parameter("@OrderID", model.OrderID, DbType.Int32)).ExecuteScalar<int>();
                            //                            if (courseCount == 1)
                            //                            {

                            #region 获取没有完成的服务次数
                            string strSqlSelStatus = @"SELECT  COUNT(*)
                                            FROM    dbo.SCHEDULE T1 
                                                    INNER JOIN [ORDER] T2 ON T2.ID = T1.OrderID  
                                                    INNER JOIN [TREATMENT] T3 ON T1.ID = T3.ScheduleID AND T3.Available =1 
                                            WHERE   T2.ID = @OrderID
                                                    AND T1.Status = 0 ";

                            int statusRes = db.SetCommand(strSqlSelStatus, db.Parameter("@OrderID", model.OrderID, DbType.Int32)).ExecuteScalar<int>();
                            #endregion
                            #region 所有服务都已完成或待客户确认时 订单的状态改变
                            if (statusRes == 0)
                            {
                                string strSqlOrderUpt = @"update [ORDER] set UpdaterID = @UpdaterID, 
                                                                        UpdateTime = @UpdateTime, 
                                                                        FinishTime = @FinishTime, 
                                                                        Status = @Status 
                                                                        WHERE ID =@OrderID 
                                                                        and Status != 2 
                                                                        and CustomerID = @CustomerID  ";

                                //订单状态 0:未完成、1:已完成、2:已取消、3:待确认
                                if (isComplete)
                                {
                                    model.Status = 1;
                                    model.FinishTime = DateTime.Now.ToLocalTime();
                                }
                                else
                                {
                                    model.Status = 3;
                                    model.FinishTime = null;
                                }

                                rows = db.SetCommand(strSqlOrderUpt, db.Parameter("@Status", model.Status, DbType.Int32)
                               , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                               , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                               , db.Parameter("@FinishTime", model.FinishTime, DbType.DateTime2)
                               , db.Parameter("@OrderID", model.OrderID, DbType.Int32)
                               , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteNonQuery();

                                if (rows == 0)
                                {
                                    db.RollbackTransaction();
                                    result = false;
                                }
                                else
                                {
                                    db.CommitTransaction();
                                    result = true;
                                }
                            }
                            else
                            {
                                //}
                                db.CommitTransaction();
                                result = true;
                            }
                            #endregion

                            #region 推送
                            if (isPush && result)
                            {
                                string SelectPushTargets = @"SELECT  top 1 T7.Abbreviation ,
                                                                        ISNULL(T5.DeviceID, '') AS DeviceID ,
                                                                        T5.DeviceType ,
                                                                        T6.ServiceName ,
                                                                        T3.ScheduleTime
                                                                FROM    dbo.COURSE T1 
                                                                INNER JOIN dbo.TREATMENT T2 ON T1.ID = T2.CourseID AND T2.Available = 1
                                                                INNER JOIN dbo.SCHEDULE T3 WITH ( NOLOCK ) ON T3.id = T2.ScheduleID AND T3.Status = 2
                                                                        INNER JOIN dbo.[ORDER] T4 WITH ( NOLOCK ) ON T1.OrderID = T4.ID
                                                                        LEFT JOIN dbo.LOGIN T5 WITH ( NOLOCK ) ON T4.CustomerID = T5.UserID
                                                                        LEFT JOIN dbo.SERVICE T6 WITH ( NOLOCK ) ON T6.ID = T4.ProductID
                                                                                                                     AND T4.ProductType = 0
                                                                        INNER JOIN dbo.COMPANY T7 WITH ( NOLOCK ) ON T4.CompanyID = T7.ID
                                                                WHERE   T1.ID = @CourseID";

                                PushOperation_Model PushTaget = db.SetCommand(SelectPushTargets, db.Parameter("@CourseID", model.CourseID, DbType.Int32)).ExecuteObject<PushOperation_Model>();

                                if (PushTaget != null)
                                {
                                    Task.Factory.StartNew(() =>
                                    {
                                        if (!string.IsNullOrWhiteSpace(PushTaget.DeviceID))
                                        {
                                            try
                                            {
                                                HS.Framework.Common.Push.HSPush.pushMsg(PushTaget.DeviceID, PushTaget.DeviceType, 0, string.Format("您在{0}的服务{1}{2}已完成，请确认。", PushTaget.Abbreviation, PushTaget.ServiceName, PushTaget.ScheduleTime.ToString()), Convert.ToBoolean(System.Configuration.ConfigurationManager.AppSettings["IsProduction"]), "5");
                                            }
                                            catch (Exception)
                                            {
                                                LogUtil.Log("push失败", model.CustomerID + "push确认服务失败,时间:" + DateTime.Now.ToLocalTime() + "CourseID:" + model.CourseID + ",DeviceID:" + PushTaget.DeviceID);
                                            }
                                        }
                                        else
                                        {
                                            LogUtil.Log("push失败", model.CustomerID + "的美容师ID为 " + PushTaget.AccountID + "的DeviceID为空");
                                        }

                                    });
                                }
                            }
                            #endregion
                        }
                    }
                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
                return result;
            }
        }


        //        public int completeBeforeTreatmentByGroupNO(CompleteTrearmentsByCourseIDOperation_Model model)
        //        {
        //            using (DbManager db = new DbManager())
        //            {
        //                if (model.Group == null)
        //                {
        //                    return 0;
        //                }
        //                db.BeginTransaction();

        //                List<Treatment> TreatmentList = new List<Treatment>();
        //                TreatmentList = model.Group.TreatmentList;
        //                if (TreatmentList == null && TreatmentList.Count <= 0)
        //                {
        //                    db.RollbackTransaction();
        //                    return 0;
        //                }

        //                #region Check
        //                int result = ChenckTreatment(model.Group, false);
        //                if (result == 0)
        //                {
        //                    db.RollbackTransaction();
        //                    return 0;
        //                }
        //                else if (result == -2)
        //                {
        //                    db.RollbackTransaction();
        //                    return -2;
        //                }
        //                else if (result == -1)
        //                {
        //                    db.RollbackTransaction();
        //                    return 0;
        //                }
        //                #endregion

        //                foreach (var item in TreatmentList)
        //                {
        //                    string strUpdateSql = @"UPDATE  T1
        //                                                    SET     T1.Status = @Status ,
        //                                                            T1.UpdaterID = @UpdaterID ,
        //                                                            T1.UpdateTime = @UpdateTime ,
        //                                                            T1.FinishTime = @FinishTime
        //                                                    FROM    dbo.SCHEDULE T1
        //                                                            INNER JOIN dbo.TREATMENT T2 ON T1.ID = T2.ScheduleID
        //                                                                                           AND T2.Available = 1
        //                                                    WHERE   T2.ScheduleID = @ScheduleID
        //                                                            AND T2.Available = 1                                                            
        //                                                            AND T1.Status =0";

        //                    int rows = db.SetCommand(strUpdateSql, db.Parameter("@Status", 4, DbType.Int32)
        //                       , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
        //                       , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
        //                       , db.Parameter("@FinishTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
        //                       , db.Parameter("@ScheduleID", item.ScheduleID, DbType.Int32)).ExecuteNonQuery();

        //                    if (rows <= 0)
        //                    {
        //                        db.RollbackTransaction();
        //                        return -2;
        //                    }
        //                }

        //                db.CommitTransaction();
        //                return 1;
        //            }

        //        }

        //        public int completeTreatmentByGroupNO(CompleteTrearmentsByCourseIDOperation_Model model)
        //        {
        //            bool isPush = false;
        //            int res = 0;
        //            using (DbManager db = new DbManager())
        //            {
        //                try
        //                {
        //                    if (model.Group == null)
        //                    {
        //                        return 0;
        //                    }

        //                    db.BeginTransaction();


        //                    if (model.Group.TreatmentList == null || model.Group.TreatmentList.Count <= 0)
        //                    {
        //                        db.RollbackTransaction();
        //                        return 0;
        //                    }

        //                    #region Check
        //                    int result = ChenckTreatment(model.Group, false);
        //                    if (result == 0)
        //                    {
        //                        db.RollbackTransaction();
        //                        return 0;
        //                    }
        //                    else if (result == -2)
        //                    {
        //                        db.RollbackTransaction();
        //                        return -2;
        //                    }
        //                    else if (result == -1)
        //                    {
        //                        db.RollbackTransaction();
        //                        return 0;
        //                    }
        //                    #endregion

        //                    List<Treatment> TreatmentList = new List<Treatment>();
        //                    TreatmentList = model.Group.TreatmentList;
        //                    if (TreatmentList == null && TreatmentList.Count <= 0)
        //                    {
        //                        db.RollbackTransaction();
        //                        return 0;
        //                    }


        //                    string strSqlCommand = @"select [USER].LoginMobile ,( select [BRANCH].IsConfirmed 
        //                                  from BRANCH Where ID =@BranchID ) IsConfirmed
        //                                  from [USER] Where ID =@CustomerID";

        //                    DataTable dt = db.SetCommand(strSqlCommand, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32),
        //                                                               db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteDataTable();
        //                    if (dt != null)
        //                    {
        //                        #region 更新当前课程下未完成、未取消、没有预约时间的服务状态
        //                        bool isComplete = (Object.Equals(dt.Rows[0]["LoginMobile"], DBNull.Value))
        //                           || (!Object.Equals(dt.Rows[0]["LoginMobile"], DBNull.Value) && !Convert.ToBoolean(dt.Rows[0]["IsConfirmed"]));
        //                        // 如果顾客是散客 或分店已被授权 则将服务改为已完成
        //                        if (isComplete)
        //                        {
        //                            model.Status = 1;
        //                            model.FinishTime = DateTime.Now.ToLocalTime();
        //                        }
        //                        // 如果顾客不是散客且分店未被授权 则将服务改为待确认
        //                        else
        //                        {
        //                            isPush = true;
        //                            model.Status = 2;
        //                            model.FinishTime = null;
        //                        }

        //                        db.BeginTransaction();

        //                        foreach (var item in TreatmentList)
        //                        {
        //                            string strUpdateSql = @"UPDATE  T1
        //                                                    SET     T1.Status = @Status ,
        //                                                            T1.UpdaterID = @UpdaterID ,
        //                                                            T1.UpdateTime = @UpdateTime ,
        //                                                            T1.FinishTime = @FinishTime
        //                                                    FROM    dbo.SCHEDULE T1
        //                                                            INNER JOIN dbo.TREATMENT T2 ON T1.ID = T2.ScheduleID
        //                                                                                           AND T2.Available = 1
        //                                                    WHERE   T2.ScheduleID = @ScheduleID
        //                                                            AND T2.Available = 1
        //                                                            AND ISNULL(T1.ScheduleTime,'') <> '' 
        //                                                            AND T1.Status =0";

        //                            int rows = db.SetCommand(strUpdateSql, db.Parameter("@Status", model.Status, DbType.Int32)
        //                               , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
        //                               , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
        //                               , db.Parameter("@FinishTime", model.FinishTime, DbType.DateTime2)
        //                               , db.Parameter("@ScheduleID", item.ScheduleID, DbType.Int32)).ExecuteNonQuery();

        //                            if (rows <= 0)
        //                            {
        //                                db.RollbackTransaction();
        //                                return -2;
        //                            }
        //                        }

        //                        res = 1;
        //                        #endregion

        //                        db.CommitTransaction();

        //                        #region 获取没有完成的服务次数
        //                        //                        string strSqlSelStatus = @"SELECT  COUNT(*)
        //                        //                                            FROM    dbo.SCHEDULE T1 
        //                        //                                                    INNER JOIN [ORDER] T2 ON T2.ID = T1.OrderID  
        //                        //                                                    INNER JOIN [TREATMENT] T3 ON T1.ID = T3.ScheduleID AND T3.Available =1 
        //                        //                                            WHERE   T2.ID = @OrderID
        //                        //                                                    AND T1.Status = 0 ";

        //                        //                        int statusRes = db.SetCommand(strSqlSelStatus, db.Parameter("@OrderID", model.OrderID, DbType.Int32)).ExecuteScalar<int>();
        //                        #endregion

        //                        #region 所有服务都已完成或待客户确认时 订单的状态改变
        //                        //                        if (statusRes == 0)
        //                        //                        {
        //                        //                            string strSqlOrderUpt = @"update [ORDER] set UpdaterID = @UpdaterID, 
        //                        //                                                                        UpdateTime = @UpdateTime, 
        //                        //                                                                        FinishTime = @FinishTime, 
        //                        //                                                                        Status = @Status 
        //                        //                                                                        WHERE ID =@OrderID 
        //                        //                                                                        and Status != 2 
        //                        //                                                                        and CustomerID = @CustomerID  ";

        //                        //                            //订单状态 0:未完成、1:已完成、2:已取消、3:待确认
        //                        //                            if (isComplete)
        //                        //                            {
        //                        //                                model.Status = 1;
        //                        //                                model.FinishTime = DateTime.Now.ToLocalTime();
        //                        //                            }
        //                        //                            else
        //                        //                            {
        //                        //                                model.Status = 3;
        //                        //                                model.FinishTime = null;
        //                        //                            }

        //                        //                           int rows = db.SetCommand(strSqlOrderUpt, db.Parameter("@Status", model.Status, DbType.Int32)
        //                        //                           , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
        //                        //                           , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
        //                        //                           , db.Parameter("@FinishTime", model.FinishTime, DbType.DateTime2)
        //                        //                           , db.Parameter("@OrderID", model.OrderID, DbType.Int32)
        //                        //                           , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteNonQuery();

        //                        //                            if (rows <= 0)
        //                        //                            {
        //                        //                                db.RollbackTransaction();
        //                        //                                return 0;
        //                        //                            }
        //                        //                            else
        //                        //                            {
        //                        //                                db.CommitTransaction();
        //                        //                                res = 1;
        //                        //                            }
        //                        //                        }
        //                        //                        else
        //                        //                        {
        //                        //                            db.CommitTransaction();
        //                        //                            res = 1;
        //                        //                        }
        //                        #endregion

        //                        #region 推送
        //                        if (isPush && res == 1)
        //                        {
        //                            string SelectPushTargets = @"SELECT  top 1 T7.Abbreviation ,
        //                                                                        ISNULL(T5.DeviceID, '') AS DeviceID ,
        //                                                                        T5.DeviceType ,
        //                                                                        T6.ServiceName ,
        //                                                                        T3.ScheduleTime
        //                                                                FROM    TREATMENT T2 
        //                                                                INNER JOIN dbo.SCHEDULE T3 WITH ( NOLOCK ) ON T3.id = T2.ScheduleID AND T3.Status = 2
        //                                                                        INNER JOIN dbo.[ORDER] T4 WITH ( NOLOCK ) ON T3.OrderID = T4.ID
        //                                                                        LEFT JOIN dbo.LOGIN T5 WITH ( NOLOCK ) ON T4.CustomerID = T5.UserID
        //                                                                        LEFT JOIN dbo.SERVICE T6 WITH ( NOLOCK ) ON T6.ID = T4.ProductID AND T4.ProductType = 0
        //                                                                        INNER JOIN dbo.COMPANY T7 WITH ( NOLOCK ) ON T4.CompanyID = T7.ID
        //                                                                WHERE   T2.GroupNO = @GroupNO AND T2.Available = 1";

        //                            PushOperation_Model PushTaget = db.SetCommand(SelectPushTargets, db.Parameter("@GroupNO", model.Group.GroupNo, DbType.Int64)).ExecuteObject<PushOperation_Model>();

        //                            if (PushTaget != null)
        //                            {
        //                                Task.Factory.StartNew(() =>
        //                                {
        //                                    if (!string.IsNullOrWhiteSpace(PushTaget.DeviceID))
        //                                    {
        //                                        try
        //                                        {
        //                                            HS.Framework.Common.Push.HSPush.pushMsg(PushTaget.DeviceID, PushTaget.DeviceType, 0, string.Format("您在{0}的服务{1}{2}已完成，请确认。", PushTaget.Abbreviation, PushTaget.ServiceName, PushTaget.ScheduleTime.ToString("MM-dd")), Convert.ToBoolean(System.Configuration.ConfigurationManager.AppSettings["IsProduction"]), "5");
        //                                        }
        //                                        catch (Exception)
        //                                        {
        //                                            LogUtil.Log("push失败", model.CustomerID + "push确认服务失败,时间:" + DateTime.Now.ToLocalTime() + "CourseID:" + model.CourseID + ",DeviceID:" + PushTaget.DeviceID);
        //                                        }
        //                                    }
        //                                    else
        //                                    {
        //                                        LogUtil.Log("push失败", model.CustomerID + "的美容师ID为 " + PushTaget.AccountID + "的DeviceID为空");
        //                                    }

        //                                });
        //                            }
        //                        }

        //                        #endregion

        //                        return res;

        //                    }
        //                    else
        //                    {
        //                        return 0;
        //                    }
        //                }
        //                catch
        //                {
        //                    db.RollbackTransaction();
        //                    throw;
        //                }
        //            }
        //        }



        public GetEcardInfo_Model getEcardInfo(int customerId)
        {
            GetEcardInfo_Model model = new GetEcardInfo_Model();
            using (DbManager db = new DbManager())
            {
                string strSql = @" select ISNULL(T1.ExpirationDate,'2099-12-31') AS ExpirationDate, T3.Balance, T2.ID LevelID,T2.LevelName, T2.Discount,T4.IsShowECardHis 
                                       From CUSTOMER T1 
                                       LEFT JOIN [LEVEL] T2 on T2.ID = T1.LevelID 
                                       LEFT JOIN (select top 1 CustomerID,Balance from BALANCE where CustomerID = @CustomerID and Available = 1 order by ID desc) T3 on T3.CustomerID = T1.UserID 
                                       LEFT JOIN BRANCH T4 WITH(NOLOCK) ON T1.BranchID=T4.ID 
                                       WHERE  UserID = @CustomerID ";

                model = db.SetCommand(strSql, db.Parameter("@CustomerID", customerId, DbType.Int32)).ExecuteObject<GetEcardInfo_Model>();

                return model;
            }
        }







        ////////////////////////////////////////////////////////////////////////////////////////////////////////////



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
                                    WHERE  T5.Available = 1 AND T1.CreateTime >= T6.StartTime AND T1.CompanyID = @CompanyID ";

                    if (operationModel.BranchID > 0)
                    {
                        strSql += " AND T1.BranchID = @BranchID";
                    }

                    if (operationModel.CustomerID > 0)
                    {
                        strSql += " AND T1.CustomerID = @CustomerID";
                    }

                    if (operationModel.OrderID > 0)
                    {
                        strSql += @" AND T1.ID = @OrderID";
                    }
                    else
                    {
                        if (operationModel.ResponsiblePersonIDs != null && operationModel.ResponsiblePersonIDs.Count > 0)
                        {
                            strSql += @" AND T1.ID IN (
                                    SELECT  [ORDER].ID
                                    FROM    [ORDER]
                                            INNER JOIN [TBL_BUSINESS_CONSULTANT] ON [ORDER].ID = [TBL_BUSINESS_CONSULTANT].MasterID
                                    WHERE   [TBL_BUSINESS_CONSULTANT].ConsultantID IN ( ";

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
                            strSql += " )) ";
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

                        if (operationModel.OrderSource >= 0)
                        {
                            strSql += " AND T1.OrderSource = @OrderSource ";
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

                        if (!string.IsNullOrEmpty(operationModel.ProductName))
                        {
                            strSql += @" AND ( T3.ServiceName LIKE '%' + @ProductName + '%'
                                              OR T4.CommodityName LIKE '%' + @ProductName + '%'
                                            ) ";
                        }
                    }

                    string strCountSql = string.Format(strSql, " count(0) ");

                    string strgetListSql = "select * from( " + string.Format(strSql, fileds) + " ) a where  rowNum between  " + ((pageIndex - 1) * pageSize + 1) + " and " + pageIndex * pageSize;

                    recordCount = db.SetCommand(strCountSql
                        , db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)
                        , db.Parameter("@OrderID", operationModel.OrderID, DbType.Int32)
                        , db.Parameter("@AccountID", operationModel.AccountID, DbType.Int32)
                        , db.Parameter("@BranchID", operationModel.BranchID, DbType.Int32)
                        , db.Parameter("@CreateTime", operationModel.CreateTime, DbType.DateTime)
                        , db.Parameter("@Status", operationModel.Status, DbType.Int32)
                        , db.Parameter("@OrderSource", operationModel.OrderSource, DbType.Int32)
                        , db.Parameter("@ProductName", operationModel.ProductName, DbType.String)
                        , db.Parameter("@CustomerID", operationModel.CustomerID, DbType.Int32)).ExecuteScalar<int>();

                    if (recordCount < 0)
                    {
                        return null;
                    }

                    list = db.SetCommand(strgetListSql
                        , db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)
                        , db.Parameter("@OrderID", operationModel.OrderID, DbType.Int32)
                        , db.Parameter("@AccountID", operationModel.AccountID, DbType.Int32)
                        , db.Parameter("@BranchID", operationModel.BranchID, DbType.Int32)
                        , db.Parameter("@CreateTime", operationModel.CreateTime, DbType.DateTime)
                        , db.Parameter("@OrderSource", operationModel.OrderSource, DbType.Int32)
                        , db.Parameter("@Status", operationModel.Status, DbType.Int32)
                        , db.Parameter("@ProductName", operationModel.ProductName, DbType.String)
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
                                T3.ID AS OrderObjectID ,
                                T11.IsConfirmed,
                                T12.AppointmentMustPaid
                        FROM    [ORDER] T1 WITH ( NOLOCK )
                                LEFT JOIN [TBL_ORDER_SERVICE] T3 WITH ( NOLOCK ) ON T1.ID = T3.OrderID
                                LEFT JOIN [CUSTOMER] T5 WITH ( NOLOCK ) ON T1.CustomerID = T5.UserID
                                LEFT JOIN [ACCOUNT] T6 WITH ( NOLOCK ) ON T6.UserID = T1.CreatorID
                                LEFT JOIN [BRANCH] T10 WITH ( NOLOCK ) ON T1.BranchID = T10.ID 
                                LEFT JOIN [SERVICE] T11 WITH(NOLOCK) ON T3.ServiceID=T11.ID 
                                LEFT JOIN [COMPANY] T12 WITH(NOLOCK) ON T1.CompanyID=T12.ID
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
                                T3.ID AS OrderObjectID, 
                                T11.IsConfirmed
                        FROM    [ORDER] T1 WITH ( NOLOCK )
                                LEFT JOIN [TBL_ORDER_COMMODITY] T3 WITH ( NOLOCK ) ON T1.ID = T3.OrderID
                                LEFT JOIN [CUSTOMER] T5 WITH ( NOLOCK ) ON T1.CustomerID = T5.UserID
                                LEFT JOIN [ACCOUNT] T6 WITH ( NOLOCK ) ON T6.UserID = T1.CreatorID
                                LEFT JOIN [BRANCH] T10 WITH ( NOLOCK ) ON T1.BranchID = T10.ID 
                                LEFT JOIN [COMMODITY] T11 WITH(NOLOCK) ON T3.CommodityID=T11.ID
                                WHERE T1.CompanyID=@CompanyID AND T3.ID = @orderObjectID AND T1.ProductType = @ProductType";
                }

                model = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                , db.Parameter("@orderObjectID", orderObjectID, DbType.Int32)
                , db.Parameter("@ProductType", productType, DbType.Int32)).ExecuteObject<GetOrderDetail_Model>();

                if (model != null && model.OrderID > 0)
                {
                    #region 是否有支付过的信息
                    model.IsMergePay = false;
                    string strSelPaymentIDSql = @" SELECT PaymentID FROM  [TBL_ORDERPAYMENT_RELATIONSHIP] WITH(NOLOCK) WHERE OrderID=@OrderID ";
                    List<int> paymentIDList = db.SetCommand(strSelPaymentIDSql
                                , db.Parameter("@OrderID", model.OrderID, DbType.Int32)).ExecuteScalarList<int>();

                    if (paymentIDList != null && paymentIDList.Count >= 0)
                    {
                        #region 合并支付的订单不能退款
                        foreach (int paymentID in paymentIDList)
                        {
                            string strSelOrderCountSql = " SELECT COUNT(0) FROM  [TBL_ORDERPAYMENT_RELATIONSHIP] WITH(NOLOCK) WHERE PaymentID=@PaymentID ";
                            int orderCount = db.SetCommand(strSelOrderCountSql
                                    , db.Parameter("@PaymentID", paymentID, DbType.Int32)).ExecuteScalar<int>();

                            if (orderCount > 1)
                            {
                                model.IsMergePay = true;
                            }
                        }
                        #endregion
                    }
                    #endregion

                    #region 是否有第三方支付
                    string strCountSql = @" SELECT COUNT(0) FROM  [TBL_NETTRADE_ORDER] WHERE CompanyID=@CompanyID AND OrderID=@OrderID ";
                    int count = db.SetCommand(strCountSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                , db.Parameter("@OrderID", model.OrderID, DbType.Int32)).ExecuteScalar<int>();

                    model.HasNetTrade = count > 0 ? true : false;
                    #endregion

                    #region 获取美丽顾问/销售顾问
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
                    #endregion

                    #region 获取使用的优惠券
                    string strOrderBenefitSql = @" SELECT  T2.PolicyID ,
                                                            T2.PolicyName ,
                                                            T2.PRCode ,
                                                            T2.PRValue1 ,
                                                            T2.PRValue2 ,
                                                            T2.PRValue3 ,
                                                            T2.PRValue4
                                                    FROM    [TBL_CUSTOMER_BENEFIT] T1 WITH ( NOLOCK )
                                                            LEFT JOIN [TBL_BENEFIT_POLICY] T2 ON T1.PolicyID = T2.PolicyID
                                                    WHERE   T1.UserID = @CustomerID
                                                            AND T1.CompanyID = @CompanyID
                                                            AND T1.OrderID = @OrderID ";
                    model.BenefitList = db.SetCommand(strOrderBenefitSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                      , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                      , db.Parameter("@OrderID", model.OrderID, DbType.Int32)).ExecuteList<OrderBenefit_Model>();

                    #endregion
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
                                        1 AS Quantity ,
                                        '' AS ThumbnailURL  
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

                    strSql += " ORDER BY T1.TGStartTime desc";
                }
                else
                {
                    strSql = @"SELECT  ISNULL(T2.Name,'') AS ServicePicName ,
                                        T1.ServicePIC AS ServicePicID ,
                                        T1.ID AS GroupNo ,
                                        0 AS IsDesignated,
                                        Status ,
                                        T1.CDStartTime AS StartTime ,
                                        T1.Quantity ,"
                                        + Common.Const.strHttp
                                        + Common.Const.server
                                        + Common.Const.strMothod
                                        + Common.Const.strSingleMark
                                        + "  + cast(T3.CompanyID as nvarchar(10)) + "
                                        + Common.Const.strSingleMark
                                        + "/Sign/"
                                        + Common.Const.strSingleMark
                                        + "  + cast(T3.CustomerID as nvarchar(16)) + "
                                        + Common.Const.strSingleMark
                                        + "/"
                                        + Common.Const.strSingleMark
                                        + "  + cast(T3.GroupNo as nvarchar(18))+ "
                                        + Common.Const.strSingleMark
                                        + "/"
                                        + Common.Const.strSingleMark
                                        + "+ T3.FileName +"
                                        + Common.Const.strThumb
                                        + " ThumbnailURL "
                               + @" FROM    [TBL_COMMODITY_DELIVERY] T1 WITH ( NOLOCK )
                                        INNER JOIN [ACCOUNT] T2 WITH ( NOLOCK ) ON T1.ServicePIC = T2.UserID 
                                        LEFT JOIN [IMAGE_SIGN] T3 WITH ( NOLOCK ) ON T1.ID = T3.GroupNo AND T3.ProductType = 1 
                                WHERE   T1.OrderObjectID = @OrderObjectID ";

                    if (status < 0)
                    {
                        strSql += " AND (T1.Status = 2 OR T1.Status=5) ";//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                    }
                    else
                    {
                        strSql += " AND T1.Status = @Status  ";
                    }
                    strSql += " ORDER BY T1.CDStartTime desc";
                }

                list = db.SetCommand(strSql, db.Parameter("@OrderObjectID", orderObjectID, DbType.Int32)
                    , db.Parameter("@Status", status, DbType.Int32)
                    , db.Parameter("@ImageHeight", "160", DbType.String)
                    , db.Parameter("@ImageWidth", "160", DbType.String)).ExecuteList<Group>();
                return list;
            }
        }

        public List<Treatment> getTreatmentListByGroupNO(long groupNO, int CompanyID)
        {
            List<Treatment> list = new List<Treatment>();
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT a.ExecutorID,a.SubServiceID,a.StartTime,a.ID as TreatmentID,b.Name as ExecutorName,c.SubServiceName ,a.status ,a.IsDesignated 
                                FROM dbo.TREATMENT a 
                                INNER JOIN [ACCOUNT] b ON a.ExecutorID=b.UserID
                                LEFT JOIN [TBL_SUBSERVICE] c ON a.SubServiceID=c.ID 
                                WHERE a.CompanyID=@CompanyID AND a.GroupNo=@GroupNo AND a.status<>3 AND a.status<>4";
                list = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@GroupNo", groupNO, DbType.Int64)).ExecuteList<Treatment>();
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
                        //int customerSalesPersonID = 0;
                        foreach (OrderDetailOperation_Model item in model.OrderList)
                        {
                            string subServiceIDs = "";
                            string[] arrSubServiceCodes = null;
                            List<int> arrSubServiceID = new List<int>();
                            if (item.OpportunityId > 0 && item.CartId > 0)
                            {
                                db.RollbackTransaction();
                                listres.Code = "2";
                                listres.Message = "参数错误";
                                listres.Data = null;
                                return listres;
                            }

                            if (item.BranchID <= 0)
                            {
                                db.RollbackTransaction();
                                listres.Code = "2";
                                listres.Message = "参数错误";
                                listres.Data = null;
                                return listres;
                            }

                            #region 获取proID
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
                                string strSqlSelectProId = @"select T1.ID ,T1.MarketingPolicy ,T1.UnitPrice ,T1.PromotionPrice,T1.SubServiceCodes ,T1.DiscountID ,T1.ServiceName AS CommodityName   
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
                            #endregion

                            #region 计算价格
                            // 服务器获取数据库A价格 
                            decimal totalOrigPriceFromService = Math.Round(com_model.UnitPrice * (decimal)item.Quantity, 2);
                            if (item.TotalOrigPrice != totalOrigPriceFromService)
                            {
                                // 传来的A价格与数据库中A价格不符合,有人变动数据 
                                db.RollbackTransaction();
                                listres.Code = "-2";//前台需要刷新接口,获取新价格 
                                listres.Message = "价格变动";
                                listres.Data = null;
                                return listres;
                            }

                            item.TotalOrigPrice = totalOrigPriceFromService;
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
                                db.RollbackTransaction();
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

                            #region 计算优惠券
                            if (!string.IsNullOrEmpty(item.BenefitID))
                            {
                                CustomerBenefitDetail_Model Benefitmodel = ECard_DAL.Instance.getCustomerBenefitDetail(model.CompanyID, model.CustomerID, item.BenefitID);

                                if (Benefitmodel == null || Benefitmodel.BenefitStatus != 1 || string.IsNullOrEmpty(Benefitmodel.PRCode))
                                {
                                    db.RollbackTransaction();
                                    listres.Code = "6";
                                    listres.Message = "该优惠券已被使用，请刷新后查看";
                                    listres.Data = null;
                                    return listres;
                                }

                                if (Benefitmodel.PRCode == "6")
                                {
                                    if (Benefitmodel.PRValue1 > 0)
                                    {
                                        if (item.TotalCalcPrice < Benefitmodel.PRValue1)
                                        {
                                            //B价格没有满足满减需要
                                            db.RollbackTransaction();
                                            listres.Code = "6";
                                            listres.Message = "优惠券没有满足使用金额!";
                                            listres.Data = null;
                                            return listres;
                                        }
                                    }

                                    if (Benefitmodel.PRValue2 != item.PRValue2)
                                    {
                                        db.RollbackTransaction();
                                        listres.Code = "6";
                                        listres.Message = "优惠券金额变动使用失败!";
                                        listres.Data = null;
                                        return listres;
                                    }

                                    if (Benefitmodel.PRValue2 < 0)
                                    {
                                        Benefitmodel.PRValue2 = Math.Abs(Benefitmodel.PRValue2);
                                    }

                                    if (item.TotalSalePrice < 0)
                                    {
                                        item.TotalSalePrice = item.TotalCalcPrice - Benefitmodel.PRValue2;

                                        if (item.TotalSalePrice < 0)
                                        {
                                            item.TotalSalePrice = 0;
                                        }
                                    }
                                }

                            }
                            #endregion

                            #region 订单主表操作
                            int OrderSource = 0;//0:普通下单 1:需求转换订单 2:购物车转换订单 3:预约转换订单
                            long SourceID = 0;

                            if (item.OpportunityId > 0)
                            {
                                OrderSource = 1;
                                SourceID = item.OpportunityId;
                            }
                            else if (item.CartId > 0)
                            {
                                OrderSource = 2;
                                SourceID = item.CartId;
                                item.IsPast = false;

                                #region 抽取专属顾问数据
                                string strSqlGetResponsiblePersonID = @"SELECT AccountID FROM RELATIONSHIP WHERE CustomerID=@CustomerID AND BranchID=@BranchID AND Available=1 AND Type=1 ";
                                customerResponsiblePersonID = db.SetCommand(strSqlGetResponsiblePersonID, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32), db.Parameter("@BranchID", item.BranchID, DbType.Int32)).ExecuteScalar<int>();
                                #endregion

                                if (customerResponsiblePersonID <= 0)
                                {
                                    customerResponsiblePersonID = 0;
                                }
                            }
                            else if (item.TaskID > 0)
                            {
                                OrderSource = 3;
                                SourceID = item.TaskID;
                            }
                            else
                            {
                                OrderSource = 0;
                                SourceID = 0;
                            }

                            string strSqlInsertOrder = @"insert into [ORDER] (CompanyID,BranchID,CustomerID,OrderTime,ProductType,Quantity,TotalOrigPrice,TotalCalcPrice,TotalSalePrice,Status,OrderSource,SourceID ,CreatorID,CreateTime,UnPaidPrice,PaymentStatus)
values (@CompanyID,@BranchID,@CustomerID,@OrderTime,@ProductType,@Quantity,@TotalOrigPrice,@TotalCalcPrice,@TotalSalePrice,@Status,@OrderSource,@SourceID ,@CreatorID,@CreateTime,@UnPaidPrice,@PaymentStatus);select @@IDENTITY";

                            object objIDs = DBNull.Value;
                            if (!string.IsNullOrEmpty(subServiceIDs) && subServiceIDs != "")
                            {
                                objIDs = subServiceIDs;
                            }

                            if (item.ResponsiblePersonID == 0)
                            {
                                item.ResponsiblePersonID = customerResponsiblePersonID;
                            }

                            //if (item.SalesID == 0)
                            //{
                            //    item.SalesID = customerSalesPersonID;
                            //}

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
                                //db.Parameter("@ProductID", item.ProductID, DbType.Int32),
                            , db.Parameter("@Quantity", item.Quantity, DbType.Int32)
                            , db.Parameter("@TotalOrigPrice", item.TotalOrigPrice, DbType.Decimal)
                            , db.Parameter("@TotalCalcPrice", item.TotalCalcPrice, DbType.Decimal)
                            , db.Parameter("@TotalSalePrice", item.TotalSalePrice, DbType.Decimal)
                                //, db.Parameter("@Remark", "", DbType.String)
                            , db.Parameter("@Status", orderStatus, DbType.Int32)// 订单状态：1:未完成、2：已完成 、3：已取消、4:已终止
                            , db.Parameter("@OrderSource", OrderSource, DbType.Int32)
                            , db.Parameter("@SourceID", SourceID > 0 ? SourceID.ToString() : "", DbType.String)
                            , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                            , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                //, db.Parameter("@Expirationtime", item.Expirationtime, DbType.DateTime2)
                                //, db.Parameter("@SalesID", item.SalesID == 0 ? (object)DBNull.Value : item.SalesID, DbType.Int32)
                            , db.Parameter("@UnPaidPrice", item.TotalSalePrice, DbType.Decimal)
                            , db.Parameter("@PaymentStatus", 1, DbType.Int32) // 支付状态 1：未支付 2：部分付 3：已支付
                                //db.Parameter("@IsPast", item.IsPast, DbType.Boolean),
                                //db.Parameter("@SubServiceIDs", objIDs, DbType.String),
                                //db.Parameter("@TGExecutingCount", 0, DbType.Int32),
                                //db.Parameter("@TGFinishedCount", item.TGPastCount, DbType.Int32),
                                //db.Parameter("@TGTotalCount", 0, DbType.Int32),
                                //db.Parameter("@TGPastCount", item.TGPastCount, DbType.Int32),
                                //db.Parameter("@TGLastTime", null, DbType.DateTime2)
                            ).ExecuteScalar<int>();

                            if (orderid <= 0)
                            {
                                db.RollbackTransaction();
                                listres.Code = "2";
                                listres.Message = "strSqlInsertOrder添加失败";
                                listres.Data = null;
                                return listres;
                            }
                            #endregion

                            #region 使用优惠券
                            if (!string.IsNullOrEmpty(item.BenefitID))
                            {
                                string strUpdateBenefitSql = @" UPDATE  [TBL_CUSTOMER_BENEFIT]
                                                            SET     BenefitStatus = 2 , 
                                                                    OrderID = @OrderID , 
                                                                    UpdaterID = @UpdaterID ,
                                                                    UpdateTime = @UpdateTime
                                                            WHERE   UserID = @UserID
                                                                    AND CompanyID = @CompanyID
                                                                    AND BenefitID = @BenefitID ";

                                int updateBenefitrrs = db.SetCommand(strUpdateBenefitSql,
                                db.Parameter("@UserID", model.CustomerID, DbType.Decimal),
                                db.Parameter("@OrderID", orderid, DbType.Int32),
                                db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32),
                                db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2),
                                db.Parameter("@BenefitID", item.BenefitID, DbType.String)).ExecuteNonQuery();
                                if (updateBenefitrrs != 1)
                                {
                                    db.RollbackTransaction();
                                    listres.Code = "2";
                                    listres.Message = "strUpdateBenefitSql添加失败";
                                    listres.Data = null;
                                    return listres;
                                }
                            }
                            #endregion

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
                                if (item.TGTotalCount > 0 && item.TGTotalCount < item.TGPastCount)
                                {
                                    db.RollbackTransaction();
                                    listres.Code = "2";
                                    listres.Message = "";
                                    listres.Data = null;
                                    return listres;
                                }




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
                                string strAddOrderCommodity = @"INSERT INTO dbo.TBL_ORDER_COMMODITY( CompanyID ,BranchID  ,CustomerID ,OrderID ,UserCardNo ,CommodityCode ,CommodityID ,CommodityName ,Quantity ,SumOrigPrice ,SumCalcPrice ,SumSalePrice ,Remark ,Status ,DeliveredAmount ,UndeliveredAmount ,ReturnedAmount ,CreatorID ,CreateTime ) 
VALUES ( @CompanyID ,@BranchID  ,@CustomerID ,@OrderID ,@UserCardNo ,@CommodityCode ,@CommodityID ,@CommodityName ,@Quantity ,@SumOrigPrice ,@SumCalcPrice ,@SumSalePrice ,@Remark ,@Status ,@DeliveredAmount ,@UndeliveredAmount ,@ReturnedAmount ,@CreatorID ,@CreateTime ) ;select @@IDENTITY";

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
                                            }
                                            else
                                            {
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

                            #region 处理过去支付
                            if (item.PaidPrice > 0 && item.PaidPrice <= item.TotalSalePrice)
                            {
                                #region 插入PAYMENT表
                                string strSqlPayAdd = @"insert into PAYMENT(CompanyID,OrderNumber,TotalPrice,CreatorID,CreateTime,PaymentTime,LevelID,Type,Status,BranchID)
values (@CompanyID,@OrderNumber,@TotalPrice,@CreatorID,@CreateTime,@PaymentTime,@LevelID,@Type,@Status,@BranchID);select @@IDENTITY";
                                int paymentId = db.SetCommand(strSqlPayAdd
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@OrderNumber", 1, DbType.Int32)
                                , db.Parameter("@TotalPrice", item.PaidPrice, DbType.Decimal)
                                , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)
                                , db.Parameter("@PaymentTime", model.CreateTime, DbType.DateTime)
                                , db.Parameter("@LevelID", DBNull.Value, DbType.Int32)
                                , db.Parameter("@Type", 1, DbType.Int32)//1：支付 2：退款
                                , db.Parameter("@Status", 4, DbType.Int32)//1：无效 2：执行 3：撤销 4:过去支付
                                    //, db.Parameter("@Status", 2, DbType.Int32)//1：无效 2：执行 3：撤销 4:过去支付
                                , db.Parameter("@BranchID", item.BranchID, DbType.Int32)).ExecuteScalar<int>();//1：无效 2：执行 3：撤销
                                #endregion

                                if (paymentId <= 0)
                                {
                                    db.RollbackTransaction();
                                    listres.Code = "2";
                                    listres.Message = "strSqlPayAdd添加失败";
                                    listres.Data = null;
                                    return listres;
                                }

                                #region 插入PAYMENT_DETAIL表
                                string strSqlDetailAdd = @"insert into PAYMENT_DETAIL(CompanyID,PaymentID,PaymentMode,PaymentAmount,CreatorID,CreateTime,ProfitRate)
values (@CompanyID,@PaymentID,@PaymentMode,@PaymentAmount,@detailCreatorID,@detailCreateTime,@ProfitRate)";
                                int insertpaydetailrs = db.SetCommand(strSqlDetailAdd
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@PaymentID", paymentId, DbType.Int32)
                                , db.Parameter("@PaymentMode", 5, DbType.Int32)//0:现金、1:储值卡、2:银行卡。3:其他 4:免支付 5:过去支付
                                , db.Parameter("@PaymentAmount", item.PaidPrice, DbType.Decimal)
                                , db.Parameter("@detailCreatorID", model.CreatorID, DbType.Int32)
                                , db.Parameter("@detailCreateTime", model.CreateTime, DbType.DateTime)
                                , db.Parameter("@ProfitRate", 1, DbType.Decimal)).ExecuteNonQuery();
                                #endregion

                                if (insertpaydetailrs <= 0)
                                {
                                    db.RollbackTransaction();
                                    listres.Code = "2";
                                    listres.Message = "strSqlDetailAdd添加失败";
                                    listres.Data = null;
                                    return listres;
                                }

                                #region 插入OrderPayment关系表
                                string strSqlOrderPayAdd = @"insert into TBL_OrderPayment_RelationShip (OrderID,PaymentID) 
values (@OrderID,@PaymentID) ";
                                int orderPaymentRes = db.SetCommand(strSqlOrderPayAdd
                                , db.Parameter("@OrderID", orderid, DbType.Int32)
                                , db.Parameter("@PaymentID", paymentId, DbType.Int32)
                                    //db.Parameter("@ResponsiblePersonID", item.ResponsiblePersonID == 0 ? customerResponsiblePersonID : item.ResponsiblePersonID, DbType.Int32)
                                    //db.Parameter("@SalesID", item.SalesID == 0 ? (object)DBNull.Value : item.SalesID, DbType.Int32)
                                ).ExecuteNonQuery();
                                #endregion

                                if (orderPaymentRes <= 0)
                                {
                                    db.RollbackTransaction();
                                    listres.Code = "2";
                                    listres.Message = "strSqlOrderPayAdd添加失败";
                                    listres.Data = null;
                                    return listres;
                                }

                                #region 订单支付成功修改Order
                                string strSqlOrderUpt = @"update [ORDER] set UnPaidPrice=@UnPaidPrice, PaymentStatus=@PaymentStatus, UpdaterID = @UpdaterID,UpdateTime = @UpdateTime where ID = @OrderID";



                                int updateorderrs = db.SetCommand(strSqlOrderUpt,
                                db.Parameter("@UnPaidPrice", item.TotalSalePrice - item.PaidPrice, DbType.Decimal),// 未支付金额 
                                db.Parameter("@PaymentStatus", item.TotalSalePrice - item.PaidPrice > 0 ? 2 : 3, DbType.Int32),// 1:未支付 2:部分支付 3:完全支付 
                                db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32),
                                db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2),
                                db.Parameter("@OrderID", orderid, DbType.Int32)).ExecuteNonQuery();
                                #endregion

                                if (updateorderrs != 1)
                                {
                                    db.RollbackTransaction();
                                    listres.Code = "2";
                                    listres.Message = "strSqlOrderUpt添加失败";
                                    listres.Data = null;
                                    return listres;
                                }
                            }
                            #endregion

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
                                if (updateorderrs != 1)
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

                            #region 需求转订单
                            if (item.OpportunityId > 0)
                            {
                                string strSqlOppCheck = @"select ID from OPPORTUNITY where ID=@ID and Status = 0";
                                int oppoid = db.SetCommand(strSqlOppCheck, db.Parameter("@ID", item.OpportunityId, DbType.Int32)).ExecuteScalar<int>();

                                if (oppoid <= 0)
                                {
                                    db.RollbackTransaction();
                                    listres.Code = "2";
                                    listres.Message = "strSqlOppCheck添加失败";
                                    listres.Data = null;
                                    return listres;
                                }

                                string strSqlOppUpt = @"update OPPORTUNITY set Status=@Status,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime where ID=@ID";
                                int oppuptrs = db.SetCommand(strSqlOppUpt,
                                db.Parameter("@Status", 1, DbType.Int32),
                                db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32),
                                db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2),
                                db.Parameter("@ID", oppoid, DbType.Int32)).ExecuteNonQuery();
                                if (oppuptrs <= 0)
                                {
                                    db.RollbackTransaction();
                                    listres.Code = "2";
                                    listres.Message = "strSqlOppUpt添加失败";
                                    listres.Data = null;
                                    return listres;
                                }
                            }
                            #endregion

                            #region 购物车转订单
                            if (item.CartId > 0)
                            {
                                //isPush = true;
                                string strSqlOppCheck = @"select ID from [CART] where ID=@ID and Status = 0";
                                int cartID = db.SetCommand(strSqlOppCheck, db.Parameter("@ID", item.CartId, DbType.Int32)).ExecuteScalar<int>();

                                if (cartID <= 0)
                                {
                                    db.RollbackTransaction();
                                    listres.Code = "5";
                                    listres.Message = "购物车已经转换订单";
                                    listres.Data = null;
                                    return listres;
                                }

                                #region 插入cart历史表
                                string strSqlInserHis = @"Insert Into [HISTORY_CART] select * from [CART] WHERE ID=@ID";
                                int inserthisrs = db.SetCommand(strSqlInserHis, db.Parameter("@ID", cartID, DbType.Int32)).ExecuteNonQuery();
                                #endregion

                                if (inserthisrs <= 0)
                                {
                                    db.RollbackTransaction();
                                    listres.Code = "2";
                                    listres.Message = "inserthisrs添加失败";
                                    listres.Data = null;
                                    return listres;
                                }

                                #region 更改Cart表状态
                                string strSqlDel = @"update CART set Status=@Status,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime where ID=@ID";
                                int delrs = db.SetCommand(strSqlDel,
                                db.Parameter("@Status", 1, DbType.Int32),
                                db.Parameter("@UpdaterID", model.CustomerID, DbType.Int32),
                                db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2),
                                db.Parameter("@ID", cartID, DbType.Int32)).ExecuteNonQuery();
                                #endregion

                                if (delrs != 1)
                                {
                                    db.RollbackTransaction();
                                    listres.Code = "2";
                                    listres.Message = "strSqlDel失败";
                                    listres.Data = null;
                                    return listres;
                                }
                            }
                            #endregion

                            #region 预约转订单
                            if (item.TaskID > 0 && item.ProductType == 0)
                            {
                                string strUpdateTaskSql = @"UPDATE  [TBL_TASK]
                                                            SET     TaskStatus=@TaskStatus ,
                                                                    ExecuteStartTime = @ExecuteStartTime ,
                                                                    ActedOrderID = @OrderID ,
                                                                    ActedOrderServiceID = @OrderObjectID ,
                                                                    UpdaterID = @UpdaterID ,
                                                                    UpdateTime = @UpdateTime
                                                            WHERE   ReservedOrderType = 2
                                                                    AND ID = @TaskID
                                                                    AND CompanyID = @CompanyID
                                                                    AND ReservedOrderType <> 3
                                                                    AND ReservedOrderType <> 4";

                                int updateTaskRows = db.SetCommand(strUpdateTaskSql
                                    , db.Parameter("@TaskStatus", 3, DbType.Int32)//1：待确认 2：已确认 3：已执行 4：已取消
                                    , db.Parameter("@ExecuteStartTime", model.CreateTime, DbType.DateTime)
                                    , db.Parameter("@OrderID", orderid, DbType.Int32)
                                    , db.Parameter("@OrderObjectID", orderObjectID, DbType.Int32)
                                    , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                                    , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime)
                                    , db.Parameter("@TaskID", item.TaskID, DbType.Int64)
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                                if (updateTaskRows != 1)
                                {
                                    db.RollbackTransaction();
                                    listres.Code = "2";
                                    listres.Message = "inserthisrs添加失败";
                                    listres.Data = null;
                                    return listres;
                                }

                                // 查看是否有指定的人 TBL_SCHEDULE中有没有数据
                                string strSelHasSchedulSql = @"SELECT COUNT(0) FROM  [TBL_SCHEDULE] WHERE TaskID=@TaskID AND CompanyID=@CompanyID";
                                int schedulCount = db.SetCommand(strSelHasSchedulSql
                                    , db.Parameter("@TaskID", item.TaskID, DbType.Int64)
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();

                                if (schedulCount > 0)
                                {
                                    string strUpdateScdlSql = @"UPDATE  [TBL_SCHEDULE]
                                                            SET     ExecuteStartTime = @ExecuteStartTime ,
                                                                    ScheduleStatus = @ScheduleStatus ,
                                                                    UpdaterID = @UpdaterID ,
                                                                    UpdateTime = @UpdateTime
                                                            WHERE   TaskID = @TaskID
                                                                    AND CompanyID = @CompanyID";

                                    int updateScdlRows = db.SetCommand(strUpdateScdlSql
                                        , db.Parameter("@ExecuteStartTime", model.CreateTime, DbType.DateTime)
                                        , db.Parameter("@ScheduleStatus", 3, DbType.Int32)//SCDL状态：2：已确认 3：已执行 4：已取消
                                        , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                                        , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime)
                                        , db.Parameter("@TaskID", item.TaskID, DbType.Int64)
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                                    if (updateScdlRows != 1)
                                    {
                                        db.RollbackTransaction();
                                        listres.Code = "2";
                                        listres.Message = "inserthisrs添加失败";
                                        listres.Data = null;
                                        return listres;
                                    }
                                }
                            }
                            #endregion

                            #region 美丽顾问/销售顾问
                            string strAddConsultant = @" INSERT INTO [TBL_BUSINESS_CONSULTANT]( CompanyID ,BusinessType ,MasterID ,ConsultantType ,ConsultantID ,CreatorID ,CreateTime )
                                                    VALUES ( @CompanyID ,@BusinessType ,@MasterID ,@ConsultantType ,@ConsultantID ,@CreatorID ,@CreateTime )";

                            #region 美丽顾问
                            if (item.ResponsiblePersonID > 0)
                            {
                                int addConsultantRes = db.SetCommand(strAddConsultant
                                       , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                       , db.Parameter("@BusinessType", 1, DbType.Int32)//1：订单，2：支付，3：充值
                                       , db.Parameter("@MasterID", orderid, DbType.Int32)
                                       , db.Parameter("@ConsultantType", 1, DbType.Int32)//1:美丽顾问 2:销售顾问
                                       , db.Parameter("@ConsultantID", item.ResponsiblePersonID, DbType.Int32)
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
                                    if (model.IsBusiness)
                                    {
                                        #region Business端
                                        string strSelectaccountSql = @"SELECT  T1.UserID AS AccountID,T2.BranchID
                                                                            FROM    ACCOUNT T1 WITH ( NOLOCK )
                                                                                    LEFT JOIN TBL_ACCOUNTBRANCH_RELATIONSHIP T2 WITH ( NOLOCK ) ON T1.UserID = T2.UserID
                                                                                    LEFT JOIN TBL_ROLE T4 WITH ( NOLOCK ) ON T1.RoleID = T4.ID
                                                                            WHERE   ( T2.BranchID = @BranchID
                                                                                      AND T1.Available = 1
                                                                                      AND T2.Available = 1
                                                                                      AND T2.UserID = @ResponsableID
                                                                                    )
                                                                                    OR ( T4.Available = 1
                                                                                         AND CHARINDEX('|41|', T4.Jurisdictions) > 0
                                                                                         AND T2.BranchID = @BranchID
                                                                                         AND T1.Available = 1
                                                                                         AND T2.Available = 1
                                                                                       )  ";
                                        List<Echo_Model> accountListTemp = db.SetCommand(strSelectaccountSql, db.Parameter("@BranchID", item.BranchID, DbType.Int32), db.Parameter("@ResponsableID", item.ResponsiblePersonID, DbType.Int32)).ExecuteList<Echo_Model>();
                                        if (accountListTemp != null && accountListTemp.Count > 0)
                                        {
                                            accountList.AddRange(accountListTemp);
                                        }
                                        #endregion
                                    }
                                    else
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

        public List<OrderInfo_Model> getOrderInfoList(int companyID, List<int> orderIDList)
        {
            using (DbManager db = new DbManager())
            {
                List<OrderInfo_Model> list = new List<OrderInfo_Model>();
                foreach (int item in orderIDList)
                {
                    string strSelMainSql = @"SELECT T1.ID AS OrderID ,
                                                    T1.ProductType ,
                                                    T2.SubServiceIDs ,
                                                    CASE T1.ProductType WHEN 0 THEN T2.Remark ELSE T3.Remark END AS Remark ,
                                                    CASE T1.ProductType WHEN 0 THEN T2.ServiceName ELSE T3.CommodityName END AS ProductName,
                                                    CASE T1.ProductType WHEN 0 THEN T2.TGExecutingCount ELSE T3.UndeliveredAmount END AS ExecutingCount,
                                                    CASE T1.ProductType WHEN 0 THEN T2.TGFinishedCount ELSE T3.DeliveredAmount END AS FinishedCount,
                                                    CASE T1.ProductType WHEN 0 THEN T2.TGTotalCount ELSE T3.Quantity END AS TotalCount, 
                                                    CASE T1.ProductType WHEN 0 THEN T2.ID ELSE T3.ID END AS OrderObjectID, 
                                                    CASE T1.ProductType WHEN 0 THEN T4.IsConfirmed ELSE T5.IsConfirmed END AS IsConfirmed  
                                            FROM    [ORDER] T1 WITH ( NOLOCK )
                                                    LEFT JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.ID = T2.OrderID
                                                    LEFT JOIN [TBL_ORDER_COMMODITY] T3 WITH ( NOLOCK ) ON T1.ID = T3.OrderID 
                                                    LEFT JOIN [SERVICE] T4 WITH( NOLOCK ) ON T2.ServiceID = T4.ID 
                                                    LEFT JOIN [COMMODITY] T5 WITH( NOLOCK ) ON T3.CommodityID = T5.ID 
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.ID = @OrderID";

                    OrderInfo_Model order = db.SetCommand(strSelMainSql
                                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                    , db.Parameter("@OrderID", item, DbType.Int32)).ExecuteObject<OrderInfo_Model>();

                    if (order == null)
                    {
                        return null;
                    }

                    #region 美丽顾问
                    string strSelSalesSql = @" SELECT  T2.UserID AS AccountID ,
                                                    T2.Name AS AccountName
                                            FROM    [TBL_BUSINESS_CONSULTANT] T1 WITH ( NOLOCK )
                                                    INNER JOIN [ACCOUNT] T2 WITH ( NOLOCK ) ON T1.ConsultantID = T2.UserID
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.BusinessType = 1
                                                    AND MasterID = @MasterID
                                                    AND ConsultantType = @ConsultantType ";

                    DataTable dt = db.SetCommand(strSelSalesSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                    , db.Parameter("@MasterID", order.OrderID, DbType.Int32)
                                    , db.Parameter("@ConsultantType", 1, DbType.Int32)).ExecuteDataTable();

                    if (dt != null && dt.Rows.Count > 0)
                    {
                        order.AccountName = StringUtils.GetDbString(dt.Rows[0]["AccountName"].ToString());
                        order.AccountID = StringUtils.GetDbInt(dt.Rows[0]["AccountID"].ToString());
                    }
                    #endregion

                    order.SurplusCount = order.TotalCount - order.FinishedCount - order.ExecutingCount;

                    if (order.ProductType == 0)
                    {
                        #region 服务
                        order.SubServiceList = new List<SubServiceList_Model>();
                        if (!string.IsNullOrEmpty(order.SubServiceIDs))
                        {
                            #region 子服务
                            string[] arrSubServiceIDs = null;

                            arrSubServiceIDs = order.SubServiceIDs.Split(new string[] { "|" }, StringSplitOptions.RemoveEmptyEntries);

                            foreach (var subID in arrSubServiceIDs)
                            {
                                string StrSqlGetSubServiceID = @"SELECT ISNULL(ID,0) AS SubServiceID,SubServiceName FROM [TBL_SubService] WHERE ID=@SubServiceID";
                                SubServiceList_Model subServiceModel = db.SetCommand(StrSqlGetSubServiceID, db.Parameter("@SubServiceID", subID, DbType.Int32)).ExecuteObject<SubServiceList_Model>();

                                if (subServiceModel != null)
                                {
                                    order.SubServiceList.Add(subServiceModel);
                                }

                            }
                            #endregion
                        }
                        else
                        {
                            #region 套盒
                            order.SubServiceList = null;
                            #endregion
                        }
                        #endregion
                    }

                    list.Add(order);
                }

                return list;
            }
        }

        public int addTG(AddTGOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                DataTable dt = new DataTable();
                foreach (TGDetailOperation_Model item in model.TGDetailList)
                {
                    if (item.ProductType == 0)
                    {
                        #region 服务

                        if (item.ServicePIC <= 0)
                        {
                            db.RollbackTransaction();
                            return 3;
                        }

                        #region 订单是否还能添加TG
                        string strSelOrderCanAddTG = @"SELECT  COUNT(0)
                                                FROM    [TBL_ORDER_SERVICE] T1 WITH ( NOLOCK )
                                                WHERE   T1.CompanyID = @CompanyID
                                                        AND T1.ID = @OrderObjectID
                                                        AND ( ( T1.TGExecutingCount + T1.TGFinishedCount + 1 ) <= T1.TGTotalCount
                                                              OR ISNULL(T1.TGTotalCount, 0) = 0
                                                            ) AND T1.Status=1 ";
                        int count = db.SetCommand(strSelOrderCanAddTG
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)).ExecuteScalar<int>();

                        if (count <= 0)
                        {
                            db.RollbackTransaction();
                            return 2;
                        }
                        #endregion

                        //生成组别ID
                        long groupNo = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "TreatGroupCode", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<long>();
                        if (groupNo <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        bool TGIsDesignated = false;

                        #region 添加 Treatment
                        if (item.TreatmentList != null && item.TreatmentList.Count > 0)
                        {
                            string strSqlAddTreatment = @"insert into TREATMENT(CompanyID,CourseID,ExecutorID,Available,CreatorID,CreateTime,BranchID,IsDesignated,GroupNo,StartTime,SubServiceID,Status)
 values (@CompanyID,@CourseID,@ExecutorID,@Available,@CreatorID,@CreateTime,@BranchID,@IsDesignated,@GroupNo,@StartTime,@SubServiceID,@Status)";


                            object subServiceID = DBNull.Value;

                            foreach (TGTreatmentOperation_Model TreatItem in item.TreatmentList)
                            {
                                if (TreatItem.IsDesignated)
                                {
                                    TGIsDesignated = true;
                                }

                                object objexecutorID = DBNull.Value;
                                if (TreatItem.SubServiceID > 0)
                                {
                                    subServiceID = TreatItem.SubServiceID;
                                }

                                #region 添加Treatment
                                int treatmentrs = db.SetCommand(strSqlAddTreatment
                                                 , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                 , db.Parameter("@CourseID", item.OrderObjectID, DbType.Int32)
                                                 , db.Parameter("@ExecutorID", TreatItem.ExecutorID, DbType.Int32)
                                    //, db.Parameter("@ScheduleID", 0, DbType.Int32)
                                                 , db.Parameter("@Available", true, DbType.Boolean)
                                                 , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                 , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                                                 , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                 , db.Parameter("@IsDesignated", TreatItem.IsDesignated, DbType.Boolean)
                                                 , db.Parameter("@GroupNo", groupNo, DbType.Int64)
                                                 , db.Parameter("@StartTime", model.CreateTime, DbType.DateTime)
                                                 , db.Parameter("@SubServiceID", subServiceID, DbType.Int32)
                                                 , db.Parameter("@Status", 1, DbType.Int32)).ExecuteNonQuery();//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认

                                if (treatmentrs <= 0)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }
                                #endregion
                            }

                        }
                        #endregion

                        #region 添加TG
                        string strAddTG = @"INSERT INTO TBL_TREATGROUP( CompanyID ,BranchID ,OrderID ,OrderServiceID ,GroupNo ,SerialNo ,ServicePIC ,IsDesignated ,TGStartTime ,TGEndTime ,TGScdlTime ,TGStatus ,Remark ,CreatorID ,CreateTime ) 
                                     VALUES ( @CompanyID ,@BranchID ,@OrderID ,@OrderServiceID ,@GroupNo ,@SerialNo ,@ServicePIC ,@IsDesignated ,@TGStartTime ,@TGEndTime ,@TGScdlTime ,@TGStatus ,@Remark ,@CreatorID ,@CreateTime );select @@IDENTITY";

                        object TGEndTime = DBNull.Value;
                        if (item.IsFinish)
                        {
                            TGEndTime = DateTime.Now.ToLocalTime();
                        }

                        int TGID = db.SetCommand(strAddTG
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                        , db.Parameter("@OrderID", item.OrderID, DbType.Int32)
                                        , db.Parameter("@OrderServiceID", item.OrderObjectID, DbType.Int32)
                                        , db.Parameter("@GroupNo", groupNo, DbType.Int64)
                                        , db.Parameter("@SerialNo", groupNo, DbType.Int64)//服务组序列号（初始值同服务组编号）
                                        , db.Parameter("@ServicePIC", item.ServicePIC, DbType.Int32)
                                        , db.Parameter("@IsDesignated", TGIsDesignated, DbType.Boolean)
                                        , db.Parameter("@TGStartTime", model.CreateTime, DbType.DateTime2)
                                        , db.Parameter("@TGEndTime", TGEndTime, DbType.DateTime2)
                                        , db.Parameter("@TGScdlTime", DBNull.Value, DbType.DateTime2)
                                        , db.Parameter("@TGStatus", 1, DbType.Int32)//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                                        , db.Parameter("@Remark", item.Remark, DbType.String)
                                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                                        ).ExecuteNonQuery();

                        if (TGID <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        #endregion

                        #region 修改TBL_ORDER_SERVICE表TGExecutingCount+1
                        string strAddHisCourse = @"INSERT INTO [HST_ORDER_SERVICE] SELECT * FROM [TBL_ORDER_SERVICE] WHERE CompanyID = @CompanyID AND ID = @OrderObjectID";
                        int hisCourseCount = db.SetCommand(strAddHisCourse
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                        if (hisCourseCount <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        string strUpdateCourseSql = @"UPDATE  [TBL_ORDER_SERVICE]
                                                    SET     TGExecutingCount = TGExecutingCount + 1 ,
                                                            Remark = @Remark ,
                                                            TGLastTime = @TGLastTime ,
                                                            UpdaterID = UpdaterID ,
                                                            UpdateTime = UpdateTime
                                                    WHERE   CompanyID = @CompanyID
                                                            AND ID = @OrderObjectID";

                        int updateCourseRes = db.SetCommand(strUpdateCourseSql
                                            , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                                            , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime2)
                                            , db.Parameter("@TGLastTime", model.CreateTime, DbType.DateTime2)
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@Remark", item.Remark, DbType.String)
                                            , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                        if (updateCourseRes <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        #region 预约转订单
                        if (item.TaskID > 0 && item.ProductType == 0)
                        {
                            string strUpdateTaskSql = @"UPDATE  [TBL_TASK]
                                                            SET     TaskStatus=@TaskStatus ,
                                                                    ExecuteStartTime = @ExecuteStartTime ,
                                                                    ActedOrderID = @OrderID ,
                                                                    ActedOrderServiceID = @OrderObjectID ,
                                                                    UpdaterID = @UpdaterID ,
                                                                    UpdateTime = @UpdateTime 
                                                            WHERE   ReservedOrderType = 1
                                                                    AND ID = @TaskID
                                                                    AND CompanyID = @CompanyID
                                                                    AND ReservedOrderType <> 3
                                                                    AND ReservedOrderType <> 4";

                            int updateTaskRows = db.SetCommand(strUpdateTaskSql
                                , db.Parameter("@TaskStatus", 3, DbType.Int32)//1：待确认 2：已确认 3：已执行 4：已取消
                                , db.Parameter("@ExecuteStartTime", model.CreateTime, DbType.DateTime)
                                , db.Parameter("@OrderID", item.OrderID, DbType.Int32)
                                , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)
                                , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                                , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime)
                                , db.Parameter("@TaskID", item.TaskID, DbType.Int64)
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                            if (updateTaskRows != 1)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            // 查看是否有指定的人 TBL_SCHEDULE中有没有数据
                            string strSelHasSchedulSql = @"SELECT COUNT(0) FROM  [TBL_SCHEDULE] WHERE TaskID=@TaskID AND CompanyID=@CompanyID";
                            int schedulCount = db.SetCommand(strSelHasSchedulSql
                                , db.Parameter("@TaskID", item.TaskID, DbType.Int64)
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();

                            if (schedulCount > 0)
                            {
                                string strUpdateScdlSql = @"UPDATE  [TBL_SCHEDULE]
                                                            SET     ExecuteStartTime = @ExecuteStartTime ,
                                                                    ScheduleStatus = @ScheduleStatus ,
                                                                    UpdaterID = @UpdaterID ,
                                                                    UpdateTime = @UpdateTime
                                                            WHERE   TaskID = @TaskID
                                                                    AND CompanyID = @CompanyID";

                                int updateScdlRows = db.SetCommand(strUpdateScdlSql
                                    , db.Parameter("@ExecuteStartTime", model.CreateTime, DbType.DateTime)
                                    , db.Parameter("@ScheduleStatus", 3, DbType.Int32)//SCDL状态：2：已确认 3：已执行 4：已取消
                                    , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                                    , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime)
                                    , db.Parameter("@TaskID", item.TaskID, DbType.Int64)
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                                if (updateScdlRows != 1)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }
                            }
                        }
                        #endregion
                        #endregion
                    }
                    else
                    {
                        #region 商品
                        int isConfirmed = 0;
                        if (item.Count > 0)
                        {
                            #region 订单是否还能添加交付单
                            string strSelOrderCanAddTG = @"SELECT  COUNT(0)
                                                        FROM    [TBL_ORDER_COMMODITY] T1 WITH ( NOLOCK )
                                                        WHERE   T1.CompanyID = @CompanyID
                                                                AND T1.OrderID = @OrderID
                                                                AND ( T1.DeliveredAmount + T1.UndeliveredAmount + @Count <= T1.Quantity ) AND T1.Status=1 ";
                            int count = db.SetCommand(strSelOrderCanAddTG
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@OrderID", item.OrderID, DbType.Int32)
                                , db.Parameter("@Count", item.Count, DbType.Int32)).ExecuteScalar<int>();

                            if (count <= 0)
                            {
                                db.RollbackTransaction();
                                return 2;
                            }
                            #endregion

                            #region 查询简单的订单信息
                            string strSelSimpleOrderSql = @"SELECT  CustomerID , 
                                                               CommodityID AS ProductID 
                                                       FROM    [TBL_ORDER_COMMODITY] T1 WITH ( NOLOCK ) 
                                                       WHERE   T1.CompanyID = @CompanyID 
                                                               AND T1.OrderID = @OrderID ";
                            SimpleOrder_Model simpleModel = db.SetCommand(strSelSimpleOrderSql
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@OrderID", item.OrderID, DbType.Int32)).ExecuteObject<SimpleOrder_Model>();

                            if (simpleModel == null)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                            #endregion

                            //生成组别ID 
                            long groupNo = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "DeliveryCode", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<long>();
                            if (groupNo <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            int commodityStatus = 1;//状态：1:未完成、2：已完成 、3：已取消、4:已终止、5：交付待确认
                            object CDEndTime = DBNull.Value;
                            if (item.IsFinish)//下单并且交付
                            {
                                #region 查询改有的状态
                                commodityStatus = 2;
                                CDEndTime = model.CreateTime;

                                string strSelIsConfirmedSql = @"SELECT T2.IsConfirmed FROM [TBL_ORDER_COMMODITY] T1 WITH(NOLOCK) 
                                                            INNER JOIN [COMMODITY] T2 WITH(NOLOCK) ON T1.CommodityID=T2.ID
                                                            WHERE T1.OrderID=@OrderID";

                                isConfirmed = db.SetCommand(strSelIsConfirmedSql
                                            , db.Parameter("@OrderID", item.OrderID, DbType.Int32)).ExecuteScalar<int>();

                                string strSelectLoginMobileSql = @"select T1.LoginMobile from [USER] T1 Where T1.ID =(SELECT T2.CustomerID FROM [ORDER] T2 WHERE T2.ID=@OrderID)";
                                string loginMobile = db.SetCommand(strSelectLoginMobileSql, db.Parameter("@OrderID", item.OrderID, DbType.Int32)).ExecuteScalar<string>();
                                if (!string.IsNullOrWhiteSpace(loginMobile))
                                {
                                    if (isConfirmed == 1)//需要顾客确认
                                    {
                                        commodityStatus = 5;
                                    }
                                }
                                #endregion

                                if (isConfirmed == 2)
                                {
                                    #region 签名
                                    if (string.IsNullOrWhiteSpace(model.SignImg) || string.IsNullOrWhiteSpace(model.ImageFormat))
                                    {
                                        db.RollbackTransaction();
                                        return 4;
                                    }
                                    string imgName = "";
                                    bool isUpLoad = addSignImgFiles(model.CompanyID, simpleModel.CustomerID, groupNo, model.ImageFormat, model.SignImg, out imgName);
                                    if (!isUpLoad)
                                    {
                                        db.RollbackTransaction();
                                        return 5;
                                    }
                                    else
                                    {
                                        string strSignSql = @"INSERT INTO IMAGE_SIGN( CompanyID ,CustomerID ,GroupNo ,ProductType ,[FileName] ,CreatorID ,CreateTime ) 
                                                        VALUES (@CompanyID ,@CustomerID ,@GroupNo ,@ProductType ,@FileName ,@CreatorID ,@CreateTime)";
                                        int addSignRes = db.SetCommand(strSignSql
                                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                , db.Parameter("@CustomerID", simpleModel.CustomerID, DbType.Int32)
                                                , db.Parameter("@GroupNo", groupNo, DbType.Int64)
                                                , db.Parameter("@ProductType", 1, DbType.Int32)
                                                , db.Parameter("@FileName", imgName, DbType.String)
                                                , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                                        if (addSignRes != 1)
                                        {
                                            db.RollbackTransaction();
                                            return 0;
                                        }
                                    }
                                    #endregion
                                }
                            }



                            #region 添加交付单
                            string strAddTG = @"INSERT INTO [TBL_COMMODITY_DELIVERY]( CompanyID ,BranchID ,CustomerID ,ServicePIC ,OrderID ,OrderObjectID ,ID ,Type ,CommodityID ,Quantity ,Status ,Remark ,CDStartTime ,CDEndTime ,CreatorID ,CreateTime) 
                                     VALUES ( @CompanyID ,@BranchID ,@CustomerID ,@ServicePIC ,@OrderID ,@OrderObjectID ,@ID ,@Type ,@CommodityID ,@Quantity ,@Status ,@Remark ,@CDStartTime ,@CDEndTime ,@CreatorID ,@CreateTime)";

                            object TGEndTime = DBNull.Value;

                            int TGID = db.SetCommand(strAddTG
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                            , db.Parameter("@CustomerID", simpleModel.CustomerID, DbType.Int32)
                                            , db.Parameter("@ServicePIC", model.CreatorID, DbType.Int32)
                                            , db.Parameter("@OrderID", item.OrderID, DbType.Int32)
                                            , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)
                                            , db.Parameter("@ID", groupNo, DbType.Int64)
                                            , db.Parameter("@Type", 1, DbType.Boolean)//1：交付 2：退货
                                            , db.Parameter("@CommodityID", simpleModel.ProductID, DbType.Int32)
                                            , db.Parameter("@Quantity", item.Count, DbType.Int32)
                                            , db.Parameter("@Status", commodityStatus, DbType.Int32)//状态：1:未完成、2：已完成 、3：已取消、4:已终止、5：交付待确认
                                            , db.Parameter("@Remark", item.Remark, DbType.String)
                                            , db.Parameter("@CDStartTime", model.CreateTime, DbType.DateTime2)
                                            , db.Parameter("@CDEndTime", CDEndTime, DbType.DateTime2)
                                            , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                            , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                            if (TGID <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            #endregion

                            #region 修改TBL_ORDER_COMMODITY表中的数量
                            string strAddHisOrderCommodity = @"INSERT INTO [HST_ORDER_COMMODITY] SELECT * FROM [TBL_ORDER_COMMODITY] WHERE CompanyID = @CompanyID AND ID = @OrderObjectID";
                            int hisOrderCommodityCount = db.SetCommand(strAddHisOrderCommodity
                                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                            if (hisOrderCommodityCount <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            string strUpdateOrderCommoditySql = @" UPDATE  dbo.TBL_ORDER_COMMODITY
                                                               SET     UpdaterID = @UpdaterID ,
                                                                       UpdateTime = UpdateTime ,
                                                                       Remark = @Remark ";
                            if (item.IsFinish)
                            {
                                strUpdateOrderCommoditySql += " ,DeliveredAmount = DeliveredAmount + @Count ";
                            }
                            else
                            {
                                strUpdateOrderCommoditySql += " ,UndeliveredAmount = UndeliveredAmount + @Count ";
                            }

                            strUpdateOrderCommoditySql += "  WHERE CompanyID = @CompanyID AND ID = @OrderObjectID ";

                            int updateOrderCommodityRes = db.SetCommand(strUpdateOrderCommoditySql
                                               , db.Parameter("@Remark", item.Remark, DbType.String)
                                               , db.Parameter("@Count", item.Count, DbType.Int32)
                                               , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                                               , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime2)
                                               , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                               , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                            if (updateOrderCommodityRes <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            #endregion

                            #region 查询是否已经完成商品订单
                            string selQuantitySql = @"SELECT  T1.DeliveredAmount ,
                                                        T1.Quantity
                                                FROM    [TBL_ORDER_COMMODITY] T1 WITH ( NOLOCK )
                                                WHERE   T1.CompanyID = @CompanyID
                                                        AND T1.OrderID = @OrderID";
                            dt = new DataTable();
                            dt = db.SetCommand(selQuantitySql
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@OrderID", item.OrderID, DbType.Int32)).ExecuteDataTable();

                            if (dt == null || dt.Rows.Count <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            int deliveredAmount = StringUtils.GetDbInt(dt.Rows[0]["DeliveredAmount"].ToString());
                            int quantity = StringUtils.GetDbInt(dt.Rows[0]["Quantity"].ToString());
                            int orderStatus = 1;//状态：1:未完成、2：已完成 、3：已取消、4:已终止
                            if (deliveredAmount > quantity || quantity == 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                            else if (deliveredAmount == quantity && quantity != 0)
                            {
                                string strSelHasConfirmedSql = @"SELECT  COUNT(0)
                                                            FROM    [TBL_COMMODITY_DELIVERY]
                                                            WHERE   CompanyID = @CompanyID
                                                                    AND OrderObjectID = @OrderObjectID
                                                                    AND ( Status = 1
                                                                          OR Status = 5
                                                                        )";
                                int needConfirmCount = db.SetCommand(strSelHasConfirmedSql
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)).ExecuteScalar<int>();

                                if (needConfirmCount <= 0)
                                {
                                    orderStatus = 2;
                                }
                            }
                            #endregion

                            if (orderStatus == 2)
                            {
                                #region 订单被完成
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

                                string strUpdateOrderCommodityStatusSql = @" UPDATE [TBL_ORDER_COMMODITY] SET Status=@Status WHERE CompanyID = @CompanyID AND ID = @OrderObjectID ";
                                int updateOrderCommodityStatusRes = db.SetCommand(strUpdateOrderCommodityStatusSql
                                                            , db.Parameter("@Status", 2, DbType.Int32)//1://1:未完成 2已完成 3亿取消 4已中止
                                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                            , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                                if (updateOrderCommodityStatusRes <= 0)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }
                                #endregion
                            }

                            if (item.IsFinish && isConfirmed == 0)
                            {
                                #region 即时PUSH
                                string strSelLoginSql = @" SELECT  T3.WeChatOpenID ,
                                                            T4.BranchName ,
                                                            T2.OrderID ,
                                                            T2.CommodityName ,
                                                            T5.Name AS AccountName ,
                                                            T6.CreateTime ,
                                                            T3.Name AS CustomerName
                                                    FROM    [TBL_COMMODITY_DELIVERY] T1 WITH ( NOLOCK )
                                                            LEFT JOIN [TBL_ORDER_COMMODITY] T2 WITH ( NOLOCK ) ON T1.OrderObjectID = T2.ID
                                                            LEFT JOIN [CUSTOMER] T3 WITH ( NOLOCK ) ON T2.CustomerID = T3.UserID
                                                            LEFT JOIN [BRANCH] T4 WITH ( NOLOCK ) ON T2.BranchID = T4.ID
                                                            LEFT JOIN [ACCOUNT] T5 WITH ( NOLOCK ) ON T1.ServicePIC = T5.UserID
                                                            LEFT JOIN [ORDER] T6 WITH ( NOLOCK ) ON T2.OrderID = T6.ID
                                                    WHERE   T1.ID = @GroupNo
                                                            AND ISNULL(T3.WeChatOpenID, '') <> ''  ";
                                DataTable pushmodel = db.SetCommand(strSelLoginSql
                                               , db.Parameter("@GroupNo", groupNo, DbType.Int64)).ExecuteDataTable();

                                if (pushmodel != null)
                                {
                                    Task.Factory.StartNew(() =>
                                    {
                                        try
                                        {
                                            #region 微信push
                                            string weChatOpenID = StringUtils.GetDbString(pushmodel.Rows[0]["WeChatOpenID"].ToString());
                                            if (!string.IsNullOrEmpty(weChatOpenID))
                                            {
                                                DateTime finishTime = model.CreateTime;
                                                string branchName = StringUtils.GetDbString(pushmodel.Rows[0]["BranchName"].ToString());
                                                string commodityName = StringUtils.GetDbString(pushmodel.Rows[0]["CommodityName"].ToString());
                                                string accountName = StringUtils.GetDbString(pushmodel.Rows[0]["AccountName"].ToString());
                                                string customerName = StringUtils.GetDbString(pushmodel.Rows[0]["CustomerName"].ToString());
                                                string strOrderCreateTime = StringUtils.GetDbString(pushmodel.Rows[0]["CreateTime"]);
                                                int orderID = StringUtils.GetDbInt(pushmodel.Rows[0]["OrderID"]);
                                                string orderNumber = "";
                                                if (!string.IsNullOrEmpty(strOrderCreateTime))
                                                {
                                                    DateTime orderCreateTime = Convert.ToDateTime(strOrderCreateTime);
                                                    orderNumber = orderCreateTime.Month.ToString().PadLeft(2, '0') + orderCreateTime.Day.ToString().PadLeft(2, '0') + orderID.ToString().PadLeft(6, '0') + orderCreateTime.Year.ToString().Substring(orderCreateTime.Year.ToString().Length - 2, 2);
                                                }

                                                string WXRemark = "交付内容：" + commodityName + "\n服务顾问：" + accountName + "\n\n本次商品交付需要您进行确认，请在会员菜单中确认完成，欢迎再次光临！";

                                                HS.Framework.Common.WeChat.WeChat we = new HS.Framework.Common.WeChat.WeChat();
                                                string accessToken = we.GetWeChatToken(model.CompanyID);
                                                if (!string.IsNullOrEmpty(accessToken))
                                                {
                                                    HS.Framework.Common.WeChat.Entity.MessageTemplate messageModel = new HS.Framework.Common.WeChat.Entity.MessageTemplate();
                                                    HS.Framework.Common.WeChat.WXCompanyInfoBase WXCompanyInfoBase = we.GetBaseInfo(model.CompanyID);
                                                    messageModel.template_id = WXCompanyInfoBase.AccountChangesTemplate;
                                                    messageModel.topcolor = "#000000";
                                                    messageModel.touser = weChatOpenID;
                                                    messageModel.data = new HS.Framework.Common.WeChat.Entity.TemplateDetail()
                                                    {
                                                        first = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#FF0000", value = "本次商品已经交付完成\n" },
                                                        keyword1 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = orderNumber },
                                                        keyword2 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = finishTime.ToString("yyyy-MM-dd HH:mm") },
                                                        remark = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = WXRemark }
                                                    };

                                                    we.TemplateMessageSend(messageModel, model.CompanyID, 4, accessToken);
                                                }
                                            }
                                            #endregion
                                        }
                                        catch (Exception)
                                        {

                                        }
                                    });
                                }
                                #endregion
                            }
                        }
                        #endregion
                    }
                }
                db.CommitTransaction();
                return 1;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="copmanyID"></param>
        /// <param name="orderID"></param>
        /// <param name="courseID"></param>
        /// <param name="type">0:加一个 1:减一个</param>
        /// <param name="updaterID"></param>
        /// <returns></returns>
        public int updateServiceTGTotalCount(int copmanyID, int orderID, int orderObjectID, int type, int updaterID)
        {
            using (DbManager db = new DbManager())
            {
                int changeCount = 1;
                if (type == 1)
                {
                    changeCount = -1;
                }

                DateTime dt = DateTime.Now.ToLocalTime();

                DataTable datatable = new DataTable();

                //TGStatus 状态：1：已完成 2：进行中 3：待确认
                string strSelSql = @" SELECT  T1.TGFinishedCount,T1.TGPastCount,T1.TGTotalCount  
                                      FROM    [TBL_ORDER_SERVICE] T1 WITH ( NOLOCK ) 
                                      WHERE   T1.CompanyID = @CompanyID 
                                              AND T1.ID = @OrderObjectID ";
                datatable = db.SetCommand(strSelSql
                    , db.Parameter("@CompanyID", copmanyID, DbType.Int32)
                    , db.Parameter("@OrderObjectID", orderObjectID, DbType.Int32)).ExecuteDataTable();

                if (datatable == null || datatable.Rows.Count <= 0)
                {
                    return 0;
                }

                int TGFinishedCount = StringUtils.GetDbInt(datatable.Rows[0]["TGFinishedCount"].ToString());
                int TGPastCount = StringUtils.GetDbInt(datatable.Rows[0]["TGPastCount"].ToString());
                int TGTotalCount = StringUtils.GetDbInt(datatable.Rows[0]["TGTotalCount"].ToString());

                if (TGFinishedCount - TGPastCount > 0)
                {
                    return 2;
                }


                db.BeginTransaction();

                #region 修改TBL_ORDER_SERVICE
                string addHisCourse = "INSERT INTO [HST_ORDER_SERVICE] SELECT * FROM [TBL_ORDER_SERVICE] WHERE CompanyID = @CompanyID AND ID = @OrderObjectID";
                int hisCourseCount = db.SetCommand(addHisCourse
                    , db.Parameter("@CompanyID", copmanyID, DbType.Int32)
                    , db.Parameter("@OrderObjectID", orderObjectID, DbType.Int32)).ExecuteNonQuery();

                if (hisCourseCount <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }



                string strUpdateSql = @"UPDATE  [TBL_ORDER_SERVICE]
                                        SET     TGTotalCount = TGTotalCount + @ChangeCount ,
                                                UpdaterID = @UpdaterID ,
                                                UpdateTime = @UpdateTime
                                        WHERE   CompanyID = @CompanyID
                                                AND ID = @OrderObjectID ";
                int updateCourseCount = db.SetCommand(strUpdateSql
                   , db.Parameter("@ChangeCount", changeCount, DbType.Int32)
                   , db.Parameter("@UpdaterID", updaterID, DbType.Int32)
                   , db.Parameter("@UpdateTime", dt, DbType.DateTime2)
                   , db.Parameter("@CompanyID", copmanyID, DbType.Int32)
                   , db.Parameter("@OrderObjectID", orderObjectID, DbType.Int32)).ExecuteNonQuery();

                if (updateCourseCount != 1)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                db.CommitTransaction();
                return 1;
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
                                        LEFT JOIN [TBL_BUSINESS_CONSULTANT] f ON a.ID=f.MasterID AND f.BusinessType=1 AND f.ConsultantType=1
                                        LEFT JOIN [ACCOUNT] d ON f.ConsultantID = d.UserID
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
                                                T1.IsDesignated ,
                                                T7.IsConfirmed ,"
                                                + strHeadImg +
                                        @" FROM    [TBL_TREATGROUP] T1 WITH ( NOLOCK )
                                                LEFT JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.OrderServiceID = T2.ID
                                                LEFT JOIN [ORDER] T3 WITH ( NOLOCK ) ON T2.OrderID = T3.ID
                                                LEFT JOIN [ACCOUNT] T4 WITH ( NOLOCK ) ON T1.ServicePIC = T4.UserID
                                                LEFT JOIN [CUSTOMER] T5 WITH ( NOLOCK ) ON T2.CustomerID = T5.UserID 
                                                LEFT JOIN [BRANCH] T6 WITH(NOLOCK) ON T1.BranchID = T6.ID 
                                                LEFT JOIN [SERVICE] T7 WITH(NOLOCK) ON T2.ServiceID=T7.ID 
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
                                                1 AS IsDesignated ,
                                                T7.IsConfirmed ,"
                                                + strHeadImg +
                                        @" FROM    [TBL_COMMODITY_DELIVERY] T1 WITH ( NOLOCK )
                                                    LEFT JOIN [TBL_ORDER_COMMODITY] T2 WITH ( NOLOCK ) ON T1.OrderObjectID = T2.ID
                                                    LEFT JOIN [ORDER] T3 WITH ( NOLOCK ) ON T2.OrderID = T3.ID
                                                    LEFT JOIN [ACCOUNT] T4 WITH ( NOLOCK ) ON T1.ServicePIC = T4.UserID
                                                    LEFT JOIN [CUSTOMER] T5 WITH ( NOLOCK ) ON T2.CustomerID = T5.UserID 
                                                    LEFT JOIN [BRANCH] T6 WITH(NOLOCK) ON T1.BranchID = T6.ID 
                                                    LEFT JOIN [COMMODITY] T7 WITH(NOLOCK) ON T2.CommodityID = T7.ID 
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

        public List<GetMyTodayDoTGList_Model> GetMyTodayDoTGList(TodayTGOperation_Model model, out int recordCount)
        {
            using (DbManager db = new DbManager())
            {
                string strSelectSql = "";
                string fileds = "  ROW_NUMBER() OVER ( ORDER BY TGStartTime DESC ) AS rowNum , *  ";



                string serviceSql = @"SELECT DISTINCT
                                            0 AS ProductType ,
                                            T2.OrderID AS OrderID ,
                                            T1.TGStartTime ,
                                            T3.PaymentStatus ,
                                            T2.ServiceName AS ProductName ,
                                            T2.TGTotalCount AS TotalCount ,
                                            1 AS FinishedCount ,
                                            T2.ID AS OrderObjectID ,
                                            T1.GroupNo ,
                                            T1.TGStatus AS Status ,
                                            T5.Name AS CustomerName ,
                                            T5.UserID AS CustomerID
                                    FROM    [TBL_TREATGROUP] T1 WITH ( NOLOCK )
                                            LEFT JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.OrderServiceID = T2.ID
                                            LEFT JOIN [ORDER] T3 WITH ( NOLOCK ) ON T2.OrderID = T3.ID
                                            LEFT JOIN [TREATMENT] T4 WITH ( NOLOCK ) ON T1.GroupNo = T4.GroupNo
                                            LEFT JOIN [CUSTOMER] T5 WITH ( NOLOCK ) ON T2.CustomerID = T5.UserID
                                            LEFT JOIN [BRANCH] T6 WITH ( NOLOCK ) ON T1.BranchID = T6.ID 
                                    WHERE   T1.CompanyID = @CompanyID
                                            AND T2.Status <> 3
                                            AND T3.RecordType = 1
                                            AND T1.TGStartTime > T6.StartTime
                                            AND T1.TGStatus <> 3
                                            AND T1.BranchID = @BranchID ";


                string commoditySql = @"SELECT  1 AS ProductType ,
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
                                                T5.UserID AS CustomerID
                                        FROM    [TBL_COMMODITY_DELIVERY] T1 WITH ( NOLOCK )
                                                LEFT JOIN [TBL_ORDER_COMMODITY] T2 WITH ( NOLOCK ) ON T1.OrderObjectID = T2.ID
                                                LEFT JOIN [ORDER] T3 WITH ( NOLOCK ) ON T2.OrderID = T3.ID
                                                LEFT JOIN [CUSTOMER] T5 WITH ( NOLOCK ) ON T2.CustomerID = T5.UserID
                                                LEFT JOIN [BRANCH] T6 WITH ( NOLOCK ) ON T1.BranchID = T6.ID
                                        WHERE   T1.CompanyID = @CompanyID
                                                AND T2.Status <> 3
                                                AND T3.RecordType = 1
                                                AND T1.CDStartTime > T6.StartTime
                                                AND T1.Status <> 3
                                                AND T1.BranchID = @BranchID ";



                if (model.ServicePIC > 0)
                {
                    serviceSql += " AND ( T1.ServicePIC = @ServicePIC  OR T4.ExecutorID = @ServicePIC  ) ";
                    commoditySql += " AND T1.ServicePIC = @ServicePIC ";
                }

                if (model.CustomerID > 0)
                {
                    serviceSql += " AND T2.CustomerID=@CustomerID ";
                    commoditySql += " AND T2.CustomerID=@CustomerID ";
                }

                if (model.Status > 0)
                {
                    serviceSql += " AND T1.TGStatus=@Status ";
                    commoditySql += " AND T1.Status=@Status ";
                }

                if (model.PageIndex > 1)
                {
                    serviceSql += " AND T1.TGStartTime <= @TGStartTime";
                    commoditySql += " AND T1.CDStartTime <= @TGStartTime";
                }

                if (model.FilterByTimeFlag == 1)
                {
                    serviceSql += Common.APICommon.getSqlWhereData_1_7_2(4, model.StartTime, model.EndTime, " T1.TGStartTime");
                    commoditySql += Common.APICommon.getSqlWhereData_1_7_2(4, model.StartTime, model.EndTime, " T1.CDStartTime");
                }

                if (model.ProductType == 0)
                {
                    strSelectSql = serviceSql;
                }
                else if (model.ProductType == 1)
                {
                    strSelectSql = commoditySql;
                }
                else
                {
                    strSelectSql = serviceSql + " UNION ALL " + commoditySql;
                }



                string strSql = " SELECT  {0} from ({1}) as b ";

                string strCountSql = string.Format(strSql, " count(0) ", strSelectSql);

                string strgetListSql = "select * from( " + string.Format(strSql, fileds, strSelectSql) + " ) a where  rowNum between  " + ((model.PageIndex - 1) * model.PageSize + 1) + " and " + model.PageIndex * model.PageSize;


                recordCount = db.SetCommand(strCountSql
               , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
               , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
               , db.Parameter("@ServicePIC", model.ServicePIC, DbType.Int32)
               , db.Parameter("@Status", model.Status, DbType.Int32)
               , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
               , db.Parameter("@TGStartTime", model.TGStartTime, DbType.DateTime)).ExecuteScalar<int>();

                if (recordCount < 0)
                {
                    return null;
                }

                List<GetMyTodayDoTGList_Model> list = db.SetCommand(strgetListSql
                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                , db.Parameter("@ServicePIC", model.ServicePIC, DbType.Int32)
                , db.Parameter("@Status", model.Status, DbType.Int32)
                , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                , db.Parameter("@TGStartTime", model.TGStartTime, DbType.DateTime)).ExecuteList<GetMyTodayDoTGList_Model>();

                return list;
            }
        }

        public int CompleteOrderObject(UtilityOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                if (model.ProductType == 0)
                {
                    #region 服务
                    DataTable dt = new DataTable();

                    #region 查询基本数据
                    string strSelOrderServiceSql = @"SELECT  T1.TGExecutingCount ,
                                                                T1.TGFinishedCount ,
                                                                T1.TGTotalCount 
                                                        FROM    [TBL_ORDER_SERVICE] T1 WITH(NOLOCK)
                                                        WHERE   T1.CompanyID = @CompanyID
                                                                AND T1.ID = @OrderObjectID
                                                                AND Status = 1"; //1:未完成 2已完成 3亿取消 4已中止
                    dt = db.SetCommand(strSelOrderServiceSql
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@OrderObjectID", model.OrderObjectID, DbType.Int32)).ExecuteDataTable();

                    if (dt == null || dt.Rows.Count < 1)
                    {
                        db.RollbackTransaction();
                        return 3;
                    }

                    int finishedCount = StringUtils.GetDbInt(dt.Rows[0]["TGFinishedCount"].ToString());
                    int executingCount = StringUtils.GetDbInt(dt.Rows[0]["TGExecutingCount"].ToString());
                    int totalCount = StringUtils.GetDbInt(dt.Rows[0]["TGTotalCount"].ToString());

                    if (dt == null || dt.Rows.Count <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    if (executingCount > 0)
                    {
                        db.RollbackTransaction();
                        return 2;
                    }

                    if (finishedCount != totalCount && totalCount > 0)
                    {
                        db.RollbackTransaction();
                        return 2;
                    }
                    #endregion

                    #region 修改订单
                    string strAddHisCourse = @"INSERT INTO [HST_ORDER_SERVICE] SELECT * FROM [TBL_ORDER_SERVICE] WHERE CompanyID = @CompanyID AND ID = @OrderObjectID";
                    int hisCourseCount = db.SetCommand(strAddHisCourse
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@OrderObjectID", model.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                    if (hisCourseCount <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    string strUpdateOrderCommodityStatusSql = @" UPDATE [TBL_ORDER_SERVICE] SET Status=@Status ,UpdaterID=@UpdaterID ,UpdateTime=@UpdateTime WHERE CompanyID = @CompanyID AND ID = @OrderObjectID ";
                    int updateOrderCommodityStatusRes = db.SetCommand(strUpdateOrderCommodityStatusSql
                                                , db.Parameter("@Status", 2, DbType.Int32)//1:未完成 2已完成 3亿取消 4已中止
                                                , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                                , db.Parameter("@UpdateTime", model.Time, DbType.DateTime)
                                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                , db.Parameter("@OrderObjectID", model.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                    if (updateOrderCommodityStatusRes != 1)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    #endregion

                    #endregion
                }
                else
                {
                    #region 商品
                    DataTable dt = new DataTable();

                    #region 查询基本数据
                    string strSelOrderServiceSql = @"SELECT  T1.UndeliveredAmount ,
                                                                T1.DeliveredAmount ,
                                                                T1.Quantity ,
                                                        FROM    [TBL_ORDER_COMMODITY] T1 WITH ( NOLOCK )
                                                        WHERE   T1.CompanyID = @CompanyID
                                                                AND T1.Status = 1"; //1:未完成 2已完成 3亿取消 4已中止
                    dt = db.SetCommand(strSelOrderServiceSql
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@OrderObjectID", model.OrderObjectID, DbType.Int32)).ExecuteDataTable();

                    if (dt == null || dt.Rows.Count < 1)
                    {
                        db.RollbackTransaction();
                        return 3;
                    }

                    int finishedCount = StringUtils.GetDbInt(dt.Rows[0]["DeliveredAmount"].ToString());
                    int executingCount = StringUtils.GetDbInt(dt.Rows[0]["UndeliveredAmount"].ToString());
                    int totalCount = StringUtils.GetDbInt(dt.Rows[0]["Quantity"].ToString());

                    if (dt == null || dt.Rows.Count <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    if (executingCount > 0 || finishedCount != totalCount)
                    {
                        db.RollbackTransaction();
                        return 2;
                    }
                    #endregion

                    #region 修改订单
                    string strAddHisOrderCommodity = @"INSERT INTO [HST_ORDER_COMMODITY] SELECT * FROM [TBL_ORDER_COMMODITY] WHERE CompanyID = @CompanyID AND ID = @OrderObjectID";
                    int hisOrderCommodityCount = db.SetCommand(strAddHisOrderCommodity
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@OrderObjectID", model.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                    if (hisOrderCommodityCount <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    string strUpdateOrderCommodityStatusSql = @" UPDATE [TBL_ORDER_COMMODITY] SET Status=@Status ,UpdaterID=@UpdaterID ,UpdateTime=@UpdateTime WHERE CompanyID = @CompanyID AND ID = @OrderObjectID ";
                    int updateOrderCommodityStatusRes = db.SetCommand(strUpdateOrderCommodityStatusSql
                                                , db.Parameter("@Status", 2, DbType.Int32) //1:未完成 2:已完成 3:亿取消 4:已中止
                                                , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                                , db.Parameter("@UpdateTime", model.Time, DbType.DateTime)
                                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                , db.Parameter("@OrderObjectID", model.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                    if (updateOrderCommodityStatusRes != 1)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    #endregion
                    #endregion
                }

                string strAddHisOrderSql = "INSERT INTO [HISTORY_ORDER] SELECT * FROM [ORDER] WHERE CompanyID = @CompanyID AND ID = @OrderID";
                int addOrderRes = db.SetCommand(strAddHisOrderSql
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@OrderID", model.OrderID, DbType.Int32)).ExecuteNonQuery();

                if (addOrderRes <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                string strUpdateOrderStatusSql = @" UPDATE [ORDER] SET Status=@Status ,UpdaterID = @UpdaterID ,UpdateTime = @UpdateTime WHERE CompanyID = @CompanyID AND ID = @OrderID ";
                int updateOrderStatusRes = db.SetCommand(strUpdateOrderStatusSql
                                            , db.Parameter("@Status", 2, DbType.Int32)//1:未完成 2已完成 3亿取消 4已中止
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@OrderID", model.OrderID, DbType.Int32)
                                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                            , db.Parameter("@UpdateTime", model.Time, DbType.DateTime)).ExecuteNonQuery();

                if (updateOrderStatusRes != 1)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                db.CommitTransaction();
                return 1;
            }
        }

        public int CompleteTreatGroup(CompleteTGOperation_Model model)
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
                                                                T1.CustomerID ,
                                                                T1.TGExecutingCount ,
                                                                T1.TGFinishedCount ,
                                                                T1.TGTotalCount,
                                                                T2.IsConfirmed,
																T3.ConsultantID AS ResponsiblePersonID ,
                                                                T2.ServiceName,
                                                                T1.Remark,
																T2.NeedVisit, 
                                                                T1.ServiceCode  
                                                        FROM    [TBL_ORDER_SERVICE] T1 WITH(NOLOCK)
                                                        INNER JOIN [SERVICE] T2 WITH(NOLOCK) ON T1.ServiceID=T2.ID 
                                                        LEFT JOIN [TBL_BUSINESS_CONSULTANT] T3 WITH(NOLOCK) ON T1.OrderID=T3.MasterID AND T3.BusinessType=1 AND T3.ConsultantType=1 
                                                        WHERE   T1.CompanyID = @CompanyID
                                                                AND T1.ID = @OrderObjectID
                                                                AND T1.Status = 1 "; //T1.Status 1:未完成 2已完成 3亿取消 4已中止
                        dt = db.SetCommand(strSelOrderServiceSql
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)).ExecuteDataTable();



                        if (dt == null || dt.Rows.Count <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        int finishedCount = StringUtils.GetDbInt(dt.Rows[0]["TGFinishedCount"].ToString());
                        int executingCount = StringUtils.GetDbInt(dt.Rows[0]["TGExecutingCount"].ToString());
                        int totalCount = StringUtils.GetDbInt(dt.Rows[0]["TGTotalCount"].ToString());
                        int isConfirmed = StringUtils.GetDbInt(dt.Rows[0]["IsConfirmed"].ToString());
                        int responsiblePersonID = StringUtils.GetDbInt(dt.Rows[0]["responsiblePersonID"].ToString());
                        string remark = dt.Rows[0]["Remark"].ToString();
                        string serviceName = dt.Rows[0]["ServiceName"].ToString();
                        bool NeedVisit = StringUtils.GetDbBool(dt.Rows[0]["NeedVisit"].ToString());
                        long serviceCode = StringUtils.GetDbLong(dt.Rows[0]["ServiceCode"].ToString());
                        model.CustomerID = StringUtils.GetDbInt(dt.Rows[0]["CustomerID"].ToString());

                        string selTGStatusSql = @" SELECT T1.TGStatus
                                                    FROM    TBL_TREATGROUP T1 WITH ( NOLOCK )
                                                    WHERE   T1.OrderServiceID = @OrderObjectID
                                                            AND T1.CompanyID = @CompanyID
                                                            AND T1.GroupNo = @GroupNo ";

                        int TGstatusRes = db.SetCommand(selTGStatusSql
                           , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                           , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)
                           , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)).ExecuteScalar<int>();

                        if (TGstatusRes != 1)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        if (model.CustomerID <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        if (totalCount != 0)
                        {
                            if ((finishedCount + 1 > totalCount) || executingCount <= 0)
                            {
                                db.RollbackTransaction();
                                return 2;
                            }
                        }

                        int serviceID = StringUtils.GetDbInt(dt.Rows[0]["ServiceID"].ToString());
                        if (serviceID <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        int TGstatus = 2;//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                        int treatMentStatus = 2; //状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认


                        string strSelectLoginMobileSql = @"select LoginMobile from [USER] Where ID =@CustomerID";
                        string loginMobile = db.SetCommand(strSelectLoginMobileSql, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteScalar<string>();

                        if (!string.IsNullOrWhiteSpace(loginMobile))//没有登陆手机号 就算需要待顾客确认 也直接完成
                        {
                            //0:不再需要确认，1:需要客户端确认，2：需要顾客签字确认 
                            if (isConfirmed == 1)
                            {
                                //待顾客确认状态
                                TGstatus = 5;
                                treatMentStatus = 5;
                            }
                        }

                        if (isConfirmed == 2)
                        {
                            #region 签名
                            if (string.IsNullOrWhiteSpace(model.SignImg) || string.IsNullOrWhiteSpace(model.ImageFormat))
                            {
                                db.RollbackTransaction();
                                return 4;
                            }
                            string imgName = "";
                            bool isUpLoad = addSignImgFiles(model.CompanyID, model.CustomerID, item.GroupNo, model.ImageFormat, model.SignImg, out imgName);
                            if (!isUpLoad)
                            {
                                db.RollbackTransaction();
                                return 3;
                            }
                            else
                            {
                                string strSignSql = @"INSERT INTO IMAGE_SIGN( CompanyID ,CustomerID ,GroupNo ,ProductType ,[FileName] ,CreatorID ,CreateTime ) 
                                                        VALUES (@CompanyID ,@CustomerID ,@GroupNo ,@ProductType ,@FileName ,@CreatorID ,@CreateTime)";
                                int addSignRes = db.SetCommand(strSignSql
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                        , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)
                                        , db.Parameter("@ProductType", 0, DbType.Int32)
                                        , db.Parameter("@FileName", imgName, DbType.String)
                                        , db.Parameter("@CreatorID", model.UpdaterID, DbType.Int32)
                                        , db.Parameter("@CreateTime", model.UpdateTime, DbType.DateTime2)).ExecuteNonQuery();

                                if (addSignRes != 1)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }
                            }
                            #endregion
                        }

                        string strSelTreatmentSql = "SELECT ID FROM [TREATMENT] WHERE CompanyID = @CompanyID AND GroupNo = @GroupNo AND Status=1";
                        List<int> treatmentIDList = db.SetCommand(strSelTreatmentSql
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)).ExecuteScalarList<int>();

                        if (treatmentIDList != null && treatmentIDList.Count > 0)
                        {
                            #region 修改Treatment
                            string strAddTreatmentHisSql = @"INSERT INTO [HISTORY_TREATMENT] SELECT * FROM [TREATMENT] WHERE CompanyID = @CompanyID AND GroupNo = @GroupNo AND Status=1";
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
                                                                AND GroupNo = @GroupNo AND Status=1 ";

                            int updateTreatmentCount = db.SetCommand(strUpdateTreatmentSql
                                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)
                                                , db.Parameter("@Status", treatMentStatus, DbType.Int32)//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                                                , db.Parameter("@FinishTime", model.UpdateTime, DbType.DateTime2)
                                                , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                                , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)).ExecuteNonQuery();

                            if (updateTreatmentCount <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                            #endregion

                            string strSelCompanyComissionCalcSql = " SELECT [ComissionCalc] FROM COMPANY WHERE ID=@CompanyID ";
                            bool isComissionCalc = db.SetCommand(strSelCompanyComissionCalcSql
                                                 , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<bool>();

                            if (isComissionCalc)
                            {
                                #region 记录业绩分享
                                string strSelOperateComissionRuleSql = @" SELECT  T1.ServiceCode ,
                                                                    T1.ProfitPct ,
                                                                    T1.HaveSubService ,
                                                                    T1.DesOPCommType ,
                                                                    T1.DesOPCommValue ,
                                                                    T1.OPCommType ,
                                                                    T1.OPCommValue
                                                            FROM    [TBL_OPERATE_COMMISSION_RULE] T1 WITH ( NOLOCK )
                                                            WHERE   T1.CompanyID = @CompanyID
                                                                    AND T1.ServiceCode = @ServiceCode
                                                                    AND T1.RecordType = 1 ";
                                Operate_Commission_Rule_Model operateCommissionRuleModel = db.SetCommand(strSelOperateComissionRuleSql

                                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                    , db.Parameter("@ServiceCode", serviceCode, DbType.Int64)).ExecuteObject<Operate_Commission_Rule_Model>();

                                foreach (int treatmentID in treatmentIDList)
                                {
                                    string strSelStatusSql = @"SELECT  T1.Status ,
                                                    T4.IsConfirmed, 
                                                    T1.SubServiceID, 
                                                    T1.IsDesignated, 
                                                    T3.ServiceCode,
                                                    T3.SumCalcPrice, 
                                                    T1.ExecutorID, 
                                                    T3.OrderID    
                                            FROM    [TREATMENT] T1 WITH ( NOLOCK )
                                                    INNER JOIN [TBL_TREATGROUP] T2 WITH ( NOLOCK ) ON T1.GroupNo = T2.GroupNo
                                                    INNER JOIN [TBL_ORDER_SERVICE] T3 WITH ( NOLOCK ) ON T2.OrderServiceID = T3.ID
                                                    INNER JOIN [SERVICE] T4 WITH ( NOLOCK ) ON T3.ServiceID = T4.ID
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.ID = @TreatmentID";

                                    DataTable treatmentDt = db.SetCommand(strSelStatusSql
                                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                            , db.Parameter("@TreatmentID", treatmentID, DbType.Int32)).ExecuteDataTable();

                                    if (treatmentDt == null || treatmentDt.Rows.Count <= 0)
                                    {
                                        return 0;
                                    }

                                    int status = StringUtils.GetDbInt(treatmentDt.Rows[0]["Status"]);
                                    int subServiceID = StringUtils.GetDbInt(treatmentDt.Rows[0]["SubServiceID"]);
                                    bool isDesignated = StringUtils.GetDbBool(treatmentDt.Rows[0]["IsDesignated"]);
                                    decimal sumCalcPrice = StringUtils.GetDbDecimal(treatmentDt.Rows[0]["SumCalcPrice"]);
                                    int executorID = StringUtils.GetDbInt(treatmentDt.Rows[0]["ExecutorID"]);
                                    int orderID = StringUtils.GetDbInt(treatmentDt.Rows[0]["OrderID"]);

                                    if (operateCommissionRuleModel != null && operateCommissionRuleModel.HaveSubService)
                                    {
                                        string strSelSubServiceCommissionRuleSql = @" SELECT T1.ServiceCode, T1.SubServiceCode, T1.DesSubServiceProfitPct ,
                                                                    T1.DesSubOPCommType ,
                                                                    T1.DesSubOPCommValue ,
                                                                    T1.SubServiceProfitPct ,
                                                                    T1.SubOPCommType ,
                                                                    T1.SubOPCommValue
                                                            FROM    [TBL_SUBSERVICE_COMMISSION_RULE] T1 WITH ( NOLOCK )
                                                            INNER JOIN [TBL_SUBSERVICE] T2 WITH(NOLOCK) ON T1.SubServiceCode=T2.SubServiceCode
                                                            WHERE   T1.CompanyID = @CompanyID
                                                                    AND T1.ServiceCode = @ServiceCode
                                                                    AND T2.ID = @SubServiceID ";

                                        SubService_Commission_Rule_Model subServiceRuleModel = db.SetCommand(strSelSubServiceCommissionRuleSql
                                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                        , db.Parameter("@ServiceCode", serviceCode, DbType.Int64)
                                                        , db.Parameter("@SubServiceID", subServiceID, DbType.Int32)).ExecuteObject<SubService_Commission_Rule_Model>();

                                        if (treatmentID > 0 && subServiceRuleModel.ServiceCode > 0 && subServiceRuleModel.SubServiceCode > 0)
                                        {
                                            #region 有子服务的情况
                                            decimal subServiceProfitPct = subServiceRuleModel.SubServiceProfitPct;
                                            int subOPCommType = subServiceRuleModel.SubOPCommType;
                                            decimal subOPCommValue = subServiceRuleModel.SubOPCommValue;
                                            object commFlag = DBNull.Value;

                                            if (isDesignated)
                                            {
                                                subServiceProfitPct = subServiceRuleModel.DesSubServiceProfitPct;
                                                subOPCommType = subServiceRuleModel.DesSubOPCommType;
                                                subOPCommValue = subServiceRuleModel.DesSubOPCommValue;
                                                commFlag = 2;
                                            }

                                            decimal profit = sumCalcPrice * operateCommissionRuleModel.ProfitPct;

                                            decimal AccountProfit = profit * subServiceProfitPct;//员工业绩(=实际业绩 x 员工业绩计算比例)
                                            decimal AccountComm = subOPCommValue;
                                            if (subOPCommType == 1)//1:按比例 2:固定值
                                            {
                                                AccountComm = AccountProfit * subOPCommValue;
                                            }

                                            string strAddProfitDetailSql = @" INSERT INTO TBL_PROFIT_COMMISSION_DETAIL ( CompanyID ,BranchID ,SourceType ,SourceID ,SubSourceID ,Income ,ProfitPct ,Profit ,CommType ,CommValue ,AccountID ,AccountProfitPct ,AccountProfit ,AccountComm ,CommFlag ,CreatorID ,CreateTime ) 
                                                                    VALUES ( @CompanyID ,@BranchID ,@SourceType ,@SourceID ,@SubSourceID ,@Income ,@ProfitPct ,@Profit ,@CommType ,@CommValue ,@AccountID ,@AccountProfitPct ,@AccountProfit ,@AccountComm ,@CommFlag ,@CreatorID ,@CreateTime ) ";

                                            int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                            , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                                            , db.Parameter("@SourceType", 2, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                                                            , db.Parameter("@SourceID", treatmentID, DbType.Int64)
                                                                            , db.Parameter("@SubSourceID", orderID, DbType.Int64)
                                                                            , db.Parameter("@Income", sumCalcPrice, DbType.Decimal)//收入 操作业绩时，为B价格
                                                                            , db.Parameter("@ProfitPct", operateCommissionRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                                                            , db.Parameter("@Profit", profit, DbType.Decimal)//实际业绩
                                                                            , db.Parameter("@CommType", subOPCommType, DbType.Int32)//该业绩的提成方式
                                                                            , db.Parameter("@CommValue", subOPCommValue, DbType.Decimal)//该业绩的提成数值
                                                                            , db.Parameter("@AccountID", executorID, DbType.Int32)//获得该业绩的员工ID
                                                                            , db.Parameter("@AccountProfitPct", subServiceProfitPct, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                                                            , db.Parameter("@AccountProfit", AccountProfit, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                                                            , db.Parameter("@AccountComm", AccountComm, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
                                                                            , db.Parameter("@CommFlag", commFlag, DbType.Int32)//1：首充 2：指定 3：E账户
                                                                            , db.Parameter("@CreatorID", model.UpdaterID, DbType.Int32)
                                                                            , db.Parameter("@CreateTime", model.UpdateTime, DbType.DateTime)).ExecuteNonQuery();

                                            if (addProfitDetailRes != 1)
                                            {
                                                db.RollbackTransaction();
                                                return 0;
                                            }
                                            #endregion
                                        }
                                    }
                                    else if (treatmentID > 0 && operateCommissionRuleModel != null && operateCommissionRuleModel.ServiceCode > 0)
                                    {
                                        #region 没有子服务
                                        int OPCommType = operateCommissionRuleModel.OPCommType;
                                        decimal OPCommValue = operateCommissionRuleModel.OPCommValue;
                                        object commFlag = DBNull.Value;

                                        if (isDesignated)
                                        {
                                            OPCommType = operateCommissionRuleModel.DesOPCommType;
                                            OPCommValue = operateCommissionRuleModel.DesOPCommValue;
                                            commFlag = 2;
                                        }

                                        decimal profit = sumCalcPrice * operateCommissionRuleModel.ProfitPct;

                                        decimal AccountProfit = profit * 1;//员工业绩(=实际业绩 x 员工业绩计算比例)
                                        decimal AccountComm = OPCommValue;
                                        if (OPCommType == 1)//1:按比例 2:固定值
                                        {
                                            AccountComm = AccountProfit * OPCommValue;
                                        }

                                        string strAddProfitDetailSql = @" INSERT INTO TBL_PROFIT_COMMISSION_DETAIL ( CompanyID ,BranchID ,SourceType ,SourceID ,SubSourceID,Income ,ProfitPct ,Profit ,CommType ,CommValue ,AccountID ,AccountProfitPct ,AccountProfit ,AccountComm ,CommFlag ,CreatorID ,CreateTime ) 
                                                                    VALUES ( @CompanyID ,@BranchID ,@SourceType ,@SourceID ,@SubSourceID ,@Income ,@ProfitPct ,@Profit ,@CommType ,@CommValue ,@AccountID ,@AccountProfitPct ,@AccountProfit ,@AccountComm ,@CommFlag ,@CreatorID ,@CreateTime ) ";

                                        int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                        , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                                        , db.Parameter("@SourceType", 2, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                                                        , db.Parameter("@SourceID", treatmentID, DbType.Int64)
                                                                        , db.Parameter("@SubSourceID", orderID, DbType.Int64)
                                                                        , db.Parameter("@Income", sumCalcPrice, DbType.Decimal)//收入 操作业绩时，为B价格
                                                                        , db.Parameter("@ProfitPct", operateCommissionRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                                                        , db.Parameter("@Profit", profit, DbType.Decimal)//实际业绩
                                                                        , db.Parameter("@CommType", OPCommType, DbType.Int32)//该业绩的提成方式
                                                                        , db.Parameter("@CommValue", OPCommValue, DbType.Decimal)//该业绩的提成数值
                                                                        , db.Parameter("@AccountID", executorID, DbType.Int32)//获得该业绩的员工ID
                                                                        , db.Parameter("@AccountProfitPct", 1, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                                                        , db.Parameter("@AccountProfit", AccountProfit, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                                                        , db.Parameter("@AccountComm", AccountComm, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
                                                                        , db.Parameter("@CommFlag", commFlag, DbType.Int32)//1：首充 2：指定 3：E账户
                                                                        , db.Parameter("@CreatorID", model.UpdaterID, DbType.Int32)
                                                                        , db.Parameter("@CreateTime", model.UpdateTime, DbType.DateTime)).ExecuteNonQuery();

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
                                                        AND GroupNo = @GroupNo
                                                        AND TGStatus = 1 ";
                        int updateTGCount = db.SetCommand(strUpdateTGSql
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)
                                            , db.Parameter("@TGStatus", TGstatus, DbType.Int32)//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                                            , db.Parameter("@TGEndTime", model.UpdateTime, DbType.DateTime2)
                                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                            , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)).ExecuteNonQuery();

                        if (updateTGCount != 1)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        #endregion

                        #region 修改TBL_ORDER_SERVICE表TGExecutingCount-1 TGFinishedCount+1
                        string strAddHisCourse = @"INSERT INTO [HST_ORDER_SERVICE] SELECT * FROM [TBL_ORDER_SERVICE] WHERE CompanyID = @CompanyID AND ID = @OrderObjectID";
                        int hisCourseCount = db.SetCommand(strAddHisCourse
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                        if (hisCourseCount <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        string strUpdateCourseSql = @"UPDATE  [TBL_ORDER_SERVICE]
                                                    SET     TGFinishedCount = TGFinishedCount + 1 ,
                                                            TGExecutingCount = TGExecutingCount - 1 ,
                                                            UpdaterID = @UpdaterID ,
                                                            UpdateTime = @UpdateTime
                                                    WHERE   CompanyID = @CompanyID
                                                            AND ID = @OrderObjectID";

                        int updateCourseRes = db.SetCommand(strUpdateCourseSql
                                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                            , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                        if (updateCourseRes != 1)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        // 无限次服务不会自动完成订单
                        if (totalCount > 0)
                        {
                            #region 再次获取数量 看是否是最后一次
                            dt = db.SetCommand(strSelOrderServiceSql
                               , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                               , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)
                               , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)).ExecuteDataTable();


                            finishedCount = StringUtils.GetDbInt(dt.Rows[0]["TGFinishedCount"].ToString());
                            executingCount = StringUtils.GetDbInt(dt.Rows[0]["TGExecutingCount"].ToString());
                            totalCount = StringUtils.GetDbInt(dt.Rows[0]["TGTotalCount"].ToString());
                            #endregion

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

                                if (count <= 0)
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

                                    if (updateOrderStatusRes != 1)
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

                                    if (updateOrderCommodityStatusRes != 1)
                                    {
                                        db.RollbackTransaction();
                                        return 0;
                                    }
                                    #endregion
                                }
                            }
                        }
                        #endregion

                        if (NeedVisit)
                        {
                            #region 回访
                            string strSqlTGStart = " select TGStartTime from TBL_TREATGROUP where GroupNo=@GroupNo and CompanyID=@CompanyID ";

                            string strTGStart = db.SetCommand(strSqlTGStart
                                , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.String)).ExecuteScalar<string>();


                            long TaskID = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "TaskID", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<long>();
                            if (TaskID == 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            string strSqlEndtTime = "select dateadd(dd,VisitTime,GETDATE()) from [SERVICE] T1 where ID = @ServiceID";

                            //DateTime scdlStartTime = db.SetCommand(strSqlStartTime, db.Parameter("@ServiceID", serviceID, DbType.Int32)).ExecuteScalar<DateTime>();
                            DateTime scdlEndTime = db.SetCommand(strSqlEndtTime, db.Parameter("@ServiceID", serviceID, DbType.Int32)).ExecuteScalar<DateTime>();
                            string TaskDescription = serviceName + "的服务回访\n服务时间" + strTGStart;
                            string strSqlTask = @" INSERT INTO [TBL_TASK]
           ([BranchID],[ID],[TaskOwnerType],[TaskOwnerID],[TaskType],[TaskName],[TaskStatus],[TaskScdlStartTime],[TaskScdlEndTime],[ActedOrderID],[ActedOrderServiceID],[ActedTreatGroupID],[CompanyID],[CreatorID],[CreateTime],[RecordType],[Remark],[TaskDescription])
     VALUES (@BranchID,@ID,1,@TaskOwnerID,2,@TaskName,2,@TaskScdlStartTime,@TaskScdlEndTime,@ActedOrderID,@ActedOrderServiceID,@ActedTreatGroupID,@CompanyID,@CreatorID,@CreateTime,1,@Remark,@TaskDescription) ";
                            int rows = db.SetCommand(strSqlTask
                       , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                       , db.Parameter("@ID", TaskID, DbType.Int64)
                       , db.Parameter("@TaskOwnerID", model.CustomerID, DbType.Int32)
                       , db.Parameter("@TaskName", serviceName, DbType.String)
                       , db.Parameter("@TaskScdlStartTime", model.UpdateTime, DbType.DateTime)
                       , db.Parameter("@TaskScdlEndTime", scdlEndTime, DbType.DateTime)
                       , db.Parameter("@ActedOrderID", item.OrderID, DbType.Int32)
                       , db.Parameter("@ActedOrderServiceID", item.OrderObjectID, DbType.Int32)
                       , db.Parameter("@ActedTreatGroupID", item.GroupNo, DbType.Int64)
                       , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                       , db.Parameter("@CreatorID", model.UpdaterID, DbType.Int32)
                       , db.Parameter("@CreateTime", model.UpdateTime, DbType.DateTime)
                       , db.Parameter("@Remark", remark, DbType.String)
                       , db.Parameter("@TaskDescription", TaskDescription, DbType.String)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            long SchduleID = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "ScheduleID", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<long>();
                            if (SchduleID == 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            if (responsiblePersonID > 0)
                            {
                                string strSqlSchdule = @" INSERT INTO [dbo].[TBL_SCHEDULE]
([BranchID],[ID],[ScheduleType],[UserID],[TaskID],[ScheduleName],[ScdlStartTime],[ScdlEndTime],[Reminded],[Repeat],[Remark],[ScheduleStatus],[CompanyID],[CreatorID],[CreateTime],[RecordType])
VALUES(@BranchID,@ID,2,@UserID,@TaskID,@ScheduleName,@ScdlStartTime,@ScdlEndTime,1,1,@Remark,2,@CompanyID,@CreatorID,@CreateTime,1) ";

                                rows = db.SetCommand(strSqlSchdule
                                , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                , db.Parameter("@ID", SchduleID, DbType.Int64)
                                , db.Parameter("@UserID", responsiblePersonID, DbType.Int32)
                                , db.Parameter("@TaskID", TaskID, DbType.Int64)
                                , db.Parameter("@ScheduleName", serviceName, DbType.String)
                                , db.Parameter("@ScdlStartTime", model.UpdateTime, DbType.DateTime)
                                , db.Parameter("@ScdlEndTime", scdlEndTime, DbType.DateTime)
                                , db.Parameter("@Remark", remark, DbType.String)
                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@CreatorID", model.UpdaterID, DbType.Int32)
                                , db.Parameter("@CreateTime", model.UpdateTime, DbType.DateTime)).ExecuteNonQuery();

                                if (rows == 0)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }
                            }

                            #endregion
                        }

                        #region 即时PUSH
                        string strSelLoginSql = @" SELECT  T3.WeChatOpenID ,
                                                            T4.BranchName ,
                                                            T2.OrderID ,
                                                            T2.ServiceName ,
                                                            T5.Name AS AccountName ,
                                                            T6.CreateTime ,
                                                            T3.Name AS CustomerName
                                                    FROM    [TBL_TREATGROUP] T1 WITH ( NOLOCK )
                                                            LEFT JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T1.OrderServiceID = T2.ID
                                                            LEFT JOIN [CUSTOMER] T3 WITH ( NOLOCK ) ON T2.CustomerID = T3.UserID
                                                            LEFT JOIN [BRANCH] T4 WITH ( NOLOCK ) ON T2.BranchID = T4.ID
                                                            LEFT JOIN [ACCOUNT] T5 WITH ( NOLOCK ) ON T1.ServicePIC = T5.UserID
                                                            LEFT JOIN [ORDER] T6 WITH ( NOLOCK ) ON T2.OrderID = T6.ID
                                                    WHERE   T1.GroupNo = @GroupNo
                                                            AND ISNULL(T3.WeChatOpenID, '') <> ''  ";
                        DataTable pushmodel = db.SetCommand(strSelLoginSql
                                       , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)).ExecuteDataTable();

                        if (pushmodel != null)
                        {
                            Task.Factory.StartNew(() =>
                            {
                                try
                                {
                                    #region 微信push
                                    string weChatOpenID = StringUtils.GetDbString(pushmodel.Rows[0]["WeChatOpenID"].ToString());
                                    if (!string.IsNullOrEmpty(weChatOpenID))
                                    {
                                        DateTime finishTime = model.UpdateTime;
                                        string branchName = StringUtils.GetDbString(pushmodel.Rows[0]["BranchName"].ToString());
                                        string accountName = StringUtils.GetDbString(pushmodel.Rows[0]["AccountName"].ToString());
                                        string customerName = StringUtils.GetDbString(pushmodel.Rows[0]["CustomerName"].ToString());
                                        string strOrderCreateTime = StringUtils.GetDbString(pushmodel.Rows[0]["CreateTime"]);
                                        int orderID = StringUtils.GetDbInt(pushmodel.Rows[0]["OrderID"]);
                                        string orderNumber = "";
                                        if (!string.IsNullOrEmpty(strOrderCreateTime))
                                        {
                                            DateTime orderCreateTime = Convert.ToDateTime(strOrderCreateTime);
                                            orderNumber = orderCreateTime.Month.ToString().PadLeft(2, '0') + orderCreateTime.Day.ToString().PadLeft(2, '0') + orderID.ToString().PadLeft(6, '0') + orderCreateTime.Year.ToString().Substring(orderCreateTime.Year.ToString().Length - 2, 2);
                                        }

                                        string WXRemark = "服务内容：" + serviceName + "\n服务顾问：" + accountName + "\n\n请在会员菜单中对我们的服务作出评价，欢迎再次光临！";
                                        if (isConfirmed == 1)
                                        {
                                            WXRemark = "服务内容：" + serviceName + "\n服务顾问：" + accountName + "\n\n本次服务需要您进行完成确认，请在会员菜单中进行确认并对我们的服务作出评价，欢迎再次光临！";
                                        }

                                        HS.Framework.Common.WeChat.WeChat we = new HS.Framework.Common.WeChat.WeChat();
                                        string accessToken = we.GetWeChatToken(model.CompanyID);
                                        if (!string.IsNullOrEmpty(accessToken))
                                        {
                                            HS.Framework.Common.WeChat.Entity.MessageTemplate messageModel = new HS.Framework.Common.WeChat.Entity.MessageTemplate();
                                            HS.Framework.Common.WeChat.WXCompanyInfoBase WXCompanyInfoBase = we.GetBaseInfo(model.CompanyID);
                                            messageModel.template_id = WXCompanyInfoBase.AccountChangesTemplate;
                                            messageModel.topcolor = "#000000";
                                            messageModel.touser = weChatOpenID;
                                            messageModel.data = new HS.Framework.Common.WeChat.Entity.TemplateDetail()
                                            {
                                                first = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#FF0000", value = "本次服务已经完成\n" },
                                                keyword1 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = orderNumber },
                                                keyword2 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = finishTime.ToString("yyyy-MM-dd HH:mm") },
                                                remark = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = WXRemark }
                                            };

                                            we.TemplateMessageSend(messageModel, model.CompanyID, 4, accessToken);
                                        }
                                    }
                                    #endregion
                                }
                                catch (Exception)
                                {

                                }
                            });
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
                                                                AND T1.Status = 1 "; //1:未完成 2已完成 3亿取消 4已中止
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
                        int isConfirmed = StringUtils.GetDbInt(dt.Rows[0]["IsConfirmed"].ToString());

                        if ((finishedCount + shouldDelivereCount > totalCount) || executingCount <= 0 || shouldDelivereCount <= 0)
                        {
                            db.RollbackTransaction();
                            return 2;
                        }

                        int commodityID = StringUtils.GetDbInt(dt.Rows[0]["CommodityID"].ToString());
                        if (commodityID <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        string selTGStatusSql = @" SELECT T1.Status
                                                    FROM    TBL_COMMODITY_DELIVERY T1 WITH ( NOLOCK )
                                                    WHERE   T1.OrderObjectID = @OrderObjectID
                                                            AND T1.CompanyID = @CompanyID
                                                            AND T1.ID = @GroupNo ";

                        int TGstatusRes = db.SetCommand(selTGStatusSql
                           , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                           , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)
                           , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)).ExecuteScalar<int>();

                        if (TGstatusRes != 1)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        #endregion

                        int deliveryStatus = 2; //状态：1:未完成、2：已完成 、3：已取消、4:已终止、5：交付待确认

                        string strSelectLoginMobileSql = @"select LoginMobile from [USER] Where ID =@CustomerID";
                        string loginMobile = db.SetCommand(strSelectLoginMobileSql, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteScalar<string>();

                        if (!string.IsNullOrWhiteSpace(loginMobile))
                        {
                            //0:不再需要确认，1:需要客户端确认，2：需要顾客签字确认 
                            if (isConfirmed == 1)
                            {
                                deliveryStatus = 5;
                            }
                        }

                        if (isConfirmed == 2)
                        {
                            #region 签名
                            if (string.IsNullOrWhiteSpace(model.SignImg) || string.IsNullOrWhiteSpace(model.ImageFormat))
                            {
                                db.RollbackTransaction();
                                return 4;
                            }

                            string imgName = "";
                            bool isUpLoad = addSignImgFiles(model.CompanyID, model.CustomerID, item.GroupNo, model.ImageFormat, model.SignImg, out imgName);
                            if (!isUpLoad)
                            {
                                db.RollbackTransaction();
                                return 3;
                            }
                            else
                            {
                                string strSignSql = @"INSERT INTO IMAGE_SIGN( CompanyID ,CustomerID ,GroupNo ,ProductType ,[FileName] ,CreatorID ,CreateTime ) 
                                                        VALUES (@CompanyID ,@CustomerID ,@GroupNo ,@ProductType ,@FileName ,@CreatorID ,@CreateTime)";
                                int addSignRes = db.SetCommand(strSignSql
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                        , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)
                                        , db.Parameter("@ProductType", 1, DbType.Int32)
                                        , db.Parameter("@FileName", imgName, DbType.String)
                                        , db.Parameter("@CreatorID", model.UpdaterID, DbType.Int32)
                                        , db.Parameter("@CreateTime", model.UpdateTime, DbType.DateTime2)).ExecuteNonQuery();

                                if (addSignRes != 1)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }
                            }
                            #endregion
                        }

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
                                                            AND ID = @GroupNo
                                                            and Status = 1 ";

                        int updateDeliverRes = db.SetCommand(updateDeliverSql
                                            , db.Parameter("@Status", deliveryStatus, DbType.Int32)//状态：1:未完成、2：已完成 、3：已取消、4:已终止、5：交付待确认
                                            , db.Parameter("@CDEndTime", model.UpdateTime, DbType.DateTime2)
                                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                            , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)).ExecuteNonQuery();

                        if (updateDeliverRes <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        #endregion

                        #region 修改TBL_ORDER_COMMODITY表中的数量
                        string strAddHisOrderCommodity = @"INSERT INTO [HST_ORDER_COMMODITY] SELECT * FROM [TBL_ORDER_COMMODITY] WHERE CompanyID = @CompanyID AND ID = @OrderObjectID";
                        int hisOrderCommodityCount = db.SetCommand(strAddHisOrderCommodity
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                        if (hisOrderCommodityCount <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        string strUpdateOrderCommoditySql = @" UPDATE  [TBL_ORDER_COMMODITY]
                                                               SET     UpdaterID = @UpdaterID ,
                                                                       UpdateTime = @UpdateTime ,
                                                                       DeliveredAmount = DeliveredAmount + @Count , 
                                                                       UndeliveredAmount = UndeliveredAmount - @Count 
                                                               WHERE CompanyID = @CompanyID AND ID = @OrderObjectID ";

                        int updateOrderCommodityRes = db.SetCommand(strUpdateOrderCommoditySql
                                           , db.Parameter("@Count", shouldDelivereCount, DbType.Int32)
                                           , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                           , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                                           , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                           , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                        if (updateOrderCommodityRes != 1)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        #endregion

                        #region 再次获取数量 看是否是最后一次
                        dt = db.SetCommand(strSelOrderServiceSql
                           , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                           , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)
                           , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)).ExecuteDataTable();


                        finishedCount = StringUtils.GetDbInt(dt.Rows[0]["DeliveredAmount"].ToString());
                        executingCount = StringUtils.GetDbInt(dt.Rows[0]["UndeliveredAmount"].ToString());
                        totalCount = StringUtils.GetDbInt(dt.Rows[0]["Quantity"].ToString());
                        shouldDelivereCount = StringUtils.GetDbInt(dt.Rows[0]["Quantity2"].ToString());

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

                                if (updateOrderCommodityStatusRes != 1)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }
                                #endregion
                            }
                            #endregion
                        }
                        #endregion

                        #region 即时PUSH
                        string strSelLoginSql = @" SELECT  T3.WeChatOpenID ,
                                                            T4.BranchName ,
                                                            T2.OrderID ,
                                                            T2.CommodityName ,
                                                            T5.Name AS AccountName ,
                                                            T6.CreateTime ,
                                                            T3.Name AS CustomerName
                                                    FROM    [TBL_COMMODITY_DELIVERY] T1 WITH ( NOLOCK )
                                                            LEFT JOIN [TBL_ORDER_COMMODITY] T2 WITH ( NOLOCK ) ON T1.OrderObjectID = T2.ID
                                                            LEFT JOIN [CUSTOMER] T3 WITH ( NOLOCK ) ON T2.CustomerID = T3.UserID
                                                            LEFT JOIN [BRANCH] T4 WITH ( NOLOCK ) ON T2.BranchID = T4.ID
                                                            LEFT JOIN [ACCOUNT] T5 WITH ( NOLOCK ) ON T1.ServicePIC = T5.UserID
                                                            LEFT JOIN [ORDER] T6 WITH ( NOLOCK ) ON T2.OrderID = T6.ID
                                                    WHERE   T1.ID = @GroupNo
                                                            AND ISNULL(T3.WeChatOpenID, '') <> ''  ";
                        DataTable pushmodel = db.SetCommand(strSelLoginSql
                                       , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)).ExecuteDataTable();

                        if (pushmodel != null)
                        {
                            Task.Factory.StartNew(() =>
                            {
                                try
                                {
                                    if (isConfirmed == 1)
                                    {
                                        #region 微信push
                                        string weChatOpenID = StringUtils.GetDbString(pushmodel.Rows[0]["WeChatOpenID"].ToString());
                                        if (!string.IsNullOrEmpty(weChatOpenID))
                                        {
                                            DateTime finishTime = model.UpdateTime;
                                            string branchName = StringUtils.GetDbString(pushmodel.Rows[0]["BranchName"].ToString());
                                            string commodityName = StringUtils.GetDbString(pushmodel.Rows[0]["CommodityName"].ToString());
                                            string accountName = StringUtils.GetDbString(pushmodel.Rows[0]["AccountName"].ToString());
                                            string customerName = StringUtils.GetDbString(pushmodel.Rows[0]["CustomerName"].ToString());
                                            string strOrderCreateTime = StringUtils.GetDbString(pushmodel.Rows[0]["CreateTime"]);
                                            int orderID = StringUtils.GetDbInt(pushmodel.Rows[0]["OrderID"]);
                                            string orderNumber = "";
                                            if (!string.IsNullOrEmpty(strOrderCreateTime))
                                            {
                                                DateTime orderCreateTime = Convert.ToDateTime(strOrderCreateTime);
                                                orderNumber = orderCreateTime.Month.ToString().PadLeft(2, '0') + orderCreateTime.Day.ToString().PadLeft(2, '0') + orderID.ToString().PadLeft(6, '0') + orderCreateTime.Year.ToString().Substring(orderCreateTime.Year.ToString().Length - 2, 2);
                                            }

                                            string WXRemark = "交付内容：" + commodityName + "\n服务顾问：" + accountName + "\n\n本次商品交付需要您进行确认，请在会员菜单中确认完成，欢迎再次光临！";

                                            HS.Framework.Common.WeChat.WeChat we = new HS.Framework.Common.WeChat.WeChat();
                                            string accessToken = we.GetWeChatToken(model.CompanyID);
                                            if (!string.IsNullOrEmpty(accessToken))
                                            {
                                                HS.Framework.Common.WeChat.Entity.MessageTemplate messageModel = new HS.Framework.Common.WeChat.Entity.MessageTemplate();
                                                HS.Framework.Common.WeChat.WXCompanyInfoBase WXCompanyInfoBase = we.GetBaseInfo(model.CompanyID);
                                                messageModel.template_id = WXCompanyInfoBase.AccountChangesTemplate;
                                                messageModel.topcolor = "#000000";
                                                messageModel.touser = weChatOpenID;
                                                messageModel.data = new HS.Framework.Common.WeChat.Entity.TemplateDetail()
                                                {
                                                    first = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#FF0000", value = "本次商品已经交付完成\n" },
                                                    keyword1 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = orderNumber },
                                                    keyword2 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = finishTime.ToString("yyyy-MM-dd HH:mm") },
                                                    remark = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = WXRemark }
                                                };

                                                we.TemplateMessageSend(messageModel, model.CompanyID, 4, accessToken);
                                            }
                                        }
                                        #endregion
                                    }
                                }
                                catch (Exception)
                                {

                                }
                            });
                        }
                        #endregion
                    }
                }
                db.CommitTransaction();
                return 1;
            }
        }

        /// <summary>
        /// 拼路径，写入文件
        /// </summary>
        public bool addSignImgFiles(int companyId, int customerID, long groupNo, string ImageFormat, string signImg, out string ImageName)
        {
            ImageName = "";
            string url = System.Configuration.ConfigurationManager.AppSettings["ImageServer"]
                               + Common.Const.strImage
                               + companyId.ToString() + "/"
                               + "Sign/" + customerID + "/" + groupNo.ToString() + "/";

            if (url == null)
            {
                return false;
            }
            if (!System.IO.Directory.Exists(url))
            {
                System.IO.Directory.CreateDirectory(url);
            }

            int i = 0;

            DateTime dt = DateTime.Now.ToLocalTime();
            Random random = new Random();
            int randomNumber = random.Next(100000);
            ImageName = string.Format("{0:yyyyMMddHHmmssffff}", dt) + (randomNumber + i).ToString("d5") + ImageFormat;

            string fileUrl = url + ImageName;
            //string fileUrl2 = url2 + item.ImageName;
            Byte[] imageByte = Convert.FromBase64String(signImg);

            using (System.IO.MemoryStream ms = new System.IO.MemoryStream(imageByte))
            {
                System.IO.FileStream fs = new System.IO.FileStream(fileUrl, System.IO.FileMode.Create);
                ms.WriteTo(fs);
                ms.Close();
                fs.Close();
                fs = null;
            }

            System.IO.FileStream files = new System.IO.FileStream(fileUrl, System.IO.FileMode.Open);
            Byte[] fliesByte = new byte[files.Length];
            files.Read(fliesByte, 0, fliesByte.Length);
            files.Close();
            string filesStrLocal = Convert.ToBase64String(fliesByte);

            if (signImg == filesStrLocal)
            {
                return true;
            }
            else
            {
                return false;
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
                                                        INNER JOIN [TBL_TREATGROUP] T3 WITH ( NOLOCK ) ON T1.ID = T3.OrderServiceID 
                                                        WHERE   T1.CompanyID = @CompanyID
                                                                AND T1.ID = @OrderObjectID 
                                                                AND T3.GroupNo=@GroupNo 
                                                                AND T1.Status = 1 
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

                        if (updateTreatmentCount != 1)
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

                                    if (updateOrderCommodityStatusRes != 1)
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

                                if (updateOrderCommodityStatusRes != 1)
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

        public int CompleteTreatment(UtilityOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSelStatusSql = @"SELECT  T1.Status ,
                                                    T4.IsConfirmed, 
                                                    T1.SubServiceID, 
                                                    T1.IsDesignated, 
                                                    T3.ServiceCode,
                                                    T3.SumCalcPrice, 
                                                    T1.ExecutorID, 
                                                    T3.OrderID    
                                            FROM    [TREATMENT] T1 WITH ( NOLOCK )
                                                    INNER JOIN [TBL_TREATGROUP] T2 WITH ( NOLOCK ) ON T1.GroupNo = T2.GroupNo
                                                    INNER JOIN [TBL_ORDER_SERVICE] T3 WITH ( NOLOCK ) ON T2.OrderServiceID = T3.ID
                                                    INNER JOIN [SERVICE] T4 WITH ( NOLOCK ) ON T3.ServiceID = T4.ID
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.ID = @TreatmentID";

                DataTable dt = db.SetCommand(strSelStatusSql
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@TreatmentID", model.TreatmentID, DbType.Int32)).ExecuteDataTable();

                if (dt == null || dt.Rows.Count <= 0)
                {
                    return 0;
                }

                int status = StringUtils.GetDbInt(dt.Rows[0]["Status"]);
                bool isConfirmed = StringUtils.GetDbBool(dt.Rows[0]["IsConfirmed"]);
                int subServiceID = StringUtils.GetDbInt(dt.Rows[0]["SubServiceID"]);
                long serviceCode = StringUtils.GetDbLong(dt.Rows[0]["ServiceCode"]);
                bool isDesignated = StringUtils.GetDbBool(dt.Rows[0]["IsDesignated"]);
                decimal sumCalcPrice = StringUtils.GetDbDecimal(dt.Rows[0]["SumCalcPrice"]);
                int executorID = StringUtils.GetDbInt(dt.Rows[0]["ExecutorID"]);
                int orderID = StringUtils.GetDbInt(dt.Rows[0]["OrderID"]);

                if (status != 1)//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                {
                    return status;
                }

                int treatMentStatus = 2; //状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认

                string strSelectLoginMobileSql = @"select LoginMobile from [USER] Where ID =@CustomerID";
                string loginMobile = db.SetCommand(strSelectLoginMobileSql, db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)).ExecuteScalar<string>();

                if (!string.IsNullOrWhiteSpace(loginMobile))
                {
                    if (isConfirmed)
                    {
                        treatMentStatus = 5;
                    }
                }

                db.BeginTransaction();
                string strAddTreatmentHisSql = @"INSERT INTO [HISTORY_TREATMENT] SELECT * FROM [TREATMENT] WHERE CompanyID = @CompanyID AND ID = @TreatmentID";
                int hisTreatmentCount = db.SetCommand(strAddTreatmentHisSql
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@TreatmentID", model.TreatmentID, DbType.Int32)).ExecuteNonQuery();

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
                                                                AND ID = @TreatmentID";

                int updateTreatmentCount = db.SetCommand(strUpdateTreatmentSql
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@TreatmentID", model.TreatmentID, DbType.Int32)
                                    , db.Parameter("@Status", treatMentStatus, DbType.Int32)//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                                    , db.Parameter("@FinishTime", model.Time, DbType.DateTime2)
                                    , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                    , db.Parameter("@UpdateTime", model.Time, DbType.DateTime2)).ExecuteNonQuery();

                if (updateTreatmentCount != 1)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                string strSelCompanyComissionCalcSql = " SELECT [ComissionCalc] FROM COMPANY WHERE ID=@CompanyID ";
                bool isComissionCalc = db.SetCommand(strSelCompanyComissionCalcSql
                                     , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<bool>();
                if (isComissionCalc)
                {
                    #region 记入操作业绩提成
                    string strSelOperateComissionRuleSql = @" SELECT  T1.ServiceCode ,
                                                                    T1.ProfitPct ,
                                                                    T1.HaveSubService ,
                                                                    T1.DesOPCommType ,
                                                                    T1.DesOPCommValue ,
                                                                    T1.OPCommType ,
                                                                    T1.OPCommValue
                                                            FROM    [TBL_OPERATE_COMMISSION_RULE] T1 WITH ( NOLOCK )
                                                            WHERE   T1.CompanyID = @CompanyID
                                                                    AND T1.ServiceCode = @ServiceCode
                                                                    AND T1.RecordType = 1 ";
                    Operate_Commission_Rule_Model operateCommissionRuleModel = db.SetCommand(strSelOperateComissionRuleSql

                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@ServiceCode", serviceCode, DbType.Int64)).ExecuteObject<Operate_Commission_Rule_Model>();

                    if (operateCommissionRuleModel != null && operateCommissionRuleModel.HaveSubService)
                    {
                        #region 有子服务的情况
                        string strSelSubServiceCommissionRuleSql = @" SELECT T1.ServiceCode, T1.SubServiceCode, T1.DesSubServiceProfitPct ,
                                                                    T1.DesSubOPCommType ,
                                                                    T1.DesSubOPCommValue ,
                                                                    T1.SubServiceProfitPct ,
                                                                    T1.SubOPCommType ,
                                                                    T1.SubOPCommValue
                                                            FROM    [TBL_SUBSERVICE_COMMISSION_RULE] T1 WITH ( NOLOCK )
                                                            INNER JOIN [TBL_SUBSERVICE] T2 WITH(NOLOCK) ON T1.SubServiceCode=T2.SubServiceCode
                                                            WHERE   T1.CompanyID = @CompanyID
                                                                    AND T1.ServiceCode = @ServiceCode
                                                                    AND T2.ID = @SubServiceID ";

                        SubService_Commission_Rule_Model subServiceRuleModel = db.SetCommand(strSelSubServiceCommissionRuleSql
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@ServiceCode", serviceCode, DbType.Int64)
                                        , db.Parameter("@SubServiceID", subServiceID, DbType.Int32)).ExecuteObject<SubService_Commission_Rule_Model>();

                        if (model.TreatmentID > 0 && subServiceRuleModel.ServiceCode > 0 && subServiceRuleModel.SubServiceCode > 0)
                        {
                            decimal subServiceProfitPct = subServiceRuleModel.SubServiceProfitPct;
                            int subOPCommType = subServiceRuleModel.SubOPCommType;
                            decimal subOPCommValue = subServiceRuleModel.SubOPCommValue;
                            object commFlag = DBNull.Value;

                            if (isDesignated)
                            {
                                subServiceProfitPct = subServiceRuleModel.DesSubServiceProfitPct;
                                subOPCommType = subServiceRuleModel.DesSubOPCommType;
                                subOPCommValue = subServiceRuleModel.DesSubOPCommValue;
                                commFlag = 2;
                            }

                            decimal profit = sumCalcPrice * operateCommissionRuleModel.ProfitPct;

                            decimal AccountProfit = profit * subServiceProfitPct;//员工业绩(=实际业绩 x 员工业绩计算比例)
                            decimal AccountComm = subOPCommValue;
                            if (subOPCommType == 1)//1:按比例 2:固定值
                            {
                                AccountComm = AccountProfit * subOPCommValue;
                            }

                            string strAddProfitDetailSql = @" INSERT INTO TBL_PROFIT_COMMISSION_DETAIL ( CompanyID ,BranchID ,SourceType ,SourceID ,SubSourceID ,Income ,ProfitPct ,Profit ,CommType ,CommValue ,AccountID ,AccountProfitPct ,AccountProfit ,AccountComm ,CommFlag ,CreatorID ,CreateTime ) 
                                                                    VALUES ( @CompanyID ,@BranchID ,@SourceType ,@SourceID ,@SubSourceID ,@Income ,@ProfitPct ,@Profit ,@CommType ,@CommValue ,@AccountID ,@AccountProfitPct ,@AccountProfit ,@AccountComm ,@CommFlag ,@CreatorID ,@CreateTime ) ";

                            int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                            , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                            , db.Parameter("@SourceType", 2, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                                            , db.Parameter("@SourceID", model.TreatmentID, DbType.Int64)
                                                            , db.Parameter("@SubSourceID", orderID, DbType.Int64)
                                                            , db.Parameter("@Income", sumCalcPrice, DbType.Decimal)//收入 操作业绩时，为B价格
                                                            , db.Parameter("@ProfitPct", operateCommissionRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                                            , db.Parameter("@Profit", profit, DbType.Decimal)//实际业绩
                                                            , db.Parameter("@CommType", subOPCommType, DbType.Int32)//该业绩的提成方式
                                                            , db.Parameter("@CommValue", subOPCommValue, DbType.Decimal)//该业绩的提成数值
                                                            , db.Parameter("@AccountID", executorID, DbType.Int32)//获得该业绩的员工ID
                                                            , db.Parameter("@AccountProfitPct", subServiceProfitPct, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                                            , db.Parameter("@AccountProfit", AccountProfit, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                                            , db.Parameter("@AccountComm", AccountComm, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
                                                            , db.Parameter("@CommFlag", commFlag, DbType.Int32)//1：首充 2：指定 3：E账户
                                                            , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                            , db.Parameter("@CreateTime", model.Time, DbType.DateTime)).ExecuteNonQuery();

                            if (addProfitDetailRes != 1)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                        }
                        #endregion
                    }
                    else if (model.TreatmentID > 0 && operateCommissionRuleModel != null && operateCommissionRuleModel.ServiceCode > 0)
                    {
                        #region 没有子服务
                        int OPCommType = operateCommissionRuleModel.OPCommType;
                        decimal OPCommValue = operateCommissionRuleModel.OPCommValue;
                        object commFlag = DBNull.Value;

                        if (isDesignated)
                        {
                            OPCommType = operateCommissionRuleModel.DesOPCommType;
                            OPCommValue = operateCommissionRuleModel.DesOPCommValue;
                            commFlag = 2;
                        }

                        decimal profit = sumCalcPrice * operateCommissionRuleModel.ProfitPct;

                        decimal AccountProfit = profit * 1;//员工业绩(=实际业绩 x 员工业绩计算比例)
                        decimal AccountComm = OPCommValue;
                        if (OPCommType == 1)//1:按比例 2:固定值
                        {
                            AccountComm = AccountProfit * OPCommValue;
                        }

                        string strAddProfitDetailSql = @" INSERT INTO TBL_PROFIT_COMMISSION_DETAIL ( CompanyID ,BranchID ,SourceType ,SourceID ,SubSourceID ,Income ,ProfitPct ,Profit ,CommType ,CommValue ,AccountID ,AccountProfitPct ,AccountProfit ,AccountComm ,CommFlag ,CreatorID ,CreateTime ) 
                                                                    VALUES ( @CompanyID ,@BranchID ,@SourceType ,@SourceID ,@SubSourceID ,@Income ,@ProfitPct ,@Profit ,@CommType ,@CommValue ,@AccountID ,@AccountProfitPct ,@AccountProfit ,@AccountComm ,@CommFlag ,@CreatorID ,@CreateTime ) ";

                        int addProfitDetailRes = db.SetCommand(strAddProfitDetailSql
                                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                        , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                        , db.Parameter("@SourceType", 2, DbType.Int32)//1：销售 2:操作 3：充值(包括首充)
                                                        , db.Parameter("@SourceID", model.TreatmentID, DbType.Int64)
                                                        , db.Parameter("@SubSourceID", orderID, DbType.Int64)
                                                        , db.Parameter("@Income", sumCalcPrice, DbType.Decimal)//收入 操作业绩时，为B价格
                                                        , db.Parameter("@ProfitPct", operateCommissionRuleModel.ProfitPct, DbType.Decimal)//业绩计算比例
                                                        , db.Parameter("@Profit", profit, DbType.Decimal)//实际业绩
                                                        , db.Parameter("@CommType", OPCommType, DbType.Int32)//该业绩的提成方式
                                                        , db.Parameter("@CommValue", OPCommValue, DbType.Decimal)//该业绩的提成数值
                                                        , db.Parameter("@AccountID", executorID, DbType.Int32)//获得该业绩的员工ID
                                                        , db.Parameter("@AccountProfitPct", 1, DbType.Decimal)//员工业绩计算比例(就是Slave里面的比例)
                                                        , db.Parameter("@AccountProfit", AccountProfit, DbType.Decimal)//员工业绩(=实际业绩 x 员工业绩计算比例)
                                                        , db.Parameter("@AccountComm", AccountComm, DbType.Decimal)//该业绩员工的提成,由员工业绩和该业绩的提成方式及数值算出
                                                        , db.Parameter("@CommFlag", commFlag, DbType.Int32)//1：首充 2：指定 3：E账户
                                                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                        , db.Parameter("@CreateTime", model.Time, DbType.DateTime)).ExecuteNonQuery();

                        if (addProfitDetailRes != 1)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion
                    }

                    #endregion
                }

                db.CommitTransaction();
                return 1;
            }
        }

        public int CancelTreatment(UtilityOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSelStatusSql = " SELECT [Status] FROM [TREATMENT] WHERE CompanyID=@CompanyID AND ID=@TreatmentID AND GroupNo=@GroupNo ";
                int status = db.SetCommand(strSelStatusSql
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@TreatmentID", model.TreatmentID, DbType.Int32)
                                        , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)).ExecuteScalar<int>();
                if (status != 1)//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                {
                    return status;
                }

                db.BeginTransaction();

                #region 修改Treatment
                string strAddTreatmentHisSql = @"INSERT INTO [HISTORY_TREATMENT] SELECT * FROM [TREATMENT] WHERE CompanyID = @CompanyID AND ID = @TreatmentID AND GroupNo=@GroupNo ";
                int hisTreatmentCount = db.SetCommand(strAddTreatmentHisSql
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@TreatmentID", model.TreatmentID, DbType.Int32)
                                    , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)).ExecuteNonQuery();

                if (hisTreatmentCount <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                string strUpdateTreatmentSql = @"UPDATE  [TREATMENT]
                                                        SET     Status = @Status ,
                                                                UpdaterID = @UpdaterID ,
                                                                UpdateTime = @UpdateTime
                                                        WHERE   CompanyID = @CompanyID
                                                                AND ID = @TreatmentID 
                                                                AND GroupNo=@GroupNo ";

                int updateTreatmentCount = db.SetCommand(strUpdateTreatmentSql
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@TreatmentID", model.TreatmentID, DbType.Int32)
                                    , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)
                                    , db.Parameter("@Status", 3, DbType.Int32)//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                                    , db.Parameter("@FinishTime", model.Time, DbType.DateTime2)
                                    , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                    , db.Parameter("@UpdateTime", model.Time, DbType.DateTime2)).ExecuteNonQuery();

                if (updateTreatmentCount <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                #region 查询是否是组里最后一个Treatment
                string strSelCountSql = @"SELECT  COUNT(0)
                                        FROM    [TREATMENT]
                                        WHERE   CompanyID = @CompanyID
                                                AND GroupNo = @GroupNo
                                                AND Status <> 3 AND Status <> 4";
                int count = db.SetCommand(strSelCountSql
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)).ExecuteScalar<int>();
                #endregion

                if (count <= 0)
                {
                    #region 最后一个活着的Treatment 取消TG

                    #region 修改TreatGroup
                    string strAddTGHisSql = @"INSERT INTO [HST_TREATGROUP] SELECT * FROM [TBL_TREATGROUP] WHERE CompanyID = @CompanyID AND GroupNo = @GroupNo";
                    int hisTGCount = db.SetCommand(strAddTGHisSql
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)).ExecuteNonQuery();

                    if (hisTGCount <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    string strUpdateTGSql = @"UPDATE  [TBL_TREATGROUP]
                                                SET     TGStatus = @TGStatus ,
                                                        UpdaterID = @UpdaterID ,
                                                        UpdateTime = @UpdateTime
                                                WHERE   CompanyID = @CompanyID
                                                        AND GroupNo = @GroupNo AND TGStatus = 1";
                    int updateTGCount = db.SetCommand(strUpdateTGSql
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)
                                        , db.Parameter("@TGStatus", 3, DbType.Int32)//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                        , db.Parameter("@UpdateTime", model.Time, DbType.DateTime2)).ExecuteNonQuery();

                    if (updateTreatmentCount <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    #endregion

                    #region 修改TBL_ORDER_SERVICE表TGExecutingCount-1
                    string strAddHisCourse = @"INSERT INTO [HST_ORDER_SERVICE] SELECT * FROM [TBL_ORDER_SERVICE] WHERE CompanyID = @CompanyID AND ID = @OrderObjectID";
                    int hisCourseCount = db.SetCommand(strAddHisCourse
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@OrderObjectID", model.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                    if (hisCourseCount <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    string strUpdateCourseSql = @"UPDATE  [TBL_ORDER_SERVICE]
                                                    SET     TGExecutingCount = TGExecutingCount - 1 ,
                                                            UpdaterID = UpdaterID ,
                                                            UpdateTime = UpdateTime
                                                    WHERE   CompanyID = @CompanyID
                                                            AND ID = @OrderObjectID AND TGExecutingCount > 0";

                    int updateCourseRes = db.SetCommand(strUpdateCourseSql
                                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                        , db.Parameter("@UpdateTime", model.Time, DbType.DateTime2)
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@OrderObjectID", model.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                    if (updateCourseRes <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    #endregion
                    #endregion
                }
                else
                {
                    #region 修改TG指定/非指定
                    string strSelTMDesignatedSql = @"SELECT  COUNT(0)
                                                FROM    [TREATMENT]
                                                WHERE   CompanyID = @CompanyID
                                                        AND GroupNo = @GroupNo 
                                                        AND IsDesignated = 1 
                                                        AND ( Status = 1 OR Status = 2 OR Status = 5) ";
                    int TGIsDesignated = db.SetCommand(strSelTMDesignatedSql
                                           , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                           , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)).ExecuteScalar<int>();

                    string strUpdateTGIsDesignatedSql = @"UPDATE  [TBL_TREATGROUP]
                                                        SET     IsDesignated = @IsDesignated , 
                                                                UpdaterID = @UpdaterID ,
                                                                UpdateTime = @UpdateTime
                                                        WHERE   CompanyID = @CompanyID
                                                                AND GroupNo = @GroupNo ";

                    int updateRows = db.SetCommand(strUpdateTGIsDesignatedSql
                        , db.Parameter("@IsDesignated", TGIsDesignated > 0 ? true : false, DbType.Boolean)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", model.Time, DbType.DateTime2)).ExecuteNonQuery();

                    if (updateRows <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    #endregion
                }

                db.CommitTransaction();
                return 1;
            }
        }

        public int UpdateTMDesignated(UtilityOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                #region 查询订单详情
                string strSqlCheckOrder = @"SELECT  TGStatus
                                                FROM    [TBL_TREATGROUP] T1 WITH ( NOLOCK )
                                                WHERE   T1.GroupNo = @GroupNo";
                int status = db.SetCommand(strSqlCheckOrder, db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)).ExecuteScalar<int>();
                #endregion

                if (status != 1)//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                {
                    return status;
                }

                #region 修改Treatment
                string strAddTreatmentHisSql = @"INSERT INTO [HISTORY_TREATMENT] SELECT * FROM [TREATMENT] WHERE CompanyID = @CompanyID AND GroupNo = @GroupNo AND ID = @TreatmentID ";
                int hisTreatmentCount = db.SetCommand(strAddTreatmentHisSql
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)
                                    , db.Parameter("@TreatmentID", model.TreatmentID, DbType.Int32)).ExecuteNonQuery();

                if (hisTreatmentCount <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                string strUpdateTreatmentSql = @"UPDATE  [TREATMENT]
                                                        SET     IsDesignated = @IsDesignated ,
                                                                UpdaterID = @UpdaterID ,
                                                                UpdateTime = @UpdateTime
                                                        WHERE   CompanyID = @CompanyID
                                                                AND GroupNo = @GroupNo 
                                                                AND ID = @TreatmentID AND Status = 1 ";

                int updateTreatmentCount = db.SetCommand(strUpdateTreatmentSql
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)
                                    , db.Parameter("@TreatmentID", model.TreatmentID, DbType.Int32)
                                    , db.Parameter("@IsDesignated", model.IsDesignated, DbType.Boolean)
                                    , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                    , db.Parameter("@UpdateTime", model.Time, DbType.DateTime2)).ExecuteNonQuery();

                if (updateTreatmentCount <= 0)
                {
                    db.RollbackTransaction();
                    return 2;
                }
                #endregion

                string strSelTMDesignatedSql = @"SELECT  COUNT(0)
                                                FROM    [TREATMENT]
                                                WHERE   CompanyID = @CompanyID
                                                        AND GroupNo = @GroupNo 
                                                        AND IsDesignated = 1 
                                                        AND ( Status = 1 OR Status = 2 OR Status = 5) ";
                int TGIsDesignated = db.SetCommand(strSelTMDesignatedSql
                                       , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                       , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)).ExecuteScalar<int>();

                #region 修改TreatGroup
                string strAddTGHisSql = @"INSERT INTO [HST_TREATGROUP] SELECT * FROM [TBL_TREATGROUP] WHERE CompanyID = @CompanyID AND GroupNo = @GroupNo";
                int hisTGCount = db.SetCommand(strAddTGHisSql
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)).ExecuteNonQuery();

                if (hisTGCount <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                string strUpdateTGSql = @"UPDATE  [TBL_TREATGROUP]
                                                SET     IsDesignated = @IsDesignated ,
                                                        UpdaterID = @UpdaterID ,
                                                        UpdateTime = @UpdateTime
                                                WHERE   CompanyID = @CompanyID
                                                        AND GroupNo = @GroupNo";
                int updateTGCount = db.SetCommand(strUpdateTGSql
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)
                                    , db.Parameter("@IsDesignated", TGIsDesignated > 0 ? true : false, DbType.Boolean)
                                    , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                    , db.Parameter("@UpdateTime", model.Time, DbType.DateTime2)).ExecuteNonQuery();

                if (updateTreatmentCount <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                #endregion

                db.CommitTransaction();
                return 1;
            }
        }

        public int CancelTreatGroup(CompleteTGOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                foreach (CompleteTGDetailOperation_Model item in model.TGDetailList)
                {
                    if (item.OrderID == 0 || item.GroupNo == 0 || item.OrderObjectID == 0)
                    {
                        return -2;
                    }

                    if (item.OrderType == 0)
                    {
                        #region 服务

                        #region 查询组下还有没有进行中的Treatment
                        string strSelHasExcutingSql = @"SELECT  COUNT(0)
                                                            FROM    [TBL_TREATGROUP]
                                                            WHERE   CompanyID = @CompanyID
                                                                    AND GroupNo=@GroupNo 
                                                                    AND TGStatus = 1";//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                        int excuting = db.SetCommand(strSelHasExcutingSql
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)).ExecuteScalar<int>();

                        if (excuting <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        #region 查询组下还有没有已完成和待确认的TG
                        string strSelHasConfirmedSql = @"SELECT  COUNT(0)
                                                            FROM    [TREATMENT]
                                                            WHERE   CompanyID = @CompanyID
                                                                    AND GroupNo=@GroupNo 
                                                                    AND ( Status = 2
                                                                          OR Status = 5
                                                                        )";//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                        int count = db.SetCommand(strSelHasConfirmedSql
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)).ExecuteScalar<int>();

                        if (count > 0)
                        {
                            db.RollbackTransaction();
                            return 2;
                        }
                        #endregion

                        #region 取消下面所有进行中的TM
                        string strAddTreatmentHisSql = @"INSERT INTO [HISTORY_TREATMENT] SELECT * FROM [TREATMENT] WHERE CompanyID = @CompanyID AND GroupNo = @GroupNo AND Status=1";
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
                                                                UpdaterID = @UpdaterID ,
                                                                UpdateTime = @UpdateTime
                                                        WHERE   CompanyID = @CompanyID
                                                                AND GroupNo = @GroupNo AND Status = 1";

                        int updateTreatmentCount = db.SetCommand(strUpdateTreatmentSql
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)
                                            , db.Parameter("@Status", 3, DbType.Int32)//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                            , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)).ExecuteNonQuery();

                        if (updateTreatmentCount <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        #region 取消TreatGroup
                        string strAddTGHisSql = @"INSERT INTO [HST_TREATGROUP] SELECT * FROM [TBL_TREATGROUP] WHERE CompanyID = @CompanyID AND GroupNo = @GroupNo AND TGStatus = 1 ";
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
                                                        UpdaterID = @UpdaterID ,
                                                        UpdateTime = @UpdateTime
                                                WHERE   CompanyID = @CompanyID
                                                        AND GroupNo = @GroupNo AND TGStatus = 1";
                        int updateTGCount = db.SetCommand(strUpdateTGSql
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)
                                            , db.Parameter("@TGStatus", 3, DbType.Int32)//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                            , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)).ExecuteNonQuery();

                        if (updateTGCount != 1)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        #region 修改TBL_ORDER_SERVICE表TGExecutingCount-1
                        string strAddHisCourse = @"INSERT INTO [HST_ORDER_SERVICE] SELECT * FROM [TBL_ORDER_SERVICE] WHERE CompanyID = @CompanyID AND ID = @OrderObjectID AND TGExecutingCount > 0";
                        int hisCourseCount = db.SetCommand(strAddHisCourse
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                        if (hisCourseCount <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        string strUpdateCourseSql = @"UPDATE  [TBL_ORDER_SERVICE]
                                                    SET     TGExecutingCount = TGExecutingCount - 1 ,
                                                            UpdaterID = UpdaterID ,
                                                            UpdateTime = UpdateTime
                                                    WHERE   CompanyID = @CompanyID
                                                            AND ID = @OrderObjectID AND TGExecutingCount > 0";

                        int updateCourseRes = db.SetCommand(strUpdateCourseSql
                                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                            , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                        if (updateCourseRes != 1)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        #endregion
                    }
                    else
                    {
                        #region 商品

                        #region 查询取消交付的数量
                        string strSelQuantitySql = @"SELECT  Quantity
                                                            FROM    [TBL_COMMODITY_DELIVERY]
                                                            WHERE   CompanyID = @CompanyID
                                                                    AND ID = @GroupNo
                                                                    AND Status = 1 ";//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                        int quantity = db.SetCommand(strSelQuantitySql
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)).ExecuteScalar<int>();

                        if (quantity <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        #region 修改TBL_COMMODITY_DELIVERY状态
                        string strAddHisDelivereSql = "INSERT INTO [HST_COMMODITY_DELIVERY] SELECT * FROM [TBL_COMMODITY_DELIVERY] WHERE CompanyID=@CompanyID AND ID=@GroupNo AND Status = 1 ";
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
                                                            UpdaterID = @UpdaterID ,
                                                            UpdateTime = @UpdateTime
                                                    WHERE   CompanyID = @CompanyID
                                                            AND ID = @GroupNo AND Status = 1";

                        int updateDeliverRes = db.SetCommand(updateDeliverSql
                                            , db.Parameter("@Status", 3, DbType.Int32)//状态：1:未完成、2：已完成 、3：已取消、4:已终止、5：交付待确认
                                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                            , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@GroupNo", item.GroupNo, DbType.Int64)).ExecuteNonQuery();

                        if (updateDeliverRes <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        #endregion

                        #region 修改TBL_ORDER_COMMODITY表中的数量
                        string strAddHisOrderCommodity = @"INSERT INTO [HST_ORDER_COMMODITY] SELECT * FROM [TBL_ORDER_COMMODITY] WHERE CompanyID = @CompanyID AND ID = @OrderObjectID";
                        int hisOrderCommodityCount = db.SetCommand(strAddHisOrderCommodity
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                        if (hisOrderCommodityCount <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        string strUpdateOrderCommoditySql = @" UPDATE  [TBL_ORDER_COMMODITY]
                                                               SET     UpdaterID = @UpdaterID ,
                                                                       UpdateTime = UpdateTime , 
                                                                       UndeliveredAmount = UndeliveredAmount - @Count 
                                                               WHERE CompanyID = @CompanyID AND ID = @OrderObjectID AND UndeliveredAmount >= @Count";

                        int updateOrderCommodityRes = db.SetCommand(strUpdateOrderCommoditySql
                                           , db.Parameter("@Count", quantity, DbType.Int32)
                                           , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                           , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                                           , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                           , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                        if (updateOrderCommodityRes != 1)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        #endregion

                        #endregion
                    }
                }

                db.CommitTransaction();
                return 1;
            }
        }

        public bool updateOrderRemark(UtilityOperation_Model orderModel)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                bool rs = false;
                string strSqlCommand = string.Empty;

                if (orderModel.ProductType == 0)
                {
                    #region 服务

                    #region 插入订单子表历史
                    strSqlCommand = @"INSERT INTO dbo.HST_ORDER_SERVICE SELECT * FROM dbo.TBL_ORDER_SERVICE WHERE ID=@OrderObjectID AND CompanyID=@CompanyID";
                    rs = db.SetCommand(strSqlCommand, db.Parameter("@OrderObjectID", orderModel.OrderObjectID, DbType.Int32),
                        db.Parameter("@CompanyID", orderModel.CompanyID, DbType.Int32)).ExecuteNonQuery() == 1;
                    if (!rs)
                    {
                        db.RollbackTransaction();
                        return rs;
                    }
                    #endregion

                    #region 更新订单子表备注
                    strSqlCommand = @"update [TBL_ORDER_SERVICE] set 
                                          Remark =@Remark,
                                          UpdaterID = @UpdaterID,
                                          UpdateTime =@UpdateTime
                                          where ID = @OrderObjectID                                           
                                          and CompanyID=@CompanyID";
                    rs = db.SetCommand(strSqlCommand, db.Parameter("@Remark", orderModel.Remark, DbType.String),
                        db.Parameter("@UpdaterID", orderModel.UpdaterID, DbType.Int32),
                        db.Parameter("@UpdateTime", orderModel.Time, DbType.DateTime2),
                        db.Parameter("@OrderObjectID", orderModel.OrderObjectID, DbType.Int32),
                        db.Parameter("@CompanyID", orderModel.CompanyID, DbType.Int32)).ExecuteNonQuery() == 1;
                    if (!rs)
                    {
                        db.RollbackTransaction();
                        return rs;
                    }
                    #endregion

                    #endregion
                }
                else
                {
                    #region 商品

                    #region 插入订单子表历史
                    strSqlCommand = @"INSERT INTO dbo.HST_ORDER_COMMODITY SELECT * FROM dbo.TBL_ORDER_COMMODITY WHERE ID=@OrderObjectID AND CompanyID=@CompanyID";
                    rs = db.SetCommand(strSqlCommand, db.Parameter("@OrderObjectID", orderModel.OrderObjectID, DbType.Int32),
                        db.Parameter("@CompanyID", orderModel.CompanyID, DbType.Int32)).ExecuteNonQuery() == 1;
                    if (!rs)
                    {
                        db.RollbackTransaction();
                        return rs;
                    }

                    #endregion

                    #region 更新订单子表备注
                    strSqlCommand = @"update [TBL_ORDER_COMMODITY] set 
                                          Remark =@Remark,
                                          UpdaterID = @UpdaterID,
                                          UpdateTime =@UpdateTime
                                          where ID = @OrderObjectID                                           
                                          and CompanyID=@CompanyID";
                    rs = db.SetCommand(strSqlCommand, db.Parameter("@Remark", orderModel.Remark, DbType.String),
                        db.Parameter("@UpdaterID", orderModel.UpdaterID, DbType.Int32),
                        db.Parameter("@UpdateTime", orderModel.Time, DbType.DateTime2),
                        db.Parameter("@OrderObjectID", orderModel.OrderObjectID, DbType.Int32),
                        db.Parameter("@CompanyID", orderModel.CompanyID, DbType.Int32)).ExecuteNonQuery() == 1;
                    if (!rs)
                    {
                        db.RollbackTransaction();
                        return rs;
                    }
                    #endregion

                    #endregion
                }

                db.CommitTransaction();
                return rs;
            }

        }

        public int UpdateExpirationTime(UtilityOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                try
                {
                    #region 查询订单详情
                    string strSqlCheckOrder = @"SELECT  Status
                                                FROM    [TBL_ORDER_SERVICE] T1 WITH ( NOLOCK )
                                                WHERE   T1.ID = @OrderObjectID";
                    int status = db.SetCommand(strSqlCheckOrder, db.Parameter("@OrderObjectID", model.OrderObjectID, DbType.Int32)).ExecuteScalar<int>();
                    #endregion

                    if (status != 1)//状态1:未完成 2:已完成 3:已取消 4:已终止
                    {
                        return status;
                    }
                    else
                    {
                        #region 修改TBL_ORDER_SERVICE表
                        string strAddHisCourse = @"INSERT INTO [HST_ORDER_SERVICE] SELECT * FROM [TBL_ORDER_SERVICE] WHERE CompanyID = @CompanyID AND ID = @OrderObjectID AND Status = 1";
                        int hisCourseCount = db.SetCommand(strAddHisCourse
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@OrderObjectID", model.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                        if (hisCourseCount <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        string strUpdateCourseSql = @"UPDATE  [TBL_ORDER_SERVICE]
                                                    SET     Expirationtime = @Expirationtime ,
                                                            UpdateTime = UpdateTime
                                                    WHERE   CompanyID = @CompanyID
                                                            AND ID = @OrderObjectID AND Status = 1";

                        int updateCourseRes = db.SetCommand(strUpdateCourseSql
                                            , db.Parameter("@Expirationtime", model.ExpirationTime, DbType.DateTime2)
                                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                            , db.Parameter("@UpdateTime", model.Time, DbType.DateTime2)
                                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                            , db.Parameter("@OrderObjectID", model.OrderObjectID, DbType.Int32)).ExecuteNonQuery();

                        if (updateCourseRes != 1)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        db.CommitTransaction();
                        return 1;
                    }

                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }

        public int UpdateTGDesignated(UtilityOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                #region 查询订单详情
                string strSqlCheckOrder = @"SELECT  TGStatus
                                                FROM    [TBL_TREATGROUP] T1 WITH ( NOLOCK )
                                                WHERE   T1.GroupNo = @GroupNo";
                int status = db.SetCommand(strSqlCheckOrder, db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)).ExecuteScalar<int>();
                #endregion

                if (status != 1)//状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
                {
                    return status;
                }

                #region 修改Treatment
                string strAddTreatmentHisSql = @"INSERT INTO [HISTORY_TREATMENT] SELECT * FROM [TREATMENT] WHERE CompanyID = @CompanyID AND GroupNo = @GroupNo";
                int hisTreatmentCount = db.SetCommand(strAddTreatmentHisSql
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)).ExecuteNonQuery();

                if (hisTreatmentCount <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                string strUpdateTreatmentSql = @"UPDATE  [TREATMENT]
                                                        SET     IsDesignated = @IsDesignated ,
                                                                UpdaterID = @UpdaterID ,
                                                                UpdateTime = @UpdateTime
                                                        WHERE   CompanyID = @CompanyID
                                                                AND GroupNo = @GroupNo";

                int updateTreatmentCount = db.SetCommand(strUpdateTreatmentSql
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)
                                    , db.Parameter("@IsDesignated", model.IsDesignated, DbType.Boolean)
                                    , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                    , db.Parameter("@UpdateTime", model.Time, DbType.DateTime2)).ExecuteNonQuery();

                if (updateTreatmentCount <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                #region 修改TreatGroup
                string strAddTGHisSql = @"INSERT INTO [HST_TREATGROUP] SELECT * FROM [TBL_TREATGROUP] WHERE CompanyID = @CompanyID AND GroupNo = @GroupNo";
                int hisTGCount = db.SetCommand(strAddTGHisSql
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)).ExecuteNonQuery();

                if (hisTGCount <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                string strUpdateTGSql = @"UPDATE  [TBL_TREATGROUP]
                                                SET     IsDesignated = @IsDesignated ,
                                                        UpdaterID = @UpdaterID ,
                                                        UpdateTime = @UpdateTime
                                                WHERE   CompanyID = @CompanyID
                                                        AND GroupNo = @GroupNo";
                int updateTGCount = db.SetCommand(strUpdateTGSql
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                    , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)
                                    , db.Parameter("@IsDesignated", model.IsDesignated, DbType.Boolean)
                                    , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                    , db.Parameter("@UpdateTime", model.Time, DbType.DateTime2)).ExecuteNonQuery();

                if (updateTreatmentCount != 1)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                #endregion

                db.CommitTransaction();
                return 1;
            }
        }

        public int updateResponsiblePerson(UtilityOperation_Model orderModel)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strSqlCommand = string.Empty;

                if (orderModel.ProductType == 0)
                {
                    #region 服务
                    #region 查询订单详情
                    string strSqlCheckOrder = @"SELECT  Status
                                                FROM    [TBL_ORDER_SERVICE] T1 WITH ( NOLOCK )
                                                WHERE   T1.ID = @OrderObjectID";
                    int status = db.SetCommand(strSqlCheckOrder, db.Parameter("@OrderObjectID", orderModel.OrderObjectID, DbType.Int64)).ExecuteScalar<int>();

                    if (status != 1)
                    {
                        db.RollbackTransaction();
                        return status;
                    }
                    #endregion
                    #endregion
                }
                else
                {
                    #region 商品
                    #region 查询订单详情
                    string strSqlCheckOrder = @"SELECT  Status
                                                FROM    [TBL_ORDER_COMMODITY] T1 WITH ( NOLOCK )
                                                WHERE   T1.ID = @OrderObjectID";
                    int status = db.SetCommand(strSqlCheckOrder, db.Parameter("@OrderObjectID", orderModel.OrderObjectID, DbType.Int64)).ExecuteScalar<int>();

                    if (status != 1)
                    {
                        db.RollbackTransaction();
                        return status;
                    }
                    #endregion
                    #endregion
                }

                string strSelCountSql = " SELECT * FROM [TBL_BUSINESS_CONSULTANT] WITH(NOLOCK) WHERE MasterID=@OrderID AND BusinessType=1 AND ConsultantType=1 ";
                int responsiblePersonCount = db.SetCommand(strSelCountSql, db.Parameter("@OrderID", orderModel.OrderID, DbType.Int32)).ExecuteScalar<int>();

                if (responsiblePersonCount > 0)
                {
                    return 0;
                }

                string strAddConsultant = @" INSERT INTO [TBL_BUSINESS_CONSULTANT]( CompanyID ,BusinessType ,MasterID ,ConsultantType ,ConsultantID ,CreatorID ,CreateTime )
                                                    VALUES ( @CompanyID ,@BusinessType ,@MasterID ,@ConsultantType ,@ConsultantID ,@CreatorID ,@CreateTime )";

                #region 美丽顾问
                if (orderModel.ResponsiblePersonID > 0)
                {
                    int addConsultantRes = db.SetCommand(strAddConsultant
                           , db.Parameter("@CompanyID", orderModel.CompanyID, DbType.Int32)
                           , db.Parameter("@BusinessType", 1, DbType.Int32)//1：订单，2：支付，3：充值
                           , db.Parameter("@MasterID", orderModel.OrderID, DbType.Int32)
                           , db.Parameter("@ConsultantType", 1, DbType.Int32)//1:美丽顾问 2:销售顾问
                           , db.Parameter("@ConsultantID", orderModel.ResponsiblePersonID, DbType.Int32)
                           , db.Parameter("@CreatorID", orderModel.UpdaterID, DbType.Int32)
                           , db.Parameter("@CreateTime", orderModel.Time, DbType.DateTime)).ExecuteNonQuery();

                    if (addConsultantRes <= 0)
                    {
                        return 0;
                    }
                }
                #endregion

                db.CommitTransaction();
                return 1;
            }
        }

        public ObjectResult<bool> deleteOrder(int CompanyID, int OrderID, int ObjectID, int ProductType, int DeleteType, int updaterId)
        {
            ObjectResult<bool> listres = new ObjectResult<bool>();
            listres.Code = "0";
            listres.Message = DeleteType == 1 ? "取消失败" : "终止失败";
            listres.Data = false;
            DateTime dt = DateTime.Now;
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                OrderDelOperation_Model model = null;
                string strSqlCheckOrder = string.Empty;
                #region 取消订单
                if (DeleteType == 1)
                {
                    #region 服务订单取消判断
                    if (ProductType == 0)
                    {
                        strSqlCheckOrder = @"SELECT  t1.PaymentStatus,t2.Status,t2.TGFinishedCount-t2.TGPastCount AS CNT,t1.TotalSalePrice
                                    FROM    dbo.[ORDER] T1
                                            INNER JOIN dbo.TBL_ORDER_SERVICE t2 ON T1.ID = t2.OrderID
                                    WHERE T1.CompanyID=@CompanyID AND T1.ProductType=0 AND t1.ID=@OrderID AND t2.ID=@ObjectID";
                        model = db.SetCommand(strSqlCheckOrder
                            , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                            , db.Parameter("@OrderID", OrderID, DbType.Int32)
                            , db.Parameter("@ObjectID", ObjectID, DbType.Int32)).ExecuteObject<OrderDelOperation_Model>();
                        if (model == null)
                        {
                            listres.Code = "0";
                            listres.Message = "strSqlCheckOrder为空";
                            listres.Data = false;
                            return listres;
                        }

                        if (model.Status != 1)
                        {
                            listres.Code = "2";
                            listres.Message = "订单状态已变化，请刷新后查看";
                            listres.Data = false;
                            return listres;
                        }
                        else if (model.PaymentStatus != 1 && model.PaymentStatus != 5)
                        {
                            listres.Code = "2";
                            listres.Message = "订单已支付不能取消";
                            listres.Data = false;
                            return listres;
                        }
                        else if (model.CNT > 0)
                        {
                            listres.Code = "3";
                            listres.Message = "服务订单有课程已完成或待客户确认";
                            listres.Data = false;
                            return listres;
                        }
                        else
                        {
                            #region 插入订单主表历史表
                            string strSqlinsertHis = @"insert into HISTORY_ORDER select * from [ORDER] where CompanyID=@CompanyID AND
                                                       ID = @OrderID ";
                            int inserthisrs = db.SetCommand(strSqlinsertHis, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                                    , db.Parameter("@OrderID", OrderID, DbType.Int32)).ExecuteNonQuery();

                            if (inserthisrs <= 0)
                            {
                                db.RollbackTransaction();
                                listres.Code = "0";
                                listres.Message = "strSqlinsertHis添加出错";
                                listres.Data = false;
                                return listres;
                            }
                            #endregion

                            #region 修改订单状态
                            string strSqlUpdateOrder = @"update [ORDER] set Status=@Status,RecordType=@RecordType,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime where CompanyID=@CompanyID AND ID=@OrderID and Status = 1 ";
                            int updateorderrs = db.SetCommand(strSqlUpdateOrder,
                                                              db.Parameter("@Status", 3, DbType.Int32),
                                                              db.Parameter("@UpdaterID", updaterId, DbType.Int32),
                                                              db.Parameter("@UpdateTime", dt, DbType.DateTime2),
                                                              db.Parameter("@OrderID", OrderID, DbType.Int32),
                                                              db.Parameter("@CompanyID", CompanyID, DbType.Int32),
                                                              db.Parameter("@RecordType", 2, DbType.Int32)).ExecuteNonQuery();
                            if (updateorderrs != 1)
                            {
                                db.RollbackTransaction();
                                listres.Code = "0";
                                listres.Message = "strSqlUpdateOrder出错";
                                listres.Data = false;
                                return listres;
                            }
                            #endregion

                            #region 插入订单子表历史
                            string strSqlinsertSubOrderHis = @"INSERT INTO dbo.HST_ORDER_SERVICE SELECT * FROM dbo.TBL_ORDER_SERVICE WHERE CompanyID=@CompanyID
                                                               AND ID=@ObjectID";
                            int inserthisrSubOrders = db.SetCommand(strSqlinsertSubOrderHis, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                                    , db.Parameter("@ObjectID", ObjectID, DbType.Int32)).ExecuteNonQuery();

                            if (inserthisrSubOrders <= 0)
                            {
                                db.RollbackTransaction();
                                listres.Code = "0";
                                listres.Message = "strSqlinsertSubOrderHis添加出错";
                                listres.Data = false;
                                return listres;
                            }
                            #endregion

                            #region 修改子订单状态
                            string strSqlUpdateSubOrder = @"update [TBL_ORDER_SERVICE] set Status=@Status,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime where CompanyID=@CompanyID AND ID=@ObjectID and Status = 1 ";
                            int updateSuborderrs = db.SetCommand(strSqlUpdateSubOrder,
                                                              db.Parameter("@Status", 3, DbType.Int32),
                                                              db.Parameter("@UpdaterID", updaterId, DbType.Int32),
                                                              db.Parameter("@UpdateTime", dt, DbType.DateTime2),
                                                              db.Parameter("@ObjectID", ObjectID, DbType.Int32),
                                                              db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteNonQuery();
                            if (updateSuborderrs != 1)
                            {
                                db.RollbackTransaction();
                                listres.Code = "0";
                                listres.Message = "strSqlUpdateSubOrder出错";
                                listres.Data = false;
                                return listres;
                            }
                            #endregion
                        }
                    }
                    #endregion
                    #region 商品订单取消判断
                    else
                    {
                        strSqlCheckOrder = @"SELECT  t1.PaymentStatus,t2.Status,t2.DeliveredAmount AS CNT,t1.TotalSalePrice,t1.BranchID,t1.CompanyID,t2.CommodityCode AS ProductCode ,
                                            t2.Quantity
                                    FROM    dbo.[ORDER] T1
                                            INNER JOIN dbo.TBL_ORDER_COMMODITY t2 ON T1.ID = t2.OrderID
                                    WHERE T1.CompanyID=@CompanyID AND T1.ProductType=1 AND t1.ID=@OrderID AND t2.ID=@ObjectID";
                        model = db.SetCommand(strSqlCheckOrder
                            , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                            , db.Parameter("@OrderID", OrderID, DbType.Int32)
                            , db.Parameter("@ObjectID", ObjectID, DbType.Int32)).ExecuteObject<OrderDelOperation_Model>();
                        if (model == null)
                        {
                            listres.Code = "0";
                            listres.Message = "strSqlCheckOrder为空";
                            listres.Data = false;
                            return listres;
                        }

                        if (model.Status != 1)
                        {
                            listres.Code = "2";
                            listres.Message = "订单状态已变化，请刷新后查看";
                            listres.Data = false;
                            return listres;
                        }
                        else if (model.PaymentStatus != 1 && model.PaymentStatus != 5)
                        {
                            listres.Code = "2";
                            listres.Message = "订单已支付不能取消";
                            listres.Data = false;
                            return listres;
                        }
                        else if (model.CNT > 0)
                        {
                            listres.Code = "3";
                            listres.Message = "服务订单有课程已完成或待客户确认";
                            listres.Data = false;
                            return listres;
                        }
                        else
                        {
                            #region 插入订单主表历史表
                            string strSqlinsertHis = @"insert into HISTORY_ORDER select * from [ORDER] where CompanyID=@CompanyID AND
                                                       ID = @OrderID ";
                            int inserthisrs = db.SetCommand(strSqlinsertHis, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                                    , db.Parameter("@OrderID", OrderID, DbType.Int32)).ExecuteNonQuery();

                            if (inserthisrs <= 0)
                            {
                                db.RollbackTransaction();
                                listres.Code = "0";
                                listres.Message = "strSqlinsertHis添加出错";
                                listres.Data = false;
                                return listres;
                            }
                            #endregion

                            #region 修改订单状态
                            string strSqlUpdateOrder = @"update [ORDER] set RecordType=@RecordType, Status=@Status,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime where CompanyID=@CompanyID AND ID=@OrderID and Status = 1 ";
                            int updateorderrs = db.SetCommand(strSqlUpdateOrder,
                                                              db.Parameter("@Status", 3, DbType.Int32),
                                                              db.Parameter("@UpdaterID", updaterId, DbType.Int32),
                                                              db.Parameter("@UpdateTime", dt, DbType.DateTime2),
                                                              db.Parameter("@OrderID", OrderID, DbType.Int32),
                                                              db.Parameter("@CompanyID", CompanyID, DbType.Int32),
                                                              db.Parameter("@RecordType", 2, DbType.Int32)).ExecuteNonQuery();
                            if (updateorderrs != 1)
                            {
                                db.RollbackTransaction();
                                listres.Code = "0";
                                listres.Message = "strSqlUpdateOrder出错";
                                listres.Data = false;
                                return listres;
                            }
                            #endregion

                            #region 插入订单子表历史
                            string strSqlinsertSubOrderHis = @"INSERT INTO dbo.HST_ORDER_COMMODITY SELECT * FROM dbo.TBL_ORDER_COMMODITY WHERE CompanyID=@CompanyID
                                                               AND ID=@ObjectID";
                            int inserthisrSubOrders = db.SetCommand(strSqlinsertSubOrderHis, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                                    , db.Parameter("@ObjectID", ObjectID, DbType.Int32)).ExecuteNonQuery();

                            if (inserthisrSubOrders <= 0)
                            {
                                db.RollbackTransaction();
                                listres.Code = "0";
                                listres.Message = "strSqlinsertSubOrderHis添加出错";
                                listres.Data = false;
                                return listres;
                            }
                            #endregion

                            #region 修改子订单状态
                            string strSqlUpdateSubOrder = @"update [TBL_ORDER_COMMODITY] set Status=@Status,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime where CompanyID=@CompanyID AND ID=@ObjectID and Status = 1 ";
                            int updateSuborderrs = db.SetCommand(strSqlUpdateSubOrder,
                                                              db.Parameter("@Status", 3, DbType.Int32),
                                                              db.Parameter("@UpdaterID", updaterId, DbType.Int32),
                                                              db.Parameter("@UpdateTime", dt, DbType.DateTime2),
                                                              db.Parameter("@ObjectID", ObjectID, DbType.Int32),
                                                              db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteNonQuery();
                            if (updateSuborderrs != 1)
                            {
                                db.RollbackTransaction();
                                listres.Code = "0";
                                listres.Message = "strSqlUpdateSubOrder出错";
                                listres.Data = false;
                                return listres;
                            }
                            #endregion

                            #region 库存操作

                            #region 查询库存
                            string strSqlSelectQty = @" SELECT TOP 1 * FROM [TBL_PRODUCT_STOCK] WHERE ProductCode=@ProductCode AND CompanyID=@CompanyID AND BranchID=@BranchID ORDER BY ID DESC ";
                            ProductStockOperation_Model stockModel = db.SetCommand(strSqlSelectQty,
                                                                       db.Parameter("@ProductCode", model.ProductCode, DbType.Int64),
                                                                       db.Parameter("@CompanyID", CompanyID, DbType.Int32),
                                                                       db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteObject<ProductStockOperation_Model>();
                            #endregion

                            if (stockModel == null)
                            {
                                db.RollbackTransaction();
                                listres.Code = "0";
                                listres.Message = "strSqlSelectQty失败";
                                listres.Data = false;
                                return listres;
                            }

                            // 不计库存 不操作库存表
                            if (stockModel.StockCalcType == 1 || stockModel.StockCalcType == 3)
                            {
                                #region 修改库存
                                string strSqlUpdateStock = @" UPDATE TBL_PRODUCT_STOCK SET ProductQty=ProductQty+@ProductQty,OperatorID=@OperatorID,OperateTime=@OperateTime WHERE ProductType=1 And ProductCode=@ProductCode And CompanyID=@CompanyID And BranchID=@BranchID";
                                int updatestockrs = db.SetCommand(strSqlUpdateStock,
                                                    db.Parameter("@ProductQty", model.Quantity, DbType.Int32),
                                                    db.Parameter("@OperatorID", updaterId, DbType.Int32),
                                                    db.Parameter("@OperateTime", dt, DbType.DateTime2),
                                                    db.Parameter("@ProductCode", model.ProductCode, DbType.Int64),
                                                    db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                                    db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                    ).ExecuteNonQuery();
                                #endregion

                                if (updatestockrs <= 0)
                                {
                                    db.RollbackTransaction();
                                    listres.Code = "0";
                                    listres.Message = "strSqlUpdateStock失败";
                                    listres.Data = false;
                                    return listres;
                                }

                                #region 批次表修改数量操作
                                string strSqlSelectStockBatch = @" SELECT * FROM [TBL_PRODUCT_STOCK_BATCH] WHERE ProductCode=@ProductCode AND CompanyID=@CompanyID AND BranchID=@BranchID ORDER BY ID ";
                                List<Product_Stock_Batch_Model> stockBatchList = db.SetCommand(strSqlSelectStockBatch,
                                db.Parameter("@ProductCode", model.ProductCode, DbType.Int64),
                                db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteList<Product_Stock_Batch_Model>();
                                if (stockBatchList != null && stockBatchList.Count > 0)
                                {
                                    string strSqlUpdateStockBatch = @" UPDATE TBL_PRODUCT_STOCK_BATCH SET Quantity=Quantity+@qtyForUpd WHERE ID = @ID ";
                                    int updStockBatch = db.SetCommand(strSqlUpdateStockBatch,
                                    db.Parameter("@qtyForUpd", model.Quantity, DbType.Int32),
                                    db.Parameter("@ID", stockBatchList[0].ID, DbType.Int32)).ExecuteNonQuery();
                                    if (updStockBatch <= 0)
                                    {
                                        db.RollbackTransaction();
                                        listres.Code = "0";
                                        listres.Message = "strSqlUpdateStockBatch失败";
                                        listres.Data = false;
                                        return listres;
                                    }
                                }
                                #endregion


                                #region 插入库存操作记录表
                                string strSqlInsertStockLog = @"INSERT INTO [TBL_PRODUCT_STOCK_OPERATELOG](CompanyID,BranchID,ProductType,ProductCode,OperateType,OperateQty,OperateSign,OrderID,ProductQty,OperatorID,OperateTime) 
                                                                            VALUES(@CompanyID,@BranchID,@ProductType,@ProductCode,@OperateType,@OperateQty,@OperateSign,@OrderID,@ProductQty,@OperatorID,@OperateTime)";
                                int insertStocklogRs = db.SetCommand(strSqlInsertStockLog,
                                                       db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                                       db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                                       db.Parameter("@ProductType", 1, DbType.Int32),
                                                       db.Parameter("@ProductCode", model.ProductCode, DbType.Int64),
                                                       db.Parameter("@OperateType", 5, DbType.Int32),//取消订单
                                                       db.Parameter("@OperateQty", model.Quantity, DbType.Int32),
                                                       db.Parameter("@OperateSign", "+", DbType.String),
                                                       db.Parameter("@OrderID", OrderID, DbType.Int32),
                                                       db.Parameter("@ProductQty", stockModel.ProductQty + model.Quantity, DbType.Int32),
                                                       db.Parameter("@OperatorID", updaterId, DbType.Int32),
                                                       db.Parameter("@OperateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)).ExecuteNonQuery();
                                #endregion

                                if (insertStocklogRs <= 0)
                                {
                                    db.RollbackTransaction();
                                    listres.Code = "0";
                                    listres.Message = "strSqlInsertStockLog添加失败";
                                    listres.Data = false;
                                    return listres;
                                }
                            }

                            #endregion
                        }
                    }
                    #endregion
                    #region 优惠券返还
                    string strSelBenefitSql = @" SELECT  T1.BenefitID
                                                FROM    [TBL_CUSTOMER_BENEFIT] T1 WITH ( NOLOCK )
                                                WHERE   T1.CompanyID = @CompanyID
                                                        AND T1.OrderID = @OrderID ";
                    string BenefitID = db.SetCommand(strSelBenefitSql
                            , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                            , db.Parameter("@OrderID", OrderID, DbType.Int32)).ExecuteScalar<string>();
                    if (!string.IsNullOrWhiteSpace(BenefitID))
                    {
                        string strUpdateBenefitSql = @" UPDATE  [TBL_CUSTOMER_BENEFIT]
                                                            SET     BenefitStatus = 1 ,
                                                                    UpdaterID = @UpdaterID ,
                                                                    UpdateTime = @UpdateTime
                                                            WHERE    CompanyID = @CompanyID
                                                                    AND BenefitID = @BenefitID ";

                        int updateBenefitrrs = db.SetCommand(strUpdateBenefitSql,
                        db.Parameter("@CompanyID", CompanyID, DbType.Int32),// 1：未支付 2：部分付 3：已支付 4：已退款 5:免支付
                        db.Parameter("@UpdaterID", updaterId, DbType.Int32),
                        db.Parameter("@UpdateTime", dt, DbType.DateTime2),
                        db.Parameter("@BenefitID", BenefitID, DbType.String)).ExecuteNonQuery();
                        if (updateBenefitrrs != 1)
                        {
                            db.RollbackTransaction();
                            listres.Code = "0";
                            listres.Message = "strUpdateBenefitSql出错";
                            listres.Data = false;
                            return listres;
                        }
                    }
                    #endregion
                    db.CommitTransaction();
                    listres.Code = "1";
                    listres.Message = "取消成功";
                    return listres;
                }
                #endregion
                #region 终止订单
                else
                {
                    #region 服务订单取消中止判断
                    if (ProductType == 0)
                    {
                        strSqlCheckOrder = @"SELECT  t1.PaymentStatus,t2.Status,t2.TGFinishedCount-t2.TGPastCount AS CNT,t1.TotalSalePrice
                                    FROM    dbo.[ORDER] T1
                                            INNER JOIN dbo.TBL_ORDER_SERVICE t2 ON T1.ID = t2.OrderID
                                    WHERE T1.CompanyID=@CompanyID AND T1.ProductType=0 AND t1.ID=@OrderID AND t2.ID=@ObjectID";
                        model = db.SetCommand(strSqlCheckOrder
                            , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                            , db.Parameter("@OrderID", OrderID, DbType.Int32)
                            , db.Parameter("@ObjectID", ObjectID, DbType.Int32)).ExecuteObject<OrderDelOperation_Model>();
                        if (model == null)
                        {
                            listres.Code = "0";
                            listres.Message = "strSqlCheckOrder为空";
                            listres.Data = false;
                            return listres;
                        }
                        else if (model.Status != 1)
                        {
                            listres.Code = "0";
                            listres.Message = "订单状态已变化，请刷新后查看";
                            listres.Data = false;
                            return listres;
                        }
                        else
                        {
                            #region 插入订单主表历史表
                            string strSqlinsertHis = @"insert into HISTORY_ORDER select * from [ORDER] where CompanyID=@CompanyID AND
                                                       ID = @OrderID ";
                            int inserthisrs = db.SetCommand(strSqlinsertHis, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                                    , db.Parameter("@OrderID", OrderID, DbType.Int32)).ExecuteNonQuery();

                            if (inserthisrs <= 0)
                            {
                                db.RollbackTransaction();
                                listres.Code = "0";
                                listres.Message = "strSqlinsertHis添加出错";
                                listres.Data = false;
                                return listres;
                            }
                            #endregion

                            #region 修改订单状态
                            string strSqlUpdateOrder = @"update [ORDER] set Status=@Status,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime where CompanyID=@CompanyID AND ID=@OrderID and Status = 1 ";
                            int updateorderrs = db.SetCommand(strSqlUpdateOrder,
                                                              db.Parameter("@Status", 4, DbType.Int32),
                                                              db.Parameter("@UpdaterID", updaterId, DbType.Int32),
                                                              db.Parameter("@UpdateTime", dt, DbType.DateTime2),
                                                              db.Parameter("@OrderID", OrderID, DbType.Int32),
                                                              db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteNonQuery();
                            if (updateorderrs <= 0)
                            {
                                db.RollbackTransaction();
                                listres.Code = "0";
                                listres.Message = "strSqlUpdateOrder出错";
                                listres.Data = false;
                                return listres;
                            }
                            #endregion

                            #region 插入订单子表历史
                            string strSqlinsertSubOrderHis = @"INSERT INTO dbo.HST_ORDER_SERVICE SELECT * FROM dbo.TBL_ORDER_SERVICE WHERE CompanyID=@CompanyID
                                                               AND ID=@ObjectID";
                            int inserthisrSubOrders = db.SetCommand(strSqlinsertSubOrderHis, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                                    , db.Parameter("@ObjectID", ObjectID, DbType.Int32)).ExecuteNonQuery();

                            if (inserthisrSubOrders <= 0)
                            {
                                db.RollbackTransaction();
                                listres.Code = "0";
                                listres.Message = "strSqlinsertSubOrderHis添加出错";
                                listres.Data = false;
                                return listres;
                            }
                            #endregion

                            #region 修改子订单状态
                            string strSqlUpdateSubOrder = @"update [TBL_ORDER_SERVICE] set Status=@Status,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime where CompanyID=@CompanyID AND ID=@ObjectID and Status = 1 ";
                            int updateSuborderrs = db.SetCommand(strSqlUpdateSubOrder,
                                                              db.Parameter("@Status", 4, DbType.Int32),
                                                              db.Parameter("@UpdaterID", updaterId, DbType.Int32),
                                                              db.Parameter("@UpdateTime", dt, DbType.DateTime2),
                                                              db.Parameter("@ObjectID", ObjectID, DbType.Int32),
                                                              db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteNonQuery();
                            if (updateSuborderrs <= 0)
                            {
                                db.RollbackTransaction();
                                listres.Code = "0";
                                listres.Message = "strSqlUpdateSubOrder出错";
                                listres.Data = false;
                                return listres;
                            }
                            #endregion
                        }
                    }
                    #endregion
                    #region 商品订单取消中止判断
                    else
                    {
                        strSqlCheckOrder = @"SELECT  t1.PaymentStatus,t2.Status,t2.DeliveredAmount AS CNT,t1.TotalSalePrice
                                    FROM    dbo.[ORDER] T1
                                            INNER JOIN dbo.TBL_ORDER_COMMODITY t2 ON T1.ID = t2.OrderID
                                    WHERE T1.CompanyID=@CompanyID AND T1.ProductType=1 AND t1.ID=@OrderID AND t2.ID=@ObjectID";
                        model = db.SetCommand(strSqlCheckOrder
                            , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                            , db.Parameter("@OrderID", OrderID, DbType.Int32)
                            , db.Parameter("@ObjectID", ObjectID, DbType.Int32)).ExecuteObject<OrderDelOperation_Model>();
                        if (model == null)
                        {
                            listres.Code = "0";
                            listres.Message = "strSqlCheckOrder为空";
                            listres.Data = false;
                            return listres;
                        }
                        else if (model.Status != 1)
                        {
                            listres.Code = "2";
                            listres.Message = "订单状态已变化，请刷新后查看";
                            listres.Data = false;
                            return listres;
                        }
                        else
                        {
                            #region 插入订单主表历史表
                            string strSqlinsertHis = @"insert into HISTORY_ORDER select * from [ORDER] where CompanyID=@CompanyID AND
                                                       ID = @OrderID ";
                            int inserthisrs = db.SetCommand(strSqlinsertHis, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                                    , db.Parameter("@OrderID", OrderID, DbType.Int32)).ExecuteNonQuery();

                            if (inserthisrs <= 0)
                            {
                                db.RollbackTransaction();
                                listres.Code = "0";
                                listres.Message = "strSqlinsertHis添加出错";
                                listres.Data = false;
                                return listres;
                            }
                            #endregion

                            #region 修改订单状态
                            string strSqlUpdateOrder = @"update [ORDER] set Status=@Status,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime where CompanyID=@CompanyID AND ID=@OrderID and Status = 1 ";
                            int updateorderrs = db.SetCommand(strSqlUpdateOrder,
                                                              db.Parameter("@Status", 4, DbType.Int32),
                                                              db.Parameter("@UpdaterID", updaterId, DbType.Int32),
                                                              db.Parameter("@UpdateTime", dt, DbType.DateTime2),
                                                              db.Parameter("@OrderID", OrderID, DbType.Int32),
                                                              db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteNonQuery();
                            if (updateorderrs <= 0)
                            {
                                db.RollbackTransaction();
                                listres.Code = "0";
                                listres.Message = "strSqlUpdateOrder出错";
                                listres.Data = false;
                                return listres;
                            }
                            #endregion

                            #region 插入订单子表历史
                            string strSqlinsertSubOrderHis = @"INSERT INTO dbo.HST_ORDER_COMMODITY SELECT * FROM dbo.TBL_ORDER_COMMODITY WHERE CompanyID=@CompanyID
                                                               AND ID=@ObjectID";
                            int inserthisrSubOrders = db.SetCommand(strSqlinsertSubOrderHis, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                                    , db.Parameter("@ObjectID", ObjectID, DbType.Int32)).ExecuteNonQuery();

                            if (inserthisrSubOrders <= 0)
                            {
                                db.RollbackTransaction();
                                listres.Code = "0";
                                listres.Message = "strSqlinsertSubOrderHis添加出错";
                                listres.Data = false;
                                return listres;
                            }
                            #endregion

                            #region 修改子订单状态
                            string strSqlUpdateSubOrder = @"update [TBL_ORDER_COMMODITY] set Status=@Status,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime where CompanyID=@CompanyID AND ID=@ObjectID and Status = 1 ";
                            int updateSuborderrs = db.SetCommand(strSqlUpdateSubOrder,
                                                              db.Parameter("@Status", 4, DbType.Int32),
                                                              db.Parameter("@UpdaterID", updaterId, DbType.Int32),
                                                              db.Parameter("@UpdateTime", dt, DbType.DateTime2),
                                                              db.Parameter("@ObjectID", ObjectID, DbType.Int32),
                                                              db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteNonQuery();
                            if (updateSuborderrs <= 0)
                            {
                                db.RollbackTransaction();
                                listres.Code = "0";
                                listres.Message = "strSqlUpdateSubOrder出错";
                                listres.Data = false;
                                return listres;
                            }
                            #endregion
                        }

                    }
                    #endregion
                    db.CommitTransaction();
                    listres.Code = "1";
                    listres.Message = "终止成功";
                    listres.Data = model.TotalSalePrice > 0 && model.PaymentStatus > 1;
                    return listres;
                }
                #endregion

            }
        }

        public ObjectResult<bool> UpdateTotalSalePrice(int updaterId, int orderId, decimal totalSalePrice, DateTime dt, int OrderObjectID, string UserCardNo, int CompanyID, int ProductType, int BranchID)
        {
            ObjectResult<bool> listres = new ObjectResult<bool>();
            listres.Code = "0";
            listres.Message = "";
            listres.Data = false;
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                try
                {
                    #region 查询订单详情
                    string strSqlCheckOrder = "";
                    if (ProductType == 0)
                    {
                        strSqlCheckOrder = @" SELECT  T2.ServiceID ProductID ,T2.Status ,T1.PaymentStatus ,T2.Quantity  FROM    [ORDER] T1 WITH ( NOLOCK ) left JOIN [TBL_ORDER_SERVICE] T2 ON T1.ID = T2.OrderID WHERE   T1.ID =@OrderID and T1.CompanyID =@CompanyID ";
                    }
                    else
                    {
                        strSqlCheckOrder = @" SELECT  T2.CommodityID ProductID ,T2.Status ,T1.PaymentStatus ,T2.Quantity
                                                FROM    [ORDER] T1 WITH ( NOLOCK ) left JOIN [TBL_ORDER_COMMODITY] T2 ON T1.ID = T2.OrderID WHERE   T1.ID =@OrderID and T1.CompanyID =@CompanyID ";
                    }
                    OrderDelOperation_Model model = db.SetCommand(strSqlCheckOrder, db.Parameter("@OrderID", orderId, DbType.Int32), db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteObject<OrderDelOperation_Model>();
                    #endregion

                    if (model == null)
                    {
                        listres.Code = "0";
                        listres.Message = "找不到该订单";
                        listres.Data = false;
                        return listres;
                    }
                    if (model.Status == 3)
                    {
                        listres.Code = "2";
                        listres.Message = "订单已取消不能修改价格";
                        listres.Data = false;
                        return listres;
                    }
                    else if (model.PaymentStatus != 1 && model.PaymentStatus != 5)
                    {
                        listres.Code = "2";
                        listres.Message = "订单状态已变化，请刷新后查看";
                        listres.Data = false;
                        return listres;
                    }
                    else
                    {
                        decimal BPrice = 0;

                        string strSqlCard = " SELECT T1.CardID FROM [TBL_CUSTOMER_CARD] T1  WHERE T1.UserCardNo=@UserCardNo";

                        int cardId = db.SetCommand(strSqlCard, db.Parameter("@UserCardNo", UserCardNo, DbType.String)).ExecuteScalar<int>();
                        if (ProductType == 0)
                        {
                            string strSqlService = @" SELECT  T1.UnitPrice ,
                                                                  T1.MarketingPolicy , 
                                                                    CASE T1.MarketingPolicy
                                                                      WHEN 0 THEN T1.UnitPrice
                                                                      WHEN 1 THEN ROUND(T1.UnitPrice * ISNULL(T2.Discount, 1), 2)
                                                                      WHEN 2 THEN T1.PromotionPrice 
                                                                    END PromotionPrice
                                                            FROM    [SERVICE] T1
                                                                    LEFT JOIN [TBL_CARD_DISCOUNT] T2 ON T1.DiscountID = T2.DiscountID AND T2.CardID = @CardID
                                                            WHERE   T1.CompanyID = @CompanyID
                                                                    AND T1.ID = @ProductID  ";
                            Service_Model mSer = db.SetCommand(strSqlService, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                , db.Parameter("@ProductID", model.ProductID, DbType.Int32)
                                , db.Parameter("@CardID", cardId, DbType.Int32)).ExecuteObject<Service_Model>();

                            if (mSer == null)
                            {
                                listres.Code = "0";
                                listres.Message = "找不到该订单";
                                listres.Data = false;
                                return listres;
                            }

                            if (mSer.MarketingPolicy == 2 && string.IsNullOrWhiteSpace(UserCardNo))
                            {
                                BPrice = Math.Round(mSer.UnitPrice * (decimal)model.Quantity, 2);
                            }
                            else
                            {
                                BPrice = Math.Round(mSer.PromotionPrice * (decimal)model.Quantity, 2);
                            }
                        }
                        else
                        {
                            string strSqlCommodity = @" SELECT  T1.UnitPrice ,
                                                                    T1.MarketingPolicy , 
                                                                    CASE T1.MarketingPolicy
                                                                      WHEN 0 THEN T1.UnitPrice
                                                                      WHEN 1 THEN ROUND(T1.UnitPrice * ISNULL(T2.Discount, 1), 2)
                                                                      WHEN 2 THEN T1.PromotionPrice 
                                                                    END PromotionPrice
                                                            FROM    [COMMODITY] T1
                                                                    LEFT JOIN [TBL_CARD_DISCOUNT] T2 ON T1.DiscountID = T2.DiscountID
                                                                                                        AND T2.CardID = @CardID
                                                            WHERE   T1.CompanyID = @CompanyID
                                                                    AND T1.ID = @ProductID ";

                            Commodity_Model mCom = db.SetCommand(strSqlCommodity, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                , db.Parameter("@ProductID", model.ProductID, DbType.Int32)
                                , db.Parameter("@CardID", cardId, DbType.Int32)).ExecuteObject<Commodity_Model>();

                            if (mCom == null)
                            {
                                listres.Code = "0";
                                listres.Message = "找不到该订单";
                                listres.Data = false;
                                return listres;
                            }

                            if (mCom.MarketingPolicy == 2 && string.IsNullOrWhiteSpace(UserCardNo))
                            {
                                BPrice = Math.Round(mCom.UnitPrice * (decimal)model.Quantity, 2);
                            }
                            else
                            {
                                BPrice = Math.Round(mCom.PromotionPrice * (decimal)model.Quantity, 2);
                            }
                        }


                        #region 插入订单历史表
                        string strSqlinsertHis = @"insert into HISTORY_ORDER select * from [ORDER] where ID = @ID and CompanyID=@CompanyID ";
                        int inserthisrs = db.SetCommand(strSqlinsertHis, db.Parameter("@ID", orderId, DbType.Int32)
                            , db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteNonQuery();
                        #endregion

                        if (inserthisrs <= 0)
                        {
                            db.RollbackTransaction();
                            listres.Code = "0";
                            listres.Message = "strSqlinsertHis添加出错";
                            listres.Data = false;
                            return listres;
                        }

                        #region 修改订单价格
                        string strSqlUpdateOrder = @"update [ORDER] set TotalSalePrice=@TotalSalePrice,UnPaidPrice=@UnPaidPrice,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime,PaymentStatus=@PaymentStatus {0} where ID=@ID and CompanyID=@CompanyID and RecordType =1 ";
                        string strSqlCalc = "";
                        //if (UserCardNo != "" && UserCardNo != null)
                        //{
                        strSqlCalc = " ,TotalCalcPrice=@TotalCalcPrice ";
                        //}
                        strSqlUpdateOrder = string.Format(strSqlUpdateOrder, strSqlCalc);

                        int updateorderrs = db.SetCommand(strSqlUpdateOrder,
                                                          db.Parameter("@TotalSalePrice", totalSalePrice, DbType.Decimal),
                                                          db.Parameter("@PaymentStatus", totalSalePrice == 0 ? 5 : 1, DbType.Int32),
                                                          db.Parameter("@UnPaidPrice", totalSalePrice, DbType.Decimal),
                                                          db.Parameter("@UpdaterID", updaterId, DbType.Int32),
                                                          db.Parameter("@UpdateTime", dt, DbType.DateTime2),
                                                          db.Parameter("@TotalCalcPrice", BPrice, DbType.Decimal),
                                                          db.Parameter("@ID", orderId, DbType.Int32)
                                                          , db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteNonQuery();
                        #endregion

                        if (updateorderrs != 1)
                        {
                            db.RollbackTransaction();
                            listres.Code = "0";
                            listres.Message = "strSqlUpdateOrder出错";
                            listres.Data = false;
                            return listres;
                        }



                        if (ProductType == 0)
                        {
                            #region 服务

                            #region 插入订单子表历史
                            string strSqlCommand = @"INSERT INTO dbo.HST_ORDER_SERVICE SELECT * FROM dbo.TBL_ORDER_SERVICE WHERE ID=@OrderObjectID AND CompanyID=@CompanyID";
                            bool rs = db.SetCommand(strSqlCommand, db.Parameter("@OrderObjectID", OrderObjectID, DbType.Int32),
                                db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteNonQuery() == 1;
                            if (!rs)
                            {
                                db.RollbackTransaction();
                                listres.Code = "0";
                                listres.Message = "strSqlUpdateOrderService出错";
                                listres.Data = false;
                                return listres;
                            }
                            #endregion

                            #region 更新订单子表C价格
                            strSqlCommand = @"update [TBL_ORDER_SERVICE] set 
                                          {0}
                                          SumSalePrice =@SumSalePrice,
                                          UserCardNo =@UserCardNo,
                                          UpdaterID = @UpdaterID,
                                          UpdateTime =@UpdateTime
                                          where ID = @OrderObjectID                                           
                                          and CompanyID=@CompanyID";

                            //if (UserCardNo != "" && UserCardNo != null)
                            //{
                            strSqlCalc = " SumCalcPrice =@SumCalcPrice , ";
                            //}
                            strSqlCommand = string.Format(strSqlCommand, strSqlCalc);

                            rs = db.SetCommand(strSqlCommand, db.Parameter("@SumCalcPrice", BPrice, DbType.Decimal)
                                , db.Parameter("@SumSalePrice", totalSalePrice, DbType.Decimal),
                                 db.Parameter("@UserCardNo", UserCardNo, DbType.String),
                                db.Parameter("@UpdaterID", updaterId, DbType.Int32),
                                db.Parameter("@UpdateTime", dt, DbType.DateTime2),
                                db.Parameter("@OrderObjectID", OrderObjectID, DbType.Int32),
                                db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteNonQuery() == 1;
                            if (!rs)
                            {
                                db.RollbackTransaction();
                                listres.Code = "0";
                                listres.Message = "strSqlUpdateOrderService出错";
                                listres.Data = false;
                                return listres;
                            }
                            #endregion

                            #endregion
                        }
                        else
                        {
                            #region 商品

                            #region 插入订单子表历史
                            string strSqlCommand = @"INSERT INTO dbo.HST_ORDER_COMMODITY SELECT * FROM dbo.TBL_ORDER_COMMODITY WHERE ID=@OrderObjectID AND CompanyID=@CompanyID";
                            bool rs = db.SetCommand(strSqlCommand, db.Parameter("@OrderObjectID", OrderObjectID, DbType.Int32),
                                db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteNonQuery() == 1;
                            if (!rs)
                            {
                                db.RollbackTransaction();
                                listres.Code = "0";
                                listres.Message = "strSqlUpdateOrderCommodity出错";
                                listres.Data = false;
                                return listres;
                            }

                            #endregion

                            #region 更新订单子表C价格
                            strSqlCommand = @"update [TBL_ORDER_COMMODITY] set 
                                            {0}
                                          SumSalePrice =@SumSalePrice,
                                          UserCardNo =@UserCardNo,
                                          UpdaterID = @UpdaterID,
                                          UpdateTime =@UpdateTime
                                          where ID = @OrderObjectID                                           
                                          and CompanyID=@CompanyID";


                            //if (UserCardNo != "" && UserCardNo != null)
                            //{
                            strSqlCalc = " SumCalcPrice =@SumCalcPrice , ";
                            //}
                            strSqlCommand = string.Format(strSqlCommand, strSqlCalc);

                            rs = db.SetCommand(strSqlCommand
                                , db.Parameter("@SumCalcPrice", BPrice, DbType.Decimal)
                                , db.Parameter("@SumSalePrice", totalSalePrice, DbType.Decimal),
                                db.Parameter("@UserCardNo", UserCardNo, DbType.String),
                                db.Parameter("@UpdaterID", updaterId, DbType.Int32),
                                db.Parameter("@UpdateTime", dt, DbType.DateTime2),
                                db.Parameter("@OrderObjectID", OrderObjectID, DbType.Int32),
                                db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteNonQuery() == 1;
                            if (!rs)
                            {
                                db.RollbackTransaction();
                                listres.Code = "0";
                                listres.Message = "strSqlUpdateOrderCommodity出错";
                                listres.Data = false;
                                return listres;
                            }
                            #endregion

                            #endregion
                        }


                        db.CommitTransaction();
                        listres.Code = "1";
                        listres.Message = "success";
                        listres.Data = true;
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

        public ObjectResult<bool> updateTreatmentExecutorID(UtilityOperation_Model model)
        {
            ObjectResult<bool> listres = new ObjectResult<bool>();
            listres.Code = "0";
            listres.Message = "修改失败";
            listres.Data = false;
            DateTime dt = DateTime.Now;
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();


                    string strSqlCheck = " select status from [TREATMENT] WHERE ID =@ID  and CompanyID=@CompanyID ";
                    int status = db.SetCommand(strSqlCheck
                             , db.Parameter("@ID", model.TreatmentID, DbType.Int32)
                             , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();

                    if (status > 1)
                    {
                        switch (status)
                        {
                            case 2:
                                listres.Message = "该服务已完成不能修改操作人";
                                break;
                            case 3:
                                listres.Message = "该服务已取消不能修改操作人";
                                break;
                            case 4:
                                listres.Message = "该服务已终止不能修改操作人";
                                break;
                            case 5:
                                listres.Message = "该服务已完成不能修改操作人";
                                break;

                        }

                        listres.Code = "2";
                        listres.Data = false;
                        return listres;

                    }
                    else
                    {

                        string strSqlHistory = @" INSERT INTO [HISTORY_TREATMENT] SELECT * FROM [TREATMENT] WHERE ID =@ID  and CompanyID=@CompanyID  ";

                        int res = db.SetCommand(strSqlHistory
                            , db.Parameter("@ID", model.TreatmentID, DbType.Int32)
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                        if (res <= 0)
                        {
                            db.RollbackTransaction();
                            listres.Code = "0";
                            listres.Message = "strSqlTreatmentHistory出错";
                            listres.Data = false;
                            return listres;
                        }

                        string strUpdateSql = @"update TREATMENT set
                            ExecutorID=@ExecuotrID, 
                            UpdaterID=@UpdaterID, 
                            UpdateTime=@UpdateTime
                            where ID=@ID and CompanyID=@CompanyID ";

                        int updateRes = db.SetCommand(strUpdateSql, db.Parameter("@ExecuotrID", model.ExecutorID, DbType.Int32)
                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                            , db.Parameter("@UpdateTime", model.Time, DbType.DateTime)
                            , db.Parameter("@ID", model.TreatmentID, DbType.Int32)
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                        if (updateRes <= 0)
                        {
                            db.RollbackTransaction();
                            listres.Code = "0";
                            listres.Message = "strUpdateSql出错";
                            listres.Data = false;
                            return listres;
                        }


                        db.CommitTransaction();
                        listres.Code = "1";
                        listres.Message = "success";
                        listres.Data = true;
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

        public ObjectResult<bool> updateTGServicePIC(UtilityOperation_Model model)
        {
            ObjectResult<bool> listres = new ObjectResult<bool>();
            listres.Code = "0";
            listres.Message = "修改失败";
            listres.Data = false;
            DateTime dt = DateTime.Now;
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();


                    string strSqlCheck = " select TGStatus from [TBL_TREATGROUP] WHERE GroupNo =@GroupNo  and CompanyID=@CompanyID ";
                    int status = db.SetCommand(strSqlCheck
                             , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)
                             , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();

                    if (status > 1)
                    {
                        switch (status)
                        {
                            case 2:
                                listres.Message = "该组服务已完成不能修改操作人";
                                break;
                            case 3:
                                listres.Message = "该组服务已取消不能修改操作人";
                                break;
                            case 4:
                                listres.Message = "该组服务已终止不能修改操作人";
                                break;
                            case 5:
                                listres.Message = "该组服务已完成不能修改操作人";
                                break;

                        }

                        listres.Code = "2";
                        listres.Data = false;
                        return listres;

                    }
                    else
                    {

                        string strSqlHistory = @" insert into HST_TREATGROUP select * from TBL_TREATGROUP WHERE GroupNo =@GroupNo  and CompanyID=@CompanyID  ";

                        int res = db.SetCommand(strSqlHistory
                             , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                        if (res <= 0)
                        {
                            db.RollbackTransaction();
                            listres.Code = "0";
                            listres.Message = "strSqlHistory出错";
                            listres.Data = false;
                            return listres;
                        }

                        string strUpdateSql = @"update TBL_TREATGROUP set
                            ServicePIC=@ServicePIC, 
                            UpdaterID=@UpdaterID, 
                            UpdateTime=@UpdateTime
                            where GroupNo =@GroupNo  and CompanyID=@CompanyID  ";

                        int updateRes = db.SetCommand(strUpdateSql, db.Parameter("@ServicePIC", model.ServicePIC, DbType.Int32)
                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                            , db.Parameter("@UpdateTime", model.Time, DbType.DateTime)
                            , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                        if (updateRes != 1)
                        {
                            db.RollbackTransaction();
                            listres.Code = "0";
                            listres.Message = "strUpdateSql出错";
                            listres.Data = false;
                            return listres;
                        }


                        db.CommitTransaction();
                        listres.Code = "1";
                        listres.Message = "success";
                        listres.Data = true;
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

        public GetTGDetail_Model getTGDetail(long GroupNo, int companyId, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  T1.GroupNo ,
                                            T1.TGStartTime ,
                                            T1.TGEndTime ,
                                            T1.TGStatus ,
                                            T1.Remark ,
                                            T2.BranchName ,"
                                            + Common.Const.strHttp
                                            + Common.Const.server
                                            + Common.Const.strMothod
                                            + Common.Const.strSingleMark
                                            + "  + cast(T3.CompanyID as nvarchar(10)) + "
                                            + Common.Const.strSingleMark
                                            + "/Sign/"
                                            + Common.Const.strSingleMark
                                            + "  + cast(T3.CustomerID as nvarchar(16)) + "
                                            + Common.Const.strSingleMark
                                            + "/"
                                            + Common.Const.strSingleMark
                                            + "  + cast(T3.GroupNo as nvarchar(18))+ "
                                            + Common.Const.strSingleMark
                                            + "/"
                                            + Common.Const.strSingleMark
                                            + "+ T3.FileName +"
                                            + Common.Const.strThumb
                                            + " ThumbnailURL "
                                + @"FROM    [TBL_TREATGROUP] T1
                                            INNER JOIN [BRANCH] T2 ON T1.BranchID = T2.ID AND T1.CompanyID = T2.CompanyID
                                            LEFT JOIN [IMAGE_SIGN] T3 WITH ( NOLOCK ) ON T1.GroupNo = T3.GroupNo AND T3.ProductType = 0
                                    WHERE   T1.GroupNo = @GroupNo
                                            AND T1.CompanyID = @CompanyID";



                GetTGDetail_Model model = db.SetCommand(strSql
                     , db.Parameter("@GroupNo", GroupNo, DbType.Int64)
                    , db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                    , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteObject<GetTGDetail_Model>();

                return model;
            }
        }

        public bool updateTGRemark(UtilityOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();


                    string strSqlHistory = @" insert into HST_TREATGROUP select * from TBL_TREATGROUP WHERE GroupNo =@GroupNo  and CompanyID=@CompanyID  ";

                    int res = db.SetCommand(strSqlHistory
                         , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (res <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    string strUpdateSql = @"update TBL_TREATGROUP set
                            Remark=@Remark, 
                            UpdaterID=@UpdaterID, 
                            UpdateTime=@UpdateTime
                            where GroupNo =@GroupNo  and CompanyID=@CompanyID  ";

                    int updateRes = db.SetCommand(strUpdateSql, db.Parameter("@Remark", model.Remark, DbType.String)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", model.Time, DbType.DateTime)
                         , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (updateRes != 1)
                    {
                        db.RollbackTransaction();
                        return false;
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

        public bool updateTreatmentRemark(UtilityOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {

                string strSqlCommond = @"update [TREATMENT] set 
                                            Remark = @Remark,
                                            UpdaterID = @UpdaterID,
                                            UpdateTime = @UpdateTime
                                            where CompanyID = @CompanyID
                                            and ID = @ID";

                int res = db.SetCommand(strSqlCommond, db.Parameter("@Remark", model.Remark, DbType.String)
                    , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                    , db.Parameter("@UpdateTime", model.Time, DbType.DateTime)
                    , db.Parameter("@ID", model.TreatmentID, DbType.Int32)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                if (res != 1)
                {
                    return false;
                }

                return true;
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

        public int updateOrderCustomerID(int companyID, int branchID, int updaterID, List<OrderUpdateCustomerIDOperation_Model> list)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                DateTime time = DateTime.Now.ToLocalTime();
                foreach (OrderUpdateCustomerIDOperation_Model item in list)
                {

                    #region 查询基本数据
                    string strSelSql = "";
                    if (item.ProductType == 0)
                    {
                        strSelSql = @"SELECT  T1.PaymentStatus ,
                                                T2.CustomerID ,
                                                T2.ServiceID AS ProductID ,
                                                T2.SumOrigPrice AS TotalOrigPrice ,
                                                T3.DiscountID,
                                                T3.MarketingPolicy  ,
                                                T3.PromotionPrice 
                                        FROM    [ORDER] T1 WITH ( NOLOCK ) 
                                                INNER JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T2.OrderID = T1.ID 
                                                INNER JOIN [SERVICE] T3 WITH(NOLOCK) ON T2.ServiceID=T3.ID 
                                        WHERE   T1.CompanyID = @CompanyID
                                                AND T1.ID = @OrderID
                                                AND T2.ID = @OrderObjectID";
                    }
                    else
                    {
                        strSelSql = @"SELECT  T1.PaymentStatus ,
                                                T2.CustomerID ,
                                                T2.CommodityID AS ProductID ,
                                                T2.SumOrigPrice AS TotalOrigPrice ,
                                                T3.DiscountID ,
                                                T3.MarketingPolicy ,
                                                T3.PromotionPrice    
                                        FROM    [ORDER] T1 WITH ( NOLOCK )
                                                INNER JOIN [TBL_ORDER_COMMODITY] T2 WITH ( NOLOCK ) ON T2.OrderID = T1.ID 
                                                INNER JOIN [COMMODITY] T3 WITH(NOLOCK) ON T2.CommodityID=T3.ID 
                                        WHERE   T1.CompanyID = @CompanyID
                                                AND T1.ID = @OrderID
                                                AND T2.ID = @OrderObjectID";
                    }

                    DataTable dt = db.SetCommand(strSelSql
                        , db.Parameter("@CompanyID", companyID, DbType.Int32)
                        , db.Parameter("@OrderID", item.OrderID, DbType.Int32)
                        , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)).ExecuteDataTable();

                    if (dt == null || dt.Rows.Count <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    int oldCustomerID = StringUtils.GetDbInt(dt.Rows[0]["CustomerID"].ToString());
                    int oldPaymentStatus = StringUtils.GetDbInt(dt.Rows[0]["PaymentStatus"].ToString());
                    int productID = StringUtils.GetDbInt(dt.Rows[0]["ProductID"].ToString());
                    int discountID = StringUtils.GetDbInt(dt.Rows[0]["DiscountID"].ToString());
                    decimal totalOrigPrice = StringUtils.GetDbDecimal(dt.Rows[0]["TotalOrigPrice"].ToString());
                    decimal promotionPrice = StringUtils.GetDbDecimal(dt.Rows[0]["PromotionPrice"].ToString());
                    int marketingPolicy = StringUtils.GetDbInt(dt.Rows[0]["MarketingPolicy"].ToString());

                    if (oldCustomerID == item.CustomerID)
                    {
                        continue;
                    }

                    if (oldPaymentStatus != 1)
                    {
                        db.RollbackTransaction();
                        return 2;
                    }
                    #endregion

                    #region 查询用户默认卡的折扣 算出新的B价格
                    string selDiscountSql = @"SELECT  ISNULL(T3.Discount, 1) AS Discount ,T2.UserCardNo
                                            FROM    [CUSTOMER] T1 WITH ( NOLOCK )
                                                    INNER JOIN [TBL_CUSTOMER_CARD] T2 WITH ( NOLOCK ) ON T1.DefaultCardNo = T2.UserCardNo
                                                    INNER JOIN [TBL_CARD_DISCOUNT] T3 ON T2.CardID = T3.CardID
                                            WHERE   T1.CompanyID = @CompanyID
                                                    AND T1.UserID = @CustomerID
                                                    AND T2.UserID = @CustomerID
                                                    AND T3.DiscountID = @DiscountID";

                    DataTable discountDt = db.SetCommand(selDiscountSql
                       , db.Parameter("@CompanyID", companyID, DbType.Int32)
                       , db.Parameter("@CustomerID", item.CustomerID, DbType.Int32)
                       , db.Parameter("@DiscountID", discountID, DbType.Int32)).ExecuteDataTable();

                    decimal discount = 1;
                    object userCardNo = DBNull.Value;
                    if (discountDt != null && discountDt.Rows.Count > 0)
                    {
                        discount = StringUtils.GetDbDecimal(discountDt.Rows[0]["Discount"].ToString(), 1);
                        userCardNo = StringUtils.GetDbString(discountDt.Rows[0]["UserCardNo"].ToString(), "");
                        if ((string)userCardNo == "")
                        {
                            userCardNo = DBNull.Value;
                        }
                        else
                        {
                            if (marketingPolicy == 2)
                            {
                                totalOrigPrice = promotionPrice;
                                discount = 1;
                            }
                        }
                    }
                    else
                    {
                        string selCardCountSql = @"SELECT  COUNT(0)
                                                    FROM    [TBL_CUSTOMER_CARD] T1 WITH ( NOLOCK )
                                                            INNER JOIN [MST_CARD] T2 WITH ( NOLOCK ) ON T1.CardID = T2.ID
                                                    WHERE   UserID = @CustomerID
                                                            AND T2.CardTypeID = 1";
                        int cardCount = db.SetCommand(selCardCountSql
                                    , db.Parameter("@CustomerID", item.CustomerID, DbType.Int32)).ExecuteScalar<int>();
                        if (cardCount > 0)
                        {
                            if (marketingPolicy == 2)
                            {
                                totalOrigPrice = promotionPrice;
                                discount = 1;
                            }
                        }
                    }

                    decimal newCalPrice = totalOrigPrice * discount;

                    #endregion

                    #region 插入订单主表历史表
                    string strSqlinsertHis = @"insert into HISTORY_ORDER select * from [ORDER] where CompanyID=@CompanyID AND ID = @OrderID ";
                    int inserthisrs = db.SetCommand(strSqlinsertHis, db.Parameter("@CompanyID", companyID, DbType.Int32)
                                            , db.Parameter("@OrderID", item.OrderID, DbType.Int32)).ExecuteNonQuery();

                    if (inserthisrs <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    #endregion

                    #region 修改订单状态
                    string strSqlUpdateOrder = @"UPDATE  [ORDER]
                                                SET     CustomerID = @CustomerID ,
                                                        TotalSalePrice = @TotalCalcPrice ,
                                                        TotalCalcPrice = @TotalCalcPrice ,
                                                        UnPaidPrice = @TotalCalcPrice ,
                                                        UpdaterID = @UpdaterID ,
                                                        UpdateTime = @UpdateTime
                                                WHERE   CompanyID = @CompanyID
                                                        AND ID = @OrderID";
                    int updateorderrs = db.SetCommand(strSqlUpdateOrder,
                                                      db.Parameter("@CustomerID", item.CustomerID, DbType.Int32),
                                                      db.Parameter("@TotalCalcPrice", newCalPrice, DbType.Decimal),
                                                      db.Parameter("@UpdaterID", updaterID, DbType.Int32),
                                                      db.Parameter("@UpdateTime", time, DbType.DateTime2),
                                                      db.Parameter("@OrderID", item.OrderID, DbType.Int32),
                                                      db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteNonQuery();
                    if (updateorderrs != 1)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    #endregion

                    if (item.ProductType == 0)
                    {
                        #region 服务

                        #region 插入订单子表历史
                        string strSqlCommand = @"INSERT INTO [HST_ORDER_SERVICE] SELECT * FROM [TBL_ORDER_SERVICE] WHERE ID=@OrderObjectID AND CompanyID=@CompanyID";
                        int rs = db.SetCommand(strSqlCommand, db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32),
                            db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteNonQuery();
                        if (rs <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        #region 更新订单子表BC价格
                        strSqlCommand = @"update [TBL_ORDER_SERVICE] set 
                                          CustomerID=@CustomerID ,
                                          SumCalcPrice =@TotalCalcPrice,
                                          SumSalePrice =@TotalCalcPrice,
                                          UserCardNo =@UserCardNo,
                                          UpdaterID = @UpdaterID,
                                          UpdateTime =@UpdateTime
                                          where ID = @OrderObjectID                                           
                                          and CompanyID=@CompanyID";
                        rs = db.SetCommand(strSqlCommand
                            , db.Parameter("@CustomerID", item.CustomerID, DbType.Int32)
                            , db.Parameter("@TotalCalcPrice", newCalPrice, DbType.Decimal)
                            , db.Parameter("@UserCardNo", userCardNo, DbType.String)
                            , db.Parameter("@UpdaterID", updaterID, DbType.Int32)
                            , db.Parameter("@UpdateTime", time, DbType.DateTime2)
                            , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)
                            , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteNonQuery();
                        if (rs != 1)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        #endregion
                    }
                    else
                    {
                        #region 商品

                        #region 插入订单子表历史
                        string strSqlCommand = @"INSERT INTO [HST_ORDER_COMMODITY] SELECT * FROM [TBL_ORDER_COMMODITY] WHERE ID=@OrderObjectID AND CompanyID=@CompanyID";
                        int rs = db.SetCommand(strSqlCommand, db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32),
                            db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteNonQuery();
                        if (rs <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        #endregion

                        #region 更新订单子表BC价格
                        strSqlCommand = @"update [TBL_ORDER_COMMODITY] set 
                                          CustomerID=@CustomerID ,
                                          SumCalcPrice =@TotalCalcPrice,
                                          SumSalePrice =@TotalCalcPrice,
                                          UserCardNo =@UserCardNo,
                                          UpdaterID = @UpdaterID,
                                          UpdateTime =@UpdateTime
                                          where ID = @OrderObjectID                                           
                                          and CompanyID=@CompanyID";
                        rs = db.SetCommand(strSqlCommand
                            , db.Parameter("@CustomerID", item.CustomerID, DbType.Int32)
                            , db.Parameter("@TotalCalcPrice", newCalPrice, DbType.Decimal)
                            , db.Parameter("@UserCardNo", userCardNo, DbType.String)
                            , db.Parameter("@UpdaterID", updaterID, DbType.Int32)
                            , db.Parameter("@UpdateTime", time, DbType.DateTime2)
                            , db.Parameter("@OrderObjectID", item.OrderObjectID, DbType.Int32)
                            , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteNonQuery();
                        if (rs != 1)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                        #endregion

                        #endregion
                    }
                }

                db.CommitTransaction();
                return 1;

            }
        }

        public string GetProductNameWithOrderID(int companyID, int orderID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT  CASE T1.ProductType
                                              WHEN 0 THEN T2.ServiceName
                                              ELSE T3.CommodityName
                                            END AS ProductName
                                    FROM    [ORDER] T1 WITH ( NOLOCK )
                                            LEFT JOIN [TBL_ORDER_SERVICE] T2 WITH ( NOLOCK ) ON T2.OrderID = T1.ID
                                            LEFT JOIN [TBL_ORDER_COMMODITY] T3 WITH ( NOLOCK ) ON T3.OrderID = T1.ID
                                    WHERE   T1.ID = @OrderID
                                            AND T1.CompanyID = @CompanyID ";

                string productName = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteScalar<string>();

                return productName;
            }
        }

        public int CanOrderCanPay(List<int> orderIDList, out List<int> orderIDListWithout0Price, out PaymentCheck_Model paymentCheckModel)
        {
            using (DbManager db = new DbManager())
            {
                orderIDListWithout0Price = new List<int>();
                paymentCheckModel = new PaymentCheck_Model();
                int CustomerID = 0;
                foreach (int item in orderIDList)
                {
                    PaymentStatusCheck_Model paymentStatus = new PaymentStatusCheck_Model();
                    string strSqlCheckIsPaid = @"Select TotalSalePrice,UnPaidPrice, PaymentStatus ,Status, CustomerID 
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

                    if (CustomerID <= 0)
                    {
                        CustomerID = paymentStatus.CustomerID;
                    }
                    else
                    {
                        if (CustomerID != paymentStatus.CustomerID)
                        {
                            return 0;
                        }
                    }

                    if (paymentStatus.TotalSalePrice > 0)
                    {
                        // 新数组排除0元订单
                        orderIDListWithout0Price.Add(item);
                        paymentCheckModel.TotalCount += 1;
                        paymentCheckModel.TotalAmount += paymentStatus.UnPaidPrice;
                    }
                }
                paymentCheckModel.CustomerID = CustomerID;
                return 1;
            }
        }

        #region WEB方法
        public OrderDetailForWeb_Model getOrderDetailForWeb(int OrderID, int CompanyID, int BranchID)
        {
            using (DbManager db = new DbManager())
            {
                string BranchWhere = string.Empty;
                if (BranchID > 0)
                {
                    BranchWhere = " AND a.BranchID=@BranchID";
                }
                string strSql = @"SELECT a.ProductType FROM dbo.[ORDER] a WITH (ROWLOCK,XLOCK) 
                                WHERE a.ID=@ID AND a.RecordType=1 AND a.CompanyID=@CompanyID" + BranchWhere;

                var ProductType = db.SetCommand(strSql, db.Parameter("@ID", OrderID, DbType.Int32)
                    , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", BranchID, DbType.Int32)).ExecuteScalar();
                if (ProductType == null)
                    return null;
                else if (HS.Framework.Common.Util.StringUtils.GetDbInt(ProductType) == 0)
                {
                    strSql = @"SELECT a.CompanyID
                                ,a.BranchID
                                ,a.ID
                                ,b.ServiceName AS ProductName
                                ,c.Name AS CustomerName
                                ,e.Name AS CreatorName
                                ,b.Status AS OrderStatus
                                ,a.PaymentStatus
                                ,d.Name AS ResponsiblePersonName
                                ,d.UserID AS ResponsiblePersonID
                                ,b.Quantity
                                ,b.IsPast
                                ,b.SumOrigPrice AS TotalOrigPrice
                                ,b.SumCalcPrice as TotalCalcPrice
                                ,b.SumSalePrice as TotalSalePrice
                                ,a.OrderTime
                                ,f.BranchName
                                ,b.Expirationtime
                                ,h.PolicyName
                                FROM dbo.[ORDER] a 
                                LEFT JOIN dbo.TBL_ORDER_SERVICE b ON a.ID=b.OrderID
								LEFT JOIN dbo.TBL_BUSINESS_CONSULTANT g on a.ID = g.MasterID and g.BusinessType = 1 and g.ConsultantType = 1
                                LEFT JOIN dbo.CUSTOMER c ON b.CustomerID=c.UserID
                                LEFT JOIN dbo.ACCOUNT d ON g.ConsultantID = d.UserID
                                LEFT JOIN dbo.ACCOUNT e ON b.CreatorID = e.UserID
                                LEFT JOIN dbo.BRANCH f ON b.BranchID=f.ID
                                LEFT JOIN dbo.TBL_CUSTOMER_BENEFIT i on a.ID = i.OrderID
                                LEFT JOIN dbo.TBL_BENEFIT_POLICY h on i.PolicyID = h.PolicyID
                                WHERE a.CompanyID=@CompanyID AND a.ID=@ID AND a.RecordType<>2" + BranchWhere;
                }
                else
                {
                    strSql = @"SELECT  a.CompanyID ,
                                a.BranchID ,
                                a.ID ,
                                b.CommodityName AS ProductName ,
                                c.Name AS CustomerName ,
                                e.Name AS CreatorName ,
                                b.Status as OrderStatus ,
                                a.PaymentStatus ,
                                d.Name AS ResponsiblePersonName ,
                                d.UserID AS ResponsiblePersonID,
                                b.Quantity ,
                                0 AS IsPast ,
                                b.SumOrigPrice AS TotalOrigPrice,
                                b.SumCalcPrice as TotalCalcPrice,
                                b.SumSalePrice as TotalSalePrice,
                                a.OrderTime ,
                                f.BranchName ,
                                '2099-12-31 23:59:59' AS Expirationtime
                                ,h.PolicyName
                        FROM    dbo.[ORDER] a
                                LEFT JOIN dbo.TBL_ORDER_COMMODITY b ON a.ID = b.OrderID
								LEFT JOIN dbo.TBL_BUSINESS_CONSULTANT g on a.ID = g.MasterID and g.BusinessType = 1 and g.ConsultantType = 1
                                LEFT JOIN dbo.CUSTOMER c ON b.CustomerID = c.UserID
                                LEFT JOIN dbo.ACCOUNT d ON g.ConsultantID = d.UserID
                                LEFT JOIN dbo.ACCOUNT e ON b.CreatorID = e.UserID
                                LEFT JOIN dbo.BRANCH f ON b.BranchID = f.ID
                                LEFT JOIN dbo.TBL_CUSTOMER_BENEFIT i on a.ID = i.OrderID
                                LEFT JOIN dbo.TBL_BENEFIT_POLICY h on i.PolicyID = h.PolicyID
                        WHERE   a.CompanyID = @CompanyID
                                AND a.ID = @ID
                                AND a.RecordType <> 2" + BranchWhere;
                }

                OrderDetailForWeb_Model model = db.SetCommand(strSql, db.Parameter("@ID", OrderID, DbType.Int32)
                    , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", BranchID, DbType.Int32)).ExecuteObject<OrderDetailForWeb_Model>();

                return model;

            }


        }

        public int updateOrder(OrderDetailOperationForWeb_Model model, out string message)
        {
            message = "操作成功";
            using (DbManager db = new DbManager())
            {
                string BranchWhere = string.Empty;
                if (model.BranchID > 0)
                {
                    BranchWhere = " AND a.BranchID=@BranchID";
                }
                string strSql = @"SELECT a.ProductType,a.PaymentStatus FROM dbo.[ORDER] a WITH (ROWLOCK,XLOCK) 
                                WHERE a.ID=@ID AND a.RecordType=1 AND a.CompanyID=@CompanyID" + BranchWhere;
                DataTable dt = db.SetCommand(strSql, db.Parameter("@ID", model.OrderID, DbType.Int32)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteDataTable();

                strSql = @" SELECT  COUNT(0)
                            FROM    dbo.TBL_ORDERPAYMENT_RELATIONSHIP T1
                                    LEFT JOIN dbo.PAYMENT T2 ON T1.PaymentID = T2.ID
                            WHERE   T1.OrderID = @OrderID AND T2.Status=2 AND
                            T2.Type =1  AND DATEDIFF(ss,T2.PaymentTime,@OrderTime) > 0";

                int count = db.SetCommand(strSql
                    , db.Parameter("@OrderID", model.OrderID, DbType.Int32)
                    , db.Parameter("@OrderTime", model.OrderTime, DbType.DateTime2)).ExecuteScalar<int>();

                string strSqlTGCount = @" select count(0) from  [TBL_TREATGROUP] T1 where T1.OrderID =@OrderID AND T1.TGStartTime<@OrderTime AND T1.TGStatus <> 3  ";

                int TGCount = db.SetCommand(strSqlTGCount
                    , db.Parameter("@OrderID", model.OrderID, DbType.Int32)
                    , db.Parameter("@OrderTime", model.OrderTime, DbType.DateTime2)).ExecuteScalar<int>();

                if (dt == null)
                {
                    message = "未找到订单";
                    return -1;
                }
                else if (count > 0)
                {
                    message = "订单时间在支付时间之后";
                    return -3;//订单时间在支付时间之后
                }
                else if (TGCount > 0)
                {
                    message = "订单时间在服务时间之后";
                    return -3;//订单时间在支付时间之后
                }
                else
                {
                    db.BeginTransaction();
                    int row = 0;

                    strSql = @"INSERT INTO dbo.HISTORY_ORDER SELECT * FROM dbo.[ORDER] WHERE ID=@OrderID";

                    row = db.SetCommand(strSql, db.Parameter("@OrderID", model.OrderID, DbType.Int32)).ExecuteNonQuery();

                    if (row != 1)
                    {
                        db.RollbackTransaction();
                        message = "操作失败";
                        return -4;
                    }

                    strSql = @"
                           UPDATE dbo.[ORDER] SET
                       --    ResponsiblePersonID =@ResponsiblePersonID ,
                          OrderTime =@OrderTime
                           ,UpdaterID =@UpdaterID
                           ,UpdateTime =@UpdateTime 
                           ,Status=@Status
                           WHERE ID =@OrderID 
                           and RecordType<>2 ";

                    row = db.SetCommand(strSql
                        , db.Parameter("@OrderID", model.OrderID, DbType.Int32)
                        , db.Parameter("@Status", model.Status, DbType.Int32)
                        //   , db.Parameter("@ResponsiblePersonID", model.ResponsiblePersonID, DbType.Int32)
                        , db.Parameter("@OrderTime", model.OrderTime, DbType.DateTime2)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                        ).ExecuteNonQuery();
                    if (row != 1)
                    {
                        db.RollbackTransaction();
                        message = "操作失败";
                        return -5;//操作失败
                    }

                    strSql = " select CompanyID,ID,BusinessType,MasterID,ConsultantType,ConsultantID,CreatorID,CreateTime,UpdaterID,UpdateTime,RecordType from [TBL_BUSINESS_CONSULTANT]  WHERE MasterID =@MasterID AND BusinessType = 1 AND ConsultantType = 1";
                    BusinessConsultant_Model mBc = db.SetCommand(strSql, db.Parameter("@MasterID", model.OrderID, DbType.Int32)).ExecuteObject<BusinessConsultant_Model>();

                    if (mBc == null)
                    {
                        strSql = @" INSERT INTO [TBL_BUSINESS_CONSULTANT]
                                       (CompanyID,BusinessType,MasterID,ConsultantType,ConsultantID,CreatorID ,CreateTime,UpdaterID,UpdateTime ,RecordType)
                                        VALUES
                                       (@CompanyID,@BusinessType,@MasterID,@ConsultantType,@ConsultantID,@CreatorID,@CreateTime,@UpdaterID,@UpdateTime,@RecordType) ";

                        row = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@BusinessType", 1, DbType.Int32)
                            , db.Parameter("@MasterID", model.OrderID, DbType.Int32)
                            , db.Parameter("@ConsultantType", 1, DbType.Int32)
                            , db.Parameter("@ConsultantID", model.ResponsiblePersonID, DbType.Int32)
                            , db.Parameter("@CreatorID", model.UpdaterID, DbType.Int32)
                            , db.Parameter("@CreateTime", model.UpdateTime, DbType.DateTime2)
                            , db.Parameter("@RecordType", 1, DbType.Int32)).ExecuteNonQuery();

                        if (row != 1)
                        {
                            db.RollbackTransaction();
                            message = "操作失败";
                            return -5;//操作失败
                        }
                    }
                    else
                    {
                        if (mBc.ConsultantID != model.ResponsiblePersonID)
                        {

                            strSql = " DELETE [TBL_BUSINESS_CONSULTANT]  WHERE MasterID =@MasterID AND BusinessType = 1 AND ConsultantType = 1 ";

                            row = db.SetCommand(strSql, db.Parameter("@MasterID", model.OrderID, DbType.Int32)).ExecuteNonQuery();
                            if (row != 1)
                            {
                                db.RollbackTransaction();
                                message = "操作失败";
                                return -5;//操作失败
                            }

                            strSql = @" INSERT INTO [TBL_BUSINESS_CONSULTANT]
                                       (CompanyID,BusinessType,MasterID,ConsultantType,ConsultantID,CreatorID ,CreateTime,UpdaterID,UpdateTime ,RecordType)
                                        VALUES
                                       (@CompanyID,@BusinessType,@MasterID,@ConsultantType,@ConsultantID,@CreatorID,@CreateTime,@UpdaterID,@UpdateTime,@RecordType) ";

                            row = db.SetCommand(strSql, db.Parameter("@CompanyID", mBc.CompanyID, DbType.Int32)
                                , db.Parameter("@BusinessType", 1, DbType.Int32)
                                , db.Parameter("@MasterID", mBc.MasterID, DbType.Int32)
                                , db.Parameter("@ConsultantType", 1, DbType.Int32)
                                , db.Parameter("@ConsultantID", model.ResponsiblePersonID, DbType.Int32)
                                , db.Parameter("@CreatorID", mBc.CreatorID, DbType.Int32)
                                , db.Parameter("@CreateTime", mBc.CreateTime, DbType.DateTime2)
                                , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                                , db.Parameter("@RecordType", 1, DbType.Int32)).ExecuteNonQuery();

                            if (row != 1)
                            {
                                db.RollbackTransaction();
                                message = "操作失败";
                                return -5;//操作失败
                            }
                        }
                    }




                    if (dt.Rows[0]["ProductType"].ToString() == "0")
                    {
                        strSql = @"INSERT INTO dbo.HST_ORDER_SERVICE SELECT * FROM dbo.tbl_ORDER_SERVICE WHERE OrderID=@OrderID";
                        row = db.SetCommand(strSql, db.Parameter("@OrderID", model.OrderID, DbType.Int32)).ExecuteNonQuery();

                        if (row != 1)
                        {
                            db.RollbackTransaction();
                            message = "操作失败";
                            return -6;
                        }

                        strSql = @"UPDATE dbo.TBL_ORDER_SERVICE SET 
                                --ResponsiblePersonID=@ResponsiblePersonID,
                                UpdaterID=@UpdaterID,UpdateTime=@UpdateTime,Status=@Status WHERE OrderID=@OrderID";
                        row = db.SetCommand(strSql
                        , db.Parameter("@OrderID", model.OrderID, DbType.Int32)
                        , db.Parameter("@Status", model.Status, DbType.Int32)
                            // , db.Parameter("@ResponsiblePersonID", model.ResponsiblePersonID, DbType.Int32)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                        ).ExecuteNonQuery();
                        if (row != 1)
                        {
                            db.RollbackTransaction();
                            message = "操作失败";
                            return -7;//操作失败
                        }
                    }
                    else
                    {
                        strSql = @"INSERT INTO dbo.HST_ORDER_COMMODITY SELECT * FROM dbo.TBL_ORDER_COMMODITY WHERE OrderID=@OrderID";
                        row = db.SetCommand(strSql, db.Parameter("@OrderID", model.OrderID, DbType.Int32)).ExecuteNonQuery();

                        if (row != 1)
                        {
                            db.RollbackTransaction();
                            message = "操作失败";
                            return -8;
                        }

                        strSql = @"UPDATE dbo.TBL_ORDER_COMMODITY SET 
                            --ResponsiblePersonID=@ResponsiblePersonID,
                                UpdaterID=@UpdaterID,UpdateTime=@UpdateTime,Status=@Status WHERE OrderID=@OrderID";
                        row = db.SetCommand(strSql
                        , db.Parameter("@OrderID", model.OrderID, DbType.Int32)
                        , db.Parameter("@Status", model.Status, DbType.Int32)
                            // , db.Parameter("@ResponsiblePersonID", model.ResponsiblePersonID, DbType.Int32)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                        ).ExecuteNonQuery();
                        if (row != 1)
                        {
                            db.RollbackTransaction();
                            message = "操作失败";
                            return -9;//操作失败
                        }
                    }

                    db.CommitTransaction();
                    return 1;

                }

            }

        }

        public ObjectResult<bool> cancelOrder(int OrderID, int UpdaterID, int CompanyID, int BranchID)
        {
            ObjectResult<bool> result = new ObjectResult<bool>();
            result.Code = "0";
            result.Data = false;
            result.Message = "操作失败！";

            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                try
                {
                    string BranchWhere = string.Empty;
                    if (BranchID > 0)
                    {
                        BranchWhere = " AND T1.BranchID=@BranchID";
                    }

                    int row = 0;

                    #region 获取订单ProductType和PaymentStatus
                    string strSql = @"SELECT  T1.ProductType, T1.PaymentStatus, T1.CompanyID, T1.BranchID, T1.CustomerID, T1.TotalSalePrice,CASE T1.ProductType when 0 then T3.ServiceID else T2.CommodityID end  ProductID,T1.Quantity FROM dbo.[ORDER] T1 WITH(ROWLOCK) LEFT JOIN [TBL_ORDER_COMMODITY] T2 ON T1.ID = T2.OrderID
                                    LEFT JOIN [TBL_ORDER_SERVICE] T3 ON T1.ID= T3.OrderID
                                      WHERE T1.CompanyID=@CompanyID AND T1.ID =@OrderID AND T1.RecordType=1" + BranchWhere;

                    CancelOrderForWeb_Model model = db.SetCommand(strSql, db.Parameter("@OrderID", OrderID, DbType.Int32)
                        , db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                        , db.Parameter("@BranchID", BranchID, DbType.Int32)).ExecuteObject<CancelOrderForWeb_Model>();
                    #endregion

                    if (model == null)
                    {
                        result.Message = "订单错误";
                        return result;
                    }

                    #region 对已支付的订单处理
                    if (model.PaymentStatus > 1 && model.PaymentStatus != 5)
                    {
                        result.Message = "请先取消支付";
                        return result;

                    }
                    #endregion

                    #region 修改主订单
                    string strSqlinsertHis = @"insert into HISTORY_ORDER select * from [ORDER] where ID = @ID ";
                    row = db.SetCommand(strSqlinsertHis, db.Parameter("@ID", OrderID, DbType.Int32)).ExecuteNonQuery();

                    if (row != 1)
                    {
                        db.RollbackTransaction();
                        result.Message = "修改失败";
                        return result;
                    }

                    strSql = @"UPDATE dbo.[ORDER] SET  Status = 3
                                     ,UpdaterID =@UpdaterID
                                     ,UpdateTime =@UpdateTime 
                                     ,RecordType=2
                                     WHERE ID =@OrderID  and RecordType != 2";
                    row = db.SetCommand(strSql, db.Parameter("@UpdaterID", UpdaterID, DbType.Int32)
                       , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime)
                       , db.Parameter("@OrderID", OrderID, DbType.Int32)).ExecuteNonQuery();

                    if (row != 1)
                    {
                        db.RollbackTransaction();
                        result.Message = "修改失败";
                        return result;
                    }

                    #endregion

                    #region 服务单对服务操作
                    if (model.ProductType == 0)
                    {
                        strSql = @"INSERT INTO dbo.HST_ORDER_SERVICE SELECT * FROM dbo.tbl_ORDER_SERVICE WHERE OrderID=@OrderID";
                        row = db.SetCommand(strSql, db.Parameter("@OrderID", OrderID, DbType.Int32)).ExecuteNonQuery();

                        if (row != 1)
                        {
                            db.RollbackTransaction();
                            result.Message = "修改失败";
                            return result;
                        }

                        strSql = @"UPDATE dbo.TBL_ORDER_SERVICE SET UpdaterID=@UpdaterID,UpdateTime=@UpdateTime,Status=3 WHERE OrderID=@OrderID";
                        row = db.SetCommand(strSql
                        , db.Parameter("@OrderID", OrderID, DbType.Int32)
                        , db.Parameter("@UpdaterID", UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                        ).ExecuteNonQuery();
                        if (row != 1)
                        {
                            db.RollbackTransaction();
                            result.Message = "修改失败";
                            return result;
                        }
                    }
                    #endregion

                    #region 商品单对商品库存操作
                    if (model.ProductType == 1)
                    {
                        strSql = @"INSERT INTO dbo.HST_ORDER_COMMODITY SELECT * FROM dbo.TBL_ORDER_COMMODITY WHERE OrderID=@OrderID";
                        row = db.SetCommand(strSql, db.Parameter("@OrderID", OrderID, DbType.Int32)).ExecuteNonQuery();

                        if (row != 1)
                        {
                            db.RollbackTransaction();
                            result.Message = "修改失败";
                            return result;
                        }

                        strSql = @"UPDATE dbo.TBL_ORDER_COMMODITY SET UpdaterID=@UpdaterID,UpdateTime=@UpdateTime,Status=3 WHERE OrderID=@OrderID";
                        row = db.SetCommand(strSql
                        , db.Parameter("@OrderID", OrderID, DbType.Int32)
                        , db.Parameter("@UpdaterID", UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                        ).ExecuteNonQuery();
                        if (row != 1)
                        {
                            db.RollbackTransaction();
                            result.Message = "修改失败";
                            return result;
                        }


                        #region 查询库存
                        string strSqlSelectProductID = " select CommodityID from TBL_ORDER_COMMODITY where OrderID = @OrderID AND CompanyID=@CompanyID ";
                        int productId = db.SetCommand(strSqlSelectProductID, db.Parameter("@OrderID", OrderID, DbType.Int32),
                                                                   db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();

                        string strSqlSelectQty = @" SELECT TOP 1 * FROM [TBL_PRODUCT_STOCK] WHERE ProductCode=(SELECT MAX(Code) FROM dbo.COMMODITY WHERE ID = @ProductID ) AND CompanyID=@CompanyID AND BranchID=@BranchID ORDER BY ID DESC ";
                        ProductStockOperation_Model stockModel = db.SetCommand(strSqlSelectQty,
                                                                   db.Parameter("@ProductID", productId, DbType.Int64),
                                                                   db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                                                   db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteObject<ProductStockOperation_Model>();
                        #endregion

                        if (stockModel == null)
                        {
                            db.RollbackTransaction();
                            result.Message = "修改失败";
                            return result;
                        }

                        // 不计库存 不操作库存表
                        if (stockModel.StockCalcType == 1 || stockModel.StockCalcType == 3)
                        {
                            #region 修改库存
                            string strSqlUpdateStock = @" UPDATE TBL_PRODUCT_STOCK SET ProductQty=ProductQty+@ProductQty,OperatorID=@OperatorID,OperateTime=@OperateTime WHERE ProductType=1 And ProductCode=(SELECT MAX(Code) FROM dbo.COMMODITY WHERE ID = @ProductID ) And CompanyID=@CompanyID And BranchID=@BranchID";
                            row = db.SetCommand(strSqlUpdateStock,
                                                db.Parameter("@ProductQty", model.Quantity, DbType.Int32),
                                                db.Parameter("@OperatorID", UpdaterID, DbType.Int32),
                                                db.Parameter("@OperateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2),
                                                db.Parameter("@ProductID", model.ProductID, DbType.Int64),
                                                db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                                db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                ).ExecuteNonQuery();
                            #endregion

                            if (row <= 0)
                            {
                                db.RollbackTransaction();
                                result.Message = "修改失败";
                                return result;
                            }

                            #region 批次表修改数量操作
                            string strSqlSelectStockBatch = @" SELECT * FROM [TBL_PRODUCT_STOCK_BATCH] WHERE ProductCode=(SELECT MAX(Code) FROM dbo.COMMODITY WHERE ID = @ProductID ) AND CompanyID=@CompanyID AND BranchID=@BranchID ORDER BY ID ";
                            List<Product_Stock_Batch_Model> stockBatchList = db.SetCommand(strSqlSelectStockBatch,
                            db.Parameter("@ProductID", model.ProductID, DbType.Int64),
                            db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                            db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteList<Product_Stock_Batch_Model>();
                            if (stockBatchList != null && stockBatchList.Count > 0)
                            {
                                string strSqlUpdateStockBatch = @" UPDATE TBL_PRODUCT_STOCK_BATCH SET Quantity=Quantity+@qtyForUpd WHERE ID = @ID ";
                                int updStockBatch = db.SetCommand(strSqlUpdateStockBatch,
                                db.Parameter("@qtyForUpd", model.Quantity, DbType.Int32),
                                db.Parameter("@ID", stockBatchList[0].ID, DbType.Int32)).ExecuteNonQuery();
                                if (updStockBatch <= 0)
                                {
                                    db.RollbackTransaction();
                                    result.Message = "修改失败";
                                    return result;
                                }
                            }
                            #endregion

                            #region 插入库存操作记录表
                            string strSqlInsertStockLog = @"INSERT INTO [TBL_PRODUCT_STOCK_OPERATELOG](CompanyID,BranchID,ProductType,ProductCode,OperateType,OperateQty,OperateSign,OrderID,ProductQty,OperatorID,OperateTime) 
                                                                            VALUES(@CompanyID,@BranchID,@ProductType,(SELECT MAX(Code) FROM dbo.COMMODITY WHERE ID = @ProductID ),@OperateType,@OperateQty,@OperateSign,@OrderID,@ProductQty,@OperatorID,@OperateTime)";
                            row = db.SetCommand(strSqlInsertStockLog,
                                                   db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                                   db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                                   db.Parameter("@ProductType", 1, DbType.Int32),
                                                   db.Parameter("@ProductID", model.ProductID, DbType.Int64),
                                                   db.Parameter("@OperateType", 5, DbType.Int32),//取消订单
                                                   db.Parameter("@OperateQty", model.Quantity, DbType.Int32),
                                                   db.Parameter("@OperateSign", "+", DbType.String),
                                                   db.Parameter("@OrderID", OrderID, DbType.Int32),
                                                   db.Parameter("@ProductQty", stockModel.ProductQty + model.Quantity, DbType.Int32),
                                                   db.Parameter("@OperatorID", UpdaterID, DbType.Int32),
                                                   db.Parameter("@OperateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)).ExecuteNonQuery();
                            #endregion

                            if (row <= 0)
                            {
                                db.RollbackTransaction();
                                result.Message = "修改失败";
                                return result;
                            }
                        }

                    }

                    #endregion

                    #region 还劵
                    string strSqlCheckBenefit = @" select BenefitID from TBL_CUSTOMER_BENEFIT where CompanyID =@CompanyID and BenefitStatus = 2 and UserID=@UserID and OrderID =@OrderID ";

                    string BenefitID = db.SetCommand(strSqlCheckBenefit
                         , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                         , db.Parameter("@OrderID", OrderID, DbType.Int32)
                         , db.Parameter("@UserID", model.CustomerID, DbType.Int32)).ExecuteScalar<string>();

                    if (!string.IsNullOrWhiteSpace(BenefitID))
                    {
                        string strSqlBenefit = " update TBL_CUSTOMER_BENEFIT set BenefitStatus = 1,OrderID = null,UseDate= null where BenefitID= @BenefitID and CompanyID =@CompanyID ";
                        row = db.SetCommand(strSqlBenefit
                         , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                         , db.Parameter("@BenefitID", BenefitID, DbType.String)).ExecuteNonQuery();

                        if (row < 1)
                        {
                            db.RollbackTransaction();
                            result.Message = "修改失败";
                            return result;
                        }

                    }


                    #endregion


                    db.CommitTransaction();
                    result.Code = "1";
                    result.Data = true;
                    result.Message = "操作成功！";
                    return result;
                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }

        public TreatmentDetailForWeb_Model getTreatmentDetailForWeb(int TreatmentID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  
                                          T6.CompanyID, 
                                          T6.BranchID,
                                          T3.ServiceName ,
                                          T4.SubServiceName ServiceDetail ,
                                          T5.Name ExecutorName,
                                          T1.ScheduleTime ,
                                          T2.IsDesignated ,
                                          T1.Status
                                  FROM    dbo.SCHEDULE T1
                                          INNER JOIN dbo.TREATMENT T2 ON T1.ID = T2.ScheduleID
                                          INNER JOIN dbo.SERVICE T3 ON T1.ServiceID = T3.ID
                                          LEFT JOIN dbo.TBL_SUBSERVICE T4 ON T1.SubServiceID = T4.SubServiceCode
                                          LEFT JOIN dbo.ACCOUNT T5 ON T2.ExecutorID = t5.UserID
                                          lEFT JOIN dbo.[ORDER] T6 ON T6.ID = T1.OrderID 
                                  WHERE   T2.ID = @TreatmentID";

                TreatmentDetailForWeb_Model model = db.SetCommand(strSql, db.Parameter("@TreatmentID", TreatmentID, DbType.Int32)).ExecuteObject<TreatmentDetailForWeb_Model>();

                return model;

            }
        }

        public bool cancelCompletedSchedule(int TreatmentID, int UpdaterID)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();
                    string strSql = @" UPDATE dbo.SCHEDULE 
                                    SET Status = 0, UpdaterID=@UpdaterID, UpdateTime=@UpdateTime
                                    FROM dbo.TREATMENT T2
                                    INNER JOIN dbo.SCHEDULE T3 
                                    ON T3.ID = T2.ScheduleID 
                                    WHERE T2.ID = @TreatmentID ";

                    int rows = db.SetCommand(strSql, db.Parameter("@TreatmentID", TreatmentID, DbType.Int32)
                                                   , db.Parameter("@UpdaterID", UpdaterID, DbType.Int32)
                                                   , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime)).ExecuteNonQuery();

                    if (rows != 1)
                    {
                        return false;
                    }

                    strSql = @"SELECT  T1.status
                           FROM    [order] T1
                                   INNER JOIN schedule T2 ON t1.ID = t2.orderid
                                   INNER JOIN treatment T3 ON t3.scheduleID = t2.id
                           WHERE   t3.ID = @TreatmentID ";

                    int status = db.SetCommand(strSql, db.Parameter("@TreatmentID", TreatmentID, DbType.Int32)).ExecuteScalar<int>();

                    if (status != 1 && status != 3)
                    {
                        db.CommitTransaction();
                        return true;
                    }
                    else
                    {
                        strSql = @"
                                UPDATE  [ORDER]
                                SET     STATUS = 0
                                FROM    [order] t1
                                        INNER JOIN schedule T2 ON t1.id = t2.orderid
                                        INNER JOIN Treatment T3 ON t2.ID = t3.scheduleID
                                WHERE   t3.ID = @TreatmentID ";

                        rows = db.SetCommand(strSql, db.Parameter("@TreatmentID", TreatmentID, DbType.Int32)).ExecuteNonQuery();
                        if (rows != 1)
                        {
                            db.RollbackTransaction();
                            return false;
                        }
                        db.CommitTransaction();
                        return true;
                    }
                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }

        }

        //        public List<CourseList> getCourseListForWeb(int OrderID)
        //        {
        //            using (DbManager db = new DbManager())
        //            {
        //                string strSql = @"SELECT T1.ID CourseID,T4.ServiceName ServiceName FROM dbo.COURSE T1 
        //                Inner Join dbo.[ORDER] T2 ON T1.OrderID = T2.ID 
        //                INNER JOIN dbo.SERVICE T4 ON T2.ProductID = T4.ID 
        //                WHERE T1.OrderID = @OrderID AND T1.Available = 1 ";

        //                List<CourseList> list = db.SetCommand(strSql, db.Parameter("@OrderID", OrderID, DbType.Int32)).ExecuteList<CourseList>();
        //                if (list != null && list.Count > 0)
        //                {
        //                    strSql = @"SELECT 
        //                                            T4.ServiceName ,
        //                                            T5.SubServiceName ServiceDetail,
        //                                            T6.Name ExecutorName,
        //                                            T1.ScheduleTime ,
        //                                            T2.IsDesignated ,
        //                                            T1.Status
        //                                  FROM dbo.SCHEDULE T1
        //                                  INNER JOIN dbo.TREATMENT T2 ON T1.ID = T2.ScheduleID
        //                                  INNER JOIN dbo.COURSE T3 ON T2.CourseID = T3.ID
        //                                  INNER JOIN dbo.SERVICE T4 ON T1.ServiceID = T4.ID
        //                                  LEFT JOIN dbo.TBL_SUBSERVICE T5 ON T1.SubServiceID = T5.SubServiceCode
        //                                  LEFT JOIN dbo.ACCOUNT T6 ON T2.ExecutorID = t6.UserID
        //                                  WHERE T3.ID =@CourseID";

        //                    for (int i = 0; i < list.Count; i++)
        //                    {
        //                        list[i].treatmentList = db.SetCommand(strSql, db.Parameter("@CourseID", list[i].CourseID, DbType.Int32)).ExecuteList<TreatmentDetailForWeb_Model>();
        //                    }
        //                }
        //                return list;

        //            }

        //        }

        public List<Payment_ForOrder> GetPaymentListByOrderID(int OrderID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT b.ID,b.PaymentTime,SUBSTRING(CONVERT(varchar(6) ,b.PaymentTime ,12),3,4) + right('000000'+ cast(b.ID AS VARCHAR(10)),6) + CONVERT(varchar(2) ,b.PaymentTime ,12) AS PaymentCode FROM dbo.TBL_ORDERPAYMENT_RELATIONSHIP a
                                 INNER JOIN dbo.PAYMENT b ON a.PaymentID=b.ID AND b.Type = 1 and b.Status = 2
                                WHERE a.OrderID=@OrderID";
                return db.SetCommand(strSql, db.Parameter("@OrderID", OrderID, DbType.Int32)).ExecuteList<Payment_ForOrder>();
            }
        }


        public GetGroupInfoForWeb_Model GetGroupInfoForWeb(long groupNO, int CompanyID, int branchID)
        {
            GetGroupInfoForWeb_Model model = new GetGroupInfoForWeb_Model();
            using (DbManager db = new DbManager())
            {


                string strSql = @"select  T1.OrderID,T1.ServicePIC AS ServicePicID,  T1.GroupNo,T2.ServiceName,T3.Name AS ServicePicName,T1.TGStatus AS Status,T1.TGStartTime AS StartTime,T1.TGEndTime AS EndTime
                                from [TBL_TREATGROUP] T1 
								inner join [TBL_ORDER_SERVICE] T4 ON T1.OrderID = T4.OrderID 
                                LEFT JOIN [SERVICE] T2 
                                ON T4.ServiceID = T2.ID 
                                LEFT JOIN [ACCOUNT] T3 
                                ON T1.ServicePIC = T3.UserID 
                                WHERE (T1.TGStatus = 2 OR T1.TGStatus = 5) AND T1.GroupNo = @GroupNo and T1.CompanyID=@CompanyID ";

                if (branchID > 0)
                {
                    strSql += " and T1.BranchID= " + branchID;
                }



                model = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@groupNO", groupNO, DbType.Int64)).ExecuteObject<GetGroupInfoForWeb_Model>();

                if (model != null)
                {
                    model.TreatmentList = new List<TreatmentForWeb>();
                    string strSqlTreatment = @" select T1.ID TreatmentID, T2.SubServiceName,T1.ExecutorID,T3.Name ExecutorName,T1.StartTime,T1.FinishTime EndTime,T1.Status from [TREATMENT] T1 
                                            LEFT JOIN [TBL_SUBSERVICE] T2 
                                            ON T1.SubServiceID = T2.ID 
                                            LEFT JOIN [ACCOUNT] T3 
                                            ON T1.ExecutorID = T3.UserID
                                            WHERE T1.GroupNo=@GroupNo AND T1.CompanyID=@CompanyID ";
                    model.TreatmentList = db.SetCommand(strSqlTreatment, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                        , db.Parameter("@groupNO", groupNO, DbType.Int64)).ExecuteList<TreatmentForWeb>();
                }
                return model;

            }
        }



        public GetCommodityDelivery_Model GetCommodityDeliveryInfoForWeb(long DeliveryID, int CompanyID, int BranchID)
        {
            GetCommodityDelivery_Model model = new GetCommodityDelivery_Model();
            using (DbManager db = new DbManager())
            {


                string strSql = @"select T1.ID as DeliveryID, T1.OrderID,T2.CommodityName,T1.ServicePIC,T1.Status,T1.CDStartTime,T1.CDEndTime from [TBL_COMMODITY_DELIVERY] T1 
                                    LEFT JOIN [COMMODITY] T2 ON T1.CommodityID = T2.ID 
                                    WHERE T1.CompanyID=@CompanyID AND T1.ID =@DeliveryID and T1.Status <> 3 ";

                if (BranchID > 0)
                {
                    strSql += " AND T1.BranchID =" + BranchID.ToString();
                }



                model = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@DeliveryID", DeliveryID, DbType.Int64)).ExecuteObject<GetCommodityDelivery_Model>();


                return model;

            }
        }

        public int EditDelivery(CommodityDeliveryOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();
                    string strSqlCheck = @" SELECT T1.OrderID FROM [TBL_COMMODITY_DELIVERY] T1 INNER JOIN [ORDER] T2 ON T1.OrderID = T2.ID  WHERE T1.CompanyID=@CompanyID and T1.ID=@DeliveryID AND  DATEDIFF(ss,T2.OrderTime,@CDStartTime) >= 0  ";
                    int orderID = db.SetCommand(strSqlCheck
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@DeliveryID", model.DeliveryID, DbType.Int64)
                        , db.Parameter("@CDStartTime", model.CDStartTime, DbType.DateTime2)).ExecuteScalar<int>();
                    if (orderID == 0)
                    {
                        return -1;
                    }

                    string strSqlHistory = " INSERT INTO HST_COMMODITY_DELIVERY SELECT * FROM TBL_COMMODITY_DELIVERY WHERE CompanyID=@CompanyID and ID=@DeliveryID ";
                    int rows = db.SetCommand(strSqlHistory
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@DeliveryID", model.DeliveryID, DbType.Int64)).ExecuteNonQuery();
                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    string strSqlUpdate = @" update TBL_COMMODITY_DELIVERY 
                                            set ServicePIC = @ServicePIC,
                                            CDStartTime =@CDStartTime,
                                            CDEndTime=@CDEndTime,
                                            UpdaterID=@UpdaterID,
                                            UpdateTime=@UpdateTime
                                            where ID=@DeliveryID AND CompanyID= @CompanyID ";
                    rows = db.SetCommand(strSqlUpdate
                        , db.Parameter("@ServicePIC", model.ServicePIC, DbType.Int32)
                        , db.Parameter("@CDStartTime", model.CDStartTime, DbType.DateTime2)
                        , db.Parameter("@CDEndTime", model.CDEndTime == null ? (object)DBNull.Value : model.CDEndTime, DbType.DateTime2)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@DeliveryID", model.DeliveryID, DbType.Int64)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    db.CommitTransaction();
                    return 1;

                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }


        public int CancelDelivey(CommodityDeliveryOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();
                    string strSqlCheck = @" SELECT T1.OrderID FROM [TBL_COMMODITY_DELIVERY] T1  WHERE T1.CompanyID=@CompanyID and T1.ID=@DeliveryID AND T1.Status <> 3 ";
                    int orderID = db.SetCommand(strSqlCheck
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@DeliveryID", model.DeliveryID, DbType.Int64)).ExecuteScalar<int>();
                    if (orderID == 0)
                    {
                        return -1;
                    }

                    string strQuantity = "  SELECT T1.Quantity FROM [TBL_COMMODITY_DELIVERY] T1  WHERE T1.CompanyID=@CompanyID and T1.ID=@DeliveryID AND T1.Status <> 3 and T1.Status <> 1 ";

                    int Quantity = db.SetCommand(strQuantity
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@DeliveryID", model.DeliveryID, DbType.Int64)).ExecuteScalar<int>();

                    string strSqlHistory = " INSERT INTO HST_COMMODITY_DELIVERY SELECT * FROM TBL_COMMODITY_DELIVERY WHERE CompanyID=@CompanyID and ID=@DeliveryID ";
                    int rows = db.SetCommand(strSqlHistory
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@DeliveryID", model.DeliveryID, DbType.Int64)).ExecuteNonQuery();
                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    string strSqlUpdate = @" update TBL_COMMODITY_DELIVERY 
                                            set Status = @Status,
                                            UpdaterID=@UpdaterID,
                                            UpdateTime=@UpdateTime
                                            where ID=@DeliveryID AND CompanyID= @CompanyID AND Status <> 3";
                    rows = db.SetCommand(strSqlUpdate
                        , db.Parameter("@Status", 3, DbType.Int32)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@DeliveryID", model.DeliveryID, DbType.Int64)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    string strSqlgetStatus = " SELECT Status FROM [ORDER] WHERE CompanyID= @CompanyID AND ID =@ID ";
                    int status = db.SetCommand(strSqlgetStatus, db.Parameter("@ID", orderID, DbType.Int32), db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();

                    if (status == 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    else if (status == 2 || status == 5)
                    {
                        status = 1;
                    }


                    string strSqlUpdateCommodity = @" update TBL_ORDER_COMMODITY set Status =@Status,
                                                    DeliveredAmount=DeliveredAmount-@Quantity,
                                                    UpdaterID=@UpdaterID,
                                                    UpdateTime=@UpdateTime 
                                                    where OrderID=@OrderID ";
                    rows = db.SetCommand(strSqlUpdateCommodity
                        , db.Parameter("@Status", status, DbType.Int32)
                        , db.Parameter("@Quantity", Quantity, DbType.Int32)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                        , db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    string strSqlUpdateOrder = @"UPDATE  [ORDER] SET Status =@Status,
                                                UpdaterID=@UpdaterID,
                                                UpdateTime=@UpdateTime 
                                                WHERE ID = @OrderID";
                    rows = db.SetCommand(strSqlUpdateOrder
                        , db.Parameter("@Status", status, DbType.Int32)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                        , db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    db.CommitTransaction();
                    return 1;

                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }

        public int CancelTGForWeb(EditTGForWebOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();
                    string strSqlCheck = @" SELECT T1.OrderID,T2.TGFinishedCount,T2.Status FROM [TBL_TREATGROUP] T1 INNER JOIN [TBL_ORDER_SERVICE] T2 ON T1.OrderID = T2.OrderID  WHERE T1.CompanyID=@CompanyID and T1.GroupNo=@GroupNo AND (T1.TGStatus = 2  or T1.TGStatus = 5 )";

                    DataTable dt = db.SetCommand(strSqlCheck
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)).ExecuteDataTable();

                    if (dt == null || dt.Rows.Count != 1)
                    {
                        return -1;
                    }
                    int orderID = StringUtils.GetDbInt(dt.Rows[0]["OrderID"]);
                    int TGFinishedCount = StringUtils.GetDbInt(dt.Rows[0]["TGFinishedCount"]);
                    int status = StringUtils.GetDbInt(dt.Rows[0]["Status"]);

                    if (orderID == 0 || TGFinishedCount == 0)
                    {
                        return -1;
                    }

                    string strSqlHistory = " INSERT INTO HST_TREATGROUP SELECT * FROM TBL_TREATGROUP WHERE CompanyID=@CompanyID and GroupNo=@GroupNo ";
                    int rows = db.SetCommand(strSqlHistory
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)).ExecuteNonQuery();
                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    string strSqlUpdate = @" update TBL_TREATGROUP 
                                            set TGStatus = @TGStatus,
                                            UpdaterID=@UpdaterID,
                                            UpdateTime=@UpdateTime
                                            where GroupNo=@GroupNo  AND CompanyID= @CompanyID AND (TGStatus = 2  or TGStatus = 5 )";
                    rows = db.SetCommand(strSqlUpdate
                        , db.Parameter("@TGStatus", 3, DbType.Int32)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    if (model.TreatmentList != null && model.TreatmentList.Count > 0)
                    {
                        string strSqlTreatHistory = @" INSERT INTO HISTORY_TREATMENT SELECT * FROM TREATMENT WHERE ID =@TreatmentID and CompanyID=@CompanyID and GroupNo =@GroupNo ";

                        string strSqlTreatUpdate = @" update TREATMENT set 
                                                    Status =@Status,
                                                    UpdaterID=@UpdaterID,
                                                    UpdateTime=UpdateTime
                                                    WHERE ID =@TreatmentID and CompanyID=@CompanyID and GroupNo =@GroupNo ";

                        foreach (TreatmentForWeb item in model.TreatmentList)
                        {
                            rows = db.SetCommand(strSqlTreatHistory
                                         , db.Parameter("@TreatmentID", item.TreatmentID, DbType.Int32)
                                         , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                         , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            rows = db.SetCommand(strSqlTreatUpdate
                                         , db.Parameter("@Status", 3, DbType.Int32)
                                         , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                         , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                                         , db.Parameter("@TreatmentID", item.TreatmentID, DbType.Int32)
                                         , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                         , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            string strDelCommissionSql = @"UPDATE  TBL_PROFIT_COMMISSION_DETAIL
                                                            SET     RecordType = @RecordType
                                                                   ,UpdaterID = @UpdaterID
                                                                   ,UpdateTime = @UpdateTime
                                                            WHERE   CompanyID = @CompanyID
                                                                    AND SourceID = @SourceID
                                                                    AND SourceType = 2";

                            rows = db.SetCommand(strDelCommissionSql
                                        , db.Parameter("@RecordType", 2, DbType.Int32)
                                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                        , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                                        , db.Parameter("@SourceID", item.TreatmentID, DbType.Int32)
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                        }


                        int newStatus = 1;
                        if (status == 2 || status == 5)
                        {
                            newStatus = 1;
                        }
                        else
                        {
                            newStatus = status;
                        }


                        string strSqlUpdateOrderService = @" update [TBL_ORDER_SERVICE] 
                                            set Status = @Status,
                                            TGFinishedCount = TGFinishedCount -1 ,
                                            UpdaterID=@UpdaterID,
                                            UpdateTime=@UpdateTime
                                            where OrderID=@OrderID  AND CompanyID= @CompanyID";
                        rows = db.SetCommand(strSqlUpdateOrderService
                            , db.Parameter("@Status", newStatus, DbType.Int32)
                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                            , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteNonQuery();

                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        string strSqlUpdateOrder = @" update [ORDER] 
                                            set Status = @Status,
                                            UpdaterID=@UpdaterID,
                                            UpdateTime=@UpdateTime
                                            where ID=@OrderID  AND CompanyID= @CompanyID";
                        rows = db.SetCommand(strSqlUpdateOrder
                            , db.Parameter("@Status", newStatus, DbType.Int32)
                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                            , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteNonQuery();

                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }


                    }

                    db.CommitTransaction();
                    return 1;

                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }

        public int EditTGForWeb(EditTGForWebOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();
                    string strSqlCheck = @" SELECT T1.OrderID,T2.TGExecutingCount,T2.TGFinishedCount,T1.TGStatus FROM [TBL_TREATGROUP] T1 INNER JOIN [TBL_ORDER_SERVICE] T2 ON T1.OrderID = T2.OrderID INNER JOIN [ORDER] T3 ON T2.OrderID = T3.ID and T3.RecordType = 1  WHERE T1.CompanyID=@CompanyID and T1.GroupNo=@GroupNo AND  DATEDIFF(ss,T3.OrderTime,@StartTime) >= 0 ";

                    DataTable dt = db.SetCommand(strSqlCheck
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)
                        , db.Parameter("@StartTime", model.StartTime, DbType.DateTime)).ExecuteDataTable();

                    if (dt == null || dt.Rows.Count != 1)
                    {
                        return -1;
                    }
                    int orderID = StringUtils.GetDbInt(dt.Rows[0]["OrderID"]);
                    int TGFinishedCount = StringUtils.GetDbInt(dt.Rows[0]["TGFinishedCount"]);
                    int TGStatus = StringUtils.GetDbInt(dt.Rows[0]["TGStatus"]);
                    int TGExecutingCount = StringUtils.GetDbInt(dt.Rows[0]["TGExecutingCount"]);

                    if (orderID == 0 || TGFinishedCount == 0)
                    {
                        return -1;
                    }

                    string strSqlHistory = " INSERT INTO HST_TREATGROUP SELECT * FROM TBL_TREATGROUP WHERE CompanyID=@CompanyID and GroupNo=@GroupNo ";
                    int rows = db.SetCommand(strSqlHistory
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)).ExecuteNonQuery();
                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    string strSqlUpdate = @" update TBL_TREATGROUP 
                                            set TGStatus = @TGStatus,
                                            ServicePIC = @ServicePIC,
											TGStartTime=@StartTime,
											TGEndTime=@EndTime,
                                            UpdaterID=@UpdaterID,
                                            UpdateTime=@UpdateTime
                                            where GroupNo=@GroupNo  AND CompanyID= @CompanyID ";
                    rows = db.SetCommand(strSqlUpdate
                        , db.Parameter("@TGStatus", model.Status, DbType.Int32)
                        , db.Parameter("@ServicePIC", model.ServicePicID, DbType.Int32)
                        , db.Parameter("@StartTime", model.StartTime, DbType.DateTime2)
                        , db.Parameter("@EndTime", model.EndTime == null ? (object)DBNull.Value : model.EndTime, DbType.DateTime2)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }


                    if (model.Status != TGStatus)
                    {
                        string strSqlUpdateOrderService = @" update [TBL_ORDER_SERVICE] 
                                            set Status = @Status,
                                            TGExecutingCount = @TGExecutingCount ,
                                            TGFinishedCount = @TGFinishedCount ,
                                            UpdaterID=@UpdaterID,
                                            UpdateTime=@UpdateTime
                                            where OrderID=@OrderID  AND CompanyID= @CompanyID ";
                        rows = db.SetCommand(strSqlUpdateOrderService
                            , db.Parameter("@Status", 1, DbType.Int32)
                            , db.Parameter("@TGExecutingCount", TGExecutingCount + 1, DbType.Int32)
                            , db.Parameter("@TGFinishedCount", TGFinishedCount - 1, DbType.Int32)
                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                            , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteNonQuery();

                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        string strSqlUpdateOrder = @" update [ORDER] 
                                            set Status = @Status,
                                            UpdaterID=@UpdaterID,
                                            UpdateTime=@UpdateTime
                                            where ID=@OrderID  AND CompanyID= @CompanyID ";
                        rows = db.SetCommand(strSqlUpdateOrder
                            , db.Parameter("@Status", 1, DbType.Int32)
                            , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                            , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@OrderID", orderID, DbType.Int32)).ExecuteNonQuery();

                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                    }

                    if (model.TreatmentList != null && model.TreatmentList.Count > 0)
                    {
                        string strSqlTreatHistory = @" INSERT INTO HISTORY_TREATMENT SELECT * FROM TREATMENT WHERE ID =@TreatmentID and CompanyID=@CompanyID and GroupNo =@GroupNo ";

                        string strSqlTreatUpdate = @" update TREATMENT set 
                                                    Status =@Status,
                                                    ExecutorID =@ExecutorID,
													StartTime=@StartTime,
													FinishTime=@EndTime,
                                                    UpdaterID=@UpdaterID,
                                                    UpdateTime=UpdateTime
                                                    WHERE ID =@TreatmentID and CompanyID=@CompanyID and GroupNo =@GroupNo ";

                        foreach (TreatmentForWeb item in model.TreatmentList)
                        {
                            rows = db.SetCommand(strSqlTreatHistory
                                         , db.Parameter("@TreatmentID", item.TreatmentID, DbType.Int32)
                                         , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                         , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            rows = db.SetCommand(strSqlTreatUpdate
                                         , db.Parameter("@Status", item.Status, DbType.Int32)
                                         , db.Parameter("@ExecutorID", item.ExecutorID, DbType.Int32)
                                         , db.Parameter("@StartTime", item.StartTime, DbType.DateTime2)
                                         , db.Parameter("@EndTime", item.EndTime, DbType.DateTime2)
                                         , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                         , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                                         , db.Parameter("@TreatmentID", item.TreatmentID, DbType.Int32)
                                         , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                         , db.Parameter("@GroupNo", model.GroupNo, DbType.Int64)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }


                            if (item.Status == 1)
                            {
                                string strSqlCheck2 = @" select Count(*) from TBL_PROFIT_COMMISSION_DETAIL  WHERE   CompanyID = @CompanyID
                                                                        AND SourceID = @SourceID
                                                                        AND SourceType = @SourceType ";
                                int checkRows = db.SetCommand(strSqlCheck2
                                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                        , db.Parameter("@SourceID", item.TreatmentID, DbType.Int32)
                                                        , db.Parameter("@SourceType", 2, DbType.Int32)).ExecuteScalar<int>();
                                if (checkRows > 0)
                                {
                                    string updateTreatmentRecord = @" UPDATE  TBL_PROFIT_COMMISSION_DETAIL
                                                                SET     RecordType = 2
                                                                       ,UpdaterID = @UpdaterID
                                                                       ,UpdateTime = @UpdateTime
                                                                WHERE   SourceID = @SourceID
                                                                        AND SourceType = 2 ";
                                    rows = db.SetCommand(updateTreatmentRecord
                                                 , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                                 , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                                                 , db.Parameter("@SourceID", item.TreatmentID, DbType.Int32)).ExecuteNonQuery();

                                    if (rows == 0)
                                    {
                                        db.RollbackTransaction();
                                        return 0;
                                    } 
                                }
                            }
                        }
                    }

                    db.CommitTransaction();
                    return 1;

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
