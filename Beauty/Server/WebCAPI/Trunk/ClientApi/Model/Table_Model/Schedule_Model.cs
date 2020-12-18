using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public  class Schedule_Model
    {
        public int BranchID { set; get; }
        public long ID { set; get; }
        public int ScheduleType { set; get; }
        public int UserID { set; get; }
        public long TaskID { set; get; }
        public string ScheduleName { set; get; }
        public string ScheduleDescription { set; get; }
        public DateTime ScdlStartTime { set; get; }
        public DateTime ScdlEndTime { set; get; }
        public DateTime ExecuteStartTime { set; get; }
        public DateTime ExecuteEndTime { set; get; }
        public int Reminded { set; get; }
        public int Repeat { set; get; }
        public string Remark { set; get; }
        public int ScheduleStatus { set; get; }
        public int CompanyID { set; get; }
        public int CreatorID { set; get; }
        public DateTime CreateTime { set; get; }
        public int UpdaterID { set; get; }
        public DateTime UpdateTime { set; get; }
        public int RecordType { set; get; }
    }
}
