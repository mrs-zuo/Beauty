using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class RegisterOperation_Model
    {
        public string LoginMobile { get; set; }
        public string AuthenticationCode { get; set; }
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public string Password { get; set; }
        public DateTime CreateTime { get; set; }
    }
}
