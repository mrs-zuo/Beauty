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

namespace WebAPI.Controllers.API
{
    public class TagController : BaseController
    {
        [HttpPost]
        [ActionName("AddTag")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage AddTag(JObject obj)
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

            if (string.IsNullOrWhiteSpace(utilityModel.Name))
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
            utilityModel.CreateTime = DateTime.Now.ToLocalTime();
            utilityModel.CreatorID = this.UserID;

            int result = Tag_BLL.Instance.addTag(utilityModel);

            if (result == 1)
            {
                res.Code = "1";
                res.Message = "添加标签成功！";
            }
            else if (result == -1)
            {
                res.Message = "标签已存在！";
            }

            return toJson(res);
        }

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

            bool isShowHave = false;
            if (utilityModel.Type == 2)
            {
                isShowHave = true;
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;

            List<TagList_Model> list = new List<TagList_Model>();
            list = Tag_BLL.Instance.getTagList(utilityModel.CompanyID, utilityModel.Type,utilityModel.BranchID, isShowHave);
            

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }
    }
}
