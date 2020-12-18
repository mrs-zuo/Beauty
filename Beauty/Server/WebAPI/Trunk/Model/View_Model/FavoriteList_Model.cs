using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class FavoriteList_Model
    {
      public int ID {get;set;}
        public int ProductID {get;set;}
        public long ProductCode {get;set;}
        public string ProductName { get; set; }
        public string Specification {get;set;}
        public int ProductType {get;set;}
        public int SortID {get;set;}
        public int MarketingPolicy {get;set;}
        public decimal UnitPrice {get;set;}
        public decimal PromotionPrice {get;set;}
        public DateTime CreateTime {get;set;}
        public bool Available {get;set;}
        public string ExpirationDate {get;set;}
        public string  FileUrl {get;set;}
    }
}
