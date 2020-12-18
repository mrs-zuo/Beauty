using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class BranchListForAccountLogin_Model
    {
        public int BranchID
        {
            set;
            get;
        }

        public string BranchName
        {
            set;
            get;
        }
    }
}
