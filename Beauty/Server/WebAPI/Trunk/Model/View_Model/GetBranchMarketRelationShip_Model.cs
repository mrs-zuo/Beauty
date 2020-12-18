using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetBranchMarketRelationShip_Model
    {
        public long ObjectID { get; set; }
        public string ObjectName { get; set; }
        public bool BranchAvailable { get; set; }
        public int StockCalcType { get; set; }
        public int ProductQty { get; set; }
        public int StockID { get; set; }
        public decimal BuyingPrice { get; set; }
        public int InsuranceQty { get; set; }
    }

    public class StockCalcType_Model
    {
        public int StockCalcTypeID { set; get; }
        public String StockCalcTypeName { set; get; }
    }

}
