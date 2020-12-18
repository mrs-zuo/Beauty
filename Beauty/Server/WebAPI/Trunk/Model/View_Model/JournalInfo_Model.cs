using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class JournalInfo_Model
    {
        public decimal IncomeAmount { get; set; }
        public decimal SalesAll { get; set; }
        public string SalesAllRatio { get; set; }
        public decimal SalesService { get; set; }
        public string SalesServiceRatio { get; set; }
        public decimal SalesCommodity { get; set; }
        public string SalesCommodityRatio { get; set; }
        public decimal SalesEcard { get; set; }
        public string SalesEcardRatio { get; set; }
        public decimal IncomeOthers { get; set; }
        public string IncomeOthersRatio { get; set; }

        public decimal OutAmout { get; set; }
        public decimal BalanceAmount { get; set; }
        public List<OutInfo_Model> listOutInfo { get; set; }


    }

    [Serializable]
    public class OutInfo_Model {
        public string OutItemName { get; set; }
        public decimal OutItemAmount { get; set; }
        public string OutItemAmountRatio { get; set; }
        public decimal OutItemAmountTotal { get; set; }
    }
}
