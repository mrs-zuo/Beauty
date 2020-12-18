using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class PaymentDetailByOrderID_Model
    {
        public int Status { get; set; }
        public DateTime CreateTime { get; set; }
        public string Operator { get; set; }
        public decimal TotalPrice { get; set; }
        public int PaymentID { get; set; }
        public int OrderNumber { get; set; }
        public DateTime PaymentTime { get; set; }
        public string PaymentCode { get; set; }
        public string SaleIDs { get; set; }
        public string SalesName { get; set; }
        public string Remark { get; set; }
        public string BranchName { get; set; }
        public string TypeName { get; set; } 
        public string Type { get; set; }

        public List<PaymentDetailList_Model> PaymentDetailList { get; set; }
        public List<Profit_Model> ProfitList { get; set; }
        public List<PaymentOrderList_Model> PaymentOrderList { get; set; }
        public List<SalesConsultantRate_model> SalesConsultantRates { get; set; }
    }

    [Serializable]
    public class PaymentDetailList_Model
    {
        public int PaymentDetailID { get; set; }
        public int PaymentMode { get; set; }
        public decimal PaymentAmount { get; set; }
        public decimal CardPaidAmount { get; set; }
        public string CardName { get; set; }
        public int CardType { get; set; }
        public decimal ProfitRate { get; set; }
        public string UserCardNo { get; set; }
    }

    [Serializable]
    public class PaymentOrderList_Model
    {
        public int OrderID { get; set; }
        public DateTime OrderTime { get; set; }
        public string OrderNumber { get; set; }
        public string ProductName { get; set; }
        public int ProductType { get; set; }
        public decimal TotalSalePrice { get; set; }
        public int OrderObjectID { get; set; }
    }
}
