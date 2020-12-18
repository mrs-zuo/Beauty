using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class CheckAuthenticationCode_Model
    {
        public string LoginMobile { get; set; }
        public string AuthenticationCode { get; set; }
    }
}
