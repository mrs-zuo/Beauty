using HS.Framework.Common.Entity;
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

namespace WebTouch.Controllers
{
    public class AppointmentController : BaseController
    {
        //
        // GET: /Appointment/

        public ActionResult MyAppointment()
        {
            GetTaskListOperation_Model utilityModel = new GetTaskListOperation_Model();
            int status = HS.Framework.Common.Safe.QueryString.IntSafeQ("s");
            if (status == 0)
            {
                status = 1;
            }
            ViewBag.Status = status;
            utilityModel.FilterByTimeFlag = 0;
            utilityModel.Status = new List<int>();
            utilityModel.TaskType = 1;
            utilityModel.Status.Add(status);
            utilityModel.PageIndex = 1;
            utilityModel.PageSize = 10;
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            List<GetTaskList_Model> topList = null;
            bool issuccess = GetPostResponseNoRedirect("Task", "GetScheduleList", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            ObjectResult<GetTaskListRes_Model> res = new ObjectResult<GetTaskListRes_Model>();
            res = JsonConvert.DeserializeObject<ObjectResult<GetTaskListRes_Model>>(data);

            if (res.Code == "1")
            {
                topList = new List<GetTaskList_Model>();
                topList = res.Data.TaskList;

            }
            return View(topList);
        }

        public ActionResult AppointmentDetail()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.LongID = StringUtils.GetDbLong(HS.Framework.Common.Safe.QueryString.SafeQ("a"));
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            GetScheduleDetail_Model model = null;
            bool issuccess = GetPostResponseNoRedirect("Task", "GetScheduleDetail", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            ObjectResult<GetScheduleDetail_Model> res = new ObjectResult<GetScheduleDetail_Model>();
            res = JsonConvert.DeserializeObject<ObjectResult<GetScheduleDetail_Model>>(data);

            if (res.Code == "1")
            {
                model = new GetScheduleDetail_Model();
                model = res.Data;

                utilityModel = new UtilityOperation_Model();
                utilityModel.BranchID = res.Data.BranchID;
                data = "";
                postJson = JsonConvert.SerializeObject(utilityModel);

                issuccess = GetPostResponseNoRedirect("Account", "GetAccountListByBranchID", postJson, out data, false);

                if (!issuccess)
                {
                    return RedirectUrl(data, "", false);
                }
                ObjectResult<List<AccountList_Model>> resAcc = new ObjectResult<List<AccountList_Model>>();
                resAcc = JsonConvert.DeserializeObject<ObjectResult<List<AccountList_Model>>>(data);

                if (resAcc.Code == "1")
                {
                    ViewBag.AccountList = resAcc.Data;
                }
            }
            return View(model);
        }

        public ActionResult CreateAppointment()
        {
            string strOrderID = HS.Framework.Common.Safe.QueryString.SafeQ("oId");
            int TaskSourceType = HS.Framework.Common.Safe.QueryString.IntSafeQ("tk");
            ViewBag.TaskSourceType = TaskSourceType;
            bool issuccess;
            string data = "";
            string postJson = "";
            GetScheduleDetail_Model model = new GetScheduleDetail_Model();
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();

            if (strOrderID != null && strOrderID != "")
            {
                utilityModel.OrderID = StringUtils.GetDbInt(strOrderID);
                postJson = JsonConvert.SerializeObject(utilityModel);
                issuccess = GetPostResponseNoRedirect("Task", "GetOrderToAppointment", postJson, out data, false);
                if (!issuccess)
                {
                    return RedirectUrl(data, "", false);
                }
                ObjectResult<GetScheduleDetail_Model> res = new ObjectResult<GetScheduleDetail_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<GetScheduleDetail_Model>>(data);

                if (res.Code == "1")
                {
                    model = res.Data;
                }

            }
            else
            {
                utilityModel.BranchID = HS.Framework.Common.Safe.QueryString.IntSafeQ("bi");
                utilityModel.ProductCode = StringUtils.GetDbLong(HS.Framework.Common.Safe.QueryString.SafeQ("cd"));
                postJson = JsonConvert.SerializeObject(utilityModel);
                issuccess = GetPostResponseNoRedirect("Task", "GetTaskBasicInfo", postJson, out data, false);

                if (!issuccess)
                {
                    return RedirectUrl(data, "", false);
                }
                ObjectResult<GetScheduleDetail_Model> res = new ObjectResult<GetScheduleDetail_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<GetScheduleDetail_Model>>(data);

                if (res.Code == "1")
                {
                    model = res.Data;
                }

            }

            utilityModel = new UtilityOperation_Model();
            utilityModel.BranchID = model.BranchID;
            data = "";
            postJson = "";
            postJson = JsonConvert.SerializeObject(utilityModel);
            issuccess = GetPostResponseNoRedirect("Account", "GetAccountListByBranchID", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            else
            {
                ObjectResult<List<AccountList_Model>> res = new ObjectResult<List<AccountList_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<AccountList_Model>>>(data);

                if (res.Code == "1")
                {
                    ViewBag.AccountList = res.Data;
                }
            }

            return View(model);
        }

        public ActionResult AddSchedule(AddTaskOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Task", "AddSchedule", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }



        public ActionResult EditTask(AddTaskOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Task", "EditTask", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }


        public ActionResult CancelSchedule(UtilityOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Task", "CancelSchedule", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }



        public ActionResult SelectAppointmentBranch()
        {
            string data = "";
            List<GetBranchList_Model> list = null;
            bool issuccess = GetPostResponseNoRedirect("Customer", "GetCustomerBranch", null, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            ObjectResult<List<GetBranchList_Model>> res = new ObjectResult<List<GetBranchList_Model>>();
            res = JsonConvert.DeserializeObject<ObjectResult<List<GetBranchList_Model>>>(data);

            if (res.Code == "1")
            {
                list = new List<GetBranchList_Model>();
                list = res.Data;

            }


            if (list.Count == 1)
            {
                return Redirect("/Appointment/SelAPTitem1?b=" + list[0].BranchID);
            }
            else
            {
                return View(list);
            }
        }



        public ActionResult SelAPTitem1()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.BranchID = HS.Framework.Common.Safe.QueryString.IntSafeQ("b");
            utilityModel.ImageHeight = 100;
            utilityModel.ImageWidth = 100;
            ViewBag.BranchID = utilityModel.BranchID;
            ViewBag.BranchName = HS.Framework.Common.Safe.QueryString.SafeQ("bn");
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            List<ProductList_Model> list = null;
            bool issuccess = GetPostResponseNoRedirect("Service", "getRecommendedServiceListByBranchID", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            ObjectResult<List<ProductList_Model>> res = new ObjectResult<List<ProductList_Model>>();
            res = JsonConvert.DeserializeObject<ObjectResult<List<ProductList_Model>>>(data);

            if (res.Code == "1")
            {
                list = res.Data;
            }


            return View(list);
        }

        public ActionResult SelAPTitem2()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.ProductType = 0;
            utilityModel.BranchID = HS.Framework.Common.Safe.QueryString.IntSafeQ("b");
            ViewBag.BranchID = utilityModel.BranchID;
            ViewBag.BranchName = HS.Framework.Common.Safe.QueryString.SafeQ("bn");
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



        public ActionResult SelAPTitem3()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.BranchID = HS.Framework.Common.Safe.QueryString.IntSafeQ("b");
            utilityModel.CustomerID = this.UserID;
            utilityModel.ImageHeight = 100;
            utilityModel.ImageWidth = 100;
            ViewBag.BranchID = utilityModel.BranchID;
            ViewBag.BranchName = HS.Framework.Common.Safe.QueryString.SafeQ("bn");
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            List<ProductList_Model> list = null;
            bool issuccess = GetPostResponseNoRedirect("Service", "GetBoughtServiceList", postJson, out data, false);
            if (issuccess)
            {
                ObjectResult<List<ProductList_Model>> res = new ObjectResult<List<ProductList_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<ProductList_Model>>>(data);

                if (res.Code == "1")
                {
                    list = res.Data;
                }
            }

            return View(list);
        }



    }
}
