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
    public class Task_DAL
    {
        #region 构造类实例
        public static Task_DAL Instance
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
            internal static readonly Task_DAL instance = new Task_DAL();
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

                    string orderBy = " ORDER BY T1.TaskScdlStartTime ";
                    if (operationModel.Status != null && operationModel.Status.Count == 1 && operationModel.Status[0] == 3)
                    {
                        orderBy = " ORDER BY T1.TaskScdlStartTime DESC ";
                    }
                    string fileds = @" ROW_NUMBER() OVER ( " + orderBy + @" ) AS rowNum ,
                                                  CASE WHEN T1.TaskStatus=2 AND T1.TaskType=2 THEN T1.TaskScdlendTime
                                                WHEN T1.TaskStatus=3 AND T1.TaskType=2 THEN T1.ExecuteEndTime 
                                                ELSE T1.TaskScdlStartTime END AS TaskScdlStartTime , 
                                                T3.Name AS CustomerName ,T4.UserID AS ResponsiblePersonID ,T4.Name AS ResponsiblePersonName ,T5.Phone AS BranchPhone ,T5.BranchName,T1.TaskStatus ,T1.TaskName ,T1.ID AS TaskID ,T1.TaskType ,
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

                    if (operationModel.TaskType != null && operationModel.TaskType.Count > 0)
                    {
                        strSql += " AND T1.TaskType in ( ";
                        for (int i = 0; i < operationModel.TaskType.Count; i++)
                        {
                            if (i == 0)
                            {
                                strSql += operationModel.TaskType[i].ToString();
                            }
                            else
                            {
                                strSql += "," + operationModel.TaskType[i].ToString();
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
                                //, db.Parameter("@TaskType", operationModel.TaskType, DbType.Int32)
                                , db.Parameter("@TaskScdlStartTime", operationModel.TaskScdlStartTime, DbType.DateTime)
                                , db.Parameter("@CustomerID", operationModel.CustomerID, DbType.Int32)
                                , db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)).ExecuteScalar<int>();

                    if (recordCount < 0)
                    {
                        return null;
                    }

                    list = db.SetCommand(strgetListSql
                         , db.Parameter("@BranchID", operationModel.BranchID, DbType.Int32)
                         //, db.Parameter("@TaskType", operationModel.TaskType, DbType.Int32)
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

        public int GetScheduleCountByCustomerID(int companyID, int customerID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  count(0)
                                    FROM    [TBL_TASK] T1 WITH ( NOLOCK )
                                    LEFT JOIN [BRANCH] T2 WITH(NOLOCK) ON T1.BranchID=T2.ID 
                                    WHERE  T1.CompanyID=@CompanyID 
                                           AND T1.CreateTime >= T2.StartTime 
                                           AND T1.TaskType = 1 
                                           AND T1.TaskStatus = 2 AND T1.TaskOwnerID = @CustomerID ";

                int count = db.SetCommand(strSql
                            , db.Parameter("@CustomerID", customerID, DbType.Int32)
                            , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalar<int>();

                return count;
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
                if (addModel.ReservedOrderID > 0)
                {
                    objReservedOrderID = addModel.ReservedOrderID;
                }

                object objReservedOrderServiceID = DBNull.Value;
                if (addModel.ReservedOrderServiceID > 0)
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
                                                            --AND T2.Available = 1
                                                    ORDER BY T2.ID DESC";
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
                                                    ORDER BY T1.ID DESC";

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
                string strSql = @" INSERT INTO TBL_TASK( BranchID ,ID ,TaskOwnerType ,TaskOwnerID ,TaskType ,TaskName ,TaskDescription ,TaskResult ,TaskStatus ,TaskScdlStartTime ,TaskScdlEndTime ,ReservedOrderType ,ReservedOrderID ,ReservedOrderServiceID ,ReservedServiceCode  ,Remark ,CompanyID ,CreatorID ,CreateTime ) 
                                VALUES ( @BranchID ,@ID ,@TaskOwnerType ,@TaskOwnerID ,@TaskType ,@TaskName ,@TaskDescription ,@TaskResult ,@TaskStatus ,@TaskScdlStartTime ,@TaskScdlEndTime ,@ReservedOrderType ,@ReservedOrderID ,@ReservedOrderServiceID ,@ReservedServiceCode  ,@Remark ,@CompanyID ,@CreatorID ,@CreateTime )  ";

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
                    , db.Parameter("@TaskScdlEndTime", addModel.TaskScdlEndTime, DbType.DateTime)
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

                if (addModel.IsBusiness)
                {
                    #region 确认预约
                    string strUpdateTask = @"UPDATE  [TBL_TASK]
                                                SET     ReservationConfirmer = @ReservationConfirmer ,
                                                        TaskStatus = 2
                                                WHERE   CompanyID = @CompanyID
                                                        AND ID = @TaskID";
                    int updateRes = db.SetCommand(strUpdateTask
                             , db.Parameter("@ReservationConfirmer", addModel.CreatorID, DbType.Int32)
                             , db.Parameter("@CompanyID", addModel.CompanyID, DbType.Int32)
                             , db.Parameter("@TaskID", taskID, DbType.Int64)).ExecuteNonQuery();

                    if (updateRes <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    #endregion

                    PushOperation_Model pushmodel = new PushOperation_Model();
                    if (addModel.ExecutorID > 0)
                    {
                        #region 指定分派任务
                        int serviceSpendTime = StringUtils.GetDbInt(serviceDT.Rows[0]["SpendTime"].ToString());
                        //DateTime scdlEndTime = addModel.TaskScdlStartTime;
                        //if (serviceSpendTime > 0)
                        //{
                        //    scdlEndTime = addModel.TaskScdlStartTime.AddMinutes(serviceSpendTime);
                        //}
                        DateTime scdlEndTime = addModel.TaskScdlStartTime.AddMinutes(15);

                        long scheduleID = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "ScheduleID", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<long>();
                        if (scheduleID <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        string strAddScheduleSql = @"INSERT INTO [TBL_SCHEDULE]( BranchID ,ID ,ScheduleType ,UserID ,TaskID ,ScheduleName ,ScheduleDescription ,ScdlStartTime ,ScdlEndTime ,Reminded ,Repeat ,Remark ,ScheduleStatus ,CompanyID ,CreatorID ,CreateTime ) 
                                                        VALUES ( @BranchID ,@ID ,@ScheduleType ,@UserID ,@TaskID ,@ScheduleName ,@ScheduleDescription ,@ScdlStartTime ,@ScdlEndTime  ,@Reminded ,@Repeat ,@Remark ,@ScheduleStatus ,@CompanyID ,@CreatorID ,@CreateTime )";

                        int scheduleRows = db.SetCommand(strAddScheduleSql
                                 , db.Parameter("@BranchID", addModel.BranchID, DbType.Int32)
                                 , db.Parameter("@ID", scheduleID, DbType.Int64)
                                 , db.Parameter("@ScheduleType", 1, DbType.Int32)
                                 , db.Parameter("@UserID", addModel.ExecutorID, DbType.Int32)
                                 , db.Parameter("@TaskID", taskID, DbType.Int64)
                                 , db.Parameter("@ScheduleName", addModel.TaskName, DbType.String)
                                 , db.Parameter("@ScheduleDescription", objTaskDescriptiont, DbType.String)
                                 , db.Parameter("@ScdlStartTime", addModel.TaskScdlStartTime, DbType.DateTime)
                                 , db.Parameter("@ScdlEndTime", scdlEndTime, DbType.DateTime)
                                 , db.Parameter("@Reminded", 0, DbType.Int32)
                                 , db.Parameter("@Repeat", 1, DbType.Int32)
                                 , db.Parameter("@Remark", DBNull.Value, DbType.String)
                                 , db.Parameter("@ScheduleStatus", 2, DbType.Int32)//2：已确认 3：已执行 4：已取消
                                 , db.Parameter("@CompanyID", addModel.CompanyID, DbType.Int32)
                                 , db.Parameter("@CreatorID", addModel.CreatorID, DbType.Int32)
                                 , db.Parameter("@CreateTime", addModel.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                        if (scheduleRows <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        #endregion
                    }

                    #region 即时PUSH
                    string strSelLoginSql = @"SELECT  T1.DeviceID AS DeviceID ,
                                                        T1.UserID AS CustomerID ,
                                                        T1.DeviceType ,
                                                        T2.BranchName,
                                                        T3.Name AS CustomerName ,
                                                        T4.Abbreviation AS CompanyName ,
														T5.UserType,
                                                        T3.WeChatOpenID
                                                FROM    [LOGIN] T1 WITH ( NOLOCK )
                                                        LEFT JOIN [Branch] T2 WITH ( NOLOCK ) ON T2.ID = @BranchID
                                                        LEFT JOIN [CUSTOMER] T3 WITH(NOLOCK) ON T3.UserID = T1.UserID 
                                                        LEFT JOIN [COMPANY] T4 WITH ( NOLOCK ) ON T4.ID = T1.CompanyID 
		                                                LEFT JOIN [USER] T5 WITH ( NOLOCK ) ON T1.UserID = T5.ID
                                                WHERE   T1.UserID = @CustomerID 
                                                        --AND ISNULL(T1.DeviceID, '') <> ''
                                                        AND T2.Available = 1";
                    pushmodel = db.SetCommand(strSelLoginSql
                                   , db.Parameter("@CustomerID", addModel.TaskOwnerID, DbType.Int32)
                                   , db.Parameter("@BranchID", addModel.BranchID, DbType.Int32)).ExecuteObject<PushOperation_Model>();

                    if (pushmodel != null)
                    {
                        string pushMsg = "您预约在" + pushmodel.CompanyName + "于" + addModel.TaskScdlStartTime.ToLongDateString() + "的" + addModel.TaskName + "服务已确认成功。";

                        //Task.Factory.StartNew(() =>
                        //{
                        try
                        {
                            #region 微信push
                            if (!string.IsNullOrEmpty(pushmodel.WeChatOpenID))
                            {
                                HS.Framework.Common.WeChat.WeChat we = new HS.Framework.Common.WeChat.WeChat();
                                string accessToken = we.GetWeChatToken(addModel.CompanyID);
                                if (!string.IsNullOrEmpty(accessToken))
                                {
                                    string accountName = "到店指定";
                                    if (addModel.ExecutorID > 0)
                                    {
                                        accountName = db.SetCommand("SELECT Name FROM [ACCOUNT] WHERE UserID=@UserID", db.Parameter("@UserID", addModel.ExecutorID, DbType.Int32)).ExecuteScalar<string>();
                                    }

                                    HS.Framework.Common.WeChat.Entity.MessageTemplate messageModel = new HS.Framework.Common.WeChat.Entity.MessageTemplate();
                                    HS.Framework.Common.WeChat.WXCompanyInfoBase WXCompanyInfoBase = we.GetBaseInfo(addModel.CompanyID);
                                    messageModel.template_id = WXCompanyInfoBase.AccountChangesTemplate;
                                    messageModel.topcolor = "#000000";
                                    messageModel.touser = pushmodel.WeChatOpenID;
                                    messageModel.data = new HS.Framework.Common.WeChat.Entity.TemplateDetail()
                                    {
                                        first = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#FF0000", value = "您的预约确认成功\n" },
                                        keyword1 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = addModel.TaskName },
                                        keyword2 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = addModel.TaskScdlStartTime.ToString("yyyy-MM-dd HH:mm") },
                                        remark = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = "预约门店：" + pushmodel.BranchName + "\n预约顾问：" + accountName + "\n\n感谢您的选择，我们将竭诚为您服务，请准时到店享受服务。" }
                                    };

                                    we.TemplateMessageSend(messageModel, addModel.CompanyID, 2, accessToken);
                                }
                            }
                            #endregion

                            if (!string.IsNullOrWhiteSpace(pushmodel.DeviceID))
                            {
                                HS.Framework.Common.Push.HSPush.pushMsg(pushmodel.DeviceID, pushmodel.DeviceType, 0, pushMsg, Convert.ToBoolean(System.Configuration.ConfigurationManager.AppSettings["IsProduction"]), "9");
                            }
                        }
                        catch (Exception)
                        {
                            LogUtil.Log("push失败", pushmodel.CustomerID + "push预约失败,时间:" + addModel.CreateTime + "美容师ID:" + pushmodel.AccountID + ",DeviceID:" + pushmodel.DeviceID + "DeviceType:" + pushmodel.DeviceType);
                        }
                        //});
                    }
                    #endregion

                    #region 插入PUSH表
                    string strSelRemindTime = @"SELECT ISNULL(RemindTime,0) AS RemindTime FROM [BRANCH] WHERE CompanyID=@CompanyID AND ID=@BranchID AND Available=1";
                    decimal remindTime = db.SetCommand(strSelRemindTime
                                       , db.Parameter("@CompanyID", addModel.CompanyID, DbType.Int32)
                                       , db.Parameter("@BranchID", addModel.BranchID, DbType.Int32)).ExecuteScalar<decimal>();

                    if (remindTime > 0)//需要预约提醒
                    {
                        string strAddPushPoolSql = @"INSERT INTO [TBL_PUSHPOOL]( BranchID ,ID ,SourceType ,SourceID ,PushTargetID ,PushType ,PushTime ,PushMessage ,PushStatus ,PhoneNumber ,PushPriority ,CompanyID ,CreatorID ,CreateTime,RecordType,PushTargetType,WeChatOpenID )
                                                VALUES ( @BranchID ,@ID ,@SourceType ,@SourceID ,@PushTargetID ,@PushType ,@PushTime ,@PushMessage ,@PushStatus ,@PhoneNumber ,@PushPriority ,@CompanyID ,@CreatorID ,@CreateTime,1,@PushTargetType,@WeChatOpenID )";

                        if (pushmodel != null && !string.IsNullOrWhiteSpace(pushmodel.DeviceID))
                        {
                            if (DateTime.Now.ToLocalTime().AddHours(StringUtils.GetDbDouble(remindTime)) < addModel.TaskScdlStartTime)
                            {
                                DateTime pushTime = addModel.TaskScdlStartTime.AddHours(StringUtils.GetDbDouble(remindTime * -1));
                                string pushMsg = "尊敬的" + pushmodel.CustomerName + "，您在" + pushmodel.CompanyName + "预约了服务，请准时到店享受服务。";

                                long pushPoolID = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "PUSHPOOL", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<long>();
                                if (pushPoolID <= 0)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }

                                int addPoolRes = db.SetCommand(strAddPushPoolSql
                                             , db.Parameter("@BranchID", addModel.BranchID, DbType.Int32)
                                             , db.Parameter("@ID", pushPoolID, DbType.Int64)
                                             , db.Parameter("@SourceType", 1, DbType.Int32)//1：预约任务
                                             , db.Parameter("@SourceID", taskID, DbType.Int64)
                                             , db.Parameter("@PushTargetID", pushmodel.CustomerID, DbType.Int32)
                                             , db.Parameter("@TargetUserType", 0, DbType.Int32)//0:customer 1:account
                                             , db.Parameter("@PushType", 1, DbType.Int32)//Push类型 1:系统Push 2:短消息
                                             , db.Parameter("@PushTime", pushTime, DbType.DateTime)
                                             , db.Parameter("@PushMessage", pushMsg, DbType.String)
                                             , db.Parameter("@PushStatus", 1, DbType.Int32)//1：待发送 2：已发送 3：已取消
                                             , db.Parameter("@PhoneNumber", DBNull.Value, DbType.String)
                                             , db.Parameter("@PushPriority", 1, DbType.Int32)
                                             , db.Parameter("@CompanyID", addModel.CompanyID, DbType.Int32)
                                             , db.Parameter("@CreatorID", addModel.CreatorID, DbType.Int32)
                                             , db.Parameter("@CreateTime", addModel.CreateTime, DbType.DateTime)
                                             , db.Parameter("@PushTargetType", pushmodel.UserType, DbType.Int32)
                                             , db.Parameter("@WeChatOpenID", pushmodel.WeChatOpenID, DbType.String)).ExecuteNonQuery();
                            }

                        }
                    }
                    #endregion
                }

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
                                        CASE ReservedOrderType WHEN 1 THEN T1.ReservedOrderID ELSE ActedOrderID END AS OrderID ,
                                        CASE ReservedOrderType WHEN 1 THEN T1.ReservedOrderServiceID ELSE ActedOrderServiceID END AS OrderObjectID ,
                                        T6.SumSalePrice AS TotalSalePrice ,
                                        T1.TaskDescription ,
                                        T1.TaskResult,
                                        T1.Remark, 
                                        T7.CreateTime AS OrderCreateTime,
                                        T1.ExecuteStartTime ,
                                        T1.CreateTime ,
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

        public int ConfirmSchedule(AddTaskOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSelTaskStatusSql = @"SELECT  T1.TaskStatus ,T2.SpendTime ,T2.ServiceName 
                                                FROM    [TBL_TASK] T1 WITH ( NOLOCK )
                                                        LEFT JOIN [SERVICE] T2 WITH ( NOLOCK ) ON T1.ReservedServiceCode = T2.Code
                                                WHERE   T1.CompanyID = @CompanyID
                                                        AND T1.ID = @TaskID
                                                ORDER BY T2.CreateTime DESC";

                DataTable dt = db.SetCommand(strSelTaskStatusSql
                             , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                             , db.Parameter("@TaskID", model.ID, DbType.Int64)).ExecuteDataTable();

                if (dt == null || dt.Rows.Count <= 0)
                {
                    return 0;
                }

                int taskStatus = StringUtils.GetDbInt(dt.Rows[0]["TaskStatus"].ToString());
                model.TaskName = dt.Rows[0]["ServiceName"].ToString();
                if (taskStatus <= 0)
                {
                    return 0;
                }

                if (taskStatus == 2 || taskStatus == 3)
                {
                    return 2;
                }

                if (taskStatus == 4)
                {
                    return 3;
                }

                db.BeginTransaction();

                #region 修改Task表
                string strUpdateTaskSql = @"UPDATE  [TBL_TASK]
                                            SET     TaskScdlStartTime = @TaskScdlStartTime , 
                                                    TaskScdlEndTime = @TaskScdlEndTime , 
                                                    TaskStatus = 2 ,
                                                    ReservationConfirmer = @AccountID ,
                                                    Remark = @Remark ,
                                                    UpdaterID = @UpdaterID ,
                                                    UpdateTime = @UpdateTime
                                            WHERE   CompanyID = @CompanyID
                                                    AND ID = @TaskID";

                int updateTaskRows = db.SetCommand(strUpdateTaskSql
                                  , db.Parameter("@TaskScdlStartTime", model.TaskScdlStartTime, DbType.DateTime)
                                  , db.Parameter("@TaskScdlEndTime", model.TaskScdlEndTime, DbType.DateTime)
                                  , db.Parameter("@AccountID", model.ReservationConfirmer, DbType.Int32)
                                  , db.Parameter("@Remark", model.Remark, DbType.String)
                                  , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                                  , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime)
                                  , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                  , db.Parameter("@TaskID", model.ID, DbType.Int64)).ExecuteNonQuery();

                if (updateTaskRows <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }
                #endregion

                string strSelScdlSql = "SELECT COUNT(0) FROM  [TBL_SCHEDULE] T1 WITH(NOLOCK) WHERE T1.CompanyID=@CompanyID AND T1.TaskID=@TaskID";
                int scdlCount = db.SetCommand(strSelScdlSql
                      , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                      , db.Parameter("@TaskID", model.ID, DbType.Int64)).ExecuteScalar<int>();

                //if (scdlCount > 0)
                //{
                //    return 2;
                //}

                if (scdlCount > 0)
                {
                    string strDelSCHEDULESql = @"DELETE FROM TBL_SCHEDULE WHERE CompanyID=@CompanyID AND TaskID=@TaskID";
                    int delres = db.SetCommand(strDelSCHEDULESql
                               , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                               , db.Parameter("@TaskID", model.ID, DbType.Int64)).ExecuteNonQuery();

                    if (delres <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                }

                if (model.ExecutorID > 0)
                {
                    int serviceSpendTime = StringUtils.GetDbInt(dt.Rows[0]["SpendTime"].ToString());
                    //DateTime scdlEndTime = model.TaskScdlStartTime;
                    //if (serviceSpendTime > 0)
                    //{
                    //    scdlEndTime = model.TaskScdlStartTime.AddMinutes(serviceSpendTime);
                    //}
                    DateTime scdlEndTime = model.TaskScdlStartTime.AddMinutes(15);
                    #region 插入SCHEDULE表
                    long scheduleID = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "ScheduleID", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<long>();
                    if (scheduleID <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    string strAddScheduleSql = @"INSERT INTO [TBL_SCHEDULE]( BranchID ,ID ,ScheduleType ,UserID ,TaskID ,ScheduleName ,ScheduleDescription ,ScdlStartTime ,ScdlEndTime ,Reminded ,Repeat ,Remark ,ScheduleStatus ,CompanyID ,CreatorID ,CreateTime ) 
                                                        VALUES ( @BranchID ,@ID ,@ScheduleType ,@UserID ,@TaskID ,@ScheduleName ,@ScheduleDescription ,@ScdlStartTime ,@ScdlEndTime  ,@Reminded ,@Repeat ,@Remark ,@ScheduleStatus ,@CompanyID ,@CreatorID ,@CreateTime )";

                    int scheduleRows = db.SetCommand(strAddScheduleSql
                             , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                             , db.Parameter("@ID", scheduleID, DbType.Int64)
                             , db.Parameter("@ScheduleType", 1, DbType.Int32)
                             , db.Parameter("@UserID", model.ExecutorID, DbType.Int32)
                             , db.Parameter("@TaskID", model.ID, DbType.Int64)
                             , db.Parameter("@ScheduleName", model.TaskName, DbType.String)
                             , db.Parameter("@ScheduleDescription", DBNull.Value, DbType.String)
                             , db.Parameter("@ScdlStartTime", model.TaskScdlStartTime, DbType.DateTime)
                             , db.Parameter("@ScdlEndTime", scdlEndTime, DbType.DateTime)
                             , db.Parameter("@Reminded", 0, DbType.Int32)
                             , db.Parameter("@Repeat", 1, DbType.Int32)
                             , db.Parameter("@Remark", model.Remark, DbType.String)
                             , db.Parameter("@ScheduleStatus", 2, DbType.Int32)//2：已确认 3：已执行 4：已取消
                             , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                             , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                             , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)).ExecuteNonQuery();

                    if (scheduleRows <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    #endregion

                }

                #region 即时PUSH
                PushOperation_Model pushmodel = new PushOperation_Model();
                string strSelLoginSql = @"SELECT  T1.DeviceID AS DeviceID ,
                                                        T1.UserID AS CustomerID ,
                                                        T1.DeviceType ,
                                                        T2.BranchName,
                                                        T3.Name AS CustomerName ,
                                                        T4.Abbreviation AS CompanyName ,
														T5.UserType,
                                                        T3.WeChatOpenID
                                                FROM    [LOGIN] T1 WITH ( NOLOCK )
                                                        LEFT JOIN [Branch] T2 WITH ( NOLOCK ) ON T2.ID = @BranchID
                                                        LEFT JOIN [CUSTOMER] T3 WITH(NOLOCK) ON T3.UserID = T1.UserID 
                                                        LEFT JOIN [COMPANY] T4 WITH ( NOLOCK ) ON T4.ID = T1.CompanyID 
		                                                LEFT JOIN [USER] T5 WITH ( NOLOCK ) ON T1.UserID = T5.ID
                                                WHERE   T1.UserID = @CustomerID 
                                                        --AND ISNULL(T1.DeviceID, '') <> ''
                                                        AND T2.Available = 1";
                pushmodel = db.SetCommand(strSelLoginSql
                               , db.Parameter("@CustomerID", model.TaskOwnerID, DbType.Int32)
                               , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteObject<PushOperation_Model>();

                if (pushmodel != null)
                {
                    string pushMsg = "您预约在" + pushmodel.CompanyName + "于" + model.TaskScdlStartTime.ToLongDateString() + "的" + model.TaskName + "服务已确认成功。";

                    //Task.Factory.StartNew(() =>
                    //{
                    try
                    {
                        #region 微信push
                        if (!string.IsNullOrEmpty(pushmodel.WeChatOpenID))
                        {
                            HS.Framework.Common.WeChat.WeChat we = new HS.Framework.Common.WeChat.WeChat();
                            string accessToken = we.GetWeChatToken(model.CompanyID);
                            if (!string.IsNullOrEmpty(accessToken))
                            {
                                string accountName = "到店指定";
                                if (model.ExecutorID > 0)
                                {
                                    accountName = db.SetCommand("SELECT Name FROM [ACCOUNT] WHERE UserID=@UserID", db.Parameter("@UserID", model.ExecutorID, DbType.Int32)).ExecuteScalar<string>();
                                }

                                HS.Framework.Common.WeChat.Entity.MessageTemplate messageModel = new HS.Framework.Common.WeChat.Entity.MessageTemplate();
                                HS.Framework.Common.WeChat.WXCompanyInfoBase WXCompanyInfoBase = we.GetBaseInfo(model.CompanyID);
                                messageModel.template_id = WXCompanyInfoBase.AccountChangesTemplate;
                                messageModel.topcolor = "#000000";
                                messageModel.touser = pushmodel.WeChatOpenID;
                                messageModel.data = new HS.Framework.Common.WeChat.Entity.TemplateDetail()
                                {
                                    first = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#FF0000", value = "您的预约确认成功\n" },
                                    keyword1 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = model.TaskName },
                                    keyword2 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = model.TaskScdlStartTime.ToString("yyyy-MM-dd HH:mm") },
                                    remark = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = "预约门店：" + pushmodel.BranchName + "\n预约顾问：" + accountName + "\n\n感谢您的选择，我们将竭诚为您服务，请准时到店享受服务。" }
                                };

                                we.TemplateMessageSend(messageModel, model.CompanyID, 2, accessToken);
                            }
                        }
                        #endregion

                        if (!string.IsNullOrWhiteSpace(pushmodel.DeviceID))
                        {
                            HS.Framework.Common.Push.HSPush.pushMsg(pushmodel.DeviceID, pushmodel.DeviceType, 0, pushMsg, Convert.ToBoolean(System.Configuration.ConfigurationManager.AppSettings["IsProduction"]), "9");
                        }
                    }
                    catch (Exception)
                    {
                        LogUtil.Log("push失败", pushmodel.CustomerID + "push预约失败,时间:" + model.CreateTime + "美容师ID:" + pushmodel.AccountID + ",DeviceID:" + pushmodel.DeviceID + "DeviceType:" + pushmodel.DeviceType);
                    }
                    //});
                }
                #endregion

                #region 插入PUSH表
                string strSelRemindTime = @"SELECT ISNULL(RemindTime,0) AS RemindTime FROM [BRANCH] WHERE CompanyID=@CompanyID AND ID=@BranchID AND Available=1";
                decimal remindTime = db.SetCommand(strSelRemindTime
                                   , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                   , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteScalar<decimal>();

                if (remindTime > 0)//需要预约提醒
                {
                    string strAddPushPoolSql = @"INSERT INTO [TBL_PUSHPOOL]( BranchID ,ID ,SourceType ,SourceID ,PushTargetID ,PushType ,PushTime ,PushMessage ,PushStatus ,PhoneNumber ,PushPriority ,CompanyID ,CreatorID ,CreateTime,RecordType,PushTargetType,WeChatOpenID  )
                                                VALUES ( @BranchID ,@ID ,@SourceType ,@SourceID ,@PushTargetID ,@PushType ,@PushTime ,@PushMessage ,@PushStatus ,@PhoneNumber ,@PushPriority ,@CompanyID ,@CreatorID ,@CreateTime,1,@PushTargetType,@WeChatOpenID  )";

                    if (pushmodel != null && !string.IsNullOrWhiteSpace(pushmodel.DeviceID))
                    {
                        if (DateTime.Now.ToLocalTime().AddHours(StringUtils.GetDbDouble(remindTime)) < model.TaskScdlStartTime)
                        {
                            DateTime pushTime = model.TaskScdlStartTime.AddHours(StringUtils.GetDbDouble(remindTime * -1));
                            string pushMsg = "尊敬的" + pushmodel.CustomerName + "，您在" + pushmodel.CompanyName + "预约了服务，请准时到店享受服务。";

                            long pushPoolID = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "PUSHPOOL", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<long>();
                            if (pushPoolID <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }

                            int addPoolRes = db.SetCommand(strAddPushPoolSql
                                         , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                         , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                         , db.Parameter("@ID", pushPoolID, DbType.Int64)
                                         , db.Parameter("@SourceType", 1, DbType.Int32)//1：预约任务
                                         , db.Parameter("@SourceID", model.ID, DbType.Int64)
                                         , db.Parameter("@PushTargetID", pushmodel.CustomerID, DbType.Int32)
                                         , db.Parameter("@TargetUserType", 0, DbType.Int32)//0:customer 1:account
                                         , db.Parameter("@PushType", 1, DbType.Int32)//Push类型 1:系统Push 2:短消息
                                         , db.Parameter("@PushTime", pushTime, DbType.DateTime)
                                         , db.Parameter("@PushMessage", pushMsg, DbType.String)
                                         , db.Parameter("@PushStatus", 1, DbType.Int32)//1：待发送 2：已发送 3：已取消
                                         , db.Parameter("@PhoneNumber", DBNull.Value, DbType.String)
                                         , db.Parameter("@PushPriority", 1, DbType.Int32)
                                         , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                         , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)
                                         , db.Parameter("@PushTargetType", pushmodel.UserType, DbType.Int32)
                                         , db.Parameter("@WeChatOpenID", pushmodel.WeChatOpenID, DbType.String)).ExecuteNonQuery();
                        }

                    }
                }
                #endregion

                db.CommitTransaction();
                return 1;
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

                if (updateTaskRows != 1)
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
                    string strUpdateSchedlSql = @"UPDATE  [TBL_SCHEDULE]
                                            SET     ScheduleStatus = 4 ,
                                                    RecordType = 2 ,
                                                    UpdaterID = @UpdaterID ,
                                                    UpdateTime = @UpdateTime
                                            WHERE   TaskID = @TaskID
                                                    AND CompanyID = @CompanyID";
                    int updateRows = db.SetCommand(strUpdateSchedlSql
                                , db.Parameter("@UpdaterID", accountID, DbType.Int32)
                                , db.Parameter("@UpdateTime", dt, DbType.DateTime)
                                , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                , db.Parameter("@TaskID", taskID, DbType.Int64)).ExecuteNonQuery();

                    if (updateRows != 1)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                }

                string strDelPushPool = @"UPDATE TBL_PUSHPOOL SET PushStatus=3,RecordType=2  WHERE SourceID=@SourceID AND PushStatus=1";
                db.SetCommand(strDelPushPool, db.Parameter("@SourceID", taskID, DbType.Int64)).ExecuteNonQuery();

                #region 即时PUSH
                string strSelLoginSql = @" SELECT  T2.BranchName ,
                                                    T1.TaskScdlStartTime ,
                                                    T1.TaskName ,
                                                    CASE  WHEN T4.Name IS NULL THEN '到店指定' ELSE T4.Name END AS AccountName ,
                                                    T5.WeChatOpenID
                                            FROM    [TBL_TASK] T1 WITH ( NOLOCK )
                                                    LEFT JOIN [BRANCH] T2 WITH ( NOLOCK ) ON T1.BranchID = T2.ID
                                                    LEFT JOIN [TBL_SCHEDULE] T3 WITH ( NOLOCK ) ON T3.TaskID = T1.ID
                                                    LEFT JOIN [ACCOUNT] T4 WITH ( NOLOCK ) ON T4.UserID = T3.UserID
                                                    LEFT JOIN [CUSTOMER] T5 WITH ( NOLOCK ) ON T1.TaskOwnerID = T5.UserID
                                            WHERE   T1.ID = @TaskID
                                                    AND ISNULL(T5.WeChatOpenID, '') <> '' ";
                DataTable pushmodel = db.SetCommand(strSelLoginSql
                               , db.Parameter("@TaskID", taskID, DbType.Int64)).ExecuteDataTable();

                if (pushmodel != null)
                {
                    Task.Factory.StartNew(() =>
                    {
                        try
                        {
                            #region 微信push
                            string weChatOpenID = StringUtils.GetDbString(pushmodel.Rows[0]["WeChatOpenID"].ToString());
                            DateTime scheduleTime = StringUtils.GetDbDateTime(pushmodel.Rows[0]["TaskScdlStartTime"].ToString());
                            string branchName = StringUtils.GetDbString(pushmodel.Rows[0]["BranchName"].ToString());
                            string accountName = StringUtils.GetDbString(pushmodel.Rows[0]["AccountName"].ToString());

                            if (!string.IsNullOrEmpty(weChatOpenID))
                            {
                                string taskName = StringUtils.GetDbString(pushmodel.Rows[0]["TaskName"].ToString());
                                HS.Framework.Common.WeChat.WeChat we = new HS.Framework.Common.WeChat.WeChat();
                                string accessToken = we.GetWeChatToken(companyID);
                                if (!string.IsNullOrEmpty(accessToken))
                                {
                                    HS.Framework.Common.WeChat.Entity.MessageTemplate messageModel = new HS.Framework.Common.WeChat.Entity.MessageTemplate();
                                    HS.Framework.Common.WeChat.WXCompanyInfoBase WXCompanyInfoBase = we.GetBaseInfo(companyID);
                                    messageModel.template_id = WXCompanyInfoBase.AccountChangesTemplate;
                                    messageModel.topcolor = "#000000";
                                    messageModel.touser = weChatOpenID;
                                    messageModel.data = new HS.Framework.Common.WeChat.Entity.TemplateDetail()
                                    {
                                        first = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#FF0000", value = "您的预约已经取消\n" },
                                        keyword1 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = taskName },
                                        keyword2 = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = scheduleTime.ToString("yyyy-MM-dd HH:mm") },
                                        remark = new HS.Framework.Common.WeChat.Entity.TemplateDetailParameter() { color = "#000000", value = "预约门店：" + branchName + "\n预约顾问：" + accountName + "\n\n如有任何疑问，请及时与我们联系，欢迎再次预约服务。" }
                                    };

                                    we.TemplateMessageSend(messageModel, companyID, 3, accessToken);
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

                db.CommitTransaction();
                return 1;
            }
        }

        public int EditVisitTask(AddTaskOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSelTaskBasicSql = "SELECT TaskStatus FROM [TBL_TASK] WHERE CompanyID=@CompanyID AND ID=@TaskID AND TaskType<>1";

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
                    strUpdateSql += ", ExecuteEndTime = @ExecuteEndTime ";
                }
                strUpdateSql += " WHERE CompanyID=@CompanyID AND ID=@TaskID";

                int updateRes = db.SetCommand(strUpdateSql
                             , db.Parameter("@ExecuteStartTime", model.ExecuteStartTime, DbType.DateTime)
                             , db.Parameter("@ExecuteEndTime", model.ExecuteStartTime, DbType.DateTime)
                             , db.Parameter("@TaskResult", model.TaskResult, DbType.String)
                             , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                             , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime)
                             , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                             , db.Parameter("@TaskID", model.ID, DbType.Int64)).ExecuteNonQuery();

                if (updateRes != 1)
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
                    strUpdaterScheduleSql += ", ScheduleStatus = 3 ";
                    strUpdaterScheduleSql += ", ExecuteEndTime = @ExecuteEndTime ";
                }
                strUpdaterScheduleSql += " WHERE CompanyID=@CompanyID AND TaskID=@TaskID";

                updateRes = db.SetCommand(strUpdaterScheduleSql
                            , db.Parameter("@ExecuteStartTime", model.ExecuteStartTime, DbType.DateTime)
                            , db.Parameter("@ExecuteEndTime", model.ExecuteStartTime, DbType.DateTime)
                            , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                            , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime)
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                            , db.Parameter("@TaskID", model.ID, DbType.Int64)).ExecuteNonQuery();

                if (updateRes != 1)
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
                                            AND T1.TaskStatus = 2 ";

                list = db.SetCommand(strSql
                     , db.Parameter("CompanyID", companyID, DbType.Int32)
                     , db.Parameter("OrderID", orderID, DbType.Int32)
                     , db.Parameter("OrderObjectID", orderObjectID, DbType.Int32)).ExecuteList<TaskSimpleList_Model>();

                return list;
            }
        }
    }
}
