using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetCartList_Model
    {
        public int CartID { get; set; }
        public long CommodityCode { get; set; }
        public int CommoditID { get; set; }
        public string CommodityName { get; set; }
        public int Quantity { get; set; }
        public int MarketingPolicy { get; set; }
        public decimal UnitPrice { get; set; }
        public decimal PromotionPrice { get; set; }
        public string ImageURL { get; set; }
        public int BranchID { get; set; }
        public string BranchName { get; set; }
        public int Available { get; set; }
    }
}
