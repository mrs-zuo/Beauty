using BLToolkit.Common;
using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Web.Mvc;
using WebManager.Controllers.Base;
using WebManager.Models;

namespace WebManager.Controllers
{
    public class CommodityController : BaseController
    {
        //
        // GET: /Commodity/

        public ActionResult GetCommodityList()
        {
            string srtCookie = CookieUtil.GetCookieValue("HSManger", true);
            Cookie_Model cookieModel = new Cookie_Model();
            if (!string.IsNullOrWhiteSpace(srtCookie))
            {
                cookieModel = JsonConvert.DeserializeObject<Cookie_Model>(srtCookie);
            }

            int branchID = StringUtils.GetDbInt(QueryString.IntSafeQ("b").ToString(), -1);
            int categoryID = StringUtils.GetDbInt(QueryString.IntSafeQ("c").ToString(), -1);
            int supplierID = StringUtils.GetDbInt(QueryString.IntSafeQ("d").ToString(), -1);

            UtilityOperation_Model model = new UtilityOperation_Model();

            //总公司可以查看各分店的商品 分公司的只能查看自己分店下的商品
            bool isBranch = cookieModel.BR > 0;
            model.BranchID = isBranch ? cookieModel.BR : branchID;
            model.CategoryID = categoryID;
            model.ImageHeight = 70;
            model.ImageWidth = 70;
            model.Type = 1;
            model.Flag = 0;
            model.SupplierID = supplierID;

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);

            string commodityData = "";
            bool comResult = this.GetPostResponseNoRedirect("Commodity_M", "getCommodityList", param, out commodityData, false);

            string calData = "";
            bool calResult = this.GetPostResponseNoRedirect("Category_M", "getCategoryList", param, out calData, false);

            if (!comResult)
            {
                return RedirectUrl(commodityData, "", false);
            }

            if (!calResult)
            {
                return RedirectUrl(calData, "", false);
            }

            string supData = "";
            bool supResult = this.GetPostResponseNoRedirect("Supplier_M", "getSupplierListForWeb", param, out supData, false);

            if (!supResult)
            {
                return RedirectUrl(supData, "", false);
            }
            ViewBag.CategoryID = categoryID;
            ViewBag.SupplierID = supplierID;
            ObjectResult<List<Commodity_Model>> comObjResult = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<List<Commodity_Model>>>(commodityData);
            ObjectResult<List<CategoryList_Model>> calObjResult = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<List<CategoryList_Model>>>(calData);
            ObjectResult<List<Supplier_Model>> supObjResult = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<List<Supplier_Model>>>(supData);

            //总公司的 可已选分店 分公司的不能选
            if (!isBranch)
            {
                string branData = "";
                bool braResult = this.GetPostResponseNoRedirect("Branch_M", "GetBranchListForWeb", param, out branData);
                if (!braResult)
                {
                    return RedirectUrl(branData, "");
                }
                ObjectResult<List<Branch_Model>> braObjResult = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<List<Branch_Model>>>(branData);
                ViewBag.BranchList = braObjResult.Data;
            }

            ViewBag.IsBranch = isBranch;
            ViewBag.BranchName = isBranch ? this.BranchName : "";
            ViewBag.BranchID = isBranch ? cookieModel.BR : branchID;
            ViewBag.CommodityList = comObjResult.Data;
            ViewBag.CategoryList = calObjResult.Data;
            ViewBag.SupplierList = supObjResult.Data;

            return View();
        }

        public ActionResult deleteCommodity(string CommodityCode)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "删除失败";
            res.Data = false;
            long commodityCode = StringUtils.GetDbLong(CommodityCode);

            UtilityOperation_Model model = new UtilityOperation_Model();
            model.CommodityCode = commodityCode;

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";
            bool result = this.GetPostResponseNoRedirect("Commodity_M", "deleteCommodity", param, out data);

            if (!result)
            {
                return Json(res);
            }

