using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetServiceDetail_Model
    {
        public int ServiceID { get; set; }
        public long ServiceCode { get; set; }
        public string ServiceName { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal PromotionPrice { get; set; }
        public string Describe { get; set; }
        public string SerialNumber { get; set; }
        public int CourseFrequency { get; set; }
        public int SpendTime { get; set; }
        public string ProductImgURL { get; set; }

        public List<string> ImgList { get; set; }
        public List<string> SubServiceNameList { get; set; }
        public string BrowseHistoryList { get; set; }
    }

    [Serializable]
    public class GetSeriviceList_Model {
        public int ServiceID { get; set; }
        public long ServiceCode { get; set; }
        public string ServiceName { get; set; }
        public int MarketingPolicy { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal PromotionPrice { get; set; }
        public string ThumbnailURL { get; set; }
        public string SearchField { get; set; }
        public int SortID { get; set; }
        public int FavoriteID { get; set; }
    }
}
