using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class AccountSchedule_Model
    {
        public int AccountID { get; set; }
        public string AccountName { get; set; }
        public string AccountCode { get; set; }
        public string Department { get; set; }

        public string PinYin { get; set; }
        public string PinYinFirst { get; set; }

        public List<ScheduleInAccount> ScheduleList { get; set; }
    }

    [Serializable]
    public class ScheduleInAccount
    {
        //public int ScheduleTime { get; set; }
        //public int SpendTime { get; set; }
        //public string ScheduleName { get; set; }
        public DateTime ScdlStartTime { get; set; }
        public DateTime ScdlEndTime { get; set; }
    }
}
