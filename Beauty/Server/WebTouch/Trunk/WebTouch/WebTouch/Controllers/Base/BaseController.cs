using HS.Framework.Common.Net;
using HS.Framework.Common.Safe;
using HS.Framework.Common.Util;
using Model.View_Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Configuration;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using WebTouch.Models;

namespace WebTouch.Controllers.Base
{
    public class BaseController : Controller
    {
        public BaseController()
        {
            int queryCompanyID = QueryString.IntSafeQ("co");

            if (queryCompanyID <= 0)
            {
                string strWeChatCompany = QueryString.SafeQ("state");
                strWeChatCompany = HttpUtility.UrlDecode(strWeChatCompany);
                queryCompanyID = StringUtils.GetDbInt(HS.Framework.Common.Safe.CryptDES.DESDecrypt(strWeChatCompany, "65033255"));
                if (queryCompanyID > 0)
                {
                    WeChatCode = QueryString.SafeQ("code");
                    if (!string.IsNullOrWhiteSpace(WeChatCode))
                    {
                        HS.Framework.Common.WeChat.WeChat weChatCommon = new HS.Framework.Common.WeChat.WeChat();
                        string strWeChatOpenIDJson = weChatCommon.CodeToToken(WeChatCode, queryCompanyID);
                        if (!string.IsNullOrWhiteSpace(strWeChatOpenIDJson))
                        {
                            var obj = Newtonsoft.Json.Linq.JObject.Parse(strWeChatOpenIDJson);
                            if (obj["openid"] != null || !string.IsNullOrWhiteSpace(StringUtils.GetDbString(obj["openid"])))
                            {
                                string weChatOpenID = StringUtils.GetDbString(obj["openid"]);
                                string weChatUnionID = StringUtils.GetDbString(obj["unionid"]);
                                //string weChatOpenID = "oEG8xuKG9o6sGlL90uZWG_J6aagE";
                                //string weChatUnionID = "oBpNrwVOOup6498J9r2h7m1P2JKY"; //StringUtils.GetDbString(obj["unionid"]);
                                CookieUtil.SetCookie("TWXOD", weChatOpenID, 0, true);
                                CookieUtil.SetCookie("TWXUD", weChatUnionID, 0, true);
                            }
                        }
                    }
                }
            }

            #region 如果传进来的CompanyID与Cookie中的CompanyID不一样 清除Cookie中的CompanyID 清除Cookie中的CompanyStyle
            int cookieCompanyID = StringUtils.GetDbInt(CookieUtil.GetCookieValue("HSTouchCOD", true));
            if (queryCompanyID > 0 && queryCompanyID != cookieCompanyID)
            {
                CookieUtil.ClearCookie("HSTouchStyle");
                CookieUtil.ClearCookie("HSTouchCOD");
                CookieUtil.SetCookie("HSTouchCOD", queryCompanyID.ToString(), 0, true);
                //cookieCompanyID = queryCompanyID;
            }
            #endregion

            //else
            //{
            //    cookieCompanyID = StringUtils.GetDbInt(CookieUtil.GetCookieValue("HSTouchCOD", true));
            //}

            string srtLoginCookie = CookieUtil.GetCookieValue("HSTouch", true);
            Cookie_Model cookieLoginModel = new Cookie_Model();
            if (!string.IsNullOrWhiteSpace(srtLoginCookie))
            {
                cookieLoginModel = JsonConvert.DeserializeObject<Cookie_Model>(srtLoginCookie);
                if (cookieLoginModel != null && cookieLoginModel.CO != 0)
                {
                    if (queryCompanyID > 0 && queryCompanyID != cookieLoginModel.CO)
                    {
                        CookieUtil.ClearCookie("HSTouch");
                        cookieLoginModel = null;
                    }
                }
            }

            if (cookieLoginModel != null)
            {
                CompanyID = cookieLoginModel.CO == 0 ? queryCompanyID : cookieLoginModel.CO;
                BranchID = cookieLoginModel.BR;
                UserID = cookieLoginModel.US;
                ClientType = 4;
                DeviceType = 4;
                APPVersion = "T1.0";
                GUID = cookieLoginModel.GU;
                Time = DateTime.Now.ToLocalTime();
                BranchName = cookieLoginModel.BranchName;
                CompanyName = cookieLoginModel.CompanyName;
                Advanced = cookieLoginModel.Advanced;
                WeChatOpenID = cookieLoginModel.WeChatOpenID == "" ? CookieUtil.GetCookieValue("TWXOD", true) : cookieLoginModel.WeChatOpenID;
            }


            this.CompanyID = queryCompanyID <= 0 ? cookieCompanyID : queryCompanyID;
            string srtStyleCookie = CookieUtil.GetCookieValue("HSTouchStyle", true);
            ViewBag.CompanyStyle = @"";
            if (queryCompanyID != cookieCompanyID || string.IsNullOrWhiteSpace(srtStyleCookie))
            {
                //this.CompanyID = queryCompanyID <= 0 ? cookieCompanyID : queryCompanyID;
                #region 去数据库拿Style
                string data = "";
                GetCompanyDetail_Model model = new GetCompanyDetail_Model();
                bool issuccess = GetPostResponseNoRedirect("Company", "GetCompanySimpleDetail", "", out data, false, false);

                if (issuccess)
                {
                    //RedirectUrl(data, "", false);
                    if (!string.IsNullOrEmpty(data))
                    {
                        HS.Framework.Common.Entity.ObjectResult<GetCompanyDetail_Model> res = new HS.Framework.Common.Entity.ObjectResult<GetCompanyDetail_Model>();
                        res = JsonConvert.DeserializeObject<HS.Framework.Common.Entity.ObjectResult<GetCompanyDetail_Model>>(data);

                        if (res.Code == "1")
                        {
                            model = res.Data;
                        }
                    }
                }
                else
                {
                    model.Style = "#f75483";
                }
                #endregion

                if (model != null && !string.IsNullOrWhiteSpace(model.Style))
                {
                    CookieUtil.SetCookie("HSTouchStyle", model.Style, 0, true);
                    ViewBag.CompanyStyle = model.Style;
                }
            }
            else
            {
                ViewBag.CompanyStyle = srtStyleCookie;
            }

            //if (cookieCompanyID > 0)
            //{
            //    this.CompanyID = cookieCompanyID;
            //}
            //else
            //{

            //}
        }

        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int UserID { get; set; }
        public DateTime Time { get; set; }
        public string Version { get; set; }
        public int ClientType { get; set; }
        public int DeviceType { get; set; }
        public string APPVersion { get; set; }
        public string GUID { get; set; }
        public string BranchName { get; set; }
        public string CompanyName { get; set; }
        public string Advanced { get; set; }
        public string CustomerName { get; set; }
        public string WeChatCode { get; set; }
        public string WeChatOpenID { get; set; }


