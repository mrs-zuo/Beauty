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
    public class Statement_MController : BaseController
    {
        [HttpPost]
        [ActionName("GetStatementCategoryList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetStatementCategoryList()
        {
            ObjectResult<List<StatementCategory_Model>> res = new ObjectResult<List<StatementCategory_Model>>();
            res.Code = "0";
            res.Data = null;

            List<StatementCategory_Model> list = new List<StatementCategory_Model>();
            list = Statement_BLL.Instance.getStatementCategoryList(this.CompanyID);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetStatementCategoryDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetStatementCategoryDetail(JObject obj)
        {
            ObjectResult<StatementCategory_Model> res = new ObjectResult<StatementCategory_Model>();
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

            if (operationModel.CategoryID <= 0) {
                res.Message = "不合法参数";
                return toJson(res);
            }
            operationModel.CompanyID = this.CompanyID;


            StatementCategory_Model model = new StatementCategory_Model();
            model = Statement_BLL.Instance.getStatementCategoryDetail(this.CompanyID, operationModel.CategoryID);

            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }



        [HttpPost]
        [ActionName("GetProductList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetProductList(JObject obj)
        {
            ObjectResult<List<GetProductList_Model>> res = new ObjectResult<List<GetProductList_Model>>();
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

            List<GetProductList_Model> list = new List<GetProductList_Model>();
            list = Statement_BLL.Instance.getProductList(operationModel.ProductType,operationModel.CategoryID,this.CompanyID);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("EditStatement")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage EditStatement(JObject obj)
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

            StatementCategory_Model operationModel = new StatementCategory_Model();
            operationModel = JsonConvert.DeserializeObject<StatementCategory_Model>(strSafeJson);

            if (operationModel.ListStatement == null || operationModel.ListStatement.Count == 0 || operationModel.CategoryName == "") {
                res.Message = "不合法参数";
                return toJson(res);
            }
            operationModel.CompanyID = this.CompanyID;
            operationModel.CreatorID = this.UserID;
            operationModel.CreateTime = DateTime.Now.ToLocalTime();
            operationModel.UpdaterID = this.UserID;
            operationModel.UpdateTime = operationModel.CreateTime;

            bool result = Statement_BLL.Instance.EditStatement(operationModel);

            if (result)
            {
                res.Code = "1";
                res.Data = true;
                res.Message = "操作成功";
            }
            return toJson(res);
        }


        [HttpPost]
        [ActionName("DeleteStatement")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage DeleteStatement(JObject obj)
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

            StatementCategory_Model operationModel = new StatementCategory_Model();
            operationModel = JsonConvert.DeserializeObject<StatementCategory_Model>(strSafeJson);

            if (operationModel.ID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            bool result = Statement_BLL.Instance.DeleteStatement(operationModel.ID,this.CompanyID);

            if (result)
            {
                res.Code = "1";
                res.Data = true;
                res.Message = "操作成功";
            }
            return toJson(res);
        }

    }
}
