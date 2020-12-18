using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class CustomerBasic_Model
    {
      public int CustomerID{get;set;}
      public string CustomerName { get; set; }
      public string Title {get;set;}
      public string LoginMobile { get; set; }
      public int ResponsiblePersonID { get; set; }
      public string ResponsiblePersonName { get; set; }
      //public int SalesID { get; set; }
      //public string SalesName { get; set; }
      public string HeadImageURL { get; set; }
      public bool IsPast { get; set; }
      public int Gender { get; set; }
      public int ScheduleCount { get; set; }
      public int RegistFrom { get; set; }
      public string SourceTypeName { get; set; }
      public int SourceTypeID { get; set; }
      

      public List<Email> EmailList { get; set; }
      public List<Phone> PhoneList { get; set; }
      public List<Address> AddressList { get; set; }
      public List<Sales_Model> SalesList { get; set; }

    }

    [Serializable]
    public class CustomerInfo_Model
    {
        public string CustomerName { get; set; }
        public string LoginMobile { get; set; }
        public int ResponsiblePersonID { get; set; }
        public string HeadImageURL { get; set; }
        public int ScheduleCount { get; set; }
        public int UnPaidCount { get; set; }
        public string DefaultCardNo { get; set; }
    }
}
