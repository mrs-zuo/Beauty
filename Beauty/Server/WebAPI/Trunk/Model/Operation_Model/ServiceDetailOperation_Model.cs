using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class ServiceDetailOperation_Model
    {
        public int CategoryID { get; set; }
        public int ServiceID { get; set; }
        public long ServiceCode { get; set; }
        public int MarketingPolicy { get; set; }
        public string ServiceName { get; set; }
        public string Describe { get; set; }
        public bool VisibleForCustomer { get; set; }
        public string SubServiceCodes { get; set; }
        public int SpendTime { get; set; }
        public int VisitTime { get; set; }
        public int ExpirationDate { get; set; }
        public bool NeedVisit { get; set; }
        public bool HaveExpiration { get; set; }
        public int DiscountID { get; set; }
        public string SerialNumber { get; set; }
        public string Thumbnail { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal PromotionPrice { get; set; }
        public int CourseFrequency { get; set; }
        public int IsConfirmed { get; set; }
        public int AutoConfirm { get; set; }
        public int AutoConfirmDays { get; set; }
        public bool Recommended { get; set; }

        public bool Available { get; set; }
        public int CreatorID { get; set; }
        public DateTime? CreateTime { get; set; }

        public int UpdaterID { get; set; }
        public DateTime? UpdateTime { get; set; }

        public List<string> BigImageUrl { get; set; }
        public List<string> deleteImageUrl { get; set; }

        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public List<ServiceBranch> BranchList { get; set; }

    }
}
