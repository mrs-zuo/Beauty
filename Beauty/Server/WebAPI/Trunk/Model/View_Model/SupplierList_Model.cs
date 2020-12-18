using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class SupplierList_Model
    {
        public int BranchID { get; set; }
        public int CompanyID { get; set; }
        public string SupplierName { get; set; }
        public int SupplierID { get; set; }
        public string SupplierAddr { get; set; }
        public string SupplierTel { get; set; }
        public string SupplierContactName { get; set; }
        public string SupplierContactTel { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public DateTime Available { get; set; }

        public string InputSearch { get; set; }

    }
}
