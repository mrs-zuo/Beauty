using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
using HS.Framework.Common.Util;
using Model.Table_Model;
using Model.Operation_Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebManager.Controllers.Base;
using WebManager.Models;

namespace WebManager.Controllers
{
    public class AppointmentController : BaseController
    {
        public ActionResult GetAppointmentList()
        {
            string srtCookie = CookieUtil.GetCookieValue("HSManger", true);
            Cookie_Model cookieModel = new Cookie_Model();
            if (!string.IsNullOrWhiteSpace(srtCookie))
            {
                cookieModel = JsonConvert.DeserializeObject<Cookie_Model>(srtCookie);
            }
            int branchID = this.BranchID;

            //总公司可以查看各分店的预约 分公司的只能查看自己分店下的预约
            bool isBranch = cookieModel.BR > 0;
            ViewBag.IsBranch = isBranch;
            ViewBag.BranchName = isBranch ? this.BranchName : "";
            ViewBag.BranchID = isBranch ? cookieModel.BR : branchID;

            return View();
        }

        public ActionResult GetBranchList()
        {
            UtilityOperation_Model model = new UtilityOperation_Model();

            string postJson = JsonConvert.SerializeObject(model);
            ObjectResult<List<Branch_Model>> res = new ObjectResult<List<Branch_Model>>();
            
            string data = string.Empty;
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("Branch_M", "getBranchAvailableList", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult GetAppointmentListForWeb(Appointment_Search_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<List<Appointment_Model>> res = new ObjectResult<List<Appointment_Model>>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("Appointment_M", "GetAppointmentList", postJson, out data);

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