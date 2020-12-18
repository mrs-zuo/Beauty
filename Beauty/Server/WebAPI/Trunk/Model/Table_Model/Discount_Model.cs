using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Discount_Model
    {
        public int ID { get; set; }
        public int CompanyID { get; set; }
        public string DiscountName { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreatorTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public bool Available { get; set; }
    }
}
