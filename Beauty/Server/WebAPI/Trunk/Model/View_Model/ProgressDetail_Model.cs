using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class ProgressDetail_Model
    {
        public int ProgressID { get; set; }
        public int ProductID { get; set; }
        public long ProductCode { get; set; }
        public int ProductType { get; set; }
        public string ProductName { get; set; }
        public int Quantity { get; set; }
        public decimal TotalSalePrice { get; set; }
        public decimal TotalCalcPrice { get; set; }
        public decimal TotalOrigPrice { get; set; }
        public string CreateTime { get; set; }
        public int Progress { get; set; }
        public string StepContent { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal PromotionPrice { get; set; }
        public int MarketingPolicy { get; set; }
        public int CustomerID { get; set; }
        public string Description { get; set; }
    }
}
