using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetRemindList_Model
    {
        public List<RemindList_Model> RemindList { get; set; }
        public List<BirthdayList_Model> BirthdayList { get; set; }
        public List<VistList_Model> VisitList { get; set; }
    }

    [Serializable]
    public class RemindList_Model
    {
        public int OrderID { get; set; }
        public string RemindContent { get; set; }
        public DateTime ScheduleTime { get; set; }
        public int ScheduleType { get; set; }
    }

    [Serializable]
    public class BirthdayList_Model
    {
        public string RemindContent { get; set; }
        public string BirthDay { get; set; }
    }

    [Serializable]
    public class VistList_Model
    {
        public int OrderID { get; set; }
        public string RemindContent { get; set; }
        public DateTime UpdateTime { get; set; }
    }
}
