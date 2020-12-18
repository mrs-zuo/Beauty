using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class Journal_Operation
    {
        public int ID { set; get; }
        public int CompanyID { set; get; }
        public int BranchID { set; get; }
        public int NameID { set; get; }
        public int Type { set; get; }
        public string StartDate { set; get; }
        public string EndDate { set; get; }
    }
}
