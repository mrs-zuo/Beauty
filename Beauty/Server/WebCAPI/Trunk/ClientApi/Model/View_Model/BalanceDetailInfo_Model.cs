using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class BalanceDetailInfo_Model
    {
        public decimal Amount { get; set; }
        public string Mode { get; set; }
        public string Remark { get; set; }
        public string Operator { get; set; }
        public DateTime? CreateTime { get; set; }
        public decimal Balance { get; set; }
        public int BalanceID { get; set; }

    }

    [Serializable]
    public class GetBalanceDetail_Model
    {
        public string BalanceNumber { get; set; }
        public int BalanceID { get; set; }
        public decimal Amount { get; set; }
        public int PaymentID { get; set; }
        public string ChangeTypeName { get; set; }
        public string Remark { get; set; }
        public string Operator { get; set; }
        public DateTime CreateTime { get; set; }
        public int TargetAccount { get; set; }
        public string BranchName { get; set; }

        public BalanceInfo_Model BalanceMain { get; set; }
        public BalanceInfo_Model BalanceSec { get; set; }
        public List<BalanceOrderList_Model> OrderList { get; set; }
    }

    [Serializable]
    public class BalanceInfo_Model
    {
        public string ActionModeName { get; set; }
        public int ActionMode { get; set; }
        public List<BalanceCardDetail_Model> BalanceCardList { get; set; }
    }

    [Serializable]
    public class BalanceCardDetail_Model
    {
        public int ActionMode { get; set; }
        public string ActionModeName { get; set; }
        public int CardType { get; set; }
        public string CardName { get; set; }
        public decimal Amount { get; set; }
        public decimal Balance { get; set; }
        public string UserCardNo { get; set; }
        public decimal CardPaidAmount { get; set; }
        public int DepositMode { get; set; }
        public string DepositModeName { get; set; }
    }

    [Serializable]
    public class BalanceOrderList_Model
    {
        public int OrderID { get; set; }
        public string OrderNumber { get; set; }
        public string ProductName { get; set; }
        public int ProductType { get; set; }
        public decimal TotalSalePrice { get; set; }
        public int OrderObjectID { get; set; }
    }
}
