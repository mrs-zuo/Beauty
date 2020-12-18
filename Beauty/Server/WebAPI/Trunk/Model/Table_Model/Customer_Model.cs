using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Customer_Model
    {
        /// <summary>
        /// 
        /// </summary>
        public Array PhoneArray
        {
            set;
            get;
        }

        /// <summary>
        /// 
        /// </summary>
        public int UserID
        {
            set;
            get;
        }

        /// <summary>
        /// 
        /// </summary>
        public int LoginMobileFlag
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public int CompanyID
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public int BranchID
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public string Password
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public int PasswordFlag
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public string Name
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public string Title
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public string Profession
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public string Email
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public sbyte EmailType
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public int EmailId
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public string Phone
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public sbyte PhoneType
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public int PhoneId
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public string Address
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public sbyte AddressType
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public int AddressId
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public string Zip
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public string Remark
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public string LoginMobile
        {
            set;
            get;
        }

        /// <summary>
        /// 
        /// </summary>
        public string HeadImage
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public int? Gender
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public decimal? Height
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public decimal? Weight
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public string BloodType
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public DateTime? BirthDay
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public int? Marriage
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public bool Available
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public int? CreatorID
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public DateTime? CreateTime
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public int? UpdaterID
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public DateTime? UpdateTime
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public string WholePin
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public string FirstPin
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public int RelationShipID
        {
            set;
            get;
        }

        public int ResponsiblePersonID
        {
            set;
            get;
        }
        /// <summary>
        /// 
        /// </summary>
        public string PinYin
        {
            set;
            get;
        }

        public int AccountID
        {
            set;
            get;
        }
        public int CustomerID
        {
            set;
            get;
        }

        List<Phone> PhoneList { get; set; }
        List<Email> EmailList { get; set; }
        List<Address> AddressList { get; set; }
        public string SearchOut { get; set; }
    }

    [Serializable]
    public class Phone 
    {
        public int PhoneID{ get;set;}
        public int PhoneType { get; set; }
        public string PhoneContent { get; set; }
    }

    [Serializable]
    public class Email
    {
       public int EmailID{ get;set;}
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
