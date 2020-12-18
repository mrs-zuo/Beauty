using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetReviewList_Model
    {
        public long GroupNo { set; get; }
        public string ServiceName { get; set; }
        public DateTime TGEndTime { get; set; }
        public int TGFinishedCount { get; set; }
        public int TGTotalCount { get; set; }
        public string ResponsiblePersonName { get; set; }
        public int OrderObjectID { get; set; }
    }
}
