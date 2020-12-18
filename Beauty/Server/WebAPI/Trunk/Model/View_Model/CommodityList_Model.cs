using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class CommodityList_Model
    {
        public long CommodityCode { set; get; }
        public int CommodityID { set; get; }
        public string CommodityName { set; get; }
        public int MarketingPolicy { set; get; }
        public decimal UnitPrice { set; get; }
        public decimal PromotionPrice { set; get; }
        public int New { set; get; }
        public int Recommended { set; get; }
        public string Specification { set; get; }
        public int FavoriteID { set; get; }
        public string SearchField { set; get; }
        public int Sortid { set; get; }
        public string ThumbnailURL { set; get; }
    }
}
