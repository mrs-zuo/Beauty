using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Ecard_Commission_Rule_Model
    {
        public int ID { get; set; }
        public long CardCode { get; set; }
        public decimal ProfitPct { get; set; }
        public int FstChargeCommType { get; set; }
        public decimal FstChargeCommValue { get; set; }
        public int ChargeCommType { get; set; }
        public decimal ChargeCommValue { get; set; }
    }
}
