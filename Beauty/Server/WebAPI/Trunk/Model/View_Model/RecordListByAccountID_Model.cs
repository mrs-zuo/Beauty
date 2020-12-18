using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class RecordListByAccountID_Model
    {
        public int RecordCount { get; set; }
        public int PageCount { get; set; }
        public List<RecordList> RecordList { get; set; }
    }

    [Serializable]
    public class RecordList
    {
        public int CustomerID { get; set; }
        public string CustomerName { get; set; }
        public int RecordID { get; set; }
        public string RecordTime { get; set; }
        public string Problem { get; set; }
        public string Suggestion { get; set; }
        public bool IsVisible { get; set; }
        public string ResponsiblePersonName { get; set; }
        public string TagName { set; get; }
        public bool IsThisBranch { set; get; }
    }
}
