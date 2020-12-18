using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetPushPoolList_Model
    {
        public int CompanyID { get; set; }
        public long ID { get; set; }
        public long SourceID { get; set; }
        public int PushType { get; set; }
        public string PushMessage { get; set; }
        public string PhoneNumber { get; set; }
        public string DeviceID { get; set; }
        public int DeviceType { get; set; }
        public int PushTargetType { get; set; }
        public string WeChatOpenID { get; set; }
        public string TaskName { get; set; }
        public DateTime TaskScdlStartTime { get; set; }
    }
}
