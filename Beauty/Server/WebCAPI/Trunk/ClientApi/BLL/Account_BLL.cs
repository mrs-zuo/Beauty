using ClientAPI.DAL;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.BLL
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

        public List<AccountList_Model> getAccountListForCustomer(int companyId, int branchId, int customerId, int flag, int imageWidth, int imageHeight)
        {
            return Account_DAL.Instance.getAccountListForCustomer(companyId, branchId, customerId, flag, imageWidth, imageHeight);
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
        public int GetRelationshipByCustomerID(int companyID, int branchID, int customerID, int type = 1)
        {
            int res = Account_DAL.Instance.GetRelationshipByCustomerID(companyID, branchID, customerID, type);
            return res;
        }

        public List<AccountList_Model> getAccountListByBranchID(int companyId, int branchId)
        {
            return Account_DAL.Instance.getAccountListByBranchID(companyId, branchId);
        }

    }
}
