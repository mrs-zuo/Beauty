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
        public bool IsPast { get; set; }
        public int Gender { get; set; }
        public int SourceType { get; set; }

        public List<PhoneOperation> PhoneList { get; set; }
        public List<EmailOperation> EmailList { get; set; }
        public List<AddressOperation> AddressList { get; set; }

    }

    [Serializable]
    public class PhoneOperation
    {
        public int OperationFlag { get; set; }
        public int PhoneID { get; set; }
        public int PhoneType { get; set; }
        public string PhoneContent { get; set; }
    }

    [Serializable]
    public class EmailOperation
    {
        public int OperationFlag { get; set; }
        public int EmailID { get; set; }
        public int EmailType { get; set; }
        public string EmailContent { get; set; }
    }

    [Serializable]
    public class AddressOperation
    {
        public int OperationFlag { get; set; }
        public int AddressID { get; set; }
        public int AddressType { get; set; }
        public string AddressContent { get; set; }
        public string ZipCode { get; set; }
    }
}
