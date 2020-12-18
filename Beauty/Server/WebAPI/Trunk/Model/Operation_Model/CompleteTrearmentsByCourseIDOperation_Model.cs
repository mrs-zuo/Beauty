using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class CompleteTrearmentsByCourseIDOperation_Model
    {

        public int OrderID { get; set; }
        public int CourseID { get; set; }
        public Group Group { get; set; }
        public int UpdaterID { get; set; }
        public int CustomerID { get; set; }
        public int BranchID { get; set; }
        public int Status { get; set; }
        public DateTime? FinishTime { get; set; }

    }
}
