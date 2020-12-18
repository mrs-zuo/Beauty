using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class ServiceDetail_Model
    {
        public int ServiceID { get; set; }
        public long ServiceCode { get; set; }
        public string ServiceName { get; set; }
        public int CourseFrequency { get; set; }
        public int SpendTime { get; set; }
        public string Describe { get; set; }
        public int MarketingPolicy { get; set; }
        public decimal PromotionPrice { get; set; }
        public decimal UnitPrice { get; set; }
        public bool HasSubServices { get; set; }
        public string SubServiceCodes { get; set; }

        public List<string> ServiceImage { get; set; }
        public List<SubServiceInServiceDetail_Model> SubServices { get; set; }
        public int ImageCount { get; set; }
        public int FavoriteID { get; set; }

        public List<ServiceEnalbeInfoDetail_Model> ProductEnalbeInfo
        {
            get;
            set;
        }
    }

    [Serializable]
    public class SubServiceInServiceDetail_Model
    {
        public string SubServiceName { get; set; }
        public int SpendTime { get; set; }
        public long SubServiceCode { get; set; }
    }

    [Serializable]
    public class ServiceEnalbeInfoDetail_Model
    {
        public string BranchName { get; set; }
        public int BranchID { get; set; }
    }
}
