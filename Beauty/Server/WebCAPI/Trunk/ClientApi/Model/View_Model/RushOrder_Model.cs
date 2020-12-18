using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    public class GetRushOrderDetail_Model
    {
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public string BranchName { get; set; }
        public string OrderCode { get; set; }
        public DateTime RushTime { get; set; }
        public DateTime LimitedPaymentTime { get; set; }
        public decimal RushPrice { get; set; }
        public int RushQuantity { get; set; }
        public decimal TotalRushPrice { get; set; }
        public string Remark { get; set; }
        public int PaymentStatus { get; set; }
        public int RushOrderID { get; set; }
        public string CreateTime { get; set; }
        public decimal OrigPrice { get; set; }
        public int ProductType { get; set; }
        public int ProductID { get; set; }
        public string PromotionID { get; set; }
        public string NetTradeNo { get; set; }
        public string ProductName { get; set; }
        public string JsParam { get; set; }
        public bool HasNetTrade { get; set; }
        public int CustomerID { get; set; }
        public long ProductCode { get; set; }
        public int OrderID { get; set; }
        public string ProductPromotionName { get; set; }
    }
}
