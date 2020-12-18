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
    public class Promotion_CController : Base_CController
    {
        [HttpPost]
        [ActionName("GetPromotionList")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetPromotionList(JObject obj)
        {
            ObjectResult<List<TBL_PromotionList_Model>> res = new ObjectResult<List<TBL_PromotionList_Model>>();
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
            List<TBL_PromotionList_Model> list = new List<TBL_PromotionList_Model>();
            list = Promotion_CBLL.Instance.getPromotionList(operationModel.CompanyID, operationModel.ImageWidth, operationModel.ImageHeight,operationModel.Type);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }
    }
}
