using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class Report_BLL
    {
        #region 构造类实例
        public static Report_BLL Instance
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
            internal static readonly Report_BLL instance = new Report_BLL();
        }
        #endregion

        public List<GetReportList_Model> getAccountReportList(int accountId, int cycleType, string startTime, string endtime, int branchId)
        {
            return Report_DAL.Instance.getAccountReportList(accountId, cycleType, startTime, endtime, branchId);
        }

        //public GetReportBasic_Model getReportBasic(int accountId, int branchId, int objectType, int cycleType, string startTime, string endtime) {
        //    return Report_DAL.Instance.getReportBasic(accountId,branchId,objectType,cycleType,startTime,endtime);
        //}

        public GetReportDetail_Model getServiceCountDeatail(int accountId, int branchId, int objectType, int cycleType, string startTime, string endtime, int companyId, int StatementCategoryID)
        {
            return Report_DAL.Instance.getServiceCountDeatail(accountId, branchId, objectType, cycleType, startTime, endtime, companyId, StatementCategoryID);
        }

        public GetReportDetail_Model getCustomerReportDetail(int accountId, int branchId, int cycleType, string startTime, string endtime, int productType, int objectType, int sortType, int companyId, int StatementCategoryID)
        {
            return Report_DAL.Instance.getCustomerReportDetail(accountId, branchId, cycleType, startTime, endtime, productType, objectType, sortType, companyId,StatementCategoryID);
        }

        public GetReportDetail_Model getOrderReportDetail(int accountId, int branchId, int companyId, int cycleType, string startTime, string endtime, int productType, int extractItemType, int objectType, int sortType, int StatementCategoryID)
        {
            return Report_DAL.Instance.getOrderReportDetail(accountId, branchId, companyId, cycleType, startTime, endtime, productType, extractItemType, objectType, sortType, StatementCategoryID);
        }
        public ReportBranchCount_Model getTotalCountReport(int companyId, int branchId)
        {
            return Report_DAL.Instance.getTotalCountReport(companyId, branchId);
        }
        public GetReportBasic_Model getReportBasic(int accountId, int branchId, int objectType, int cycleType, string startTime, string endtime, int companyId, int statementCategoryID)
        {
            return Report_DAL.Instance.getReportBasic(accountId, branchId, objectType, cycleType, startTime, endtime, companyId, statementCategoryID);
        }

        public GetReportDetail_Model getBalanceReportDetail(int accountId, int cycleType, string startTime, string endtime, int branchId, int objectType)
        {
            return Report_DAL.Instance.getBalanceReportDetail(accountId, cycleType, startTime, endtime, branchId, objectType);
        }

        public GetReportDetail_Model getServiceExecuteDetail(int accountId, int cycleType, string startTime, string endtime, int branchId, int objectType, int sortType, int companyId, int StatementCategoryID)
        {
            return Report_DAL.Instance.getServiceExecuteDetail(accountId, cycleType, startTime, endtime, branchId, objectType, sortType, companyId, StatementCategoryID);
        }

        public GetReportDetail_Model getCustomerTreatmentDetail(int accountId, int cycleType, string startTime, string endtime, int branchId, int objectType, int companyId, int StatementCategoryID)
        {
            return Report_DAL.Instance.getCustomerTreatmentDetail(accountId, cycleType, startTime, endtime, branchId, objectType, companyId, StatementCategoryID);
        }

        public GetBranchBusinessDetail_Model getBranchBusinessDetail(int cycleType, string startTime, string endtime, int branchId, int companyId)
        {
            return Report_DAL.Instance.getBranchBusinessDetail(cycleType, startTime, endtime, branchId, companyId);
        }

        public GetReportBasic_Model getCustomerBasic(int accountId, int branchId, int objectType, int cycleType, string startTime, string endtime, int companyId) {
            return Report_DAL.Instance.getCustomerBasic( accountId,  branchId,  objectType,  cycleType,  startTime,  endtime,  companyId) ;
        }

        public GetReportBasic_Model getEcardBasic(int accountId, int branchId, int objectType, int cycleType, string startTime, string endtime, int companyId)
        {
            return Report_DAL.Instance.getEcardBasic(accountId, branchId, objectType, cycleType, startTime, endtime, companyId);
        }

        public List<CardInfo_Model> getCardInfo(int CompanyID, int BranchID) {
            return Report_DAL.Instance.getCardInfo(CompanyID, BranchID);
        }

        public GetCommissionProfit_Model GetAccountCommProfit(int CompanyID, int AccountID, string startTime, string endtime, int BranchID)
        {
            return Report_DAL.Instance.GetAccountCommProfit(CompanyID, AccountID,   startTime,  endtime, BranchID);
        }

        public JournalInfo_Model GetJournalInfo(int CompanyID, string startTime, string endtime, int BranchID,int CycleType) {
            return Report_DAL.Instance.GetJournalInfo(CompanyID,  startTime, endtime, BranchID, CycleType);
        }
    }
}
