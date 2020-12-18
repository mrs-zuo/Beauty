using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    public class UtilityOperation_Model
    {
        public int Type { get; set; }
        public int ID { get; set; }
        public int UpdaterID { get; set; }
        public int AccountID { get; set; }
        public int CustomerID { get; set; }
        public int CreatorID { get; set; }
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int UserType { get; set; }
        public int ProductType { get; set; }
        public string TagIDs { get; set; }
        public int ProductCode { get; set; }
        public int ImageWidth { get; set; }
        public int ImageHeight { get; set; }
        public int PageIndex { get; set; }
        public int PageSize { get; set; }
        public long ServiceCode { get; set; }
        public long CommodityCode { get; set; }
        public string strSearch { get; set; }
        public string BrowseHistoryCodes { get; set; }
    }

    public class BrowseHistoryOperation_Model
    {
        public long CommodityCode { get; set; }
        public long ServiceCode { get; set; }
    }
}
