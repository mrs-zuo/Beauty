using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class CustomerAddOperation_Model
    {
        public string ImageType { get; set; }
        public int HeadFlag { get; set; }
        public bool IsCheck { get; set; }
        public bool PasswordFlag { get; set; }
        public bool isLoginMobileFlag { get; set; }
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public string LoginMobile { get; set; }
        public string Password { get; set; }
        public string CustomerName { get; set; }
        public string Title { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int LevelID { get; set; }
        public string ImageString { get; set; }
        public string FileName { get; set; }
        public string PinYin { get; set; }
        public int ImageHeight { get; set; }
        public int ImageWidth { get; set; }
        public int ResponsiblePersonID { get; set; }
        public bool IsPast { get; set; }
        //public int SalesPersonID { get; set; }
        public int CardID { get; set; }
        public int Gender { get; set; }
        public int SourceType { get; set; }
        public List<int> SalesPersonIDList { get; set; }
        public List<Email> EmailList { get; set; }
        public List<Phone> PhoneList { get; set; }
        public List<Address> AddressList { get; set; }

    }
    [Serializable]
    public class Phone
    {
        public int PhoneID { get; set; }
        public int PhoneType { get; set; }
        public string PhoneContent { get; set; }
    }

    [Serializable]
    public class Email
    {
        public int EmailID { get; set; }
        public int EmailType { get; set; }
        public string EmailContent { get; set; }
    }

    [Serializable]
    public class Address
    {
        public int AddressID { get; set; }
        public int AddressType { get; set; }
        public string AddressContent { get; set; }
        public string ZipCode { get; set; }
    }
}
