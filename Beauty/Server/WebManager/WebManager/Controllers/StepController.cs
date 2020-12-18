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
    public class StepController : BaseController
    {
        //
        // GET: /Step/

        public ActionResult GetStepList()
        {
            Step_Model model = new Step_Model();
            string data = string.Empty;
            bool issuccess = GetPostResponseNoRedirect("Step_M", "GetStepList", "", out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            ObjectResult<List<Step_Model>> res = new ObjectResult<List<Step_Model>>();
            res = JsonConvert.DeserializeObject<ObjectResult<List<Step_Model>>>(data);
            return View(res.Data);
        }
        
        public ActionResult EditStep()
        {
            Step_Model model = new Step_Model();
            model.ID = HS.Framework.Common.Safe.QueryString.IntSafeQ("ID", -1);
            if (model.ID > 0)
            {
                string postJson = JsonConvert.SerializeObject(model);
                string data = string.Empty;
                bool issuccess = GetPostResponseNoRedirect("Step_M", "GetStepByID", postJson, out data, false);
                if (!issuccess)
                {
                    return RedirectUrl(data, "", false);
                }
                ObjectResult<Step_Model> res = new ObjectResult<Step_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<Step_Model>>(data);
                return View(res.Data);
            }
            else {
                return View();
            }
        }

        public ActionResult AddStep(Step_Model model)
        {
            model.StepContent = model.StepContent.Replace("\n", "|").Replace("\r", "|").Replace("\r\n", "|");
            string[] tempContent = model.StepContent.Split(new string[] { "|" }, StringSplitOptions.RemoveEmptyEntries);
            model.StepContent = string.IsNullOrEmpty(model.StepContent) ? "" : string.Join("|", tempContent);
            model.StepNumber = tempContent.Length;
            string data = string.Empty;
            string postJson = JsonConvert.SerializeObject(model);
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message="操作失败";
            bool issuccess = GetPostResponseNoRedirect("Step_M", "AddStep", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
              return Json(res);   
            }            
        }

        public ActionResult UpdateStep(Step_Model model)
        {
            model.StepContent = model.StepContent.Replace("\n", "|").Replace("\r", "|").Replace("\r\n", "|");
            string[] tempContent = model.StepContent.Split(new string[] { "|" }, StringSplitOptions.RemoveEmptyEntries);
            model.StepContent = string.IsNullOrEmpty(model.StepContent) ? "" : string.Join("|", tempContent);
            model.StepNumber = tempContent.Length;
            string data = string.Empty;
            string postJson = JsonConvert.SerializeObject(model);
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "操作失败";
            bool issuccess = GetPostResponseNoRedirect("Step_M", "UpdateStep", postJson, out data);
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
