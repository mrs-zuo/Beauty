using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetRemindListByCustomerID_Model
    {
        public string ScheduleTime { get; set; }
        public string ServiceName { get; set; }
        public string Excutor { get; set; }
        public string ExcutorMobile { get; set; }
        public string ResponserPerson { get; set; }
        public string ResponserPersonMobile { get; set; }
        public int ExecutorID { get; set; }
        public int ResponsiblePersonID { get; set; }
        public bool ExecutorChat_Use { get; set; }
        public bool ResponsiblePersonChat_Use { get; set; }
        public string Phone { get; set; }
    }
}
