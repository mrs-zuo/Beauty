using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class ConfirmOrderOperation_Model
    {
        public int CustomerID { get; set; }
        public string Password { get; set; }
        public List<ConfirmOrderList> OrderList { get; set; }
    }

    public class ConfirmOrderList
    {
        public int ProductType { get; set; }
        public int ID { get; set; }
        public int TreatmentID { get; set; }
    }
}
