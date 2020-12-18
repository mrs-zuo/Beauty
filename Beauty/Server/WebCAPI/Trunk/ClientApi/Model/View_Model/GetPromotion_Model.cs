using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class PromotionList_Model
    {
        public string PromotionCode { get; set; }
        public DateTime EndDate { get; set; }
        public DateTime StartDate { get; set; }
        public int Type { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string PromotionPictureURL { get; set; }
        public bool HasProduct { get; set; }
    }

    [Serializable]
    public class PromotionDetail_Model
    {
        public string PromotionCode { get; set; }
        public DateTime EndDate { get; set; }
        public DateTime StartDate { get; set; }
        public int Type { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string PromotionPictureURL { get; set; }
        public bool HasProduct { get; set; }

        public List<PromotionProductList_Model> ProductList { get; set; }
        public List<Model.Table_Model.SimpleBranch_Model> BranchList { get; set; }
    }

    [Serializable]
    public class PromotionProductList_Model
    {
        public long ProductCode { get; set; }
        public int ProductID { get; set; }
        public string ProductPromotionName { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal DiscountPrice { get; set; }
        public int ProductType { get; set; }
        public int SoldQuantity { get; set; }
        //public string Notice { get; set; }
        public string ThumbnailURL { get; set; }
        public decimal PRValue { get; set; }
    }
}
