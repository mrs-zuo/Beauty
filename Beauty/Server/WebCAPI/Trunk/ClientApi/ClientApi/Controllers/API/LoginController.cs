using ClientApi.Authorize;
using ClientAPI.BLL;
using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.Table_Model;
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
    public class LoginController : BaseController
    {
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
            if (this.ClientType == 2)
            {
                loginModel.IPAddress = HS.Framework.Common.Util.Misc.FullIPAddress;
            }

            if (this.ClientType == 4)
            {

                loginModel.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSADecryptForWeb(loginModel.LoginMobile);
                loginModel.Password = HS.Framework.Common.Safe.CryptRSA.RSADecryptForWeb(loginModel.Password);
            }
            else
            {
                loginModel.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(loginModel.LoginMobile);
                loginModel.Password = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(loginModel.Password);
            }

            //if (!loginModel.IsNormalLogin)
            //{
            //    Login_BLL.Instance.logOut(this.GUID, this.CompanyID, this.BranchID, this.UserID);
            //}

            ObjectResult<RoleForLogin_Model> loginResult = new ObjectResult<RoleForLogin_Model>();
            loginResult = Login_BLL.Instance.updateLoginInfo(loginModel, this.ClientType);
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

        [HttpPost]
        [ActionName("Logout")]
        public HttpResponseMessage Logout()
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "1";
            result.Message = "登出成功！";
            result.Data = null;
            Login_BLL.Instance.logOut(this.GUID, this.CompanyID, this.BranchID, this.UserID, this.ClientType);
            return toJson(result);
        }

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

            if (this.ClientType == 4)
            {
                model.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSADecryptForWeb(model.LoginMobile);
                model.Password = HS.Framework.Common.Safe.CryptRSA.RSADecryptForWeb(model.Password);
            }
            else
            {
                model.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.LoginMobile);
                model.Password = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.Password);
            }
            if (string.IsNullOrWhiteSpace(model.LoginMobile) || string.IsNullOrWhiteSpace(model.Password))
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
            return toJson(result);
        }

        [HttpPost]
        [ActionName("updateLoginInfoForWeChat")]
        public HttpResponseMessage updateLoginInfoForWeChat(JObject obj)
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
            if (this.ClientType == 2)
            {
                loginModel.IPAddress = HS.Framework.Common.Util.Misc.FullIPAddress;
            }

            ObjectResult<RoleForLogin_Model> loginResult = new ObjectResult<RoleForLogin_Model>();
            loginResult = Login_BLL.Instance.updateLoginInfoForWeChat(loginModel);
            switch (loginResult.Code)
            {
                case "1":
                    result.Code = loginResult.Code;
                    result.Data = loginResult.Data;
                    break;
                case "-3":
                    result.Code = "-3";
                    break;
                default:
                    break;
            }
            return toJson(result);
        }

        [HttpPost]
        [ActionName("getUserByWeChatOpenID")]
        public HttpResponseMessage getUserByWeChatOpenID(JObject obj)
        {
            ObjectResult<Login_Model> result = new ObjectResult<Login_Model>();
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

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;

            Login_Model model = Login_BLL.Instance.getUserByWeChatOpenID(operationModel.CompanyID, operationModel.Prama);
            if (model != null)
            {
                result.Code = "1";
                result.Data = model;
            }

            return toJson(result);
        }

        [HttpPost]
        [ActionName("BindWeChatOpenID")]
        public HttpResponseMessage BindWeChatOpenID(JObject obj)
        {
            ObjectResult<CompanyListForCustomerLogin_Model> result = new ObjectResult<CompanyListForCustomerLogin_Model>();
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

            int sex = -1;
            string headimgurl = "";
            string fileName = "";
            DateTime dt = DateTime.Now.ToLocalTime();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<Login_Model>(strSafeJson);
            model.RoleType = 1;
            model.ClientType = this.ClientType;
            model.DeviceType = this.DeviceType;
            model.AppVersion = this.APPVersion;

            if (this.ClientType == 4)
            {
                model.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSADecryptForWeb(model.LoginMobile);
                model.Password = HS.Framework.Common.Safe.CryptRSA.RSADecryptForWeb(model.Password);
            }
            else
            {
                model.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.LoginMobile);
                model.Password = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.Password);
            }
            if (string.IsNullOrWhiteSpace(model.LoginMobile) || string.IsNullOrWhiteSpace(model.Password))
            {
                result.Message = "不合法参数！";
                result.Data = null;
            }

            if (model.ImageHeight == 0 || model.ImageWidth == 0)
            {
                model.ImageWidth = 160;
                model.ImageHeight = 160;
            }

            if (!string.IsNullOrWhiteSpace(model.WeChatUserInfoPrama) && !model.WeChatUserInfoPrama.Contains("errcode"))
            {
                var WeChatObj = Newtonsoft.Json.Linq.JObject.Parse(model.WeChatUserInfoPrama);
                if (WeChatObj["headimgurl"] != null && !string.IsNullOrWhiteSpace(HS.Framework.Common.Util.StringUtils.GetDbString(WeChatObj["headimgurl"])))
                {
                    headimgurl = HS.Framework.Common.Util.StringUtils.GetDbString(WeChatObj["headimgurl"]);

                    Random random = new Random();
                    string randomNumber = "";

                    for (int i = 0; i < 5; i++)
                    {
                        randomNumber += random.Next(10).ToString();
                    }
                    fileName = string.Format("{0:yyyyMMddHHmmssffff}", dt) + randomNumber + ".jpg";
                }

                sex = HS.Framework.Common.Util.StringUtils.GetDbInt(WeChatObj["sex"]);
            }

            result = Login_BLL.Instance.bindWeChatOpenID(model, fileName, sex);


            if (result != null && result.Data != null)
            {
                CompanyListForCustomerLogin_Model companymodel = result.Data;

                //System.Threading.Tasks.Task.Factory.StartNew(() =>
                //{
                string server = System.Configuration.ConfigurationSettings.AppSettings["ImageServer"];
                string serverFolder = System.Configuration.ConfigurationSettings.AppSettings["ImageFolder"];
                string newHeadimgurl= "";
                if (!string.IsNullOrWhiteSpace(headimgurl))
                {
                    newHeadimgurl = headimgurl.Substring(0, headimgurl.LastIndexOf('/') + 1) + "96"; string folder = server + serverFolder + companymodel.CompanyID + "\\Customer\\" + companymodel.CustomerID + "\\";
                    string url = folder + fileName;
                    if (!System.IO.Directory.Exists(folder))
                    {
                        System.IO.Directory.CreateDirectory(folder);
                    }

                    String WebAddress = newHeadimgurl;
                    System.Net.WebRequest request = System.Net.WebRequest.Create(WebAddress);
                    System.Net.WebResponse response = request.GetResponse();
                    System.IO.Stream responseStream = response.GetResponseStream();
                    System.Drawing.Image image = null;

                    image = System.Drawing.Image.FromStream(response.GetResponseStream());
                    //保存在服务器的本地硬盘
                    image.Save(url);
                    //});
                }
          
            }

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

            if (this.ClientType == 4)
            {
                model.OldPassword = HS.Framework.Common.Safe.CryptRSA.RSADecryptForWeb(model.OldPassword);
                model.NewPassword = HS.Framework.Common.Safe.CryptRSA.RSADecryptForWeb(model.NewPassword);
            }
            else
            {
                model.OldPassword = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.OldPassword);
                model.NewPassword = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.NewPassword);
            }
            bool blResult = Login_BLL.Instance.updateUserPassword(this.UserID, model.OldPassword, model.NewPassword);

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
            if (this.ClientType == 4)
            {
                model.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSADecryptForWeb(model.LoginMobile);
            }
            else
            {
                model.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.LoginMobile);
            }
            if (!Customer_BLL.Instance.IsExistCustomer(model.LoginMobile, model.CompanyID))
            {
                result.Code = "0";
                result.Message = "用户不存在！";
                return toJson(result);
            }
            //model = Customer_BLL.Instance.getCustomerInfo(model.LoginMobile, model.CompanyID);
            int sendRes = Login_BLL.Instance.getAuthenticationCode(model.LoginMobile, model.CompanyID, 0);
            if (sendRes != 2) {

               result.Code = "0";
               result.Message = "发送失败！";
               return toJson(result);
           }
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

            if (this.ClientType == 4)
            {

                model.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSADecryptForWeb(model.LoginMobile);
                model.AuthenticationCode = HS.Framework.Common.Safe.CryptRSA.RSADecryptForWeb(model.AuthenticationCode);
            }
            else
            {
                model.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.LoginMobile);
                model.AuthenticationCode = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.AuthenticationCode);
            }

            ObjectResult<List<CompanyListByLoginMobile_Model>> ObjResult = Login_BLL.Instance.checkAuthenticationCode(model.LoginMobile, model.AuthenticationCode, model.CompanyID);
            if (ObjResult.Code == "1")
            {
                result.Code = "1";
                result.Data = ObjResult.Data;
                result.Message = "验证成功！";
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
            if (this.ClientType == 4)
            {
                model.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSADecryptForWeb(model.LoginMobile);
                model.Password = HS.Framework.Common.Safe.CryptRSA.RSADecryptForWeb(model.Password);
            }
            else
            {
                model.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.LoginMobile);
                model.Password = HS.Framework.Common.Safe.CryptRSA.RSADecrypt(model.Password);
            }
            bool blResult = Login_BLL.Instance.updateUserPassword(model);
            if (blResult)
            {
                result.Code = "1";
                result.Message = "修改成功！";
            }

            return toJson(result);
        }


        [HttpPost]
        [ActionName("test")]
        public HttpResponseMessage test()
        {
            DateTime dt = DateTime.Now;
            Random random = new Random();
            string randomNumber = "";

            for (int i = 0; i < 5; i++)
            {
                randomNumber += random.Next(10).ToString();
            }
            string fileName = string.Format("{0:yyyyMMddHHmmssffff}", dt) + randomNumber + ".jpg";

            string headimgurl = "http://wx.qlogo.cn/mmopen/g3MonUZtNHkdmzicIlibx6iaFqAc56vxLSUfpb6n5WKSYVY0ChQKkiaJSgQ1dZuTOgvLLrhJbERQQ4eMsv84eavHiaiceqxibJxCfHe/0";
            string newHeadimgurl = headimgurl.Substring(0, headimgurl.LastIndexOf('/') + 1) + "96";
            string folder = WebAPI.Common.CommonUtility.updateUrlSpell(46, 0, 26367);
            string url = folder + fileName;
            if (!System.IO.Directory.Exists(folder))
            {
                System.IO.Directory.CreateDirectory(folder);
            }

            String WebAddress = newHeadimgurl;
            System.Net.WebRequest request = System.Net.WebRequest.Create(WebAddress);
            System.Net.WebResponse response = request.GetResponse();
            System.IO.Stream responseStream = response.GetResponseStream();
            System.Drawing.Image image = null;

            image = System.Drawing.Image.FromStream(response.GetResponseStream());
            //保存在服务器的本地硬盘

            image.Save(url);
            return null;
        }

        [HttpPost]
        [ActionName("UnBindWeChat")]
        public HttpResponseMessage UnBindWeChat()
        {
            ObjectResult<bool> result = new ObjectResult<bool>();
            result.Code = "0";
            result.Message = "登出失败！";
            result.Data = false;
            bool res = Login_BLL.Instance.unBindWeChat(this.GUID, this.CompanyID, this.UserID, this.ClientType);
            if (res) {

                result.Code = "1";
                result.Message = "登出成功！";
                result.Data = true;
            }
            return toJson(result);
        }
    }
}
