using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetUnconfirmedOrderList_Model
    {
        public int OrderID { get; set; }
        public int TreatmentID { get; set; }
        public int ProductType { get; set; }
        public string Time { get; set; }
        public string AccountName { get; set; }
        public int Quantity { get; set; }
        public string ProductName { get; set; }
        public int BranchID { get; set; }
        public string BranchName { get; set; }
        public string Remark { get; set; }
        public int IsLastFlag { get; set; }
    }
}
