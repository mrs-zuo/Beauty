using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Product_Commission_Rule_Model
    {
        public int ProductType { get; set; }
        public long ProductCode { get; set; }
        public decimal ProfitPct { get; set; }
        public int ECardSACommType { get; set; }
        public decimal ECardSACommValue { get; set; }
        public int NECardSACommType { get; set; }
        public decimal NECardSACommValue { get; set; }

        public int ID { get; set; }
        public int CompanyID { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public int RecordType { get; set; }
    }
}
