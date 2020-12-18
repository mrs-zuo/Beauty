using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class GetTaskListOperation_Model
    {
        public GetTaskListOperation_Model()
        {
            this.PageIndex = 1;
            this.PageSize = 10;
        }
        public List<int> Status { get; set; }

        public int FilterByTimeFlag { get; set; }
        public string StartTime { get; set; }
        public string EndTime { get; set; }
        public int PageIndex { get; set; }
        public int PageSize { get; set; }
        public int CompanyID { get; set; }

        public List<int> ResponsiblePersonIDs { get; set; }
        public int CustomerID { get; set; }
        public DateTime? TaskScdlStartTime { get; set; }
        public int BranchID { get; set; }

        //1:服务预约 2:订单回访 3:联系任务 4:生日回访
        public List<int> TaskType { get; set; }
    }
}
