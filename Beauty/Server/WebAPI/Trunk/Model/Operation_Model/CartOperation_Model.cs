using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class CartOperation_Model
    {
        public int CompanyID { get; set; }
        public int CustomerID { get; set; }
        public int ID { get; set; }
        public long CommodityCode { get; set; }
        public int Quantity { get; set; }
        public int Status { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public int BranchID { get; set; }
        public int CartID { get; set; }
        public List<CartIDList_Model> CartIDList { get; set; }
    }

    public class CartIDList_Model {
        public int CartID { get; set; }
    }
}
