using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class AliPayResault_Model
    {
        public string NetTradeNo { get; set; }
        public string TradeState { get; set; }
        public string Code { get; set; }
        public string Msg { get; set; }
        public string SubMsg { get; set; }
        public string TradeNo { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal ReceiptAmount { get; set; }
        public decimal InvoiceAmount { get; set; }
        public decimal BuyerPayAmount { get; set; }
        public decimal PointAmount { get; set; }
        public string DisplayResult { get; set; }
        public string OperationTip { get; set; }
        public string ProductName { get; set; }
        public DateTime CreateTime { get; set; }
        /// <summary>
        /// 分类：1:消费、2:消费撤销、3：充值、4：充值撤销
        /// </summary>
        public int ChangeType { get; set; }
        public string ChangeTypeName { get; set; }
    }
}
 