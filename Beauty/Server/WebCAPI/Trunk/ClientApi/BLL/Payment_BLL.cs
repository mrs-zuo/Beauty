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
    public class Payment_BLL
    {
        #region 构造类实例
        public static Payment_BLL Instance
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
            internal static readonly Payment_BLL instance = new Payment_BLL();
        }
        #endregion

        public PaymentInfo_Model getPaymentInfo(GetPaymentInfoOperation_Model operationModel)
        {
            PaymentInfo_Model model = Payment_DAL.Instance.getPaymentInfo(operationModel);
            model.IsPartPay = false;
            return model;
        }

        public int PayAdd(PaymentAddOperation_Model model)
        {
            if (model.OrderIDList == null || model.OrderIDList.Count <= 0)
            {
                return 0;
            }

            int res = Payment_DAL.Instance.PayAdd(model, model.OrderIDList);
            return res;
        }

        public List<UnPaidList_Model> getUnPaidList(int companyID, int branchID)
        {
            List<UnPaidList_Model> list = Payment_DAL.Instance.getUnPaidList(companyID, branchID);
            return list;
        }

        public List<UnPaidListByCustomerID_Model> getUnPaidListByCustomerID(int companyID, int CustomerID)
        {
            List<UnPaidListByCustomerID_Model> list = Payment_DAL.Instance.getUnPaidListByCustomerID(companyID, CustomerID);
            return list;
        }

        public List<UnPaidListTG_Model> getUnPaidTGList(int companyID, int orderObjectID, int productType)
        {
            List<UnPaidListTG_Model> list = Payment_DAL.Instance.getUnPaidTGList(companyID, orderObjectID, productType);
            return list;
        }

        public List<PaymentDetailByOrderID_Model> GetPaymentListByOrderID(int companyID, int orderID, int paymentID)
        {
            List<PaymentDetailByOrderID_Model> list = Payment_DAL.Instance.GetPaymentListByOrderID(companyID, orderID, paymentID);
            return list;
        }



        public List<PaymentDetailList_Model> GetPayDetailListByPaymentID(int companyID, int paymentID)
        {
            List<PaymentDetailList_Model> list = Payment_DAL.Instance.GetPayDetailListByPaymentID(companyID, paymentID);
            return list;
        }

        public List<Profit_Model> getProfitListByMasterID(int masterID, int type)
        {
            List<Profit_Model> list = Payment_DAL.Instance.getProfitListByMasterID(masterID, type);
            return list;
        }

        public List<PaymentOrderList_Model> getOrderListByPaymentID(int companyID, int paymentID)
        {
            List<PaymentOrderList_Model> list = Payment_DAL.Instance.getOrderListByPaymentID(companyID, paymentID);
            return list;
        }

        /// <summary>
        /// 是否处理过 -1:NetTradeNo不存在 0:没有处理过 1:已经处理过
        /// </summary>
        /// <param name="netTradeNo"></param>
        /// <returns>-1:NetTradeNo不存在 0:没有处理过 1:已经处理过</returns>
        public int HasTradePay(string netTradeNo)
        {
            int res = Payment_DAL.Instance.HasTradePay(netTradeNo);
            return res;
        }


        public WeChatPayResault_Model GetWeChatPayResault(string netTradeNo, int companyID = 0)
        {
            WeChatPayResault_Model model = Payment_DAL.Instance.GetWeChatPayResault(netTradeNo, companyID);
            return model;
        }

        public bool DeleteNetTradeControl(string netTradeNo)
        {
            bool res = Payment_DAL.Instance.DeleteNetTradeControl(netTradeNo);
            return res;
        }

        public bool AddWeiXinResult(WeChatReturn_Model weChatModel, int CompanyID, DateTime time, int userID)
        {
            bool res = Payment_DAL.Instance.AddWeiXinResult(weChatModel, CompanyID, time, userID);
            return res;
        }

        public int AddRushTradePay(WeChatReturn_Model weChatModel, DateTime time)
        {
            int res = Payment_DAL.Instance.AddRushTradePay(weChatModel, time);
            return res;
        }

        public List<WeChatPayResault_Model> GetWeChatPayResaultByID(int companyID, string netTradeNo = "", int orderID = 0, int customerID = 0, string userCardNo = "")
        {
            List<WeChatPayResault_Model> list = Payment_DAL.Instance.GetWeChatPayResaultByID(companyID, netTradeNo, orderID, customerID, userCardNo);
            return list;
        }
    }
}
