using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetECardList_Model
    {
        public string UserCardNo { get; set; }
        public string CardName { get; set; }
        public bool IsDefault { get; set; }
        public int CardTypeID { get; set; }
        public decimal Balance { get; set; }
        public decimal Rate { get; set; }
        public decimal PresentRate { get; set; }
    }

    [Serializable]
    public class GetCompanyCardList_Model
    {
        public int CardID { get; set; }
        public int CardTypeID { get; set; }
        public string CardCode { get; set; }
        public string CardName { get; set; }
        public string CardDescription { get; set; }
        public DateTime CardExpiredDate { get; set; }
        public bool IsDefault { get; set; }

        public List<CardDiscountList_Model> DiscountList { get; set; }
    }

    [Serializable]
    public class CardDiscountList_Model
    {
        public string DiscountName { get; set; }
        public decimal Discount { get; set; }
    }

    [Serializable]
    public class CustomerEcardDiscount_Model
    {
        public int CardID { get; set; }
        public string UserCardNo { get; set; }
        public string CardName { get; set; }
        public decimal Discount { get; set; }
    }
}
