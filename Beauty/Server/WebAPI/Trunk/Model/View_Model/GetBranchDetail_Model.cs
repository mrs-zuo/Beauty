using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetBranchDetail_Model
    {
        public int BranchID { get; set; }
        public string BranchName { get; set; }
        public string Summary { get; set; }
        public string Contact { get; set; }
        public string Phone { get; set; }
        public string Fax { get; set; }
        public string Address { get; set; }
        public string Zip { get; set; }
        public string Web { get; set; }
        public string BusinessHours { get; set; }
        public string Remark { get; set; }
        public bool Visible { get; set; }
        public decimal Longitude { get; set; }
        public decimal Latitude { get; set; }
        public DateTime StartTime { get; set; }
        public decimal RemindTime { get; set; }
        public bool IsShowECardHis { get; set; }
        public bool IsConfirmed { get; set; }
        public bool IsPay { get; set; }
        public string DefaultPassword { get; set; }
        public int BirthdayRemindTime { get; set; }
        public bool IsPartPay { get; set; }

        public List<string> ImgList { get; set; }
    }
}
