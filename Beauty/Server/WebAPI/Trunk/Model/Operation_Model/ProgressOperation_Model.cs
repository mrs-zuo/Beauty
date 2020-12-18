using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class ProgressOperation_Model
    {
        public long ProductCode { get; set; }
        public int ProductType { get; set; }
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int CustomerID { get; set; }
        public int OpportunityID { get; set; }
        public int Progress { get; set; }
        public int Quantity { get; set; }
        public decimal TotalSalePrice { get; set; }
        public string Description { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int? UpdaterID { get; set; }
        public DateTime Updatetime { get; set; }

        public int ID { get; set; }
        public int ProductID { get; set; }
        public decimal TotalOrigPrice { get; set; }
        public decimal TotalCalcPrice { get; set; }

        public int ProgressID { get; set; }
    }
}
