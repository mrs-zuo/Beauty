using HS.Framework.Common.Net;
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
using WebManager.Models;

namespace WebManager.Controllers.Base
{
    public class BaseController : Controller
    {
        public BaseController()
        {
            string srtCookie = CookieUtil.GetCookieValue("HSManger", true);

            Cookie_Model cookieModel = new Cookie_Model();
            if (!string.IsNullOrWhiteSpace(srtCookie))
            {
                cookieModel = JsonConvert.DeserializeObject<Cookie_Model>(srtCookie);
            }

            CompanyListForAccountLogin_Model model = new CompanyListForAccountLogin_Model();
            string strCompanyCookie = CookieUtil.GetCookieValue("CompanyInfo", true);
            if (!string.IsNullOrWhiteSpace(strCompanyCookie))
            {
                model = Newtonsoft.Json.JsonConvert.DeserializeObject<CompanyListForAccountLogin_Model>(strCompanyCookie);
            }

            CompanyID = cookieModel.CO;
            BranchID = cookieModel.BR;
            UserID = cookieModel.US;
            ClientType = 3;
            DeviceType = 3;
            APPVersion = "1.0";
            GUID = cookieModel.GU;
            Time = DateTime.Now.ToLocalTime();
            BranchName = cookieModel.BranchName;
            CompanyName = cookieModel.CompanyName;
            Advanced = cookieModel.Advanced;
            if (model != null)
            {
                AccountName = model.AccountName;
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
        public string AccountName { get; set; }


        //strParam:
        //"GetAccountListByCompanyIDCompanyID=17&PageIndex=1&Type=0&ImageHeight=170&ImageWidth=170&PageSize=15"
        /// <summary>
        /// 调用API方法
        /// </summary>
        /// <param name="strController">控制器名称</param>
        /// <param name="strAction">方法名称</param>
        /// <param name="strParam">参数</param>
        /// <param out name="Data">返回具体数据</param>
        /// <returns>调用结果</returns>
        //public bool GetPostResponse(string strController, string strAction, string strParam, out string Data, bool isAjax = true)
        //{
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
        //    string srtCookie = CookieUtil.GetCookieValue("HSManger", true);

        //    if (strAction.ToUpper() != "GETCOMPANYLIST" && strAction.ToUpper() != "UPDATELOGININFO")
        //    {
        //        if (string.IsNullOrEmpty(srtCookie))
        //        {
        //            Data = "10013";
        //            RedirectUrl("/");
        //            return false;
        //        }

        //        cookieModel = JsonConvert.DeserializeObject<Cookie_Model>(srtCookie);

        //        if (cookieModel == null)
        //        {
        //            Data = "10013";
        //            RedirectUrl("/");
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
        //    headers.Add("CO", cookieModel.CO.ToString());//111
        //    headers.Add("BR", cookieModel.BR.ToString());//114
        //    headers.Add("US", cookieModel.US.ToString());//4675
        //    headers.Add("CT", "3");//web
        //    headers.Add("DT", "3");//web
        //    headers.Add("AV", "1.0");
        //    headers.Add("ME", strAction.ToUpper());
        //    headers.Add("TI", DateTime.Now.ToLocalTime().ToString());
        //    headers.Add("GU", cookieModel.GU);
        //    headers.Add("Authorization", token);

        //    bool isSuccess = false;
        //    HttpStatusCode resCode = NetUtil.GetResponse(PostUrl, strParam, out Data, headers);

        //    isAjax = Request.IsAjaxRequest();
        //    if (isAjax)
        //    {
        //        switch (resCode)
        //        {
        //            case HttpStatusCode.OK:
        //                //200
        //                isSuccess = true;
        //                break;
        //            case HttpStatusCode.Unauthorized:
        //                //401错误 验证不通过 清除Cookie 返回登录页面
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

        //                myCookie = new HttpCookie("HSManger");
        //                if (myCookie != null)
        //                {

        //                    myCookie.Domain = "";

        //                    DateTime now = DateTime.Now;
        //                    myCookie.Expires = now.AddYears(-2);
        //                    Response.Clear();
        //                    this.Response.BufferOutput = true;
        //                    Response.Cookies.Add(myCookie);
        //                }

        //                //CookieUtil.ClearCookie("CompanyInfo");
        //                //CookieUtil.ClearCookie("HSManger");
        //                RedirectUrl("/Login/Login?err=1");
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
        //                //401错误 验证不通过 清除Cookie 返回登录页面
        //                CookieUtil.ClearCookie("CompanyInfo");
        //                CookieUtil.ClearCookie("HSManger");
        //                RedirectUrl("/Login/Login?err=1");
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
         
        /// <summary>
        /// 
        /// </summary>
        /// <param name="strController"></param>
        /// <param name="strAction"></param>
        /// <param name="strParam"></param>
        /// <param name="Data"></param>
        /// <param name="isAjax"></param>
        /// <returns>Data=10013 RedirectUrl("/") Data=401</returns>
        public bool GetPostResponseNoRedirect(string strController, string strAction, string strParam, out string Data, bool isAjax = true)
        {
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
            string srtCookie = CookieUtil.GetCookieValue("HSManger", true);

            if (strAction.ToUpper() != "GETCOMPANYLIST" && strAction.ToUpper() != "UPDATELOGININFO")
            {
                if (string.IsNullOrEmpty(srtCookie))
                {
                    Data = "10013";
                    //RedirectUrl("/");
                    return false;
                }

                cookieModel = JsonConvert.DeserializeObject<Cookie_Model>(srtCookie);

                if (cookieModel == null)
                {
                    Data = "10013";
                    //RedirectUrl("/");
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
            headers.Add("CO", cookieModel.CO.ToString());//111
            headers.Add("BR", cookieModel.BR.ToString());//114
            headers.Add("US", cookieModel.US.ToString());//4675
            headers.Add("CT", "3");//web
            headers.Add("DT", "3");//web
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
                        //401错误 验证不通过 清除Cookie 返回登录页面
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

                        myCookie = new HttpCookie("HSManger");
                        if (myCookie != null)
                        {

                            myCookie.Domain = "";

                            DateTime now = DateTime.Now;
                            myCookie.Expires = now.AddYears(-2);
                            Response.Clear();
                            this.Response.BufferOutput = true;
                            Response.Cookies.Add(myCookie);
                        }

                        //CookieUtil.ClearCookie("CompanyInfo");
                        //CookieUtil.ClearCookie("HSManger");
                        //RedirectUrl("/Login/Login?err=1");
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
                        //Data = "200";
                        isSuccess = true;
                        break;
                    case HttpStatusCode.Unauthorized:
                        //401错误 验证不通过 清除Cookie 返回登录页面
                        CookieUtil.ClearCookie("CompanyInfo");
                        CookieUtil.ClearCookie("HSManger");
                        //RedirectUrl("/Login/Login?err=1");
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
                        //RedirectUrl("/Home/Index?err=1");
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

        public RedirectResult RedirectUrl(string code, string url, bool isAjax = true)
        {
            if (string.IsNullOrWhiteSpace(url))
            {
                switch (code)
                {
                    case "10013":
                        url = "/";
                        break;
                    case "401":
                        url = "/home/index?err=2";
                        break;
                    case "500":
                        url = "/home/index?err=2";
                        break;
                    case "404":
                        url = "/home/index?err=2";
                        break;
                    default:
                        url = "/home/index?err=2";
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
    }
}
