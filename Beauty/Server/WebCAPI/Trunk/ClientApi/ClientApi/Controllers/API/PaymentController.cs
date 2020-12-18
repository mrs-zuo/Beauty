using ClientApi.Authorize;
using ClientAPI.BLL;
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

namespace ClientApi.Controllers.API
{
    public class PaymentController : BaseController
    {
        [HttpPost]
        [ActionName("GetPaymentInfo")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"OrderList":[{"OrderID":123,"OrderObjectID":22,"ProductType":0},{"OrderID":123,"OrderObjectID":22,"ProductType":0}]}
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
            operationModel.CustomerID = this.UserID;

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
        /// {"OrderCount":2,"TotalPrice":200,"Remark":"金刚葫芦娃","OrderIDList":[1,2],"CustomerID":123,"SlaveID":[26,27,28],"PaymentDetailList":[{"UserCardNo":"卡号","CardType":0,"PaymentMode":1,"PaymentAmount":50},{"UserCardNo":"卡号","CardType":0,"PaymentMode":1,"PaymentAmount":50}],"GiveDetailList":[{"UserCardNo":"卡号","CardType":0,"PaymentMode":1,"PaymentAmount":50},{"UserCardNo":"卡号","CardType":0,"PaymentMode":1,"PaymentAmount":50}]}
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

            PaymentAddOperation_Model paymentAddModel = new PaymentAddOperation_Model();
            paymentAddModel = JsonConvert.DeserializeObject<PaymentAddOperation_Model>(strSafeJson);

            if (paymentAddModel == null || paymentAddModel.OrderIDList == null || paymentAddModel.OrderIDList.Count <= 0 || paymentAddModel.OrderCount <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            //paymentAddModel.BranchID = this.BranchID;
            paymentAddModel.CompanyID = this.CompanyID;
            paymentAddModel.CreatorID = this.UserID;
            //paymentAddModel.IsCustomer = true;
            paymentAddModel.CustomerID = this.UserID;
            paymentAddModel.CreateTime = DateTime.Now.ToLocalTime();
            paymentAddModel.Remark = StringUtils.GetDbString(paymentAddModel.Remark, "");
            paymentAddModel.ClientType = this.ClientType;

            int result = Payment_BLL.Instance.PayAdd(paymentAddModel);

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
                default:
                    res.Code = "0";
                    res.Message = "支付失败!";
                    break;
            }

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

            utilityModel.CompanyID = this.CompanyID;
            //utilityModel.BranchID = this.BranchID;

            List<UnPaidListByCustomerID_Model> list = new List<UnPaidListByCustomerID_Model>();
            list = Payment_BLL.Instance.getUnPaidListByCustomerID(utilityModel.CompanyID, utilityModel.CustomerID);
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

                        List<Profit_Model> profitList = Payment_BLL.Instance.getProfitListByMasterID(item.PaymentID, 2);
                        item.ProfitList = profitList;

                        DateTime dt = Convert.ToDateTime(item.PaymentTime);
                        item.PaymentCode = dt.Month.ToString().PadLeft(2, '0') + dt.Day.ToString().PadLeft(2, '0') + item.PaymentID.ToString().PadLeft(6, '0') + dt.Year.ToString().Substring(dt.Year.ToString().Length - 2, 2);
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


        [ActionName("UpdateWeChatPayment")]
        /// Aaron.Han 微信回调接口
        public HttpResponseMessage UpdateWeChatPayment()
        {
            string postStr = this.Request.Content.ReadAsStringAsync().Result;
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

            if (tradeModel.ChangeType == 1 && tradeModel.NetTradeActionMode == "W5")
            {
                #region 促销逻辑
                DateTime time = DateTime.Now.ToLocalTime();
                int payRes = Payment_BLL.Instance.AddRushTradePay(weChatModel, time);
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
            utilityModel.CustomerID = this.UserID;
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

                    if (tradeModel.ChangeType == 1 && tradeModel.NetTradeActionMode == "W5")
                    {
                        #region 促销支付逻辑
                        DateTime time = DateTime.Now.ToLocalTime();
                        int payRes = Payment_BLL.Instance.AddRushTradePay(weChatModel, time);
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
                        payResaultModel.DisplayResult = "未支付";
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
    }
}
