using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class CompanyListForCustomerLogin_Model
    {
        public int CustomerID { set; get; }
        public string CompanyName { set; get; }
        public string CustomerName { set; get; }
        public string CompanyCode { set; get; }
        public int CompanyScale { set; get; }
        public int CompanyID { set; get; }
        public string CompanyAbbreviation { set; get; }
        public int BranchID { set; get; }
        public string BranchName { set; get; }
        public int BranchCount { set; get; }
        public string HeadImageURL { set; get; }
        public string CurrencySymbol { set; get; }
        public string Advanced { set; get; }

        public int PromotionCount { set; get; }
        public int NewMessageCount { set; get; }
        public int RemindCount { set; get; }
        public int TotalMessageCount { set; get; }
        public decimal Discount { set; get; }
        public int UnpaidOrderCount { set; get; }
        public int UnconfirmedOrderCount { set; get; }
    }
}
