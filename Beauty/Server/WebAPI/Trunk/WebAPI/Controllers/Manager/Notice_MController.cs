using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.Table_Model;
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
using WebAPI.Controllers.API;

namespace WebAPI.Controllers.Manager
{
    public class Notice_MController : BaseController
    {
        [HttpPost]
        [ActionName("GetNoticeList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetNoticeList(JObject obj)
        {
            PageResult<Notice_Model> res = new PageResult<Notice_Model>();
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
            utilityModel.CompanyID = this.CompanyID;

            if (utilityModel.PageIndex <= 0)
            {
                utilityModel.PageIndex = 1;
            }

            if (utilityModel.PageSize <= 0)
            {
                utilityModel.PageSize = 999999;
            }

            int recordCount = 0;
            List<Notice_Model> list = new List<Notice_Model>();
            list = Notice_BLL.Instance.getNoticeList(utilityModel.CompanyID, utilityModel.Flag, utilityModel.Type, utilityModel.PageIndex, utilityModel.PageSize, out  recordCount);

            res.Code = "1";
            res.Message = "";
            res.Data = list;
            res.RecordCount = recordCount;
            res.PageIndex = utilityModel.PageIndex;
            res.PageSize = utilityModel.PageSize;

            return toJson(res);
        }

        [HttpPost]
        [ActionName("DeleteNotice")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage DeleteNotice(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            utilityModel.CompanyID = this.CompanyID;
            bool issuccess = Notice_BLL.Instance.deleteNotice(utilityModel.CompanyID, utilityModel.ID);

            if (issuccess)
            {
                res.Code = "1";
                res.Message = "";
                res.Data = true;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("AddNotice")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage AddNotice(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
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

            Notice_Model operationModel = new Notice_Model();
            operationModel = JsonConvert.DeserializeObject<Notice_Model>(strSafeJson);

            if (operationModel == null || string.IsNullOrEmpty(operationModel.NoticeTitle))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.CompanyID = this.CompanyID;
            operationModel.BranchID = this.BranchID;
            operationModel.CreateTime = DateTime.Now.ToLocalTime();
            operationModel.CreatorID = this.UserID;
            bool issuccess = Notice_BLL.Instance.insertNotice(operationModel);

            if (issuccess)
            {
                res.Code = "1";
                res.Message = "";
                res.Data = true;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("UpdateNotice")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage UpdateNotice(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
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

            Notice_Model operationModel = new Notice_Model();
            operationModel = JsonConvert.DeserializeObject<Notice_Model>(strSafeJson);

            if (operationModel == null || string.IsNullOrEmpty(operationModel.NoticeTitle))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.CompanyID = this.CompanyID;
            operationModel.BranchID = this.BranchID;
            operationModel.UpdateTime = DateTime.Now.ToLocalTime();
            operationModel.UpdaterID = this.UserID;
            bool issuccess = Notice_BLL.Instance.updateNotice(operationModel);

            if (issuccess)
            {
                res.Code = "1";
                res.Message = "";
                res.Data = true;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetNoticeDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetNoticeDetail(JObject obj)
        {
            ObjectResult<Notice_Model> res = new ObjectResult<Notice_Model>();
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

            utilityModel.CompanyID = this.CompanyID;
            Notice_Model model = new Notice_Model();
            model = Notice_BLL.Instance.getNoticeDetail(utilityModel.CompanyID, utilityModel.ID);
            if (model == null)
            {
                model = new Notice_Model();
                model.StartDate = DateTime.Now.ToLocalTime();
                model.EndDate = DateTime.Now.ToLocalTime();
            }
            res.Code = "1";
            res.Message = "";
            res.Data = model;

            return toJson(res);
        }
    }
}
