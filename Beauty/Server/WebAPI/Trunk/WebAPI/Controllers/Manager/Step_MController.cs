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
    public class Step_MController : BaseController
    {
        [HttpPost]
        [ActionName("AddStep")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage AddStep(JObject obj)
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

            Step_Model model = JsonConvert.DeserializeObject<Step_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.CrteatorID = this.UserID;            
            res.Code = "1";
            res.Message = "操作成功";
            res.Data = Step_BLL.Instance.AddStep(model); ;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("UpdateStep")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage UpdateStep(JObject obj)
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

            Step_Model model = JsonConvert.DeserializeObject<Step_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.CrteatorID = this.UserID;
            res.Code = "1";
            res.Message = "操作成功";
            res.Data = Step_BLL.Instance.UpdateStep(model); ;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetStepList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetStepList()
        {
            ObjectResult<List<Step_Model>> res = new ObjectResult<List<Step_Model>>();
            res.Code = "1";
            res.Message = "";
            res.Data = Step_BLL.Instance.GetStepList(this.CompanyID);
            return toJson(res);

        }

        [HttpPost]
        [ActionName("GetStepByID")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetStepByID(JObject obj)
        {
            ObjectResult<Step_Model> res = new ObjectResult<Step_Model>();
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

            Step_Model model = JsonConvert.DeserializeObject<Step_Model>(strSafeJson);
            res.Code = "1";
            res.Message = "";
            res.Data = Step_BLL.Instance.GetStepByID(this.CompanyID, model.ID);
            return toJson(res);

        }
    }
}
