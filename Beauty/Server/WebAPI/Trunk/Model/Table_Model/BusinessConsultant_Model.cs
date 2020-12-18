using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
  public class BusinessConsultant_Model
    {
        public int CompanyID { set; get; }
        public int ID { set; get; }
        public int BusinessType { set; get; }
        public int MasterID { set; get; }
        public int ConsultantType { set; get; }
        public int ConsultantID { set; get; }
        public int CreatorID { set; get; }
        public DateTime CreateTime { set; get; }
        public int UpdaterID { set; get; }
        public DateTime UpdateTime { set; get; }
        public int RecordType { set; get; }
    }
}
