using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetUnfinishOrder_Model
    {
        public int OrderID { get; set; }
        public string ProductName { get; set; }
        public DateTime OrderTime { get; set; }
        public string ResponsiblePersonName { get; set; }
        public int TGExecutingCount { get; set; }
        public int TGFinishedCount { get; set; }
        public int TGTotalCount { get; set; }
        public int ProductType { get; set; }
        public int BranchID { get; set; }
        public int OrderObjectID { get; set; }
    }
}
