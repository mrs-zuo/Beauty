using BLToolkit.Data;
using HS.Framework.Common;
using HS.Framework.Common.Push;
using HS.Framework.Common.WeChat;
using HS.Framework.Common.WeChat.Entity;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using WebAPI.Common;

namespace WebAPI.DAL
{
    public class PushTool_DAL
    {
        #region 构造类实例
        public static PushTool_DAL Instance
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
            internal static readonly PushTool_DAL instance = new PushTool_DAL();
        }
        #endregion


        public void getPushPoolList()
        {
            System.Diagnostics.StackTrace st = new System.Diagnostics.StackTrace(1, true);
            string strPgm;  //当前的程序名称及行号等监察信息

            using (DbManager db = new DbManager())
            {
                string strSql = @" select Top 20 T1.ID,T1.SourceID,T1.PushType,T1.PushMessage,T1.PhoneNumber,T2.DeviceID,T2.DeviceType,T1.PushTargetType,T1.WeChatOpenID ,T1.CompanyID,T3.TaskName,T3.TaskScdlStartTime
                                from [TBL_PUSHPOOL] T1 with (nolock)
								INNER JOIN [LOGIN] T2 ON T1.PushTargetID = T2.UserID
								LEFT JOIN [TBL_TASK] T3 ON T1.SourceID = T3.ID
                                where T1.PushStatus = 1 and T1.PushTime <= GETDATE() and T1.RecordType = 1 and T2.DeviceID IS NOT NULL AND T2.DeviceID <> ''
                                order by T1.PushPriority desc
";

                List<GetPushPoolList_Model> list = db.SetCommand(strSql).ExecuteList<GetPushPoolList_Model>();


                if (list != null && list.Count > 0)
                {
                        foreach (GetPushPoolList_Model item in list)
                        {
                            try
                            {
                                switch (item.PushType)
                                {
                                    case 1:
                                        try
                                        {
                                            HSPush.pushMsg(item.DeviceID, item.DeviceType, item.PushTargetType, item.PushMessage);
                                        }
                                        catch
                                        {
                                            LogUtil.Log("push失败", "pushID为" + item.ID + "推送失败");                                            
                                        }
                                        break;
                                    case 2:
                                        try
                                        {
                                            if (!string.IsNullOrWhiteSpace(item.PhoneNumber))
                                            {
                                                strPgm = st.GetFrame(0).GetMethod().Name + "(" + st.GetFrame(0).GetFileLineNumber().ToString() + ")";
                                                int result = SMSInfo_DAL.Instance.getSMSInfo(0, item.PhoneNumber, strPgm, 0);
                                                if (result == 0)
                                                {
                                                    SendShortMessage.sendShortMessageForTask(item.PhoneNumber, item.PushMessage);
                                                    //保存短信发送履历信息
                                                    strPgm = st.GetFrame(0).GetMethod().Name + "(" + st.GetFrame(0).GetFileLineNumber().ToString() + ")";
                                                    SMSInfo_DAL.Instance.addSMSHis(0, 0, item.PhoneNumber, item.PushMessage, strPgm, 0);
                                                }
                                            }
                                        }
                                        catch
                                        {
                                            LogUtil.Log("发送短消息失败", "pushID为" + item.ID + "发送短消息失败");                                            
                                        }
                                        break;
                                }

                                if (!string.IsNullOrEmpty(item.WeChatOpenID))
                                {
                                    WeChat wx = new WeChat();
                                    string token = wx.GetWeChatToken(item.CompanyID);
                                    if (!string.IsNullOrEmpty(token))
                                    {
                                        MessageTemplate template = new MessageTemplate();
                                        template.touser = item.WeChatOpenID;
                                        template.url = null;
                                        template.data = new TemplateDetail();
                                        template.data.first = new TemplateDetailParameter() { value = item.PushMessage, color = "" };
                                        template.data.keyword1 = new TemplateDetailParameter() { value = item.TaskName, color = "" };
                                        template.data.keyword2 = new TemplateDetailParameter() { value = item.TaskScdlStartTime.ToString("yyyy-MM-dd HH:mm"), color = "" };
                                        template.data.remark = new TemplateDetailParameter() { value = "", color = "" };
                                        wx.TemplateMessageSend(template, item.CompanyID, 3, token);
                                    }
                                }

                                string strSqlUpdate = @" Update [TBL_PUSHPOOL]
                                                            set PushStatus = 2         
                                                            where ID=@PushID ";

                                int rows = db.SetCommand(strSqlUpdate, db.Parameter("@PushID", item.ID, DbType.Int64)).ExecuteNonQuery();

                                if (rows == 0)
                                {
                                    LogUtil.Log("更新失败", "pushID为" + item.ID + "更新失败");
                                }

                                Thread.Sleep(1000);


                            }
                            catch (Exception ex)
                            {
                                LogUtil.Error(ex);
                                LogUtil.Log("push失败", "pushID为" + item.ID + "推送失败");
                                continue;
                            }
                        }

                }
                else
                {
                    LogUtil.Log("", "暂时没有推送任务");
                }
            }
        }


    }
}
