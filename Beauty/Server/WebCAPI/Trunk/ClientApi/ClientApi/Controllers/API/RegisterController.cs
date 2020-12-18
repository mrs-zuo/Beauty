using ClientAPI.BLL;
using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.View_Model;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace ClientApi.Controllers.API
{
    public class RegisterController : BaseController
    {

        [HttpPost]
        [ActionName("getAuthenticationCode")]
        public HttpResponseMessage getAuthenticationCode(JObject obj)
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "1";
            result.Message = "发送成功！";
            result.Data = null;

            if (obj == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            UtilityOperation_Model model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            if (this.ClientType == 4)
            {
                model.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSADecryptForWeb(model.LoginMobile);
            }
            else
            {
                model.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.LoginMobile);
            }
            if (Customer_BLL.Instance.IsExistCustomer(model.LoginMobile, model.CompanyID))
            {
                result.Code = "0";
                result.Message = "用户已存在！";
                return toJson(result);
            }
            int sendRes = Login_BLL.Instance.getAuthenticationCode(model.LoginMobile, model.CompanyID,model.CreatorID);

            if (sendRes != 2)
            {
                result.Code = "0";
                result.Message = "验证码获取失败！";
                return toJson(result);
            }
            return toJson(result);
        }





        [HttpPost]
        [ActionName("checkAuthenticationCode")]
        public HttpResponseMessage checkAuthenticationCode(JObject obj)
        {
            ObjectResult<bool> result = new ObjectResult<bool>();
            result.Code = "0";
            result.Message = "注册失败！";
            result.Data = false;

            if (obj == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                result.Message = "不合法参数";
                return toJson(result);
            }
            RegisterOperation_Model model = Newtonsoft.Json.JsonConvert.DeserializeObject<RegisterOperation_Model>(strSafeJson);
            if (model == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            if (this.ClientType == 4)
            {
                model.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSADecryptForWeb(model.LoginMobile);
                model.AuthenticationCode = HS.Framework.Common.Safe.CryptRSA.RSADecryptForWeb(model.AuthenticationCode);
                model.Password = HS.Framework.Common.Safe.CryptRSA.RSADecryptForWeb(model.Password);
            }
            else
            {
                model.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.LoginMobile);
                model.AuthenticationCode = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.AuthenticationCode);
                model.Password = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.Password);
            }
            model.CreateTime = DateTime.Now.ToLocalTime();

            int res = Register_BLL.Instance.checkAuthenticationCode(model);
            if (res == 1)
            {
                result.Code = "1";
                result.Data = true;
                result.Message = "注册成功！";
            }
            else if(res == -1) {
                result.Message = "该手机已经存在！";
            }

            return toJson(result);
        }
    }
}