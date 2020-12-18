using ClientAPI.DAL;
using HS.Framework.Common.Push;
using HS.Framework.Common.Util;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.BLL
{
   public class Message_BLL
    {
        #region 构造类实例
        public static Message_BLL Instance
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
            internal static readonly Message_BLL instance = new Message_BLL();
        }
        #endregion
     

       public List<GetContactList_Model> getContactListForCustomer(int companyId, int customerId, int imageWidth, int imageHeight)
       {
           return Message_DAL.Instance.getContactListForCustomer(companyId, customerId, imageWidth, imageHeight);
       }


       public List<GetMessageList_Model> getRealTimeMsg(int fromUserId, int toUserId, int messageId)
       {
           List<GetMessageList_Model> list = Message_DAL.Instance.getRealTimeMsg(fromUserId, toUserId, messageId);
           foreach (GetMessageList_Model item in list)
           {
               if (item.FromUserID == fromUserId)
               {
                   item.SendOrReceiveFlag = 0;//表示该信息由FromUserID接受
               }
               else if (item.FromUserID == toUserId)
               {
                   item.SendOrReceiveFlag = 1;//表示该信息由FromUserID发送
               }
           }
           return list;
       }

       public bool receiveMsg(int fromUserId, int toUserId)
       {
           return Message_DAL.Instance.receiveMsg(fromUserId, toUserId);
       }

       public List<int> getMsgWithNoReceive(int fromUserId, int toUserId)
       {
           return Message_DAL.Instance.getMsgWithNoReceive(fromUserId, toUserId);
       }

       public List<GetMessageList_Model> getMsgByLastTen(int fromUserId, int toUserId)
       {
           return Message_DAL.Instance.getMsgByLastTen(fromUserId, toUserId);
       }

       public List<GetMessageList_Model> getMsgByLastId(int fromUserId, int toUserId, int messageId)
       {
           return Message_DAL.Instance.getMsgByLastId(fromUserId, toUserId, messageId);
       }

       public List<GetMessageList_Model> getHistoryMsg(int accountId, int customerId, int messageId)
       {
           return Message_DAL.Instance.getHistoryMsg(accountId, customerId, messageId);
       }

       public void pushMsg(List<int> listToUserId, string strMessage)
       {
           List<PushMessage_Model> list = Message_DAL.Instance.getDeviceToken(listToUserId);
           if (list != null && list.Count > 0)
           {
               foreach (PushMessage_Model item in list)
               {
                   HSPush.pushMsg(item.DeviceID, item.DeviceType, item.UserType, strMessage, StringUtils.GetDbBool(System.Configuration.ConfigurationManager.AppSettings["IsProduction"]), "1");
               }
           }
       }

       public List<AddMessage_Model> addMessage(Message_Model model)
       {
           return Message_DAL.Instance.addMessage(model);
       }

    }
}
