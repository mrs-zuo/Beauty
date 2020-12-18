using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetCartList_Model
    {
        public int BranchID { get; set; }
        public string BranchName { get; set; }
        public DateTime CreateTime { get; set; }
        public List<CartDetail_Model> CartDetailList { get; set; }
    }

    [Serializable]
    public class CartDetail_Model
    {
        public string CartID { get; set; }
        public int BranchID { get; set; }
        public int ProductType { get; set; }
        public long ProductCode { get; set; }
        public string ProductName { get; set; }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }
        public string ImageURL { get; set; }
        public DateTime CreateTime { get; set; }
        public bool Available { get; set; }
    }
}
