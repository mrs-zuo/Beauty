using HS.Framework.Common.Entity;
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

        public List<PaymentList_Model> getPaymentList(UtilityOperation_Model model)
        {
            List<PaymentList_Model> list = Payment_DAL.Instance.getPaymentList(model);
            return list;
        }

        //public PaymentDetailInfo_Model getPaymentDetail(UtilityOperation_Model model)
        //{
        //    PaymentDetailInfo_Model res = Payment_DAL.Instance.getPaymentDetail(model);
        //    return res;
        //}

        /// <summary>
        /// GetPaymentDetailModeAmount
        /// </summary>
        /// <param name="paymentID"></param>
        /// <param name="mode">0:现金 1:E卡 2:银行卡 3:其他</param>
        /// <returns></returns>
        public decimal GetPaymentDetailModeAmount(int paymentID, int mode)
        {
            decimal res = Payment_DAL.Instance.GetPaymentDetailModeAmount(paymentID, mode);
            return res;
        }

        public List<GetBalanceList_Model> getBalanceList(int customerId)
        {
            List<GetBalanceList_Model> list = Payment_DAL.Instance.getBalanceList(customerId);
            return list;
        }

        public bool rechargeBanlance(RechargeOperation_Model model)
        {
            bool res = Payment_DAL.Instance.rechargeBanlance(model);
            return res;
        }

        public BalanceDetailInfo_Model getBalanceDetail(int balanceId)
        {
            BalanceDetailInfo_Model model = Payment_DAL.Instance.getBalanceDetail(balanceId);
            return model;
        }


        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        public PaymentInfo_Model getPaymentInfo(GetPaymentInfoOperation_Model operationModel)
        {
            PaymentInfo_Model model = Payment_DAL.Instance.getPaymentInfo(operationModel);

            if (operationModel.OrderList != null && operationModel.OrderList.Count > 1)
            {
                model.IsPartPay = false;
            }
            return model;
        }

        public int PayAdd(PaymentAddOperationList_Model model)
        {
            int res = Payment_DAL.Instance.PayAdd(model);
            return res;
        }

        /*public int PayRefund(PaymentRefundOperationList_Modelcs paymentRefundOperationListModel)
        {
            int res = Payment_DAL.Instance.PayRefund(paymentRefundOperationListModel);
            return res;
        }*/
        public int PayRefund(PaymentRefundOperation_Modelcs paymentRefundOperationModel)
        {
            int res = Payment_DAL.Instance.PayRefund(paymentRefundOperationModel);
            return res;
        }

        public RefundOrderInfo_Model getRefundOrderInfo(int companyID, int branchID, int customerID, int orderID, int productType, out int res)
        {
            RefundOrderInfo_Model model = Payment_DAL.Instance.getRefundOrderInfo(companyID, branchID, customerID, orderID, productType, out res);
            return model;
        }

        public List<PaymentDetailByOrderID_Model> GetPaymentListByOrderID(int companyID, int orderID, int paymentID)
        {
            List<PaymentDetailByOrderID_Model> list = Payment_DAL.Instance.GetPaymentListByOrderID(companyID, orderID, paymentID);
            return list;
        }

        public List<PaymentOrderList_Model> getOrderListByPaymentID(int companyID, int paymentID)
        {
            List<PaymentOrderList_Model> list = Payment_DAL.Instance.getOrderListByPaymentID(companyID, paymentID);
            return list;
        }

        public List<PaymentDetailList_Model> GetPayDetailListByPaymentID(int companyID, int paymentID)
        {
            List<PaymentDetailList_Model> list = Payment_DAL.Instance.GetPayDetailListByPaymentID(companyID, paymentID);
            return list;
        }

        public List<UnPaidList_Model> getUnPaidList(int companyID, int branchID)
        {
            List<UnPaidList_Model> list = Payment_DAL.Instance.getUnPaidList(companyID, branchID);
            return list;
        }

        public List<UnPaidListByCustomerID_Model> getUnPaidListByCustomerID(int companyID, int branchID, int CustomerID)
        {
            List<UnPaidListByCustomerID_Model> list = Payment_DAL.Instance.getUnPaidListByCustomerID(companyID, branchID, CustomerID);
            return list;
        }

        public List<UnPaidListTG_Model> getUnPaidTGList(int companyID, int orderObjectID, int productType)
        {
            List<UnPaidListTG_Model> list = Payment_DAL.Instance.getUnPaidTGList(companyID, orderObjectID, productType);
            return list;
        }

        /// <summary>
        /// 获取分享业绩的人
        /// </summary>
        /// <param name="masterID">主键ID</param>
        /// <param name="type">1:充值 2:消费</param>
        /// <returns></returns>
        public List<Profit_Model> getProfitListByMasterID(int masterID, int type)
        {
            List<Profit_Model> list = Payment_DAL.Instance.getProfitListByMasterID(masterID, type);
            return list;
        }
        /// <summary>
        /// 获取销售顾问 订单支付时
        /// </summary>
        /// <param name="OrderID">OrderID</param>
        /// <returns></returns>
        public List<SalesConsultantRate_model> getSalesConsultantRateListByOrderID(string OrderID)
        {
            return Payment_DAL.Instance.getSalesConsultantRateListByOrderID(OrderID);
        }
        /// <summary>
        /// 获取销售顾问 支付详情时
        /// </summary>
        /// <param name="PaymentID">PaymentID</param>
        /// <returns></returns>
        public List<SalesConsultantRate_model> getSalesConsultantRateListByPaymentID(string PaymentID)
        {
            return Payment_DAL.Instance.getSalesConsultantRateListByPaymentID(PaymentID);
        }
        public string GetNetTradeQRCode(GetNetTradeQRCodeOperation_Model model, int type, out string productName)
        {
            productName = "";

            string advanced = WebAPI.DAL.Company_DAL.Instance.getAdvancedByCompanyID(model.CompanyID);
            if (!advanced.Contains("|6|") && !advanced.Contains("|5|"))
            {
                return "";
            }

            string strOrderID = "";
            if (type == 1)
            {
                if (model.OrderID == null || model.OrderID.Count <= 0)
                {
                    return "";
                }

                #region 订单编号
                for (int i = 0; i < model.OrderID.Count; i++)
                {
                    List<int> orderIDListWithout0Price = new List<int>();
                    PaymentCheck_Model paymentCheckModel = new PaymentCheck_Model();
                    //2:已完全支付订单不能支付 6:已取消订单不能支付
                    int canPayRes = Order_DAL.Instance.CanOrderCanPay(model.OrderID, out orderIDListWithout0Price, out paymentCheckModel);
                    if (canPayRes != 1)
                    {
                        return "";
                    }

                    if (i == 0)
                    {
                        strOrderID += "|" + model.OrderID[i].ToString() + "|";
                    }
                    else
                    {
                        strOrderID += model.OrderID[i].ToString() + "|";
                    }
                }
                #endregion

                #region 获取商品名称
                productName = Order_DAL.Instance.GetProductNameWithOrderID(model.CompanyID, model.OrderID[0]);
                if (string.IsNullOrWhiteSpace(productName))
                {
                    return "";
                }
                if (model.OrderID.Count > 1)
                {
                    productName = productName + "等";
                }

                #endregion
            }
            else
            {
                GetCardInfo_Model cardModel = ECard_DAL.Instance.GetCardInfo(model.CompanyID, model.CustomerID, model.UserCardNo);
                if (cardModel == null)
                {
                    return "";
                }

                productName = "账户充值-" + cardModel.CardName;
            }

            #region 业绩参与人
            string strSlaveIDs = "";
            if (model.Slavers != null && model.Slavers.Count > 0)
            {
                for (int i = 0; i < model.Slavers.Count; i++)
                {
                    if (i == 0)
                    {
                        strSlaveIDs += "|" + model.Slavers[i].SlaveID.ToString() + "," + Math.Round(model.Slavers[i].ProfitPct, 3).ToString() + "|";
                    }
                    else
                    {
                        strSlaveIDs += model.Slavers[i].SlaveID.ToString() + "," + Math.Round(model.Slavers[i].ProfitPct, 3).ToString() + "|";
                    }
                }
            }
            #endregion

            string res = Payment_DAL.Instance.GetNetTradeQRCode(model, strOrderID, strSlaveIDs, productName);
            return res;
        }

        public GetWeChatPayInfo_Model GetWeChatPayInfo(int companyId, string netTradeNo)
        {
            GetWeChatPayInfo_Model model = Payment_DAL.Instance.GetWeChatPayInfo(companyId, netTradeNo);
            return model;
        }

        /// <summary>
        /// 是否处理过 -1:NetTradeNo不存在 0:没有处理过 1:已经处理过
        /// </summary>
        /// <param name="netTradeNo"></param>
        /// <returns>-1:NetTradeNo不存在 0:没有处理过 1:已经处理过</returns>
        public int HasTradePay(string netTradeNo, int netTradeVendor = 1)
        {
            int res = Payment_DAL.Instance.HasTradePay(netTradeNo, netTradeVendor);
            return res;
        }

        public bool AddWeiXinResult(WeChatReturn_Model weChatModel, int CompanyID, DateTime time, int userID)
        {
            bool res = Payment_DAL.Instance.AddWeiXinResult(weChatModel, CompanyID, time, userID);
            return res;
        }

        public int AddTradePay(WeChatReturn_Model weChatModel, DateTime time)
        {
            int res = Payment_DAL.Instance.AddTradePay(weChatModel, time);
            return res;
        }

        public int AddAliTradePay(Alipay_trade_pay_response AliModel, DateTime time)
        {
            int res = Payment_DAL.Instance.AddAliTradePay(AliModel, time);
            return res;
        }

        public WeChatPayResault_Model GetWeChatPayResault(string netTradeNo, int companyID = 0)
        {
            WeChatPayResault_Model model = Payment_DAL.Instance.GetWeChatPayResault(netTradeNo, companyID);
            return model;
        }

        public bool AddAliPayFailResult(Alipay_trade_pay_response aliPayModel, int CompanyID, DateTime time, int userID)
        {
            bool res = Payment_DAL.Instance.AddAliPayFailResult(aliPayModel, CompanyID, time, userID);
            return res;
        }

        public AliPayResault_Model GetAliPayResault(string netTradeNo, int companyID = 0)
        {
            AliPayResault_Model model = Payment_DAL.Instance.GetAliPayResault(netTradeNo, companyID);
            return model;
        }

        public List<WeChatPayResault_Model> GetWeChatPayResaultByID(int companyID, string netTradeNo = "", int orderID = 0, int customerID = 0, string userCardNo = "")
        {
            List<WeChatPayResault_Model> list = Payment_DAL.Instance.GetWeChatPayResaultByID(companyID, netTradeNo, orderID, customerID, userCardNo);
            return list;
        }

        public bool DeleteNetTradeControl(string netTradeNo)
        {
            bool res = Payment_DAL.Instance.DeleteNetTradeControl(netTradeNo);
            return res;
        }

        #region WEB方法
        public ObjectResult<List<CancelPaymentMsgForWeb>> cancelPayment(string paymentCode, int updaterID, int companyID, int branchID)
        {
            ObjectResult<List<CancelPaymentMsgForWeb>> result = new ObjectResult<List<CancelPaymentMsgForWeb>>();

            result.Code = "0";

            result.Data = null;
            result.Message = "";
            if (paymentCode.Length != 12)
            {
                return result;
            }

            int PaymentID = StringUtils.GetDbInt(paymentCode.Substring(4, 6));

            if (PaymentID > 0)
            {
                return Payment_DAL.Instance.cancelPayment(PaymentID, updaterID, companyID, branchID);
            }
            else
            {
                return result;
            }
        }

        public int updatePaymentDetailMode(int companyID ,string paymentCode, List<UpdatePaymentDetailForWeb> detailList, DateTime PaymentTime, int updaterID, List<Slave_Model> listSalesID, bool changeSalesID,int IsUseRate, out string message)
        {
            if (paymentCode.Length != 12)
            {
                message = "请输入正确的12位支付编号";
                return -1;
            }

            int paymentID = StringUtils.GetDbInt(paymentCode.Substring(4, 6));

            return Payment_DAL.Instance.updatePaymentDetailMode(companyID, detailList, paymentID, PaymentTime, updaterID, listSalesID, changeSalesID, IsUseRate, out message);
        }

        public PaymentDetailInfo_Model getPaymentDetailForWeb(int companyID, string paymentCode, int branchID)
        {
            if (paymentCode.Length != 12)
            {
                return null;
            }
            PaymentDetailInfo_Model paymodel = new PaymentDetailInfo_Model();

            int paymentID = StringUtils.GetDbInt(paymentCode.Substring(4, 6));

            if (paymentID > 0)
            {
                paymodel = Payment_DAL.Instance.getPaymentDetailForWeb(companyID, paymentID, branchID);
            }

            if (paymodel != null)
            {
                paymodel.accountList = Account_DAL.Instance.getAccountListForPaymentEdit(paymentID);
                paymodel.PaymentCode = paymentCode;

            }
            return paymodel;
        }
        #endregion
    }
}
