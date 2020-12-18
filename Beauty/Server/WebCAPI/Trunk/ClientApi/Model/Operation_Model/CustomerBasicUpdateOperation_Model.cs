using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class CustomerBasicUpdateOperation_Model
    {

        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public string CustomerName { get; set; }
        public string Title { get; set; }
        public string LoginMobile { get; set; }
        public string Password { get; set; }
        public int CustomerID { get; set; }
        public int AccountID { get; set; }
        public DateTime UpdateTime { get; set; }
        public int PasswordFlag { get; set; }
        public int HeadFlag { get; set; }
        public string HeadImageFile { get; set; }
        public string PinYin { get; set; }
        public string ImageType { get; set; }
        public string ImageString { get; set; }
        public int Gender { get; set; }


    }
}
