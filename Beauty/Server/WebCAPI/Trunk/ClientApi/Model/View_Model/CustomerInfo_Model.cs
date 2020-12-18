using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class CustomerInfo_Model
    {
        public string CompanyCode { get; set; }
        public string CustomerName { get; set; }
        public string LoginMobile { get; set; }
        public string HeadImageURL { get; set; }
        //public int ScheduleCount { get; set; }
        public int AllOrderCount { get; set; }
        public int UnPaidCount { get; set; }
        public int NeedConfirmTGCount { get; set; }
        public int NeedReviewTGCount { get; set; }
        public string DefaultCardNo { get; set; }
    }
}
