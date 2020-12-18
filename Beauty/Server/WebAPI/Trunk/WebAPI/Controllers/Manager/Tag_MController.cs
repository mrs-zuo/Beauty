using HS.Framework.Common;
using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
using Model.Operation_Model;
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
using WebAPI.Controllers.API;

namespace WebAPI.Controllers.Manager
{
    public class Tag_MController : BaseController
    {
        [HttpPost]
        [ActionName("GetTagList")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage GetTagList(JObject obj)
        {
            ObjectResult<List<TagList_Model>> res = new ObjectResult<List<TagList_Model>>();
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

            if (utilityModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (utilityModel.Type <= 0 || utilityModel.Type > 2)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;

            List<TagList_Model> list = new List<TagList_Model>();
            list = Tag_BLL.Instance.getTagList(utilityModel.CompanyID, utilityModel.Type, utilityModel.BranchID, false);


            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetTagDetail")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage GetTagDetail(JObject obj)
        {
            ObjectResult<TagDetailForWeb_Model> res = new ObjectResult<TagDetailForWeb_Model>();
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

            if (utilityModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (utilityModel.Type <= 0 || utilityModel.Type > 2)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.CompanyID = this.CompanyID;

            TagDetailForWeb_Model model = new TagDetailForWeb_Model();
            model = Tag_BLL.Instance.getTagDetailForWeb(utilityModel.CompanyID, utilityModel.ID, utilityModel.Type);

            if (model == null)
            {
                model = new TagDetailForWeb_Model();
            }

            List<GetAccountListByGroupFroWeb_Model> userList = new List<GetAccountListByGroupFroWeb_Model>();
            userList = Account_BLL.Instance.getAccountListUsedByGroupForWeb(utilityModel.CompanyID, utilityModel.ID);
            model.UserList = userList;
            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("AddTag")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage AddTag(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "操作失败";
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

            TagDetailForWeb_Model utilityModel = new TagDetailForWeb_Model();
            utilityModel = JsonConvert.DeserializeObject<TagDetailForWeb_Model>(strSafeJson);

            if (utilityModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (utilityModel.Type <= 0 || utilityModel.Type > 2)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CreatorID = this.UserID;
            utilityModel.CreateTime = DateTime.Now.ToLocalTime();


            int addRes = Tag_BLL.Instance.addTagForWeb(utilityModel);
            if (addRes == 1)
            {
                res.Code = "1";
                res.Data = true;
                res.Message = "操作成功";
            }
            else if (addRes == -1)
            {
                res.Code = "0";
                res.Data = false;
                res.Message = "已有相同名字的组!";
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("EditTag")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage EditTag(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "操作失败";
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

            TagDetailForWeb_Model utilityModel = new TagDetailForWeb_Model();
            utilityModel = JsonConvert.DeserializeObject<TagDetailForWeb_Model>(strSafeJson);

            if (utilityModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (utilityModel.Type <= 0 || utilityModel.Type > 2)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.BranchID = this.BranchID;
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CreatorID = this.UserID;
            utilityModel.CreateTime = DateTime.Now.ToLocalTime();


            int addRes = Tag_BLL.Instance.editTagForWeb(utilityModel);
            if (addRes == 1)
            {
                res.Code = "1";
                res.Data = true;
                res.Message = "操作成功";
            }
            else if (addRes == -1)
            {
                res.Code = "0";
                res.Data = false;
                res.Message = "已有相同名字的组!";
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("DeleteTag")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage DeleteTag(JObject obj)
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

            TagOperation_Model utilityModel = new TagOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<TagOperation_Model>(strSafeJson);

            if (utilityModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (utilityModel.Type <= 0 || utilityModel.Type > 2)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.CompanyID = this.CompanyID;

            bool isSuccess = Tag_BLL.Instance.deleteTag(utilityModel);

            if (isSuccess)
            {
                res.Code = "1";
                res.Message = "操作成功!";
            }
            else
            {
                res.Code = "0";
                res.Message = "操作失败!";
            }
            res.Data = isSuccess;
            return toJson(res);
        }
    }
}