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
    public class Category_MController : BaseController
    {
        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [ActionName("getCategoryList")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage  getCategoryList(JObject obj)
        {
            ObjectResult<List<CategoryList_Model>> res = new ObjectResult<List<CategoryList_Model>>();
            res.Code = "0";
            res.Data = null;

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;
            operationModel.IsBusiness = this.IsBusiness;

            List <CategoryList_Model> list = Category_BLL.Instance.getCategoryListForWeb(this.CompanyID, operationModel.Type, operationModel.BranchID, operationModel.Flag, operationModel.SupplierID);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }


        [HttpPost]
        [ActionName("getCategoryIdByName")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getCategoryIdByName(JObject obj)
        {
            ObjectResult<int> res = new ObjectResult<int>();
            res.Code = "0";
            res.Message = "";
            res.Data = 0;

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

            int categoryID = Category_BLL.Instance.getCategoryIdByName(utilityModel.CompanyID, utilityModel.CategoryName, utilityModel.Type);

            if (categoryID > 0)
            {
                res.Code = "1";
                res.Message = "";
                res.Data = categoryID;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("deleteCategory")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage deleteCategory(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "操作失败";

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

            int result = Category_BLL.Instance.deleteCategory(this.UserID, operationModel.CategoryID, this.CompanyID, operationModel.Type);

            switch (result)
            {
                case 1:
                    res.Code = "1";
                    res.Data = true;
                    res.Message = "操作成功！";
                    break;
                case -1:
                    res.Message = "该分类下有商品！不能删除！";
                    break;
                case -2:
                    res.Message = "请先删除该层下级分类！";
                    break;
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("addCategory")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage addCategory(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "添加失败！";

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

            Category_Model model = new Category_Model();
            model = JsonConvert.DeserializeObject<Category_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.BranchID = this.BranchID;
            model.CreatorID = this.UserID;
            model.CreateTime = DateTime.Now.ToLocalTime();
            model.Available = true;


            bool result = Category_BLL.Instance.addCategory(model);

            res.Code = "1";
            res.Data = true;
            res.Message = "添加成功！";
            return toJson(res);
        }

        [HttpPost]
        [ActionName("updateCategory")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage updateCategory(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "操作失败！";

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

            Category_Model model = new Category_Model();
            model = JsonConvert.DeserializeObject<Category_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.BranchID = this.BranchID;
            model.UpdaterID = this.UserID;
            model.UpdateTime = DateTime.Now.ToLocalTime();



            bool result = Category_BLL.Instance.updateCategory(model);

            res.Code = "1";
            res.Data = true;
            res.Message = "操作成功！";
            return toJson(res);
        }

        [HttpPost]
        [ActionName("getCategoryDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getCategoryDetail(JObject obj)
        {
            ObjectResult<Category_Model> res = new ObjectResult<Category_Model>();
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

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);


            Category_Model model = Category_BLL.Instance.getCategoryDetail(operationModel.CategoryID);

            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("existCategoryId")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage existCategoryId(JObject obj)
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            utilityModel.CompanyID = this.CompanyID;

            bool existCategoryID = Category_BLL.Instance.existCategoryId(utilityModel.CompanyID, utilityModel.CategoryID, utilityModel.Type);

            if (existCategoryID)
            {
                res.Code = "1";
                res.Message = "";
                res.Data = existCategoryID;
            }

            return toJson(res);
        }


    }
}
