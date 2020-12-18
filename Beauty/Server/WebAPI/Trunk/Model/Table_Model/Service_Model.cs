using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Service_Model
    {
        public int CompanyID { get; set; }
        public int CategoryID { get; set; }
        public int ID { get; set; }
        public int BranchID { get; set; }
        public string ServiceName { get; set; }
        public decimal UnitPrice { get; set; }
        public string SubServiceCodes { get; set; }
        public decimal PromotionPrice { get; set; }
        public string Describe { get; set; }
        public bool Available { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public bool VisibleForCustomer { get; set; }
        public string ThumbnailUrl { get; set; }
        public string BigPictureUrl { get; set; }
        public long ServiceCode { get; set; }
        public string CategoryName { get; set; }
        public int MarketingPolicy { get; set; }
        public int Sortid { get; set; }
        public string SerialNumber { get; set; }
        public int DiscountID { get; set; }
        public int SpendTime { get; set; }
        public int VisitTime { get; set; }
        public int ExpirationDate { get; set; }
        public bool NeedVisit { get; set; }
        public bool HaveExpiration { get; set; }
        public string QRcodeUrl { get; set; }
        public string CompanyCode { get; set; }
        public int CourseFrequency { get; set; }
        public int IsConfirmed { get; set; }
        public int AutoConfirm { get; set; }
        public int AutoConfirmDays { get; set; }
        public bool Recommended { get; set; }

        public List<ServiceBranch> BranchList { get; set; }
        public ImageCommon_Model thumbImage { get; set; }
        public List<ImageCommon_Model> BigImageList { get; set; }
    }

    [Serializable]
    public class ServiceBranch
    {
        public int BranchID { get; set; }
        public string BranchName { get; set; }
        public bool IsExist { get; set; }
    }
}
