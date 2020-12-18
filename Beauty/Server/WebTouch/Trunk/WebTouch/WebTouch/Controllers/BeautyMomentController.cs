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
    public class BeautyMomentController : BaseController
    {
        //
        // GET: /BeautyMoment/

        public ActionResult BeautyMomentList()
        {
            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel.ServiceYear = QueryString.IntSafeQ("yy");
            if (operationModel.ServiceYear <= 0)
            {
                operationModel.ServiceYear = DateTime.Now.Year;
            }

            string postJson = JsonConvert.SerializeObject(operationModel);

            string data = "";
            List<AllCustomerRecPic> list = null;
            bool issuccess = GetPostResponseNoRedirect("Image", "getCustomerRecPic", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            ObjectResult<List<AllCustomerRecPic>> res = new ObjectResult<List<AllCustomerRecPic>>();
            res = JsonConvert.DeserializeObject<ObjectResult<List<AllCustomerRecPic>>>(data);

            if (res.Code == "1")
            {
                list = new List<AllCustomerRecPic>();
                list = res.Data;

            }
            ViewBag.Year = operationModel.ServiceYear;
            return View(list);
        }


        public ActionResult BeautyMomentDetail()
        {
            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel.ServiceYear = QueryString.IntSafeQ("yy");
            operationModel.ServiceCode = StringUtils.GetDbLong(QueryString.SafeQ("pc"));
            operationModel.Url = StringUtils.GetDbString(this.Request.Url);
            operationModel.CompanyID = this.CompanyID;
            string postJson = JsonConvert.SerializeObject(operationModel);

            string data = "";
            CustomerRecPicDetail model = null;
            bool issuccess = GetPostResponseNoRedirect("Image", "getCustomerServicePic", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            else
            {
                ObjectResult<CustomerRecPicDetail> res = new ObjectResult<CustomerRecPicDetail>();
                res = JsonConvert.DeserializeObject<ObjectResult<CustomerRecPicDetail>>(data);

                if (res.Code == "1")
                {
                    model = new CustomerRecPicDetail();
                    model = res.Data;

                }
            }

            data = "";
            string jsParam = "";
            issuccess = GetPostResponseNoRedirect("ShareToOther", "GetWXJSShare", postJson, out data, false);

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

            ViewBag.Year = operationModel.ServiceYear;
            ViewBag.JsParam = jsParam;
            return View(model);
        }


        public ActionResult EditBeautyMoment()
        {
            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel.GroupNo = StringUtils.GetDbLong(QueryString.SafeQ("gn"));
            operationModel.Url = StringUtils.GetDbString(this.Request.Url);
            operationModel.CompanyID = this.CompanyID;
            string postJson = JsonConvert.SerializeObject(operationModel);

            string data = "";
            CustomerTGPic model = null;
            bool issuccess = GetPostResponseNoRedirect("Image", "getCustomerTGPic", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            else
            {
                ObjectResult<CustomerTGPic> res = new ObjectResult<CustomerTGPic>();
                res = JsonConvert.DeserializeObject<ObjectResult<CustomerTGPic>>(data);

                if (res.Code == "1")
                {
                    model = new CustomerTGPic();
                    model = res.Data;

                }
            }

            data = "";
            string jsParam = "";
            issuccess = GetPostResponseNoRedirect("ShareToOther", "GetWXJSShare", postJson, out data, false);
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




        public ActionResult EditBeautyMomentPhoto()
        {
            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel.RecordImgID = QueryString.SafeQ("ri");

            string postJson = JsonConvert.SerializeObject(operationModel);

            string data = "";
            CustomerTGPicList model = new CustomerTGPicList();
            if (!string.IsNullOrWhiteSpace(operationModel.RecordImgID))
            {

                bool issuccess = GetPostResponseNoRedirect("Image", "getCustomerPicDetail", postJson, out data, false);

                if (!issuccess)
                {
                    return RedirectUrl(data, "", false);
                }
                ObjectResult<CustomerTGPicList> res = new ObjectResult<CustomerTGPicList>();
                res = JsonConvert.DeserializeObject<ObjectResult<CustomerTGPicList>>(data);

                if (res.Code == "1")
                {
                    model = res.Data;

                }

            }
            ViewBag.GroupNo = StringUtils.GetDbLong(QueryString.SafeQ("gn"));

            return View(model);
        }

        public ActionResult UpdateTGComment(ServiceEffectImageOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Image", "UpdateServiceEffectImage", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }


        public ActionResult AddTGPic(ServiceEffectImageOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            if (model != null && model.AddImage != null && model.AddImage.Count > 0)
            {
                foreach (AddTreatmentImageOperation_Model item in model.AddImage)
                {
                    HS.Framework.Common.LogUtil.Log("imagestring", item.ImageString);
                    item.ImageFormat = "." + item.ImageString.Substring(item.ImageString.IndexOf("image/") + 6, item.ImageString.IndexOf("base64,") - item.ImageString.IndexOf("image/") - 7);
                    //item.ImageString = item.ImageString.Replace("\")", "").Replace(")", "");
                    if (item.ImageString.IndexOf("\")") > 0)
                    {
                        item.ImageString = item.ImageString.Substring(item.ImageString.IndexOf("base64,") + 7, item.ImageString.Length - item.ImageString.IndexOf("base64,") - 9);
                    }
                    else
                    {
                        item.ImageString = item.ImageString.Substring(item.ImageString.IndexOf("base64,") + 7, item.ImageString.Length - item.ImageString.IndexOf("base64,") - 8);
                    }
                    //item.ImageString = item.ImageString.Substring(item.ImageString.IndexOf("base64,") + 7, item.ImageString.Length - item.ImageString.IndexOf("base64,") - 7);
                }
                string postJson = JsonConvert.SerializeObject(model);
                string data = string.Empty;
                bool issuccess = GetPostResponseNoRedirect("Image", "UpdateServiceEffectImage", postJson, out data);
                if (issuccess)
                {
                    return Content(data, "application/json; charset=utf-8");
                }
                else
                {
                    return Json(res);
                }
            }
            else
            {
                return Json(res);
            }
        }


        public ActionResult EditCustomerPic(UtilityOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            bool issuccess = GetPostResponseNoRedirect("Image", "editCustomerPic", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult GetShareUrl(long GroupNo)
        {
            ObjectResult<string> res = new ObjectResult<string>();
            res.Message = "修改失败";
            UtilityOperation_Model model = new UtilityOperation_Model();
            model.GroupNo = GroupNo;
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
            bool issuccess = GetPostResponseNoRedirect("ShareToOther", "ShareGroupNo", postJson, out data);
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
