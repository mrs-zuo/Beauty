using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class CustomerBasic_Model
    {
        public int CustomerID { get; set; }
        public string CustomerName { get; set; }
        public string LoginMobile { get; set; }
        public string HeadImageURL { get; set; }
        public int Gender { get; set; }

        public List<CustomerBasicBranch_Model> BranchList { get; set; }
    }

    public class CustomerBasicBranch_Model
    {
        public int BranchID { get; set; }
        public string BranchName { get; set; }
        public int ResponsiblePersonID { get; set; }
        public string ResponsiblePersonName { get; set; }
    }
}
