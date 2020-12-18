using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class CommodityDetail_Model
    {
        public int CategoryID
        {
            get;
            set;
        }
        public int CommodityID
        {
            get;
            set;
        }
        public long CommodityCode
        {
            get;
            set;
        }
        public int MarketingPolicy
        {
            get;
            set;
        }
        public int StockQuantity
        {
            get;
            set;
        }
        public int StockCalcType
        {
            get;
            set;
        }
        public string FavoriteID
        {
            get;
            set;
        }
        public string CommodityName
        {
            get;
            set;
        }
        public string Describe
        {
            get;
            set;
        }
        public string Specification
        {
            get;
            set;
        }
        public int ImageCount
        {
            get;
            set;
        }

        public bool VisibleForCustomer{get;set;}

        public bool New{get;set;}
        public bool Recommended{get;set;}
        public int DiscountID{get;set;}
        public string SerialNumber{get;set;}
        public string Thumbnail { get; set; }
        public List<string> CommodityImage { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal PromotionPrice { get; set; }
        public List<CommodityEnalbeInfoDetail> ProductEnalbeInfo { get; set; }
        public List<ProductBranchRelationship_Model> ProductBranchRelationship { get; set; }
        public List<ImageCommon_Model> BigImageList { get; set; }
        public bool IsConfirmed { get; set; }
    }

    [Serializable]
    public class CommodityEnalbeInfoDetail
    {
        public int BranchID { get; set; }
        public string BranchName { get; set; }
        public int Quantity { get; set; }
        public int StockCalcType { get; set; }
    }
}
