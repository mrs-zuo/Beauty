using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class PushOperation_Model
    {
        public string CustomerName { get; set; }
        public string DeviceID { get; set; }
        public int DeviceType { get; set; }
        public int CustomerID { get; set; }
        public int AccountID { get; set; }
        public string CompanyName { get; set; }
        public string AccountName { get; set; }
        public string ServiceName { get; set; }
        public DateTime Time { get; set; }
        public string BranchName { get; set; }
        public DateTime ScheduleTime { get; set; }
        public string Abbreviation { get; set; }
        public string LoginMobile { get; set; }
        public decimal Threshold { get; set; }
        public bool BalanceRemind { get; set; }
        public int UserType { get; set; }
        public string CardName { get; set; }
        public string WeChatOpenID { get; set; }
    }
}
