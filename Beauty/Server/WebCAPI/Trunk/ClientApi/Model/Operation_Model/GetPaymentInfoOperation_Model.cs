using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class GetPaymentInfoOperation_Model
    {
        public int CustomerID { get; set; }
        public List<PaymentInfoDetailOperation_Model> OrderList { get; set; }

        public int CompanyID { get; set; }
        public int BranchID { get; set; }
    }

    public class PaymentInfoDetailOperation_Model
    {
        public int OrderID { get; set; }
        public int OrderObjectID { get; set; }
        public int ProductType { get; set; }
    }
}
