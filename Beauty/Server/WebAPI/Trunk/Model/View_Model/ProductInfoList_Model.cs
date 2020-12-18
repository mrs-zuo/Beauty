using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class ProductInfoList_Model
    {
        public int ID { get; set; }
        public long Code { get; set; }
        public int ProductType { get; set; }
        public string Name { get; set; }
        public decimal UnitPrice { get; set; }
        public int MarketingPolicy { get; set; }
        public decimal PromotionPrice { get; set; }
        public DateTime ExpirationDate { get; set; }
        public int CardID { get; set; }
        public string CardName { get; set; }
        public int CourseFrequency { get; set; }
        public decimal Discount { get; set; }

    }
}
