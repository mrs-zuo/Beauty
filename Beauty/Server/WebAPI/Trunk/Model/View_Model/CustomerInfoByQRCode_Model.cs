using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class CustomerInfoByQRCode_Model
    {
        public CustomerInfoByQRCode_Model() { }
        public int CustomerID { set; get; }
        public bool IsMyCustomer { get; set; }
        public string CustomerName { get; set; }
        public decimal Discount { get; set; }
        public string HeadImageURL { get; set; }
    }
}
