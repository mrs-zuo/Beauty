using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetScheduleDetail_Model
    {
        public long TaskID { get; set; }
        public int TaskOwnerID { get; set; }
        public string TaskOwnerName { get; set; }
        public string BranchName { get; set; }
        public DateTime TaskScdlStartTime { get; set; }
        public long ProductCode { get; set; }
        public string ProductName { get; set; }
        public int AccountID { get; set; }
        public string AccountName { get; set; }
        public string Remark { get; set; }
        public int TaskType { get; set; }
        public int OrderID { get; set; }
        public int OrderObjectID { get; set; }
        public string OrderNumber { get; set; }
        public decimal TotalSalePrice { get; set; }
        public string TaskDescription { get; set; }
        public string TaskResult { get; set; }
        public int TaskStatus { get; set; }
        public DateTime OrderCreateTime { get; set; }
        public DateTime? ExecuteStartTime { get; set; }
        public DateTime CreateTime { get; set; }

        public int BranchID { get; set; }
    }
}
