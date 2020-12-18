using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
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
    public class CustomerSourceController : BaseController
    {
        //
        // GET: /CustomerSource/

        public ActionResult CustomerSourceList()
        {
            bool issuccess = false;
            string data;
            issuccess = GetPostResponseNoRedirect("CustomerSource_M", "GetCustomerSourceList", "", out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<CustomerSource_Model>> res = new ObjectResult<List<CustomerSource_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<CustomerSource_Model>>>(data);

                if (res.Code == "1")
                {
                    ViewBag.CustomerSource = res.Data;
                }
            }
            return View();
        }

        public ActionResult CustomerSourceEdit()
        {
            UtilityOperation_Model model = new UtilityOperation_Model();
            model.ID = QueryString.IntSafeQ("cd");
            if (model.ID > 0)
            {
                string postJson = JsonConvert.SerializeObject(model);
                bool issuccess = false;
                string data;
                issuccess = GetPostResponseNoRedirect("CustomerSource_M", "GetCustomerSourceDetail", postJson, out data, false);
                if (!issuccess)
                {
                    return RedirectUrl(data, "", false);
                }

                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<CustomerSource_Model> res = new ObjectResult<CustomerSource_Model>();
                    res = JsonConvert.DeserializeObject<ObjectResult<CustomerSource_Model>>(data);

                    if (res.Code == "1")
                    {
                        ViewBag.CustomerSource = res.Data;
                    }
                }
            }
            return View();
        }

        public ActionResult OperateCustomerSource(CustomerSource_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            res.Message = "处理失败";
            if (model.ID == 0)
            {
                issuccess = GetPostResponseNoRedirect("CustomerSource_M", "addCustomerSource", postJson, out data);
            }
            else
            {
                issuccess = GetPostResponseNoRedirect("CustomerSource_M", "UpdateCustomerSource", postJson, out data);
            }

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }



        public ActionResult deleteCustomerSource(int ID)
        {
            CustomerSource_Model model = new CustomerSource_Model();
            model.ID = ID;
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            res.Message = "处理失败";
            issuccess = GetPostResponseNoRedirect("CustomerSource_M", "DeleteCustomerSource", postJson, out data);

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
