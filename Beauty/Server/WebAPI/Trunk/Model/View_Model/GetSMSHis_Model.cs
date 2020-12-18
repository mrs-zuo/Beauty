using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{

    // 短信履历一览
    [Serializable]
    public class GetSMSNum_Model
    {
        public int SMSNum { get; set; }         // 可发送短信数量
        public int SMSSent { get; set; }        // 已发送短信数量
        public List<SMSNumList_Model> SMSNumList { get; set; } // 各门店已发送短信数量List
    }

    // 各门店已发送短信数量List
    [Serializable]
    public class SMSNumList_Model {
        public string BranchName { set;get;}    // 门店名称
        public int SentNum { set; get; }        // 已发送短信数量
    }
}
