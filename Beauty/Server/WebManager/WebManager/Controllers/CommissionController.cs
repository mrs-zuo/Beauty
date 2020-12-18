using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.Table_Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebManager.Controllers.Base;

namespace WebManager.Controllers
{
    public class CommissionController : BaseController
    {
        //
        // GET: /Commission/

        public ActionResult AccountList()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.InputSearch = Server.UrlDecode(Request.QueryString["InputSearch"]);
            bool issuccess = false;
            string data;
            string postJson = JsonConvert.SerializeObject(utilityModel);
            issuccess = GetPostResponseNoRedirect("Commission_M", "GetAccountList", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<Commission_Account_Model>> res = new ObjectResult<List<Commission_Account_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<Commission_Account_Model>>>(data);

                if (res.Code == "1")
                {
                    ViewBag.AccountList = res.Data;
                }
            }
            return View();
        }

        public ActionResult EditAccount()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.AccountID = StringUtils.GetDbInt(QueryString.IntSafeQ("aId").ToString(), 0);
            int EditFlag = StringUtils.GetDbInt(QueryString.IntSafeQ("e").ToString(),0);
            ViewBag.EditFlag = EditFlag;

            if (utilityModel.AccountID <= 0) {
                return RedirectUrl("10013", "", false);
            }

            string postJson = JsonConvert.SerializeObject(utilityModel);
            bool issuccess = false;
            string data;
            issuccess = GetPostResponseNoRedirect("Commission_M", "GetAccountDetail", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<Commission_Account_Model> res = new ObjectResult<Commission_Account_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<Commission_Account_Model>>(data);

                if (res.Code == "1")
                {
                    ViewBag.Account = res.Data;
                }
            }
            return View();
        }


        public ActionResult UpdateAccount(Commission_Account_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            res.Message = "修改失败";
            issuccess = GetPostResponseNoRedirect("Commission_M", "EditAccount", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }


        public ActionResult ServiceList()
        {

            UtilityOperation_Model model = new UtilityOperation_Model();

            model.BranchID = -1;
            model.CategoryID = -1;
            model.ImageHeight = 70;
            model.ImageWidth = 70;
            model.InputSearch = Server.UrlDecode(Request.QueryString["InputSearch"]);
            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);

            string data = string.Empty;
            bool issuccess = this.GetPostResponseNoRedirect("Commission_M", "GetServiceList", param, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            ObjectResult<List<Service_Model>> res = new ObjectResult<List<Service_Model>>();
            res = JsonConvert.DeserializeObject<ObjectResult<List<Service_Model>>>(data);

            if (res.Code == "1")
            {
                ViewBag.ServiceList = res.Data;
            }

            return View();
        }

        public ActionResult EditService()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.ServiceCode = StringUtils.GetDbLong(QueryString.SafeQ("cd").ToString(), 0);
            int EditFlag = StringUtils.GetDbInt(QueryString.IntSafeQ("e").ToString(), 0);
            ViewBag.EditFlag = EditFlag;

            if (utilityModel.ServiceCode <= 0)
            {
                return RedirectUrl("10013", "", false);
            }

            string postJson = JsonConvert.SerializeObject(utilityModel);
            bool issuccess = false;
            string data;
            issuccess = GetPostResponseNoRedirect("Commission_M", "GetServiceDetail", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<Commission_Product_Model> res = new ObjectResult<Commission_Product_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<Commission_Product_Model>>(data);

                if (res.Code == "1")
                {
                    ViewBag.Service = res.Data;
                }
            }
            return View();
        }

        public ActionResult CommodityList()
        {
            UtilityOperation_Model model = new UtilityOperation_Model();

            model.BranchID = -1;
            model.CategoryID = -1;
            model.ImageHeight = 70;
            model.ImageWidth = 70;
            model.InputSearch = Server.UrlDecode(Request.QueryString["InputSearch"]);
            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);

            string data = string.Empty;
            bool issuccess = this.GetPostResponseNoRedirect("Commission_M", "getCommodityList", param, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            ObjectResult<List<Commodity_Model>> res = new ObjectResult<List<Commodity_Model>>();
            res = JsonConvert.DeserializeObject<ObjectResult<List<Commodity_Model>>>(data);

            if (res.Code == "1")
            {
                ViewBag.Commodity = res.Data;
            }

            return View();
        }

        public ActionResult EditCommodity()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.CommodityCode = StringUtils.GetDbLong(QueryString.SafeQ("cd").ToString(), 0);
            int EditFlag = StringUtils.GetDbInt(QueryString.IntSafeQ("e").ToString(), 0);
            ViewBag.EditFlag = EditFlag;

            if (utilityModel.CommodityCode <= 0)
            {
                return RedirectUrl("10013", "", false);
            }

            string postJson = JsonConvert.SerializeObject(utilityModel);
            bool issuccess = false;
            string data;
            issuccess = GetPostResponseNoRedirect("Commission_M", "GetCommodityDetail", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<Commission_Product_Model> res = new ObjectResult<Commission_Product_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<Commission_Product_Model>>(data);

                if (res.Code == "1")
                {
                    ViewBag.Commodity = res.Data;
                }
            }
            return View();
        }


        public ActionResult EditProduct(Commission_Product_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            res.Message = "修改失败";
            issuccess = GetPostResponseNoRedirect("Commission_M", "EditProduct", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }


        public ActionResult CardList()
        {
            string data = string.Empty;
            bool issuccess = this.GetPostResponseNoRedirect("Commission_M", "GetCardList", null, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            ObjectResult<List<Commission_Card_Model>> res = new ObjectResult<List<Commission_Card_Model>>();
            res = JsonConvert.DeserializeObject<ObjectResult<List<Commission_Card_Model>>>(data);

            if (res.Code == "1")
            {
                ViewBag.CardList = res.Data;
            }
            return View();
        }

        public ActionResult EditCard()
        {
            Commission_Card_Model utilityModel = new Commission_Card_Model();
            utilityModel.CardCode = StringUtils.GetDbLong(QueryString.SafeQ("cd").ToString(), 0);

            int EditFlag = StringUtils.GetDbInt(QueryString.IntSafeQ("e").ToString(), 0);
            ViewBag.EditFlag = EditFlag;
            if (utilityModel.CardCode <= 0)
            {
                return RedirectUrl("10013", "", false);
            }

            string postJson = JsonConvert.SerializeObject(utilityModel);
            bool issuccess = false;
            string data;
            issuccess = GetPostResponseNoRedirect("Commission_M", "GetCardDetail", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<Commission_Card_Model> res = new ObjectResult<Commission_Card_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<Commission_Card_Model>>(data);

                if (res.Code == "1")
                {
                    ViewBag.Card = res.Data;
                }
            }
            return View();
        }




        public ActionResult UpdateCard(Commission_Card_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            res.Message = "修改失败";
            issuccess = GetPostResponseNoRedirect("Commission_M", "EditCard", postJson, out data);

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
