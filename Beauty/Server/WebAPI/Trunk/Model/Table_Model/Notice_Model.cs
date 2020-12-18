using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Notice_Model
    {
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int ID { get; set; }
        public string NoticeTitle { get; set; }
        public string NoticeContent { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public bool Available { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public int TYPE { get; set; }
    }
}
