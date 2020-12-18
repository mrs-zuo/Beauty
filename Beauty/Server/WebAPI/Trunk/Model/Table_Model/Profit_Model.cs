using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Profit_Model
    {
        public string AccountName { get; set; }
        public int AccountID { get; set; }
        public decimal ProfitPct { get; set; }
    }
}
