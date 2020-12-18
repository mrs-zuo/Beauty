using ClientAPI.BLL;
using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
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

namespace ClientApi.Controllers.API
{
    public class ShareToOtherController : BaseController
    {
        [HttpPost]
        [ActionName("GetWXJSShare")]
        public HttpResponseMessage GetWXJSShare(JObject obj)
        {
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
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

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if ( string.IsNullOrWhiteSpace(operationModel.Url))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            ShareJSParam_Model model = new ShareJSParam_Model();
            HS.Framework.Common.WeChat.WeChat wc = new HS.Framework.Common.WeChat.WeChat();
            //string strJson = wc.GetWeChatJSConfig(this.CompanyID, operationModel.Url);
            string strJson = wc.GetWeChatJSConfig(operationModel.CompanyID, operationModel.Url);

            res.Code = "1";
            res.Data = strJson;
            return toJson(res);

        }




        [HttpPost]
        [ActionName("ShareGroupNo")]
        //{"GroupNo":2012568547854,"ImageWidth":160,"ImageHeight":160}
        public HttpResponseMessage ShareGroupNo(JObject obj)
        {
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
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

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (operationModel.GroupNo <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }


            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }

            string pwdCompanyId = CryptDES.DESEncrypt(this.CompanyID.ToString(), "share123");
            string pwdCustomerId = CryptDES.DESEncrypt(this.UserID.ToString(), "share123");
            string pwdGroupNo = CryptDES.DESEncrypt(operationModel.GroupNo.ToString(), "share123");
            


            string strDomain = WebUtility_BLL.Instance.GetDomain(operationModel.Type);
            string str = strDomain + "ShareToOthers/BeautyRecord?co=" + System.Web.HttpUtility.UrlEncode(pwdCompanyId) + "&cd=" + System.Web.HttpUtility.UrlEncode(pwdCustomerId) + "&gn=" + System.Web.HttpUtility.UrlEncode(pwdGroupNo);

            //ShareToOther_BLL.Instance.AddTGShareStatics(this.CompanyID, this.UserID, operationModel.GroupNo, str);

            res.Code = "1";
            res.Data = str;
            return toJson(res);
        }


        [HttpPost]
        [ActionName("SharePromotionDetail")]
        public HttpResponseMessage SharePromotionDetail(JObject obj)
        {
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
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

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (string.IsNullOrWhiteSpace(operationModel.PromotionID ))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }


            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }

            string pwdCompanyId = CryptDES.DESEncrypt(this.CompanyID.ToString(),"share123");
            string pwdPromotionId = CryptDES.DESEncrypt(operationModel.PromotionID.ToString(), "share123");


            string strDomain = WebUtility_BLL.Instance.GetDomain(operationModel.Type);
            string str = strDomain + "Promotion/PromotionDetail?co=" + System.Web.HttpUtility.UrlEncode(pwdCompanyId) + "&pc=" + System.Web.HttpUtility.UrlEncode(pwdPromotionId);

            //ShareToOther_BLL.Instance.AddShareStatics(this.CompanyID, 2, this.UserID, operationModel.PromotionID, str);

            res.Code = "1";
            res.Data = str;
            return toJson(res);
        }


        [HttpPost]
        [ActionName("getCustomerTGPic")]
        //{"GroupNo":2012568547854,"ImageWidth":160,"ImageHeight":160}
        public HttpResponseMessage getCustomerTGPic(JObject obj)
        {
            ObjectResult<CustomerTGPic> res = new ObjectResult<CustomerTGPic>();
            res.Code = "0";
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

            PwdOperation_Model operationModel = new PwdOperation_Model();
            operationModel = JsonConvert.DeserializeObject<PwdOperation_Model>(strSafeJson);

            if (string.IsNullOrWhiteSpace(operationModel.PwdCompanyID) || string.IsNullOrWhiteSpace(operationModel.PwdCustomerID) || string.IsNullOrWhiteSpace(operationModel.PwdGroupNo))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }


            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }

            int CompanyID = StringUtils.GetDbInt(CryptDES.DESDecrypt(operationModel.PwdCompanyID,"share123"));
            int CustomerID = StringUtils.GetDbInt(CryptDES.DESDecrypt(operationModel.PwdCustomerID,"share123"));
            long GroupNo = StringUtils.GetDbLong(CryptDES.DESDecrypt(operationModel.PwdGroupNo,"share123"));

            if (CompanyID <= 0 || CustomerID <= 0 || GroupNo <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }


            CustomerTGPic model = Image_BLL.Instance.getCustomerTGPic(CompanyID, CustomerID, GroupNo, operationModel.ImageWidth, operationModel.ImageHeight);
          //  ShareToOther_BLL.Instance.UpdateTGShareCount(CompanyID, GroupNo);

            res.Code = "1";
            res.Data = model;
            return toJson(res);

        }
    }
}