        //strParam:
        //"GetAccountListByCompanyIDCompanyID=17&PageIndex=1&Type=0&ImageHeight=170&ImageWidth=170&PageSize=15"
        /// </summary>
        /// <param name="strController">控制器名称</param>
        /// <param name="strAction">方法名称</param>
        /// <param name="strParam">JSON格式参数</param>
        /// <param name="Data">返回的JSON数据</param>
        /// <param name="isAjax">是否是Ajax调用,默认为true</param>
        /// <param name="isNeedLogin">是否需要登录验证,默认为true</param>
        /// <returns></returns>
        //public bool GetPostResponse(string strController, string strAction, string strParam, out string Data, bool isAjax = true, bool isNeedLogin = true)
        //{
        //    string urlPath = "";
        //    if (this.Request != null)
        //    {
        //        urlPath = this.Request.Url.PathAndQuery;
        //    }

        //    string PostUrl = StringUtils.GetDbString(ConfigurationManager.AppSettings["PostUrl"]) + strController + "/" + strAction;

        //    if (string.IsNullOrEmpty(strController))
        //    {
        //        Data = "10013";
        //        return false;
        //    }

        //    if (string.IsNullOrEmpty(strAction))
        //    {
        //        Data = "10013";
        //        return false;
        //    }

        //    Cookie_Model cookieModel = new Cookie_Model();
        //    string srtCookie = CookieUtil.GetCookieValue("HSTouch", true);

