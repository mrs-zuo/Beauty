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
    public class OrderController : BaseController
    {
        public ActionResult AllOrder()
        {
            GetOrderListOperation_Model utilityModel = new GetOrderListOperation_Model();
            utilityModel.PageIndex = 1;
            utilityModel.PageSize = 999999;
            utilityModel.PaymentStatus = 0;//所有
            utilityModel.Status = -1;//除取消外的所有
            utilityModel.ProductType = -1;
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            GetOrderListRes_Model OrderListModel = new GetOrderListRes_Model();
            bool issuccess = GetPostResponseNoRedirect("Order", "GetOrderList", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<GetOrderListRes_Model> res = new ObjectResult<GetOrderListRes_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<GetOrderListRes_Model>>(data);

                if (res.Code == "1")
                {
                    OrderListModel = res.Data;
                }
            }
            return View(OrderListModel);
        }

        public ActionResult UnpaidOrder()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CustomerID = this.UserID;
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            List<UnPaidListByCustomerID_Model> unPayList = null;
            bool issuccess = GetPostResponseNoRedirect("Payment", "UnPaidListByCustomerID", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<UnPaidListByCustomerID_Model>> res = new ObjectResult<List<UnPaidListByCustomerID_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<UnPaidListByCustomerID_Model>>>(data);

                if (res.Code == "1")
                {
                    unPayList = new List<UnPaidListByCustomerID_Model>();
                    unPayList = res.Data;
                }
            }
            return View(unPayList);
        }

        public ActionResult UnconfirmedOrder()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CustomerID = this.UserID;
            utilityModel.Type = -1;// -1:全部 0:服务 1:商品
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            List<TGList_Model> tgList = new List<TGList_Model>();
            bool issuccess = GetPostResponseNoRedirect("Order", "GetUnconfirmTreatGroup", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<TGList_Model>> res = new ObjectResult<List<TGList_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<TGList_Model>>>(data);

                if (res.Code == "1")
                {
                    tgList = res.Data;
                }
            }

            return View(tgList);
        }

        public ActionResult ComfirmTG(List<CompleteTGDetailOperation_Model> TGDetailList)
        {
            CompleteTGOperation_Model model = new CompleteTGOperation_Model();
            model.TGDetailList = TGDetailList;
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Order", "ConfirmTreatGroup", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult UnReviewedOrder()
        {
            string data = "";
            List<GetReviewList_Model> list = new List<GetReviewList_Model>();
            bool issuccess = GetPostResponseNoRedirect("Review", "GetUnReviewList", "", out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<GetReviewList_Model>> res = new ObjectResult<List<GetReviewList_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<GetReviewList_Model>>>(data);

                if (res.Code == "1")
                {
                    list = res.Data;
                }
            }
            return View(list);
        }

        public ActionResult ReviewOrder()
        {
            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel.GroupNo = StringUtils.GetDbLong(QueryString.SafeQ("gn"));
            string postJson = JsonConvert.SerializeObject(operationModel);
            string data = "";
            GetReviewDetail_Model model = null;
            bool issuccess = GetPostResponseNoRedirect("Review", "GetReviewDetail", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            ObjectResult<GetReviewDetail_Model> res = new ObjectResult<GetReviewDetail_Model>();
            res = JsonConvert.DeserializeObject<ObjectResult<GetReviewDetail_Model>>(data);

            if (res.Code == "1" && res.Data != null)
            {
                model = new GetReviewDetail_Model();
                model = res.Data;
            }

            return View(model);
        }

        public ActionResult EditReview(ReviewOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Review", "EditReview", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult OrderDetail()
        {
            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel.OrderObjectID = QueryString.IntSafeQ("oId");
            operationModel.ProductType = QueryString.IntSafeQ("t");
            operationModel.Status = 0;
            string postJson = JsonConvert.SerializeObject(operationModel);
            string data = "";
            GetOrderDetail_Model model = null;
            bool issuccess = GetPostResponseNoRedirect("Order", "GetOrderDetail", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            else
            {

                ObjectResult<GetOrderDetail_Model> res = new ObjectResult<GetOrderDetail_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<GetOrderDetail_Model>>(data);

                if (res.Code == "1")
                {
                    model = new GetOrderDetail_Model();
                    model = res.Data;
                }
            }

            operationModel.Status = -1;
            postJson = JsonConvert.SerializeObject(operationModel);
            data = "";
            issuccess = GetPostResponseNoRedirect("Order", "GetTreatGroupByOrderObjectID", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            else
            {

                ObjectResult<List<Group>> res = new ObjectResult<List<Group>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<Group>>>(data);

                if (res.Code == "1")
                {
                    ViewBag.CompleteList = res.Data;
                }
            }

            return View(model);
        }

        public ActionResult UnfinishedOrder()
        {
            GetOrderListOperation_Model utilityModel = new GetOrderListOperation_Model();
            utilityModel.ProductType = -1;
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            List<GetUnfinishOrder_Model> list = null;
            bool issuccess = GetPostResponseNoRedirect("Order", "GetUnfinishOrder", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            ObjectResult<List<GetUnfinishOrder_Model>> res = new ObjectResult<List<GetUnfinishOrder_Model>>();
            res = JsonConvert.DeserializeObject<ObjectResult<List<GetUnfinishOrder_Model>>>(data);

            if (res.Code == "1")
            {
                list = res.Data;
            }


            return View(list);
        }


        public ActionResult PayOrder()
        {
            PaymentAddOperation_Model addPayment = new PaymentAddOperation_Model();

            string strJson = Request.Form["txtOrderList"].ToString();
            PaymentInfoParam tempModel = new PaymentInfoParam();
            tempModel = JsonConvert.DeserializeObject<PaymentInfoParam>(strJson);
            addPayment.OrderCount = tempModel.OrderCount;
            addPayment.TotalPrice = StringUtils.GetDbDecimal(tempModel.TotalSalePrice);
            addPayment.OrderIDList = new List<int>();
            foreach (PaymentInfoDetailOperation_Model item in tempModel.OrderList)
            {
                addPayment.OrderIDList.Add(item.OrderID);
            }

            ViewBag.AddPayment = addPayment;

            GetPaymentInfoOperation_Model utilityModel = new GetPaymentInfoOperation_Model();
            utilityModel.BranchID = tempModel.BranchID;
            utilityModel.OrderList = tempModel.OrderList;
            string postJson = JsonConvert.SerializeObject(utilityModel);
            string data = "";
            bool issuccess;
            PaymentInfo_Model model = new PaymentInfo_Model();

            issuccess = GetPostResponseNoRedirect("Payment", "GetPaymentInfo", postJson, out data, false, true);


            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            ObjectResult<PaymentInfo_Model> res = new ObjectResult<PaymentInfo_Model>();
            res = JsonConvert.DeserializeObject<ObjectResult<PaymentInfo_Model>>(data);

            if (res.Code == "1")
            {
                model = new PaymentInfo_Model();
                model = res.Data;
            }




            return View(model);
        }


        public ActionResult AddPayment(PaymentAddOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Payment", "AddPayment", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

    }
}
