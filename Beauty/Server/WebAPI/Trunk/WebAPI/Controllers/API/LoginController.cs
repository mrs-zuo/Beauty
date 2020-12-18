using HS.Framework.Common;
using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using WebAPI.Authorize;
using WebAPI.BLL;
using WebAPI.Common;

namespace WebAPI.Controllers.API
{
    public class LoginController : BaseController
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
            if (string.IsNullOrWhiteSpace(model.LoginMobile) || string.IsNullOrWhiteSpace(model.Password) || (model.ClientType != 1 && model.ClientType != 2 && model.ClientType != 3) || (model.DeviceType != 0 && model.DeviceType != 1 && model.DeviceType != 2))
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

                if (ClientType == 1)
                {
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
                            result.Data = listCompanyListForAccount.Data;
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
                else if (ClientType == 2)
                {
                    ObjectResult<object> listCompanyListForCustomer = Login_BLL.Instance.getCompanyListForCustomer(model);
                    switch (listCompanyListForCustomer.Code)
                    {
                        case "1":
                            result.Code = "1";
                            result.Message = "";
                            result.Data = listCompanyListForCustomer.Data;
                            break;
                        case "-1":
                            result.Code = "0";
                            result.Message = "账户名密码错误！";
                            result.Data = listCompanyListForCustomer.Data;
                            break;
                        case "-3":
                            result.Code = "-3";
                            result.Message = "";
                            result.Data = listCompanyListForCustomer.Data;
                            break;
                        default:
                            break;
                    }
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
            //loginModel.BranchID = this.BranchID;
            //loginModel.CompanyID = this.CompanyID;
            //loginModel.UserID = this.UserID;
            loginModel.GUID = Guid.NewGuid().ToString();
            //loginModel.AppVersion = this.APPVersion;
            //loginModel.ClientType = this.ClientType;
            //loginModel.DeviceType = this.DeviceType;
            loginModel.IPAddress = HS.Framework.Common.Util.Misc.FullIPAddress;
            loginModel.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(loginModel.LoginMobile);
            loginModel.Password = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(loginModel.Password);

            if (!loginModel.IsNormalLogin)
            {
                Login_BLL.Instance.logOut(this.GUID, this.CompanyID, this.BranchID, this.UserID);
            }

            ObjectResult<RoleForLogin_Model> loginResult = new ObjectResult<RoleForLogin_Model>();
            loginResult = Login_BLL.Instance.updateLoginInfo(loginModel, 1);
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

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [ActionName("Logout")]
        public HttpResponseMessage Logout()
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "1";
            result.Message = "登出成功！";
            result.Data = null;
            Login_BLL.Instance.logOut(this.GUID, this.CompanyID, this.BranchID, this.UserID);
            return toJson(result);
        }

        [HttpPost]
        [ActionName("updateUserPassword")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage updateUserPassword(JObject obj)
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "0";
            result.Message = "修改失败！";
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

            UpdateUserPassword_Model model = new UpdateUserPassword_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<UpdateUserPassword_Model>(strSafeJson);
            model.OldPassword = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.OldPassword);
            model.NewPassword = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.NewPassword);
            int blResult = Login_BLL.Instance.updateUserPassword(this.UserID, model.OldPassword, model.NewPassword);
            switch (blResult)
            {
                case 1:
                    result.Code = "1";
                    result.Message = "修改成功！";
                    break;
                case -1:
                    result.Code = "0";
                    result.Message = "旧密码输入有误！";
                    break;
                default:
                    break;
            }

            return toJson(result);
        }

        [HttpPost]
        [ActionName("updateCustomerPassword")]
        public HttpResponseMessage updateCustomerPassword(JObject obj)
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "0";
            result.Message = "修改失败！";
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

            Login_Model model = new Login_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<Login_Model>(strSafeJson);

            //检验CustomerID输入是否正确
            List<string> listCustomerIds = model.CustomerIDs.Split(',').Distinct().ToList();
            listCustomerIds.Remove("");
            List<int> listIntCustomerIds = new List<int>();

            //判断CustomerIDs中存在非数字
            for (int i = 0; i < listCustomerIds.Count; i++)
            {
                int customerID = 0;
                if (int.TryParse(listCustomerIds[i], out customerID))
                {
                    listIntCustomerIds.Add(customerID);
                }
                else
                {
                    result.Message = "不合法参数";
                    return toJson(result);
                }
            }

            model.CustomerIDList = listIntCustomerIds;
            model.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.LoginMobile);
            model.Password = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.Password);
            bool blResult = Login_BLL.Instance.updateUserPassword(model);
            if (blResult)
            {
                result.Code = "1";
                result.Message = "修改成功！";
            }

            return toJson(result);
        }

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
            model.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.LoginMobile);
            if (!Customer_BLL.Instance.IsExistCustomer(model.LoginMobile))
            {
                result.Code = "0";
                result.Message = "用户不存在！";
                return toJson(result);
            }
            Login_BLL.Instance.getAuthenticationCode(model.LoginMobile);
            return toJson(result);
        }

        [HttpPost]
        [ActionName("checkAuthenticationCode")]
        public HttpResponseMessage checkAuthenticationCode(JObject obj)
        {
            ObjectResult<List<CompanyListByLoginMobile_Model>> result = new ObjectResult<List<CompanyListByLoginMobile_Model>>();
            result.Code = "0";
            result.Message = "验证失败！";
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
            CheckAuthenticationCode_Model model = Newtonsoft.Json.JsonConvert.DeserializeObject<CheckAuthenticationCode_Model>(strSafeJson);
            if (model == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            model.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.LoginMobile);
            model.AuthenticationCode = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.AuthenticationCode);

            ObjectResult<List<CompanyListByLoginMobile_Model>> ObjResult = Login_BLL.Instance.checkAuthenticationCode(model.LoginMobile, model.AuthenticationCode);
            if (ObjResult.Code == "1")
            {
                result.Code = "1";
                result.Data = ObjResult.Data;
                result.Message = "验证成功！";
            }

            return toJson(result);
        }


        //暂时先不做，等需求确定后再做
        //[HttpPost]
        //[ActionName("LoginForWX")]
        //public HttpResponseMessage LoginForWX(JObject obj)
        //{
        //    ObjectResult<RoleForLogin_Model> rs = new ObjectResult<RoleForLogin_Model>();
        //    rs.Code = "0";
        //    if (obj is Nullable)
        //        return toJson(rs);
        //    string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
        //    if (string.IsNullOrEmpty(strSafeJson))
        //        return toJson(result);

        //    Login_Model loginModel = Newtonsoft.Json.JsonConvert.DeserializeObject<Login_Model>(strSafeJson);
        //    loginModel.WXOpenID = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(loginModel.WXOpenID);

        //}

    }
}
