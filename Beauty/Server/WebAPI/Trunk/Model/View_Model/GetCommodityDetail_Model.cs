using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetCommodityDetail_Model
    {
        public int CommodityID { get; set; }
        public long CommodityCode { get; set; }
        public string CommodityName { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal PromotionPrice { get; set; }
        public string Describe { get; set; }
        public string SerialNumber { get; set; }
        public string Specification { get; set; }
        public bool New { get; set; }
        public bool Recommended { get; set; }
        public string ProductImgURL { get; set; }

        public List<string> ImgList { get; set; }
        public string BrowseHistoryList { get; set; }
    }
}
