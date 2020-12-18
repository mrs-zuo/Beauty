using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class CustomerBenefitList_Model
    {
        public string PolicyID { get; set; }
        public string PolicyName { get; set; }
        public string BenefitID { get; set; }
        /// <summary>
        /// 政策内容
        /// </summary>
        public string PolicyActPosition { get; set; }

        public string PolicyDescription { get; set; }
        public string PRCode { get; set; }
        public decimal PRValue1 { get; set; }
        public decimal PRValue2 { get; set; }
        public decimal PRValue3 { get; set; }
        public decimal PRValue4 { get; set; }
    }

    [Serializable]
    public class CustomerBenefitDetail_Model
    {
        public string PolicyID { get; set; }
        public string PolicyName { get; set; }
        public string PolicyDescription { get; set; }
        /// <summary>
        /// 政策内容
        /// </summary>
        public string PolicyActPosition { get; set; }
        /// <summary>
        /// 细则说明
        /// </summary>
        public string PolicyComments { get; set; }
        /// <summary>
        /// 发放日
        /// </summary>
        public DateTime GrantDate { get; set; }
        /// <summary>
        /// 最终有效日
        /// </summary>
        public DateTime ValidDate { get; set; }
        public string PRCode { get; set; }
        public decimal PRValue1 { get; set; }
        public decimal PRValue2 { get; set; }
        public decimal PRValue3 { get; set; }
        public decimal PRValue4 { get; set; }
        public int BenefitStatus { get; set; }
        public List<SimpleBranch_Model> BranchList { get; set; }
    }
}
