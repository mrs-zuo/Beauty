using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class CustomerCard_Model
    {
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int UserID { get; set; }
        public string UserCardNo { get; set; }
        public int CardID { get; set; }
        public string Currency { get; set; }
        public decimal Balance { get; set; }
        public DateTime CardCreatedDate { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
    }
}
