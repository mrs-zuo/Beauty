using HS.Framework.Common;
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

namespace WebAPI.Controllers.API
{
    public class TemplateController : BaseController
    {
        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"Subject":"GO","TemplateContent":"GIG","TemplateType":0}</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("AddTemplate")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage AddTemplate(JObject obj)
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

            Template_Model operationModel = new Template_Model();
            operationModel = JsonConvert.DeserializeObject<Template_Model>(strSafeJson);

            if (operationModel.Subject == "" || operationModel.Subject == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.TemplateContent == "" || operationModel.TemplateContent == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }


            if (operationModel.TemplateType < 0 || operationModel.TemplateType > 1)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            operationModel.CompanyID = this.CompanyID;
            operationModel.BranchID = this.BranchID;
            operationModel.CreatorID = this.UserID;
            operationModel.OperateTime = DateTime.Now.ToLocalTime();

            bool result = Template_BLL.Instance.addTemplate(operationModel);
            if (result)
            {
                res.Data = true;
                res.Code = "1";
                res.Message = Resources.sysMsg.sucTemplateAdd;
            }
            else
            {
                res.Data = false;
                res.Code = "0";
                res.Message = Resources.sysMsg.errTemplateAdd;
            }


            return toJson(res);
        }


        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"Subject":"addGO","TemplateContent":"GddIG","TemplateType":1,"TemplateID":19}</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("UpdateTemplate")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage UpdateTemplate(JObject obj)
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

            Template_Model operationModel = new Template_Model();
            operationModel = JsonConvert.DeserializeObject<Template_Model>(strSafeJson);


            if (operationModel.TemplateID < 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.Subject == "" || operationModel.Subject == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.TemplateContent == "" || operationModel.TemplateContent == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }


            if (operationModel.TemplateType < 0 || operationModel.TemplateType > 1)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            operationModel.UpdaterID = this.UserID;
            operationModel.OperateTime = DateTime.Now.ToLocalTime();

            bool result = Template_BLL.Instance.updateTemplate(operationModel);
            if (result)
            {
                res.Data = true;
                res.Code = "1";
                res.Message = Resources.sysMsg.sucTemplateUpdate;
            }
            else
            {
                res.Data = false;
                res.Code = "0";
                res.Message = Resources.sysMsg.errTemplateUpdate;
            }


            return toJson(res);
        }


        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"TemplateID":19}</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("DeleteTemplate")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage DeleteTemplate(JObject obj)
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

            Template_Model operationModel = new Template_Model();
            operationModel = JsonConvert.DeserializeObject<Template_Model>(strSafeJson);


            if (operationModel.TemplateID < 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.UpdaterID = this.UserID;
            operationModel.OperateTime = DateTime.Now.ToLocalTime();

            bool result = Template_BLL.Instance.deleteTemplate(operationModel.TemplateID);
            if (result)
            {
                res.Data = true;
                res.Code = "1";
                res.Message = "模板已被删除，请刷新后查看";
            }
            else
            {
                res.Data = false;
                res.Code = "0";
                res.Message = "模板已被删除，请刷新后查看";
            }


            return toJson(res);

        }



        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetTemplateList")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetTemplateList()
        {
            ObjectResult<List<Template_Model>> res = new ObjectResult<List<Template_Model>>();
            res.Code = "0";
            res.Data = null;

            List<Template_Model> list = Template_BLL.Instance.getTemplatList(this.UserID, this.CompanyID);
            res.Code = "1";
            res.Data = list;

            return toJson(res);

        }
    }
}
