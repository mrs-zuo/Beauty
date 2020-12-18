using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class OpportunityDetail_Model
    {
        public int OpportunityID { get; set; }
        public int ProductID { get; set; }
        public int ProductType { get; set; }
        public string ProductName { get; set; }
        public int Quantity { get; set; }
        public decimal TotalOrigPrice { get; set; }
        public decimal TotalCalcPrice { get; set; }
        public decimal TotalSalePrice { get; set; }
        public string CreateTime { get; set; }
        public int Progress { get; set; }
        public string StepContent { get; set; }
        public int BranchID { get; set; }

        public int CustomerID { get; set; }
        public string CustomerName { get; set; }
        public long ProductCode { get; set; }
        public int ResponsiblePersonID { get; set; }
        public string ExpirationTime { get; set; }
    }
}
