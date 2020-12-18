using ClientAPI.DAL;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.BLL
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

        public CustomerInfo_Model getCustomerInfo(int companyID, int customerId, int imageWidth, int imageHeight)
        {
            CustomerInfo_Model model = Customer_DAL.Instance.getCustomerInfo(companyID, customerId, imageWidth, imageHeight);
            return model;
        }

        public CustomerBasic_Model getCustomerBasic(int companyID, int customerId, int imageWidth, int imageHeight)
        {
            CustomerBasic_Model model = Customer_DAL.Instance.getCustomerBasic(companyID, customerId, imageWidth, imageHeight);
            return model;
        }

        public bool customerUpdateBasic(CustomerBasicUpdateOperation_Model model)
        {
            bool res = Customer_DAL.Instance.customerUpdateBasic(model);
            return res;
        }

        public CartAndNewMessageCount_Model getCartAndNewMessageCount(UtilityOperation_Model model)
        {
            CartAndNewMessageCount_Model result = new CartAndNewMessageCount_Model();
            result.RemindCount = Task_DAL.Instance.GetScheduleCountByCustomerID(model.CompanyID, model.CustomerID);
            result.PromotionCount = Promotion_DAL.Instance.getPromotionCount(model.CompanyID, 1, model.BranchID);
            result.UnpaidOrderCount = Order_DAL.Instance.getUnpaidOrderCount(model.CustomerID);
            result.UnconfirmedOrderCount = Order_DAL.Instance.getUnconfirmedOrderCount(model.CompanyID, model.CustomerID);
            result.NewMessageCount = Message_DAL.Instance.getMsgCount(model.CustomerID).NewMessageCount;
            result.CartCount = Cart_DAL.Instance.getCartCount(model.CompanyID, model.CustomerID);
            return result;
        }


        public bool IsExistCustomer(string loginMobile, int companyId)
        {
            return Customer_DAL.Instance.IsExistCustomer(loginMobile,companyId);
        }

        public bool IsExistFavorite(int companyID, int customerID, long productCode, int productType, out string userFavoriteID)
        {
            bool isSuccess = Customer_DAL.Instance.IsExistFavorite(companyID, customerID, productCode, productType, out userFavoriteID);
            return isSuccess;
        }

        public List<FavoriteList_Model> getFavorteList(int companyID, int customerID, int productType, int imageWidth, int imageHeight)
        {
            List<FavoriteList_Model> list = Customer_DAL.Instance.getFavorteList(companyID, customerID, productType, imageWidth, imageHeight);
            if (list != null && list.Count > 0)
            {
                list = list.OrderByDescending(x => x.CreateTime).ToList();
            }
            return list;
        }

        public int addFavorite(CustomerFavorite_Model model)
        {
            string userFavoriteID = "";
            bool isExistFavorte = IsExistFavorite(model.CompanyID, model.CustomerID, model.ProductCode, model.ProductType, out userFavoriteID);
            if (!isExistFavorte)
            {
                int res = Customer_DAL.Instance.addFavorite(model);
                return res;
            }
            else
            {
                return 2;
            }
        }

        public bool delFavorite(CustomerFavorite_Model model)
        {
            bool res = Customer_DAL.Instance.delFavorite(model);
            return res;
        }
        public UtilityOperation_Model getCustomerInfo(string loginMobile, int companyId)
        {
           return Customer_DAL.Instance.getCustomerInfo(loginMobile, companyId);
        }
    }
}
