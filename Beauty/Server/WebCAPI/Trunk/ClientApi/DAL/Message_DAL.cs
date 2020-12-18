using BLToolkit.Data;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.DAL
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

        public List<GetContactList_Model> getContactListForCustomer(int companyId, int customerId, int imageWidth, int imageHeight)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" ((select T6.cnt NewMessageCount,T1.UserID AccountID,case 
when 
	(CHARINDEX('|50|',T7.Jurisdictions)>0) and   (CHARINDEX('|49|',T7.Jurisdictions)=0)
then 
	--名字
	T1.Name
when 
	(CHARINDEX('|50|',T7.Jurisdictions)>0) and   (CHARINDEX('|49|',T7.Jurisdictions)>0)
then 
	--名字加职位
	case when T1.Title = '' or T1.Title is null then '' when T1.Title is not null then T1.Title + ' ' end + T1.Name 
else 
	--职位，职位为空显示名字
	case when T1.Title = '' or T1.Title is null then T1.name when T1.Title is not null then T1.Title end end  AccountName,T1.Available,CASE WHEN (CHARINDEX('|15|',T7.Jurisdictions)>0 OR T1.RoleID = -1) THEN 1 ELSE 0 END Chat_Use,T4.MessageContent MessageContent,CONVERT(varchar(16),T4.SendTime,20) SendTime,"
                    + WebAPI.Common.Const.strHttp + WebAPI.Common.Const.server + WebAPI.Common.Const.strMothod + WebAPI.Common.Const.strSingleMark
                    + "  + cast(T1.CompanyID as nvarchar(10)) + " + WebAPI.Common.Const.strSingleMark + "/" + WebAPI.Common.Const.strImageObjectType1 + WebAPI.Common.Const.strSingleMark
                    + "  + cast(T1.UserID as nvarchar(10)) + '/' + T1.HeadImageFile + " + WebAPI.Common.Const.strThumb
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
                            and T1.UserID>=@CustomerId  and T1.Available = 1  ) 
                            union 
                            (select T6.cnt NewMessageCount,T1.UserID AccountID, case 
when 
	(CHARINDEX('|50|',T7.Jurisdictions)>0) and   (CHARINDEX('|49|',T7.Jurisdictions)=0)
then 
	--名字
	T1.Name
when 
	(CHARINDEX('|50|',T7.Jurisdictions)>0) and   (CHARINDEX('|49|',T7.Jurisdictions)>0)
then 
	--名字加职位
	case when T1.Title = '' or T1.Title is null then '' when T1.Title is not null then T1.Title + ' ' end + T1.Name 
else 
	--职位，职位为空显示名字
	case when T1.Title = '' or T1.Title is null then T1.name when T1.Title is not null then T1.Title end end  AccountName, T1.Available,CASE WHEN (CHARINDEX('|15|',T7.Jurisdictions)>0 OR T1.RoleID = -1) THEN 1 ELSE 0 END Chat_Use,T4.MessageContent MessageContent,CONVERT(varchar(16),T4.SendTime,20) SendTime,  "
                    + WebAPI.Common.Const.strHttp + WebAPI.Common.Const.server + WebAPI.Common.Const.strMothod + WebAPI.Common.Const.strSingleMark
                    + "  + cast(T1.CompanyID as nvarchar(10)) + " + WebAPI.Common.Const.strSingleMark + "/" + WebAPI.Common.Const.strImageObjectType1 + WebAPI.Common.Const.strSingleMark
                    + "  + cast(T1.UserID as nvarchar(10)) + '/' + T1.HeadImageFile + " + WebAPI.Common.Const.strThumb
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
                            and T1.UserID< @CustomerId   and T1.Available = 1 ) ) 
                            order by  T1.Available desc, T4.sendTime desc ";

                List<GetContactList_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@CustomerID", customerId, DbType.Int32)
                    , db.Parameter("@ImageHeight", imageHeight.ToString(), DbType.String)
                    , db.Parameter("@ImageWidth", imageWidth.ToString(), DbType.String)).ExecuteList<GetContactList_Model>();
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


    }
}
