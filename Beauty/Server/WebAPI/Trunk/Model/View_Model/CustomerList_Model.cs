using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class CustomerList_Model
    {
        public bool IsMyCustomer { get; set; }
        public int CustomerID { get; set; }
        public string CustomerName { get; set; }
        public string LoginMobile { get; set; }
        public string Phone { get; set; }
        public string PinYin { get; set; }
        public string HeadImageURL { get; set; }
        public string SourceType { get; set; }
        public string ComeTime { get; set; }
    }
}
