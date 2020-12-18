using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetGroupInfoForWeb_Model
    {
        public long GroupNo { get; set; }
        public int OrderID { get; set; }
        public int ServicePicID { get; set; }
        public string ServiceName { get; set; }
        public int Status { get; set; }
        public string ServicePicName { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public List<TreatmentForWeb> TreatmentList { get; set; }
        public List<AccountList_Model> AccountList { get; set; }
    }

    [Serializable]
    public class TreatmentForWeb
    {
        public string SubServiceName { get; set; }
        public int ExecutorID { get; set; }
        public string ExecutorName { get; set; }
        public int TreatmentID { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public int Status { get; set; }
    }
}
