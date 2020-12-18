using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class CustomerAdd_Model
    {
        public bool IsMyCustomer { get; set; }
        public int CustomerID { get; set; }
        public string CustomerName { get; set; }
        public string LoginMobile { get; set; }
        //public decimal Discount { get; set; }
        public string HeadImageURL { get; set; }
        public string PinYin { get; set; }
        public bool IsPast { get; set; }
        public int SalesPersonID { get; set; }
    }
}
