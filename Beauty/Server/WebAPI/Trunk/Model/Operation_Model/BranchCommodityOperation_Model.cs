using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    public class BranchCommodityOperation_Model
    {
        public int CompanyID { set; get; }
        public int OperatorID { set; get; }
        public DateTime OperateTime { set; get; }
        public long Code { set; get; }
        public int Type { set; get; }
        public List<BranchStockOperation_Model> operationList { get; set; }
    }


    public class BranchStockOperation_Model
    {
        public int BranchID { set; get; }
        public string BranchName { set; get; }
        
        
        //TBL_PRODUCT_STOCK表
        public int ProductStockID { set; get; }
        public int ProductQty { set; get; }
        public int StockCalcType { set; get; }
        public decimal BuyingPrice { get; set; }
        public int InsuranceQty { get; set; }

        //TBL_PRODUCT_STOCK_OPERATELOG
        public int OperateType { set; get; }
        public int OperateQty { set; get; }
        public string OperateSign { set; get; }
        public int OrderID { set; get; }
        public string OperateRemark { set; get; }


        //TBL_PRODUCT_RELATIONSHIP
        public int ProductRelationShipID { set; get; }
        public bool BranchAvailable { set; get; }
    }

}
