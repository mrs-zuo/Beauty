using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class MessageOperation_Model
    {
        public int ImageWidth { get; set; }
        public int ImageHeight { get; set; }
        public int HereUserID { get; set; }
        public int ThereUserID { get; set; }
        public int MessageID { get; set; }
        public int BranchID { get; set; }
    }
}
