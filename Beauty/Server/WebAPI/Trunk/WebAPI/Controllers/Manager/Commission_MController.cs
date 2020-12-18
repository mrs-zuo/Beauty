
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
    public class Commission_MController : BaseController
    {

        [HttpPost]
        [ActionName("GetAccountList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetAccountList(JObject obj)
        {
            ObjectResult<List<Commission_Account_Model>> res = new ObjectResult<List<Commission_Account_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            List<Commission_Account_Model> list = new List<Commission_Account_Model>();
            list = Commission_BLL.Instance.GetAccountList(this.CompanyID,operationModel.InputSearch);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }



        [HttpPost]
        [ActionName("GetAccountDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetAccountDetail(JObject obj)
        {
            ObjectResult<Commission_Account_Model> res = new ObjectResult<Commission_Account_Model>();
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

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);


            if (operationModel.AccountID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            Commission_Account_Model model = new Commission_Account_Model();
            model = Commission_BLL.Instance.GetAccountDetail(this.CompanyID, operationModel.AccountID);

            res.Code = "1";
            res.Message = "";
            res.Data = model;

            return toJson(res);
        }


        [HttpPost]
        [ActionName("EditAccount")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage EditAccount(JObject obj)
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

            Commission_Account_Model model = new Commission_Account_Model();
            model = JsonConvert.DeserializeObject<Commission_Account_Model>(strSafeJson);


            if (model.AccountID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            model.CompanyID = this.CompanyID;
            model.CreatorID = this.UserID;
            bool result  = Commission_BLL.Instance.EditAccount(model);

            if (result) {
                res.Code = "1";
                res.Message = "修改成功!";
                res.Data = true;
            }

            return toJson(res);
        }



        [HttpPost]
        [ActionName("GetServiceList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetServiceList(JObject obj)
        {
            ObjectResult<List<Service_Model>> res = new ObjectResult<List<Service_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            List<Service_Model> list = new List<Service_Model>();
            list = Commission_BLL.Instance.getServiceList(this.CompanyID,operationModel.ImageWidth,operationModel.ImageHeight, operationModel.InputSearch);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetServiceDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetServiceDetail(JObject obj)
        {
            ObjectResult<Commission_Product_Model> res = new ObjectResult<Commission_Product_Model>();
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

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);


            if (operationModel.ServiceCode <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            Commission_Product_Model model = new Commission_Product_Model();
            model = Commission_BLL.Instance.GetServiceDetail(this.CompanyID, operationModel.ServiceCode);

            res.Code = "1";
            res.Message = "";
            res.Data = model;

            return toJson(res);
        }






        [HttpPost]
        [ActionName("GetCommodityList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCommodityList(JObject obj)
        {
            ObjectResult<List<Commodity_Model>> res = new ObjectResult<List<Commodity_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            List<Commodity_Model> list = new List<Commodity_Model>();
            list = Commission_BLL.Instance.getCommodityList(this.CompanyID, operationModel.ImageWidth, operationModel.ImageHeight, operationModel.InputSearch);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetCommodityDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCommodityDetail(JObject obj)
        {
            ObjectResult<Commission_Product_Model> res = new ObjectResult<Commission_Product_Model>();
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

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);


            if (operationModel.CommodityCode <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            Commission_Product_Model model = new Commission_Product_Model();
            model = Commission_BLL.Instance.GetCommodityDetail(this.CompanyID, operationModel.CommodityCode);

            res.Code = "1";
            res.Message = "";
            res.Data = model;

            return toJson(res);
        }





        [HttpPost]
        [ActionName("EditProduct")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage EditProduct(JObject obj)
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

            Commission_Product_Model operationModel = new Commission_Product_Model();
            operationModel = JsonConvert.DeserializeObject<Commission_Product_Model>(strSafeJson);


            if (operationModel.ProductCode <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            operationModel.CompanyID = this.CompanyID;
            operationModel.CreatorID = this.UserID;
            operationModel.CreateTime = DateTime.Now.ToLocalTime();
            Commission_Product_Model model = new Commission_Product_Model();
            bool result = Commission_BLL.Instance.EditProduct(operationModel);

            if (result)
            {
                res.Code = "1";
                res.Message = "修改成功";
                res.Data = true;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetCardList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCardList()
        {
            ObjectResult<List<Commission_Card_Model>> res = new ObjectResult<List<Commission_Card_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;


            List<Commission_Card_Model> list = new List<Commission_Card_Model>();
            list = Commission_BLL.Instance.GetCardList(this.CompanyID);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }





        [HttpPost]
        [ActionName("GetCardDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCardDetail(JObject obj)
        {
            ObjectResult<Commission_Card_Model> res = new ObjectResult<Commission_Card_Model>();
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

            Commission_Card_Model operationModel = new Commission_Card_Model();
            operationModel = JsonConvert.DeserializeObject<Commission_Card_Model>(strSafeJson);


            if (operationModel.CardCode <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            Commission_Card_Model model = new Commission_Card_Model();
            model = Commission_BLL.Instance.GetCardDetail(this.CompanyID, operationModel.CardCode);

            res.Code = "1";
            res.Message = "";
            res.Data = model;

            return toJson(res);
        }




        [HttpPost]
        [ActionName("EditCard")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage EditCard(JObject obj)
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

            Commission_Card_Model operationModel = new Commission_Card_Model();
            operationModel = JsonConvert.DeserializeObject<Commission_Card_Model>(strSafeJson);


            if (operationModel.CardCode <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.CompanyID = this.CompanyID;
            operationModel.CreatorID = this.UserID;
            operationModel.CreateTime = DateTime.Now.ToLocalTime();

            bool result = Commission_BLL.Instance.EditCard(operationModel);

            if (result)
            {
                res.Code = "1";
                res.Message = "修改成功";
                res.Data = true;
            }

            return toJson(res);
        }


    }
}
