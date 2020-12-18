using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.Table_Model;
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
    public class CustomerSource_MController : BaseController
    {
        [HttpPost]
        [ActionName("GetCustomerSourceList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCustomerSourceList()
        {
            ObjectResult<List<CustomerSource_Model>> res = new ObjectResult<List<CustomerSource_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            List<CustomerSource_Model> list = new List<CustomerSource_Model>();
            list = CustomerSource_BLL.Instance.getCustomerSourceList(this.CompanyID);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }


        [HttpPost]
        [ActionName("DeleteCustomerSource")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage DeleteCustomerSource(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "删除失败";
            res.Data = false;

            if (obj == null)
            {
                res.Message = "不合法参数！";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数！";
                return toJson(res);
            }

            CustomerSource_Model model = Newtonsoft.Json.JsonConvert.DeserializeObject<CustomerSource_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.UpdaterID = this.UserID;
            model.UpdateTime = DateTime.Now.ToLocalTime();

            bool result = CustomerSource_BLL.Instance.deleteCustomerSource(model);

            if (result)
            {
                res.Code = "1";
                res.Message = "删除成功!";
                res.Data = true;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetCustomerSourceDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCustomerSourceDetail(JObject obj)
        {
            ObjectResult<CustomerSource_Model> res = new ObjectResult<CustomerSource_Model>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数！";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数！";
                return toJson(res);
            }

            UtilityOperation_Model utilityModel = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            CustomerSource_Model model = CustomerSource_BLL.Instance.getCustomerSourceDetail(this.CompanyID, utilityModel.ID);


            res.Code = "1";
            res.Data = model;


            return toJson(res);
        }

        [HttpPost]
        [ActionName("addCustomerSource")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage addCustomerSource(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "新增失败";
            res.Data = false;

            if (obj == null)
            {
                res.Message = "不合法参数！";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数！";
                return toJson(res);
            }

            CustomerSource_Model model = Newtonsoft.Json.JsonConvert.DeserializeObject<CustomerSource_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.CreatorID = this.UserID;
            model.CreateTime = DateTime.Now.ToLocalTime();

            bool result = CustomerSource_BLL.Instance.addCustomerSource(model);

            if (result)
            {
                res.Code = "1";
                res.Message = "新增成功!";
                res.Data = true;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("UpdateCustomerSource")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage UpdateCustomerSource(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "更新失败";
            res.Data = false;

            if (obj == null)
            {
                res.Message = "不合法参数！";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数！";
                return toJson(res);
            }

            CustomerSource_Model model = Newtonsoft.Json.JsonConvert.DeserializeObject<CustomerSource_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.UpdaterID = this.UserID;
            model.UpdateTime = DateTime.Now.ToLocalTime();

            bool result = CustomerSource_BLL.Instance.updateCustomerSource(model);

            if (result)
            {
                res.Code = "1";
                res.Message = "更新成功!";
                res.Data = true;
            }

            return toJson(res);
        }

    }
}
