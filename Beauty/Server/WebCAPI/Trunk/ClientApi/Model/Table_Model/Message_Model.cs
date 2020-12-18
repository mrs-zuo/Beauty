using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Message_Model
    {
        public int CompanyID { set; get; }
        public int BranchID { set; get; }
        public int ID { set; get; }
        public int MessageType { set; get; }
        public bool GroupFlag { set; get; }
        public int FromUserID { set; get; }
        public List<int> listToUserID { set; get; }
        public int MessageContentID { set; get; }
        public string MessageContent { set; get; }
        public DateTime SendTime { set; get; }
        public DateTime ReceiveTime { set; get; }
        public string ToUserIDs { set; get; }
    }
}
