using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class OrderCountOperation_Model
    {
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int CustomerID { get; set; }
        public bool IsBusiness { get; set; }
    }
}
