using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class WeChatPayResault_Model
    {
        public string NetTradeNo { get; set; }
        public string NetTradeActionMode { get; set; }
        public decimal CashFee { get; set; }
        public decimal PointAmount { get; set; }
        public decimal CouponAmount { get; set; }
        public string ProductName { get; set; }
        public DateTime CreateTime { get; set; }
        public string BankName { get; set; }
        public string TransactionID { get; set; }
        public string ResultCode { get; set; }
        public string TradeState { get; set; }
        public string ErrCode { get; set; }
        public string ErrCodeDes { get; set; }
        public string DisplayResult { get; set; }
        public string OperationTip { get; set; }
        /// <summary>
        /// 分类：1:消费、2:消费撤销、3：充值、4：充值撤销
        /// </summary>
        public int ChangeType { get; set; }
        public string ChangeTypeName { get; set; }
        public string ProductPromotionName { get; set; }
    }
}
