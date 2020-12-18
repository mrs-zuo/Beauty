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
    public class Image_MController : BaseController
    {
        [HttpPost]
        [ActionName("GetBusinessImage")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetBusinessImage(JObject obj)
        {
            ObjectResult<List<ImageCommon_Model>> res = new ObjectResult<List<ImageCommon_Model>>();
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (utilityModel.ID < 0) {
                res.Message = "不合法参数！";
                return toJson(res);
            }

            List<ImageCommon_Model> list = new List<ImageCommon_Model>();
            list = Image_BLL.Instance.getBusinessImageForWeb(this.CompanyID, utilityModel.BranchID);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }


        [HttpPost]
        [ActionName("UpdateBusinessImage")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage UpdateBusinessImage(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (utilityModel.ID < 0)
            {
                res.Message = "不合法参数！";
                return toJson(res);
            }

            List<ImageCommon_Model> list = new List<ImageCommon_Model>();
            list = Image_BLL.Instance.getBusinessImageForWeb(this.CompanyID, utilityModel.BranchID);

            res.Code = "1";
            res.Message = "";
            res.Data = false;

            return toJson(res);
        }
    }
}