            return Content(data, "application/json; charset=utf-8");
        }

        public ActionResult deleteMultiCommodity(DelMultiCommodity_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Data = false;
            res.Message = "删除失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Commodity_M", "deteleMultiCommodity", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");
        }

        public ActionResult EditCommodity()
        {
            long commodityCode = QueryString.LongSafeQ("CD");
            ViewBag.commodityCode = commodityCode;

            string srtCookie = CookieUtil.GetCookieValue("HSManger", true);
            Cookie_Model cookieModel = new Cookie_Model();
            if (!string.IsNullOrWhiteSpace(srtCookie))
            {
                cookieModel = JsonConvert.DeserializeObject<Cookie_Model>(srtCookie);
            }

            int tabIndex = StringUtils.GetDbInt(QueryString.IntSafeQ("tabidx").ToString(), -1);

            UtilityOperation_Model model = new UtilityOperation_Model();


            //总公司可以查看各分店的商品 分公司的只能查看自己分店下的商品
            bool isBranch = cookieModel.BR > 0;
            #region Param 赋值
            model.BranchID = cookieModel.BR == 0 ? -1 : cookieModel.BR;
            model.CompanyID = cookieModel.CO;
            model.ImageHeight = 500;
            model.ImageWidth = 500;
            model.Type = 1;
            model.Flag = 1;
            model.CommodityCode = commodityCode;

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            #endregion

            #region 获取分类列表
            string calData = "";
            bool calResult = this.GetPostResponseNoRedirect("Category_M", "getCategoryList", param, out calData, false);

            if (!calResult)
            {
                return RedirectUrl(calData, "", false);
            }


            ObjectResult<List<CategoryList_Model>> calObjResult = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<List<CategoryList_Model>>>(calData);
            ViewBag.CategoryList = calObjResult.Data;

            #endregion

            #region 获取商品详细信息

            string comData = "";
            bool comResult = this.GetPostResponseNoRedirect("Commodity_M", "getCommodityDetail", param, out comData, false);

            if (!comResult)
            {
                return RedirectUrl(comData, "", false);
            }

            ObjectResult<CommodityDetail_Model> comObjResult = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<CommodityDetail_Model>>(comData);
            ViewBag.CommodityDetail = comObjResult.Data;

            ViewBag.BigImageList = comObjResult.Data.BigImageList;
            ImageCommon_Model imageModel = new ImageCommon_Model();
            imageModel.FileUrl = comObjResult.Data.Thumbnail;

            ViewBag.thumbImage = imageModel;

            #endregion

            #region 供应商下拉列表
            //供应商下拉框信息
            string comDataSupplier = "";
            bool comResultSupplier = this.GetPostResponseNoRedirect("Commodity_M", "getCommoditySupplierDetail", param, out comDataSupplier, false);
            if (!comResultSupplier)
            {
                return RedirectUrl(comDataSupplier, "", false);
            }
            ObjectResult<CommodityDetail_Model> comObjResultSupplier = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<CommodityDetail_Model>>(comDataSupplier);
            ViewBag.SupplierDetail = comObjResultSupplier.Data.SupplierDetail;
            #endregion

            #region 获取出入库列表
            string proData = "";
            bool proResult = this.GetPostResponseNoRedirect("Commodity_M", "getStorageDetail", param, out proData, false);
            if (!proResult)
            {
                return RedirectUrl(proData, "", false);
            }
            ObjectResult<List<StorageDetail_Model>> proObjResult = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<List<StorageDetail_Model>>>(proData);
            ViewBag.StorageDetail = proObjResult.Data;

            string quaData = "";
            bool quaResult = this.GetPostResponseNoRedirect("Commodity_M", "getQuantity", param, out quaData, false);
            if (!quaResult)
            {
                return RedirectUrl(quaData, "", false);
            }
            ObjectResult<int> quaObjResult = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<int>>(quaData);
            ViewBag.Quantity = quaObjResult.Data;
            ViewBag.BranchName = cookieModel.BranchName;
            #endregion


            model.Flag = 0;//GetDiscountList中Flag = 0 是取Available= 1的DIsucount
            param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string discountData = "";
            List<GetLevelList_Model> list = new List<GetLevelList_Model>();
            bool levelResult = GetPostResponseNoRedirect("Level_M", "GetDiscountList", param, out discountData, false);
            if (!levelResult)
            {
                return RedirectUrl(discountData, "", false);
            }

            ObjectResult<List<GetDiscountListForManager_Model>> objDiscount = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<List<GetDiscountListForManager_Model>>>(discountData);
            ViewBag.DiscountList = objDiscount.Data;
            ViewBag.isBranch = this.BranchID > 0;
            ViewBag.tabIndex = tabIndex;

            return View();
        }

        public ActionResult addCommodity(CommodityDetailOperation_Model model)
        {
            ObjectResult<addProductResult_Model> res = new ObjectResult<addProductResult_Model>();
            res.Code = "0";
            res.Data = null;
            res.Message = "添加失败";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Commodity_M", "addCommodity", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");
        }

        public ActionResult updateCommodity(CommodityDetailOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Data = false;
            res.Message = "更新失败";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Commodity_M", "updateCommodityDetail", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");
        }

        public ActionResult updateProductStocks(BranchCommodityOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Data = false;
            res.Message = "更新失败";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Commodity_M", "updateProductStocks", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");
        }

        public ActionResult downloadCommodity(UtilityOperation_Model model)
        {
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Data = "";
            res.Message = "下载失败";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Commodity_M", "downloadCommodityList", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");
        }

        /// <summary>
        /// 批量添加商品批次模板下载
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public ActionResult downloadCommodityBatchTemplate(UtilityOperation_Model model)
        {
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Data = "";
            res.Message = "下载失败";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Commodity_M", "downloadCommodityBatchTemplateList", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");
        }

        public ActionResult getCommodityPrintList(DelMultiCommodity_Model model)
        {
            ObjectResult<List<Commodity_Model>> res = new ObjectResult<List<Commodity_Model>>();
            res.Data = null;
            res.Message = "删除失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Commodity_M", "getPrintList", param, out data);

            if (!result)
                return Json(res);
            else
                res = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<List<Commodity_Model>>>(data);

            return Json(res);
        }

        public ActionResult EditCommoditySort()
        {
            int categoryID = StringUtils.GetDbInt(QueryString.IntSafeQ("c").ToString(), -1);
            UtilityOperation_Model model = new UtilityOperation_Model();
            //总公司可以查看各分店的商品 分公司的只能查看自己分店下的商品
            model.CategoryID = categoryID;
            model.ImageHeight = 500;
            model.ImageWidth = 500;
            model.Type = 1;
            model.Flag = 0;
            model.BranchID = -1;
            model.SupplierID = -1;

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);

            string commodityData = "";
            bool comResult = this.GetPostResponseNoRedirect("Commodity_M", "getCommodityList", param, out commodityData, false);

            if (!comResult)
            {
                return RedirectUrl(commodityData, "", false);
            }

            string calData = "";
            bool calResult = this.GetPostResponseNoRedirect("Category_M", "getCategoryList", param, out calData, false);

            if (!calResult)
            {
                return RedirectUrl(calData, "", false);
            }

            ViewBag.CategoryID = categoryID;
            ObjectResult<List<Commodity_Model>> comObjResult = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<List<Commodity_Model>>>(commodityData);
            ObjectResult<List<CategoryList_Model>> calObjResult = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<List<CategoryList_Model>>>(calData);

            ViewBag.CommodityList = comObjResult.Data;
            ViewBag.CategoryList = calObjResult.Data;

            return View();
        }

        public ActionResult UpdateCommoditySort(UtilityOperation_Model SortMode)
        {
            string postJson = JsonConvert.SerializeObject(SortMode);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Commodity_M", "UpdateCommoditySort", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }


        public ActionResult AddBatch(string code)
        {
            if (string.IsNullOrWhiteSpace(code))
            {
                return Redirect("/Commodity/GetCommodityList?b=-1&c=-1");
            }
            long commodityCode = long.Parse(code);
            ViewBag.commodityCode = commodityCode;

            string srtCookie = CookieUtil.GetCookieValue("HSManger", true);
            Cookie_Model cookieModel = new Cookie_Model();
            if (!string.IsNullOrWhiteSpace(srtCookie))
            {
                cookieModel = JsonConvert.DeserializeObject<Cookie_Model>(srtCookie);
            }

            int branchID = StringUtils.GetDbInt(QueryString.IntSafeQ("b").ToString(), -1);
            int categoryID = StringUtils.GetDbInt(QueryString.IntSafeQ("c").ToString(), -1);

            UtilityOperation_Model model = new UtilityOperation_Model();

            //总公司可以查看各分店的商品 分公司的只能查看自己分店下的商品
            bool isBranch = cookieModel.BR > 0;
            model.BranchID = isBranch ? cookieModel.BR : branchID;
            model.CompanyID = cookieModel.CO;
            model.ImageHeight = 70;
            model.ImageWidth = 70;
            model.Type = 1;
            model.Flag = 1;
            model.CommodityCode = commodityCode;

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);

            //总公司的 可已选分店 分公司的不能选
            if (!isBranch)
            {
                string comData = "";
                bool comResult = this.GetPostResponseNoRedirect("Commodity_M", "getCommodityDetail", param, out comData, false);

                if (!comResult)
                {
                    return RedirectUrl(comData, "", false);
                }

                ObjectResult<CommodityDetail_Model> comObjResult = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<CommodityDetail_Model>>(comData);
                ViewBag.CommodityDetail = comObjResult.Data;
            }
            //供应商下拉框信息
            string comDataSupplier = "";
            bool comResultSupplier = this.GetPostResponseNoRedirect("Commodity_M", "getCommoditySupplierDetail", param, out comDataSupplier, false);
            if (!comResultSupplier)
            {
                return RedirectUrl(comDataSupplier, "", false);
            }
            ObjectResult<CommodityDetail_Model> comObjResultSupplier = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<CommodityDetail_Model>>(comDataSupplier);
            if (ViewBag.CommodityDetail == null)
            {
                ViewBag.CommodityDetail = comObjResultSupplier.Data;
            }
            else {
                ViewBag.CommodityDetail.SupplierDetail = comObjResultSupplier.Data.SupplierDetail;
            }
            ViewBag.IsBranch = isBranch;
            ViewBag.BranchName = isBranch ? this.BranchName : "";
            ViewBag.BranchID = isBranch ? cookieModel.BR : branchID;

            return View((object)code);
        }

        public ActionResult DoAddBatch(Product_Stock_Batch_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Data = false;
            res.Message = "更新失败";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Commodity_M", "DoAddBatch", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");
        }

        public ActionResult updateBatchStocks(BatchCommodityOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Data = false;
            res.Message = "更新失败";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Commodity_M", "updateBatchStocks", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");
        }

        public ActionResult DeleteBatch(BatchCommodityOperation_Model.DelBatchOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Data = false;
            res.Message = "删除失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Commodity_M", "deleteBatch", param, out data);

            if (!result)
            {
                return Json(res);
            }
            else
            {
                return Content(data, "application/json; charset=utf-8");
            }
        }

        public ActionResult operateQuantity(int Quantity, long commodityCode)
        {
           
            StorageDetail_Model model = new StorageDetail_Model();
            model.Quantity = Quantity;
            model.ProductCode = commodityCode;

            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Data = false;
            res.Message = "添加失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Commodity_M", "operateQuantity", param, out data);

            if (!result)
            {
                return Json(res);
            }
            else
            {
                return Content(data, "application/json; charset=utf-8");
            }
        }
        public ActionResult applyCommodityCode(int Quantity, long commodityCode)
        {

            StorageDetail_Model model = new StorageDetail_Model();
            model.Quantity = Quantity;
            model.ProductCode = commodityCode;

            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Data = false;
            res.Message = "添加失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Commodity_M", "applyCommodityCode", param, out data);

            if (!result)
            {
                return Json(res);
            }
            else
            {
                return Content(data, "application/json; charset=utf-8");
            }
        }
        public ActionResult agreeCommodityCode(int id, string batchNO, DateTime expiryDate)
        {

            StorageDetail_Model model = new StorageDetail_Model();
            model.ID = id;
            model.BatchNO = batchNO;
            model.ExpiryDate = expiryDate;

            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Data = false;
            res.Message = "添加失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Commodity_M", "agreeCommodityCode", param, out data);

            if (!result)
            {
                return Json(res);
            }
            else
            {
                return Content(data, "application/json; charset=utf-8");
            }
        }
        public ActionResult negativeCommodityCode(int id)
        {

            StorageDetail_Model model = new StorageDetail_Model();
            model.ID = id;

            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Data = false;
            res.Message = "添加失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Commodity_M", "negativeCommodityCode", param, out data);

            if (!result)
            {
                return Json(res);
            }
            else
            {
                return Content(data, "application/json; charset=utf-8");
            }
        }
        public ActionResult confirmCommodityCode(int id)
        {

            StorageDetail_Model model = new StorageDetail_Model();
            model.ID = id;

            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Data = false;
            res.Message = "添加失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Commodity_M", "confirmCommodityCode", param, out data);

            if (!result)
            {
                return Json(res);
            }
            else
            {
                return Content(data, "application/json; charset=utf-8");
            }
        }
    }
}
