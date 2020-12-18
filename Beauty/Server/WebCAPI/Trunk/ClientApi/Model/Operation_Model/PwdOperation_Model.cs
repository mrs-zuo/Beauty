using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class PwdOperation_Model
    {
        public string PwdCompanyID { get; set; }
        public string PwdCustomerID { get; set; }
        public string PwdGroupNo { get; set; }

        public int ImageWidth { get; set; }
        public int ImageHeight { get; set; }
    }
}
