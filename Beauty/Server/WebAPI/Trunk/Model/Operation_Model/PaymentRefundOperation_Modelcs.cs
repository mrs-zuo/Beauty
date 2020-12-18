using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class PaymentRefundOperation_Modelcs
    {
        public int PaymentID { get; set; }
        public int TargetPaymentID { get; set; }
        public int BranchID { get; set; }
        public int CompanyID { get; set; }
        public decimal TotalPrice { get; set; }
        public int CreatorID { get; set; }
        public string Remark { get; set; }
        public DateTime CreateTime { get; set; }
        public int OrderID { get; set; }
        public int CustomerID { get; set; }
        //业绩比
        public decimal BranchProfitRate { get; set; }
        //业绩提成比例flag
        public int AverageFlag { get; set; }
        public List<Slave_Model> Slavers { get; set; }
        public List<PaymentDetail_Model> PaymentDetailList { get; set; }
        public List<PaymentDetail_Model> GiveDetailList { get; set; }
        public int ProductType { get; set; }
    }
    [Serializable]
    public class PaymentRefundOperationList_Modelcs
    {
        public List<PaymentRefundOperation_Modelcs> PaymentRefundOperationList { get; set; }
    }
}
