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
    public class Account_BLL
    {
        #region 构造类实例
        public static Account_BLL Instance
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
            internal static readonly Account_BLL instance = new Account_BLL();
        }
        #endregion


        /// <summary>
        /// 获取公司下面所有员工
        /// </summary>
        /// <param name="companyID">公司ID</param>
        /// <param name="width">头像宽</param>
        /// <param name="hight">头像高</param>
        /// <param name="pageIndex">当前页数</param>
        /// <param name="pageSize">分页大小</param>
        /// <param name="type">0:抽取全部 1:抽取首页标志</param>
        /// <param name="recordCount">共有多少条</param>
        /// <returns></returns>
        public List<GetAccountList_Model> getAccountList(int companyID, int width, int hight, int pageIndex, int pageSize, int type, out int recordCount)
        {
            List<GetAccountList_Model> list = Account_DAL.Instance.getAccountList(companyID, width, hight, pageIndex, pageSize, type, out recordCount);
            return list;
        }

        public GetAccountList_Model getAccountDetail(int companyID, int accountID, int hight, int width)
        {
            GetAccountList_Model detail = Account_DAL.Instance.getAccountDetail(companyID, accountID, hight, width);
            return detail;
        }

        public List<SubQuery_Model> GetHierarchySubQuery_2_2(int accountID, int branchID)
        {
            List<SubQuery_Model> list = Account_DAL.Instance.GetHierarchySubQuery_2_2(accountID, branchID);
            return list;
        }

        public UserRole_Model getUserRole_2_2(int userId)
        {
            UserRole_Model model = Account_DAL.Instance.getUserRole_2_2(userId);
            return model;
        }

        /// <summary>
        /// 是否已经收藏过了
        /// </summary>
        /// <param name="CompanyID"></param>
        /// <param name="AccountID"></param>
        /// <param name="Code"></param>
        /// <param name="ProductType"></param>
        /// <returns>0:没有收藏 >0:收藏过</returns>
        public int isFavoriteExist(int CompanyID, int branchID, int AccountID, long Code, int ProductType)
        {
            return Account_DAL.Instance.isFavoriteExist(CompanyID, branchID, AccountID, Code, ProductType);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="CompanyID"></param>
        /// <param name="accountID"></param>
        /// <param name="BranchID"></param>
        /// <param name="imageWidth"></param>
        /// <param name="imageHeight"></param>
        /// <returns></returns>
        public List<AccountList_Model> getAccountList_new(int CompanyID, int accountID, int BranchID, string TagIDs, int imageWidth, int imageHeight)
        {
            List<int> tagIDs = new List<int>();
            if (!string.IsNullOrWhiteSpace(TagIDs))
            {
                string[] arrayTagIDs = TagIDs.Split(new string[] { "|" }, StringSplitOptions.RemoveEmptyEntries);
                if (arrayTagIDs != null && arrayTagIDs.Length > 0)
                {
                    foreach (string TagID in arrayTagIDs)
                    {
                        int idTemp = HS.Framework.Common.Util.StringUtils.GetDbInt(TagID, 0);
                        if (idTemp <= 0)
                        {
                            tagIDs = null;
                            break;
                        }
                        tagIDs.Add(idTemp);
                    }
                }
            }
            return Account_DAL.Instance.getAccountList_new(CompanyID, accountID, BranchID, tagIDs, imageWidth, imageHeight);
        }

        /// <summary>
        /// 返回顾客的专属顾问/销售顾问
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="branchID"></param>
        /// <param name="customerID"></param>
        /// <param name="type">1:专属顾问 2:销售顾问</param>
        /// <returns></returns>
        public List<int> GetRelationshipByCustomerID(int companyID, int branchID, int customerID, int type = 1)
        {
            List<int> res = Account_DAL.Instance.GetRelationshipByCustomerID(companyID, branchID, customerID, type);
            return res;
        }

        public List<AccountList_Model> getAccountListForCustomer(int companyId, int branchId, int customerId, int flag, int imageWidth, int imageHeight, string strTagIDs)
        {
            return Account_DAL.Instance.getAccountListForCustomer(companyId, branchId, customerId, flag, imageWidth, imageHeight, strTagIDs);
        }

        public List<ScheduleInAccount> getScheduleListByAccount(int accountID, int branchID, DateTime? date, int CompanyID)
        {
            return Account_DAL.Instance.getScheduleListByAccount(accountID, branchID, date, CompanyID);
        }


        public List<AccountList_Model> getAccountListByCompanyID(int companyID, int branchID, string TagIDs, int imageWidth, int imageHeight)
        {
            List<int> tagIDs = new List<int>();
            if (!string.IsNullOrWhiteSpace(TagIDs))
            {
                string[] arrayTagIDs = TagIDs.Split(new string[] { "|" }, StringSplitOptions.RemoveEmptyEntries);
                if (arrayTagIDs != null && arrayTagIDs.Length > 0)
                {
                    foreach (string TagID in arrayTagIDs)
                    {
                        int idTemp = HS.Framework.Common.Util.StringUtils.GetDbInt(TagID, 0);
                        if (idTemp <= 0)
                        {
                            tagIDs = null;
                            break;
                        }
                        tagIDs.Add(idTemp);
                    }
                }
            }
            return Account_DAL.Instance.getAccountListByCompanyID(companyID, branchID, tagIDs, imageWidth, imageHeight);
        }

        public AccountDetail_Model getAccountDetail(int accountId, int imageWidth, int imageHeight)
        {
            return Account_DAL.Instance.getAccountDetail(accountId, imageWidth, imageHeight);
        }



        public List<FavoriteList_Model> getFavoriteByAccountID(int CompanyID, int AccountID, int BranchID, int ProductType, int imageWidth, int imageHeight, int customerId)
        {
            return Account_DAL.Instance.getFavoriteByAccountID(CompanyID, AccountID, BranchID, ProductType, imageWidth, imageHeight, customerId);
        }

        public int deleteFavorite(int ID)
        {
            return Account_DAL.Instance.deleteFavorite(ID);
        }

        public int addFavorite(Favorite_Model model)
        {
            return Account_DAL.Instance.addFavorite(model);
        }

        public bool updateAccDetail(UpdateAccountDetailOperation_Model model)
        {
            return Account_DAL.Instance.updateAccDetail(model);
        }

        /// <summary>
        /// 改变美容师状态
        /// </summary>
        /// <param name="customerId"></param>
        /// <returns></returns>
        public bool changeAccState(int companyId, int accountId, int available)
        {
            return Account_DAL.Instance.changeAccState(companyId, accountId, available);
        }


        public AccountInfo_Model getAccountCountInfo(int companyID)
        {
            return Account_DAL.Instance.getAccountCountInfo(companyID);
        }

        public int AttendanceByAccount(int companyID, int branchID, int accountID, DateTime nowTime, int CheckOnAccID)
        {
            int res = Account_DAL.Instance.AttendanceByAccount(companyID, branchID, accountID, nowTime, CheckOnAccID);
            return res;
        }

        #region
        public List<AccountListForWeb_Model> getAccountListForWeb(int userId, int branchId, int companyId, int available, string strInput)
        {
            return Account_DAL.Instance.getAccountListForWeb(userId, branchId, companyId, available, strInput);
        }

        public List<GetAccountListByGroupFroWeb_Model> getAccountListUsedByGroupForWeb(int companyID, int tagID = 0)
        {
            List<GetAccountListByGroupFroWeb_Model> list = Account_DAL.Instance.getAccountListUsedByGroupForWeb(companyID, tagID);
            return list;
        }


        public Account_Model getAccountDetailForWeb(int userId, int companyId)
        {
            return Account_DAL.Instance.getAccountDetailForWeb(userId, companyId);
        }


        public List<BranchSelection_Model> getBranchIDListForWeb(int companyID, int userID, int branchID)
        {
            return Account_DAL.Instance.getBranchIDListForWeb(companyID, userID, branchID);
        }

        public List<AccountTag_Model> getTagsIDListForWeb(int companyID, int userID, int branchID = 0)
        {
            return Account_DAL.Instance.getTagsIDListForWeb(companyID, userID, branchID);
        }

        public int AddAccount(Account_Model model)
        {
            return Account_DAL.Instance.AddAccount(model);
        }


        public bool UpdateAccount(Account_Model model)
        {
            return Account_DAL.Instance.UpdateAccount(model);
        }

        public bool IsExsitAccountMobileInCompany(Account_Model model)
        {
            return Account_DAL.Instance.IsExsitAccountMobileInCompany(model);
        }


        public bool IsExsitAccountNameInCompany(Account_Model model)
        {
            return Account_DAL.Instance.IsExsitAccountNameInCompany(model);
        }


        public List<Hierarchy_Model> getHierarchyList(int userId, int type)
        {
            return Account_DAL.Instance.getHierarchyList(userId, type);
        }

        public Hierarchy_Model getLoginAccount(int userId)
        {
            return Account_DAL.Instance.getLoginAccount(userId);
        }

        public Hierarchy_Model getTopAccount(int userId)
        {
            return Account_DAL.Instance.getTopAccount(userId);
        }


        public Hierarchy_Model getHierarchyDetail(int hierarchyId)
        {
            return Account_DAL.Instance.getHierarchyDetail(hierarchyId);
        }


        public int UpdateHierarchy(Hierarchy_Model model)
        {
            return Account_DAL.Instance.UpdateHierarchy(model);
        }


        public bool resetPassword(Account_Model model)
        {
            return Account_DAL.Instance.resetPassword(model);
        }


        public bool OperateBranch(AccountBranchOperation_Model model)
        {
            return Account_DAL.Instance.OperateBranch(model);
        }

        public int checkAccountBranchCancel(int accountId, int branchId)
        {
            return Account_DAL.Instance.checkAccountBranchCancel(accountId, branchId);
        }

        public List<AccountList_Model> getAccountListByTagID(int companyID, int branchID, int tagID, int hight, int width)
        {
            List<AccountList_Model> list = Account_DAL.Instance.getAccountListByTagID(companyID, branchID, tagID, hight, width);
            return list;
        }


        public bool isCanAddAccount(int companyId)
        {
            return Account_DAL.Instance.isCanAddAccount(companyId);
        }

        public int CanDeleteAccount(int accountId, int companyId)
        {
            return Account_DAL.Instance.CanDeleteAccount(accountId, companyId);
        }

        public bool EditAccountSort(Branch_Model model)
        {
            return Account_DAL.Instance.EditAccountSort(model);
        }

        #endregion
    }
}
