using HS.Framework.Common;
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
using WebAPI.BLL;

namespace WebAPI.Controllers.API
{
    public class PromotionController : BaseController
    {
        #region 手机端WebApi方法

        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"BranchID": 0,"ImageHeight": 200,"ImageWidth": 290}</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetCompanyPromotionInfo_2_2_2")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetCompanyPromotionInfo_2_2_2(JObject obj)
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
            list = Promotion_BLL.Instance.getCompanyPromotionInfo(operationModel);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        #endregion
    }
}