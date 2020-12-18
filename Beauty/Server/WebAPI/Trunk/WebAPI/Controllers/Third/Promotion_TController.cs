using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using WebAPI.BLL;
using WebAPI.Controllers.API;

namespace WebAPI.Controllers.Third
{
    public class Promotion_TController : BaseController
    {
        [HttpPost]
        [ActionName("GetPromotionImgList")]
        //CompanyID=7&ImageWidth=160&ImageWidth=160&Type=0
        public HttpResponseMessage GetPromotionImgList(JObject obj)
        {
            ObjectResult<List<string>> res = new ObjectResult<List<string>>();
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

            if (operationModel.CompanyID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }

            List<string> list = Promotion_BLL.Instance.getPromotionImg(operationModel.CompanyID, operationModel.ImageWidth, operationModel.ImageHeight, 0);
            res.Code = "1";
            res.Data = list;
            return toJson(res);

        }
    }
}
