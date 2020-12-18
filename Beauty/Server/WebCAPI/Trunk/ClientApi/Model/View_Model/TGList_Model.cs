using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class TGList_Model
    {
        public int OrderID { get; set; }
        public int OrderObjectID { get; set; }
        public int ProductType { get; set; }
        public string ServicePICName { get; set; }
        public long GroupNo { get; set; }
        public int TotalCount { get; set; }
        public int FinishedCount { get; set; }
        public string ProductName { get; set; }
        public DateTime TGStartTime { get; set; }
    }
}
