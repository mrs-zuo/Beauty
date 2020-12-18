using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    public class ProductBranchRelationship_Model
    {
        public int BranchID { set; get; }
        public string BranchName { set; get; }

        //TBL_PRODUCT_STOCK表
        public int ProductStockID { set; get; }
        public int ProductQty { set; get; }
        public int StockCalcType { set; get; }
        public decimal BuyingPrice { set; get; }
        public int InsuranceQty { set; get; }

        //TBL_PRODUCT_RELATIONSHIP
        public int ProductRelationShipID { set; get; }
        public bool BranchAvailable { set; get; }
    }
}
