using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Journal_Account_Model
    {
        public int ID { get; set; }
        public int BranchID { get; set; }
        public int InOutType { get; set; }
        public int NameID { get; set; }
        public DateTime Date { get; set; }
        public decimal Amount { get; set; }
        public int OperatorID { get; set; }
        public string Remark { get; set; }
        public int CompanyID { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public int RecordType { get; set; }

        public string ItemName { get; set; }
        public string OperatorName { get; set; }
    }
}
