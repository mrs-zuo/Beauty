using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class Statistics_Model
    { 
        public int ObjectCount { set; get; }
        public string ObjectName { set; get; }
        public string ObjectId { set; get; }
        public decimal SumOrigPrice { set; get; }
        public decimal TotalAmout { set; get; }
        public decimal ConsumeAmout { set; get; }
        public decimal RechargeAmout { set; get; }
        public string Datesort { set; get; }
        public string TempGroupObject { set; get; }
    }
}
