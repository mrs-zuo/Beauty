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
        public int CompanyID { get; set; }
        public int ProductType { get; set; }
        public int Status { get; set; }
        public int PaymentStatus { get; set; }
        public DateTime? CreateTime { get; set; }
        public int PageIndex { get; set; }
        public int PageSize { get; set; }
        public int CustomerID { get; set; }
    }
}
