using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class UpdateUserPassword_Model
    {
        public int UserID { get; set; }
        public string OldPassword { get; set; }

        public string NewPassword { get; set; } 
    }
}
