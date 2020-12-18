using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class EditMarketRelationShipForBranchOperation_Model
    {
        // 1:服务 2:商品 3：账户 4：会员卡
        public int MarketType { set; get; }
        public int CompanyID { set; get; }
        public int BranchID { set; get; }
        public int OperatorID { set; get; }
        public DateTime OperatorTime { set; get; }
        public List<EditMarketRelationShipForBranchDetail_Model> EditList { set; get; }
        
    }

    [Serializable]
    public class EditMarketRelationShipForBranchDetail_Model {
        public bool Available { set; get; }
        public long ObjectID { set; get; }
        public int ProductQty { set; get; }
        public int StockCalcType { set; get; }
        public int OperateQty { set; get; }
        public int OperateType { set; get; }
        public string OperateSign { set; get; }
        public string Remark { set; get; }
        public int StockID { get; set; }
        public decimal BuyingPrice { set; get; }
        public int InsuranceQty { get; set; }
    }

    [Serializable]
    public class ProductStock_Model
    {
        public int StockID { set; get; }
        public int ProductQty { set; get; }
    }
}
