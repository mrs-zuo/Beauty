using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class SubQuery_Model
    {
        public int SuperiorID { get; set; }
        public int SubordinateID { get; set; }
        public int SubBranchID { get; set; }
        public int Level { get; set; }
    }
}
