using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetBalanceList_Model
    {
        public int ID { get; set; }
        public int Type { get; set; }
        public int Mode { get; set; }
        public decimal Amount { get; set; }
        public decimal Balance { get; set; }
        public string ProductName { get; set; }
        public string Time { get; set; }
        public string Remark { get; set; }
        public int PaymentID { get; set; }
        public int OrderCount { get; set; }
        public string RechargeText { get; set; }
    }

    [Serializable]
    public class GetCustomerBalanceList_Model
    {
        public int BalanceID { get; set; }
        public int PaymentID { get; set; }
        public int ChangeType { get; set; }
        public int TargetAccount { get; set; }
        public string ChangeTypeName { get; set; }
        public DateTime CreateTime { get; set; }
    }

    [Serializable]
    public class GetCardBalanceList_Model
    {
        public int BalanceID { get; set; }
        public int ActionMode { get; set; }
        public DateTime CreateTime { get; set; }
        public decimal Amount { get; set; }
        public decimal Balance { get; set; }
        public string ActionModeName { get; set; }
        public int ActionType { get; set; }
        public int ChangeType { get; set; }
        public int PaymentID { get; set; }
    }
}
