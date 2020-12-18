using ClientApi.Authorize;
using ClientAPI.BLL;
using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.Table_Model;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace ClientApi.Controllers.API
{
    public class WebUtilityController : BaseController
    {
        [HttpPost]
        [ActionName("GetQRCode")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage GetQRCode(JObject obj)
        {
            ObjectResult<string> res = new ObjectResult<string>();
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

            QRInfoOperation_Model qrModel = new QRInfoOperation_Model();

            qrModel = Newtonsoft.Json.JsonConvert.DeserializeObject<QRInfoOperation_Model>(strSafeJson);

            if (qrModel.Code == 0 || (qrModel.Type != 0 && qrModel.Type != 1 && qrModel.Type != 2))
            {
                res.Message = "输入格式不正确";
            }
            else
            {
                string separator = "^";
                string strTemp = "http://" + WebAPI.Common.Const.server + "/GetQRcode.aspx?size=" + qrModel.QRCodeSize + "&content=" + "http://" + WebAPI.Common.Const.server + "/a.aspx?id=" + qrModel.CompanyCode + separator + qrModel.Type.ToString().PadLeft(3, '0') + separator + qrModel.Code.ToString().PadLeft(10, '0');

                res.Code = "1";
                res.Data = strTemp;
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetAndroidURL")]
        public HttpResponseMessage GetAndroidURL()
        {
            ObjectResult<string> obj = new ObjectResult<string>();
            obj.Code = "1";
            obj.Data = System.Configuration.ConfigurationManager.AppSettings["AndroidCustomerURL"].ToString();
            return toJson(obj);
        }


        [HttpPost]
        [ActionName("CustomerLocation")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage CustomerLocation(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
            res.Data = true;

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

            CustomerLocation_Model model= new CustomerLocation_Model();

            model = Newtonsoft.Json.JsonConvert.DeserializeObject<CustomerLocation_Model>(strSafeJson);
            model.CustomerID = this.UserID;
            model.DeviceType = this.DeviceType;
            model.CompanyID = this.CompanyID;
            model.LocationTime = DateTime.Now.ToLocalTime();
            model.CreatorID = this.UserID;
            model.CreateTime = model.LocationTime;
            model.UpdaterID = this.UserID;
            model.UpdateTime = model.LocationTime;
            WebUtility_BLL.Instance.CustomerLocation(model);
            return toJson(res);
        } 
    }
}
