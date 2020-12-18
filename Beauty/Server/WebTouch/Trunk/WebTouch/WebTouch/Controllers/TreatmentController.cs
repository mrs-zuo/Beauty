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

namespace WebTouch.Controllers
{
    public class TreatmentController : BaseController
    {
        //
        // GET: /Service/

        public ActionResult ServiceRecord()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            int type = QueryString.IntSafeQ("t");
            ViewBag.Type = type;
            if (type == 1)
            {
                utilityModel.GroupNo = StringUtils.GetDbLong(QueryString.SafeQ("gn"));
                string postJson = JsonConvert.SerializeObject(utilityModel);
                string data = "";
                GetTGDetail_Model model = null;
                bool issuccess = GetPostResponseNoRedirect("Order", "GetTGDetail", postJson, out data, false);

                if (!issuccess)
                {
                    return RedirectUrl(data, "", false);
                }

                ObjectResult<GetTGDetail_Model> res = new ObjectResult<GetTGDetail_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<GetTGDetail_Model>>(data);

                if (res.Code == "1")
                {
                    model = new GetTGDetail_Model();
                    model = res.Data;
                }


                ViewBag.MainKey = utilityModel.GroupNo;
                return View(model);
            }
            else
            {
                utilityModel.TreatmentID = QueryString.IntSafeQ("tId");
                string postJson = JsonConvert.SerializeObject(utilityModel);
                string data = "";
                GetTreatmentDetail_Model model = null;
                bool issuccess = GetPostResponseNoRedirect("Order", "GetTreatmentDetail", postJson, out data, false);
                if (!issuccess)
                {
                    return RedirectUrl(data, "", false);
                }
                ObjectResult<GetTreatmentDetail_Model> res = new ObjectResult<GetTreatmentDetail_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<GetTreatmentDetail_Model>>(data);

                if (res.Code == "1")
                {
                    model = new GetTreatmentDetail_Model();
                    model = res.Data;


                }
                ViewBag.MainKey = utilityModel.TreatmentID;
                return View(model);
            }
        }

        public ActionResult ReviewDetail()
        {
            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            int type = QueryString.IntSafeQ("t");
            ViewBag.Type = type;
            if (type == 1)
            {
                operationModel.GroupNo = StringUtils.GetDbLong(QueryString.SafeQ("gn"));
                string postJson = JsonConvert.SerializeObject(operationModel);
                string data = "";
                GetReviewDetail_Model model = null;
                bool issuccess = GetPostResponseNoRedirect("Review", "GetReviewDetailForTG", postJson, out data, false);
                if (!issuccess)
                {
                    return RedirectUrl(data, "", false);
                }
                ObjectResult<GetReviewDetail_Model> res = new ObjectResult<GetReviewDetail_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<GetReviewDetail_Model>>(data);

                if (res.Code == "1" && res.Data != null)
                {
                    model = new GetReviewDetail_Model();
                    model = res.Data;
                }
                ViewBag.MainKey = operationModel.GroupNo;
                return View(model);
            }
            else
            {
                operationModel.TreatmentID = QueryString.IntSafeQ("tId");
                string postJson = JsonConvert.SerializeObject(operationModel);
                string data = "";
                Review_Model model = null;
                bool issuccess = GetPostResponseNoRedirect("Review", "GetReviewDetailForTM", postJson, out data, false);

                if (!issuccess)
                {
                    return RedirectUrl(data, "", false);
                }
                ObjectResult<Review_Model> res = new ObjectResult<Review_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<Review_Model>>(data);

                if (res.Code == "1")
                {
                    model = new Review_Model();
                    model = res.Data;
                }
                ViewBag.MainKey = operationModel.TreatmentID;
                return View(model);
            }
        }



        public ActionResult ServiceEffect()
        {
            ServiceEffectImageOperation_Model operationModel = new ServiceEffectImageOperation_Model();
            int type = QueryString.IntSafeQ("t");
            ViewBag.Type = type;
            if (type == 1)
            {
                ViewBag.MainKey = QueryString.LongSafeQ("gn");
                operationModel.GroupNo = QueryString.LongSafeQ("gn");
                operationModel.TreatmentID = 0;
            }
            else
            {

                operationModel.TreatmentID = QueryString.IntSafeQ("tId");
                ViewBag.TreatmentID = operationModel.TreatmentID;
                ViewBag.MainKey = operationModel.TreatmentID;

            }

            operationModel.ImageThumbHeight = 200;
            operationModel.ImageThumbWidth = 200;
            string postJson = JsonConvert.SerializeObject(operationModel);
            string data = "";
            GetServiceEffectImage_Model model = null;
            bool issuccess = GetPostResponseNoRedirect("Image", "getServiceEffectImage", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            ObjectResult<GetServiceEffectImage_Model> res = new ObjectResult<GetServiceEffectImage_Model>();
            res = JsonConvert.DeserializeObject<ObjectResult<GetServiceEffectImage_Model>>(data);

            if (res.Code == "1")
            {
                model = new GetServiceEffectImage_Model();
                model = res.Data;

            }


            return View(model);
        }



        public ActionResult test()
        {
            return View();
        }


    }
}
