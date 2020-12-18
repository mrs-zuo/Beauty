using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.Table_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using WebAPI.Authorize;
using WebAPI.BLL;
using WebAPI.Controllers.API;

namespace WebAPI.Controllers.Manager
{
    public class CommoditySupplier_MController : BaseController
    {
        [HttpPost]
        [ActionName("GetCommodityList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCommodityList(JObject obj)//
        {
            ObjectResult<List<Commodity_Model>> res = new ObjectResult<List<Commodity_Model>>();
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

            List<Commodity_Model> list = new List<Commodity_Model>();
            Commodity_Model model = new Commodity_Model();
            //model.BranchID = this.BranchID;
            model.CompanyID = this.CompanyID;
            list = CommoditySupplier_BLL.Instance.GetCommodityList(model);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetSupplierList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetSupplierList(JObject obj)
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
            list = CommoditySupplier_BLL.Instance.GetSupplierList(model);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetCommoditySupplierList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCommoditySupplierList(JObject obj)
        {
            ObjectResult<List<SupplierCommodity_Model>> res = new ObjectResult<List<SupplierCommodity_Model>>();
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

            List<SupplierCommodity_Model> list = new List<SupplierCommodity_Model>();
            SupplierCommodity_Model model = new SupplierCommodity_Model();
            //model.BranchID = this.BranchID;
            model.CompanyID = this.CompanyID;
            model.CommodityID = utilityModel.CommodityID;
            list = CommoditySupplier_BLL.Instance.GetCommoditySupplierList(model);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }

        [HttpPost]
        [ActionName("ChangeCommoditySupplier")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage ChangeCommoditySupplier(JObject obj)
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

            SupplierCommodity_Model model = new SupplierCommodity_Model();
            model = JsonConvert.DeserializeObject<SupplierCommodity_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.CreatorID = this.UserID;
            model.UpdaterID = this.UserID;
            model.CreateTime = DateTime.Now.ToLocalTime();
            model.UpdateTime = model.CreateTime;

            bool result = CommoditySupplier_BLL.Instance.ChangeCommoditySupplier(model);

            if (result)
            {
                res.Code = "1";
                res.Message = "更新成功!";
                res.Data = true;
            }
            else
            {
                res.Code = "0";
                res.Message = "更新失败!";
                res.Data = false;
            }

            return toJson(res);
        }
    }
}