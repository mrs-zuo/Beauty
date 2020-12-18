using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Commodity_Model
    {
        public int CompanyID { get; set; }
        public string CompanyCode { get; set; }
        public int? BranchID { get; set; }
        public int? CategoryID { get; set; }
        public int ID { get; set; }
        public string CommodityName { get; set; }
        public decimal UnitPrice { get; set; }
        public string SubServiceCodes { get; set; }
        public string BranchName { get; set; }
        public bool BranchAvailable { get; set; }
        public string ObjectAttr { get; set; }
        public decimal PromotionPrice { get; set; }
        public string Specification { get; set; }
        public string Describe { get; set; }
        public bool New { get; set; }
        public bool Recommended { get; set; }
        public int? StockQuantity { get; set; }
        public bool Available { get; set; }
        public int? CreatorID { get; set; }
        public DateTime? CreateTime { get; set; }
        public int? UpdaterID { get; set; }
        public DateTime? UpdateTime { get; set; }
        public bool VisibleForCustomer { get; set; }
        public string ThumbnailUrl { get; set; }
        public string BigPictureUrl { get; set; }
        public long CommodityCode { get; set; }
        public string CategoryName { get; set; }
        public int MarketingPolicy { get; set; }
        public string QRcodeUrl { get; set; }
        public string ObjectName { get; set; }
        public int Sortid { get; set; }
        public string SerialNumber { get; set; }
        public int DiscountID { get; set; }
        public bool ExpiryRemind { get; set; }
        public string SearchOut { get; set; }
        public string CommodityID { get; set; }
        public int AutoConfirm { get; set; }
        public int AutoConfirmDays { get; set; }
    }
}
