using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebTouch.Controllers.Base;
using WebTouch.Models;

using System.Security.Cryptography;
namespace WebTouch.Controllers
{
    public class LoginController : BaseController
    {
        //
        // GET: /Login/
        private RSACrypto rsa = new RSACrypto();
        private RSAParameters rsaParam;

        public ActionResult Login()
        {

            string fromUrl = QueryString.SafeQ("fu",100);
            if (string.IsNullOrWhiteSpace(fromUrl))
            {
                fromUrl = this.Request.Url.PathAndQuery;
            }
            if (fromUrl.Contains("fu="))
            {
                int fuIndex = fromUrl.IndexOf("fu=");
                fromUrl = fromUrl.Substring(fuIndex, (fromUrl.Length - fuIndex));
                fromUrl = fromUrl.Replace("fu=", "");
            }
            string srtCookie = CookieUtil.GetCookieValue("HSTouch", true);
            string data = "";
            bool result;

            Cookie_Model cookieModel = new Cookie_Model();
            if (!string.IsNullOrWhiteSpace(srtCookie))
            {
                cookieModel = JsonConvert.DeserializeObject<Cookie_Model>(srtCookie);

                if (cookieModel != null && cookieModel.CO != this.CompanyID)
                {
                    CookieUtil.DeleteCookie("HSTouch");
                    cookieModel = null;
                }

                if (cookieModel != null)
                {
                    return Redirect("/");
                    //return Redirect(string.IsNullOrWhiteSpace(HS.Framework.Common.Safe.QueryString.SafeQ("fu")) ? "/" : fromUrl);
                }
            }

            string weChatOpenID = StringUtils.GetDbString(CookieUtil.GetCookieValue("TWXOD", true));
            string weChatUnionID = StringUtils.GetDbString(CookieUtil.GetCookieValue("TWXUD", true));

            if (!string.IsNullOrWhiteSpace(weChatOpenID))
            {
                if (this.CompanyID <= 0)
                {
                    return Redirect("/Login/Login?err=1");
                }

                #region 微信公众号过来绑定或者自动的登录
                Login_Model loginModel = new Login_Model(); ;
                UtilityOperation_Model operationModel = new UtilityOperation_Model();
                operationModel.Prama = weChatOpenID;
                string param = Newtonsoft.Json.JsonConvert.SerializeObject(operationModel);

                result = this.GetPostResponseNoRedirect("Login", "getUserByWeChatOpenID", param, out data, false, false);

                if (!result)
                {
                    return RedirectUrl(data, "", false);
                }

                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<Login_Model> res = new ObjectResult<Login_Model>();
                    res = JsonConvert.DeserializeObject<ObjectResult<Login_Model>>(data);
                    loginModel = res.Data;
                }


                if (loginModel != null && loginModel.UserID > 0)
                {
                    #region 查询到OpenID有记录,自动登录
                    loginModel.WXOpenID = weChatOpenID;
                    bool updateResult = updateLogin(loginModel.CompanyID, loginModel.UserID, loginModel.WXOpenID, loginModel.CompanyName);
                    if (updateResult)
                    {
                        CookieUtil.DeleteCookie("TWXOD");
                        CookieUtil.DeleteCookie("TWXUD");

                        return Redirect(string.IsNullOrWhiteSpace(fromUrl) ? "/" : fromUrl);
                    }
                    #endregion
                }
                #endregion
            }




            string strPublicKey = HS.Framework.Common.Safe.CryptRSA.GetPublicKeyStringForWeb();

            rsa.InitCrypto(strPublicKey);
            rsaParam = rsa.ExportParameters(false);
            ViewBag.RSA_E = RSAStringHelper.BytesToHexString(rsaParam.Exponent);
            ViewBag.RSA_M = RSAStringHelper.BytesToHexString(rsaParam.Modulus);


            ViewBag.UrlPath = fromUrl;
            ViewBag.WeChatOpenID = weChatOpenID;
            ViewBag.CompanyID = QueryString.IntSafeQ("co");
            return View();
        }

