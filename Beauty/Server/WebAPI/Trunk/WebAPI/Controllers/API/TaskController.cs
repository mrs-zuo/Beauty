using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.View_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Web.Http;
using WebAPI.Authorize;
using WebAPI.BLL;
using System.Linq;

namespace WebAPI.Controllers.API
{
    public class TaskController : BaseController
    {
        [HttpPost]
        [ActionName("GetScheduleList")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"BranchID":98,"Status": [1,2],"FilterByTimeFlag":1,"StartTime":"2015-8-08","EndTime":"2015-8-08","PageIndex":1,"PageSize":10,"ResponsiblePersonIDs":[],"CustomerID":0,"TaskScdlStartTime":"2015-08-08 0:00:00"}
        public HttpResponseMessage GetScheduleList(JObject obj)
        {
            ObjectResult<GetTaskListRes_Model> res = new ObjectResult<GetTaskListRes_Model>();
            res.Code = "0";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            GetTaskListOperation_Model operationModel = new GetTaskListOperation_Model();
            operationModel = JsonConvert.DeserializeObject<GetTaskListOperation_Model>(strSafeJson);

            if (operationModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.CompanyID = this.CompanyID;
            if (this.IsBusiness)
            {
                operationModel.BranchID = this.BranchID;
            }
            else
            {
                operationModel.CustomerID = this.UserID;
            }

            if (operationModel.FilterByTimeFlag == 1)
            {
                if ((String.IsNullOrWhiteSpace(operationModel.StartTime) || String.IsNullOrWhiteSpace(operationModel.EndTime)))
                {
                    res.Message = "请选择日期!";
                    return toJson(res);
                }
                else
                {
                    DateTime dtStartTime = new DateTime();
                    DateTime dtEndTiime = new DateTime();
                    if (DateTime.TryParse(operationModel.StartTime, out dtStartTime) && DateTime.TryParse(operationModel.EndTime, out dtEndTiime))
                    {
                        operationModel.StartTime = dtStartTime.ToShortDateString();
                        operationModel.EndTime = dtEndTiime.ToShortDateString();
                    }
                    else
                    {
                        res.Message = "请输入正确的时间格式!";
                        return toJson(res);
                    }
                }
            }

            if (operationModel.PageIndex <= 0)
            {
                operationModel.PageIndex = 1;
            }

            if (operationModel.PageSize <= 0)
            {
                operationModel.PageSize = 10;
            }

            GetTaskListRes_Model model = new GetTaskListRes_Model();
            List<GetTaskList_Model> list = new List<GetTaskList_Model>();
            int recordCount = 0;
            list = Task_BLL.Instance.GetScheduleList(operationModel, out recordCount);

            if (list == null)
            {
                model.RecordCount = 0;
                model.PageCount = 0;
                res.Data = model;
                res.Code = "1";
            }
            else
            {
                model.RecordCount = recordCount;
                model.PageCount = Pagination.GetPageCount(recordCount, operationModel.PageSize);
                model.TaskList = list;
                res.Data = model;
                res.Code = "1";
            }

            return toJson(res, "yyyy-MM-dd HH:mm:ss.ff");
        }

        [HttpPost]
        [ActionName("AddSchedule")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"ExecutorID":11857,"TaskType":1,"Remark":"","TaskScdlStartTime":"2015-08-08 08:00:00","ReservedOrderType":2,"ReservedServiceCode":1507080000000001,"TaskOwnerID":11736,"ReservedOrderID":0,"ReservedOrderServiceID":0}
        public HttpResponseMessage AddSchedule(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            AddTaskOperation_Model addModel = new AddTaskOperation_Model();
            addModel = JsonConvert.DeserializeObject<AddTaskOperation_Model>(strSafeJson);

            if (addModel == null || addModel.TaskScdlStartTime == null || addModel.TaskScdlStartTime < DateTime.Now)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            addModel.IsBusiness = this.IsBusiness;
            addModel.BranchID = this.BranchID;
            addModel.CompanyID = this.CompanyID;
            addModel.CreatorID = this.UserID;
            addModel.CreateTime = DateTime.Now.ToLocalTime();
            addModel.TaskScdlEndTime = addModel.TaskScdlStartTime.AddMinutes(15);
            addModel.TaskOwnerType = 1;
            addModel.TaskType = 1;
            addModel.TaskStatus = 1;
            if (!this.IsBusiness)
            {
                addModel.TaskOwnerID = this.UserID;
            }
            addModel.ReservationConfirmer = this.UserID;

            res.Code = Task_BLL.Instance.AddSchedule(addModel).ToString();

            switch (res.Code)
            {
                case "1":
                    res.Message = "服务预约成功!";
                    res.Data = true;
                    break;
                case "2":
                    res.Message = "不合法参数!";
                    break;
                case "3":
                    res.Message = "该服务不能预约!";
                    break;
                default:
                    res.Message = "服务预约失败!";
                    break;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetScheduleDetail")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"LongID":123456789564}
        public HttpResponseMessage GetScheduleDetail(JObject obj)
        {
            ObjectResult<GetScheduleDetail_Model> res = new ObjectResult<GetScheduleDetail_Model>();
            res.Code = "0";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (operationModel == null || operationModel.LongID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.CompanyID = this.CompanyID;

            GetScheduleDetail_Model model = new GetScheduleDetail_Model();
            model = Task_BLL.Instance.GetScheduleDetail(operationModel.CompanyID, operationModel.LongID);
            if (model != null && model.OrderID > 0)
            {
                DateTime dt = Convert.ToDateTime(model.OrderCreateTime);
                model.OrderNumber = dt.Month.ToString().PadLeft(2, '0') + dt.Day.ToString().PadLeft(2, '0') + model.OrderID.ToString().PadLeft(6, '0') + dt.Year.ToString().Substring(dt.Year.ToString().Length - 2, 2);
            }
            res.Data = model;
            res.Code = "1";
            return toJson(res);
        }

        [HttpPost]
        [ActionName("ConfirmSchedule")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage ConfirmSchedule(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            AddTaskOperation_Model addModel = new AddTaskOperation_Model();
            addModel = JsonConvert.DeserializeObject<AddTaskOperation_Model>(strSafeJson);

            if (addModel == null || addModel.TaskScdlStartTime == null || addModel.TaskOwnerID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (addModel.TaskScdlStartTime < DateTime.Now)
            {
                res.Message = "时间不正确!";
                return toJson(res);
            }

            addModel.IsBusiness = this.IsBusiness;
            addModel.BranchID = this.BranchID;
            addModel.CompanyID = this.CompanyID;
            addModel.CreatorID = this.UserID;
            addModel.CreateTime = DateTime.Now.ToLocalTime();
            addModel.TaskScdlEndTime = addModel.TaskScdlStartTime.AddMinutes(15);
            addModel.TaskOwnerType = 1;
            addModel.TaskType = 1;
            addModel.TaskStatus = 1;
            addModel.ReservationConfirmer = this.UserID;

            res.Code = Task_BLL.Instance.ConfirmSchedule(addModel).ToString();

            switch (res.Code)
            {
                case "1":
                    res.Message = "确认服务预约成功!";
                    res.Data = true;
                    break;
                case "2":
                    res.Message = "预约已确认或已经开始执行,不能确认!";
                    break;
                case "3":
                    res.Message = "该预约已经被取消!";
                    break;
                default:
                    res.Message = "确认预约失败!";
                    break;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("CancelSchedule")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"LongID":123123456456}
        public HttpResponseMessage CancelSchedule(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (operationModel == null || operationModel.LongID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.CompanyID = this.CompanyID;
            operationModel.UpdaterID = this.UserID;
            operationModel.Time = DateTime.Now.ToLocalTime();

            res.Code = Task_BLL.Instance.CancelSchedule(operationModel.CompanyID, operationModel.LongID, operationModel.UpdaterID, operationModel.Time).ToString();

            switch (res.Code)
            {
                case "1":
                    res.Message = "取消服务预约成功!";
                    res.Data = true;
                    break;
                default:
                    res.Message = "取消预约失败!";
                    break;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("EditVisitTask")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage EditVisitTask(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            AddTaskOperation_Model addModel = new AddTaskOperation_Model();
            addModel = JsonConvert.DeserializeObject<AddTaskOperation_Model>(strSafeJson);

            if (addModel == null || addModel.ExecuteStartTime == null || addModel.ExecuteStartTime > DateTime.Now || addModel.ID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            addModel.IsBusiness = this.IsBusiness;
            addModel.BranchID = this.BranchID;
            addModel.CompanyID = this.CompanyID;
            addModel.CreatorID = this.UserID;
            addModel.CreateTime = DateTime.Now.ToLocalTime();
            addModel.TaskOwnerType = 1;
            addModel.TaskType = 1;
            //addModel.TaskStatus = 1;
            addModel.ReservationConfirmer = this.UserID;

            res.Code = Task_BLL.Instance.EditVisitTask(addModel).ToString();

            switch (res.Code)
            {
                case "1":
                    if (addModel.TaskStatus == 3)
                    {
                        res.Message = "回访操作成功!";
                    }
                    else
                    {
                        res.Message = "该次回访暂存成功!";
                    }
                    res.Data = true;
                    break;
                case "2":
                    res.Message = "没有该回访任务";
                    break;
                case "3":
                    res.Message = "该回访任务已经被执行!";
                    break;
                case "4":
                    res.Message = "该回访任务已经被取消!";
                    break;
                default:
                    res.Message = "回访操作失败!";
                    break;
            }

            return toJson(res);
        }
    }
}