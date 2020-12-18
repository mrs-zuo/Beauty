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

namespace WebTouch.Controllers
{
    public class PromotionController : BaseController
    {
        public ActionResult PromotionList()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.ImageHeight = 200;
            utilityModel.ImageWidth = 290;
            utilityModel.Type = 0;// 促销类型 0:所有展示 1:顶部展示 2:列表展示
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            List<PromotionList_Model> topList = new List<PromotionList_Model>();
            bool issuccess = GetPostResponse("Promotion", "GetPromotionList", postJson, out data,  false);
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
            return View(topList);
        }

        public ActionResult PromotionDetail()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.ImageHeight = 200;
            utilityModel.ImageWidth = 290;
            utilityModel.Prama = HS.Framework.Common.Safe.QueryString.SafeQ("pc");// 促销类型 0:所有展示 1:顶部展示 2:列表展示
            if (string.IsNullOrWhiteSpace(utilityModel.Prama))
            {
                return View();
            }

            string postJson = JsonConvert.SerializeObject(utilityModel);
            string data = "";
            PromotionDetail_Model model = new PromotionDetail_Model();
            bool issuccess = GetPostResponse("Promotion", "GetPromotionDetail", postJson, out data, false);
            if (issuccess)
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
            return View(model);
        }
    }
}
