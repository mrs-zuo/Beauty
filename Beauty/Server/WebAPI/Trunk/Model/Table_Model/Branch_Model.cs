using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Branch_Model
    {
        public int CompanyID { get; set; }
        public int ID { get; set; }
        public string BranchName { get; set; }
        public string Summary { get; set; }
        public string Contact { get; set; }
        public string Phone { get; set; }
        public string Fax { get; set; }
        public string Web { get; set; }
        public string Address { get; set; }
        public string Zip { get; set; }
        public decimal Longitude { get; set; }
        public decimal Latitude { get; set; }
        public string BusinessHours { get; set; }
        public string Remark { get; set; }
        public bool Visible { get; set; }
        public bool Available { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public string StartTime { get; set; }
        public decimal RemindTime { get; set; }
        public bool IsShowECardHis { get; set; }
        public bool IsConfirmed { get; set; }
        public bool IsPay { get; set; }
        public string DefaultPassword { get; set; }
        public int BirthdayRemindTime { get; set; }
        public bool IsPartPay { get; set; }
        public List<string> BigImageUrl { get; set; }
        public int IsUseRate { get; set; }
        public int DefaultConsultant { get; set; }
        public List<string> DeleteImageUrl { get; set; }

        public List<AccountSort_Model> ListAccountSort { get; set; }
        public int UserID { get; set; }
        public int LostRemind { get; set; }
        public int ExpiryRemind { get; set; }
        public decimal CommissionRate { get; set; }
        public DateTime ? IssuedDate { get; set; }
    }

    [Serializable]
    public class BranchSelection_Model
    {
        public int BranchID { get; set; }
        public string BranchName { get; set; }
        public bool IsExist { get; set; }
        public bool VisibleForCustomer { get; set; }
    }

    [Serializable]
    public class BranchSelectOperation_Model
    {
        public int CompanyID { get; set; }
        public string ObjectCode { get; set; }
        public int ObjectID { get; set; }
        public int ObjectType { get; set; }
        public List<int> BranchList { get; set; }
        public int OperatorID { get; set; }
        public DateTime OperatorTime { get; set; }
    }
}
