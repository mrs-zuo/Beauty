using Model.Operation_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebTouch.Models
{
    [Serializable]
    public class PaymentInfoParam
    {
        public int OrderCount { get; set; }
        public string TotalSalePrice { get; set; }
        public int BranchID { get; set; }
        public List<PaymentInfoDetailOperation_Model> OrderList { get;set;}
    }
}