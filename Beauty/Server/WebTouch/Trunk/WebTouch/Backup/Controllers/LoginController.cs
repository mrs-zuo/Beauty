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

namespace WebTouch.Controllers
{
    public class LoginController : BaseController
    {
        //
        // GET: /Login/

        public ActionResult Login()
        {
            string fromUrl = HS.Framework.Common.Safe.QueryString.SafeQ("fu");
            string srtCookie = CookieUtil.GetCookieValue("HSTouch", true);
            string data = "";
            bool result;

            Cookie_Model cookieModel = new Cookie_Model();
            if (!string.IsNullOrWhiteSpace(srtCookie))
            {
                cookieModel = JsonConvert.DeserializeObject<Cookie_Model>(srtCookie);
                if (cookieModel != null)
                {
                    return Redirect("/");
                }
            }

            string weChatOpenID = StringUtils.GetDbString(CookieUtil.GetCookieValue("TWXOD", true));
            string weChatUnionID = StringUtils.GetDbString(CookieUtil.GetCookieValue("TWXUD", true));

            if (!string.IsNullOrWhiteSpace(weChatOpenID) && !string.IsNullOrWhiteSpace(weChatUnionID))
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

                result = this.GetPostResponse("Login", "getUserByWeChatOpenID", param, out data, false, false);
                if (result)
                {
                    if (!string.IsNullOrEmpty(data))
                    {
                        ObjectResult<Login_Model> res = new ObjectResult<Login_Model>();
                        res = JsonConvert.DeserializeObject<ObjectResult<Login_Model>>(data);
                        loginModel = res.Data;
                    }
                }

                if (loginModel != null)
                {
                    #region 查询到OpenID有记录,自动登录
                    loginModel.WXOpenID = weChatOpenID;
                    bool updateResult = updateLogin(loginModel.CompanyID, loginModel.UserID, loginModel.WXOpenID, loginModel.CompanyName);
                    if (updateResult)
                    {
                        CookieUtil.DeleteCookie("TWXOD");
                        CookieUtil.DeleteCookie("TWXUD");
                        return Redirect(fromUrl);
                    }
                    #endregion
                }
                #endregion
            }


            ViewBag.UrlPath = fromUrl;
            ViewBag.WeChatOpenID = weChatOpenID;
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
            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);

            string data = "";
            bool result = this.GetPostResponse("Login", "updateLoginInfoForWeChat", param, out data, true, false);

            if (!result)
            {
                return false;
            }

            ObjectResult<RoleForLogin_Model> loginResult = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<RoleForLogin_Model>>(data);

            if (loginResult.Code != "1")
            {
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
                CookieUtil.SetCookie("HSTouch", Newtonsoft.Json.JsonConvert.SerializeObject(cookieModel), 0, true);
                //CookieUtil.ClearCookie("param");
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
            bool result = this.GetPostResponse("Login", "updateLoginInfo", param, out data, true, false);

            if (!result)
            {
                return false;
            }

            ObjectResult<RoleForLogin_Model> loginResult = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<RoleForLogin_Model>>(data);

            if (loginResult.Code != "1")
            {
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
                //cookieModel.RoleID = loginResult.Data.RoleID;

                CookieUtil.SetCookie("HSTouch", Newtonsoft.Json.JsonConvert.SerializeObject(cookieModel), 0, true);
                CookieUtil.ClearCookie("param");
                Session["LoginError"] = null;

                return true;
            }
        }

        public string getCompanyList(string loginMobile, string password, string validateCode, bool needRSAEncrypt)
        {
            Login_Model model = new Login_Model();
            if (needRSAEncrypt)
            {
                model.LoginMobile = CryptRSA.RSAEncrypt(loginMobile);
                model.Password = CryptRSA.RSAEncrypt(password);
            }
            else
            {
                model.LoginMobile = loginMobile;
                model.Password = password;
            }

            model.CompanyID = this.CompanyID;
            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string res = "0";

            string data = "";
            bool result = this.GetPostResponse("Login", "getCompanyList", param, out data, true, false);

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

        public string BindWeChatOpenID(string loginMobile, string password, string validateCode, bool needRSAEncrypt)
        {
            Login_Model model = new Login_Model();
            if (needRSAEncrypt)
            {
                model.LoginMobile = CryptRSA.RSAEncrypt(loginMobile);
                model.Password = CryptRSA.RSAEncrypt(password);
            }
            else
            {
                model.LoginMobile = loginMobile;
                model.Password = password;
            }
            model.WXOpenID = StringUtils.GetDbString(CookieUtil.GetCookieValue("TWXOD", true));
            model.WXUnionID = StringUtils.GetDbString(CookieUtil.GetCookieValue("TWXUD", true));
            model.CompanyID = this.CompanyID;
            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string res = "0";

            string data = "";
            bool result = this.GetPostResponse("Login", "BindWeChatOpenID", param, out data, true, false);

            if (!result)
            {
                res = "-1";
                return res;
            }

            ObjectResult<CompanyListForCustomerLogin_Model> resultList = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<CompanyListForCustomerLogin_Model>>(data);

            if (resultList.Code != "1")
            {
                //Session["LoginError"] = "Error";
                res = "0";
                return res;
            }

            //Session["LoginError"] = null;
            if (resultList.Data != null)
            {
                bool updateResult = updateLogin(resultList.Data.CompanyID, resultList.Data.CustomerID, model.LoginMobile, model.Password, resultList.Data.CompanyName);
                if (updateResult)
                {
                    res = "1";
                    CookieUtil.DeleteCookie("TWXOD");
                    CookieUtil.DeleteCookie("TWXUD");
                    return res;
                }
                else
                {
                    return res;
                }
            }
            else
            {
                // CookieUtil.SetCookie("CompanyList", Newtonsoft.Json.JsonConvert.SerializeObject(resultList.Data), 0, true);
                //CookieUtil.SetCookie("param", Newtonsoft.Json.JsonConvert.SerializeObject(model), 0, true);
                res = "2";
                return res;
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
                    CookieUtil.ClearCookie("CompanyList");
                }
                return Json(res);
            }
        }
    }
}
