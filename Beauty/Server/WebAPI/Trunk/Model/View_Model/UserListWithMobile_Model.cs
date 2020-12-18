using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class UserListWithMobile_Model
    {
        public int UserID { get; set; }
        public string LoginMobile { get; set; }
        public string Password { get; set; }
    }
}
