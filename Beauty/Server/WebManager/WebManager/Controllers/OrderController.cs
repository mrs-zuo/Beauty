using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebManager.Controllers.Base;

namespace WebManager.Controllers
{
    public class OrderController : BaseController
    {
        public ActionResult OrderEdit()
        {
            return View();
        }

        public ActionResult OrderEditNew()
        {
            return View();
        }

        public ActionResult GetAccountList()
        {
            ObjectResult<List<AccountListForWeb_Model>> res = new ObjectResult<List<AccountListForWeb_Model>>();
            res.Code = "0";
            res.Data = null;
            res.Message = "操作失败！";

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.BranchID = this.BranchID;
            utilityModel.Available = 1;
            string data;
            string postJson = JsonConvert.SerializeObject(utilityModel);
            bool result = GetPostResponseNoRedirect("Account_M", "GetAccountList", postJson, out data);

            if (!result)
                return Json(res);
            else
                res = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<List<AccountListForWeb_Model>>>(data);
            return Json(res);
        }

        public ContentResult getOrderDetail(UtilityOperation_Model model)
        {
            ObjectResult<OrderDetailForWeb_Model> res = new ObjectResult<OrderDetailForWeb_Model>();
            res.Code = "0";
            res.Data = null;
            res.Message = "操作失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Order_M", "getOrderDetail", param, out data);

            if (!result)
                return Content(JsonConvert.SerializeObject(res));
            else
            {
                return Content(data);
            }
        }

        public ContentResult getTreatmentDetail(UtilityOperation_Model model)
        {
            ObjectResult<TreatmentDetailForWeb_Model> res = new ObjectResult<TreatmentDetailForWeb_Model>();
            res.Code = "0";
            res.Data = null;
            res.Message = "操作失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Order_M", "getTreatmentDetail", param, out data);

            if (!result)
                return Content(JsonConvert.SerializeObject(res));
            else
            {
                //var timeConverter = new IsoDateTimeConverter { DateTimeFormat = "yyyy-MM-dd HH:mm" };
                //res = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<TreatmentDetailForWeb_Model>>(data);
                return Content(data);
            }
        }

        public ActionResult updateOrder(OrderDetailOperationForWeb_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "获取失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Order_M", "updateOrder", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");
        }

        public ActionResult cancelCompletedTreatment(UtilityOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "操作失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Order_M", "cancelCompletedTreatment", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");
        }

        public ActionResult cancelCompletedOrder(UtilityOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "操作失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Order_M", "cancelCompletedOrder", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");
        }



        public ContentResult getPaymentDetail(UtilityOperation_Model model)
        {
            ObjectResult<PaymentDetailInfo_Model> res = new ObjectResult<PaymentDetailInfo_Model>();
            res.Code = "0";
            res.Data = null;
            res.Message = "操作失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Order_M", "getPaymentDetail", param, out data);

            if (!result)
                return Content(JsonConvert.SerializeObject(res));
            else
            {
                return Content(data);
            }
        }

        public ActionResult updatePaymentMode(UpdatePaymentForWeb model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "操作失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Order_M", "updatePaymentMode", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");
        }


        public ActionResult cancelPayment(UtilityOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "操作失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Order_M", "cancelPayment", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");
        }



        public ContentResult getBalanceDetail(UtilityOperation_Model model)
        {
            ObjectResult<GetBalanceDetailForWeb_Model> res = new ObjectResult<GetBalanceDetailForWeb_Model>();
            res.Code = "0";
            res.Data = null;
            res.Message = "操作失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Order_M", "GetBalanceDetailForWeb", param, out data);

            if (!result)
                return Content(JsonConvert.SerializeObject(res));
            else
            {
                return Content(data);
            }
        }

        public ActionResult cancelBalance(UtilityOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "操作失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Order_M", "CancelChargeForWeb", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");
        }




        public ContentResult getTGDetail(UtilityOperation_Model model)
        {
            ObjectResult<GetGroupInfoForWeb_Model> res = new ObjectResult<GetGroupInfoForWeb_Model>();
            res.Code = "0";
            res.Data = null;
            res.Message = "操作失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Order_M", "GetGroupInfoForWeb", param, out data);

            if (!result)
                return Content(JsonConvert.SerializeObject(res));
            else
            {
                return Content(data);
            }
        }




        public ContentResult getDeliveryDetail(UtilityOperation_Model model)
        {
            ObjectResult<GetCommodityDelivery_Model> res = new ObjectResult<GetCommodityDelivery_Model>();
            res.Code = "0";
            res.Data = null;
            res.Message = "操作失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Order_M", "GetCommodityDeliveryInfoForWeb", param, out data);

            if (!result)
                return Content(JsonConvert.SerializeObject(res));
            else
            {
                return Content(data);
            }
        }

        public ContentResult EditDelivery(CommodityDeliveryOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "操作失败！";
            bool result = false;
            string data = "";
            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            if (model.CDStartTime > model.CDEndTime && model.CDEndTime != null)
            {
                res.Message = "开始时间不能小于结束时间";
            }
            else
            {
                result = this.GetPostResponseNoRedirect("Order_M", "EditDelivery", param, out data);
            }

            if (!result)
                return Content(JsonConvert.SerializeObject(res));
            else
            {
                return Content(data);
            }
        }


        public ContentResult CancelDelivey(CommodityDeliveryOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "撤销失败！";
            bool result = false;
            string data = "";
            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            result = this.GetPostResponseNoRedirect("Order_M", "CancelDelivey", param, out data);

            if (!result)
                return Content(JsonConvert.SerializeObject(res));
            else
            {
                return Content(data);
            }
        }

        public ContentResult CancelTG(EditTGForWebOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "撤销失败！";
            bool result = false;
            string data = "";
            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            result = this.GetPostResponseNoRedirect("Order_M", "CancelTGForWeb", param, out data);

            if (!result)
                return Content(JsonConvert.SerializeObject(res));
            else
            {
                return Content(data);
            }
        }



        public ContentResult EditTG(EditTGForWebOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "编辑失败！";
            bool result = false;
            string data = "";
            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            if (model.StartTime > model.EndTime && model.EndTime != null)
            {
                res.Message = "开始时间不能小于结束时间";
            }
            else
            {
                result = this.GetPostResponseNoRedirect("Order_M", "EditTGForWeb", param, out data);
            }

            if (!result)
                return Content(JsonConvert.SerializeObject(res));
            else
            {
                return Content(data);
            }
        }

        public ActionResult EdtiBalanceProfit(BalanceForWebOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "操作失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Order_M", "EdtiBalanceProfit", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");
        }

    }
}
