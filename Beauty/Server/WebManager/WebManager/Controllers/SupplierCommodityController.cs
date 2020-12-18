using HS.Framework.Common.Entity;
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
    public class SupplierCommodityController : BaseController
    {
        public ActionResult EditSupplierCommodity()
        {
            return View();
        }


        public ActionResult GetSupplierList(UtilityOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<List<Supplier_Model>> res = new ObjectResult<List<Supplier_Model>>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("SupplierCommodity_M", "GetSupplierList", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }


        public ActionResult GetCommodityList(UtilityOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<List<Commodity_Model>> res = new ObjectResult<List<Commodity_Model>>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("SupplierCommodity_M", "GetCommodityList", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);//
            }
        }

        public ActionResult GetSupplierCommodityList(UtilityOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<List<SupplierCommodity_Model>> res = new ObjectResult<List<SupplierCommodity_Model>>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("SupplierCommodity_M", "GetSupplierCommodityList", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult ChangeSupplierCommodity(SupplierCommodity_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "更新失败";
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("SupplierCommodity_M", "ChangeSupplierCommodity", postJson, out data);

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