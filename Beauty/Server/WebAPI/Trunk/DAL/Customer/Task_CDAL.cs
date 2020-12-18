using BLToolkit.Data;
using HS.Framework.Common;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL.Customer
{
    public class Task_CDAL
    {
        #region 构造类实例
        public static Task_CDAL Instance
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
            internal static readonly Task_CDAL instance = new Task_CDAL();
        }
        #endregion

        public List<GetTaskList_Model> GetScheduleList(GetTaskListOperation_Model operationModel, out int recordCount)
        {
            recordCount = 0;
            if (operationModel != null)
            {
                using (DbManager db = new DbManager())
                {
                    List<GetTaskList_Model> list = new List<GetTaskList_Model>();

                    string fileds = @" ROW_NUMBER() OVER ( ORDER BY T1.TaskScdlStartTime) AS rowNum ,
                                                  T1.TaskScdlStartTime ,T3.Name AS CustomerName ,T4.UserID AS ResponsiblePersonID ,T4.Name AS ResponsiblePersonName ,T5.Phone AS BranchPhone ,T5.BranchName,T1.TaskStatus ,T1.TaskName ,T1.ID AS TaskID ,T1.TaskType ,
                                                  CASE WHEN CHARINDEX('|15|', T6.Jurisdictions) > 0 THEN 1 ELSE 0 END AS ResponsiblePersonChat_Use ";

                    string strSql = "";

                    strSql = @"SELECT  {0}
                                    FROM    [TBL_TASK] T1 WITH ( NOLOCK )
                                    LEFT JOIN [TBL_SCHEDULE] T2 WITH ( NOLOCK ) ON T1.ID = T2.TaskID
                                    LEFT JOIN [CUSTOMER] T3 WITH ( NOLOCK ) ON T1.TaskOwnerID=T3.UserID
                                    LEFT JOIN [Account] T4 WITH ( NOLOCK ) ON T2.UserID=T4.UserID 
                                    LEFT JOIN [BRANCH] T5 WITH(NOLOCK) ON T1.BranchID=T5.ID 
                                    LEFT JOIN [TBL_ROLE] T6 ON T6.CompanyID = T1.CompanyID AND T6.ID = T4.RoleID 
                                    WHERE  T1.CompanyID=@CompanyID AND T1.CreateTime >= T5.StartTime ";

                    if (operationModel.ResponsiblePersonIDs != null && operationModel.ResponsiblePersonIDs.Count > 0)
                    {
                        strSql += " AND T2.UserID in ( ";
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
                        strSql += " )";
                    }

                    if (operationModel.Status != null && operationModel.Status.Count > 0)
                    {
                        strSql += " AND T1.TaskStatus in ( ";
                        for (int i = 0; i < operationModel.Status.Count; i++)
                        {
                            if (i == 0)
                            {
                                strSql += operationModel.Status[i].ToString();
                            }
                            else
                            {
                                strSql += "," + operationModel.Status[i].ToString();
                            }
                        }
                        strSql += " )";
                    }

                    //if (operationModel.TaskType > 0)
                    //{
                    //    strSql += " AND T1.TaskType = @TaskType";
                    //}

                    if (operationModel.BranchID > 0)
                    {
                        strSql += " AND T1.BranchID = @BranchID";
                    }

                    if (operationModel.PageIndex > 1)
                    {
                        //strSql += " AND T1.TaskScdlStartTime > @TaskScdlStartTime";
                        //operationModel.PageIndex = 1;
                    }

                    if (operationModel.FilterByTimeFlag == 1)
                    {

                        strSql += Common.APICommon.getSqlWhereData_1_7_2(4, operationModel.StartTime, operationModel.EndTime, " T1.TaskScdlStartTime");
                    }

                    if (operationModel.CustomerID > 0)
                    {
                        strSql += " AND T1.TaskOwnerID = @CustomerID";
                    }

                    string strCountSql = string.Format(strSql, " count(0) ");

                    string strgetListSql = "select * from( " + string.Format(strSql, fileds) + " ) a where  rowNum between  " + ((operationModel.PageIndex - 1) * operationModel.PageSize + 1) + " and " + operationModel.PageIndex * operationModel.PageSize;

                    recordCount = db.SetCommand(strCountSql
                                , db.Parameter("@BranchID", operationModel.BranchID, DbType.Int32)
                                , db.Parameter("@TaskType", operationModel.TaskType, DbType.Int32)
                                , db.Parameter("@TaskScdlStartTime", operationModel.TaskScdlStartTime, DbType.DateTime)
                                , db.Parameter("@CustomerID", operationModel.CustomerID, DbType.Int32)
                                , db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)).ExecuteScalar<int>();

                    if (recordCount < 0)
                    {
                        return null;
                    }

                    list = db.SetCommand(strgetListSql
                         , db.Parameter("@BranchID", operationModel.BranchID, DbType.Int32)
                         , db.Parameter("@TaskType", operationModel.TaskType, DbType.Int32)
                         , db.Parameter("@TaskScdlStartTime", operationModel.TaskScdlStartTime, DbType.DateTime)
                         , db.Parameter("@CustomerID", operationModel.CustomerID, DbType.Int32)
                         , db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)).ExecuteList<GetTaskList_Model>();
                    return list;
                }
            }
            else
            {
                return null;
            }
        }

        public int AddSchedule(AddTaskOperation_Model addModel)
        {
            using (DbManager db = new DbManager())
            {
                DataTable serviceDT = new DataTable();

                #region 判断赋值
                object objTaskDescriptiont = DBNull.Value;
                if (!string.IsNullOrWhiteSpace(addModel.TaskDescription))
                {
                    objTaskDescriptiont = addModel.TaskDescription;
                }

                object objTaskResult = DBNull.Value;
                if (!string.IsNullOrWhiteSpace(addModel.TaskResult))
                {
                    objTaskResult = addModel.TaskResult;
                }

                object objReservedOrderID = DBNull.Value;
                if (addModel.ReservedOrderID >= 0)
                {
                    objReservedOrderID = addModel.ReservedOrderID;
                }

                object objReservedOrderServiceID = DBNull.Value;
                if (addModel.ReservedOrderServiceID >= 0)
                {
                    objReservedOrderServiceID = addModel.ReservedOrderServiceID;
                }
                #endregion

                if (addModel.ReservedOrderType == 1)
                {
                    #region 抽取存单数据
                    if (addModel.ReservedOrderID <= 0 || addModel.ReservedOrderServiceID <= 0)
                    {
                        // 不合法参数
                        return 2;
                    }

                    string strSelOrderServiceSql = @"SELECT TOP 1 T1.ServiceCode ,T1.ServiceName ,T2.SpendTime
                                                    FROM    [TBL_ORDER_SERVICE] T1 WITH ( NOLOCK )
                                                            LEFT JOIN [SERVICE] T2 WITH ( NOLOCK ) ON T1.ServiceCode = T2.Code
                                                    WHERE   T1.OrderID = @OrderID
                                                            AND T1.ID = @OrderObjectID
                                                            AND T1.CompanyID = @CompanyID
                                                    ORDER BY T2.CreateTime DESC";
                    serviceDT = db.SetCommand(strSelOrderServiceSql
                                        , db.Parameter("@OrderID", addModel.ReservedOrderID, DbType.Int32)
                                        , db.Parameter("@OrderObjectID", addModel.ReservedOrderServiceID, DbType.Int32)
                                        , db.Parameter("@CompanyID", addModel.CompanyID, DbType.Int32)).ExecuteDataTable();

                    if (serviceDT == null || serviceDT.Rows.Count <= 0)
                    {
                        return 3;
                    }

                    addModel.ReservedServiceCode = StringUtils.GetDbLong(serviceDT.Rows[0]["ServiceCode"].ToString());
                    addModel.TaskName = serviceDT.Rows[0]["ServiceName"].ToString();
                    #endregion
                }
                else
                {
                    #region 抽取新单数据
                    if (addModel.ReservedServiceCode <= 0)
                    {
                        // 不合法参数
                        return 2;
                    }

                    string strSelServiceSql = @"SELECT TOP 1 T1.Code ,T1.ServiceName ,T1.SpendTime 
                                                    FROM    [SERVICE] T1 WITH ( NOLOCK )
                                                    WHERE   T1.CompanyID = @CompanyID
                                                            AND T1.Code = @Code
                                                            AND T1.Available = 1
                                                    ORDER BY T1.CreateTime DESC";

                    serviceDT = db.SetCommand(strSelServiceSql
                                        , db.Parameter("@Code", addModel.ReservedServiceCode, DbType.Int64)
                                        , db.Parameter("@CompanyID", addModel.CompanyID, DbType.Int32)).ExecuteDataTable();

                    if (serviceDT == null || serviceDT.Rows.Count <= 0)
                    {
                        return 3;
                    }

                    addModel.ReservedServiceCode = StringUtils.GetDbLong(serviceDT.Rows[0]["Code"].ToString());
                    addModel.TaskName = serviceDT.Rows[0]["ServiceName"].ToString();
                    #endregion
                }

                db.BeginTransaction();

                long taskID = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "TaskID", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<long>();
                if (taskID <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                #region 创建TASK
                string strSql = @" INSERT INTO TBL_TASK( BranchID ,ID ,TaskOwnerType ,TaskOwnerID ,TaskType ,TaskName ,TaskDescription ,TaskResult ,TaskStatus ,TaskScdlStartTime ,ReservedOrderType ,ReservedOrderID ,ReservedOrderServiceID ,ReservedServiceCode  ,Remark ,CompanyID ,CreatorID ,CreateTime ) 
                                VALUES ( @BranchID ,@ID ,@TaskOwnerType ,@TaskOwnerID ,@TaskType ,@TaskName ,@TaskDescription ,@TaskResult ,@TaskStatus ,@TaskScdlStartTime ,@ReservedOrderType ,@ReservedOrderID ,@ReservedOrderServiceID ,@ReservedServiceCode  ,@Remark ,@CompanyID ,@CreatorID ,@CreateTime )  ";

                int rows = db.SetCommand(strSql, db.Parameter("@BranchID", addModel.BranchID, DbType.Int32)
                    , db.Parameter("@ID", taskID, DbType.Int64)
                    , db.Parameter("@TaskOwnerType", addModel.TaskOwnerType, DbType.Int32)
                    , db.Parameter("@TaskOwnerID", addModel.TaskOwnerID, DbType.Int32)
                    , db.Parameter("@TaskType", addModel.TaskType, DbType.Int32)
                    , db.Parameter("@TaskName", addModel.TaskName, DbType.String)
                    , db.Parameter("@TaskDescription", objTaskDescriptiont, DbType.String)
                    , db.Parameter("@TaskResult", objTaskResult, DbType.String)
                    , db.Parameter("@TaskStatus", addModel.TaskStatus, DbType.Int32)
                    , db.Parameter("@TaskScdlStartTime", addModel.TaskScdlStartTime, DbType.DateTime)
                    , db.Parameter("@ReservedOrderType", addModel.ReservedOrderType, DbType.Int32)
                    , db.Parameter("@ReservedOrderID", objReservedOrderID, DbType.Int32)
                    , db.Parameter("@ReservedOrderServiceID", objReservedOrderServiceID, DbType.Int32)
                    , db.Parameter("@ReservedServiceCode", addModel.ReservedServiceCode, DbType.Int64)
                    , db.Parameter("@Remark", addModel.Remark, DbType.String)
                    , db.Parameter("@CompanyID", addModel.CompanyID, DbType.Int32)
                    , db.Parameter("@CreatorID", addModel.CreatorID, DbType.Int32)
                    , db.Parameter("@CreateTime", addModel.CreateTime, DbType.DateTime)).ExecuteNonQuery();
                if (rows <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                db.CommitTransaction();
                return 1;
            }
        }

        public GetScheduleDetail_Model GetScheduleDetail(int companyID, long taskID)
        {
            using (DbManager db = new DbManager())
            {
                GetScheduleDetail_Model model = new GetScheduleDetail_Model();
                string strSql = @"SELECT  T1.ID AS TaskID ,
                                        T1.TaskOwnerID ,
                                        T3.Name AS TaskOwnerName ,
                                        T5.BranchName ,
                                        T1.TaskScdlStartTime ,
                                        T1.ReservedServiceCode AS ProductCode ,
                                        T1.TaskName AS ProductName ,
                                        T4.UserID AS AccountID ,
                                        T4.Name AS AccountName ,
                                        T1.TaskType ,
                                        CASE TaskType WHEN 1 THEN T1.ReservedOrderID ELSE ActedOrderID END AS OrderID ,
                                        CASE TaskType WHEN 1 THEN T1.ReservedOrderServiceID ELSE ActedOrderServiceID END AS OrderObjectID ,
                                        T6.SumSalePrice AS TotalSalePrice ,
                                        T1.TaskDescription ,
                                        T1.TaskResult,
                                        T1.Remark, 
                                        T7.CreateTime AS OrderCreateTime,
                                        T1.ExecuteStartTime ,
                                        TaskStatus   
                                FROM    [TBL_TASK] T1 WITH ( NOLOCK )
                                        LEFT JOIN [TBL_SCHEDULE] T2 WITH ( NOLOCK ) ON T1.ID = T2.TaskID
                                        LEFT JOIN [CUSTOMER] T3 WITH ( NOLOCK ) ON T1.TaskOwnerID = T3.UserID
                                        LEFT JOIN [ACCOUNT] T4 WITH ( NOLOCK ) ON T2.UserID = T4.UserID
                                        LEFT JOIN [BRANCH] T5 WITH ( NOLOCK ) ON T1.BranchID = T5.ID
                                        LEFT JOIN [TBL_ORDER_SERVICE] T6 WITH ( NOLOCK ) ON ISNULL(T1.ReservedOrderServiceID,T1.ActedOrderServiceID) = T6.ID 
                                        LEFT JOIN [ORDER] T7  WITH ( NOLOCK ) ON T7.ID = T6.OrderID
                                WHERE   T1.CompanyID = @CompanyID
                                        AND T1.ID = @TaskID";

                model = db.SetCommand(strSql
                      , db.Parameter("@CompanyID", companyID, DbType.Int32)
                      , db.Parameter("@TaskID", taskID, DbType.Int64)).ExecuteObject<GetScheduleDetail_Model>();

                return model;
            }
        }

        public int CancelSchedule(int companyID, long taskID, int accountID, DateTime dt)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                string strUpdateTaskSql = @"UPDATE  [TBL_TASK]
                                            SET     TaskStatus = 4 ,
                                                    RecordType = 2 ,
                                                    UpdaterID = @UpdaterID ,
                                                    UpdateTime = @UpdateTime
                                            WHERE   CompanyID = @CompanyID
                                                    AND ID = @TaskID";

                int updateTaskRows = db.SetCommand(strUpdateTaskSql
                                  , db.Parameter("@UpdaterID", accountID, DbType.Int32)
                                  , db.Parameter("@UpdateTime", dt, DbType.DateTime)
                                  , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                  , db.Parameter("@TaskID", taskID, DbType.Int64)).ExecuteNonQuery();

                if (updateTaskRows <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                string strSelScdlSql = "SELECT COUNT(0) FROM  [TBL_SCHEDULE] T1 WITH(NOLOCK) WHERE T1.CompanyID=@CompanyID AND T1.TaskID=@TaskID";
                int scdlCount = db.SetCommand(strSelScdlSql
                              , db.Parameter("@CompanyID", companyID, DbType.Int32)
                              , db.Parameter("@TaskID", taskID, DbType.Int64)).ExecuteScalar<int>();

                if (scdlCount > 0)
                {
                    string strDelSchedlSql = "DELETE FROM [TBL_SCHEDULE] WHERE TaskID=@TaskID AND CompanyID=@CompanyID";
                    int delRows = db.SetCommand(strDelSchedlSql
                                , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                , db.Parameter("@TaskID", taskID, DbType.Int64)).ExecuteNonQuery();

                    if (delRows <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                }

                db.CommitTransaction();
                return 1;
            }
        }

        public int EditVisitTask(AddTaskOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSelTaskBasicSql = "SELECT TaskStatus FROM [TBL_TASK] WHERE CompanyID=@CompanyID AND ID=@TaskID AND TaskType=2";

                int taskStatus = db.SetCommand(strSelTaskBasicSql
                             , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                             , db.Parameter("@TaskID", model.ID, DbType.Int64)).ExecuteScalar<int>();

                if (taskStatus <= 0)
                {
                    return 2;
                }

                if (taskStatus == 3)
                {
                    return 3;
                }

                if (taskStatus == 4)
                {
                    return 4;
                }

                db.BeginTransaction();
                string strUpdateSql = @"UPDATE  [TBL_TASK]
                                        SET     ExecuteStartTime = @ExecuteStartTime
                                                , TaskResult = @TaskResult
                                                , UpdaterID = @UpdaterID
                                                , UpdateTime = @UpdateTime ";
                if (model.TaskStatus == 3)
                {
                    strUpdateSql += ", TaskStatus = 3 ";
                }
                strUpdateSql += " WHERE CompanyID=@CompanyID AND ID=@TaskID";

                int updateRes = db.SetCommand(strUpdateSql
                             , db.Parameter("@ExecuteStartTime", model.ExecuteStartTime, DbType.DateTime)
                             , db.Parameter("@TaskResult", model.TaskResult, DbType.String)
                             , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                             , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime)
                             , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                             , db.Parameter("@TaskID", model.ID, DbType.Int64)).ExecuteNonQuery();

                if (updateRes <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }


                string strUpdaterScheduleSql = @"UPDATE  [TBL_SCHEDULE]
                                                    SET     ExecuteStartTime = @ExecuteStartTime ,
                                                            UpdaterID = @UpdaterID ,
                                                            UpdateTime = @UpdateTime ";
                if (model.TaskStatus == 3)
                {
                    strUpdateSql += ", ScheduleStatus = 3 ";
                    strUpdateSql += ", ExecuteEndTime = @UpdateTime ";
                }
                strUpdateSql += " WHERE CompanyID=@CompanyID AND ID=@TaskID";

                updateRes = db.SetCommand(strUpdaterScheduleSql
                            , db.Parameter("@ExecuteStartTime", model.ExecuteStartTime, DbType.DateTime)
                            , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                            , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime)
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@TaskID", model.ID, DbType.Int64)).ExecuteNonQuery();

                if (updateRes <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }

                db.CommitTransaction();
                return 1;
            }
        }

        public List<TaskSimpleList_Model> GetScheduleListByOrderID(int companyID, int orderID, int orderObjectID)
        {
            List<TaskSimpleList_Model> list = new List<TaskSimpleList_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  T1.ID AS TaskID ,
                                            T1.TaskScdlStartTime ,
                                            T3.Name AS ResponsiblePersonName 
                                    FROM    [TBL_TASK] T1 WITH ( NOLOCK )
                                            LEFT JOIN [TBL_SCHEDULE] T2 WITH ( NOLOCK ) ON T1.ID = T2.TaskID
                                            LEFT JOIN [ACCOUNT] T3 WITH ( NOLOCK ) ON T2.UserID = T3.UserID
                                    WHERE   T1.CompanyID = @CompanyID
                                            AND T1.TaskType=1
                                            AND T1.ReservedOrderID=@OrderID
                                            AND T1.ReservedOrderServiceID=@OrderObjectID
                                            AND ( TaskStatus=1 OR TaskStatus=2 )";

                list = db.SetCommand(strSql
                     , db.Parameter("CompanyID", companyID, DbType.Int32)
                     , db.Parameter("OrderID", orderID, DbType.Int32)
                     , db.Parameter("OrderObjectID", orderObjectID, DbType.Int32)).ExecuteList<TaskSimpleList_Model>();

                return list;
            }
        }
    }
}
