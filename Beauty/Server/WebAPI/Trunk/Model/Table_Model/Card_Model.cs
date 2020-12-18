using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Card_Model
    {
        public int CompanyID { get; set; }
        public int ID { get; set; }
        public long CardCode { get; set; }
        public int CardTypeID { get; set; }
        public string CardName { get; set; }
        public string CardDescription { get; set; }
        public int VaildPeriod { get; set; }
        public int ValidPeriodUnit { get; set; }
        public decimal StartAmount { get; set; }
        public decimal BalanceNotice { get; set; }
        public decimal Rate { get; set; }
        public int CardBranchType { get; set; }
        public int CardProductType { get; set; }
        public decimal PresentRate { get; set; }
        public bool Available { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public decimal ProfitRate { get; set; }

        public List<CardDiscount_Model> listDiscount { get; set; }
        public List<CardBranch_Model> listBranch { get; set; }
        public bool IsDefault { get; set; }

    }

    [Serializable]
    public class CardDiscount_Model
    {
        public int CardID { get; set; }
        public int DiscountID { get; set; }
        public string DiscountName { get; set; }
        public decimal Discount { get; set; }
    }

     [Serializable]
    public class CardBranch_Model
    {
        public int CardID { get; set; }
        public int BranchID { get; set; }
        public string BranchName { get; set; }
        public int Type { get; set; }
    }
}
