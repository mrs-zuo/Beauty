using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class StatisticsSurplus_Model
    { 
        public int OrderID { set; get; }
        public string OrderNumber { set; get; }
        public string ProductName { set; get; }
        public int ProductSurPlusNum { set; get; }
        public decimal ProductSurplusPrice { set; get; }
        public int ProductServiceType { set; get; }
    }
}
