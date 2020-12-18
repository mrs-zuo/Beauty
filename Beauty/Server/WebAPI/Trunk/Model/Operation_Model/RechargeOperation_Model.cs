using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class RechargeOperation_Model
    {
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int CustomerID { get; set; }
        public int ResponsiblePersonID { get; set; }
        public int CreatorID { get; set; }
        public int Mode { get; set; }
        public decimal Amount { get; set; }
        public int Type { get; set; }
        public string Remark { get; set; }
        public int PeopleCount { get; set; }
        public decimal GiveAmount { get; set; }
        public DateTime CreateTime { get; set; }
        public List<int> SlaveID { get; set; }
    }


    [Serializable]
    public class CardRechargeOperation_Model
    {
        /// <summary>
        /// 1:账户消费、2:账户消费撤销、3：账户充值、4：账户充值撤销、5：账户直扣、6：账户直扣撤销(9:退款 也属于账户直扣)
        /// </summary>
        public int ChangeType { get; set; }
        /// <summary>
        /// 1:储值卡、2:积分、3:现金券
        /// </summary>
        public int CardType { get; set; }
        public int DepositMode { get; set; }
        public string UserCardNo { get; set; }
        public int CustomerID { get; set; }
        public int ResponsiblePersonID { get; set; }
        public decimal Amount { get; set; }
        public string Remark { get; set; }
        //业绩提成比例flag
        public int AverageFlag { get; set; }
        //业绩提成比例
        public decimal BranchProfitRate { get; set; }
        public List<Slave_Model> Slavers { get; set; }
        public List<RechargeGiveOperation_Model> GiveList { get; set; }

        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
    }

    [Serializable]
    public class Slave_Model
    {
        public int SlaveID { get; set; }
        public decimal ProfitPct { get; set; }
    }

    [Serializable]
    public class RechargeGiveOperation_Model
    {
        public int CardType { get; set; }
        public string UserCardNo { get; set; }
        public decimal Amount { get; set; }
    }

    [Serializable]
    public class CardOutAndInOperation_Model
    {
        public string OutCardNo { get; set; }
        public int CardID { get; set; }
        public int CustomerID { get; set; }
        public string Remark { get; set; }
        public DateTime CardExpiredDate { get; set; }
        public string RealCardNo { get; set; }
        public bool IsDefault { get; set; }

        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public DateTime Time { get; set; }
        public int OperaterID { get; set; }
    }
}
