using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetRushOrderList_Model
    {
        public DateTime RushTime { get; set; }
        public int BranchID { get; set; }
        public string BranchName { get; set; }
        public string ProductName { get; set; }
        public int PaymentStatus { get; set; }
        public int RushOrderID { get; set; }
        public string PromotionID { get; set; }
        public int RushQuantity { get; set; }
        public decimal TotalRushPrice { get; set; }
        public string ProductPromotionName { get; set; }
    }
}
