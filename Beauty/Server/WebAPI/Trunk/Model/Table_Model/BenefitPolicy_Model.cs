using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class BenefitPolicy_Model
    {
        public string PolicyID { get; set; }
        public string PolicyName { get; set; }
        public int PolicyType { get; set; }
        public int PolicyActType { get; set; }
        public int PolicyActPosition { get; set; }
        public string PolicyDescription { get; set; }
        public string PolicyComments { get; set; }
        public int Amount { get; set; }
        public DateTime StartDate { get; set; }
        public string PRCode { get; set; }
        public decimal PRValue1 { get; set; }
        public decimal PRValue2 { get; set; }
        public decimal PRValue3 { get; set; }
        public decimal PRValue4 { get; set; }
        public int ValidDays { get; set; }
        public int CompanyID { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public int RecordType { get; set; }

        public List<BranchSelection_Model> listBranch { get; set; }
        public List<PromotionRule_Model> listRule { get; set; }

    }
}
