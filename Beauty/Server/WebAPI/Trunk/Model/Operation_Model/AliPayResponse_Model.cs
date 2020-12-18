using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class AliPayResponse_Model
    {
        public string BuyerLogonId { get; set; }
        public string BuyerPayAmount { get; set; }
        public string FundBillList { get; set; }
        public string GmtPayment { get; set; }
        public string InvoiceAmount { get; set; }
        public string OpenId { get; set; }
        public string OutTradeNo { get; set; }
        public string PointAmount { get; set; }
        public string ReceiptAmount { get; set; }
        public string TotalAmount { get; set; }
        public string TradeNo { get; set; }
        public string Code { get; set; }
        public string Msg { get; set; }
        public string SubCode { get; set; }
        public string SubMsg { get; set; }
        public string Body { get; set; }
        public string IsError { get; set; }
        public string TradeState { get; set; }
    }

    [Serializable]
    public class AliPayResponseBody_Model
    {
        public Alipay_trade_pay_response alipay_trade_pay_response { get; set; }
        public string sign { get; set; }
    }

    [Serializable]
    public class AliPayQueryResponseBody_Model
    {
        public Alipay_trade_pay_response alipay_trade_query_response { get; set; }
        public string sign { get; set; }
    }

    [Serializable]
    public class Alipay_trade_pay_response
    {
        public string code { get; set; }
        public string msg { get; set; }
        public string buyer_logon_id { get; set; }
        public string buyer_pay_amount { get; set; }
        public string buyer_user_id { get; set; }
        public string invoice_amount { get; set; }
        public string open_id { get; set; }
        public string out_trade_no { get; set; }
        public List<FundBillList> fund_bill_list { get; set; }
        public string strFundBillList { get; set; }
        public string point_amount { get; set; }
        public string receipt_amount { get; set; }
        public string total_amount { get; set; }
        public string trade_no { get; set; }
        public string trade_status { get; set; }
        public string sub_code { get; set; }
        public string sub_desc { get; set; }
        public string send_pay_date { get; set; }
        public List<DiscountGoodsDetail> discount_goods_detail { get; set; }
        public string strDiscountGoodsDetail { get; set; }
    }

    [Serializable]
    public class FundBillList
    {
        public string fund_channel { get; set; }
        public string amount { get; set; }
    }

    [Serializable]
    public class DiscountGoodsDetail
    {
        public string goods_id { get; set; }
        public string goods_name { get; set; }
        public string discount_amount { get; set; }
        public string voucher_id { get; set; }
    }
}
