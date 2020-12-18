using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class AccountBranchOperation_Model
    {
        public int CompanyID { get; set; }
        public int UserID { get; set; }
        public List<BranchSelection_Model> BranchList { get; set; }
        public int OperatorID { get; set; }
        public DateTime OperatorTime { get; set; }
    }
}
