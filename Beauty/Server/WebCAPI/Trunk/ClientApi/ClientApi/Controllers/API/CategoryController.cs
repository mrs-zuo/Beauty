using ClientApi.Authorize;
using ClientAPI.BLL;
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

namespace ClientApi.Controllers.API
{
    public class CategoryController : BaseController
    {
        [HttpPost]
        [ActionName("GetCategoryList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCategoryList(JObject obj)
        {
            ObjectResult<CategoryInfo_Model> res = new ObjectResult<CategoryInfo_Model>();
            res.Code = "0";
            res.Data = null;

            UtilityOperation_Model operationModel = new UtilityOperation_Model();

            string strSafeJson = StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;

            CategoryInfo_Model model = new CategoryInfo_Model();
            model = Category_BLL.Instance.getCategoryList(operationModel);

            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }
    }
}
