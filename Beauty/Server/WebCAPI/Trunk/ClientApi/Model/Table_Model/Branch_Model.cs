using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    public class Branch_Model
    {

    }

    [Serializable]
    public class SimpleBranch_Model
    {
        public int BranchID { get; set; }
        public string BranchName { get; set; }
    }
}
