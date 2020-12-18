using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class TreatmentDelOperation_Model
    {
        public int CustomerID { get; set; }
        public int UpdaterID { get; set; }
        public int BranchID { get; set; }
        public int OrderID { get; set; }
        public Group Group { get; set; }

        public DateTime UpdateTime { get; set; }
    }
}
