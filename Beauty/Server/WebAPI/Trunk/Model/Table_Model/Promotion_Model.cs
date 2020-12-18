using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Promotion_Model
    {
        public int ID { get; set; }
        public int CompanyID { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public int Type { get; set; }
        public string TextContent { get; set; }
        public int OperatorID { get; set; }
        public DateTime OperatorTime { get; set; }
        public string ImageFile { get; set; }
        public string PromotionImgUrl { get; set; }
        public List<BranchSelection_Model> BranchList { get; set; }
        public int HasProduct { get; set; }
        public int PromotionType { get; set; }
    }

    [Serializable]
    public class New_Promotion_Model
    {
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public string PromotionCode { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public int Type { get; set; }
        public string ImageFile { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public List<BranchSelection_Model> BranchList { get; set; }
        public string PromotionImgUrl { get; set; }
        public int HasProduct { get; set; }
        public int PromotionType { get; set; }

        public List<PromotionRule_Model> listPromotionRule { get; set; }
    }

    [Serializable]
    public class PromotionRule_Model {
        public int ID { get; set; }
        public int PromotionType { get; set; }
        public string PromotionTypeName { get; set; }
        public string PRCode { get; set; }
        public string PRDesc { get; set; }
        public string PRSample { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public int RecordType { get; set; }

        public decimal PRValue { get; set; }
        public bool IsUse { get; set; }

    }

    [Serializable]
    public class PromotoinProduct_Model
    {
        public string PromotionID { get; set; }
        public int ProductID { get; set; }
        public string ProductPromotionName { get; set; }
        public int ProductType { get; set; }
        public decimal DiscountPrice { get; set; }
        public string Notice { get; set; }
        public int SoldQuantity { get; set; }
        public int CompanyID { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public int RecordType { get; set; }
        public string Specification { get; set; }


        public int PromotionType { get; set; }
        public int SurplusQuantity { get; set; }
        public decimal UnitPrice { get; set; }
        public string ProductName { get; set; }
        public long ProductCode { get; set; }
        public List<PromotionRule_Model> PromotionRuleList { get; set; }
        public int IsAdd { get; set; }
    }





    [Serializable]
    public class PromotionSale_Model
    {
        public int CompanyID { get; set; }
        public string PromotionID { get; set; }
        public string ProductPromotionName { get; set; }
        public string BranchName { get; set; }
        public decimal DiscountPrice { get; set; }
        public int RushOrderCount { get; set; }
        public int SoldQuantity { get; set; }
        public int PayOrder { get; set; }
        public int SurplusQuantity { get; set; }
        public int RushQuantity { get; set; }
        public int PRValue { get; set; }
        public decimal PayAmount { get; set; }
    }
        


}
