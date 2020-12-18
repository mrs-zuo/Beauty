using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class PaymentAddOperation_Model
    {
        public int BranchID { get; set; }
        public int CompanyID { get; set; }
        public int OrderCount { get; set; }
        public decimal TotalPrice { get; set; }
        public int CreatorID { get; set; }
        public string Remark { get; set; }
        public DateTime CreateTime { get; set; }
        public List<int> OrderIDList{ get;set;}
        public int CustomerID { get; set; }
        public List<int> SlaveID { get; set; }
        public PaymentDetail_Model PaymentDetail { get; set; }
        public int ClientType { get; set; }
        //public List<PaymentDetail_Model> GiveDetailList { get; set; }
    }
    [Serializable]
    public class PaymentDetail_Model
    {
        public string UserCardNo { get; set; }
        public int CardType { get; set; }

        /// <summary>
        /// 支付方式：0:现金、1:储值卡、2:银行卡。3:其他 4:免支付 5：过去支付 6:积分 7：现金券
        /// </summary>
        public int PaymentMode { get; set; }

        /// <summary>
        /// 每种支付方式支付多少钱
        /// </summary>
        public decimal PaymentAmount { get; set; }
    }
    [Serializable]
    public class PaymentCheck_Model
    {
        public int TotalCount { get; set; }
        public decimal TotalAmount { get; set; }
    }
    [Serializable]
    public class PaymentStatusCheck_Model
    {
        public decimal TotalSalePrice { get; set; }
        public decimal UnPaidPrice { get; set; }
        public int PaymentStatus { get; set; }
        public int Status { get; set; }
        public int BranchID { get; set; }
    }
    [Serializable]
    public class PaymentBranchRole
    {
        public bool IsCustomerConfirm { get; set; }
        public bool IsAccountEcardPay { get; set; }
        public bool IsPartPay { get; set; }
        public int IsUseRate { get; set; }
    }
    [Serializable]
    public class PaymentProductType
    {
        public bool IsCommodityOrder { get; set; }
        public bool OnlyOneCourse { get; set; }
        public int Quantity { get; set; }
    }
}
