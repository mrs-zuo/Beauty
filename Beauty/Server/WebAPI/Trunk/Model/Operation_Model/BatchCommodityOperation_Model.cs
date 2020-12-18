using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    public class BatchCommodityOperation_Model
    {
        public List<BatchStockOperation_Model> batchList { get; set; }

        public class BatchStockOperation_Model
        {
            //TBL_PRODUCT_STOCK_BATCH表
            public int CompanyID { set; get; }
            public int ID { get; set; }
            public int Quantity { get; set; }
            public DateTime ExpiryDate { get; set; }
            public int BranchID { get; set; }
            public long ProductCode { get; set; }
            public string BatchNO { get; set; }
            public int? SupplierID { get; set; }
            public String SupplierName { get; set; }
        }

        public class DelBatchOperation_Model
        {
            //TBL_PRODUCT_STOCK_BATCH表
            public int CompanyID { set; get; }
            public int ID { get; set; }
            public int Quantity { get; set; }
            public string BatchNO { get; set; }

            //TBL_PRODUCT_STOCK表
            public int BranchID { get; set; }
            public long ProductCode { get; set; }
        }
    }
}
