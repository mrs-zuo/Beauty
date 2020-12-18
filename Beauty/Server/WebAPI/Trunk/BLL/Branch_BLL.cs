using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class Branch_BLL
    {
        #region 构造类实例
        public static Branch_BLL Instance
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
            internal static readonly Branch_BLL instance = new Branch_BLL();
        }
        #endregion

        public List<GetBranchList_Model> getBranchList(int companyID, int pageIndex, int pageSize, out int recordCount)
        {
            List<GetBranchList_Model> list = Branch_DAL.Instance.getBranchList(companyID, pageIndex, pageSize, out  recordCount);
            return list;
        }

        public GetBranchDetail_Model getBranchDetail(int companyID, int branchID)
        {
            GetBranchDetail_Model model = Branch_DAL.Instance.getBranchDetail(companyID, branchID);
            return model;
        }

        public List<string> getBranchImgList(int companyID, int branchID, int hight, int width, int count = 0)
        {
            List<string> list = Branch_DAL.Instance.getBranchImgList(companyID, branchID, hight, width);
            if (count > 0 && list != null && list.Count > 0 && list.Count > count)
            {
                list = list.Take(count).ToList();
            }
            return list;
        }


        #region 后台方法
        public List<Branch_Model> getBranchListForWeb(int companyID)
        {
            return Branch_DAL.Instance.getBranchListForWeb(companyID);
        }

        public List<Branch_Model> getBranchAvailableList(int companyID)
        {
            return Branch_DAL.Instance.getBranchAvailableList(companyID);
        }

        public int deleteBranch(int branchId, int accountId, bool Available,int CompanyID)
        {
            return Branch_DAL.Instance.deleteBranch(branchId, accountId, Available,CompanyID);
        }

        public Branch_Model getBranchDetailForWeb(int branchID)
        {
            return Branch_DAL.Instance.getBranchDetailForWeb(branchID);
        }

        public int addBranch(Branch_Model model)
        {
            return Branch_DAL.Instance.addBranch(model);
        }


        public bool updateBranch(Branch_Model model)
        {
            return Branch_DAL.Instance.updateBranch(model);
        }


        public bool isCanAddBranch(int companyId)
        {
            return Branch_DAL.Instance.isCanAddBranch(companyId);
        }


        #region 门店页面编辑其他相关内容的方法
        public List<GetBranchMarketRelationShip_Model> getCommodityList(int branchId, int companyId)
        {
            return Branch_DAL.Instance.getCommodityList(branchId, companyId);
        }

        public List<StockCalcType_Model> getStockCalcTypeList()
        {
            return Branch_DAL.Instance.getStockCalcTypeList();
        }

        public bool OperateCommodityBranch(EditMarketRelationShipForBranchOperation_Model model)
        {
            return Branch_DAL.Instance.OperateCommodityBranch(model);
        }

        public List<GetBranchMarketRelationShip_Model> getServiceList(int branchId, int companyId)
        {
            return Branch_DAL.Instance.getServiceList(branchId, companyId);
        }

        public bool OperateServiceBranch(EditMarketRelationShipForBranchOperation_Model model) {

            return Branch_DAL.Instance.OperateServiceBranch(model);
        }


        public PriceRange_Model getPriceRange(int BranchID, int CompanyID) {
            return Branch_DAL.Instance.getPriceRange(BranchID,CompanyID);
        }


        public bool EditPriceRange(PriceRange_Model model) {
            return Branch_DAL.Instance.EditPriceRange(model);
        }
        #endregion


        public List<Account_Model> getAccountListForBranchEdit(int BranchID, int CompanyID) {
            return Branch_DAL.Instance.getAccountListForBranchEdit(BranchID, CompanyID);
        }
        public List<Account_Model> getAccountListForDefaultConsultant(int BranchID, int CompanyID) {
            return Branch_DAL.Instance.getAccountListForDefaultConsultant(BranchID, CompanyID);
        }

        #endregion
    }
}
