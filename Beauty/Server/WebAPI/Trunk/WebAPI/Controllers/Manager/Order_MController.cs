using HS.Framework.Common.Entity;
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
using WebAPI.Authorize;
using WebAPI.BLL;
using WebAPI.Controllers.API;


namespace WebAPI.Controllers.Manager
{
    public class Order_MController : BaseController
    {

        [HttpPost]
        [ActionName("getOrderDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getOrderDetail(JObject obj)
        {
            //TreatmentListFlag 更改订单信息的时候为0  取消订单状态的时候为1
            ObjectResult<OrderDetailForWeb_Model> res = new ObjectResult<OrderDetailForWeb_Model>();
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
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;

            OrderDetailForWeb_Model modelRes = new OrderDetailForWeb_Model();
            modelRes = Order_BLL.Instance.getOrderDetailForWeb(utilityModel.OrderCode, utilityModel.CompanyID, utilityModel.BranchID);
            if (modelRes == null)
            {

                res.Code = "0";
                res.Message = "请输入正确的12位订单编号！";
                return toJson(res);
            }

            modelRes.PaymentList = Order_BLL.Instance.GetPaymentListByOrderID(utilityModel.OrderCode);
            //if (modelRes.CompanyID != this.CompanyID)
            //{
            //    res.Code = "-1";
            //    res.Message = "请输入正确的订单编号！";
            //    return toJson(res);
            //}
            //if (modelRes.BranchID != this.BranchID && this.BranchID != 0)
            //{
            //    res.Code = "-2";
            //    res.Message = "请输入本店的订单编号！";
            //    return toJson(res);
            //}
            //if ((modelRes.OrderStatus != 1 && modelRes.OrderStatus != 3) && (!utilityModel.SelectTreatment))
            //{
            //    res.Code = "-3";
            //    res.Message = "请输入已完成的订单编号！";
            //    return toJson(res);
            //}
            //if (modelRes.OrderStatus == 2 && !utilityModel.SelectTreatment)
            //{
            //    res.Code = "-4";
            //    res.Message = "请输入未取消的订单号！";
            //    return toJson(res);
            //}


            res.Code = "1";
            res.Message = "";
            res.Data = modelRes;

            return toJson(res, "yyyy-MM-dd HH:mm:ss");
        }


        [HttpPost]
        [ActionName("getTreatmentDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getTreatmentDetail(JObject obj)
        {

            //TreatmentListFlag 更改订单信息的时候为0  取消订单状态的时候为1
            ObjectResult<TreatmentDetailForWeb_Model> res = new ObjectResult<TreatmentDetailForWeb_Model>();
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
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;

            TreatmentDetailForWeb_Model modelRes = new TreatmentDetailForWeb_Model();
            modelRes = Order_BLL.Instance.getTreatmentDetailForWeb(utilityModel.TreatmentCode);

            if (modelRes == null)
            {
                res.Code = "0";
                res.Message = "请输入正确的服务编号！";
                return toJson(res);
            }
            if (modelRes.CompanyID != this.CompanyID)
            {
                res.Code = "-1";
                res.Message = "请输入本公司的服务编号！";
                return toJson(res);
            }
            if (modelRes.BranchID != this.BranchID && this.BranchID != 0)
            {
                res.Code = "-2";
                res.Message = "请输入本店的服务编号！";
                return toJson(res);
            }
            if (modelRes.Status == 0 || modelRes.Status == 3)
            {
                res.Code = "-3";
                res.Message = "请输入已完成的服务编号！";
                return toJson(res);
            }

            res.Code = "1";
            res.Message = "";
            res.Data = modelRes;

            return toJson(res, "yyyy-MM-dd HH:mm:ss");
        }

        [HttpPost]
        [ActionName("updateOrder")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage updateOrder(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "操作失败！";
            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            OrderDetailOperationForWeb_Model model = new OrderDetailOperationForWeb_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<OrderDetailOperationForWeb_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.BranchID = this.BranchID;
            model.UpdaterID = this.UserID;
            model.UpdateTime = DateTime.Now.ToLocalTime();
            string message = "";
            int exRes = Order_BLL.Instance.updateOrder(model, out message);

            res.Code = exRes.ToString();
            res.Data = exRes == 1;
            res.Message = message;

            return toJson(res);
        }

        [HttpPost]
        [ActionName("cancelCompletedTreatment")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage cancelCompletedTreatment(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "操作失败！";
            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model model = new UtilityOperation_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            bool isSuccess = Order_BLL.Instance.cancelCompletedSchedule(model.TreatmentCode, this.UserID);
            if (isSuccess)
            {
                res.Code = "1";
                res.Data = isSuccess;
                res.Message = "操作成功";
            }
            else
            {
                res.Code = "0";
                res.Data = isSuccess;
                res.Message = "操作失败";
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("cancelCompletedOrder")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage cancelCompletedOrder(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "操作失败！";
            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model model = new UtilityOperation_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            res = Order_BLL.Instance.cancelOrder(model.OrderCode, this.UserID, this.CompanyID, this.BranchID);

            return toJson(res);
        }

        [HttpPost]
        [ActionName("cancelPayment")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage cancelPayment(JObject obj)
        {

            ObjectResult<List<CancelPaymentMsgForWeb>> res = new ObjectResult<List<CancelPaymentMsgForWeb>>();
            res.Code = "0";
            res.Data = null;
            res.Message = "操作失败！";
            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model model = new UtilityOperation_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            res = Payment_BLL.Instance.cancelPayment(model.PaymentCode, this.UserID, this.CompanyID, this.BranchID);

            return toJson(res);
        }

        [HttpPost]
        [ActionName("getPaymentDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getPaymentDetail(JObject obj)
        {
            ObjectResult<PaymentDetailInfo_Model> res = new ObjectResult<PaymentDetailInfo_Model>();
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
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;

            PaymentDetailInfo_Model modelRes = new PaymentDetailInfo_Model();
            modelRes = Payment_BLL.Instance.getPaymentDetailForWeb(utilityModel.CompanyID, utilityModel.PaymentCode, utilityModel.BranchID);

            if (modelRes == null)
            {
                res.Code = "0";
                res.Message = "请输入正确的12位支付编号!";
                return toJson(res);
            }

            if (modelRes.Status == 1 || modelRes.Status == 3 || modelRes.Status == 5)
            {
                res.Code = "-3";
                res.Message = "请输入未取消的支付号!";
                return toJson(res);
            }

            res.Code = "1";
            res.Message = "";
            res.Data = modelRes;

            return toJson(res, "yyyy-MM-dd HH:mm:ss");

        }

        [HttpPost]
        [ActionName("updatePaymentMode")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage updatePaymentMode(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "操作失败！";
            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UpdatePaymentForWeb model = new UpdatePaymentForWeb();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<UpdatePaymentForWeb>(strSafeJson);

            string message = "";
            int exRes = Payment_BLL.Instance.updatePaymentDetailMode(this.CompanyID,model.PaymentCode, model.DetailList, model.PaymentTime, this.UserID, model.ProfitList, model.IsChangeProfit == 1,model.IsUseRate, out message);

            res.Code = exRes.ToString();
            res.Data = exRes == 1;
            res.Message = message;

            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetBalanceDetailForWeb")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetBalanceDetailForWeb(JObject obj)
        {
            ObjectResult<GetBalanceDetailForWeb_Model> res = new ObjectResult<GetBalanceDetailForWeb_Model>();
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
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;

            GetBalanceDetailForWeb_Model modelRes = new GetBalanceDetailForWeb_Model();
            modelRes = ECard_BLL.Instance.GetBalanceDetailForWeb(utilityModel.CompanyID, utilityModel.BalanceCode, utilityModel.BranchID);

            if (modelRes == null)
            {
                res.Code = "0";
                res.Message = "请输入正确的12位交易编号!";
                return toJson(res);
            }

            res.Code = "1";
            res.Message = "";
            res.Data = modelRes;

            return toJson(res, "yyyy-MM-dd HH:mm:ss");

        }


        [HttpPost]
        [ActionName("CancelChargeForWeb")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage CancelChargeForWeb(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;
            utilityModel.UpdaterID = this.UserID;

            int code = ECard_BLL.Instance.CancelCharge(utilityModel.CompanyID, utilityModel.BranchID, utilityModel.BalanceCode, utilityModel.UpdaterID);
            res.Code = code.ToString();
            switch (code)
            {
                case 1:
                    res.Message = "操作成功!";
                    res.Data = true;
                    break;
                case 2:
                    res.Message = "撤销失败!";
                    break;
                case 3:
                    res.Message = "储值卡金额不足!";
                    break;
                default:
                    res.Message = "操作失败!";
                    break;
            }

            return toJson(res, "yyyy-MM-dd HH:mm:ss");

        }

        [HttpPost]
        [ActionName("UpdateChargeProfitForWeb")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage UpdateChargeProfitForWeb(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;
            utilityModel.UpdaterID = this.UserID;

            int code = ECard_BLL.Instance.UpdateChargeProfitForWeb(utilityModel.CompanyID, utilityModel.BalanceCode, utilityModel.UpdaterID, utilityModel.ProfitList);
            res.Code = code.ToString();
            switch (code)
            {
                case 1:
                    res.Message = "操作成功!";
                    break;
                default:
                    res.Message = "操作失败!";
                    break;
            }

            return toJson(res, "yyyy-MM-dd HH:mm:ss");

        }




        [HttpPost]
        [ActionName("GetGroupInfoForWeb")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetGroupInfoForWeb(JObject obj)
        {
            //TreatmentListFlag 更改订单信息的时候为0  取消订单状态的时候为1
            ObjectResult<GetGroupInfoForWeb_Model> res = new ObjectResult<GetGroupInfoForWeb_Model>();
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

            GetGroupInfoForWeb_Model modelRes = new GetGroupInfoForWeb_Model();
            modelRes = Order_BLL.Instance.GetGroupInfoForWeb(utilityModel.GroupNo, this.CompanyID,this.BranchID);

            if (modelRes == null)
            {
                res.Code = "0";
                res.Message = "请输入正确的16位服务编号！";
                return toJson(res);
            }

            res.Code = "1";
            res.Message = "";
            res.Data = modelRes;

            return toJson(res, "yyyy-MM-dd HH:mm:ss");
        }



        [HttpPost]
        [ActionName("GetCommodityDeliveryInfoForWeb")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCommodityDeliveryInfoForWeb(JObject obj)
        {

            //TreatmentListFlag 更改订单信息的时候为0  取消订单状态的时候为1
            ObjectResult<GetCommodityDelivery_Model> res = new ObjectResult<GetCommodityDelivery_Model>();
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

            GetCommodityDelivery_Model modelRes = new GetCommodityDelivery_Model();
            modelRes = Order_BLL.Instance.GetCommodityDeliveryInfoForWeb(utilityModel.DeliveryCode, this.CompanyID,this.BranchID);

            if (modelRes == null)
            {
                res.Code = "0";
                res.Message = "请输入正确的16位交付编号！";
                return toJson(res);
            }

            res.Code = "1";
            res.Message = "";
            res.Data = modelRes;

            return toJson(res, "yyyy-MM-dd HH:mm:ss");
        }




        [HttpPost]
        [ActionName("EditDelivery")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage EditDelivery(JObject obj)
        {

            //TreatmentListFlag 更改订单信息的时候为0  取消订单状态的时候为1
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
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


            CommodityDeliveryOperation_Model utilityModel = new CommodityDeliveryOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<CommodityDeliveryOperation_Model>(strSafeJson);

            utilityModel.CompanyID = this.CompanyID;
            utilityModel.UpdaterID = this.UserID;
            utilityModel.UpdateTime = DateTime.Now.ToLocalTime();
            int Res = Order_BLL.Instance.EditDelivery(utilityModel);

            switch (Res)
            {
                case 1:
                    res.Code = "1";
                    res.Message = "编辑成功";
                    res.Data = true;
                    break;
                case 0:
                    res.Message = "编辑失败";
                    break;
                case -1:
                    res.Message = "开始时间不能小于订单时间";
                    break;
                case -2:
                    res.Message = "订单编号错误";
                    break;
                default:
                    res.Message = "编辑失败";
                    break;
            }

            return toJson(res, "yyyy-MM-dd HH:mm:ss");
        }
        [HttpPost]
        [ActionName("CancelDelivey")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage CancelDelivey(JObject obj)
        {

            //TreatmentListFlag 更改订单信息的时候为0  取消订单状态的时候为1
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
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


            CommodityDeliveryOperation_Model utilityModel = new CommodityDeliveryOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<CommodityDeliveryOperation_Model>(strSafeJson);

            utilityModel.CompanyID = this.CompanyID;
            utilityModel.UpdaterID = this.UserID;
            utilityModel.UpdateTime = DateTime.Now.ToLocalTime();
            int Res = Order_BLL.Instance.CancelDelivey(utilityModel);

            switch (Res)
            {
                case 1:
                    res.Code = "1";
                    res.Message = "撤销成功";
                    res.Data = true;
                    break;
                case 0:
                    res.Message = "撤销失败";
                    break;
                case -1:
                    res.Message = "该记录已经被撤销";
                    break;
                case -2:
                    res.Message = "订单编号错误";
                    break;
                default:
                    res.Message = "撤销失败";
                    break;
            }

            return toJson(res, "yyyy-MM-dd HH:mm:ss");
        }


        [ActionName("CancelTGForWeb")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage CancelTGForWeb(JObject obj)
        {

            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
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


            EditTGForWebOperation_Model utilityModel = new EditTGForWebOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<EditTGForWebOperation_Model>(strSafeJson);

            utilityModel.CompanyID = this.CompanyID;
            utilityModel.UpdaterID = this.UserID;
            utilityModel.UpdateTime = DateTime.Now.ToLocalTime();
            int Res = Order_BLL.Instance.CancelTGForWeb(utilityModel);

            switch (Res)
            {
                case 1:
                    res.Code = "1";
                    res.Message = "取消成功";
                    res.Data = true;
                    break;
                case 0:
                    res.Message = "取消失败";
                    break;
                case -1:
                    res.Message = "该记录已经被取消";
                    break;
                case -2:
                    res.Message = "服务编号错误";
                    break;
                default:
                    res.Message = "取消失败";
                    break;
            }

            return toJson(res, "yyyy-MM-dd HH:mm:ss");
        }


        [ActionName("EditTGForWeb")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage EditTGForWeb(JObject obj)
        {

            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
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


            EditTGForWebOperation_Model utilityModel = new EditTGForWebOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<EditTGForWebOperation_Model>(strSafeJson);

            utilityModel.CompanyID = this.CompanyID;
            utilityModel.UpdaterID = this.UserID;
            utilityModel.UpdateTime = DateTime.Now.ToLocalTime();
            int Res = Order_BLL.Instance.EditTGForWeb(utilityModel);

            switch (Res)
            {
                case 1:
                    res.Code = "1";
                    res.Message = "编辑成功";
                    res.Data = true;
                    break;
                case 0:
                    res.Message = "编辑失败";
                    break;
                case -1:
                    res.Message = "开始时间不能早于下单时间";
                    break;
                case -2:
                    res.Message = "服务编号错误";
                    break;
                default:
                    res.Message = "编辑失败";
                    break;
            }

            return toJson(res, "yyyy-MM-dd HH:mm:ss");
        }



        [ActionName("EdtiBalanceProfit")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage EdtiBalanceProfit(JObject obj)
        {

            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
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


            BalanceForWebOperation_Model utilityModel = new BalanceForWebOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<BalanceForWebOperation_Model>(strSafeJson);

            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CreateTime = DateTime.Now.ToLocalTime();
            utilityModel.CreateID = this.UserID;
            bool Res = ECard_BLL.Instance.EdtiBalanceProfit(utilityModel);

            if (Res)
            {

                res.Code = "1";
                res.Message = "编辑成功";
                res.Data = true;
            }
            else
            {

                res.Message = "编辑失败";
            }
            return toJson(res, "yyyy-MM-dd HH:mm:ss");
        }



    }
}
