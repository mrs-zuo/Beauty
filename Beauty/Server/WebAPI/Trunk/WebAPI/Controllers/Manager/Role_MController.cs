using HS.Framework.Common.Entity;
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
using WebAPI.Controllers.API;

namespace WebAPI.Controllers.Manager
{
    public class Role_MController : BaseController
    {
        [HttpPost]
        [ActionName("GetRoleList")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetRoleList()
        {
            ObjectResult<List<Role_Model>> res = new ObjectResult<List<Role_Model>>();
            res.Code = "0";
            res.Data = null;

            List<Role_Model> list = new List<Role_Model>();
            list = RoleCheck_BLL.Instance.getRoleList(this.CompanyID);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetRoleDetail")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetRoleDetail(JObject obj)
        {
            ObjectResult<Role_Model> res = new ObjectResult<Role_Model>();
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            utilityModel.CompanyID = this.CompanyID;

            Role_Model model =  RoleCheck_BLL.Instance.getRoleDetail(utilityModel.CompanyID, utilityModel.ID) ??
                                new Role_Model();

            List<Jurisdiction_Model> list = new List<Jurisdiction_Model>();
            list = RoleCheck_BLL.Instance.getJurisdictionList(utilityModel.CompanyID, utilityModel.Advanced, utilityModel.ID);
            model.JurisdictionList = list;
            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("AddRole")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage AddRole(JObject obj)
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

            Role_Model Model = new Role_Model();
            Model = JsonConvert.DeserializeObject<Role_Model>(strSafeJson);
            Model.CompanyID = this.CompanyID;
            Model.OperatorID = this.UserID;
            Model.OperatorTime = DateTime.Now.ToLocalTime();

           
            bool isSuccess = RoleCheck_BLL.Instance.addRole(Model);

            res.Message = isSuccess ? "操作成功" : "操作失败";

            res.Code = "1";
            res.Data = isSuccess;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("EditRole")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage EditRole(JObject obj)
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

            Role_Model Model = new Role_Model();
            Model = JsonConvert.DeserializeObject<Role_Model>(strSafeJson);

            if (Model == null || Model.ID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            Model.CompanyID = this.CompanyID;
            Model.OperatorID = this.UserID;
            Model.OperatorTime = DateTime.Now.ToLocalTime();


            bool isSuccess = RoleCheck_BLL.Instance.updateRole(Model);

            res.Message = isSuccess ? "操作成功" : "操作失败";

            res.Code = "1";
            res.Data = isSuccess;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("DeleteRole")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage DeleteRole(JObject obj)
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
            if (operationModel == null || operationModel.ID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            bool isSuccess = RoleCheck_BLL.Instance.deleteRole(operationModel.ID, this.UserID);

            res.Message = isSuccess ? "操作成功" : "操作失败";

            res.Code = "1";
            res.Data = isSuccess;
            return toJson(res);
        }
    }
}
