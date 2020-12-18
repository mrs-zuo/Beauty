using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class CompanyListForAccountLogin_Model
    {
        public int AccountID { set; get; }
        public int RoleID { set; get; }
        public string CompanyName { set; get; }
        public string AccountName { set; get; }
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
        //切换门店标示
        public bool canChangeBranch { set; get; }
        //public List<BranchListForAccountLogin_Model> BranchList { get; set; }
    }
}
