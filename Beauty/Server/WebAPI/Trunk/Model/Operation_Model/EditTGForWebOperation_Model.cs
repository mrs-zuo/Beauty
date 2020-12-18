using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class EditTGForWebOperation_Model
    {
        public int CompanyID { get; set; }
        public long GroupNo { get; set; }
        public int ServicePicID { get; set; }
        public int Status { get; set; }
        public DateTime StartTime { get; set; }
        public DateTime? EndTime { get; set; }
        public List<TreatmentForWeb> TreatmentList { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
    }
}
