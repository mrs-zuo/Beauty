using HS.Framework.Common.Entity;
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
    public class ProductController : BaseController
    {
        //
        // GET: /Product/

        public ActionResult ServiceCategory()
        {
            int categoryID = HS.Framework.Common.Safe.QueryString.IntSafeQ("c");
            ViewBag.CategoryID = categoryID;
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CategoryID = categoryID;
            utilityModel.Type = 0;
            string postJson = JsonConvert.SerializeObject(utilityModel);

            //string url = "/Product/ProductCategory?t=" + productType;
            //if (categoryID > 0)
            //{
            //    url += "&c=" + categoryID;
            //}

            string data = "";
            CategoryInfo_Model model = new CategoryInfo_Model();

            bool issuccess = GetPostResponseNoRedirect("Category", "GetCategoryList", postJson, out data, false, true);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<CategoryInfo_Model> res = new ObjectResult<CategoryInfo_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<CategoryInfo_Model>>(data);

                if (res.Code == "1")
                {
                    model = res.Data;
                }
            }
            return View(model);
        }

        public ActionResult CommodityCategory()
        {
            int categoryID = HS.Framework.Common.Safe.QueryString.IntSafeQ("c");
            ViewBag.CategoryID = categoryID;
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CategoryID = categoryID;
            utilityModel.Type = 1;
            string postJson = JsonConvert.SerializeObject(utilityModel);

            //string url = "/Product/ProductCategory?t=" + productType;
            //if (categoryID > 0)
            //{
            //    url += "&c=" + categoryID;
            //}

            string data = "";
            CategoryInfo_Model model = new CategoryInfo_Model();

            bool issuccess = GetPostResponseNoRedirect("Category", "GetCategoryList", postJson, out data, false, true);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<CategoryInfo_Model> res = new ObjectResult<CategoryInfo_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<CategoryInfo_Model>>(data);

                if (res.Code == "1")
                {
                    model = res.Data;
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
            utilityModel.ImageHeight = 98;
            utilityModel.ImageWidth = 98;
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
                    issuccess = GetPostResponseNoRedirect("Commodity", "GetCommodityListByCompanyID", postJson, out data, false, true);
                }
                else
                {
                    //分类下
                    issuccess = GetPostResponseNoRedirect("Commodity", "GetCommodityListByCategoryID", postJson, out data, false, true);
                }
            }
            else //服务
            {
                if (categoryID <= 0)
                {
                    //公司下所有
                    issuccess = GetPostResponseNoRedirect("Service", "GetServiceListByCompanyID", postJson, out data, false, true);
                }
                else
                {
                    //分类下
                    issuccess = GetPostResponseNoRedirect("Service", "getServiceListByCategoryID", postJson, out data, false, true);
                }
            }

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<ProductListInfo_Model> res = new ObjectResult<ProductListInfo_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<ProductListInfo_Model>>(data);

                if (res.Code == "1")
                {
                    model = res.Data;
                }
            }
            return View(model);
        }

        public ActionResult ServiceDetail()
        {
            long productCode = StringUtils.GetDbLong(HS.Framework.Common.Safe.QueryString.SafeQ("lc"));

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.ProductCode = productCode;
            utilityModel.ImageHeight = 600;
            utilityModel.ImageWidth = 800;
            utilityModel.CustomerID = this.UserID;
            string postJson = JsonConvert.SerializeObject(utilityModel);


            string data = "";
            bool issuccess;
            ServiceDetail_Model model = null;

            issuccess = GetPostResponseNoRedirect("Service", "GetServiceDetailByServiceCode_2_1", postJson, out data, false, true);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            ObjectResult<ServiceDetail_Model> res = new ObjectResult<ServiceDetail_Model>();
            res = JsonConvert.DeserializeObject<ObjectResult<ServiceDetail_Model>>(data);

            if (res.Code == "1")
            {
                model = new ServiceDetail_Model();
                model = res.Data;
            }
            return View(model);
        }

        public ActionResult CommodityDetail()
        {
            long productCode = StringUtils.GetDbLong(HS.Framework.Common.Safe.QueryString.SafeQ("lc"));

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.ProductCode = productCode;
            utilityModel.ImageHeight = 600;
            utilityModel.ImageWidth = 800;
            utilityModel.CustomerID = this.UserID;
            string postJson = JsonConvert.SerializeObject(utilityModel);


            string data = "";
            bool issuccess;
            CommodityDetail_Model model = null;

            issuccess = GetPostResponseNoRedirect("Commodity", "getCommodityDetailByCommodityCode", postJson, out data, false, true);


            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            ObjectResult<CommodityDetail_Model> res = new ObjectResult<CommodityDetail_Model>();
            res = JsonConvert.DeserializeObject<ObjectResult<CommodityDetail_Model>>(data);

            if (res.Code == "1")
            {
                model = new CommodityDetail_Model();
                model = res.Data;
            }
            return View(model);
        }


        public ActionResult PurchaseDetail()
        {
            string postJson = Request.Form["txtCardIDList"].ToString();

            string data = "";
            bool issuccess;
            List<ProductInfoList_Model> list = null;

            issuccess = GetPostResponseNoRedirect("Commodity", "getProductInfoListForWeb", postJson, out data, false, true);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            ObjectResult<List<ProductInfoList_Model>> res = new ObjectResult<List<ProductInfoList_Model>>();
            res = JsonConvert.DeserializeObject<ObjectResult<List<ProductInfoList_Model>>>(data);

            if (res.Code == "1")
            {
                list = new List<ProductInfoList_Model>();
                list = res.Data;
            }

            return View(list);
        }


        public ActionResult MyCart()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.ImageHeight = 98;
            utilityModel.ImageWidth = 98;
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            bool issuccess;
            List<GetCartList_Model> list = null;

            issuccess = GetPostResponseNoRedirect("Cart", "GetCartList", postJson, out data, false, true);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            ObjectResult<List<GetCartList_Model>> res = new ObjectResult<List<GetCartList_Model>>();
            res = JsonConvert.DeserializeObject<ObjectResult<List<GetCartList_Model>>>(data);

            if (res.Code == "1")
            {
                list = new List<GetCartList_Model>();
                list = res.Data;
            }

            return View(list);
        }

        public ActionResult AddFavorite(CustomerFavorite_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Customer", "AddFavorite", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult DelFavorite(CustomerFavorite_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Customer", "DelFavorite", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult AddCart(CartOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Cart", "AddCart", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }



        public ActionResult UpdateCart(CartOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Cart", "UpdateCart", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult DeleteCart(CartOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Cart", "DeleteCart", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult GetCardList(UtilityOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;

            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = GetPostResponseNoRedirect("ECard", "GetCardDiscountList", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }



        public ActionResult AddNewOrder(OrderOperation_Model model)
        {
            foreach (OrderDetailOperation_Model item in model.OrderList)
            {
                item.TotalOrigPrice = StringUtils.GetDbDecimal(item.StrTotalOrigPrice, -1);
                item.TotalCalcPrice = StringUtils.GetDbDecimal(item.StrTotalCalcPrice, -1);
                item.TotalSalePrice = StringUtils.GetDbDecimal(item.StrTotalCalcPrice, -1);
            }

            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;

            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = GetPostResponseNoRedirect("Order", "AddNewOrder", postJson, out data);

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
