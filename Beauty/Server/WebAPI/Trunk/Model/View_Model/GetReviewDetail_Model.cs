using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetReviewDetail_Model
    {
        public long GroupNo { set; get; }
        public string ServiceName { get; set; }
        public DateTime TGEndTime { get; set; }
        public int TGFinishedCount { get; set; }
        public int TGTotalCount { get; set; }
        public string ResponsiblePersonName { get; set; }
        public List<TMReviewDetail_Model> listTM { get; set; }
        public string Comment { get; set; }
        public int Satisfaction { get; set; }
    }

    [Serializable]
    public class TMReviewDetail_Model
    {
        public int TreatmentID { get; set; }
        public string TMExectorName { get; set; }
        public string SubServiceName { get; set; }
        public string Comment { get; set; }
        public int Satisfaction { get; set; }
    }
}
