using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class OpportunityAddOperation_Model
    {
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int AccountID { get; set; }
        public int CustomerID { get; set; }
        public List<ProductList> ProductList { get; set; }

       
        public int Status { get; set; }
        public DateTime CreateTime { get; set; }
        public int Progress { get; set; }
        public int Available { get; set; }
    }

    public class ProductList
    {
        public long ProductCode { get; set; }
        public int ProductType { get; set; }
        public int Quantity { get; set; }
        public int ResponsiblePersonID { get; set; }
        public decimal TotalSalePrice { get; set; }

        public int StepID { get; set; }
        public int ProductID { get; set; }
        public decimal TotalOrigPrice { get; set; }
        public decimal TotalCalcPrice { get; set; }
    }
}
