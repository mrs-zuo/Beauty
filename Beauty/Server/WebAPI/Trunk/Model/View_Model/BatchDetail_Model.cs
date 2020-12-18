using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class BatchDetail_Model
    {
        public string BranchName { set; get; }

        //TBL_PRODUCT_STOCK_BATCH表
        public int BranchID { get; set; }
        public int CompanyID { get; set; }
        public int ID { get; set; }
        public long ProductCode { get; set; }
        public string BatchNO { get; set; }
        public int Quantity { get; set; }
        public DateTime ExpiryDate { get; set; }
        public int OperatorID { get; set; }
        public DateTime OperateTime { get; set; }
        public int? SupplierID { get; set; }
        public String SupplierName { get; set; }
        public int DayDiffNum { get; set; }

    }
}
