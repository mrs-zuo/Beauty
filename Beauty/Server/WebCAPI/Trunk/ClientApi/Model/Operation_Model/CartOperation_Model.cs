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
        public long ProductCode { get; set; }
        public int ProductType { get; set; }
        public int Quantity { get; set; }
        /// <summary>
        /// 1:正常、2:已结算、3:已取消。
        /// </summary>
        public int Status { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public int BranchID { get; set; }
        public string CartID { get; set; }
        public List<string> CartIDList { get; set; }
    }

    public class CartIDList_Model {
        public string CartID { get; set; }
    }
}
