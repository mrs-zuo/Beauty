using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    public class AddRushOrderOperation_Model
    {
        public int CompanyID { get; set; }
        public int CustomerID { get; set; }
        public DateTime Time { get; set; }
        public DateTime LimitedPaymentTime { get; set; }
        public DateTime ReleaseTime { get; set; }

        public int BranchID { get; set; }
        public string PromotionID { get; set; }
        public int ProductID { get; set; }
        public int ProductType { get; set; }
        public int Qty { get; set; }
        public string Remark { get; set; }
    }
}
