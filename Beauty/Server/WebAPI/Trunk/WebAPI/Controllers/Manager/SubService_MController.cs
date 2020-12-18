using HS.Framework.Common.Entity;
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
    public class SubService_MController : BaseController
    {
        [HttpPost]
        [ActionName("GetSubServiceList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetSubServiceList()
        {
            ObjectResult<List<SubService_Model>> res = new ObjectResult<List<SubService_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;
            List<SubService_Model> list = SubService_BLL.Instance.GetSubServiceList(this.CompanyID);
            if (list != null && list.Count > 0)
            {
                res.Code = "1";
                res.Message = "";
                res.Data = list;
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetSubServiceDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetSubServiceDetail(JObject obj)
        {
            ObjectResult<SubService_Model> res = new ObjectResult<SubService_Model>();
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

            SubService_Model model = JsonConvert.DeserializeObject<SubService_Model>(strSafeJson);
            model = SubService_BLL.Instance.GetSubServiceDetail(this.CompanyID, model.SubServiceCode);
            if (model != null)
            {
                res.Code = "1";
                res.Message = "";
                res.Data = model;
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("AddSubService")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage AddSubService(JObject obj)
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

            SubService_Model model = JsonConvert.DeserializeObject<SubService_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.CreatorID = this.UserID;
            bool rs = SubService_BLL.Instance.AddSubService(model);
            res.Code = "1";
            res.Message = "添加成功";
            res.Data = rs;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("UpdateSubService")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage UpdateSubService(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "修改失败";
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

            SubService_Model model = JsonConvert.DeserializeObject<SubService_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.UpdaterID = this.UserID;
            bool rs = SubService_BLL.Instance.UpdateSubService(model);
            res.Code = "1";
            res.Message = "修改成功";
            res.Data = rs;
            return toJson(res);
        }
               
    }
}
