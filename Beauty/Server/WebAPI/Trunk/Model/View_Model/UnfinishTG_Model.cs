using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class UnfinishTG_Model
    {
        public string ProductName { get; set; }        
        public DateTime TGStartTime { get; set; }
        public string AccountName { get; set; }
        public int AccountID { get; set; }
        public int PaymentStatus { get; set; }
        public int TotalCount { get; set; }
        public int FinishedCount { get; set; }
        public long GroupNo { get; set; }
        public int OrderID { get; set; }
        public int OrderObjectID { get; set; }
        public int ProductType { get; set; }
        public string HeadImageURL { get; set; }
        public int Status { get; set; }
        public string CustomerName { get; set; }
        public int CustomerID { get; set; }
        public bool IsDesignated { get; set; }
        public int IsConfirmed { get; set; }
    }
}
