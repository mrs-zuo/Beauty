using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebManager.Controllers.Base;
using WebManager.Models;
using HS.Framework.Common.Entity;
using Newtonsoft.Json;
using Model.Operation_Model;
using Model.View_Model;
using HS.Framework.Common.Safe;
using HS.Framework.Common.Util;

namespace WebManager.Controllers
{
    public class SupplierController : BaseController
    {
        public ActionResult GetSupplierList()
        {
            ViewBag.isBranch = this.BranchID > 0;
            string data = string.Empty;
            SupplierList_Model model = new SupplierList_Model();
            model.CompanyID = this.CompanyID;
            model.InputSearch = Server.UrlDecode(Request.QueryString["InputSearch"]); 
            string postJson = JsonConvert.SerializeObject(model);
            bool issuccess = GetPostResponseNoRedirect("Supplier_M", "GetSupplierList", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            ObjectResult<List<SupplierList_Model>> res = new ObjectResult<List<SupplierList_Model>>();
            res = JsonConvert.DeserializeObject<ObjectResult<List<SupplierList_Model>>>(data);
            if (res.Code.Equals("1"))
            {
                return View(res.Data);
            }
            return View();
        }

        public ActionResult EditSupplier()
        {
            ViewBag.isBranch = this.BranchID > 0;
            SupplierList_Model model = new SupplierList_Model();
            model.CompanyID = this.CompanyID;
            model.SupplierID = StringUtils.GetDbInt(QueryString.IntSafeQ("SupplierID").ToString(), -1);
            if (model.SupplierID > 0)
            {
                string postJson = JsonConvert.SerializeObject(model);
                string data;
                bool issuccess = GetPostResponseNoRedirect("Supplier_M", "GetSupplierDetail", postJson, out data, false);
                if (!issuccess)
                {
                    return RedirectUrl(data, "", false);
                }

                ObjectResult<SupplierList_Model> res = new ObjectResult<SupplierList_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<SupplierList_Model>>(data);
                if (res.Code.Equals("1"))
                {
                    return View(res.Data);
                }
            }
            return View();
        }

        public ActionResult AddSupplier(SupplierList_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "新增失败";
           
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            bool issuccess = GetPostResponseNoRedirect("Supplier_M", "AddSupplier", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult UpdateSupplier(SupplierList_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";

            if (model.SupplierID > 0)
            {
                bool issuccess = GetPostResponseNoRedirect("Supplier_M", "UpdateSupplier", postJson, out data);
                if (issuccess)
                {
                    return Content(data, "application/json; charset=utf-8");
                }
                else
                {
                    return Json(res);
                }
            }
            else
            {
                return Json(res);
            }

        }

        public ActionResult DeleteSupplier(SupplierList_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "删除失败";

            bool issuccess = GetPostResponseNoRedirect("Supplier_M", "DeleteSupplier", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }
        public ActionResult IsExsitSupplierName(SupplierList_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("Supplier_M", "IsExsitSupplierName", postJson, out data);

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