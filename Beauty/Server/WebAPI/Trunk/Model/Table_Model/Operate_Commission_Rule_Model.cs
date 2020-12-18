using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Operate_Commission_Rule_Model
    {
        public long ServiceCode { get; set; }
        public decimal ProfitPct { get; set; }
        public bool HaveSubService { get; set; }
        public int DesOPCommType { get; set; }
        public decimal DesOPCommValue { get; set; }
        public int OPCommType { get; set; }
        public decimal OPCommValue { get; set; }
        public int CompanyID { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public int RecordType { get; set; }
    }
}
