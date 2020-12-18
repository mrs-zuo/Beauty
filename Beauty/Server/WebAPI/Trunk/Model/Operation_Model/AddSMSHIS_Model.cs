using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class AddSMSHIS_Model
    {
        public int SMSHISNO { get; set; }
        public int COMPANYID { get; set; }
        public string RcvNumber { get; set; }
        public DateTime SendTime { get; set; }
        public string SMSContent { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
    }
}
