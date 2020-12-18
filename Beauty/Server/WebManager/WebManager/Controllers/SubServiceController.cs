using HS.Framework.Common.Entity;
using Model.Table_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebManager.Controllers.Base;
namespace WebManager.Controllers
{
    public class SubServiceController : BaseController
    {
        //
        // GET: /SubService/

        public ActionResult GetSubServiceList()
        {
            ViewBag.isBranch = this.BranchID>0;
            string data=string.Empty;
            SubService_Model model=new SubService_Model();
            model.CompanyID=this.CompanyID;
            string postJson=JsonConvert.SerializeObject(model);
            bool issuccess = GetPostResponseNoRedirect("SubService_M", "GetSubServiceList", postJson, out data, false); 
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            ObjectResult<List<SubService_Model>> res = new ObjectResult<List<SubService_Model>>();
            res = JsonConvert.DeserializeObject<ObjectResult<List<SubService_Model>>>(data);
            if (res.Code.Equals("1"))
            {
                return View(res.Data);
            }
            return View();
        }

        public ActionResult EditSubService()
        {
            if (this.BranchID > 0)
            {
                return Redirect("/");
            }
            SubService_Model model = new SubService_Model();
            model.SubServiceCode = HS.Framework.Common.Safe.QueryString.LongSafeQ("SubServiceCode", -1);
            if (model.SubServiceCode > 0)
            {
                string postJson = JsonConvert.SerializeObject(model);
                string data = string.Empty;
                bool issuccess = GetPostResponseNoRedirect("SubService_M", "GetSubServiceDetail", postJson, out data, false);
                if (!issuccess)
                {
                    return RedirectUrl(data, "", false);
                }

                ObjectResult<SubService_Model> res = new ObjectResult<SubService_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<SubService_Model>>(data);
                if (res.Code.Equals("1"))
                {
                    return View(res.Data);
                }
            }
            return View();
        }

        public ActionResult AddSubService(SubService_Model model)
        {            
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "新增失败";
            if (this.BranchID > 0)
            {
                res.Message = "非总部无权限操作";
                return Json(res);
            }
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            bool issuccess = GetPostResponseNoRedirect("SubService_M", "AddSubService", postJson, out data);            
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult UpdateSubService(SubService_Model model)
        {           
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            if (this.BranchID > 0)
            {
                res.Message = "非总部无权限操作";
                return Json(res);
            }
            if (model.SubServiceCode > 0)
            {
                bool issuccess = GetPostResponseNoRedirect("SubService_M", "UpdateSubService", postJson, out data);
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

    }
}
