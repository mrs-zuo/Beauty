using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.View_Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebTouch.Controllers.Base;
using WebTouch.Filter;

namespace WebTouch.Controllers
{
    public class HomeController : BaseController
    {
        public ActionResult Index()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.ImageHeight = 600;
            utilityModel.ImageWidth = 800;
            utilityModel.Type = 1;// 促销类型 0:所有展示 1:顶部展示 2:列表展示
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

            ViewBag.TopList = topList;

            utilityModel.ImageHeight = 120;
            utilityModel.ImageWidth = 160;
            utilityModel.Type = 2;// 促销类型 0:所有展示 1:顶部展示 2:列表展示
            postJson = JsonConvert.SerializeObject(utilityModel);

            List<PromotionList_Model> buttomList = new List<PromotionList_Model>();
            issuccess = GetPostResponseNoRedirect("Promotion", "GetPromotionList", postJson, out data, false, false);
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
                    buttomList = res.Data;
                }

            }

            ViewBag.ButtomList = buttomList;

            utilityModel.ImageHeight = 400;
            utilityModel.ImageWidth = 400;
            postJson = JsonConvert.SerializeObject(utilityModel);
            List<ProductList_Model> RecommendedList = new List<ProductList_Model>();
            issuccess = GetPostResponseNoRedirect("Commodity", "getRecommendedProductList", postJson, out data, false, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<ProductList_Model>> res = new ObjectResult<List<ProductList_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<ProductList_Model>>>(data);

                if (res.Code == "1")
                {
                    RecommendedList = res.Data;
                }
            }
            ViewBag.RecommendedList = RecommendedList;
            return View();
        }


        public ActionResult test()
        {
            return View();
        }
    }
}
