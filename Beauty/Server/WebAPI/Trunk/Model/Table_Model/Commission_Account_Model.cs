using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Commission_Account_Model
    {
        public int AccountID { set; get; }
        public decimal BaseSalary { set; get; }
        public int CommType { set; get; }
        public int CommPattern { set; get; }
        public int ProfitRangeUnit { set; get; }
        public int ProfitMinRange { set; get; }
        public int ProfitMaxRange { set; get; }
        public decimal ProfitPct { set; get; }
        public int CompanyID { set; get; }
        public int CreatorID { set; get; }
        public DateTime CreateTime { set; get; }
        public int UpdaterID { set; get; }
        public DateTime UpdateTime { set; get; }
        public int RecordType { set; get; }

        public string HeadImageFile { set; get; }
        public string AccountName { set; get; }
        public int CommPatternSales { set; get; }
        public int CommPatternOperate { set; get; }
        public int CommPatternRecharge { set; get; }
        public List<CommissionDetail_Account> ListCommSales { set; get; }
        public List<CommissionDetail_Account> ListCommOperate { set; get; }
        public List<CommissionDetail_Account> ListCommRecharge { set; get; }
        public List<CommissionDetail_Account> ListComm { set; get; }
    }

    [Serializable]
    public class CommissionDetail_Account {
        public int CommType { set; get; }
        public int CommPattern { set; get; }
        public int ProfitRangeUnit { set; get; }
        public decimal ProfitMinRange { set; get; }
        public decimal ProfitMaxRange { set; get; }
        public decimal ProfitPct { set; get; }
    }
}
