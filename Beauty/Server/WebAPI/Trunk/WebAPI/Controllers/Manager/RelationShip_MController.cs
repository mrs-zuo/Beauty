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
    public class RelationShip_MController : BaseController
    {

        [HttpPost]
        [ActionName("GetCustomerList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCustomerList(JObject obj)
        {
            ObjectResult<List<Customer_Model>> res = new ObjectResult<List<Customer_Model>>();
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

            List<Customer_Model> list = new List<Customer_Model>();
            list = RelationShip_BLL.Instance.GetCustomerList(this.BranchID,this.CompanyID);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetCustomerListByAccountName")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCustomerListByAccountName(JObject obj)
        {
            ObjectResult<List<Customer_Model>> res = new ObjectResult<List<Customer_Model>>();
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

            List<Customer_Model> list = new List<Customer_Model>();
            if (utilityModel.InputSearch == null || utilityModel.InputSearch == "")
            {
                list = RelationShip_BLL.Instance.GetCustomerList(this.BranchID, this.CompanyID);
            }
            else
            {
                list = RelationShip_BLL.Instance.GetCustomerListByAccountName(utilityModel.BranchID, utilityModel.InputSearch, utilityModel.Type);
            }

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }




        [HttpPost]
        [ActionName("GetAccountList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetAccountList(JObject obj)
        {
            ObjectResult<List<RelationShip_Model>> res = new ObjectResult<List<RelationShip_Model>>();
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

            List<RelationShip_Model> list = new List<RelationShip_Model>();
            list = RelationShip_BLL.Instance.GetAccountList(utilityModel.BranchID);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetRelationShipList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetRelationShipList(JObject obj)
        {
            ObjectResult<List<RelationShip_Model>> res = new ObjectResult<List<RelationShip_Model>>();
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

            List<RelationShip_Model> list = new List<RelationShip_Model>();
            list = RelationShip_BLL.Instance.GetRelationShipList(utilityModel.CustomerID, utilityModel.BranchID,utilityModel.Type);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }


        [HttpPost]
        [ActionName("ChangeRelationShip")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage ChangeRelationShip(JObject obj)
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

            RelationShip_Model model = new RelationShip_Model();
            model = JsonConvert.DeserializeObject<RelationShip_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.CreatorID = this.UserID;
            model.UpdaterID = this.UserID;
            model.CreateTime = DateTime.Now.ToLocalTime();
            model.UpdateTime = model.CreateTime;

            bool result = RelationShip_BLL.Instance.changeRelationShip(model);

            if (result)
            {
                res.Code = "1";
                res.Message = "更新成功!";
                res.Data = true;
            }
            else {
                res.Code = "0";
                res.Message = "更新失败!";
                res.Data = false;
            }

            return toJson(res);
        }
    }
}
