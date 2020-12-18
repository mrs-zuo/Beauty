using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class PaymentDetailOrderInfo_Model
    {
        public string OrderNumber { get; set; }
        public string ProductName { get; set; }
        public DateTime CreateTime { get; set; }
        public decimal TotalSalePrice { get; set; }
        public int ID { get; set; }
        public int ProductType { get; set; }
    }
}
