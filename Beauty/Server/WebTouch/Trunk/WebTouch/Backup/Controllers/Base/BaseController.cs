﻿using HS.Framework.Common.Net;
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
            int companyID = QueryString.IntSafeQ("co");

            if (companyID <= 0)
            {
                string strWeChatCompany = QueryString.SafeQ("state");
                strWeChatCompany = HttpUtility.UrlDecode(strWeChatCompany);
                companyID = StringUtils.GetDbInt(HS.Framework.Common.Safe.CryptDES.DESDecrypt(strWeChatCompany, "65033255"));
                if (companyID > 0)
                {
                    WeChatCode = QueryString.SafeQ("code");
                    if (!string.IsNullOrWhiteSpace(WeChatCode))
                    {
                        string strWeChatOpenIDJson = HS.Framework.Common.WeChat.WeChat.CodeToToken(WeChatCode);
                        if (!string.IsNullOrWhiteSpace(strWeChatOpenIDJson))
                        {
                            var obj = Newtonsoft.Json.Linq.JObject.Parse(strWeChatOpenIDJson);
                            if (obj["openid"] != null || !string.IsNullOrWhiteSpace(StringUtils.GetDbString(obj["openid"])))
                            {
                                string weChatOpenID = StringUtils.GetDbString(obj["openid"]);
                                string weChatUnionID = StringUtils.GetDbString(obj["unionid"]);

                                CookieUtil.SetCookie("TWXOD", weChatOpenID, 0, true);
                                CookieUtil.SetCookie("TWXUD", weChatUnionID, 0, true);
                            }
                        }
                    }
                }
            }

            if (companyID > 0)
            {
                CookieUtil.SetCookie("HSTouchCOD", companyID.ToString(), 0, true);
            }

            int cookieCompanyID = StringUtils.GetDbInt(CookieUtil.GetCookieValue("HSTouchCOD", true));

            string srtCookie = CookieUtil.GetCookieValue("HSTouch", true);
            Cookie_Model cookieModel = new Cookie_Model();
            if (!string.IsNullOrWhiteSpace(srtCookie))
            {
                cookieModel = JsonConvert.DeserializeObject<Cookie_Model>(srtCookie);
            }

            if (cookieModel != null)
            {
                CompanyID = cookieModel.CO == 0 ? cookieCompanyID : cookieModel.CO;
                BranchID = cookieModel.BR;
                UserID = cookieModel.US;
                ClientType = 4;
                DeviceType = 4;
                APPVersion = "T1.0";
                GUID = cookieModel.GU;
                Time = DateTime.Now.ToLocalTime();
                BranchName = cookieModel.BranchName;
                CompanyName = cookieModel.CompanyName;
                Advanced = cookieModel.Advanced;
            }

            if (cookieCompanyID > 0)
            {
                if (cookieModel.CO > 0 && cookieCompanyID != cookieModel.CO)
                {
                    CookieUtil.ClearCookie("HSTouch");
                }
                this.CompanyID = cookieCompanyID;
            }
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

        //strParam:
        //"GetAccountListByCompanyIDCompanyID=17&PageIndex=1&Type=0&ImageHeight=170&ImageWidth=170&PageSize=15"
        /// <summary>
        /// 调用API方法
        /// </summary>
        /// <param name="strController">控制器名称</param>
        /// <param name="strAction">方法名称</param>
        /// <param name="strParam">参数</param>
        /// <param out name="Data">返回具体数据</param>
        /// <param out name="urlPath">登录后后要跳转的页面</param>
        /// <returns>调用结果</returns>
        public bool GetPostResponse(string strController, string strAction, string strParam, out string Data, bool isAjax = true, bool isNeedLogin = true)
        {
            string urlPath = this.Request.Url.PathAndQuery;

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

            if (isNeedLogin)
            {
                if (this.CompanyID <= 0)
                {
                    if (!string.IsNullOrWhiteSpace(urlPath) && urlPath != "/")
                    {
                        RedirectUrl("/Login/Login?fu=" + urlPath);
                    }
                    else
                    {
                        RedirectUrl("/Login/Login");
                    }
                }

                if (string.IsNullOrEmpty(srtCookie))
                {
                    Data = "10013";
                    RedirectUrl("/Login/Login");
                    return false;
                }

                cookieModel = JsonConvert.DeserializeObject<Cookie_Model>(srtCookie);

                if (cookieModel == null)
                {
                    Data = "10013";
                    RedirectUrl("/");
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
            headers.Add("CT", "4");//Touch
            headers.Add("DT", "4");//Touch
            headers.Add("AV", "1.0");
            headers.Add("ME", strAction.ToUpper());
            headers.Add("TI", DateTime.Now.ToLocalTime().ToString());
            headers.Add("GU", cookieModel.GU);
            headers.Add("Authorization", token);

            bool isSuccess = false;
            HttpStatusCode resCode = NetUtil.GetResponse(PostUrl, strParam, out Data, headers);

            isAjax = Request.IsAjaxRequest();
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
                        RedirectUrl("/Login/Login?err=1&fu=" + urlPath);
                        break;
                    case HttpStatusCode.InternalServerError:
                        //500错误 
                        isSuccess = false;
                        break;
                    case HttpStatusCode.NotFound:
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
                        RedirectUrl("/Login/Login?err=1");
                        break;
                    case HttpStatusCode.InternalServerError:
                        //500错误 
                        isSuccess = false;
                        break;
                    case HttpStatusCode.NotFound:
                        isSuccess = false;
                        break;
                    default:
                        RedirectUrl("/Home/Index?err=1");
                        break;
                }
            }

            return isSuccess;
        }

        public void RedirectUrl(string url)
        {
            this.Response.Clear();
            this.Response.BufferOutput = true;
            if (!this.Response.IsRequestBeingRedirected)
            {
                this.Response.Redirect(url, true);
            }
        }
    }
}
