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
    public class ProductController : BaseController
    {
        //
        // GET: /Product/

        public ActionResult ProductCategory()
        {
            int productType = HS.Framework.Common.Safe.QueryString.IntSafeQ("t");
            int categoryID = HS.Framework.Common.Safe.QueryString.IntSafeQ("c");
            ViewBag.ProductType = productType;
            ViewBag.CategoryID = categoryID;
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CategoryID = categoryID;
            utilityModel.Type = productType;
            string postJson = JsonConvert.SerializeObject(utilityModel);

            //string url = "/Product/ProductCategory?t=" + productType;
            //if (categoryID > 0)
            //{
            //    url += "&c=" + categoryID;
            //}

            string data = "";
            CategoryInfo_Model model = new CategoryInfo_Model();

            bool issuccess = GetPostResponse("Category", "GetCategoryList", postJson, out data , false, true);

            if (issuccess)
            {
                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<CategoryInfo_Model> res = new ObjectResult<CategoryInfo_Model>();
                    res = JsonConvert.DeserializeObject<ObjectResult<CategoryInfo_Model>>(data);

                    if (res.Code == "1")
                    {
                        model = res.Data;
                    }
                }
            }
            return View(model);
        }

        public ActionResult ProductList()
        {
            int productType = HS.Framework.Common.Safe.QueryString.IntSafeQ("t");
            int categoryID = HS.Framework.Common.Safe.QueryString.IntSafeQ("c");
            ViewBag.ProductType = productType;
            ViewBag.CategoryID = categoryID;

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            //utilityModel.CompanyID = this.CompanyID;
            utilityModel.CategoryID = categoryID;
            utilityModel.ImageHeight = 160;
            utilityModel.ImageWidth = 160;
            utilityModel.isShowAll = true;
            string postJson = JsonConvert.SerializeObject(utilityModel);

            //string url = "/Product/ProductList?t" + productType;
            //if (categoryID > 0)
            //{
            //    url += "&c=" + categoryID;
            //}

            string data = "";
            bool issuccess;
            ProductListInfo_Model model = new ProductListInfo_Model();
            if (productType == 1) //商品
            {
                if (categoryID <= 0)
                {
                    //公司下所有
                    issuccess = GetPostResponse("Commodity", "GetCommodityListByCompanyID", postJson, out data,  false, true);
                }
                else
                { 
                    //分类下
                    issuccess = GetPostResponse("Commodity", "GetCommodityListByCategoryID", postJson, out data,  false, true);
                }
            }
            else //服务
            {
                if (categoryID <= 0)
                {
                    //公司下所有
                    issuccess = GetPostResponse("Service", "GetServiceListByCompanyID", postJson, out data,  false, true);
                }
                else
                {
                    //分类下
                    issuccess = GetPostResponse("Service", "getServiceListByCategoryID", postJson, out data,  false, true);
                }
            }

            if (issuccess)
            {
                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<ProductListInfo_Model> res = new ObjectResult<ProductListInfo_Model>();
                    res = JsonConvert.DeserializeObject<ObjectResult<ProductListInfo_Model>>(data);

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
