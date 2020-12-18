using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class Opportunity_BLL
    {
        #region 构造类实例
        public static Opportunity_BLL Instance
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
            internal static readonly Opportunity_BLL instance = new Opportunity_BLL();
        }
        #endregion

        public List<OpportunityList_Model> getOpportunityList(GetOpportunityListOperation_Model model, int pageSize, int pageIndex, out int recordCount)
        {
            List<OpportunityList_Model> list = Opportunity_DAL.Instance.getOpportunityList(model, pageSize, pageIndex, out recordCount);
            return list;
        }

        public OpportunityDetail_Model getOpportunityDetail(int opportunityId, int productType)
        {
            OpportunityDetail_Model model = Opportunity_DAL.Instance.getOpportunityDetail(opportunityId, productType);
            return model;
        }

        public int GetMaxStepId(int companyId, Int64 stepCode)
        {
            int res = Opportunity_DAL.Instance.GetMaxStepId(companyId, stepCode);
            return res;
        }

        public bool addOpportunity(OpportunityAddOperation_Model model)
        {
            bool res = Opportunity_DAL.Instance.addOpportunity(model);
            return res;
        }

        public bool deleteOpportunity(int AccountID, int OpportunityID)
        {
            bool res = Opportunity_DAL.Instance.deleteOpportunity(AccountID, OpportunityID);
            return res;
        }

        public List<ProgressList_Model> getProgressHistory(int opportunityId)
        {
            List<ProgressList_Model> list = Opportunity_DAL.Instance.getProgressHistory(opportunityId);
            return list;
        }

        public ProgressDetail_Model getProgressDetail(int progressId, int productType)
        {
            ProgressDetail_Model model = Opportunity_DAL.Instance.getProgressDetail(progressId, productType);
            return model;
        }

        public bool addProgress(ProgressOperation_Model model)
        {
            bool res = Opportunity_DAL.Instance.addProgress(model);
            return res;
        }

        public bool updateProgress(ProgressOperation_Model model)
        {
            bool res = Opportunity_DAL.Instance.updateProgress(model);
            return res;
        }

        public int getStepNumber(int opportunityId)
        {
            int res = Opportunity_DAL.Instance.getStepNumber(opportunityId);
            return res;
        }

        public List<GetStepList_Model> GetStepListByCompanyID(int companyID)
        {
            List<GetStepList_Model> list = Opportunity_DAL.Instance.GetStepListByCompanyID(companyID);
            return list;
        }
    }
}
