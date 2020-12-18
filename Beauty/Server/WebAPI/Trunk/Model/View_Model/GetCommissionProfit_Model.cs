using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetCommissionProfit_Model
    {
        public string ObjectName { set; get; }
        public decimal SalesProfit { set; get; }
        public decimal SalesComm { set; get; }
        public decimal OptProfit { set; get; }
        public decimal OptComm { set; get; }
        public decimal ECardProfit { set; get; }
        public decimal ECardComm { set; get; }
    }

    [Serializable]
    public class GetAccountCommissionProfit_Model
    {
        public string AccountName { set; get; }
        public decimal AccountProfit { set; get; }
        public decimal AccountComm { set; get; }
        public int SourceType { set; get; }
        public decimal BranchProfitRate { set; get; }
    }
}
