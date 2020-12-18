using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class UserRole_Model
    {
        public int RoleID { get; set; }
        public bool IsPay { get; set; }
        public string Jurisdictions { get; set; }
        public string IsPartPay { get; set; }
    }
}
