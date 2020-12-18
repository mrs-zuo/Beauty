using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetOrderListRes_Model
    {
        public int RecordCount { get; set; }
        public int PageCount { get; set; }
        public List<GetOrderList_Model> OrderList { get; set; }
    }

    [Serializable]
    public class GetOrderList_Model
    {
        public int OrderObjectID { get; set; }
        public int OrderID { get; set; }
        public string ResponsiblePersonName { get; set; }
        public string CustomerName { get; set; }
        public int ProductType { get; set; }
        public int Quantity { get; set; }
        public decimal TotalOrigPrice { get; set; }
        public decimal TotalSalePrice { get; set; }
        public decimal UnPaidPrice { get; set; }
        public string OrderTime { get; set; }
        public string ProductName { get; set; }
        public int OrderSource { get; set; }
        public int Status { get; set; }
        public int PaymentStatus { get; set; }
        public DateTime CreateTime { get; set; }
    }
}
