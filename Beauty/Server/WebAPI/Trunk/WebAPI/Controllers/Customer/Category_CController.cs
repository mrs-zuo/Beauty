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
using WebAPI.BLL.Customer;

namespace WebAPI.Controllers.Customer
{
    public class Category_CController : Base_CController
    {
        [HttpPost]
        [ActionName("getCategoryListByCompanyID")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getCategoryListByCompanyID(JObject obj)
        {
            ObjectResult<List<CategoryList_Model>> res = new ObjectResult<List<CategoryList_Model>>();
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
            operationModel.BranchID = this.BranchID;
            operationModel.IsBusiness = this.IsBusiness;

            List<CategoryList_Model> list = new List<CategoryList_Model>();
            list = Category_CBLL.Instance.getCategoryListByCompanyId(operationModel);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [ActionName("getCategoryListByCategoryID")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getCategoryListByCategoryID(JObject obj)
        {
            ObjectResult<List<CategoryList_Model>> res = new ObjectResult<List<CategoryList_Model>>();
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
            operationModel.BranchID = this.BranchID;
            operationModel.IsBusiness = this.IsBusiness;

            List<CategoryList_Model> list = Category_CBLL.Instance.getCategoryListByParentCategoryId(operationModel);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }
    }
}
