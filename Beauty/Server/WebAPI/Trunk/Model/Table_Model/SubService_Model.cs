using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class SubService_Model
    {
        public int ID { set; get; }
        public long SubServiceCode { set; get; }
        public int CompanyID { set; get; }
        public string SubServiceName { set; get; }
        public int VisitTime { set; get; }
        public bool NeedVisit { set; get; }
        public int SpendTime { set; get; }
        public bool Available { set; get; }
        public int CreatorID { set; get; }
        public DateTime CreateTime { set; get; }
        public int UpdaterID { set; get; }
        public DateTime UpdateTime { set; get; }
    }
}
