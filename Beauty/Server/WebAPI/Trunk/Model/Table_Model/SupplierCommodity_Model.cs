using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class SupplierCommodity_Model
    {
        public int SupplierID { get; set; }
        public int CommodityID { get; set; }
        public string CommodityName { get; set; }
        public string SupplierName { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public string SearchOut { get; set; }
        public bool isChecked { get; set; }
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public List<int> ListSupplierID { get; set; }
        public List<int> ListCommodityID { get; set; }

    }
}
