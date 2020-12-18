using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class RecordListByCustomerID_Model
    {
        public int CreatorID { get; set; }
        public string CreatorName { get; set; }
        public int RecordID { get; set; }
        public string RecordTime { get; set; }
        public string Problem { get; set; }
        public string Suggestion { get; set; }
        public bool IsVisible { get; set; }
        public string TagName { set; get; }
    }
}
