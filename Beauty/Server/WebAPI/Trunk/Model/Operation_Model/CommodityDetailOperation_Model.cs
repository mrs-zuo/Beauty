using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class CommodityDetailOperation_Model
    {
        public int CategoryID{get;set;}
        public int CommodityID{get;set;}
        public long CommodityCode{get;set;}
        public int MarketingPolicy{get;set;}
        public string CommodityName{get;set;}
        public string Describe{get;set;}
        public string Specification{get;set;}
        public bool VisibleForCustomer { get; set; }
        public bool New { get; set; }
        public bool Recommended { get; set; }
        public int DiscountID { get; set; }
        public string SerialNumber { get; set; }
        public string Thumbnail { get; set; }
        //public List<string> CommodityImage { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal PromotionPrice { get; set; }
        public int IsConfirmed { get; set; }
        public int AutoConfirm { get; set; }
        public int AutoConfirmDays { get; set; }
        public List<string> BigImageUrl { get; set; }
        public List<string> deleteImageUrl { get; set; }
         
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int UpdaterID { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
		public string Manufacturer { get; set; }
        public string ApprovalNumber { get; set; }
    }
}
