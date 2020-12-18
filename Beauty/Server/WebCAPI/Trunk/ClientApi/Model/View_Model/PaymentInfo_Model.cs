using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{

    [Serializable]
    public class PaymentInfo_Model
    {
        public decimal TotalOrigPrice { get; set; }
        public decimal TotalCalcPrice { get; set; }
        public decimal TotalSalePrice { get; set; }
        public decimal UnPaidPrice { get; set; }
        public DateTime ExpirationDate { get; set; }
        public int CardID { get; set; }
        public string CardName { get; set; }
        public int CardTypeID { get; set; }
        public bool IsPay { get; set; }
        public bool IsPartPay { get; set; }
        public int SalesPersonID { get; set; }
        public long ProductCode { get; set; }
        public string SalesName { get; set; }
        public string UserCardNo { get; set; }
        public decimal Balance { get; set; }
        public decimal GivePointAmount { get; set; }
        public decimal GiveCouponAmount { get; set; }
    }

    [Serializable]
    public class GetPaymentInfo_Model
    {
        public int ID { get; set; }
        public decimal TotalPrice { get; set; }
        public int Type { get; set; }
        public int Status { get; set; }
    }

    [Serializable]
    public class GetPaymentDetailInfo_Model
    {
        public int CompanyID { get; set; }
        /// <summary>
        /// 支付方式：0:现金、1:储值卡、2:银行卡。3:其他 4:免支付 5：过去支付 6:积分 7：现金券
        /// </summary>
        public int PaymentMode { get; set; }
        public decimal PaymentAmount { get; set; }
        public string UserCardNo { get; set; }
        public decimal CardPaidAmount { get; set; }
    }


    [Serializable]
    public class GetCustomerInfoByPaymentID_Model
    {
        public int CustomerID { get; set; }
        public int LevelID { get; set; }
        public int BranchID { get; set; }
    }

    [Serializable]
    public class GetPaymentOrderInfo_Model
    {
        public int OrderID { get; set; }
        public decimal TotalSalePrice { get; set; }
        public decimal UnPaidPrice { get; set; }
        public int PaymentStatus { get; set; }
        public int ResponsiblePersonID { get; set; }
        public int CustomerID { get; set; }
    }

    [Serializable]
    public class CancelPaymentMsgForWeb
    {
        public string CardName { get; set; }
        public decimal Balance { get; set; }
    }

    [Serializable]
    public class UpdatePaymentForWeb
    {
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public string PaymentCode { get; set; }
        public DateTime PaymentTime { get; set; }
        public int UpdaterID { get; set; }
        public List<int> ProfitList { get; set; }
        public int IsChangeProfit { get; set; }
        public List<UpdatePaymentDetailForWeb> DetailList { get; set; }
    }

    [Serializable]
    public class UpdatePaymentDetailForWeb
    {
        public int PaymentDetailID { get; set; }
        public int PaymentMode { get; set; }
    }
}
