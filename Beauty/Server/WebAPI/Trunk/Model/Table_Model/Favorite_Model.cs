using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Favorite_Model
    {
        public int ID { get; set; }
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int AccountID { get; set; }
        public int ProductType { get; set; }
        public long ProductCode { get; set; }
        public int SortID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdateTime { get; set; }
    }
}