        //    if (urlPath == "/" || urlPath.ToUpper() == "/HOME/INDEX")
        //    {
        //        if (this.CompanyID <= 0)
        //        {
        //            CookieUtil.DeleteCookie("HSTouch");
        //            RedirectUrl("/Login/Login?fu=" + urlPath);
        //        }
        //    }

        //    if (isNeedLogin)
        //    {
        //        if (this.CompanyID <= 0)
        //        {
        //            CookieUtil.DeleteCookie("HSTouch");
        //            RedirectUrl("/Login/Login?fu=" + urlPath);
        //        }

        //        if (string.IsNullOrEmpty(srtCookie))
        //        {
        //            Data = "10013";
        //            //CookieUtil.DeleteCookie("HSTouch");
        //            RedirectUrl("/Login/Login?fu=" + urlPath);
        //            return false;
        //        }

        //        cookieModel = JsonConvert.DeserializeObject<Cookie_Model>(srtCookie);

        //        if (cookieModel == null)
        //        {
        //            Data = "10013";
        //            //CookieUtil.DeleteCookie("HSTouch");
        //            RedirectUrl("/Login/Login?fu=" + urlPath);
        //            return false;
        //        }

        //        if (cookieModel.CO != this.CompanyID)
        //        {
        //            Data = "10013";
        //            CookieUtil.DeleteCookie("HSTouch");
        //            RedirectUrl("/Login/Login?fu=" + urlPath);
        //            return false;
        //        }
        //    }


        //    NameValueCollection headers = null;
        //    string key = StringUtils.GetDbString(ConfigurationManager.AppSettings["EncryptKey"]);
        //    key = string.IsNullOrEmpty(key) ? "HS" : key;
        //    string finalKey = (strAction + strParam + this.CompanyID + this.GUID + key).ToUpper();
        //    string token = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(finalKey, "MD5");
        //    headers = new NameValueCollection();
        //    headers.Add("Accept-Languag", "zh-cn");
        //    headers.Add("Accept-Charset", "UTF-8");
        //    headers.Add("CO", this.CompanyID.ToString());//111
        //    headers.Add("BR", cookieModel.BR.ToString());//114
        //    headers.Add("US", cookieModel.US.ToString());//4675
        //    headers.Add("CT", "4");//Touch
        //    headers.Add("DT", "4");//Touch
        //    headers.Add("AV", "1.0");
        //    headers.Add("ME", strAction.ToUpper());
        //    headers.Add("TI", DateTime.Now.ToLocalTime().ToString());
        //    headers.Add("GU", cookieModel.GU);
        //    headers.Add("Authorization", token);

        //    bool isSuccess = false;
        //    HttpStatusCode resCode = NetUtil.GetResponse(PostUrl, strParam, out Data, headers);
        //    //HS.Framework.Common.LogUtil.Log("resCode", Data);
        //    if (Request != null)
        //    {
        //        isAjax = Request.IsAjaxRequest();
        //    }
        //    else
        //    {
        //        isAjax = false;
        //    }

        //    if (isAjax)
        //    {

        //        switch (resCode)
        //        {

