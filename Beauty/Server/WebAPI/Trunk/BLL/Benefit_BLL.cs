using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class Benefit_BLL
    {  
        #region 构造类实例
        public static Benefit_BLL Instance
        {
            get
            {
                return Nested.instance;
            }
        }

        class Nested
        {
            static Nested()
            {
            }
            internal static readonly Benefit_BLL instance = new Benefit_BLL();
        }
        #endregion


        public List<BenefitPolicy_Model> getBenefitList(int companyId,int branchId) {
            return Benefit_DAL.Instance.getBenefitList(companyId, branchId);
        }

        public BenefitPolicy_Model getBenefitDetail(int companyId, string policyId)
        {
            return Benefit_DAL.Instance.getBenefitDetail(companyId, policyId);
        }

        public string AddBenefitPolicy(BenefitPolicy_Model model) {
            return Benefit_DAL.Instance.AddBenefitPolicy(model);
        }


        public bool UpdateBenefitPolicy(BenefitPolicy_Model model) {
            return Benefit_DAL.Instance.UpdateBenefitPolicy(model);
        }


        public bool DeteleBenefitPolicy(BenefitPolicy_Model model) {
            return Benefit_DAL.Instance.DeteleBenefitPolicy(model);
        }
        public List<PromotionRule_Model> getBenfitRule() {
            return Benefit_DAL.Instance.getBenfitRule();
        }


        public int OperateBranch(BranchSelectOperation_Model model) {
            return Benefit_DAL.Instance.OperateBranch(model);
        }
    }
}
