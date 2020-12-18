using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class BalanceForWebOperation_Model
    {
        public int CompanyID { get; set; }
        public string BalanceCode { get; set; }
        public int BalanceID { get; set; }
        public DateTime? CreateTime { get; set; }
        public int CreateID { get; set; }

        public List<Slave_Model> ProfitList { get; set; }
    }
}
