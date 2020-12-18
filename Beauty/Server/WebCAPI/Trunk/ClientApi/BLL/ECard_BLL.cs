using ClientAPI.DAL;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.BLL
{
    public class ECard_BLL
    {
        #region 构造类实例
        public static ECard_BLL Instance
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
            internal static readonly ECard_BLL instance = new ECard_BLL();
        }
        #endregion

        public List<GetECardList_Model> GetCustomerCardList(int companyID, int branchID, int customerID)
        {
            List<GetECardList_Model> list = ECard_DAL.Instance.GetCustomerCardList(companyID, branchID, customerID);
            return list;
        }

        public List<GetECardList_Model> GetCustomerPointCouponList(int companyID, int branchID, int customerID)
        {
            List<GetECardList_Model> list = ECard_DAL.Instance.GetCustomerPointCouponList(companyID, branchID, customerID);
            return list;
        }

        public GetCardInfo_Model GetCardInfo(int companyID, int customerID, string userCardNo)
        {
            GetCardInfo_Model model = ECard_DAL.Instance.GetCardInfo(companyID, customerID, userCardNo);
            return model;
        }

        public List<CardDiscountList_Model> GetCardDisCountListByCardID(int companyID, int cardID)
        {
            List<CardDiscountList_Model> list = ECard_DAL.Instance.GetCardDisCountListByCardID(companyID, cardID);
            return list;
        }

        public List<GetCardBalanceList_Model> GetCardBalanceByUserCardNo(int companyID, int branchID, int customerID, string userCardNo, int cardType)
        {
            List<GetCardBalanceList_Model> list = ECard_DAL.Instance.GetCardBalanceByUserCardNo(companyID, branchID, customerID, userCardNo, cardType);
            return list;
        }

        public List<GetCustomerBalanceList_Model> GetBalanceListByCustomerID(int companyID, int branchID, int customerID)
        {
            List<GetCustomerBalanceList_Model> list = ECard_DAL.Instance.GetBalanceListByCustomerID(companyID, branchID, customerID);
            return list;
        }

        public GetBalanceDetail_Model GetBalanceDetail(int companyID, int balanceID, int changeType)
        {
            GetBalanceDetail_Model model = ECard_DAL.Instance.GetBalanceDetail(companyID, balanceID, changeType);
            return model;
        }

        public List<BalanceOrderList_Model> GetBalanceOrderListByPaymentID(int companyID, int paymentID)
        {
            List<BalanceOrderList_Model> list = ECard_DAL.Instance.GetBalanceOrderListByPaymentID(companyID, paymentID);
            return list;
        }

        public int UpdateCustomerDefaultCard(int companyID, int accountID, int customerID, string userCardNo)
        {
            int res = ECard_DAL.Instance.UpdateCustomerDefaultCard(companyID, accountID, customerID, userCardNo);
            return res;
        }

        public List<CustomerEcardDiscount_Model> GetCardDiscountList(int companyID, int branchID, int customerID, long productCode, int productType)
        {
            List<CustomerEcardDiscount_Model> list = ECard_DAL.Instance.GetCardDiscountList(companyID, branchID, customerID, productCode, productType);
            return list;
        }

        public List<CustomerBenefitList_Model> getCustomerBenefitList(int companyID, int customerID, int branchID, int type)
        {
            return ECard_DAL.Instance.getCustomerBenefitList(companyID, customerID, branchID, type);
        }

        public CustomerBenefitDetail_Model getCustomerBenefitDetail(int companyID, int customerID, string benefitID)
        {
            return ECard_DAL.Instance.getCustomerBenefitDetail(companyID, customerID, benefitID);
        }


    }
}
