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
    public class LevelController : BaseController
    {

        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"Flag": 0}</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetLevelList_2_2_2")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetLevelList_2_2_2(JObject obj)
        {
            ObjectResult<List<GetLevelList_Model>> res = new ObjectResult<List<GetLevelList_Model>>();
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

            LevelOperation_Model operationModel = new LevelOperation_Model();
            operationModel = JsonConvert.DeserializeObject<LevelOperation_Model>(strSafeJson);

            if (operationModel.Flag < 0 || operationModel.Flag > 1)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            List<GetLevelList_Model> list = new List<GetLevelList_Model>();
            list = Level_BLL.Instance.getLevelList(this.CompanyID, operationModel.Flag);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }


        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"CustomerID": 33,"LevelID":0} || {"CustomerID": 0,"LevelID":1}</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetDiscountListForWebService")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetDiscountListForWebService(JObject obj)
        {
            ObjectResult<List<GetDiscountList_Model>> res = new ObjectResult<List<GetDiscountList_Model>>();
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

            LevelOperation_Model operationModel = new LevelOperation_Model();
            operationModel = JsonConvert.DeserializeObject<LevelOperation_Model>(strSafeJson);

            if (operationModel.CustomerID < 0 || operationModel.LevelID < 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            else if (operationModel.LevelID > 0 && operationModel.CustomerID > 0) {
                res.Message = "不合法参数";
                return toJson(res);
            }
            else if (operationModel.LevelID == 0 && operationModel.CustomerID == 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            List<GetDiscountList_Model> list = new List<GetDiscountList_Model>();
            list = Level_BLL.Instance.getDiscountListForWebService(operationModel.LevelID, operationModel.CustomerID);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }



        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"CustomerID": 33,"LevelID":2} }</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("ChangeLevel")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage ChangeLevel(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
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

            LevelOperation_Model operationModel = new LevelOperation_Model();
            operationModel = JsonConvert.DeserializeObject<LevelOperation_Model>(strSafeJson);

            if (operationModel.CustomerID <= 0 )
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

           bool result = Level_BLL.Instance.changeLevel(operationModel.LevelID, operationModel.CustomerID);

           if (result)
           {
               res.Code = "1";
               res.Message = Resources.sysMsg.sucCustomerLevelUpdate; 
           }
           else {
               res.Code = "0";
               res.Message = Resources.sysMsg.errCustomerLevelUpdate;
           }
            res.Data = result;
            return toJson(res);
        }
    }
}
