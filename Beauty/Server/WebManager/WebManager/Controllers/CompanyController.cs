using System;
using System.Collections.Generic;
using System.Linq;
using System.Transactions;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using WebMatrix.WebData;
using WebManager.Models;
using WebManager.Controllers.Base;
using Model.Table_Model;
using Newtonsoft.Json;
using HS.Framework.Common.Entity;
using Model.Operation_Model;

namespace WebManager.Controllers
{
    public class CompanyController : BaseController
    {
        public ActionResult GetCompanyList()
        {
            return View();
        }
        public ActionResult EditCompany()
        {

            string data = "";
            ViewBag.List = null;
            bool issuccess = GetPostResponseNoRedirect("Company_M", "GetCompanyDetail", "", out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<Company_Model> res = new ObjectResult<Company_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<Company_Model>>(data);

                if (res.Code == "1")
                {
                    ViewBag.Company = res.Data;
                }
            }

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.BranchID = 0;
            string postJson = JsonConvert.SerializeObject(utilityModel);
            data = "";
            issuccess = GetPostResponseNoRedirect("Image_M", "GetBusinessImage", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<ImageCommon_Model>> res = new ObjectResult<List<ImageCommon_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<ImageCommon_Model>>>(data);

                if (res.Code == "1")
                {
                    ViewBag.BigImageList = res.Data;
                }
            }

            return View();
        }

        public ActionResult UpdateCompany(Company_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "新增失败";

            bool issuccess = GetPostResponseNoRedirect("Company_M", "UpdateCompany", postJson, out data);
            
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
