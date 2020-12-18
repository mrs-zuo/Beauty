using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Task_Model
    {
        public int BranchID { set; get; }
        public long ID { set; get; }
        public int TaskOwnerType { set; get; }
        public int TaskOwnerID { set; get; }
        public int TaskType { set; get; }
        public string TaskName { set; get; }
        public string TaskDescription { set; get; }
        public string TaskResult { set; get; }
        public int TaskStatus { set; get; }
        public DateTime TaskScdlStartTime { set; get; }
        public DateTime TaskScdlEndTime { set; get; }
        public DateTime ExecuteStartTime { set; get; }
        public DateTime ExecuteEndTime { set; get; }
        public int ReservedOrderType { set; get; }
        public int ReservedOrderID { set; get; }
        public int ReservedOrderServiceID { set; get; }
        public long ReservedServiceCode { set; get; }
        public int ReservationConfirmer { set; get; }
        public int ActedOrderID { set; get; }
        public int ActedOrderServiceID { set; get; }
        public long ActedTreatGroupID { set; get; }
        public int CompanyID { set; get; }
        public int CreatorID { set; get; }
        public DateTime CreateTime { set; get; }
        public int UpdaterID { set; get; }
        public DateTime UpdateTime { set; get; }
        public int RecordType { set; get; }
        public string Remark { set; get; }


    }
}
