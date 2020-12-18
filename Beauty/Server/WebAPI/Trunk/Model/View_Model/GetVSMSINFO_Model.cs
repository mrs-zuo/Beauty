using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetVSMSINFO_Model
    {
        public int COMPANYID { get; set; }
        public int SMSNum { get; set; }
        public int SentNum { get; set; }
        public string StartDate { get; set; }
        public string EndDate { get; set; }
    }
}
