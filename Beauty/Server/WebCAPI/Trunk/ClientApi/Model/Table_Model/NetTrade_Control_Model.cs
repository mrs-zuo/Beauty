using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class NetTrade_Control_Model
    {
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public string NetTradeNo { get; set; }
        public int NetActionType { get; set; }
        public int NetTradeVendor { get; set; }
        public string NetTradeActionMode { get; set; }
        public string ProductName { get; set; }
        public decimal NetTradeAmount { get; set; }
        public decimal PointAmount { get; set; }
        public decimal CouponAmount { get; set; }
        public decimal MoneyAmount { get; set; }
        public string Participants { get; set; }
        public int CreatorID { get; set; }
        public string Remark { get; set; }
        public string UserCardNo { get; set; }
        public int ResponsiblePersonID { get; set; }
        public int CustomerID { get; set; }
    }
}
