using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class ExecutingOrder_Model
    {
        public string ProductName { get; set; }
        public int TotalCount { get; set; }
        public int FinishedCount { get; set; }
        public int ExecutingCount { get; set; }
        public DateTime OrderTime { get; set; }
        public string AccountName { get; set; }
        public int AccountID { get; set; }
        public int OrderID { get; set; }
        public int OrderObjectID { get; set; }
        public int ProductType { get; set; }
    }
}
