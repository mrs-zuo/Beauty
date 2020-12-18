using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Product_Stock_Batch_Model
    {
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int ID { get; set; }
        public long ProductCode { get; set; }
        public string BatchNO { get; set; }
        public int Quantity { get; set; }
        public DateTime ExpiryDate { get; set; }
        public int OperatorID { get; set; }
        public DateTime OperateTime { get; set; }
    }
}
