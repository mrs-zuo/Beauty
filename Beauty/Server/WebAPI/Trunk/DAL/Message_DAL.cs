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
using HS.Framework.Common.Util;

namespace WebAPI.DAL
{
    public class Message_DAL
    {
        #region 构造类实例
        public static Message_DAL Instance
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
            internal static readonly Message_DAL instance = new Message_DAL();
        }
        #endregion

        public List<GetContactList_Model> getContactListForAccount(int accountId, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"  select * from ( 
                                ( SELECT  T5.cnt AS NewMessageCount ,T1.UserID CustomerID ,T1.Name CustomerName ,T1.Available ,
                                        T3.MessageContent MessageContent ,CONVERT(VARCHAR(16), T2.SendTime, 20) SendTime,
                                        {0}{1}{2}{3}{4}  + cast(T1.CompanyID as nvarchar(10)) + {5}/{6}{7}  + cast(T1.UserID as nvarchar(10)) + '/'+ T1.HeadImageFile + {8} HeadImageURL 
                                        FROM  [CUSTOMER] T1 WITH(NOLOCK)
                                        LEFT JOIN [MESSAGE] T2 WITH(NOLOCK) 
                                        ON T1.UserID = ToUserID OR T1.UserID = FromUserID
                                        LEFT JOIN [MESSAGE_CONTENT] T3 WITH(NOLOCK) 
                                        ON T2.MessageContentID = T3.ID
                                        LEFT JOIN ( SELECT  T4.FromUserID ,COUNT(0) AS cnt
                                                    FROM    [MESSAGE] T4 WITH(NOLOCK)
                                                    WHERE   T4.ToUserID = @AccountID AND ReceiveTime IS NULL
                                                    GROUP BY T4.FromUserID) T5 
                                        ON T5.FromUserID = T2.FromUserID
                                        WHERE   T2.ID IN (
                                        SELECT  MAX(TABLETEMP.ID) AS MessageId
                                        FROM  ( 
                                        SELECT ToUserID ,MAX(ID) AS ID
                                        FROM [MESSAGE]
                                        WHERE ToUserID IN (
                                        SELECT  ToUserID
                                        FROM    [MESSAGE] WITH(NOLOCK)
                                        WHERE   FromUserID = @AccountID
                                        GROUP BY ToUserID )
                                        AND FromUserID = @AccountID
                                        GROUP BY  ToUserID
                                        UNION
                                        SELECT FromUserID , MAX(ID) AS MessageId
                                        FROM [MESSAGE]
                                        WHERE FromUserID IN (
                                        SELECT FromUserID
                                        FROM [MESSAGE] WITH(NOLOCK)
                                        WHERE ToUserID = @AccountID
                                        GROUP BY FromUserID )
                                        AND ToUserID = @AccountID
                                        GROUP BY FromUserID
                                        ) TABLETEMP
                                        GROUP BY TABLETEMP.ToUserID ) ) ) T6
                                        WHERE T6.Available = 1 OR ( T6.Available = 0 AND T6.MessageContent IS NOT NULL)
                                        ORDER BY T6.Available DESC ,T6.SendTime DESC ,T6.CustomerID  ";

                strSql = string.Format(strSql, Common.Const.strHttp,
                    Common.Const.server,
                    Common.Const.strMothod,
                    "",
                    Common.Const.strSingleMark,
                    Common.Const.strSingleMark,
                    Common.Const.strImageObjectType0,
                    Common.Const.strSingleMark,
                    Common.Const.strThumb);

