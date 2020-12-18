using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class TreatmentDetailForWeb_Model
    {
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public string TreatmentCode { get; set; }
        public string ServiceName { get; set; }
        public string ServiceDetail { get; set; }
        public string ExecutorName { get; set; }
        public DateTime? ScheduleTime { get; set; }
        public bool IsDesignated { get; set; }
        public int Status { get; set; }
    }
}
