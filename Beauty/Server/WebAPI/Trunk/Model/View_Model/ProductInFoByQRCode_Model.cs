using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class ProductInFoByQRCode_Model
    {
        public ProductInFoByQRCode_Model() { }
        public int ID { set; get; }
        public long Code { set; get; }
        public int Type { set; get; }
        public string Name { set; get; }
        public int MarketingPolicy { set; get; }
        public decimal UnitPrice { set; get; }
        public decimal PromotionPrice { set; get; }
        public string ExpirationTime { get; set; }
    }
}
