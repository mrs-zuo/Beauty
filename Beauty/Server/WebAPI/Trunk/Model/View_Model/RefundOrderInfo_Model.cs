using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class RefundOrderInfo_Model
    {
        public decimal RefundAmount { get; set; }
        public decimal GivePointAmount { get; set; }
        public decimal GiveCouponAmount { get; set; }
        public List<RefundOrderPaymentList> PaymentList { get; set; }
        public List<GetECardList_Model> CardList { get; set; }
        public decimal Rate { get; set; }
    }

    [Serializable]
    public class RefundOrderPaymentList
    {
        public int PaymentID { get; set; }
        public DateTime CreateTime { get; set; }
        public string Operator { get; set; }
        public decimal TotalPrice { get; set; }
        public DateTime PaymentTime { get; set; }
        public string PaymentCode { get; set; }
        public string BranchName { get; set; }
        public string TypeName { get; set; }
        public string Remark { get; set; }

        public List<PaymentDetailList_Model> PaymentDetailList { get; set; }
        public List<Profit_Model> ProfitList { get; set; }
        public List<SalesConsultantRate_model> SalesConsultantRates { get; set; }
    }
}