                List<GetContactList_Model> list = db.SetCommand(strSql, db.Parameter("@AccountID", accountId, DbType.Int32)
                    , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                    , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<GetContactList_Model>();
                return list;
            }
        }

        public List<GetContactList_Model> getContactListForCustomer(int companyId, int customerId, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" ((select T6.cnt NewMessageCount,T1.UserID AccountID, T1.Name AccountName,T1.Available,CASE WHEN (CHARINDEX('|15|',T7.Jurisdictions)>0 OR T1.RoleID = -1) THEN 1 ELSE 0 END Chat_Use,T4.MessageContent MessageContent,CONVERT(varchar(16),T4.SendTime,20) SendTime,"
                    + Common.Const.strHttp + Common.Const.server + Common.Const.strMothod + Common.Const.strSingleMark
                    + "  + cast(T1.CompanyID as nvarchar(10)) + " + Common.Const.strSingleMark + "/" + Common.Const.strImageObjectType1 + Common.Const.strSingleMark
                    + "  + cast(T1.UserID as nvarchar(10)) + '/' + T1.HeadImageFile + " + Common.Const.strThumb
                    + @"HeadImageURL 
                            from ACCOUNT T1 
                            left join  
                            (select T3.ID,T3.MessageType,T8.MessageContent,T3.FromUserID,T3.ToUserID,CONVERT(varchar(16),T3.SendTime,20) SendTime  
                            from MESSAGE  T3 
                            left join MESSAGE_CONTENT T8 
                            on T3.MessageContentID =T8.ID  
                            WHERE T3.ID IN ( 
                            select max(T3.ID ) 
                            from MESSAGE T3 
                            where (T3.FromUserID = @CustomerId or ToUserID = @CustomerId ) 
                            group by (T3.FromUserID + T3.ToUserID + ABS(T3.FromUserID - T3.ToUserID))/2)) T4 
                            on T1.UserID = (T4.FromUserID + T4.ToUserID + ABS(T4.FromUserID - T4.ToUserID))/2 
                            left join ( 
                            select T5.FromUserID, COUNT(*) cnt  
                            from message T5 
                            where T5.ReceiveTime is null 
                            AND T5.FromUserID>= @CustomerId AND T5.ToUserID = @CustomerID 
                            GROUP BY T5.FromUserID) T6
                            on T1.UserID = T6.FromUserID 
                            LEFT JOIN dbo.TBL_ROLE  T7 WITH(NOLOCK) ON T1.RoleID =T7.ID 
                            LEFT JOIN dbo.TBL_ACCOUNTBRANCH_RELATIONSHIP  T8 WITH(NOLOCK) ON T1.UserID =T8.UserID AND T8.Available = 1 
                            where ( T8.BranchID IN (SELECT BranchID FROM dbo.RELATIONSHIP WHERE CustomerID =@CustomerID AND Available = 1) OR T1.UserID = T4.FromUserID OR T1.UserID =  T4.ToUserID)  
                            and T1.CompanyID = @CompanyID 
                            and T1.UserID>=@CustomerId   ) 
                            union 
                            (select T6.cnt NewMessageCount,T1.UserID AccountID, T1.Name AccountName, T1.Available,CASE WHEN (CHARINDEX('|15|',T7.Jurisdictions)>0 OR T1.RoleID = -1) THEN 1 ELSE 0 END Chat_Use,T4.MessageContent MessageContent,CONVERT(varchar(16),T4.SendTime,20) SendTime,  "
                    + Common.Const.strHttp + Common.Const.server + Common.Const.strMothod + Common.Const.strSingleMark
                    + "  + cast(T1.CompanyID as nvarchar(10)) + " + Common.Const.strSingleMark + "/" + Common.Const.strImageObjectType1 + Common.Const.strSingleMark
                    + "  + cast(T1.UserID as nvarchar(10)) + '/' + T1.HeadImageFile + " + Common.Const.strThumb
                    + @"HeadImage 
                            from ACCOUNT T1 
                            left join( 
                            select T3.ID,T3.MessageType,T8.MessageContent,T3.FromUserID,T3.ToUserID,CONVERT(varchar(16),T3.SendTime,20) SendTime 
                            from MESSAGE T3  
                            left join MESSAGE_CONTENT T8 
                            on T3.MessageContentID =T8.ID  
                            WHERE T3.ID IN ( 
                            select max(T3.ID) 
                            from MESSAGE T3 
                            where (T3.FromUserID = @CustomerId or ToUserID = @CustomerId) 
                            group by (T3.FromUserID + T3.ToUserID - ABS(T3.FromUserID - T3.ToUserID))/2)) T4 
                            on T1.UserID = (T4.FromUserID + T4.ToUserID - ABS(T4.FromUserID - T4.ToUserID))/2 
                            left join ( 
                            select T5.FromUserID, COUNT(*) cnt 
                            from message T5 
                            where T5.ReceiveTime is null 
                            AND T5.FromUserID < @CustomerId AND T5.ToUserID = @CustomerID  
                            GROUP BY T5.FromUserID) T6 
                            on T1.UserID = T6.FromUserID  
                            LEFT JOIN dbo.TBL_ROLE   T7 WITH(NOLOCK) ON T1.RoleID =T7.ID 
                            LEFT JOIN dbo.TBL_ACCOUNTBRANCH_RELATIONSHIP  T8 WITH(NOLOCK) ON T1.UserID =T8.UserID AND T8.Available = 1 
                            where ( T8.BranchID IN (SELECT BranchID FROM dbo.RELATIONSHIP WHERE CustomerID =@CustomerID AND Available = 1) OR T1.UserID = T4.FromUserID OR T1.UserID =  T4.ToUserID) 
                            and T1.CompanyID = @CompanyID 
                            and T1.UserID< @CustomerId  ) ) 
                            order by  T1.Available desc, T4.sendTime desc , T1.Name";

                List<GetContactList_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@CustomerID", customerId, DbType.Int32)
                    , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                    , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<GetContactList_Model>();
                return list;
            }
        }


        public List<AddMessage_Model> addMessage(Message_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();
                    string strSqlContent = @" INSERT INTO MESSAGE_CONTENT(CompanyID, MessageContent) 
                                            VALUES (@CompanyID, @MessageContent)
                                            ; select @@IDENTITY";

                    int contentId = db.SetCommand(strSqlContent, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@MessageContent", model.MessageContent, DbType.String)).ExecuteScalar<int>();

                    if (contentId <= 0)
                    {
                        db.RollbackTransaction();
                        return null;
                    }

                    string strSqlMessage = @" insert into MESSAGE(
                                            CompanyID, BranchID, MessageType,GroupFlag,FromUserID,ToUserID,MessageContentID,SendTime )
                                            values (
                                            @CompanyID, @BranchID, @MessageType,@GroupFlag,@FromUserID,@ToUserID,@MessageContentID,@SendTime)
                                            ; select @@IDENTITY ";

                    List<AddMessage_Model> list = new List<AddMessage_Model>();

                    foreach (int item in model.listToUserID)
                    {
                        int messageId = db.SetCommand(strSqlMessage, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                        , db.Parameter("@MessageType", model.MessageType, DbType.Int32)
                        , db.Parameter("@GroupFlag", model.GroupFlag, DbType.Boolean)
                        , db.Parameter("@FromUserID", model.FromUserID, DbType.Int32)
                        , db.Parameter("@ToUserID", item, DbType.Int32)
                        , db.Parameter("@MessageContentID", contentId, DbType.Int32)
                        , db.Parameter("@SendTime", model.SendTime, DbType.DateTime2)).ExecuteScalar<int>();

                        if (messageId <= 0)
                        {
                            db.RollbackTransaction();
                            return null;
                        }
                        else
                        {
                            AddMessage_Model mTemp = new AddMessage_Model();
                            mTemp.NewMessageID = messageId;
                            list.Add(mTemp);
                        }
                    }
                    db.CommitTransaction();
                    return list;
                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }


        /// <summary>
        /// 取得接受者的DeviceID
        /// </summary>
        /// <param name="toUserId"></param>
        /// <returns></returns>
        public List<PushMessage_Model> getDeviceToken(List<int> listToUserId)
        {
            using (DbManager db = new DbManager())
            {
                string strWhere = "";
                foreach (int toUserId in listToUserId)
                {
                    if (strWhere != "")
                    {
                        strWhere += " ,";
                    }
                    strWhere += toUserId.ToString();
                }


                string strSql = @" SELECT T1.DeviceID ,T1.DeviceType,T2.UserType from LOGIN  T1 
                                    left join [USER] T2 on T2.ID = T1.UserID 
                                    WHERE T1.UserID IN ( "
                                + strWhere + ")";

                List<PushMessage_Model> list = db.SetCommand(strSql).ExecuteList<PushMessage_Model>();
                return list;
            }
        }

        public List<GetMessageList_Model> getRealTimeMsg(int fromUserId, int toUserId, int messageId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"select T1.ID MessageID,T2.MessageContent,CONVERT(varchar(16),SendTime,20) SendTime, T1.FromUserID
                                    from MESSAGE T1 
                                    left join MESSAGE_CONTENT T2 
                                    on T1.MessageContentID =T2.ID  
                                    where T1.FromUserID = @FromUserID and T1.ToUserID = @ToUserID AND T1.ID > @ID 
                                    Order By T1.ID ";

                List<GetMessageList_Model> list = db.SetCommand(strSql, db.Parameter("@FromUserID", fromUserId, DbType.Int32)
                    , db.Parameter("@ToUserID", toUserId, DbType.Int32)
                    , db.Parameter("@ID", messageId.ToString(), DbType.Int32)).ExecuteList<GetMessageList_Model>();

                return list;
            }
        }

        public bool receiveMsg(int fromUserId, int toUserId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"update MESSAGE set 
                                        ReceiveTime=@ReceiveTime 
                                        where ReceiveTime is null 
                                        and (FromUserID = @FromUserID 
                                        and ToUserID = @ToUserID) ";

                int rows = db.SetCommand(strSql, db.Parameter("@ReceiveTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                    , db.Parameter("@FromUserID", fromUserId, DbType.Int32)
                    , db.Parameter("@ToUserID", toUserId.ToString(), DbType.Int32)).ExecuteNonQuery();

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


        public List<GetMessageList_Model> getNewMessageForMarketingByCompanyID(int companyId, int messageId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"select T1.FromUserID, T3.Name FromUserName, T2.MessageID, T6.MessageContent,CONVERT(varchar(16),T1.SendTime,20) SendTime, T4.SendCount, T5.ReceiveCount,T1.MessageContentID from MESSAGE T1 
                                    left join (select  MessageContentID,MAX(ID) MessageID from MESSAGE T1 where T1.CompanyID = @CompanyID and T1.ID > @NewerThanMessageID and T1.MessageType = 1 group by MessageContentID) T2 
                                    on T2.MessageContentID = T1.MessageContentID 
                                    left join ACCOUNT T3 on T3.UserID = T1.FromUserID
                                    left join (select MessageContentID, COUNT(*) SendCount from MESSAGE where CompanyID = @CompanyID and ID > @NewerThanMessageID and MessageType = 1 group by MessageContentID ) T4 
                                    on T4.MessageContentID = T1.MessageContentID
                                    left join (select MessageContentID, COUNT(*) ReceiveCount from MESSAGE where CompanyID = @CompanyID and ID > @NewerThanMessageID and MessageType = 1 and ReceiveTime is not null group by MessageContentID ) T5 
                                    on T5.MessageContentID = T1.MessageContentID
                                    left join MESSAGE_CONTENT T6 on T6.ID = T1.MessageContentID
                                    where T1.CompanyID = @CompanyID and T1.MessageType = 1 and T1.ID > @NewerThanMessageID
                                    group by T1.FromUserID, T3.Name, T4.SendCount, T5.ReceiveCount, T2.MessageID, T6.MessageContent,T1.SendTime,T1.MessageContentID
                                    order by T2.MessageID desc ";

                List<GetMessageList_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@NewerThanMessageID", messageId, DbType.Int32)).ExecuteList<GetMessageList_Model>();

                return list;
            }
        }

        public List<GetMessageList_Model> getNewMessageForMarketingByBranchID(int branchId, int messageId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select  T1.FromUserID, T3.Name FromUserName, T2.MessageID, T6.MessageContent,CONVERT(varchar(16),T1.SendTime,20) SendTime, T4.SendCount, T5.ReceiveCount,T1.MessageContentID from MESSAGE T1 
                                    left join (select  MessageContentID,MAX(ID) MessageID from MESSAGE T1 where T1.BranchID = @BranchID and T1.ID > @NewerThanMessageID and T1.MessageType = 1 group by MessageContentID) T2 
                                    on T2.MessageContentID = T1.MessageContentID
                                    left join ACCOUNT T3 on T3.UserID = T1.FromUserID
                                    left join (select MessageContentID, COUNT(*) SendCount from MESSAGE where BranchID = @BranchID and ID > @NewerThanMessageID and MessageType = 1 group by MessageContentID ) T4 
                                    on T4.MessageContentID = T1.MessageContentID
                                    left join (select MessageContentID, COUNT(*) ReceiveCount from MESSAGE where BranchID = @BranchID and ID > @NewerThanMessageID and MessageType = 1 and ReceiveTime is not null group by MessageContentID ) T5
                                    on T5.MessageContentID = T1.MessageContentID
                                    left join MESSAGE_CONTENT T6 on T6.ID = T1.MessageContentID
                                    where T1.BranchID = @BranchID and T1.MessageType = 1 and T1.ID > @NewerThanMessageID
                                    group by T1.FromUserID, T3.Name, T4.SendCount, T5.ReceiveCount, T2.MessageID, T6.MessageContent,T1.SendTime,T1.MessageContentID
                                    order by T2.MessageID desc";

                List<GetMessageList_Model> list = db.SetCommand(strSql, db.Parameter("@BranchID", branchId, DbType.Int32)
                    , db.Parameter("@NewerThanMessageID", messageId, DbType.Int32)).ExecuteList<GetMessageList_Model>();

                return list;
            }
        }


        /// <summary>
        /// 取得接受营销消息的用户信息
        /// </summary>
        /// <param name="MessageContentID"></param>
        /// <returns></returns>
        public List<string> getAcceptMarketingMessageCustomerName(int messageContentId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select T2.Name ToUserName 
                                    from MESSAGE T1 join CUSTOMER T2
                                    on T1.ToUserID = T2.UserID
                                    where T1.MessageContentID = @MessageContentID
                                    and T1.MessageType = 1 ";

                List<string> list = db.SetCommand(strSql, db.Parameter("@MessageContentID", messageContentId, DbType.Int32)).ExecuteScalarList<string>();

                return list;
            }
        }

        public MessageCount_Model getMsgCount(int toUserId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select Count(*) NewMessageCount from Message  T1 
                                        where ToUserID = @ToUserID 
                                        AND ReceiveTime is NULL ";

                MessageCount_Model model = db.SetCommand(strSql, db.Parameter("@ToUserID", toUserId, DbType.Int32)).ExecuteObject<MessageCount_Model>();

                return model;
            }
        }


        /// <summary>
        /// 取得单个联系人未读的消息
        /// </summary>
        /// <param name="fromUserId"></param>
        /// <param name="toUserId"></param>
        /// <returns></returns>
        public List<int> getMsgWithNoReceive(int fromUserId, int toUserId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select T1.ID MessageID
                                    from MESSAGE T1 
                                    left join MESSAGE_CONTENT T2 
                                    on T1.MessageContentID =T2.ID 
                                    where (FromUserID = @FromUserID and ToUserID = @ToUserID) AND ReceiveTime is null 
                                    Order By T1.ID";

                List<int> list = db.SetCommand(strSql, db.Parameter("@FromUserID", fromUserId, DbType.Int32)
                    , db.Parameter("@ToUserID", toUserId, DbType.Int32)).ExecuteScalarList<int>();

                return list;
            }
        }

        public List<GetMessageList_Model> getMsgByLastId(int fromUserId, int toUserId, int messageId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select T1.ID MessageID,T2.MessageContent,CONVERT(varchar(16),SendTime,20) SendTime,T1.FromUserID
                                   from MESSAGE T1
                                   left join MESSAGE_CONTENT T2 
                                   on T1.MessageContentID =T2.ID  
                                   where ((T1.FromUserID = @FromUserID and T1.ToUserID = @ToUserID) 
                                   OR (T1.ToUserID = @FromUserID and T1.FromUserID =@ToUserID )) AND T1.ID >= @ID 
                                   Order By T1.ID";

                List<GetMessageList_Model> list = db.SetCommand(strSql, db.Parameter("@FromUserID", fromUserId, DbType.Int32)
                    , db.Parameter("@ToUserID", toUserId, DbType.Int32)
                    , db.Parameter("@ID", messageId, DbType.Int32)).ExecuteList<GetMessageList_Model>();

                return list;
            }
        }

        public List<GetMessageList_Model> getMsgByLastTen(int fromUserId, int toUserId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select T1.ID MessageID,T2.MessageContent,CONVERT(varchar(16),SendTime,20) SendTime,T1.FromUserID
                                   from MESSAGE T1 
                                   left join MESSAGE_CONTENT T2 
                                   on T1.MessageContentID =T2.ID 
                                   Where T1.ID in (
                                   select top 10 ID from MESSAGE 
                                   where (FromUserID = @FromUserID and ToUserID = @ToUserID) 
                                   or (ToUserID = @FromUserID and FromUserID =@ToUserID ) 
                                   Order  by ID desc) 
                                   Order By T1.ID";

                List<GetMessageList_Model> list = db.SetCommand(strSql, db.Parameter("@FromUserID", fromUserId, DbType.Int32)
                    , db.Parameter("@ToUserID", toUserId, DbType.Int32)).ExecuteList<GetMessageList_Model>();

                return list;
            }
        }



        public List<GetMessageList_Model> getHistoryMsg(int accountId, int customerId, int messageId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select T2.ID MessageID,T2.MessageContent,CONVERT(varchar(16),T2.SendTime,20) SendTime, T2.FromUserID
                                    from (select TOP 10 T1.ID ID, T3.MessageContent MessageContent,CONVERT(varchar(16),T1.SendTime,20) SendTime, T1.FromUserID, T1.ToUserID 
                                    from MESSAGE T1 
                                    left join MESSAGE_CONTENT T3 
                                    on T1.MessageContentID =T3.ID 
                                    where ((T1.FromUserID = @AccountId and T1.ToUserID = @CustomerId) 
                                    OR (T1.ToUserID = @AccountId and T1.FromUserID =@CustomerId )) AND T1.ID < @ID 
                                    Order By ID desc ) T2 Order By ID";

                List<GetMessageList_Model> list = db.SetCommand(strSql, db.Parameter("@AccountId", accountId, DbType.Int32)
                    , db.Parameter("@CustomerId", customerId, DbType.Int32)
                     , db.Parameter("@ID", messageId, DbType.Int32)).ExecuteList<GetMessageList_Model>();

                return list;
            }
        }

        public List<GetMessageList_Model> getHistoryMessageForMarketingFirstTime(int companyId, int branchId, DateTime sendTime, int selectCount)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select top (@SelectCount) T1.FromUserID, T3.Name FromUserName, T2.MessageID, T6.MessageContent,CONVERT(varchar(16),T1.SendTime,20) SendTime, T4.SendCount, T5.ReceiveCount,T1.MessageContentID from MESSAGE T1 
                                    left join (select  MessageContentID,MAX(ID) MessageID from MESSAGE T1 where T1.CompanyID = @CompanyID {0} and T1.SendTime < @SendTime and T1.MessageType = 1 group by MessageContentID) T2 
                                    on T2.MessageContentID = T1.MessageContentID 
                                    left join ACCOUNT T3 on T3.UserID = T1.FromUserID
                                    left join (select MessageContentID, COUNT(*) SendCount from MESSAGE where CompanyID = @CompanyID {1} and SendTime < @SendTime and MessageType = 1 group by MessageContentID ) T4 
                                    on T4.MessageContentID = T1.MessageContentID
                                    left join (select MessageContentID, COUNT(*) ReceiveCount from MESSAGE where CompanyID = @CompanyID {2} and SendTime < @SendTime and MessageType = 1 and ReceiveTime is not null group by MessageContentID ) T5
                                    on T5.MessageContentID = T1.MessageContentID
                                    left join MESSAGE_CONTENT T6 on T6.ID = T1.MessageContentID
                                    where T1.CompanyID = @CompanyID {3} and T1.MessageType = 1 and T1.SendTime < @SendTime
                                    group by T1.FromUserID, T3.Name, T4.SendCount, T5.ReceiveCount, T2.MessageID, T6.MessageContent,T1.SendTime,T1.MessageContentID
                                    order by T2.MessageID desc";


                if (branchId == 0)
                {
                    strSql = string.Format(strSql, "", "", "", "");
                }
                else
                {
                    strSql = string.Format(strSql, " AND T1.BranchID = @BranchID ", " AND BranchID = @BranchID ", " AND BranchID = @BranchID ", " AND T1.BranchID = @BranchID ");
                }

                List<GetMessageList_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@BranchID", branchId, DbType.Int32)
                     , db.Parameter("@SelectCount", selectCount, DbType.Int32)
                     , db.Parameter("@SendTime", sendTime, DbType.DateTime)).ExecuteList<GetMessageList_Model>();

                return list;
            }
        }

        public List<GetMessageList_Model> getHistoryMessageForMarketing(int companyId, int branchId, int messageId, int selectCount)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select top (@SelectCount) T1.FromUserID, T3.Name FromUserName, T2.MessageID, T6.MessageContent,CONVERT(varchar(16),T1.SendTime,20) SendTime, T4.SendCount, T5.ReceiveCount,T1.MessageContentID from MESSAGE T1 
                                       left join (select  MessageContentID,MAX(ID) MessageID from MESSAGE T1 where T1.CompanyID = @CompanyID {0} and T1.ID < @OlderThanMessageID and T1.MessageType = 1 group by MessageContentID) T2 
                                       on T2.MessageContentID = T1.MessageContentID 
                                       left join ACCOUNT T3 on T3.UserID = T1.FromUserID
                                       left join (select MessageContentID, COUNT(*) SendCount from MESSAGE where CompanyID = @CompanyID {1} and ID < @OlderThanMessageID and MessageType = 1 group by MessageContentID ) T4 
                                       on T4.MessageContentID = T1.MessageContentID
                                       left join (select MessageContentID, COUNT(*) ReceiveCount from MESSAGE where CompanyID = @CompanyID {2} and ID < @OlderThanMessageID and MessageType = 1 and ReceiveTime is not null group by MessageContentID ) T5
                                       on T5.MessageContentID = T1.MessageContentID
                                       left join MESSAGE_CONTENT T6 on T6.ID = T1.MessageContentID
                                       where T1.CompanyID = @CompanyID {3} and T1.MessageType = 1 and T1.ID < @OlderThanMessageID
                                       group by T1.FromUserID, T3.Name, T4.SendCount, T5.ReceiveCount, T2.MessageID, T6.MessageContent,T1.SendTime,T1.MessageContentID
                                       order by T2.MessageID desc";
                if (branchId == 0)
                {
                    strSql = string.Format(strSql, "", "", "", "");
                }
                else
                {
                    strSql = string.Format(strSql, " AND T1.BranchID = @BranchID ", " AND BranchID = @BranchID ", " AND BranchID = @BranchID ", " AND T1.BranchID = @BranchID ");
                }

                List<GetMessageList_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@BranchID", branchId, DbType.Int32)
                     , db.Parameter("@SelectCount", selectCount, DbType.Int32)
                     , db.Parameter("@OlderThanMessageID", messageId, DbType.Int32)).ExecuteList<GetMessageList_Model>();

                return list;
            }
        }

        public List<GetMessageList_Model> getMessageForMarketing(int companyID, int branchID, int accountID, DateTime sendTime, int pageSize, int pageIndex, out int recordCount)
        {
            using (DbManager db = new DbManager())
            {

                List<GetMessageList_Model> list = new List<GetMessageList_Model>();
                string fileds = @" ROW_NUMBER() OVER ( ORDER BY T2.MessageID DESC ) AS rowNum ,
                                                  T1.FromUserID ,T3.Name FromUserName ,T2.MessageID ,T6.MessageContent ,
                                                   CONVERT(VARCHAR(16), T1.SendTime, 20) SendTime ,T4.SendCount ,T5.ReceiveCount ,T1.MessageContentID ";
                string strSql = @"SELECT {0}
                                 FROM   MESSAGE T1
                                        LEFT JOIN ( SELECT  MessageContentID ,
                                                            MAX(ID) MessageID
                                                    FROM    MESSAGE T1
                                                    WHERE   T1.FromUserID = @AccountID AND T1.SendTime < @SendTime AND T1.MessageType = 1
                                                    GROUP BY MessageContentID
                                                  ) T2 ON T2.MessageContentID = T1.MessageContentID
                                        LEFT JOIN ACCOUNT T3 ON T3.UserID = T1.FromUserID
                                        LEFT JOIN ( SELECT  MessageContentID ,
                                                            COUNT(*) SendCount
                                                    FROM    MESSAGE
                                                    WHERE   FromUserID = @AccountID AND SendTime < @SendTime AND MessageType = 1
                                                    GROUP BY MessageContentID
                                                  ) T4 ON T4.MessageContentID = T1.MessageContentID
                                        LEFT JOIN ( SELECT  MessageContentID ,
                                                            COUNT(*) ReceiveCount
                                                    FROM    MESSAGE
                                                    WHERE   FromUserID = @AccountID AND SendTime < @SendTime AND MessageType = 1 AND ReceiveTime IS NOT NULL
                                                    GROUP BY MessageContentID
                                                  ) T5 ON T5.MessageContentID = T1.MessageContentID
                                        LEFT JOIN MESSAGE_CONTENT T6 ON T6.ID = T1.MessageContentID
                                 WHERE  T1.FromUserID = @AccountID
                                        AND T1.MessageType = 1 AND T1.SendTime < @SendTime AND T1.CompanyID=@CompanyID";
                if (branchID > 0)
                {
                    strSql += " AND T1.BranchID=@BranchID ";
                }
                strSql += @" GROUP BY T1.FromUserID ,
                                    T3.Name ,T4.SendCount , T5.ReceiveCount , T2.MessageID ,
                                    T6.MessageContent , T1.SendTime ,T1.MessageContentID";

                string strCountSql = "SELECT COUNT(0) FROM ( " + string.Format(strSql, " T1.FromUserID ") + " ) T1";

                string strgetListSql = "select * from( " + string.Format(strSql, fileds) + " ) a where  rowNum between  " + ((pageIndex - 1) * pageSize + 1) + " and " + pageIndex * pageSize;

                recordCount = db.SetCommand(strCountSql, db.Parameter("@AccountID", accountID, DbType.Int32)
                                                       , db.Parameter("@BranchID", branchID, DbType.Int32)
                                                       , db.Parameter("@SendTime", sendTime, DbType.DateTime)
                                                       , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalar<int>();

                if (recordCount < 0)
                {
                    return null;
                }

                list = db.SetCommand(strgetListSql, db.Parameter("@AccountID", accountID, DbType.Int32)
                                                  , db.Parameter("@BranchID", branchID, DbType.Int32)
                                                  , db.Parameter("@SendTime", sendTime, DbType.DateTime)
                                                  , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<GetMessageList_Model>();
                return list;
            }
        }

        public List<GetMessageList_Model> getMessageForMarketingForManager(int companyID, int accountID, DateTime sendTime, int pageSize, int pageIndex, out int recordCount)
        {
            using (DbManager db = new DbManager())
            {

                List<GetMessageList_Model> list = new List<GetMessageList_Model>();
                string fileds = @" ROW_NUMBER() OVER ( ORDER BY T2.MessageID DESC ) AS rowNum ,
                                                  T1.FromUserID ,T3.Name FromUserName ,T2.MessageID ,T6.MessageContent ,
                                                   CONVERT(VARCHAR(16), T1.SendTime, 20) SendTime ,T4.SendCount ,T5.ReceiveCount ,T1.MessageContentID ";
                string strSql = @"SELECT {0}
                                 FROM   MESSAGE T1
                                        LEFT JOIN ( SELECT  MessageContentID ,
                                                            MAX(ID) MessageID
                                                    FROM    MESSAGE T1
                                                    WHERE   T1.FromUserID = @AccountID AND T1.SendTime < @SendTime AND T1.MessageType = 1
                                                    GROUP BY MessageContentID
                                                  ) T2 ON T2.MessageContentID = T1.MessageContentID
                                        LEFT JOIN ACCOUNT T3 ON T3.UserID = T1.FromUserID
                                        LEFT JOIN ( SELECT  MessageContentID ,
                                                            COUNT(*) SendCount
                                                    FROM    MESSAGE
                                                    WHERE   FromUserID = @AccountID AND SendTime < @SendTime AND MessageType = 1
                                                    GROUP BY MessageContentID
                                                  ) T4 ON T4.MessageContentID = T1.MessageContentID
                                        LEFT JOIN ( SELECT  MessageContentID ,
                                                            COUNT(*) ReceiveCount
                                                    FROM    MESSAGE
                                                    WHERE   FromUserID = @AccountID AND SendTime < @SendTime AND MessageType = 1 AND ReceiveTime IS NOT NULL
                                                    GROUP BY MessageContentID
                                                  ) T5 ON T5.MessageContentID = T1.MessageContentID
                                        LEFT JOIN MESSAGE_CONTENT T6 ON T6.ID = T1.MessageContentID
                                 WHERE  T1.FromUserID = @AccountID
                                        AND T1.MessageType = 1 AND T1.SendTime < @SendTime AND T1.CompanyID=@CompanyID
                                 GROUP BY T1.FromUserID ,
                                        T3.Name ,T4.SendCount , T5.ReceiveCount , T2.MessageID ,
                                        T6.MessageContent , T1.SendTime ,T1.MessageContentID";

                string strCountSql = "SELECT COUNT(0) FROM ( " + string.Format(strSql, " T1.FromUserID ") + " ) T1";

                string strgetListSql = "select * from( " + string.Format(strSql, fileds) + " ) a where  rowNum between  " + ((pageIndex - 1) * pageSize + 1) + " and " + pageIndex * pageSize;

                recordCount = db.SetCommand(strCountSql, db.Parameter("@AccountID", accountID, DbType.Int32)
                                                       , db.Parameter("@SendTime", sendTime, DbType.DateTime)
                                                       , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalar<int>();

                if (recordCount < 0)
                {
                    return null;
                }

                list = db.SetCommand(strgetListSql, db.Parameter("@AccountID", accountID, DbType.Int32)
                                                  , db.Parameter("@SendTime", sendTime, DbType.DateTime)
                                                  , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<GetMessageList_Model>();
                return list;
            }
        }
    }
}