        //            case HttpStatusCode.OK:
        //                //200
        //                isSuccess = true;
        //                break;
        //            case HttpStatusCode.Unauthorized:
        //                //401错误 验证不通过 清除Cookie 返回登陆页面
        //                isSuccess = false;
        //                HttpCookie myCookie = new HttpCookie("CompanyInfo");
        //                if (myCookie != null)
        //                {
        //                    myCookie.Domain = "";
        //                    DateTime now = DateTime.Now;
        //                    myCookie.Expires = now.AddYears(-2);
        //                    Response.Clear();
        //                    this.Response.BufferOutput = true;
        //                    Response.Cookies.Add(myCookie);
        //                }
        //                myCookie = new HttpCookie("HSTouch");
        //                if (myCookie != null)
        //                {
        //                    myCookie.Domain = "";
        //                    DateTime now = DateTime.Now;
        //                    myCookie.Expires = now.AddYears(-2);
        //                    Response.Clear();
        //                    this.Response.BufferOutput = true;
        //                    Response.Cookies.Add(myCookie);
        //                }
        //                RedirectUrl("/Login/Login?err=1&fu=" + urlPath);
        //                break;
        //            case HttpStatusCode.InternalServerError:
        //                //500错误 
        //                isSuccess = false;
        //                break;
        //            case HttpStatusCode.NotFound:
        //                isSuccess = false;
        //                break;
        //            default:
        //                isSuccess = false;
        //                break;
        //        }
        //    }
        //    else
        //    {
        //        switch (resCode)
        //        {
        //            case HttpStatusCode.OK:
        //                //200
        //                isSuccess = true;
        //                break;
        //            case HttpStatusCode.Unauthorized:
        //                //401错误 验证不通过 清除Cookie 返回登陆页面
        //                //CookieUtil.DeleteCookie("CompanyInfo");
        //                //CookieUtil.DeleteCookie("HSTouch");
        //                RedirectUrl("/Login/LogOut?fu=" + urlPath);
        //                break;
        //            case HttpStatusCode.InternalServerError:
        //                //500错误 
        //                isSuccess = false;
        //                break;
        //            case HttpStatusCode.NotFound:
        //                isSuccess = false;
        //                break;
        //            default:
        //                RedirectUrl("/Home/Index?err=1");
        //                break;
        //        }
        //    }

        //    return isSuccess;
        //}

        public RedirectResult RedirectUrl(string code, string url, bool isAjax = true)
        {
            if (string.IsNullOrWhiteSpace(url))
            {
                switch (code)
                {
                    case "10013":
                        url = "/Home/Index";
                        break;
                    case "401":
                        url = "/Home/Index";
                        break;
                    case "500":
                        url = "/Home/Index";
                        break;
                    case "404":
                        url = "/Home/Index";
                        break;
                    case "10020":
                        if (this.Request != null)
                        {
                            url = "/Login/Login?fu=" + this.Request.Url.PathAndQuery.Replace("&", "%26");
                        }
                        else
                        {
                            url = "/Home/Index";
                        }
                        break;
                    default:
                        url = "/Home/Index";
                        break;
                }
            }

            //if (!string.IsNullOrWhiteSpace(url))
            //{
            //    this.Response.Clear();
            //    this.Response.BufferOutput = true;
            //    if (!this.Response.IsRequestBeingRedirected)
            //    {
            //        this.Response.Redirect(url, true);
            //    }
            //}

            return Redirect(url);
        }

