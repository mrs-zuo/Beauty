using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class PromotionProductDetail_Model
    {
        public int ProductID { get; set; }
        public long ProductCode { get; set; }
        public int ProductType { get; set; }
        public int ImageCount { get; set; }
        public string ProductPromotionName { get; set; }
        public List<string> ProductImage { get; set; }
        public decimal UnitPrice { get; set; }
        public int SoldQuantity { get; set; }
        public decimal DiscountPrice { get; set; }
        public string Notice { get; set; }
        public List<Model.Table_Model.SimpleBranch_Model> BranchList { get; set; }
        public string PromotionID { get; set; }
        public decimal PRValue { get; set; }
    }
}
