using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
   public class PriceRange_Model
    {
        public int PriceRangeNo { set; get; }
        public string PriceRangeName { set; get; }
        public string PriceRangeValue { set; get; }
        public int BranchID { set; get; }
        public int CompanyID { set; get; }
        public int CreatorID { set; get; }
        public DateTime CreateTime { set; get; }
        public int UpdaterID { set; get; }
        public DateTime UpdateTime { set; get; }
        public int RecordType { set; get; }
        
    }
}
