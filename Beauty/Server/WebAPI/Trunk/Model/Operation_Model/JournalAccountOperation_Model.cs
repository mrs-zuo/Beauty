using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class JournalAccountOperation_Model
    {
        public int ID { get; set; }
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int InOutType { get; set; }
        public int ItemAID { get; set; }
        public int ItemBID { get; set; }
        public int ItemCID { get; set; }
        public DateTime InOutDate { get; set; }
        public string Remark { get; set; }
        public decimal Amount { get; set; }
        public int OperatorID { get; set; }
        public int CheckResult { get; set; }
        public int CheckID { get; set; }
        public DateTime CheckTime { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }

    }
}
