using HS.Framework.Common;
using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Xml;
using WebAPI.Authorize;
using WebAPI.BLL;

namespace WebAPI.Controllers.API
{
    public class PaymentController : BaseController
    {

        [HttpPost]
        [ActionName("GetPaymentList")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage GetPaymentList(JObject obj)
        {
            ObjectResult<List<PaymentList_Model>> res = new ObjectResult<List<PaymentList_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.CustomerID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.BranchID = this.BranchID;

            List<PaymentList_Model> list = new List<PaymentList_Model>();
            list = Payment_BLL.Instance.getPaymentList(utilityModel);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetPaymentInfo")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"CustomerID":123 ,"OrderList":[{"OrderID":123,"OrderObjectID":22,"ProductType":0},{"OrderID":123,"OrderObjectID":22,"ProductType":0}]}
        public HttpResponseMessage GetPaymentInfo(JObject obj)
        {
            ObjectResult<PaymentInfo_Model> res = new ObjectResult<PaymentInfo_Model>();
            res.Code = "0";
            res.Message = "该订单非本店订单,不能支付!";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            GetPaymentInfoOperation_Model operationModel = new GetPaymentInfoOperation_Model();
            operationModel = JsonConvert.DeserializeObject<GetPaymentInfoOperation_Model>(strSafeJson);

            if (operationModel == null || operationModel.OrderList == null || operationModel.OrderList.Count <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.CompanyID = this.CompanyID;
            operationModel.BranchID = this.BranchID;
            if (!this.IsBusiness)
            {
                operationModel.CustomerID = this.UserID;
            }

            PaymentInfo_Model model = Payment_BLL.Instance.getPaymentInfo(operationModel);

            if (model != null)
            {
                res.Code = "1";
                res.Message = "Success";
                res.Data = model;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("AddPayment")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"OrderCount":2,"TotalPrice":200,"Remark":"金刚葫芦娃","OrderIDList":[1,2],"CustomerID":123,"Slavers":[{"SlaveID":12,"ProfitPct":0.3},{"SlaveID":36,"ProfitPct":0.7}],"PaymentDetailList":[{"UserCardNo":"卡号","CardType":0,"PaymentMode":1,"PaymentAmount":50},{"UserCardNo":"卡号","CardType":0,"PaymentMode":1,"PaymentAmount":50}],"GiveDetailList":[{"UserCardNo":"卡号","CardType":0,"PaymentMode":1,"PaymentAmount":50},{"UserCardNo":"卡号","CardType":0,"PaymentMode":1,"PaymentAmount":50}]}
        public HttpResponseMessage AddPayment(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "支付失败";
            res.Data = false;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            /*PaymentAddOperation_Model paymentAddModel = new PaymentAddOperation_Model();
            paymentAddModel = JsonConvert.DeserializeObject<PaymentAddOperation_Model>(strSafeJson);*/
            PaymentAddOperationList_Model PaymentAddOperationListModel = new PaymentAddOperationList_Model();
            PaymentAddOperationListModel = JsonConvert.DeserializeObject<PaymentAddOperationList_Model>(strSafeJson);
            //List<PaymentAddOperation_Model> PaymentAddOperationList = PaymentAddOperationListModel.PaymentAddOperationList;
            /*if (PaymentAddOperationListModel == null || PaymentAddOperationList == null || PaymentAddOperationList[0].OrderIDList == null || PaymentAddOperationList[0].OrderIDList.Count <= 0 || PaymentAddOperationList[0].OrderCount <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }*/
            if (PaymentAddOperationListModel == null || PaymentAddOperationListModel.PaymentAddOperationList == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            else {
                foreach (PaymentAddOperation_Model model in PaymentAddOperationListModel.PaymentAddOperationList)
                {
                    if (model.OrderIDList == null || model.OrderCount <= 0) {
                        res.Message = "不合法参数";
                        return toJson(res);
                    }
                }
            }
            DateTime time = DateTime.Now.ToLocalTime();
            foreach (PaymentAddOperation_Model model in PaymentAddOperationListModel.PaymentAddOperationList) {
                model.BranchID = this.BranchID;
                model.CompanyID = this.CompanyID;
                model.CreatorID = this.UserID;
                model.ClientType = this.ClientType;
                model.CreateTime = time;
                model.Remark = StringUtils.GetDbString(model.Remark, "");
            }
            

            #region 权限判断
            if (this.IsBusiness)
            {
                bool roleRes = RoleCheck_BLL.Instance.IsAccountHasTheRole(this.CompanyID, this.UserID, "|7|");
                if (!roleRes)
                {
                    res.Message = "没有该权限!";
                    return toJson(res);
                }
            }
            #endregion

            if (this.IsBusiness)
            {
                foreach (PaymentAddOperation_Model model in PaymentAddOperationListModel.PaymentAddOperationList)
                {
                    model.IsCustomer = false;
                }
            }
            else
            {
                //paymentAddModel.IsCustomer = true;
                //paymentAddModel.CustomerID = this.UserID;
                foreach (PaymentAddOperation_Model model in PaymentAddOperationListModel.PaymentAddOperationList)
                {
                    model.IsCustomer = true;
                    model.CustomerID = this.UserID;
                }
            }

            /*paymentAddModel.CreateTime = DateTime.Now.ToLocalTime();
            paymentAddModel.Remark = StringUtils.GetDbString(paymentAddModel.Remark, "");*/

            int result = Payment_BLL.Instance.PayAdd(PaymentAddOperationListModel);

            switch (result)
            {
                case 0:
                    res.Code = "0";
                    res.Message = "支付失败!";
                    break;
                case 1:
                    res.Code = "1";
                    res.Message = "支付成功!";
                    res.Data = true;
                    break;
                case 2:
                    res.Code = "2";
                    res.Message = "支付失败,订单已支付!";
                    break;
                case 3:
                    res.Code = "3";
                    res.Message = "没有卡支付权限";
                    break;
                case 4:
                    res.Code = "4";
                    res.Message = "余额不足!";
                    break;
                case 5:
                    res.Code = "5";
                    res.Message = "付款金额与订单金额不一致!";
                    break;
                case 6:
                    res.Code = "6";
                    res.Message = "已取消订单不能支付!";
                    break;
                case 7:
                    res.Code = "7";
                    res.Message = "支付异常!";
                    break;
                case 8:
                    res.Code = "5";
                    res.Message = "系统繁忙中!请耐心等待支付结果!";
                    break;
                default:
                    res.Code = "0";
                    res.Message = "支付失败!";
                    break;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("RefundPay")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"TotalPrice":200,"Remark":"金刚葫芦娃","OrderID":123,"CustomerID":123,"Slavers":[{"SlaveID":12,"ProfitPct":0.3},{"SlaveID":36,"ProfitPct":0.7}],"PaymentDetailList":[{"UserCardNo":"卡号","CardType":0,"PaymentMode":1,"PaymentAmount":50},{"UserCardNo":"卡号","CardType":0,"PaymentMode":1,"PaymentAmount":50}],"GiveDetailList":[{"UserCardNo":"卡号","CardType":0,"PaymentMode":1,"PaymentAmount":50},{"UserCardNo":"卡号","CardType":0,"PaymentMode":1,"PaymentAmount":50}]}
        public HttpResponseMessage RefundPay(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "支付失败";
            res.Data = false;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            PaymentRefundOperation_Modelcs paymentRefundModel = new PaymentRefundOperation_Modelcs();
            paymentRefundModel = JsonConvert.DeserializeObject<PaymentRefundOperation_Modelcs>(strSafeJson);
            /*PaymentRefundOperationList_Modelcs paymentRefundOperationListModel = new PaymentRefundOperationList_Modelcs();
            paymentRefundOperationListModel = JsonConvert.DeserializeObject<PaymentRefundOperationList_Modelcs>(strSafeJson);*/

            if (paymentRefundModel == null || paymentRefundModel.OrderID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            /*if (paymentRefundOperationListModel == null || paymentRefundOperationListModel.PaymentRefundOperationList == null) {
                res.Message = "不合法参数";
                return toJson(res);
            }*/

            paymentRefundModel.BranchID = this.BranchID;
            paymentRefundModel.CompanyID = this.CompanyID;
            paymentRefundModel.CreatorID = this.UserID;

            #region 权限判断
            if (this.IsBusiness)
            {
                bool roleRes = RoleCheck_BLL.Instance.IsAccountHasTheRole(paymentRefundModel.CompanyID, paymentRefundModel.CreatorID, "|7|");
                //bool roleRes = RoleCheck_BLL.Instance.IsAccountHasTheRole(this.CompanyID, this.UserID, "|7|");
                if (!roleRes)
                {
                    res.Message = "没有该权限!";
                    return toJson(res);
                }
            }
            #endregion
            //DateTime createTime = DateTime.Now.ToLocalTime();

            paymentRefundModel.CreateTime = DateTime.Now.ToLocalTime();
            paymentRefundModel.Remark = StringUtils.GetDbString(paymentRefundModel.Remark, "");

            int result = Payment_BLL.Instance.PayRefund(paymentRefundModel);
            /*foreach (PaymentRefundOperation_Modelcs model in paymentRefundOperationListModel.PaymentRefundOperationList) {
                model.BranchID = this.BranchID;
                model.CompanyID = this.CompanyID;
                model.CreatorID = this.UserID;
                model.CreateTime = createTime;
                model.Remark = StringUtils.GetDbString(model.Remark, "");
            }
            int result = Payment_BLL.Instance.PayRefund(paymentRefundOperationListModel);*/
            switch (result)
            {
                case 0:
                    res.Code = "0";
                    res.Message = "退款失败!";
                    break;
                case 1:
                    res.Code = "1";
                    res.Message = "退款成功!";
                    res.Data = true;
                    break;
                case 3:
                    res.Code = "3";
                    res.Message = "没有卡退款权限";
                    break;
                case 5:
                    res.Code = "5";
                    res.Message = "退款金额与应退金额不一致!";
                    break;
                case 7:
                    res.Code = "7";
                    res.Message = "退款异常!";
                    break;
                case 8:
                    res.Code = "5";
                    res.Message = "系统繁忙中!请耐心等待退款结果!";
                    break;
                default:
                    res.Code = "0";
                    res.Message = "退款失败!";
                    break;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetRefundOrderInfo")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"OrderID":123,"CustomerID":12123}
        public HttpResponseMessage GetRefundOrderInfo(JObject obj)
        {
            ObjectResult<RefundOrderInfo_Model> res = new ObjectResult<RefundOrderInfo_Model>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.OrderID <= 0 || utilityModel.CustomerID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;

            int getRes = 0;
            RefundOrderInfo_Model model = new RefundOrderInfo_Model();
            model = Payment_BLL.Instance.getRefundOrderInfo(utilityModel.CompanyID, utilityModel.BranchID, utilityModel.CustomerID, utilityModel.OrderID, utilityModel.ProductType, out getRes);

            if (model == null)
            {
                switch (getRes)
                {
                    case -1:
                        res.Code = "0";
                        res.Message = "订单没有支付记录!";
                        break;
                    case -2:
                        res.Code = "0";
                        res.Message = "合并支付订单不能退款!";
                        break;
                }
            }

            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetPaymentDetailByOrderID")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"OrderID":123,"PaymentID":0}
        public HttpResponseMessage GetPaymentDetailByOrderID(JObject obj)
        {
            ObjectResult<List<PaymentDetailByOrderID_Model>> res = new ObjectResult<List<PaymentDetailByOrderID_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (utilityModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.CompanyID = this.CompanyID;

            List<PaymentDetailByOrderID_Model> list = new List<PaymentDetailByOrderID_Model>();
            list = Payment_BLL.Instance.GetPaymentListByOrderID(utilityModel.CompanyID, utilityModel.OrderID, utilityModel.PaymentID);
            if (list != null && list.Count > 0)
            {
                foreach (PaymentDetailByOrderID_Model item in list)
                {
                    if (item.PaymentID > 0)
                    {
                        List<PaymentDetailList_Model> paymentDetailList = Payment_BLL.Instance.GetPayDetailListByPaymentID(utilityModel.CompanyID, item.PaymentID);
                        item.PaymentDetailList = paymentDetailList;

                        //业绩参与人员
                        List<Profit_Model> profitList = Payment_BLL.Instance.getProfitListByMasterID(item.PaymentID, 2);
                        item.ProfitList = profitList;
                        DateTime dt = Convert.ToDateTime(item.PaymentTime);
                        item.PaymentCode = dt.Month.ToString().PadLeft(2, '0') + dt.Day.ToString().PadLeft(2, '0') + item.PaymentID.ToString().PadLeft(6, '0') + dt.Year.ToString().Substring(dt.Year.ToString().Length - 2, 2);
                        //销售顾问人员
                        item.SalesConsultantRates = Payment_BLL.Instance.getSalesConsultantRateListByPaymentID(item.PaymentID.ToString());
                    }
                }

                if (list != null && list.Count > 0)
                {
                    if (utilityModel.OrderID <= 0)
                    {
                        list = list.Take(1).ToList();
                    }
                    List<PaymentOrderList_Model> paymentOrderList = Payment_BLL.Instance.getOrderListByPaymentID(utilityModel.CompanyID, list[0].PaymentID);
                    paymentOrderList = paymentOrderList.Where(c => c.OrderID != utilityModel.OrderID).ToList();
                    foreach (PaymentOrderList_Model item in paymentOrderList)
                    {
                        DateTime dt = Convert.ToDateTime(item.OrderTime);
                        item.OrderNumber = dt.Month.ToString().PadLeft(2, '0') + dt.Day.ToString().PadLeft(2, '0') + item.OrderID.ToString().PadLeft(6, '0') + dt.Year.ToString().Substring(dt.Year.ToString().Length - 2, 2);
                    }
                    list[0].PaymentOrderList = paymentOrderList;

                }
            }

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetUnPaidList")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        public HttpResponseMessage GetUnPaidList(JObject obj)
        {
            ObjectResult<List<UnPaidList_Model>> res = new ObjectResult<List<UnPaidList_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.BranchID = this.BranchID;
            utilityModel.CompanyID = this.CompanyID;

            List<UnPaidList_Model> list = Payment_BLL.Instance.getUnPaidList(utilityModel.CompanyID, utilityModel.BranchID);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("UnPaidListByCustomerID")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"CustomerID":123}
        public HttpResponseMessage UnPaidListByCustomerID(JObject obj)
        {
            ObjectResult<List<UnPaidListByCustomerID_Model>> res = new ObjectResult<List<UnPaidListByCustomerID_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.CustomerID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (utilityModel.BranchID > 0 && utilityModel.BranchID != this.BranchID)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.CompanyID = this.CompanyID;
            //utilityModel.BranchID = this.BranchID;

            List<UnPaidListByCustomerID_Model> list = new List<UnPaidListByCustomerID_Model>();
            list = Payment_BLL.Instance.getUnPaidListByCustomerID(utilityModel.CompanyID, utilityModel.BranchID, utilityModel.CustomerID);
            if (list != null && list.Count > 0)
            {
                foreach (UnPaidListByCustomerID_Model item in list)
                {
                    item.TGList = new List<UnPaidListTG_Model>();
                    item.TGList = Payment_BLL.Instance.getUnPaidTGList(utilityModel.CompanyID, item.OrderObjectID, item.ProductType);
                }
            }

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetNetTradeQRCode")]
        [HTTPBasicAuthorize]
        /// Aaron.Han 生成扫码二维码
        /// {"CustomerID":123,"OrderID":[1,2,3],"SlaveID":[1,2,3],"TotalAmount":100,"PointAmount":1000,"CouponAmount":1000,"Remark":"asdadsdasdas"}
        public HttpResponseMessage GetNetTradeQRCode(JObject obj)
        {
            ObjectResult<GetNetTradeQRCode_Model> res = new ObjectResult<GetNetTradeQRCode_Model>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            GetNetTradeQRCodeOperation_Model utilityModel = new GetNetTradeQRCodeOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<GetNetTradeQRCodeOperation_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.CustomerID <= 0 || utilityModel.TotalAmount <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (utilityModel.OrderID == null && string.IsNullOrWhiteSpace(utilityModel.UserCardNo))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (utilityModel.OrderID != null && utilityModel.OrderID.Count > 0 && !string.IsNullOrWhiteSpace(utilityModel.UserCardNo))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;
            utilityModel.AccountID = this.UserID;
            utilityModel.Time = DateTime.Now.ToLocalTime();
            utilityModel.NetActionType = 1;
            utilityModel.NetTradeActionMode = "W1";
            utilityModel.NetTradeVendor = 1;
            if (!string.IsNullOrWhiteSpace(utilityModel.UserCardNo))
            {
                utilityModel.ChangeType = 3;
            }
            else
            {
                utilityModel.ChangeType = 1;
            }


            string ProductName = "";
            string netTradeNo = Payment_BLL.Instance.GetNetTradeQRCode(utilityModel, utilityModel.ChangeType, out ProductName);
            if (string.IsNullOrWhiteSpace(netTradeNo))
            {
                res.Message = "数据准备失败!";
                res.Data = null;
                return toJson(res);
            }



            HS.Framework.Common.WeChat.WeChatPay weChat = new HS.Framework.Common.WeChat.WeChatPay();
            string QRCodeUrl = weChat.GetPrePayQRCode(netTradeNo, utilityModel.CompanyID);

            if (string.IsNullOrWhiteSpace(QRCodeUrl))
            {
                res.Message = "获取二维码失败!";
                res.Data = null;
                return toJson(res);
            }

            GetNetTradeQRCode_Model QRcodeModel = new GetNetTradeQRCode_Model();
            QRcodeModel.NetTradeNo = netTradeNo;
            QRcodeModel.QRCodeUrl = QRCodeUrl;
            QRcodeModel.ProductName = ProductName;

            res.Code = "1";
            res.Data = QRcodeModel;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetWeChatPayInfo")]
        /// Aaron.Han 返回支付信息给微信
        public HttpResponseMessage GetWeChatPayInfo()
        {
            var postStr = this.Request.Content.ReadAsStringAsync().Result;

            //w01
            HS.Framework.Common.WeChat.WeChatPay we = new HS.Framework.Common.WeChat.WeChatPay();
            //string postStr = HS.Framework.Common.Safe.InputStreamString.SafeS(System.Web.HttpContext.Current.Request);
            XmlDocument doc = new XmlDocument();
            doc.XmlResolver = null;
            doc.LoadXml(postStr);
            if (doc != null)
            {
                XmlNode root = doc.FirstChild;
                string out_trade_no = root["product_id"].InnerText;
                //int companyID = we.GetCompanyIDByAPPID(root["appid"].InnerText);
                //int companyID = 0;
                GetWeChatPayInfo_Model model = Payment_BLL.Instance.GetWeChatPayInfo(0, out_trade_no);
                if (model == null)
                {
                    return toJson(null);
                }

                string WeChatPayNotify_Url = System.Configuration.ConfigurationManager.AppSettings["WeChatPayNotify_Url"];
                string Spdill_Create_IP = System.Configuration.ConfigurationManager.AppSettings["Spdill_Create_IP"];
                string total_fee = ((int)(Math.Round(model.NetTradeAmount, 2) * 100)).ToString();
                string res = we.GetWeChatPaymentInfo(doc, model.CompanyID, "attach", model.ProductName, WeChatPayNotify_Url, Spdill_Create_IP, total_fee);
                return toXML(null, res);
            }
            else
            {
                return toJson(null);
            }
        }


        [ActionName("UpdateWeChatPayment")]
        /// Aaron.Han 扫码支付后 微信回调接口
        public HttpResponseMessage UpdateWeChatPayment()
        {
            string postStr = this.Request.Content.ReadAsStringAsync().Result;
            //            string postStr = @"<xml><appid><![CDATA[wx1aa3ce096117de41]]></appid>
            //<attach><![CDATA[attach]]></attach>
            //<bank_type><![CDATA[CMB_CREDIT]]></bank_type>
            //<cash_fee><![CDATA[4300]]></cash_fee>
            //<fee_type><![CDATA[CNY]]></fee_type>
            //<is_subscribe><![CDATA[N]]></is_subscribe>
            //<mch_id><![CDATA[1271443001]]></mch_id>
            //<nonce_str><![CDATA[86bd1a43b10f45e08a7801fd304dd246]]></nonce_str>
            //<openid><![CDATA[oEG8xuEPj6wxnMQdfcxWjNy8_dGc]]></openid>
            //<out_trade_no><![CDATA[NCP16040100000072]]></out_trade_no>
            //<result_code><![CDATA[SUCCESS]]></result_code>
            //<return_code><![CDATA[SUCCESS]]></return_code>
            //<sign><![CDATA[5AA5808559AE5B3F9A5006573DF9C313]]></sign>
            //<sub_mch_id><![CDATA[1284928701]]></sub_mch_id>
            //<time_end><![CDATA[20160401131933]]></time_end>
            //<total_fee>4300</total_fee>
            //<trade_type><![CDATA[NATIVE]]></trade_type>
            //<transaction_id><![CDATA[4001692001201604014453078982]]></transaction_id>
            //</xml>";
            LogUtil.Log("微信回调参数", postStr);
            XmlDocument doc = new XmlDocument();
            doc.XmlResolver = null;
            doc.LoadXml(postStr);
            if (doc == null)
            {
                return toXML(null, @"<xml>
                                  <return_code><![CDATA[FAIL]]></return_code>
                                  <return_msg><![CDATA[参数丢失]]></return_msg>
                                </xml>");

            }

            HS.Framework.Common.WeChat.WeChatPay we = new HS.Framework.Common.WeChat.WeChatPay();
            if (!we.PayResult(doc))
            {
                return toXML(null, @"<xml>
                                  <return_code><![CDATA[FAIL]]></return_code>
                                  <return_msg><![CDATA[参数丢失]]></return_msg>
                                </xml>");
            }

            XmlNode root = doc.FirstChild;
            if (root == null)
            {
                return toXML(null, @"<xml>
                                  <return_code><![CDATA[FAIL]]></return_code>
                                  <return_msg><![CDATA[参数丢失]]></return_msg>
                                </xml>");
            }

            WeChatReturn_Model weChatModel = new WeChatReturn_Model();
            weChatModel.return_code = root["return_code"].InnerText;
            weChatModel.result_code = root["result_code"].InnerText;
            weChatModel.appid = root["appid"].InnerText;
            weChatModel.out_trade_no = root["out_trade_no"].InnerText;
            weChatModel.attach = root["attach"].InnerText;
            weChatModel.bank_type = root["bank_type"].InnerText;
            weChatModel.fee_type = root["fee_type"].InnerText;
            weChatModel.is_subscribe = root["is_subscribe"].InnerText;
            weChatModel.mch_id = root["mch_id"].InnerText;
            weChatModel.nonce_str = root["nonce_str"].InnerText;
            weChatModel.openid = root["openid"].InnerText;
            weChatModel.sign = root["sign"].InnerText;
            weChatModel.time_end = root["time_end"].InnerText;
            weChatModel.cash_fee = StringUtils.GetDbDecimal(root["cash_fee"].InnerText);
            weChatModel.total_fee = StringUtils.GetDbDecimal(root["total_fee"].InnerText);
            weChatModel.trade_type = root["trade_type"].InnerText;
            weChatModel.transaction_id = root["transaction_id"].InnerText;

            #region  查询之前是否支付成功
            int payedRes = Payment_BLL.Instance.HasTradePay(weChatModel.out_trade_no);
            if (payedRes == -1)
            {
                return toXML(null, @"<xml>
                                  <return_code><![CDATA[SUCCESS]]></return_code>
                                  <return_msg><![CDATA[OK]]></return_msg>
                                </xml>");
            }
            else if (payedRes == 1)
            {
                return toXML(null, @"<xml>
                                  <return_code><![CDATA[SUCCESS]]></return_code>
                                  <return_msg><![CDATA[OK]]></return_msg>
                                </xml>");
            }
            #endregion

            //查询ChangeType 是走支付逻辑还是充值逻辑
            WeChatPayResault_Model tradeModel = Payment_BLL.Instance.GetWeChatPayResault(weChatModel.out_trade_no);
            if (tradeModel == null)
            {
                return toXML(null, @"<xml>
                                  <return_code><![CDATA[FAIL]]></return_code>
                                  <return_msg><![CDATA[参数丢失]]></return_msg>
                                </xml>");
            }

            if (tradeModel.ChangeType == 1)
            {
                #region 支付逻辑
                DateTime time = DateTime.Now.ToLocalTime();
                int payRes = Payment_BLL.Instance.AddTradePay(weChatModel, time);
                if (payRes == 1)
                {
                    return toXML(null, @"<xml>
                                  <return_code><![CDATA[SUCCESS]]></return_code>
                                  <return_msg><![CDATA[OK]]></return_msg>
                                </xml>");
                }
                #endregion
            }
            else if (tradeModel.ChangeType == 3)
            {
                #region 充值逻辑
                DateTime time = DateTime.Now.ToLocalTime();
                int payRes = ECard_BLL.Instance.CardRechargeByWeChat(weChatModel, time);
                if (payRes == 1)
                {
                    return toXML(null, @"<xml>
                                  <return_code><![CDATA[SUCCESS]]></return_code>
                                  <return_msg><![CDATA[OK]]></return_msg>
                                </xml>");
                }
                #endregion
            }

            return toXML(null, @"<xml>
                                  <return_code><![CDATA[FAIL]]></return_code>
                                  <return_msg><![CDATA[参数丢失]]></return_msg>
                                </xml>");
        }

        [HttpPost]
        [ActionName("WeChatPayByCustomer")]
        [HTTPBasicAuthorize]
        /// Aaron.Han 微信顾客刷卡支付
        //{"CustomerID":123,"OrderID":[1,2,3],"SlaveID":[1,2,3],"TotalAmount":100,"PointAmount":1000,"CouponAmount":1000,"UserCode":"65417854566521445","Remark":"adasdasddas"}
        public HttpResponseMessage WeChatPayByCustomer(JObject obj)
        {
            ObjectResult<WeChatPayResault_Model> res = new ObjectResult<WeChatPayResault_Model>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            #region 参数合法性验证
            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            GetNetTradeQRCodeOperation_Model utilityModel = new GetNetTradeQRCodeOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<GetNetTradeQRCodeOperation_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.CustomerID <= 0 || utilityModel.TotalAmount <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (utilityModel.OrderID == null && string.IsNullOrWhiteSpace(utilityModel.UserCardNo))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (utilityModel.OrderID != null && utilityModel.OrderID.Count > 0 && !string.IsNullOrWhiteSpace(utilityModel.UserCardNo))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            #endregion

            #region 准备数据
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;
            utilityModel.AccountID = this.UserID;
            utilityModel.Time = DateTime.Now.ToLocalTime();
            utilityModel.NetActionType = 1;
            utilityModel.NetTradeActionMode = "W2";
            utilityModel.NetTradeVendor = 1;
            if (!string.IsNullOrWhiteSpace(utilityModel.UserCardNo))
            {
                utilityModel.ChangeType = 3;
            }
            else
            {
                utilityModel.ChangeType = 1;
            }

            string ProductName = "";
            string netTradeNo = Payment_BLL.Instance.GetNetTradeQRCode(utilityModel, utilityModel.ChangeType, out ProductName);
            if (string.IsNullOrWhiteSpace(netTradeNo))
            {
                res.Message = "数据准备失败!";
                return toJson(res);
            }

            //GetWeChatPayInfo_Model model = Payment_BLL.Instance.GetWeChatPayInfo(utilityModel.CompanyID, netTradeNo);
            //if (model == null)
            //{
            //    res.Message = "数据准备失败!";
            //    return toJson(res);
            //}
            #endregion

            WeChatPayResault_Model payResaultModel = new WeChatPayResault_Model();

            int payedRes = Payment_BLL.Instance.HasTradePay(netTradeNo);
            if (payedRes == -1)
            {
                res.Message = "该支付已经失效!";
                return toJson(res);
            }
            else if (payedRes == 1)
            {
                payResaultModel = Payment_BLL.Instance.GetWeChatPayResault(netTradeNo, this.CompanyID);
                res.Message = "已经支付了";
                return toJson(res);
            }

            //bool hasPayed = Payment_BLL.Instance.HasTradePay(netTradeNo);
            //if (hasPayed)
            //{
            //    payResaultModel = Payment_BLL.Instance.GetWeChatPayResault(netTradeNo, this.CompanyID);
            //    res.Message = "已经支付了";
            //    return toJson(res);
            //}

            string Spdill_Create_IP = System.Configuration.ConfigurationManager.AppSettings["Spdill_Create_IP"];
            string total_fee = ((int)(Math.Round(utilityModel.TotalAmount, 2) * 100)).ToString();
            HS.Framework.Common.WeChat.WeChatPay we = new HS.Framework.Common.WeChat.WeChatPay();
            string outRes = we.ScanPayByUserCode(utilityModel.UserCode, netTradeNo, utilityModel.CompanyID, ProductName, "描述", Spdill_Create_IP, total_fee);
            XmlDocument doc = new XmlDocument();
            doc.XmlResolver = null;
            doc.LoadXml(outRes);

            if (doc == null)
            {
                res.Message = "支付失败";
                return toJson(res);
            }

            XmlNode root = doc.FirstChild;

            WeChatReturn_Model weChatModel = new WeChatReturn_Model();
            weChatModel.return_code = root["return_code"].InnerText;
            if (weChatModel.return_code != "SUCCESS")
            {
                payResaultModel = Payment_BLL.Instance.GetWeChatPayResault(netTradeNo, this.CompanyID);
                res.Message = "失败";
                return toJson(res);
            }

            weChatModel.result_code = root["result_code"].InnerText;
            weChatModel.appid = root["appid"].InnerText;
            weChatModel.out_trade_no = netTradeNo;

            if (string.IsNullOrWhiteSpace(weChatModel.result_code) || weChatModel.result_code != "SUCCESS")
            {
                #region 返回result_code为FAIL
                weChatModel.err_code = root["err_code"].InnerText;
                weChatModel.err_code_des = root["err_code_des"].InnerText;
                //err_code为系统错误,银行错误,用户正在支付的时候 不计入WeiXinPayResult表
                if (weChatModel.err_code == "SYSTEMERROR" || weChatModel.err_code == "BANKERROR" || weChatModel.err_code == "USERPAYING" || weChatModel.err_code == "NOTPAY")
                {
                    #region 只返回 不记表
                    res.Code = "1";
                    payResaultModel = Payment_BLL.Instance.GetWeChatPayResault(netTradeNo, this.CompanyID);
                    payResaultModel.ResultCode = "";//支付结果未知
                    payResaultModel.TradeState = root["err_code"].InnerText;
                    payResaultModel.ErrCode = root["err_code"].InnerText;
                    payResaultModel.ErrCodeDes = root["err_code_des"].InnerText;

                    if (payResaultModel.ErrCode == "ORDERNOTEXIST")
                    {
                        payResaultModel.DisplayResult = "支付结果未知";
                        payResaultModel.OperationTip = "请确认顾客已经扫码";
                    }
                    else
                    {
                        payResaultModel.DisplayResult = "支付结果未知";
                        payResaultModel.OperationTip = "请重新查询支付结果";
                    }
                    res.Message = root["err_code_des"].InnerText;
                    res.Data = payResaultModel;
                    return toJson(res);
                    #endregion
                }
                else
                {
                    #region 失败记入TBL_WEIXINPAY_RESULT
                    bool addRes = Payment_BLL.Instance.AddWeiXinResult(weChatModel, this.CompanyID, DateTime.Now.ToLocalTime(), this.UserID);
                    payResaultModel = Payment_BLL.Instance.GetWeChatPayResault(netTradeNo, this.CompanyID);
                    res.Code = "1";
                    res.Message = weChatModel.err_code;
                    res.Data = payResaultModel;
                    return toJson(res);
                    #endregion
                }
                #endregion
            }

            if (weChatModel.result_code == "SUCCESS")
            {
                if (weChatModel.trade_state == "USERPAYING" || weChatModel.trade_state == "NOTPAY")
                {
                    #region 等待用户支付
                    weChatModel.trade_state_desc = root["trade_state_desc"].InnerText;
                    payResaultModel = Payment_BLL.Instance.GetWeChatPayResault(netTradeNo, this.CompanyID);
                    payResaultModel.ResultCode = weChatModel.result_code;
                    payResaultModel.TradeState = weChatModel.trade_state;
                    if (weChatModel.trade_state == "USERPAYING")
                    {
                        payResaultModel.DisplayResult = "用户支付中";
                        payResaultModel.OperationTip = "请重新查询支付结果";
                    }
                    else if (weChatModel.trade_state == "NOTPAY")
                    {
                        payResaultModel.DisplayResult = "已撤销";
                        payResaultModel.OperationTip = "请重新查询支付结果";
                    }
                    //payResaultModel.ErrCode = weChatModel.trade_state;
                    //payResaultModel.ErrCodeDes = root["trade_state_desc"].InnerText;
                    res.Message = root["trade_state_desc"].InnerText;
                    return toJson(res);
                    #endregion
                }

                #region 成功逻辑
                weChatModel.attach = root["attach"].InnerText;
                weChatModel.bank_type = root["bank_type"].InnerText;
                weChatModel.fee_type = root["fee_type"].InnerText;
                weChatModel.is_subscribe = root["is_subscribe"].InnerText;
                weChatModel.mch_id = root["mch_id"].InnerText;
                weChatModel.nonce_str = root["nonce_str"].InnerText;
                weChatModel.openid = root["openid"].InnerText;
                weChatModel.out_trade_no = root["out_trade_no"].InnerText;
                weChatModel.sign = root["sign"].InnerText;
                weChatModel.time_end = root["time_end"].InnerText;
                weChatModel.cash_fee = StringUtils.GetDbDecimal(root["cash_fee"].InnerText);
                weChatModel.total_fee = StringUtils.GetDbDecimal(root["total_fee"].InnerText);
                weChatModel.trade_type = root["trade_type"].InnerText;
                weChatModel.transaction_id = root["transaction_id"].InnerText;

                //查询ChangeType 是走支付逻辑还是充值逻辑
                WeChatPayResault_Model tradeModel = Payment_BLL.Instance.GetWeChatPayResault(weChatModel.out_trade_no);
                if (tradeModel == null)
                {
                    res.Message = "支付返回错误";
                    return toJson(res);
                }

                if (tradeModel.ChangeType == 1)
                {
                    #region 支付逻辑
                    DateTime time = DateTime.Now.ToLocalTime();
                    int payRes = Payment_BLL.Instance.AddTradePay(weChatModel, time);
                    if (payRes != 1)
                    {
                        res.Code = "0";
                        res.Message = "支付返回错误";
                        return toJson(res);
                    }
                    #endregion
                }
                else if (tradeModel.ChangeType == 3)
                {
                    #region 充值逻辑
                    DateTime time = DateTime.Now.ToLocalTime();
                    int payRes = ECard_BLL.Instance.CardRechargeByWeChat(weChatModel, time);
                    if (payRes != 1)
                    {
                        res.Code = "0";
                        res.Message = "支付返回错误";
                        return toJson(res);
                    }
                    #endregion
                }
                #endregion
            }

            payResaultModel = Payment_BLL.Instance.GetWeChatPayResault(weChatModel.out_trade_no, this.CompanyID);
            if (payResaultModel != null)
            {
                payResaultModel.CashFee = payResaultModel.CashFee / 100;
            }
            res.Code = "1";
            res.Data = payResaultModel;
            res.Message = "支付成功";
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetWeChatPayRes")]
        [HTTPBasicAuthorize]
        /// Aaron.Han 微信主动查询支付结果
        //{"NetTradeNo":"12345687456123"}
        public HttpResponseMessage GetWeChatPayRes(JObject obj)
        {
            ObjectResult<WeChatPayResault_Model> res = new ObjectResult<WeChatPayResault_Model>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (utilityModel == null || string.IsNullOrWhiteSpace(utilityModel.NetTradeNo))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;
            utilityModel.AccountID = this.UserID;
            utilityModel.Time = DateTime.Now.ToLocalTime();

            WeChatPayResault_Model payResaultModel = new WeChatPayResault_Model();

            int payedRes = Payment_BLL.Instance.HasTradePay(utilityModel.NetTradeNo);
            if (payedRes == -1)
            {
                res.Message = "该支付已经失效!";
                return toJson(res);
            }
            else if (payedRes == 1)
            {
                res.Code = "1";
                payResaultModel = Payment_BLL.Instance.GetWeChatPayResault(utilityModel.NetTradeNo, this.CompanyID);
                res.Message = "已经处理!";
                res.Data = payResaultModel;
                return toJson(res);
            }

            HS.Framework.Common.WeChat.WeChatPay we = new HS.Framework.Common.WeChat.WeChatPay();
            string outRes = we.QueryPaymentByID("", utilityModel.NetTradeNo, this.CompanyID);

            XmlDocument doc = new XmlDocument();
            doc.XmlResolver = null;
            doc.LoadXml(outRes);

            if (doc == null)
            {
                res.Message = "支付失败";
                return toJson(res);
            }

            XmlNode root = doc.FirstChild;

            WeChatReturn_Model weChatModel = new WeChatReturn_Model();
            weChatModel.return_code = root["return_code"].InnerText;
            if (weChatModel.return_code != "SUCCESS")
            {
                res.Message = "失败";
                return toJson(res);
            }

            weChatModel.result_code = root["result_code"].InnerText;
            weChatModel.appid = root["appid"].InnerText;
            weChatModel.out_trade_no = utilityModel.NetTradeNo;

            if (string.IsNullOrWhiteSpace(weChatModel.result_code) || weChatModel.result_code != "SUCCESS")
            {
                #region 返回result_code为FAIL
                weChatModel.err_code = root["err_code"].InnerText;
                weChatModel.err_code_des = root["err_code_des"].InnerText;
                //err_code为系统错误,银行错误,用户正在支付的时候 不记入WeiXinPayResult表
                if (weChatModel.err_code == "SYSTEMERROR" || weChatModel.err_code == "ORDERNOTEXIST" || weChatModel.err_code == "BANKERROR" || weChatModel.err_code == "USERPAYING")
                {
                    #region 只返回 不记表
                    res.Code = "1";
                    payResaultModel = Payment_BLL.Instance.GetWeChatPayResault(utilityModel.NetTradeNo, this.CompanyID);
                    payResaultModel.ResultCode = "";//支付结果未知
                    payResaultModel.TradeState = weChatModel.err_code;
                    payResaultModel.ErrCode = root["err_code"].InnerText;
                    payResaultModel.ErrCodeDes = root["err_code_des"].InnerText;
                    payResaultModel.DisplayResult = "支付结果未知";
                    if (payResaultModel.ErrCode == "ORDERNOTEXIST")
                    {
                        TimeSpan span = DateTime.Now - payResaultModel.CreateTime;
                        if (span.TotalMinutes >= 10)
                        {
                            bool delRes = Payment_BLL.Instance.DeleteNetTradeControl(utilityModel.NetTradeNo);
                        }
                        payResaultModel.OperationTip = "请确认顾客已经扫码";
                    }
                    else
                    {
                        payResaultModel.OperationTip = "请重新查询支付结果";
                    }
                    res.Message = root["err_code_des"].InnerText;
                    res.Data = payResaultModel;
                    return toJson(res);
                    #endregion
                }
                else
                {
                    #region 失败记入TBL_WEIXINPAY_RESULT
                    bool addRes = Payment_BLL.Instance.AddWeiXinResult(weChatModel, this.CompanyID, DateTime.Now.ToLocalTime(), this.UserID);
                    payResaultModel = Payment_BLL.Instance.GetWeChatPayResault(utilityModel.NetTradeNo, this.CompanyID);
                    res.Code = "1";
                    res.Message = weChatModel.err_code;
                    res.Data = payResaultModel;
                    return toJson(res);
                    #endregion
                }
                #endregion
            }

            weChatModel.trade_state = root["trade_state"].InnerText;

            if (weChatModel.result_code == "SUCCESS")
            {
                //trade_state不是成功 并且不是等待用户支付 的时候 记入WeiXinResult表
                //SUCCESS—支付成功 REFUND—转入退款,NOTPAY—未支付,CLOSED—已关闭,REVOKED—已撤销（刷卡支付）,USERPAYING--用户支付中,PAYERROR--支付失败(其他原因，如银行返回失败)
                if (weChatModel.trade_state == "SUCCESS")
                {
                    #region 成功的逻辑
                    weChatModel.attach = root["attach"].InnerText;
                    weChatModel.bank_type = root["bank_type"].InnerText;
                    weChatModel.fee_type = root["fee_type"].InnerText;
                    weChatModel.is_subscribe = root["is_subscribe"].InnerText;
                    weChatModel.mch_id = root["mch_id"].InnerText;
                    weChatModel.nonce_str = root["nonce_str"].InnerText;
                    weChatModel.openid = root["openid"].InnerText;
                    weChatModel.out_trade_no = root["out_trade_no"].InnerText;
                    weChatModel.sign = root["sign"].InnerText;
                    weChatModel.time_end = root["time_end"].InnerText;
                    weChatModel.cash_fee = StringUtils.GetDbDecimal(root["cash_fee"].InnerText);
                    weChatModel.total_fee = StringUtils.GetDbDecimal(root["total_fee"].InnerText);
                    weChatModel.trade_type = root["trade_type"].InnerText;
                    weChatModel.transaction_id = root["transaction_id"].InnerText;

                    //查询ChangeType 是走支付逻辑还是充值逻辑
                    WeChatPayResault_Model tradeModel = Payment_BLL.Instance.GetWeChatPayResault(weChatModel.out_trade_no);
                    if (tradeModel == null)
                    {
                        res.Message = "支付返回错误";
                        return toJson(res);
                    }

                    if (tradeModel.ChangeType == 1)
                    {
                        #region 支付逻辑
                        DateTime time = DateTime.Now.ToLocalTime();
                        int payRes = Payment_BLL.Instance.AddTradePay(weChatModel, time);
                        if (payRes != 1)
                        {
                            res.Code = "0";
                            res.Message = "支付返回错误";
                            return toJson(res);
                        }
                        #endregion
                    }
                    else if (tradeModel.ChangeType == 3)
                    {
                        #region 充值逻辑
                        DateTime time = DateTime.Now.ToLocalTime();
                        int payRes = ECard_BLL.Instance.CardRechargeByWeChat(weChatModel, time);
                        if (payRes != 1)
                        {
                            res.Code = "0";
                            res.Message = "支付返回错误";
                            return toJson(res);
                        }
                        #endregion
                    }
                    #endregion
                }
                else if (weChatModel.trade_state == "USERPAYING" || weChatModel.trade_state == "NOTPAY")
                {
                    #region 等待用户支付
                    res.Code = "1";
                    payResaultModel = Payment_BLL.Instance.GetWeChatPayResault(utilityModel.NetTradeNo, this.CompanyID);
                    payResaultModel.ResultCode = weChatModel.result_code;
                    payResaultModel.TradeState = weChatModel.trade_state;
                    if (weChatModel.trade_state == "USERPAYING")
                    {
                        payResaultModel.ResultCode = "";//支付结果未知
                        payResaultModel.DisplayResult = "用户支付中";
                        payResaultModel.OperationTip = "请重新查询支付结果";
                    }
                    else if (weChatModel.trade_state == "NOTPAY")
                    {
                        payResaultModel.ResultCode = "";//支付结果未知
                        payResaultModel.DisplayResult = "已撤销";
                        payResaultModel.OperationTip = "请重新查询支付结果";
                    }

                    //payResaultModel.ErrCode = weChatModel.trade_state;
                    //payResaultModel.ErrCodeDes = root["trade_state_desc"].InnerText;
                    res.Data = payResaultModel;
                    res.Message = root["trade_state_desc"].InnerText;
                    return toJson(res);
                    #endregion
                }
                else
                {
                    #region 支付的其他状态
                    res.Code = "1";
                    weChatModel.trade_state_desc = root["trade_state_desc"].InnerText;
                    bool addRes = Payment_BLL.Instance.AddWeiXinResult(weChatModel, this.CompanyID, DateTime.Now.ToLocalTime(), this.UserID);
                    payResaultModel = Payment_BLL.Instance.GetWeChatPayResault(utilityModel.NetTradeNo, this.CompanyID);
                    if (weChatModel.trade_state == "CLOSED")
                    {
                        payResaultModel.DisplayResult = "已关闭";
                    }
                    else if (weChatModel.trade_state == "REVOKED")
                    {
                        payResaultModel.DisplayResult = "已撤销";
                    }
                    else if (weChatModel.trade_state == "PAYERROR")
                    {
                        payResaultModel.DisplayResult = "支付失败";
                    }
                    res.Data = payResaultModel;
                    res.Message = root["trade_state_desc"].InnerText;
                    return toJson(res);
                    #endregion
                }
            }

            payResaultModel = Payment_BLL.Instance.GetWeChatPayResault(utilityModel.NetTradeNo, this.CompanyID);
            res.Code = "1";
            res.Data = payResaultModel;
            res.Message = "支付成功";
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetWeChatPayResaultByID")]
        [HTTPBasicAuthorize]
        /// Aaron.Han 
        //{"NetTradeNo":"12345687456123"}
        public HttpResponseMessage GetWeChatPayResaultByID(JObject obj)
        {
            ObjectResult<List<WeChatPayResault_Model>> res = new ObjectResult<List<WeChatPayResault_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (utilityModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;

            List<WeChatPayResault_Model> payResaultList = new List<WeChatPayResault_Model>();

            payResaultList = Payment_BLL.Instance.GetWeChatPayResaultByID(this.CompanyID, utilityModel.NetTradeNo, utilityModel.OrderID, utilityModel.CustomerID, utilityModel.UserCardNo);
            res.Code = "1";
            res.Data = payResaultList;
            res.Message = "";
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetAliPayNetTradeQRCode")]
        [HTTPBasicAuthorize]
        /// Aaron.Han 生成支付宝扫码二维码
        /// {"CustomerID":123,"OrderID":[1,2,3],"SlaveID":[1,2,3],"TotalAmount":100,"PointAmount":1000,"CouponAmount":1000,"Remark":"asdadsdasdas"}
        public HttpResponseMessage GetAliPayNetTradeQRCode(JObject obj)
        {
            ObjectResult<GetNetTradeQRCode_Model> res = new ObjectResult<GetNetTradeQRCode_Model>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            GetNetTradeQRCodeOperation_Model utilityModel = new GetNetTradeQRCodeOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<GetNetTradeQRCodeOperation_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.CustomerID <= 0 || utilityModel.TotalAmount <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (utilityModel.OrderID == null && string.IsNullOrWhiteSpace(utilityModel.UserCardNo))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (utilityModel.OrderID != null && utilityModel.OrderID.Count > 0 && !string.IsNullOrWhiteSpace(utilityModel.UserCardNo))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;
            utilityModel.AccountID = this.UserID;
            utilityModel.Time = DateTime.Now.ToLocalTime();
            utilityModel.NetActionType = 1;
            utilityModel.NetTradeActionMode = "A2";
            utilityModel.NetTradeVendor = 2;
            if (!string.IsNullOrWhiteSpace(utilityModel.UserCardNo))
            {
                utilityModel.ChangeType = 3;
            }
            else
            {
                utilityModel.ChangeType = 1;
            }


            string ProductName = "";
            string netTradeNo = Payment_BLL.Instance.GetNetTradeQRCode(utilityModel, utilityModel.ChangeType, out ProductName);
            if (string.IsNullOrWhiteSpace(netTradeNo))
            {
                res.Message = "数据准备失败!";
                res.Data = null;
                return toJson(res);
            }



            HS.Framework.Common.AliPay.AliPay aliPay = new HS.Framework.Common.AliPay.AliPay();
            //string QRCodeUrl = aliPay.GetPrePayQRCode(netTradeNo, utilityModel.CompanyID);
            //decimal aliPayTotalAmount = Math.Round(utilityModel.TotalAmount / 100, 2);
            string QRCodeUrl = aliPay.GetPrePayQRCode(utilityModel.CompanyID, netTradeNo, utilityModel.TotalAmount, "body", ProductName, "", 1, this.UserID);

            if (string.IsNullOrWhiteSpace(QRCodeUrl))
            {
                res.Message = "获取二维码失败!";
                res.Data = null;
                return toJson(res);
            }

            GetNetTradeQRCode_Model QRcodeModel = new GetNetTradeQRCode_Model();
            QRcodeModel.NetTradeNo = netTradeNo;
            QRcodeModel.QRCodeUrl = QRCodeUrl;
            QRcodeModel.ProductName = ProductName;

            res.Code = "1";
            res.Data = QRcodeModel;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetAliPayRes")]
        [HTTPBasicAuthorize]
        /// Aaron.Han 支付宝主动查询支付结果
        //{"NetTradeNo":"12345687456123"}
        public HttpResponseMessage GetAliPayRes(JObject obj)
        {
            ObjectResult<AliPayResault_Model> res = new ObjectResult<AliPayResault_Model>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (utilityModel == null || string.IsNullOrWhiteSpace(utilityModel.NetTradeNo))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;
            utilityModel.AccountID = this.UserID;
            utilityModel.Time = DateTime.Now.ToLocalTime();

            AliPayResault_Model payResaultModel = new AliPayResault_Model();

            int payedRes = Payment_BLL.Instance.HasTradePay(utilityModel.NetTradeNo, 2);
            if (payedRes == -1)
            {
                res.Message = "该支付已经失效!";
                return toJson(res);
            }
            else if (payedRes == 1)
            {
                res.Code = "1";
                payResaultModel = Payment_BLL.Instance.GetAliPayResault(utilityModel.NetTradeNo, this.CompanyID);
                res.Message = "已经处理!";
                res.Data = payResaultModel;
                return toJson(res);
            }

            HS.Framework.Common.AliPay.AliPay aliPay = new HS.Framework.Common.AliPay.AliPay();
            string outRes = aliPay.QueryPaymentByID(utilityModel.NetTradeNo, utilityModel.CompanyID);
            if (string.IsNullOrEmpty(outRes))
            {
                res.Message = "支付失败";
                return toJson(res);
            }

            AliPayQueryResponseBody_Model responseBodyModel = JsonConvert.DeserializeObject<AliPayQueryResponseBody_Model>(outRes);

            if (responseBodyModel.alipay_trade_query_response == null || responseBodyModel == null)
            {
                res.Message = "支付失败";
                return toJson(res);
            }

            Alipay_trade_pay_response payresponseModel = new Alipay_trade_pay_response();
            payresponseModel = responseBodyModel.alipay_trade_query_response;

            if (payresponseModel.code == "40004")
            {
                #region 交易明确失败 记录TBL_ALIPAY_RESULT表
                responseBodyModel.alipay_trade_query_response.out_trade_no = utilityModel.NetTradeNo;
                bool addRes = Payment_BLL.Instance.AddAliPayFailResult(payresponseModel, this.CompanyID, DateTime.Now.ToLocalTime(), this.UserID);
                payResaultModel = Payment_BLL.Instance.GetAliPayResault(utilityModel.NetTradeNo, this.CompanyID);
                res.Code = "1";
                res.Message = payresponseModel.sub_desc;
                res.Data = payResaultModel;
                return toJson(res);
                #endregion
            }
            else if (payresponseModel.code == "10000" && (payresponseModel.trade_status == "TRADE_SUCCESS" || payresponseModel.trade_status == "TRADE_FINISHED"))
            {
                #region 成功
                //查询ChangeType 是走支付逻辑还是充值逻辑
                AliPayResault_Model tradeModel = Payment_BLL.Instance.GetAliPayResault(payresponseModel.out_trade_no);
                if (tradeModel == null)
                {
                    res.Message = "支付返回错误";
                    return toJson(res);
                }

                if (payresponseModel.fund_bill_list != null && payresponseModel.fund_bill_list.Count > 0)
                {
                    payresponseModel.strFundBillList = JsonConvert.SerializeObject(payresponseModel.fund_bill_list);
                }

                if (payresponseModel.discount_goods_detail != null && payresponseModel.discount_goods_detail.Count > 0)
                {
                    payresponseModel.strDiscountGoodsDetail = JsonConvert.SerializeObject(payresponseModel.discount_goods_detail);
                }

                if (tradeModel.ChangeType == 1)
                {
                    #region 支付逻辑
                    DateTime time = DateTime.Now.ToLocalTime();

                    int payRes = Payment_BLL.Instance.AddAliTradePay(payresponseModel, time);
                    if (payRes != 1)
                    {
                        res.Code = "0";
                        res.Message = "支付返回错误";
                        return toJson(res);
                    }
                    #endregion
                }
                else if (tradeModel.ChangeType == 3)
                {
                    #region 充值逻辑
                    DateTime time = DateTime.Now.ToLocalTime();
                    int payRes = ECard_BLL.Instance.CardRechargeByAliPay(payresponseModel, time);
                    if (payRes != 1)
                    {
                        res.Code = "0";
                        res.Message = "支付返回错误";
                        return toJson(res);
                    }
                    #endregion
                }
                #endregion
            }
            else
            {
                #region 不作处理
                res.Code = "1";
                payResaultModel = Payment_BLL.Instance.GetAliPayResault(utilityModel.NetTradeNo, this.CompanyID);
                payResaultModel.Code = payresponseModel.code;

                if (payResaultModel.Code == "10003")
                {
                    payResaultModel.TradeState = "WAIT_BUYER_PAY";//支付结果未知
                }
                payResaultModel.DisplayResult = "支付结果未知";
                payResaultModel.OperationTip = "请重新查询支付结果";
                res.Message = payresponseModel.msg;
                res.Data = payResaultModel;
                return toJson(res);
                #endregion
            }

            payResaultModel = Payment_BLL.Instance.GetAliPayResault(utilityModel.NetTradeNo, this.CompanyID);
            res.Code = "1";
            res.Data = payResaultModel;
            res.Message = "支付成功";
            return toJson(res);
        }

        [HttpPost]
        [ActionName("AliPayByAuthCode")]
        [HTTPBasicAuthorize]
        /// Aaron.Han 支付宝顾客刷卡支付
        //{"CustomerID":123,"OrderID":[1,2,3],"SlaveID":[1,2,3],"TotalAmount":100,"PointAmount":1000,"CouponAmount":1000,"UserCode":"65417854566521445","Remark":"adasdasddas"}
        public HttpResponseMessage AliPayByAuthCode(JObject obj)
        {
            ObjectResult<AliPayResault_Model> res = new ObjectResult<AliPayResault_Model>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            #region 参数合法性验证
            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            GetNetTradeQRCodeOperation_Model utilityModel = new GetNetTradeQRCodeOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<GetNetTradeQRCodeOperation_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.CustomerID <= 0 || utilityModel.TotalAmount <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (utilityModel.OrderID == null && string.IsNullOrWhiteSpace(utilityModel.UserCardNo))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (utilityModel.OrderID != null && utilityModel.OrderID.Count > 0 && !string.IsNullOrWhiteSpace(utilityModel.UserCardNo))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            #endregion

            #region 准备数据
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;
            utilityModel.AccountID = this.UserID;
            utilityModel.Time = DateTime.Now.ToLocalTime();
            utilityModel.NetActionType = 1;
            utilityModel.NetTradeActionMode = "A1";
            utilityModel.NetTradeVendor = 2;
            if (!string.IsNullOrWhiteSpace(utilityModel.UserCardNo))
            {
                utilityModel.ChangeType = 3;
            }
            else
            {
                utilityModel.ChangeType = 1;
            }

            string ProductName = "";
            string netTradeNo = Payment_BLL.Instance.GetNetTradeQRCode(utilityModel, utilityModel.ChangeType, out ProductName);
            if (string.IsNullOrWhiteSpace(netTradeNo))
            {
                res.Message = "数据准备失败!";
                return toJson(res);
            }

            //GetWeChatPayInfo_Model model = Payment_BLL.Instance.GetWeChatPayInfo(utilityModel.CompanyID, netTradeNo);
            //if (model == null)
            //{
            //    res.Message = "数据准备失败!";
            //    return toJson(res);
            //}
            #endregion

            AliPayResault_Model payResaultModel = new AliPayResault_Model();

            int payedRes = Payment_BLL.Instance.HasTradePay(netTradeNo, 2);
            if (payedRes == -1)
            {
                res.Message = "该支付已经失效!";
                return toJson(res);
            }
            else if (payedRes == 1)
            {
                payResaultModel = Payment_BLL.Instance.GetAliPayResault(netTradeNo, this.CompanyID);
                res.Message = "已经支付了";
                return toJson(res);
            }

            //bool hasPayed = Payment_BLL.Instance.HasTradePay(netTradeNo);
            //if (hasPayed)
            //{
            //    payResaultModel = Payment_BLL.Instance.GetWeChatPayResault(netTradeNo, this.CompanyID);
            //    res.Message = "已经支付了";
            //    return toJson(res);
            //}

            string Spdill_Create_IP = System.Configuration.ConfigurationManager.AppSettings["Spdill_Create_IP"];
            string total_fee = ((int)(Math.Round(utilityModel.TotalAmount, 2) * 100)).ToString();

            HS.Framework.Common.AliPay.AliPay aliPay = new HS.Framework.Common.AliPay.AliPay();
            string outRes = aliPay.PayByAuthCode(utilityModel.CompanyID, netTradeNo, utilityModel.UserCode, utilityModel.TotalAmount, "body", ProductName, "", 1, this.UserID);
            if (string.IsNullOrEmpty(outRes))
            {
                res.Message = "支付失败";
                return toJson(res);
            }

            AliPayResponseBody_Model responseBodyModel = JsonConvert.DeserializeObject<AliPayResponseBody_Model>(outRes);

            if (responseBodyModel.alipay_trade_pay_response == null || responseBodyModel == null)
            {
                res.Message = "支付失败";
                return toJson(res);
            }

            Alipay_trade_pay_response payresponseModel = new Alipay_trade_pay_response();
            payresponseModel = responseBodyModel.alipay_trade_pay_response;

            if (payresponseModel.code == "40004")
            {
                #region 交易明确失败 记录TBL_ALIPAY_RESULT表
                responseBodyModel.alipay_trade_pay_response.out_trade_no = netTradeNo;
                bool addRes = Payment_BLL.Instance.AddAliPayFailResult(payresponseModel, this.CompanyID, DateTime.Now.ToLocalTime(), this.UserID);
                payResaultModel = Payment_BLL.Instance.GetAliPayResault(netTradeNo, this.CompanyID);
                res.Code = "1";
                res.Message = payresponseModel.sub_desc;
                res.Data = payResaultModel;
                return toJson(res);
                #endregion
            }
            else if (payresponseModel.code == "10000")
            {
                #region 成功
                //查询ChangeType 是走支付逻辑还是充值逻辑
                AliPayResault_Model tradeModel = Payment_BLL.Instance.GetAliPayResault(payresponseModel.out_trade_no);
                if (tradeModel == null)
                {
                    res.Message = "支付返回错误";
                    return toJson(res);
                }

                if (payresponseModel.fund_bill_list != null && payresponseModel.fund_bill_list.Count > 0)
                {
                    payresponseModel.strFundBillList = JsonConvert.SerializeObject(payresponseModel.fund_bill_list);
                }

                if (payresponseModel.discount_goods_detail != null && payresponseModel.discount_goods_detail.Count > 0)
                {
                    payresponseModel.strDiscountGoodsDetail = JsonConvert.SerializeObject(payresponseModel.discount_goods_detail);
                }

                if (tradeModel.ChangeType == 1)
                {
                    #region 支付逻辑
                    DateTime time = DateTime.Now.ToLocalTime();
                    payresponseModel.trade_status = "TRADE_SUCCESS";


                    int payRes = Payment_BLL.Instance.AddAliTradePay(payresponseModel, time);
                    if (payRes != 1)
                    {
                        res.Code = "0";
                        res.Message = "支付返回错误";
                        return toJson(res);
                    }
                    #endregion
                }
                else if (tradeModel.ChangeType == 3)
                {
                    #region 充值逻辑
                    DateTime time = DateTime.Now.ToLocalTime();
                    int payRes = ECard_BLL.Instance.CardRechargeByAliPay(payresponseModel, time);
                    if (payRes != 1)
                    {
                        res.Code = "0";
                        res.Message = "支付返回错误";
                        return toJson(res);
                    }
                    #endregion
                }
                #endregion
            }
            else
            {
                #region 不作处理
                res.Code = "1";
                payResaultModel = Payment_BLL.Instance.GetAliPayResault(netTradeNo, this.CompanyID);
                payResaultModel.Code = payresponseModel.code;

                if (payResaultModel.Code == "10003")
                {
                    payResaultModel.TradeState = "WAIT_BUYER_PAY";//支付结果未知
                }
                payResaultModel.DisplayResult = "支付结果未知";
                payResaultModel.OperationTip = "请重新查询支付结果";
                res.Message = payresponseModel.msg;
                res.Data = payResaultModel;
                return toJson(res);
                #endregion
            }

            payResaultModel = Payment_BLL.Instance.GetAliPayResault(payresponseModel.out_trade_no, this.CompanyID);
            res.Code = "1";
            res.Data = payResaultModel;
            res.Message = "支付成功";
            return toJson(res);
        }
    }
}