        /// 
        /// </summary>
        /// <param name="strController"></param>
        /// <param name="strAction"></param>
        /// <param name="strParam"></param>
        /// <param name="Data"></param>
        /// <param name="isAjax"></param>
        /// <returns>Data=10013 RedirectUrl("/") Data=401</returns>
        public bool GetPostResponseNoRedirect(string strController, string strAction, string strParam, out string Data, bool isAjax = true, bool isNeedLogin = true)
        {
            string urlPath = "";
            if (this.Request != null)
            {
                urlPath = this.Request.Url.PathAndQuery;
            }

            string PostUrl = StringUtils.GetDbString(ConfigurationManager.AppSettings["PostUrl"]) + strController + "/" + strAction;
            if (string.IsNullOrEmpty(strController))
            {
                Data = "10013";
                return false;
            }

            if (string.IsNullOrEmpty(strAction))
            {
                Data = "10013";
                return false;
            }

            Cookie_Model cookieModel = new Cookie_Model();
            string srtCookie = CookieUtil.GetCookieValue("HSTouch", true);

            if (urlPath == "/" || urlPath.ToUpper() == "/HOME/INDEX")
            {
                if (this.CompanyID <= 0)
                {
                    Data = "10020";
                    //RedirectUrl("/");
                    return false;
                }
            }

            if (isNeedLogin)
            {
                if (this.CompanyID <= 0)
                {
                    CookieUtil.DeleteCookie("HSTouch");
                    Data = "10020";
                }

                if (string.IsNullOrEmpty(srtCookie))
                {
                    Data = "10020";
                    return false;
                }

                cookieModel = JsonConvert.DeserializeObject<Cookie_Model>(srtCookie);

                if (cookieModel == null)
                {
                    Data = "10020";
                    return false;
                }

                if (cookieModel.CO != this.CompanyID)
                {
                    Data = "10020";
                    return false;
                }
            }

            NameValueCollection headers = null;
            string key = StringUtils.GetDbString(ConfigurationManager.AppSettings["EncryptKey"]);
            key = string.IsNullOrEmpty(key) ? "HS" : key;
            string finalKey = (strAction + strParam + this.CompanyID + this.GUID + key).ToUpper();
            string token = System.Web.Security.FormsAuthentication.HashPasswordForStoringInConfigFile(finalKey, "MD5");
            headers = new NameValueCollection();
            headers.Add("Accept-Languag", "zh-cn");
            headers.Add("Accept-Charset", "UTF-8");
            headers.Add("CO", this.CompanyID.ToString());//111
            headers.Add("BR", cookieModel.BR.ToString());//114
            headers.Add("US", cookieModel.US.ToString());//4675
            headers.Add("CT", "4");//touh
            headers.Add("DT", "4");//touh
            headers.Add("AV", "1.0");
            headers.Add("ME", strAction.ToUpper());
            headers.Add("TI", DateTime.Now.ToLocalTime().ToString());
            headers.Add("GU", cookieModel.GU);
            headers.Add("Authorization", token);

            bool isSuccess = false;
            HttpStatusCode resCode = NetUtil.GetResponse(PostUrl, strParam, out Data, headers);

            if (Request != null)
            {
                isAjax = Request.IsAjaxRequest();
            }
            else
            {
                isAjax = false;
            }

            if (isAjax)
            {
                switch (resCode)
                {
                    case HttpStatusCode.OK:
                        //200
                        isSuccess = true;
                        break;
                    case HttpStatusCode.Unauthorized:
                        //401错误 验证不通过 清除Cookie 返回登陆页面
                        isSuccess = false;
                        Data = "401";
                        HttpCookie myCookie = new HttpCookie("CompanyInfo");
                        if (myCookie != null)
                        {
                            myCookie.Domain = "";
                            DateTime now = DateTime.Now;
                            myCookie.Expires = now.AddYears(-2);
                            Response.Clear();
                            this.Response.BufferOutput = true;
                            Response.Cookies.Add(myCookie);
                        }

                        myCookie = new HttpCookie("HSTouch");
                        if (myCookie != null)
                        {
                            myCookie.Domain = "";
                            DateTime now = DateTime.Now;
                            myCookie.Expires = now.AddYears(-2);
                            Response.Clear();
                            this.Response.BufferOutput = true;
                            Response.Cookies.Add(myCookie);
                        }
                        break;
                    case HttpStatusCode.InternalServerError:
                        //500错误 
                        Data = "500";
                        isSuccess = false;
                        break;
                    case HttpStatusCode.NotFound:
                        Data = "404";
                        isSuccess = false;
                        break;
                    default:
                        isSuccess = false;
                        break;
                }
            }
            else
            {
                switch (resCode)
                {
                    case HttpStatusCode.OK:
                        //200
                        isSuccess = true;
                        break;
                    case HttpStatusCode.Unauthorized:
                        //401错误 验证不通过 清除Cookie 返回登陆页面
                        CookieUtil.ClearCookie("CompanyInfo");
                        CookieUtil.ClearCookie("HSTouch");
                        break;
                    case HttpStatusCode.InternalServerError:
                        //500错误 
                        Data = "500";
                        isSuccess = false;
                        break;
                    case HttpStatusCode.NotFound:
                        Data = "404";
                        isSuccess = false;
                        break;
                    default:
                        Data = "404";
                        break;
                }
            }

            return isSuccess;
        }

    }
}
