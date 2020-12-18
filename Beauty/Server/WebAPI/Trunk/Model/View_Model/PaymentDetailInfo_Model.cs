using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class PaymentDetailInfo_Model
    {
        public int Status { get; set; }
        public DateTime CreateTime { get; set; }
        public string Operator { get; set; }
        public decimal TotalPrice { get; set; }
        public int PaymentID { get; set; }
        public int OrderNumber { get; set; }
        public DateTime PaymentTime { get; set; }
        public string PaymentCode { get; set; }
        public int IsUseRate { get; set; }

        public List<PaymentDetailList_Model> PaymentDetailList { get; set; }
        public List<Profit_Model> ProfitList { get; set; }
        public List<PaymentDetailOrderInfo_Model> OrderList { get; set; }
        public List<AccountList_Model> accountList { get; set; }
    }
}
