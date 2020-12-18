using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetContactList_Model
    {
        public int NewMessageCount { get; set; }
        public int CustomerID { get; set; }
        public string CustomerName { get; set; }
        public int AccountID { get; set; }
        public string AccountName { get; set; }
        public bool Available { get; set; }
        public string MessageContent { get; set; }
        public DateTime? SendTime { get; set; }
        public string HeadImageURL { get; set; }
        public int Chat_Use { get; set; }
    }

    [Serializable]
    public class GetMessageList_Model
    {
        public int MessageID { get; set; }
        public int MessageContentID { get; set; }
        public string MessageContent { get; set; }
        public DateTime? SendTime { get; set; }
        public int SendOrReceiveFlag { get; set; }
        public int FromUserID { get; set; }
        public string FromUserName { get; set; }
        public int SendCount { get; set; }
        public int ReceiveCount { get; set; }
        public List<string> ToUserName { get; set; }
    }

    [Serializable]
    public class GetMarketMessageList_Model
    {
        public int RecordCount { get; set; }
        public int PageCount { get; set; }
        public List<GetMessageList_Model> MessageList { get; set; }
    }

    [Serializable]
    public class AddMessage_Model
    {
        public int NewMessageID { get; set; }
    }

    [Serializable]
    public class PushMessage_Model {
        public string DeviceID { get; set; }
        public int DeviceType { get; set; }
        public int UserType { get; set; }
    }

    [Serializable]
    public class MessageCount_Model {
        public int NewMessageCount { set;get;}
    }
}
