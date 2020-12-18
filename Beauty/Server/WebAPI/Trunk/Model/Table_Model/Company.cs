using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Company
    {
        public string Name { get; set; }
        public DateTime CreateTime { get; set; }
    }

    [Serializable]
    public class Company_Model
    {
        public int ID { get; set; }
        public string CompanyCode { get; set; }
        public int AccountNumber { get; set; }
        public int BranchNumber { get; set; }
        public string Name { get; set; }
        public string Abbreviation { get; set; }
        public int CompanyScale { get; set; }
        public string Summary { get; set; }
        public string Contact { get; set; }
        public string Phone { get; set; }
        public string Fax { get; set; }
        public string Web { get; set; }
        public int SettlementCurrency { get; set; }
        public string Remark { get; set; }
        public bool Visible { get; set; }
        public bool Available { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public string Advanced { get; set; }
        public decimal MemorySpace { get; set; }
        public int DefaultLevelID { get; set; }
        public bool BalanceRemind { get; set; }
        public List<string> BigImageUrl { get; set; }
        public List<string> deleteImageUrl { get; set; }
        public string Style { get; set; }
        public bool ComissionCalc { get; set; }
        public bool AppointmentMustPaid { get; set; }
        public decimal CommissionRate { get; set; }
        public DateTime ? IssuedDate { get; set; }
    }
}