        public bool updateLogin(int CompanyID, int UserID, string weChatOpenID, string CompanyName)
        {
            Login_Model model = new Login_Model();
            model.CompanyID = CompanyID;
            model.UserID = UserID;
            model.ClientType = 4;
            model.DeviceType = 4;
            model.AppVersion = "T1.0";
            model.IPAddress = HS.Framework.Common.Util.Misc.FullIPAddress;
            model.WXOpenID = weChatOpenID;
            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);

            string data = "";
            bool result = this.GetPostResponseNoRedirect("Login", "updateLoginInfoForWeChat", param, out data, true, false);

            if (!result)
            {
                CookieUtil.DeleteCookie("HSTouch");
                return false;
            }

            ObjectResult<RoleForLogin_Model> loginResult = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<RoleForLogin_Model>>(data);

            if (loginResult.Code != "1")
            {
                CookieUtil.DeleteCookie("HSTouch");
                return false;
            }
            else
            {
                Cookie_Model cookieModel = new Cookie_Model();
                cookieModel.CO = CompanyID;
                cookieModel.US = UserID;
                cookieModel.GU = loginResult.Data.GUID;
                cookieModel.LoginMobile = model.LoginMobile;
                cookieModel.Password = model.Password;
                cookieModel.CompanyName = CompanyName;
                cookieModel.CurrencySymbol = loginResult.Data.CurrencySymbol;
                cookieModel.WeChatOpenID = StringUtils.GetDbString(CookieUtil.GetCookieValue("TWXOD", true));
                CookieUtil.SetCookie("HSTouch", Newtonsoft.Json.JsonConvert.SerializeObject(cookieModel), 0, true);
                //CookieUtil.DeleteCookie("param");
                //Session["LoginError"] = null;

                return true;
            }
        }

        public bool updateLogin(int CompanyID, int UserID, string LoginMobile, string Password, string CompanyName)
        {
            Login_Model model = new Login_Model();
            model.CompanyID = CompanyID;
            //model.BranchID = BranchID;
            model.UserID = UserID;
            model.LoginMobile = LoginMobile;
            model.Password = Password;
            model.ClientType = 4;
            model.DeviceType = 4;
            model.AppVersion = "T1.0";
            model.IPAddress = HS.Framework.Common.Util.Misc.FullIPAddress;
            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);

            string data = "";
            bool result = this.GetPostResponseNoRedirect("Login", "updateLoginInfo", param, out data, true, false);

            if (!result)
            {
                CookieUtil.DeleteCookie("HSTouch");
                return false;
            }

            ObjectResult<RoleForLogin_Model> loginResult = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<RoleForLogin_Model>>(data);

            if (loginResult.Code != "1")
            {
                CookieUtil.DeleteCookie("HSTouch");
                return false;
            }
            else
            {
                Cookie_Model cookieModel = new Cookie_Model();
                cookieModel.CO = CompanyID;
                //cookieModel.BR = BranchID;
                cookieModel.US = UserID;
                cookieModel.GU = loginResult.Data.GUID;
                //cookieModel.Role = loginResult.Data.Role;
                cookieModel.LoginMobile = model.LoginMobile;
                cookieModel.Password = model.Password;
                //cookieModel.Advanced = Advanced;
                //cookieModel.BranchName = BranchName;
                cookieModel.CompanyName = CompanyName;
                cookieModel.CurrencySymbol = loginResult.Data.CurrencySymbol;
                //cookieModel.RoleID = loginResult.Data.RoleID;
                cookieModel.WeChatOpenID = StringUtils.GetDbString(CookieUtil.GetCookieValue("TWXOD", true));
                CookieUtil.SetCookie("HSTouch", Newtonsoft.Json.JsonConvert.SerializeObject(cookieModel), 0, true);
                CookieUtil.DeleteCookie("param");
                Session["LoginError"] = null;

                return true;
            }
        }

        public string getCompanyList(string loginMobile, string password, string validateCode, bool needRSAEncrypt)
        {
            Login_Model model = new Login_Model();
            //if (needRSAEncrypt)
            //{
            //    model.LoginMobile = CryptRSA.RSAEncrypt(loginMobile);
            //    model.Password = CryptRSA.RSAEncrypt(password);
            //}
            //else
            //{
            //    model.LoginMobile = loginMobile;
            //    model.Password = password;
            //}
            model.LoginMobile = loginMobile;
            model.Password = password;

            model.CompanyID = this.CompanyID;
            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string res = "0";

            string data = "";
            bool result = this.GetPostResponseNoRedirect("Login", "getCompanyList", param, out data, true, false);

            if (!result)
            {

                res = "-1";
                return res;
            }

            ObjectResult<List<CompanyListForCustomerLogin_Model>> resultList = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<List<CompanyListForCustomerLogin_Model>>>(data);

            if (resultList.Code != "1")
            {
                Session["LoginError"] = "Error";
                res = "0";

                return res;
            }
            else
            {
                Session["LoginError"] = null;
                if (resultList.Data.Count == 1)
                {
                    //SetCompanyInfoCookie(resultList.Data, 0, 0, false);
                    bool updateResult = updateLogin(resultList.Data[0].CompanyID, resultList.Data[0].CustomerID, model.LoginMobile, model.Password, resultList.Data[0].CompanyName);
                    if (updateResult)
                    {
                        res = "1";
                        return res;
                    }
                    else
                    {
                        return res;
                    }
                }
                else
                {
                    CookieUtil.SetCookie("CompanyList", Newtonsoft.Json.JsonConvert.SerializeObject(resultList.Data), 0, true);
                    CookieUtil.SetCookie("param", Newtonsoft.Json.JsonConvert.SerializeObject(model), 0, true);

                    res = "2";
                    return res;
                }
            }
        }

        public ActionResult BindWeChatOpenID(string loginMobile, string password, string validateCode, bool needRSAEncrypt)
        {
            ObjectResult<CompanyListForCustomerLogin_Model> res = new ObjectResult<CompanyListForCustomerLogin_Model>();
            res.Code = "0";
            res.Message = "网络繁忙,请稍后再登！";
            Login_Model model = new Login_Model();
            //if (needRSAEncrypt)
            //{
            //    model.LoginMobile = CryptRSA.RSAEncrypt(loginMobile);
            //    model.Password = CryptRSA.RSAEncrypt(password);
            //}
            //else
            //{
            //    model.LoginMobile = loginMobile;
            //    model.Password = password;
            //}

            model.LoginMobile = loginMobile;
            model.Password = password;
            model.WXOpenID = StringUtils.GetDbString(CookieUtil.GetCookieValue("TWXOD", true));
            model.WXUnionID = StringUtils.GetDbString(CookieUtil.GetCookieValue("TWXUD", true));
            model.CompanyID = this.CompanyID;
            HS.Framework.Common.WeChat.WeChat we = new HS.Framework.Common.WeChat.WeChat();
            if (!string.IsNullOrWhiteSpace(model.WXOpenID))
            {
                model.WeChatUserInfoPrama = we.GetUserDetail(this.CompanyID, model.WXOpenID);
            }
            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";
            bool result = this.GetPostResponseNoRedirect("Login", "BindWeChatOpenID", param, out data, true, false);

            if (!result)
            {
                return Json(res);
            }

            ObjectResult<CompanyListForCustomerLogin_Model> resultList = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<CompanyListForCustomerLogin_Model>>(data);

            if (resultList.Code != "1")
            {
                //Session["LoginError"] = "Error";
                return Content(data, "application/json; charset=utf-8");
            }

            //Session["LoginError"] = null;
            if (resultList.Data != null)
            {
                bool updateResult = updateLogin(resultList.Data.CompanyID, resultList.Data.CustomerID, model.LoginMobile, model.Password, resultList.Data.CompanyName);
                if (updateResult)
                {
                    res.Code = "1";
                    CookieUtil.DeleteCookie("TWXOD");
                    CookieUtil.DeleteCookie("TWXUD");
                    return Json(res);
                }
                else
                {
                    return Json(res);
                }
            }
            else
            {
                // CookieUtil.SetCookie("CompanyList", Newtonsoft.Json.JsonConvert.SerializeObject(resultList.Data), 0, true);
                //CookieUtil.SetCookie("param", Newtonsoft.Json.JsonConvert.SerializeObject(model), 0, true);
                res.Code = "2";
                return Json(res);
            }

        }

        public void SetCompanyInfoCookie(List<CompanyListForAccountLogin_Model> companyList, int companyIndex, bool canChangeBranch)
        {
            CookieUtil.SetCookie("CompanyInfo", Newtonsoft.Json.JsonConvert.SerializeObject(companyList[companyIndex]), 0, false);
        }

        public ActionResult select()
        {
            string strCookie = CookieUtil.GetCookieValue("CompanyList", true);
            if (string.IsNullOrEmpty(strCookie))
            {
                return Redirect("/");
            }
            ViewBag.CompanyList = JsonConvert.DeserializeObject<List<CompanyListForAccountLogin_Model>>(strCookie);
            return View();
        }

        public ActionResult selectCompany(string CompanyIndex)
        {
            int companyIndex = StringUtils.GetDbInt(CompanyIndex);
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "选择公司失败！请重试！";
            res.Data = false;

            string cookie = CookieUtil.GetCookieValue("CompanyList", true);
            if (string.IsNullOrEmpty(cookie))
                return Json(res);
            List<CompanyListForAccountLogin_Model> list = JsonConvert.DeserializeObject<List<CompanyListForAccountLogin_Model>>(cookie);

            if (companyIndex < 0 || list.Count < (companyIndex + 1))
            {
                res.Data = false;
                return Json(res);
            }
            else
            {
                Login_Model model = JsonConvert.DeserializeObject<Login_Model>(CookieUtil.GetCookieValue("param", true));

                bool updateResult = updateLogin(list[companyIndex].CompanyID, list[companyIndex].AccountID, model.LoginMobile, model.Password, list[companyIndex].CompanyName);

                if (updateResult)
                {
                    res.Data = updateResult;
                    res.Message = "";
                    res.Code = "1";
                    //SetCompanyInfoCookie(list, companyIndex, false);
                    CookieUtil.DeleteCookie("CompanyList");
                }
                return Json(res);
            }
        }

        public ActionResult LogOut()
        {
            string Url = QueryString.SafeQ("fu");
            ViewBag.outUrl = Url;
            CookieUtil.ClearCookie("CompanyInfo");
            CookieUtil.ClearCookie("HSTouch");
            return View();
        }

        public ActionResult ChangePassword()
        {
            string strPublicKey = HS.Framework.Common.Safe.CryptRSA.GetPublicKeyStringForWeb();

            rsa.InitCrypto(strPublicKey);
            rsaParam = rsa.ExportParameters(false);
            ViewBag.RSA_E = RSAStringHelper.BytesToHexString(rsaParam.Exponent);
            ViewBag.RSA_M = RSAStringHelper.BytesToHexString(rsaParam.Modulus);
            return View();
        }



        public ActionResult Setup()
        {
            return View();
        }

        public ActionResult UpdatePassWord(UpdateUserPassword_Model model)
        {
            model.UserID = this.UserID;
            //model.OldPassword = HS.Framework.Common.Safe.CryptRSA.RSAEncrypt(model.OldPassword);
            //model.NewPassword = HS.Framework.Common.Safe.CryptRSA.RSAEncrypt(model.NewPassword);
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Login", "updateUserPassword", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult UnBindWeChat()
        {
            string data = string.Empty;
            bool issuccess = GetPostResponseNoRedirect("Login", "UnBindWeChat", null, out data);
            ObjectResult<bool> res = new ObjectResult<bool>();
            if (issuccess)
            {
                res = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<bool>>(data);
                if (res.Code == "1" && res.Data)
                {
                    CookieUtil.ClearCookie("CompanyInfo");
                    CookieUtil.ClearCookie("HSTouch");
                }
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }


    }
}
