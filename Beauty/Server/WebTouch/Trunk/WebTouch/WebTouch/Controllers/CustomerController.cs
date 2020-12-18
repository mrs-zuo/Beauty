using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.View_Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebTouch.Controllers.Base;

namespace WebTouch.Controllers
{
    public class CustomerController : BaseController
    {
        public ActionResult MyFavorite()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();

            utilityModel.ImageHeight = 98;
            utilityModel.ImageWidth = 98;
            utilityModel.ProductType = -1;

            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            List<FavoriteList_Model> list = null;
            bool issuccess = GetPostResponseNoRedirect("Customer", "getFavorteList", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<FavoriteList_Model>> res = new ObjectResult<List<FavoriteList_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<FavoriteList_Model>>>(data);

                if (res.Code == "1")
                {
                    list = new List<FavoriteList_Model>();
                    list = res.Data;
                }
            }
            return View(list);
        }

        public ActionResult MyInformation()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();

            utilityModel.ImageHeight = 100;
            utilityModel.ImageWidth = 100;

            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            CustomerBasic_Model customerModel = new CustomerBasic_Model();
            bool issuccess = GetPostResponseNoRedirect("Customer", "getCustomerBasic", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<CustomerBasic_Model> res = new ObjectResult<CustomerBasic_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<CustomerBasic_Model>>(data);

                if (res.Code == "1")
                {
                    customerModel = res.Data;
                }
            }
            return View(customerModel);
        }

        public ActionResult EditInformation()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();

            utilityModel.ImageHeight = 100;
            utilityModel.ImageWidth = 100;

            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            CustomerBasic_Model customerModel = new CustomerBasic_Model();
            bool issuccess = GetPostResponseNoRedirect("Customer", "getCustomerBasic", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<CustomerBasic_Model> res = new ObjectResult<CustomerBasic_Model>();
                    res = JsonConvert.DeserializeObject<ObjectResult<CustomerBasic_Model>>(data);

                    if (res.Code == "1")
                    {
                        customerModel = res.Data;
                    }
            }
            return View(customerModel);
        }

        public ActionResult customerUpdateBasic(CustomerBasicUpdateOperation_Model model)
        {
            if (!string.IsNullOrWhiteSpace(model.ImageString) && model.ImageString.IndexOf("image/") > 0)
            {
                model.ImageType = model.ImageString.Substring(model.ImageString.IndexOf("image/") + 6, model.ImageString.IndexOf("base64,") - model.ImageString.IndexOf("image/") - 7);
            }
            model.ImageString = model.ImageString.Substring(model.ImageString.IndexOf("base64,") + 7, model.ImageString.Length - model.ImageString.IndexOf("base64,") - 8);
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Customer", "updateCustomerBasic", postJson, out data);
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
