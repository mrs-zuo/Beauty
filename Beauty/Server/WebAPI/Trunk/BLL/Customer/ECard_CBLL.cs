using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL.Customer;

namespace WebAPI.BLL.Customer
{
    public class ECard_CBLL
    {
        #region 构造类实例
        public static ECard_CBLL Instance
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
            internal static readonly ECard_CBLL instance = new ECard_CBLL();
        }
        #endregion

        public List<GetECardList_Model> GetCustomerCardList(int companyID, int branchID, int customerID)
        {
            List<GetECardList_Model> list = ECard_CDAL.Instance.GetCustomerCardList(companyID, branchID, customerID);
            return list;
        }

        public List<GetECardList_Model> GetCustomerPointCouponList(int companyID, int branchID, int customerID)
        {
            List<GetECardList_Model> list = ECard_CDAL.Instance.GetCustomerPointCouponList(companyID, branchID, customerID);
            return list;
        }

        public GetCardInfo_Model GetCardInfo(int companyID, int customerID, string userCardNo)
        {
            GetCardInfo_Model model = ECard_CDAL.Instance.GetCardInfo(companyID, customerID, userCardNo);
            return model;
        }

        public List<GetCompanyCardList_Model> GetBranchCardList(int companyID, int branchID, bool isShowAll, bool isOnlyMoneyCard = false)
        {
            List<GetCompanyCardList_Model> list = ECard_CDAL.Instance.GetBranchCardList(companyID, branchID, isShowAll, isOnlyMoneyCard);
            return list;
        }

        public List<CardDiscountList_Model> GetCardDisCountListByCardID(int companyID, int cardID)
        {
            List<CardDiscountList_Model> list = ECard_CDAL.Instance.GetCardDisCountListByCardID(companyID, cardID);
            return list;
        }

        public List<GetCustomerBalanceList_Model> GetBalanceListByCustomerID(int companyID, int branchID, int customerID)
        {
            List<GetCustomerBalanceList_Model> list = ECard_CDAL.Instance.GetBalanceListByCustomerID(companyID, branchID, customerID);
            return list;
        }

        public List<GetCardBalanceList_Model> GetCardBalanceByUserCardNo(int companyID, int branchID, int customerID, string userCardNo, int cardType)
        {
            List<GetCardBalanceList_Model> list = ECard_CDAL.Instance.GetCardBalanceByUserCardNo(companyID, branchID, customerID, userCardNo, cardType);
            return list;
        }

        public GetBalanceDetail_Model GetBalanceDetail(int companyID, int balanceID, int changeType)
        {
            GetBalanceDetail_Model model = ECard_CDAL.Instance.GetBalanceDetail(companyID, balanceID, changeType);
            return model;
        }

        public List<BalanceOrderList_Model> GetBalanceOrderListByPaymentID(int companyID, int paymentID)
        {
            List<BalanceOrderList_Model> list = ECard_CDAL.Instance.GetBalanceOrderListByPaymentID(companyID, paymentID);
            return list;
        }

        public List<CustomerEcardDiscount_Model> GetCardDiscountList(int companyID, int branchID, int customerID, long productCode, int productType)
        {
            List<CustomerEcardDiscount_Model> list = ECard_CDAL.Instance.GetCardDiscountList(companyID, branchID, customerID, productCode, productType);
            return list;
        }
    }
}
