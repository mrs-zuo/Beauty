using HS.Framework.Common;
using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using WebAPI.Authorize;
using WebAPI.BLL;

namespace WebAPI.Controllers.API
{
    public class NoticeController : BaseController
    {
        [HttpPost]
        [ActionName("GetRemindListByAccountID")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage GetRemindListByAccountID(JObject obj)
        {
            ObjectResult<GetRemindList_Model> res = new ObjectResult<GetRemindList_Model>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            //if (obj == null)
            //{
            //    res.Message = "不合法参数";
            //    return toJson(res);
            //}

            //string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            //if (string.IsNullOrEmpty(strSafeJson))
            //{
            //    res.Message = "不合法参数";
            //    return toJson(res);
            //}

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            //utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            //if (utilityModel == null || utilityModel.CustomerID <= 0)
            //{
            //    res.Message = "不合法参数";
            //    return toJson(res);
            //}
            utilityModel.AccountID = this.UserID;
            utilityModel.BranchID = this.BranchID;

            GetRemindList_Model model = new GetRemindList_Model();
            model.RemindList = Notice_BLL.Instance.getRemindListByAccountID(utilityModel.AccountID, utilityModel.BranchID);
            model.BirthdayList = Notice_BLL.Instance.getBirthdayListByAccountID(utilityModel.AccountID, utilityModel.BranchID);
            model.VisitList = Notice_BLL.Instance.getVisitListByAccountID(utilityModel.AccountID, utilityModel.BranchID);

            res.Code = "1";
            res.Message = "success";
            res.Data = model;

            return toJson(res,"yyyy-MM-dd HH:mm");
        }

        [HttpPost]
        [ActionName("GetRemindCountByAccountID")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage GetRemindCountByAccountID()
        {
            ObjectResult<int> res = new ObjectResult<int>();
            res.Code = "0";
            res.Message = "";
            res.Data = 0;

            res.Code = "1";
            res.Message = "success";
            res.Data = 0;
            return toJson(res);

            //UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            //utilityModel.AccountID = this.UserID;
            //utilityModel.BranchID = this.BranchID;


            //int RemindCount = Notice_BLL.Instance.getRemindCountByAccountID(utilityModel.AccountID, utilityModel.BranchID);
            //int BirthdayCount = Notice_BLL.Instance.getBirthdayCountByAccountID(utilityModel.AccountID, utilityModel.BranchID);
            //int VisitCount = Notice_BLL.Instance.getVisitCountByAccountID(utilityModel.AccountID, utilityModel.BranchID);

            //res.Code = "1";
            //res.Message = "success";
            //res.Data = RemindCount + BirthdayCount + VisitCount;

            //return toJson(res);
        }

        [HttpPost]
        [ActionName("getRemindListByCustomerID")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage getRemindListByCustomerID(JObject obj)
        {
            ObjectResult<List<GetRemindListByCustomerID_Model>> res = new ObjectResult<List<GetRemindListByCustomerID_Model>>();
            res.Code = "0";
            res.Message = "";
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.CustomerID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CustomerID = this.UserID;

            if (utilityModel.ImageHeight <= 0)
            {
                utilityModel.ImageHeight = 160;
            }

            if (utilityModel.ImageWidth <= 0)
            {
                utilityModel.ImageWidth = 160;
            }

            List<GetRemindListByCustomerID_Model> list = new List<GetRemindListByCustomerID_Model>();
            list = Notice_BLL.Instance.getRemindListByCustomerID(utilityModel.CustomerID, utilityModel.ImageWidth, utilityModel.ImageHeight);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }



        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetNoticeList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetNoticeList()
        {
            ObjectResult<List<Notice_Model>> res = new ObjectResult<List<Notice_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            List<Notice_Model> list = new List<Notice_Model>();
            int recordCount=0;
            list = Notice_BLL.Instance.getNoticeList(this.CompanyID, 1, 0, 1, 999999999, out recordCount);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res,"yyyy-MM-dd");
        }



        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetNoticeNumber")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetNoticeNumber()
        {
            ObjectResult<int> res = new ObjectResult<int>();
            res.Code = "0";
            res.Message = "";
            res.Data = -1;

            int cnt = Notice_BLL.Instance.getNoticeNumber(this.CompanyID);

            if (cnt > -1)
            {
                res.Code = "1";
                res.Data = cnt;
            }
            else
            {
                res.Code = "-1";
                res.Data = cnt;
            }

            return toJson(res);
        }
    }
}
