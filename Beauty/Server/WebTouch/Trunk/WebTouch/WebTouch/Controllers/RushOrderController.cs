using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.View_Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebTouch.Controllers.Base;
using WebTouch.Models;

namespace WebTouch.Controllers
{
    public class RushOrderController : BaseController
    {

        public ActionResult CreateRushOrder()
        {
            string data = "";
            PromotionProductDetail_Model model = new PromotionProductDetail_Model();
            int ProductType = QueryString.IntSafeQ("t");
            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel.ID = QueryString.IntSafeQ("pi");
            operationModel.PromotionID = QueryString.SafeQ("pc");
            operationModel.ImageHeight = 200;
            operationModel.ImageWidth = 200;
            string postJson = JsonConvert.SerializeObject(operationModel);
            bool issuccess = false;
            if (ProductType == 0)
            {
                issuccess = GetPostResponseNoRedirect("Service", "GetPromotionServiceDetailByID", postJson, out data, false);
            }
            else
            {
                issuccess = GetPostResponseNoRedirect("Commodity", "GetPromotionCommodityDetailByID", postJson, out data, false);
            }

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            ObjectResult<PromotionProductDetail_Model> res = new ObjectResult<PromotionProductDetail_Model>();
            res = JsonConvert.DeserializeObject<ObjectResult<PromotionProductDetail_Model>>(data);

            if (res.Code == "1")
            {
                model = res.Data;
            }
            return View(model);
        }

        public ActionResult PayRushOrder()
        {
            string data = "";
            Cookie_Model cookieModel = new Cookie_Model();
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.OrderID = QueryString.IntSafeQ("ro");
            //utilityModel.WeChatOpenID = "o4voAwU7hli4D3B1ZVTrNxfB7gWE";
            utilityModel.WeChatOpenID = this.WeChatOpenID;
            string postJson = JsonConvert.SerializeObject(utilityModel);
            GetRushOrderDetail_Model model = null;
            bool issuccess = GetPostResponseNoRedirect("Order", "GetRushOrderDetail", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            ObjectResult<GetRushOrderDetail_Model> resDetail = new ObjectResult<GetRushOrderDetail_Model>();
            resDetail = JsonConvert.DeserializeObject<ObjectResult<GetRushOrderDetail_Model>>(data);
            if (resDetail.Code == "1")
            {
                model = new GetRushOrderDetail_Model();
                model = resDetail.Data;
                if (DateTime.Now > model.LimitedPaymentTime)
                {
                    return Redirect("/RushOrder/MyRushOrder");
                }
            }
            return View(model);
        }



        public ActionResult MyRushOrder()
        {
            string data = "";
            bool issuccess = GetPostResponseNoRedirect("Order", "GetRushOrderList", "", out data, false);
            List<GetRushOrderList_Model> list = new List<GetRushOrderList_Model>();

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            ObjectResult<List<GetRushOrderList_Model>> res = new ObjectResult<List<GetRushOrderList_Model>>();
            res = JsonConvert.DeserializeObject<ObjectResult<List<GetRushOrderList_Model>>>(data);

            if (res.Code == "1")
            {
                list = res.Data;
            }
            return View(list);
        }


        public ActionResult RushOrderDetail()
        {
            string data = "";
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.OrderID = QueryString.IntSafeQ("ro");
            string postJson = JsonConvert.SerializeObject(utilityModel);
            bool issuccess = GetPostResponseNoRedirect("Order", "GetRushOrderDetail", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "/RushOrder/MyRushOrder", false);
            }
            GetRushOrderDetail_Model model = new GetRushOrderDetail_Model();

            ObjectResult<GetRushOrderDetail_Model> res = new ObjectResult<GetRushOrderDetail_Model>();
            res = JsonConvert.DeserializeObject<ObjectResult<GetRushOrderDetail_Model>>(data);

            if (res.Code == "1")
            {

                if (!string.IsNullOrWhiteSpace(res.Data.NetTradeNo) && res.Data.PaymentStatus == 0)
                {
                    utilityModel.NetTradeNo = res.Data.NetTradeNo;
                    postJson = JsonConvert.SerializeObject(utilityModel);
                    data = "";
                    issuccess = GetPostResponseNoRedirect("Payment", "GetWeChatPayRes", postJson, out data, false);
                    if (issuccess)
                    {
                        issuccess = GetPostResponseNoRedirect("Order", "GetRushOrderDetail", postJson, out data, false);
                        if (issuccess)
                        {
                            data = "";
                            res = new ObjectResult<GetRushOrderDetail_Model>();
                            res = JsonConvert.DeserializeObject<ObjectResult<GetRushOrderDetail_Model>>(data);
                            if (res.Code == "1")
                            {
                                res.Data = model;
                            }
                            else
                            {
                                return RedirectUrl(data, "/RushOrder/MyRushOrder", false);
                            }
                        }
                    }
                    else
                    {
                        model = res.Data;
                    }
                }
                else
                {
                    model = res.Data;
                }

            }

            return View(model);
        }

        public ActionResult AddRushOrder(AddRushOrderOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<int> res = new ObjectResult<int>();
            bool issuccess = GetPostResponseNoRedirect("Order", "AddRushOrder", postJson, out data, false);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult WXPayResults()
        {
            string data = "";

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.NetTradeNo = QueryString.SafeQ("tr");
            string postJson = JsonConvert.SerializeObject(utilityModel);
            bool issuccess = GetPostResponseNoRedirect("Payment", "GetWeChatPayRes", postJson, out data, false);
            WeChatPayResault_Model model = new WeChatPayResault_Model();

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            ObjectResult<WeChatPayResault_Model> res = new ObjectResult<WeChatPayResault_Model>();
            res = JsonConvert.DeserializeObject<ObjectResult<WeChatPayResault_Model>>(data);

            if (res.Code == "1")
            {
                model = res.Data;
            }
            return View(model);
        }

    }
}
