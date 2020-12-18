using HS.Framework.Common.Entity;
using Model.Table_Model;
using Model.View_Model;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using WebAPI.BLL;
using WebAPI.Controllers.API;

namespace WebAPI.Controllers.Manager
{
    public class Login_MController : BaseController
    {
        /// <summary>
        /// 欧小兵
        /// {"LoginMobile":"GQR8GveURTDRMaZj+4Yek5Ed6cAdJ3bvB5ec2qSOgd538nFTrXsg5ZMfjSgjFApxcH5d7MGtJQD/A1jgj4sUSgtVgH8JtwdvGXbL24sF1hg02f6N/2PYwytn2K5zIbNRXPfb739wDOKSXyJlkGvHD4sQmVSlcuovqHLTGFyJPck=","Password":"Kn3f9etQUgapCAPq6Al7Kx+ICvEzWnvRPlY9+JKnChPqFoJ96kGZ2XZdPwX78AO7c3nsEMZNf/uOTC38+c3mXS1VWQpVEk0hbzvbFwgSsCpHARExHAVlK8Xz0DhBOM9cDXAJMEayojYZnhow9LepUnRAYupVookBkqjgiwDGmTM=","ImageHeight":160,"ImageWidth":160}
        /// </summary>
        /// <param name="strJson"></param>
        [HttpPost]
        [ActionName("getCompanyList")]
        public HttpResponseMessage getCompanyList(JObject obj)
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "0";
            result.Message = "账户名密码错误！";
            result.Data = null;
            if (obj == null)
            {
                result.Message = "不合法参数！";
                return toJson(result);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                result.Message = "不合法参数！";
                return toJson(result);
            }

            Login_Model model = new Login_Model();

            model = Newtonsoft.Json.JsonConvert.DeserializeObject<Login_Model>(strSafeJson);
            model.RoleType = 1;
            model.ClientType = this.ClientType;
            model.DeviceType = this.DeviceType;
            model.AppVersion = this.APPVersion;
            model.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.LoginMobile);
            model.Password = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.Password);
            if (string.IsNullOrWhiteSpace(model.LoginMobile) || string.IsNullOrWhiteSpace(model.Password) ||  model.ClientType != 3 ||  model.DeviceType != 3)
            {
                result.Message = "不合法参数！";
                result.Data = null;
            }
            else
            {
                if (model.ImageHeight == 0 || model.ImageWidth == 0)
                {
                    model.ImageWidth = 160;
                    model.ImageHeight = 160;
                }

                ObjectResult<object> listCompanyListForAccount = Login_BLL.Instance.getCompanyListForAccount(model);
                switch (listCompanyListForAccount.Code)
                {
                    case "1":
                        result.Code = "1";
                        result.Message = "";
                        result.Data = listCompanyListForAccount.Data;
                        break;
                    case "-1":
                        result.Code = "0";
                        result.Message = "账户名密码错误！";
                        break;
                    case "-3":
                        result.Code = "-3";
                        result.Message = "";
                        result.Data = listCompanyListForAccount.Data;
                        break;
                    default:
                        break;
                }
            }
            return toJson(result);
        }

        /// <summary>
        /// 欧小兵
        /// CO: 7
        /// US: 26
        /// {"DeviceID":"ss15615565614561561561651","OSVersion":"ss23123124124124","LoginMobile":"GQR8GveURTDRMaZj+4Yek5Ed6cAdJ3bvB5ec2qSOgd538nFTrXsg5ZMfjSgjFApxcH5d7MGtJQD/A1jgj4sUSgtVgH8JtwdvGXbL24sF1hg02f6N/2PYwytn2K5zIbNRXPfb739wDOKSXyJlkGvHD4sQmVSlcuovqHLTGFyJPck=","Password":"Kn3f9etQUgapCAPq6Al7Kx+ICvEzWnvRPlY9+JKnChPqFoJ96kGZ2XZdPwX78AO7c3nsEMZNf/uOTC38+c3mXS1VWQpVEk0hbzvbFwgSsCpHARExHAVlK8Xz0DhBOM9cDXAJMEayojYZnhow9LepUnRAYupVookBkqjgiwDGmTM="}
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("updateLoginInfo")]
        public HttpResponseMessage updateLoginInfo(JObject obj)
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
            if (string.IsNullOrEmpty(strSafeJson))
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            Login_Model loginModel = new Login_Model();
            loginModel = Newtonsoft.Json.JsonConvert.DeserializeObject<Login_Model>(strSafeJson);
            loginModel.GUID = Guid.NewGuid().ToString();            
            loginModel.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(loginModel.LoginMobile);
            loginModel.Password = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(loginModel.Password);

            ObjectResult<RoleForLogin_Model> loginResult = new ObjectResult<RoleForLogin_Model>();
            loginResult = Login_BLL.Instance.updateLoginInfo(loginModel, 3);
            switch (loginResult.Code)
            {
                case "1":
                    result.Code = loginResult.Code;
                    result.Data = loginResult.Data;
                    break;
                case "-3":
                    result.Code = "-3";
                    //result.Message = loginResult.Data;
                    break;
                default:
                    break;
            }
            return toJson(result);
        }

    }
}
