using ClientApi.Authorize;
using ClientAPI.BLL;
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

namespace ClientApi.Controllers.API
{
    public class PromotionController : BaseController
    {
        [HttpPost]
        [ActionName("GetPromotionList")]
        public HttpResponseMessage GetPromotionList(JObject obj)
        {
            ObjectResult<List<PromotionList_Model>> res = new ObjectResult<List<PromotionList_Model>>();
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

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 200;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 290;
            }

            operationModel.CustomerID = this.UserID;
            operationModel.CompanyID = this.CompanyID;
            List<PromotionList_Model> list = new List<PromotionList_Model>();
            list = Promotion_BLL.Instance.GetPromotionList(operationModel.CompanyID, operationModel.BranchID, operationModel.ImageWidth, operationModel.ImageHeight, operationModel.Type);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetPromotionDetail")]
        //{"Prama":"PRM15121700000001","ImageHeight":160,"ImageWidth":160}
        public HttpResponseMessage GetPromotionDetail(JObject obj)
        {
            ObjectResult<PromotionDetail_Model> res = new ObjectResult<PromotionDetail_Model>();
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

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 200;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 290;
            }

            operationModel.CustomerID = this.UserID;
            operationModel.CompanyID = this.CompanyID;
            PromotionDetail_Model model = new PromotionDetail_Model();
            model = Promotion_BLL.Instance.GetPromotionDetail(operationModel.CompanyID, operationModel.ImageWidth, operationModel.ImageHeight, operationModel.Prama);

            if (this.ClientType == 2) {
                model.Description = model.Description.Replace("</br>","\r\n");
            }

            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }
    }
}
