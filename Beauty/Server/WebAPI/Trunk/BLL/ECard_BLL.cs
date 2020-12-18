using HS.Framework.Common.Util;
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

        public int UpdateCustomerDefaultCard(int companyID, int accountID, int customerID, string userCardNo)
        {
            int res = ECard_DAL.Instance.UpdateCustomerDefaultCard(companyID, accountID, customerID, userCardNo);
            return res;
        }

        public bool UpdateExpirationDate(int companyID, string userCardNo, DateTime cardExpiredDate)
        {
            bool isSuccess = ECard_DAL.Instance.UpdateExpirationDate(companyID, userCardNo, cardExpiredDate);
            return isSuccess;
        }

        public List<GetCompanyCardList_Model> GetBranchCardList(int companyID, int branchID, bool isShowAll, bool isOnlyMoneyCard = false)
        {
            List<GetCompanyCardList_Model> list = ECard_DAL.Instance.GetBranchCardList(companyID, branchID, isShowAll, isOnlyMoneyCard);
            return list;
        }

        public List<CardDiscountList_Model> GetCardDisCountListByCardID(int companyID, int cardID)
        {
            List<CardDiscountList_Model> list = ECard_DAL.Instance.GetCardDisCountListByCardID(companyID, cardID);
            return list;
        }

        public int AddCustomerCard(AddCustomerCardOperation_Model model)
        {
            int res = ECard_DAL.Instance.AddCustomerCard(model);
            return res;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns>0失败,1成功,2充值类型不对,3金额不够</returns>
        public int CardRecharge(CardRechargeOperation_Model model)
        {
            int res = ECard_DAL.Instance.CardRecharge(model);
            return res;
        }

        public int CardRechargeByWeChat(WeChatReturn_Model weChatModel, DateTime time)
        {
            int res = ECard_DAL.Instance.CardRechargeByWeChat(weChatModel, time);
            return res;
        }

        public int CardRechargeByAliPay(Alipay_trade_pay_response aliPayModel, DateTime time)
        {
            int res = ECard_DAL.Instance.CardRechargeByAliPay(aliPayModel, time);
            return res;
        }

        public List<GetCustomerBalanceList_Model> GetBalanceListByCustomerID(int companyID, int branchID, int customerID)
        {
            List<GetCustomerBalanceList_Model> list = ECard_DAL.Instance.GetBalanceListByCustomerID(companyID, branchID, customerID);
            return list;
        }

        public List<GetCardBalanceList_Model> GetCardBalanceByUserCardNo(int companyID, int branchID, int customerID, string userCardNo, int cardType)
        {
            List<GetCardBalanceList_Model> list = ECard_DAL.Instance.GetCardBalanceByUserCardNo(companyID, branchID, customerID, userCardNo, cardType);
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

        public List<CustomerEcardDiscount_Model> GetCardDiscountList(int companyID, int branchID, int customerID, long productCode, int productType)
        {
            List<CustomerEcardDiscount_Model> list = ECard_DAL.Instance.GetCardDiscountList(companyID, branchID, customerID, productCode, productType);
            return list;
        }

        public List<CustomerBenefitList_Model> getCustomerBenefitList(int companyID, int customerID,int branchID, int type)
        {
            List<CustomerBenefitList_Model> list = ECard_DAL.Instance.getCustomerBenefitList(companyID, customerID, branchID, type);
            return list;
        }

        public CustomerBenefitDetail_Model getCustomerBenefitDetail(int companyID, int customerID, string benefitID)
        {
            CustomerBenefitDetail_Model model = ECard_DAL.Instance.getCustomerBenefitDetail(companyID, customerID, benefitID);
            return model;
        }

        public int CardOutAndIn(CardOutAndInOperation_Model model)
        {
            int res = ECard_DAL.Instance.CardOutAndIn(model);
            return res;
        }

        #region WEB方法

        public GetBalanceDetailForWeb_Model GetBalanceDetailForWeb(int companyID, string balanceCode, int BranchID)
        {
            if (balanceCode.Length != 12)
            {
                return null;
            }
            GetBalanceDetailForWeb_Model model = new GetBalanceDetailForWeb_Model();

            int balanceID = StringUtils.GetDbInt(balanceCode.Substring(4, 6));

            if (balanceID > 0)
            {
                model = ECard_DAL.Instance.GetBalanceDetailForWeb(companyID, balanceID,  BranchID);
                if (model != null) {
                    model.accountList = Account_DAL.Instance.getAccountListForBalanceEdit(model.BranchID, model.BalanceID);
                    model.BalanceCode = balanceCode;
                }
            }

            return model;
        }

        public int CancelCharge(int companyID, int branchID, string balanceCode, int updaterID)
        {
            if (balanceCode.Length != 12)
            {
                return 0;
            }
            int balanceID = StringUtils.GetDbInt(balanceCode.Substring(4, 6));

            int res = 0;
            if (balanceID > 0)
            {
                res = ECard_DAL.Instance.CancelCharge(companyID, branchID, balanceID, updaterID);
            }

            return res;
        }

        public int UpdateChargeProfitForWeb(int companyID, string balanceCode, int updaterID, List<Slave_Model> ProfitList)
        {
            if (balanceCode.Length != 12)
            {
                return 0;
            }
            int balanceID = StringUtils.GetDbInt(balanceCode.Substring(4, 6));

            int res = 0;
            if (balanceID > 0)
            {
                res = ECard_DAL.Instance.UpdateChargeProfitForWeb(companyID, balanceID, updaterID, ProfitList);
            }

            return res;
        }



        public bool EdtiBalanceProfit(BalanceForWebOperation_Model model)
        {
            if (model.BalanceCode.Length != 12)
            {
                return false;
            }
            model.BalanceID= StringUtils.GetDbInt(model.BalanceCode.Substring(4, 6));

            bool res = false;
            if (model.BalanceID > 0)
            {
                res = ECard_DAL.Instance.EdtiBalanceProfit(model);
            }

            return res;
        }
        #endregion
    }
}
