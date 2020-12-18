using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetEcardInfo_Model
    {
        public DateTime ExpirationDate { get; set; }
        public decimal Balance { get; set; }
        public int LevelID { get; set; }
        public string LevelName { get; set; }
        public decimal Discount { get; set; }
        public bool IsShowECardHis { get; set; }
    }

    [Serializable]
    public class GetCardInfo_Model
    {
        public int CardID { get; set; }
        public string CardName { get; set; }
        public string UserCardNo { get; set; }
        public decimal Balance { get; set; }
        public string Currency { get; set; }
        public DateTime CardCreatedDate { get; set; }
        public DateTime CardExpiredDate { get; set; }
        public string CardDescription { get; set; }
        public int CardType { get; set; }
        public string CardTypeName { get; set; }
        public string RealCardNo { get; set; }
        public bool IsDefaultCard { get; set; }

        public List<CardDiscountList_Model> DiscountList { get; set; }
    }

    [Serializable]
    public class GetMstCard_Model
    {
        public int CardID { get; set; }
        public int VaildPeriod { get; set; }
        public int ValidPeriodUnit { get; set; }
        public long CardCode { get; set; }
    }
}
