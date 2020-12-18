using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class OrderDetailOperationForWeb_Model
    {
        public int OrderID { get; set; }
        public string OrderCode { get; set; }
        public int Status { get; set; }
        public DateTime Expirationtime { get; set; }
        public int ResponsiblePersonID { get; set; }
        public DateTime OrderTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public int OrderCompleted { get; set; }
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
    }

    [Serializable]
    public class CancelOrderForWeb_Model
    {
        public int CompanyID { get; set; }
        public int CustomerID { get; set; }
        public int BranchID { get; set; }
        public int ResponsiblePersonID { get; set; }
        public int SalesID { get; set; }
        public int ProductCode { get; set; }
        public int ProductID { get; set; }
        public int ProductType { get; set; }
        public int Quantity { get; set; }
        public int PaymentStatus { get; set; }
        public decimal TotalSalePrice { get; set; }
    }
}
