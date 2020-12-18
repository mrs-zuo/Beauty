using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.Common;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class Customer_BLL
    {
        #region 构造类实例
        public static Customer_BLL Instance
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
            internal static readonly Customer_BLL instance = new Customer_BLL();
        }
        #endregion

        /// <summary>
        /// 二维码获取顾客信息
        /// </summary>
        /// <param name="companyCode"></param>
        /// <param name="customerId"></param>
        /// <param name="accountId"></param>
        /// <returns></returns>
        public ObjectResult<CustomerInfoByQRCode_Model> getCustomerInfoByQRCode(string companyCode, int branchId, long customerId, int accountId)
        {
            return Customer_DAL.Instance.getCustomerInfoByQRCode(companyCode, branchId, customerId, accountId);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="branchId"></param>
        /// <param name="accountId"></param>
        /// <param name="imageWidth"></param>
        /// <param name="imageHeight"></param>
        /// <param name="type"></param>
        /// <param name="CardCode"></param>
        /// <param name="sourceType"></param>
        /// <param name="AccountIDList"></param>
        /// <param name="RegistFrom"></param>
        /// <param name="FirstVisitType"></param>
        /// <param name="FirstVisitDateTime"></param>
        /// <param name="EffectiveCustomerType"></param>
        /// <param name="pageFlg"></param>
        /// <param name="pageIndex"></param>
        /// <param name="pageSize"></param>
        /// <param name="customerName"></param>
        /// <param name="customerTel"></param>
        /// <param name="searchDateTime"></param>
        /// <returns></returns>
        public ObjectResultSup<List<CustomerList_Model>> GetCustomerList(int companyId, int branchId, int accountId, int imageWidth, int imageHeight, int type, string CardCode, int sourceType, List<int> AccountIDList, int RegistFrom,int FirstVisitType, string FirstVisitDateTime,int EffectiveCustomerType,
            bool pageFlg, int pageIndex, int pageSize,
            string customerName, string customerTel, string searchDateTime
            )
        {
            return Customer_DAL.Instance.GetCustomerList(companyId, branchId, accountId, imageWidth, imageHeight, type, CardCode, sourceType, AccountIDList, RegistFrom, FirstVisitType, FirstVisitDateTime, EffectiveCustomerType,
                 pageFlg, pageIndex, pageSize,
                 customerName, customerTel, searchDateTime
                );
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="customerID"></param>
        /// <param name="expirationDate"></param>
        /// <returns></returns>
        public bool UpdateExpirationDateByCustomer(int companyID, int UpdaterID, int customerID, DateTime expirationDate)
        {
            return Customer_DAL.Instance.UpdateExpirationDateByCustomer(companyID, UpdaterID, customerID, expirationDate);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="customerID"></param>
        /// <param name="companyID"></param>
        /// <param name="branchID"></param>
        /// <returns></returns>
        public bool IsExistResponsiblePersonID(int customerID, int companyID, int branchID)
        {
            return Customer_DAL.Instance.IsExistResponsiblePersonID(customerID, companyID, branchID);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="accountID"></param>
        /// <param name="customerID"></param>
        /// <param name="companyID"></param>
        /// <param name="branchID"></param>
        /// <param name="creatorID"></param>
        /// <returns></returns>
        public bool AddResponsiblePersonID(int accountID, int customerID, int companyID, int branchID, int creatorID)
        {
            return Customer_DAL.Instance.AddResponsiblePersonID(accountID, customerID, companyID, branchID, creatorID);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <param name="mImage"></param>
        /// <param name="isLoginMobileFlag"></param>
        /// <returns></returns>
        public CustomerAdd_Model customerAdd(CustomerAddOperation_Model model)
        {
            model.PinYin = CommonUtility.getPinYin(model.CustomerName);
            return Customer_DAL.Instance.customerAdd(model);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool customerUpdateBasic(CustomerBasicUpdateOperation_Model model)
        {
            model.PinYin = CommonUtility.getPinYin(model.CustomerName);
            return Customer_DAL.Instance.customerUpdateBasic(model);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="strMobile"></param>
        /// <param name="userId"></param>
        /// <param name="companyId"></param>
        /// <param name="userType"></param>
        /// <returns></returns>
        public List<UserListWithMobile_Model> userListWithMobile(string strMobile, int userId, int companyId, int userType)
        {
            return Customer_DAL.Instance.userListWithMobile(strMobile, userId, companyId, userType);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="name"></param>
        /// <returns></returns>
        public bool IsExistCustomerName(int companyID, string name)
        {
            return Customer_DAL.Instance.IsExistCustomerName(companyID, name);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="phonenumber"></param>
        /// <returns></returns>
        public string IsExistCustomerPhone(int companyID, string phonenumber)
        {
            return Customer_DAL.Instance.IsExistCustomerPhone(companyID, phonenumber);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool customerUpdateDetail(Customer_Model model)
        {
            return Customer_DAL.Instance.customerUpdateDetail(model);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="customerId"></param>
        /// <returns></returns>
        public CustomerDetail_Model getCustomerDetail(int customerId)
        {
            return Customer_DAL.Instance.getCustomerDetail(customerId);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="customerId"></param>
        /// <param name="branchID"></param>
        /// <param name="imageWidth"></param>
        /// <param name="imageHeight"></param>
        /// <returns></returns>
        public CustomerBasic_Model getCustomerBasic(int customerId, int companyID, int branchID, int imageWidth, int imageHeight)
        {
            return Customer_DAL.Instance.getCustomerBasic(customerId, companyID, branchID, imageWidth, imageHeight);
        }

        public CustomerInfo_Model getCustomerInfo(int customerId, int companyID, int branchID, int imageWidth, int imageHeight)
        {
            return Customer_DAL.Instance.getCustomerInfo(customerId, companyID, branchID, imageWidth, imageHeight);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="AccountID"></param>
        /// <param name="CustomerID"></param>
        /// <returns></returns>
        public bool deleteCustomer(int AccountID, int CustomerID, int CompanyID)
        {
            return Customer_DAL.Instance.deleteCustomer(AccountID, CustomerID, CompanyID);
        }


        public List<QuestionAnswer_Model> getQuestionAnswer(int customerId, int companyId)
        {
            return Customer_DAL.Instance.getQuestionAnswer(customerId, companyId);
        }

        public bool updateAnswer(UpdateAnswerOperation_Model model)
        {
            return Customer_DAL.Instance.updateAnswer(model);
        }


        public CartAndNewMessageCount_Model getCartAndNewMessageCount(UtilityOperation_Model model)
        {
            CartAndNewMessageCount_Model result = new CartAndNewMessageCount_Model();
            result.RemindCount = Task_DAL.Instance.GetScheduleCountByCustomerID(model.CompanyID, model.CustomerID);
            result.PromotionCount = Promotion_DAL.Instance.getPromotionCount(model.CompanyID, 1, model.BranchID);
            result.UnpaidOrderCount = Order_DAL.Instance.getUnpaidOrderCount(model.CustomerID);
            result.UnconfirmedOrderCount = Order_DAL.Instance.getUnconfirmedOrderCount(model.CompanyID, model.CustomerID);
            result.NewMessageCount = Message_DAL.Instance.getMsgCount(model.CustomerID).NewMessageCount;
            result.CartCount = Cart_DAL.Instance.getCartCount(model.CustomerID);
            return result;
        }

        public bool IsExistCustomer(string loginMobile)
        {
            return Customer_DAL.Instance.IsExistCustomer(loginMobile);
        }

        public bool CustomerExistOrderOrRechargeHistory(int customerId, int branchId)
        {
            return Customer_DAL.Instance.CustomerExistOrderOrRechargeHistory(customerId, branchId);
        }

        public bool updateSalesPersonID(int CompanyID, int BranchID, List<int> AccountIDList, int CustomerID, int CreatorID)
        {
            return Customer_DAL.Instance.updateSalesPersonID(CompanyID, BranchID, AccountIDList, CustomerID, CreatorID);
        }

        public List<CustomerSourceType_Model> GetCustomerSourceTypeList(int companyID)
        {
            return Customer_DAL.Instance.GetCustomerSourceTypeList(companyID);
        }
    }
}
