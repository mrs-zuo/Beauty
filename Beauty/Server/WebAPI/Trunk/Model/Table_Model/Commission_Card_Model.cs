using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Commission_Card_Model
    {
        public int ComECardID { set; get; }
        public long CardCode { set; get; }
        public decimal ProfitPct { set; get; }
        public int FstChargeCommType { set; get; }
        public decimal FstChargeCommValue { set; get; }
        public int ChargeCommType { set; get; }
        public decimal ChargeCommValue { set; get; }
        public int CompanyID { set; get; }
        public int CreatorID { set; get; }
        public DateTime CreateTime { set; get; }
        public int UpdaterID { set; get; }
        public DateTime UpdateTime { set; get; }
        public int RecordType { set; get; }
        public string CardName { set; get; }
    }
}
