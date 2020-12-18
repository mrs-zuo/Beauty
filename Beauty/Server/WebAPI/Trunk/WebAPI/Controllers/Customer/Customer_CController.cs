using HS.Framework.Common.Entity;
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
    public class Customer_CController : Base_CController
    {
        [HttpPost]
        [ActionName("GetCustomerBasic")]
        [HTTPBasicAuthorizeAttribute]
        // {"CustomerID":2569}
        public HttpResponseMessage GetCustomerBasic(JObject obj)
        {
            ObjectResult<CustomerBasic_Model> res = new ObjectResult<CustomerBasic_Model>();
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
            operationModel.CompanyID = this.CompanyID;
            operationModel.BranchID = this.BranchID;

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }

            CustomerBasic_Model model = Customer_CBLL.Instance.GetCustomerBasic(operationModel.CustomerID, operationModel.CompanyID, operationModel.BranchID, operationModel.ImageWidth, operationModel.ImageHeight);

            res.Code = "1";
            res.Data = model;
            return toJson(res);

        }

        [HttpPost]
        [ActionName("GetCustomerInfo")]
        [HTTPBasicAuthorizeAttribute]
        // {"CustomerID":2569}
        public HttpResponseMessage GetCustomerInfo(JObject obj)
        {
            ObjectResult<CustomerInfo_Model> res = new ObjectResult<CustomerInfo_Model>();
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
            operationModel.CompanyID = this.CompanyID;
            operationModel.BranchID = this.BranchID;

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }

            CustomerInfo_Model model = Customer_CBLL.Instance.GetCustomerInfo(operationModel.CustomerID, operationModel.CompanyID, operationModel.BranchID, operationModel.ImageWidth, operationModel.ImageHeight);

            res.Code = "1";
            res.Data = model;
            return toJson(res);

        }
    }
}
