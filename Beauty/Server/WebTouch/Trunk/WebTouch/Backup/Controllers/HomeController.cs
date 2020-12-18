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
            utilityModel.ImageHeight = 200;
            utilityModel.ImageWidth = 290;
            utilityModel.Type = 1;// 促销类型 0:所有展示 1:顶部展示 2:列表展示
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            List<PromotionList_Model> topList = new List<PromotionList_Model>();
            bool issuccess = GetPostResponse("Promotion", "GetPromotionList", postJson, out data, false, false);
            if (issuccess)
            {
                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<List<PromotionList_Model>> res = new ObjectResult<List<PromotionList_Model>>();
                    res = JsonConvert.DeserializeObject<ObjectResult<List<PromotionList_Model>>>(data);

                    if (res.Code == "1")
                    {
                        topList = res.Data;
                    }
                }
            }

            ViewBag.TopList = topList;

            utilityModel.ImageHeight = 200;
            utilityModel.ImageWidth = 290;
            utilityModel.Type = 2;// 促销类型 0:所有展示 1:顶部展示 2:列表展示
            postJson = JsonConvert.SerializeObject(utilityModel);

            List<PromotionList_Model> buttomList = new List<PromotionList_Model>();
            issuccess = GetPostResponse("Promotion", "GetPromotionList", postJson, out data, false, false);
            if (issuccess)
            {
                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<List<PromotionList_Model>> res = new ObjectResult<List<PromotionList_Model>>();
                    res = JsonConvert.DeserializeObject<ObjectResult<List<PromotionList_Model>>>(data);

                    if (res.Code == "1")
                    {
                        buttomList = res.Data;
                    }
                }
            }

            ViewBag.ButtomList = buttomList;

            return View();
        }
    }
}
