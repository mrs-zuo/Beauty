using HS.Framework.Common;
using HS.Framework.Common.Caching;
using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.View_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using WebAPI.Authorize;
using WebAPI.BLL;
using WebAPI.Common;

namespace WebAPI.Controllers.API
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
                string strTemp = "http://" + Const.server + "/GetQRcode.aspx?size=" + qrModel.QRCodeSize + "&content=" + "http://" + Const.server + "/a.aspx?id=" + qrModel.CompanyCode + separator + qrModel.Type.ToString().PadLeft(3, '0') + separator + qrModel.Code.ToString().PadLeft(10, '0');

                res.Code = "1";
                res.Data = strTemp;
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("getInfoByQRcode")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getInfoByQRcode(JObject obj)
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "0";
            result.Message = "";
            result.Data = null;
            if (obj == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);

            QRInfo_Model qrModel = Newtonsoft.Json.JsonConvert.DeserializeObject<QRInfo_Model>(strSafeJson);
            string[] strQRCode = qrModel.QRCode.Split('^');
            if (strQRCode == null)
            {
                result.Message = "不合法参数";
                return toJson(result);

            }

            if (strQRCode.Length != 3)
            {
                result.Code = "0";
                result.Message = "格式不正确";
            }
            else
            {
                string companyCode = strQRCode[0];
                int type = Convert.ToInt32(strQRCode[1]);
                long code = Convert.ToInt64(strQRCode[2]);

                if (type != 0 && type != 1 && type != 2)
                {
                    result.Code = "0";
                    result.Message = "格式不正确";
                }
                else
                {
                    switch (type)
                    {
                        case 0:
                            ObjectResult<CustomerInfoByQRCode_Model> resultCustomer = new ObjectResult<CustomerInfoByQRCode_Model>();
                            resultCustomer = Customer_BLL.Instance.getCustomerInfoByQRCode(companyCode, this.BranchID, code, this.UserID);
                            if (resultCustomer.Code == "1")
                            {
                                result.Code = "1";
                                result.Data = resultCustomer.Data;
                            }
                            break;
                        case 1:
                            ObjectResult<ProductInFoByQRCode_Model> resultCommodity = new ObjectResult<ProductInFoByQRCode_Model>();
                            resultCommodity = Commodity_BLL.Instance.getCommodityInfoByQRCode(companyCode, this.BranchID, code, this.UserID);
                            if (resultCommodity.Code == "1")
                            {
                                result.Code = "1";
                                result.Data = resultCommodity.Data;
                            }
                            break;
                        case 2:
                            ObjectResult<ProductInFoByQRCode_Model> resultService = new ObjectResult<ProductInFoByQRCode_Model>();
                            resultService = Service_BLL.Instance.getServiceInfoByQRCode(companyCode, this.BranchID, code, this.UserID);
                            if (resultService.Code == "1")
                            {
                                result.Code = "1";
                                result.Data = resultService.Data;
                            }
                            break;
                        default:
                            result.Code = "0";
                            break;
                    }
                    if (result.Code == "0")
                    {
                        result.Message = "扫描失败";
                    }
                }
            }
            return toJson(result);
        }

        [HttpGet]
        [ActionName("GetWXToken")]
        public HttpResponseMessage GetWXToken(string key)
        {
            ObjectResult<string> obj = new ObjectResult<string>();
            obj.Code = "0";
            string rskey = string.Empty;
            try
            {
                rskey = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(key);
            }
            catch (Exception ex)
            {
                obj.Message = "你无权调用";
                return toJson(obj);
            }

            DateTime dt;
            if (!DateTime.TryParse(rskey, out dt))
            {
                obj.Message = "你无权调用";
                return toJson(obj);
            }
            else
            {
                long l1 = (dt.ToUniversalTime().Ticks - 621355968000000000) / 10000000;
                long l2 = (DateTime.Now.ToUniversalTime().Ticks - 621355968000000000) / 10000000;
                if (Math.Abs(l1 - l2) > 30)
                {
                    obj.Message = "你无权调用";
                    return toJson(obj);
                }
            }

            var token = MemcachedNew.Get("WX", "access_token");
            if (token != null)
            {
                obj.Code = "1";
                obj.Data = token.ToString();
                return toJson(obj);
            }
            else
            {
                string data = string.Empty;
                HttpStatusCode code = HS.Framework.Common.Net.NetUtil.GetResponse("https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=wx1aa3ce096117de41&secret=4102cb1d0d07f2f244d8a6246c678e2c", null, out data, null, "application/json", "get");
                if (HttpStatusCode.OK == code)
                {
                    if (data.Contains("errcode"))
                    {
                        return toJson(obj);
                    }
                    else
                    {
                        WXTokenRS rs = Newtonsoft.Json.JsonConvert.DeserializeObject<WXTokenRS>(data);
                        MemcachedNew.Set("WX", "access_token", rs.access_token, rs.expires_in - 120);
                        obj.Code = "1";
                        obj.Data = rs.access_token;
                        return toJson(obj);
                    }

                }
                else
                {
                    return toJson(obj);
                }
            }
        }

        [HttpPost]
        [ActionName("GetAndroidURL")]
        public HttpResponseMessage GetAndroidURL(JObject inobj)
        {
            ObjectResult<string> obj = new ObjectResult<string>();
            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(inobj);
            QRInfoClientOperation_Model operationModel = new QRInfoClientOperation_Model();
            operationModel = JsonConvert.DeserializeObject<QRInfoClientOperation_Model>(strSafeJson);
            if (operationModel.ClientID == "ADK")
            {
                obj.Data = System.Configuration.ConfigurationManager.AppSettings["ADKAndroidBusinessURL"].ToString();
            }
            else
            {
                obj.Data = System.Configuration.ConfigurationManager.AppSettings["AndroidBusinessURL"].ToString();
            }
            obj.Code = "1";
            return toJson(obj);
        }

        [Serializable]
        public class WXTokenRS
        {
            public string access_token { get; set; }
            public int expires_in { get; set; }
        }

        [HttpPost]
        [ActionName("Calculates")]
        public HttpResponseMessage Calculates(JObject obj)
        {
            ObjectResult<double> res = new ObjectResult<double>();
            res.Code = "0";
            res.Message = "";

            double EARTH_RADIUS = 6378.137; //地球半径

            double lng1 = 121.538596; //地点1 经度; 
            double lat1 = 31.328502; //地点1 纬度;

            double lng2 = 121.533494;//地点2 经度; 
            double lat2 = 31.234992;//地点2 纬度; 

            double radLat1 = rad(lat1);

            double radLat2 = rad(lat2);

            double a = radLat1 - radLat2;

            double b = rad(lng1) - rad(lng2);

            double s = 2 * Math.Asin(Math.Sqrt(Math.Pow(Math.Sin(a / 2), 2) +

             Math.Cos(radLat1) * Math.Cos(radLat2) * Math.Pow(Math.Sin(b / 2), 2)));

            s = s * EARTH_RADIUS;

            s = Math.Round(s * 10000) / 10000;
            res.Data = s;
            return toJson(res);
        }

        private static double rad(double d)
        {
            return d * Math.PI / 180.0;
        }
    }

}