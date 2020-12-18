using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class SubService_Commission_Rule_Model
    {
        public long ServiceCode { get; set; }
        public long SubServiceCode { get; set; }
        public decimal DesSubServiceProfitPct { get; set; }
        public int DesSubOPCommType { get; set; }
        public decimal DesSubOPCommValue { get; set; }
        public decimal SubServiceProfitPct { get; set; }
        public int SubOPCommType { get; set; }
        public decimal SubOPCommValue { get; set; }
        public int CompanyID { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public int RecordType { get; set; }
    }
}
