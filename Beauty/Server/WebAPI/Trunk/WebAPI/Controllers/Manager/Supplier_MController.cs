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
    public class Supplier_MController : BaseController
    {
        [HttpPost]
        [ActionName("GetSupplierList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetSupplierList(JObject obj)
        {
            ObjectResult<List<SupplierList_Model>> res = new ObjectResult<List<SupplierList_Model>>();
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

            SupplierList_Model model = JsonConvert.DeserializeObject<SupplierList_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            List<SupplierList_Model> list = Supplier_BLL.Instance.GetSupplierList(model);
            if (list != null && list.Count > 0)
            {
                res.Code = "1";
                res.Message = "";
                res.Data = list;
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetSupplierDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetSubServiceDetail(JObject obj)
        {
            ObjectResult<SupplierList_Model> res = new ObjectResult<SupplierList_Model>();
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

            SupplierList_Model model = JsonConvert.DeserializeObject<SupplierList_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            SupplierList_Model detaillist = Supplier_BLL.Instance.GetSubServiceDetail(model);
            if (model != null)
            {
                res.Code = "1";
                res.Message = "";
                res.Data = detaillist;
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("AddSupplier")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage AddSupplier(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "新增失败";
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

            SupplierList_Model model = JsonConvert.DeserializeObject<SupplierList_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.CreatorID = this.UserID;
            bool rs = Supplier_BLL.Instance.AddSupplier(model);
            res.Code = "1";
            res.Message = "添加成功";
            res.Data = rs;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("UpdateSupplier")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage UpdateSupplier(JObject obj)
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

            SupplierList_Model model = JsonConvert.DeserializeObject<SupplierList_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.UpdaterID = this.UserID;
            bool rs = Supplier_BLL.Instance.UpdateSupplier(model);
            res.Code = "1";
            res.Message = "修改成功";
            res.Data = rs;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("DeleteSupplier")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage DeleteSupplier(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "删除失败";
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

            SupplierList_Model model = JsonConvert.DeserializeObject<SupplierList_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.UpdaterID = this.UserID;
            bool rs = Supplier_BLL.Instance.DeleteSupplier(model);
            res.Code = "1";
            res.Message = "删除成功";
            res.Data = rs;
            return toJson(res);
        }
        [HttpPost]
        [ActionName("IsExsitSupplierName")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage IsExsitSupplierName(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "该供应商已存在!";
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

            SupplierList_Model model = new SupplierList_Model();
            model = JsonConvert.DeserializeObject<SupplierList_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;

            bool result = Supplier_BLL.Instance.IsExsitSupplierName(model);


            res.Code = "1";
            res.Data = result;


            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetSupplierDetailInfo")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetSupplierDetailInfo(JObject obj)
        {
            ObjectResult<Supplier_Commodity_RELATION_Model> res = new ObjectResult<Supplier_Commodity_RELATION_Model>();
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

            Supplier_Commodity_RELATION_Model model = JsonConvert.DeserializeObject<Supplier_Commodity_RELATION_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            Supplier_Commodity_RELATION_Model supplierDetail = Supplier_BLL.Instance.GetSupplierDetail(model);
            if (model != null)
            {
                res.Code = "1";
                res.Message = "";
                res.Data = supplierDetail;
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetSupplierListForWeb")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getSupplierListForWeb(JObject obj)
        {
            ObjectResult<List<Supplier_Model>> res = new ObjectResult<List<Supplier_Model>>();
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            List<Supplier_Model> list = new List<Supplier_Model>();
            Supplier_Model model = new Supplier_Model();
            //model.BranchID = this.BranchID;
            model.CompanyID = this.CompanyID;
            list = Supplier_BLL.Instance.GetSupplierListForWeb(model);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }
    }
}
