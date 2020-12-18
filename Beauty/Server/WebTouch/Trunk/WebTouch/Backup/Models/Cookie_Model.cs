using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebTouch.Models
{
    [Serializable]
    public class Cookie_Model
    {
        public int CO { get; set; }
        public int BR { get; set; }
        public int US { get; set; }
        public string GU { get; set; }
        public string CompanyName { get; set; }
        public string BranchName { get; set; }
        public string Role { get; set; }
        public string Advanced { get; set; }
        public string LoginMobile { get; set; }
        public string Password { get; set; }
        public string AccountName { get; set; }
        public int RoleID { get; set; }
    }
}