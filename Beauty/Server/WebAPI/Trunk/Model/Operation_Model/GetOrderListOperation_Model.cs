using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class GetOrderListOperation_Model
    {
        public GetOrderListOperation_Model()
        {
            this.PageIndex = 1;
            this.PageSize = 10;
        }
        public int AccountID { get; set; }
        public int ProductType { get; set; }
        public int Status { get; set; }
        public int PaymentStatus { get; set; }
        public DateTime? CreateTime { get; set; }
        public int FilterByTimeFlag { get; set; }
        public string StartTime { get; set; }
        public string EndTime { get; set; }
        public int BranchID { get; set; }
        public int PageIndex { get; set; }
        public int PageSize { get; set; }
        public bool IsBusiness { get; set; }
        public int ExecutorID { get; set; }
        public bool IsShowAll { get; set; }
        public string SerchField { get; set; }

        public int CompanyID { get; set; }
        public string ProductName { get; set; }
        public int OrderID { get; set; }

        /// <summary>
        /// 0:普通下单 1:需求转换订单 2:购物车转换订单 3:预约转换订单 4：订单导入 5:促销订单
        /// </summary>
        public int OrderSource { get; set; }

        public List<int> ResponsiblePersonIDs { get; set; }
        public int CustomerID { get; set; }
    }
}
