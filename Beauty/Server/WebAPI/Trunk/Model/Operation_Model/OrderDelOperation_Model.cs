using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class OrderDelOperation_Model
    {
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int ProductType { get; set; }
        public int ProductID { get; set; }
        public int Status { get; set; }
        public int CNT { get; set; }
        public int Quantity { get; set; }
        public long ProductCode { get; set; }
        public decimal TotalSalePrice { get; set; }
        public int PaymentID { get; set; }

        public int PaymentStatus { get; set; }
    }
}
