using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class AddCustomerCardOperation_Model
    {
        public int CardID { get; set; }
        public bool IsDefault { get; set; }
        public int CustomerID { get; set; }
        public string Currency { get; set; }
        public DateTime CardCreatedDate { get; set; }
        public DateTime CardExpiredDate { get; set; }
        public string RealCardNo { get; set; }

        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public DateTime LocalTime { get; set; }
        public int AccountID { get; set; }

    }

    [Serializable]
    public class UpdateCustomerCardExpiredDateOperation_Model
    {
        public string UserCardNo { get; set; }
        public DateTime CardExpiredDate { get; set; }
        public int CompanyID { get; set; }
    }
}
