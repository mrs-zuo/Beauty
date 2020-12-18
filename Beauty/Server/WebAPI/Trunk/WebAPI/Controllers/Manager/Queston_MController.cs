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
    public class Queston_MController : BaseController
    {
        [HttpPost]
        [ActionName("GetQuestionList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetQuestionList(JObject obj)
        {
            ObjectResult<List<Question_Model>> res = new ObjectResult<List<Question_Model>>();
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
            
            Question_Model model = JsonConvert.DeserializeObject<Question_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            List<Question_Model> list = Queston_BLL.Instance.GetQuestionList(model.CompanyID, model.QuestionType);
            res.Code = "1";
            res.Message = "";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetQuestionDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetQuestionDetail(JObject obj)
        {
            ObjectResult<Question_Model> res = new ObjectResult<Question_Model>();
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

            Question_Model model = JsonConvert.DeserializeObject<Question_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            Question_Model rsModel = Queston_BLL.Instance.GetQuestionDetail(model.CompanyID, model.ID);
            if (rsModel != null)
            {
                rsModel.HaveAnswer = Queston_BLL.Instance.CheckQuestionHaveANSWER(model.CompanyID, model.ID);
            }
            res.Code = "1";
            res.Message = "";
            res.Data = rsModel;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("AddQuerstion")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage AddQuerstion(JObject obj)
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

            Question_Model model = JsonConvert.DeserializeObject<Question_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.CreatorID = this.UserID;
            bool rs = Queston_BLL.Instance.AddQuerstion(model);
            res.Code = "1";
            res.Message = "添加成功";
            res.Data = rs;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("UpdateQuestion")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage UpdateQuestion(JObject obj)
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

            Question_Model model = JsonConvert.DeserializeObject<Question_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.CreatorID = this.UserID;
            bool rs = Queston_BLL.Instance.UpdateQuestion(model);
            res.Code = "1";
            res.Message = "修改成功";
            res.Data = rs;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("DelQuestion")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage DelQuestion(JObject obj)
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

            Question_Model model = JsonConvert.DeserializeObject<Question_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.CreatorID = this.UserID;
            int rs = Queston_BLL.Instance.DelQuestion(model.CompanyID,model.ID);

            if (rs == 1)
            {
                res.Code = "1";
                res.Message = "删除成功";
                res.Data = true;
            }
            else if (rs == -2)
            {
                res.Message = "该问题正在被使用不能删除";
            }
            return toJson(res);
        }
       
    }
}
