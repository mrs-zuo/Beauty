using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;
using HS.Framework.Common.Push;
using HS.Framework.Common.Util;
using System.Configuration;

namespace WebAPI.BLL
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

        public List<GetContactList_Model> getContactListForAccount(int accountId, int imageWidth, int imageHeight)
        {
            return Message_DAL.Instance.getContactListForAccount(accountId, imageWidth, imageHeight);
        }

        public List<GetContactList_Model> getContactListForCustomer(int companyId, int customerId, int imageWidth, int imageHeight)
        {
            return Message_DAL.Instance.getContactListForCustomer(companyId, customerId, imageWidth, imageHeight);
        }

        public List<AddMessage_Model> addMessage(Message_Model model)
        {
            return Message_DAL.Instance.addMessage(model);
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

        public List<GetMessageList_Model> getNewMessageForMarketingByCompanyID(int companyId, int messageId)
        {
            return Message_DAL.Instance.getNewMessageForMarketingByCompanyID(companyId, messageId);
        }

        public List<GetMessageList_Model> getNewMessageForMarketingByBranchID(int branchId, int messageId)
        {
            return Message_DAL.Instance.getNewMessageForMarketingByBranchID(branchId, messageId);
        }

        /// <summary>
        /// 取得接受营销消息的用户信息
        /// </summary>
        /// <param name="MessageContentID"></param>
        /// <returns></returns>
        public List<string> getAcceptMarketingMessageCustomerName(int messageContentId)
        {
            return Message_DAL.Instance.getAcceptMarketingMessageCustomerName(messageContentId);
        }


        public MessageCount_Model getMsgCount(int toUserId)
        {
            return Message_DAL.Instance.getMsgCount(toUserId);
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


        /// <summary>
        /// 取得单个联系人未读的消息
        /// </summary>
        /// <param name="fromUserId"></param>
        /// <param name="toUserId"></param>
        /// <returns></returns>
        public List<int> getMsgWithNoReceive(int fromUserId, int toUserId)
        {
            return Message_DAL.Instance.getMsgWithNoReceive(fromUserId, toUserId);
        }

        public List<GetMessageList_Model> getMsgByLastId(int fromUserId, int toUserId, int messageId)
        {
            return Message_DAL.Instance.getMsgByLastId(fromUserId, toUserId, messageId);
        }

        public List<GetMessageList_Model> getMsgByLastTen(int fromUserId, int toUserId)
        {
            return Message_DAL.Instance.getMsgByLastTen(fromUserId, toUserId);
        }

        public List<GetMessageList_Model> getHistoryMsg(int accountId, int customerId, int messageId)
        {
            return Message_DAL.Instance.getHistoryMsg(accountId, customerId, messageId);
        }

        public List<GetMessageList_Model> getHistoryMessageForMarketingFirstTime(int companyId, int branchId, DateTime sendTime, int selectCount)
        {
            return Message_DAL.Instance.getHistoryMessageForMarketingFirstTime(companyId, branchId, sendTime, selectCount);
        }

        public List<GetMessageList_Model> getHistoryMessageForMarketing(int companyId, int branchId, int messageId, int selectCount)
        {
            return Message_DAL.Instance.getHistoryMessageForMarketing(companyId, branchId, messageId, selectCount);
        }

        public List<GetMessageList_Model> getMessageForMarketing(int companyID, int branchID, int accountID, DateTime sendTime, int pageSize, int pageIndex, out int recordCount)
        {
            List<GetMessageList_Model> list = Message_DAL.Instance.getMessageForMarketing(companyID, branchID, accountID, sendTime, pageSize, pageIndex, out recordCount);
            return list;
        }

        public List<GetMessageList_Model> getMessageForMarketingForManager(int companyID, int accountID, DateTime SendTime, int pageSize, int pageIndex, out int recordCount)
        {
            List<GetMessageList_Model> list = Message_DAL.Instance.getMessageForMarketingForManager(companyID, accountID, SendTime, pageSize, pageIndex, out recordCount);
            return list;
        }
    }
}
