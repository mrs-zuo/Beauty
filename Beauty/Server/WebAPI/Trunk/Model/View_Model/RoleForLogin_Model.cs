using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class RoleForLogin_Model
    {
        public int CompanyID { set; get; }
        public int BranchID { set; get; }
        public int UserID { set; get; }
        public int RoleID { set; get; }
        public int IsAccountPayEcard { set; get; }
        public string Role { set; get; }
        public string GUID { set;get; }
        public bool ComissionCalc { set; get; }
    }
}
