using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.View_Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebTouch.Controllers.Base;

namespace WebTouch.Controllers
{
    public class PromotionController : BaseController
    {
        public ActionResult PromotionList()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.ImageHeight = 120;
            utilityModel.ImageWidth = 160;
            utilityModel.Type = 0;// 促销类型 0:所有展示 1:顶部展示 2:列表展示
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            List<PromotionList_Model> topList = new List<PromotionList_Model>();
            bool issuccess = GetPostResponseNoRedirect("Promotion", "GetPromotionList", postJson, out data, false, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<PromotionList_Model>> res = new ObjectResult<List<PromotionList_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<PromotionList_Model>>>(data);

                if (res.Code == "1")
                {
                    topList = res.Data;
                }
            }
            return View(topList);
        }

        public ActionResult PromotionDetail()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            string strCompanyID = QueryString.SafeQ("co");
            if (string.IsNullOrWhiteSpace(strCompanyID))
            {
                utilityModel.CompanyID = this.CompanyID;
                utilityModel.Prama = QueryString.SafeQ("pc");
            }
            else
            {
                utilityModel.CompanyID = StringUtils.GetDbInt(CryptDES.DESDecrypt(strCompanyID, "share123"));
                this.CompanyID = utilityModel.CompanyID;
                CookieUtil.SetCookie("HSTouchCOD", utilityModel.CompanyID.ToString(), 0, true);
                string strParam = QueryString.SafeQ("pc");
                utilityModel.Prama = CryptDES.DESDecrypt(strParam, "share123");
            }
            utilityModel.ImageHeight = 600;
            utilityModel.ImageWidth = 800;

            utilityModel.Url = StringUtils.GetDbString(this.Request.Url);
            if (string.IsNullOrWhiteSpace(utilityModel.Prama))
            {
                return View();
            }

            string postJson = JsonConvert.SerializeObject(utilityModel);
            string data = "";
            PromotionDetail_Model model = new PromotionDetail_Model();
            bool issuccess = GetPostResponseNoRedirect("Promotion", "GetPromotionDetail", postJson, out data, false, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            else
            {
                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<PromotionDetail_Model> res = new ObjectResult<PromotionDetail_Model>();
                    res = JsonConvert.DeserializeObject<ObjectResult<PromotionDetail_Model>>(data);

                    if (res.Code == "1")
                    {
                        model = res.Data;
                    }

                }
            }
            data = "";
            string jsParam = "";
            issuccess = GetPostResponseNoRedirect("ShareToOther", "GetWXJSShare", postJson, out data, false, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            else
            {
                ObjectResult<string> res = new ObjectResult<string>();
                res = JsonConvert.DeserializeObject<ObjectResult<string>>(data);

                if (res.Code == "1")
                {
                    jsParam = res.Data;

                }
            }
            ViewBag.JsParam = jsParam;
            return View(model);
        }



        public ActionResult GetShareUrl(string PromotionCode)
        {
            ObjectResult<string> res = new ObjectResult<string>();
            res.Message = "修改失败";
            UtilityOperation_Model model = new UtilityOperation_Model();
            model.PromotionID = PromotionCode;
            string strDomain = System.Web.HttpContext.Current.Request.Url.Host;
            if (strDomain.IndexOf("test") > 0)
            {
                model.Type = 2;
            }
            else
            {
                model.Type = 1;
            }
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            bool issuccess = GetPostResponseNoRedirect("ShareToOther", "SharePromotionDetail", postJson, out data, true, false);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

    }
}
