using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{

    [Serializable]
    public class Review_Model
    {
        public long GroupNo { set; get; }
        public int TreatmentID { get; set; }
        public int ReviewID { set; get; }
        public string Comment { set; get; }
        public int Satisfaction { set; get; }
        public int CompanyID { set; get; }
        public int CreatorID { set; get; }
        public DateTime CreateTime { set; get; }
        public int UpdaterID { set; get; }
        public DateTime UpdateTime { set; get; }
        public int RecordType { set; get; }
        public int OrderID { set; get; }
        public string SubServiceName { set; get; }
        public string ExecuteName { set; get; }
    }
}
