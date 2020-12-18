using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class GetNetTradeQRCodeOperation_Model
    {
        public string UserCode { get; set; }
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int AccountID { get; set; }
        public DateTime Time { get; set; }
        /// <summary>
        /// 网络支付类型 1:支付 2:退款
        /// </summary>
        public int NetActionType { get; set; }

        /// <summary>
        /// 分类：1:消费、2:消费撤销、3：充值、4：充值撤销
        /// </summary>
        public int ChangeType { get; set; } 
        /// <summary>
        /// 1:微信 2:支付宝
        /// </summary>
        public int NetTradeVendor { get; set; }
        /// <summary>
        /// W1:商家微信二维码支付 W2:客户微信被扫支付 W3:客户微信APP支付 W4:管理端微信支付退款 A1:商家支付宝条码支付 A2：商家支付宝扫码支付
        /// </summary>
        public string NetTradeActionMode { get; set; }

        public int CustomerID { get; set; }
        public List<int> OrderID { get; set; }
        public List<Slave_Model> Slavers { get; set; }
        public decimal MoneyAmount { get; set; }
        public decimal TotalAmount { get; set; }
        public decimal PointAmount { get; set; }
        public decimal CouponAmount { get; set; }
        public string Remark { get; set; }
        public string UserCardNo { get; set; }
        public int ResponsiblePersonID { get; set; }
    }
}
