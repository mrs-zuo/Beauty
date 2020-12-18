using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetBalanceDetailForWeb_Model
    {
        public string BalanceCode { get; set; }
        public string BalanceNumber { get; set; }
        public int ChangeType { get; set; }
        public int BalanceID { get; set; }
        public decimal Amount { get; set; }
        public int PaymentID { get; set; }
        public string ChangeTypeName { get; set; }
        public string Remark { get; set; }
        public string Operator { get; set; }
        public DateTime? CreateTime { get; set; }
        public int TargetAccount { get; set; }
        public int CustomerID { get; set; }
        public int BranchID { get; set; }

        public List<AccountList_Model> accountList { get; set; }
        public List<Profit_Model> ProfitList { get; set; }
        public List<BalanceInfo_Model> BalanceList { get; set; }
        public List<BalanceInfo_Model> GiveList { get; set; }
    }
}
