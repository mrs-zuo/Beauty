using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebManager.Controllers.Base;

namespace WebManager.Controllers
{
    public class ServiceController : BaseController
    {
        //
        // GET: /Service/

        public ActionResult GetServiceList()
        {
            int branchID = StringUtils.GetDbInt(QueryString.IntSafeQ("b").ToString(), -1);
            int categoryID = StringUtils.GetDbInt(QueryString.IntSafeQ("c").ToString(), -1);

            UtilityOperation_Model model = new UtilityOperation_Model();

            //总公司可以查看各分店的商品 分公司的只能查看自己分店下的商品
            bool isBranch = this.BranchID > 0;
            model.BranchID = isBranch ? this.BranchID : branchID;
            model.CategoryID = categoryID;
            model.ImageHeight = 70;
            model.ImageWidth = 70;
            model.Type = 0;
            model.Flag = 0;

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);

            string serviceData = "";
            bool comResult = this.GetPostResponseNoRedirect("Service_M", "GetServiceList", param, out serviceData, false);

            string calData = "";
            bool calResult = this.GetPostResponseNoRedirect("Category_M", "getCategoryList", param, out calData, false);

            //if (!(comResult && calResult))
            //{
            //    return Redirect("/");
            //}

            if (!comResult)
            {
                return RedirectUrl(serviceData, "", false);
            }

            if (!calResult)
            {
                return RedirectUrl(calData, "", false);
            }


            ViewBag.CategoryID = categoryID;
            ObjectResult<List<Service_Model>> comObjResult = JsonConvert.DeserializeObject<ObjectResult<List<Service_Model>>>(serviceData);
            ObjectResult<List<CategoryList_Model>> calObjResult = JsonConvert.DeserializeObject<ObjectResult<List<CategoryList_Model>>>(calData);

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
            ViewBag.BranchID = isBranch ? this.BranchID : branchID;
            ViewBag.BranchName = isBranch ? this.BranchName : "";
            ViewBag.ServiceList = comObjResult.Data;
            ViewBag.CategoryList = calObjResult.Data;

            return View();
        }

        public ActionResult EditService()
        {
            long serviceCode = QueryString.LongSafeQ("CD");

            ViewBag.ServiceCode = serviceCode;
            UtilityOperation_Model model = new UtilityOperation_Model();

            //总公司可以查看各分店的商品 分公司的只能查看自己分店下的商品
            model.BranchID = this.BranchID == 0 ? -1 : this.BranchID;
            model.ImageHeight = 500;
            model.ImageWidth = 500;
            model.Type = 0;
            model.Flag = 1;
            model.ServiceCode = serviceCode;

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);

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

            #region 获取图片
            string serData = "";
            bool serResult = this.GetPostResponseNoRedirect("Service_M", "GetServiceDetail", param, out serData, false);

            if (!serResult)
            {
                return RedirectUrl(serData, "", false);
            }

            ObjectResult<Service_Model> serObjResult = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<Service_Model>>(serData);
            ViewBag.ServiceDetail = serObjResult.Data;
            ViewBag.thumbImage = serObjResult.Data.thumbImage;
            ViewBag.BigImageList = serObjResult.Data.BigImageList;
            #endregion

            #region 获取折扣分类
            model.Flag = 0;
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
            #endregion

            #region 获取子服务
            string subData = "";
            bool subResult = this.GetPostResponseNoRedirect("Service_M", "getSubServiceList", param, out subData, false);

            if (!subResult)
            {
                return RedirectUrl(subData, "", false);
            }

            ObjectResult<List<SubService_Model>> subObjResult = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<List<SubService_Model>>>(subData);

            ViewBag.SubserviceList = subObjResult.Data;
            ViewBag.isBranch = this.BranchID > 0;
            #endregion
            return View();
        }

        public ActionResult addService(ServiceDetailOperation_Model model)
        {
            ObjectResult<addProductResult_Model> res = new ObjectResult<addProductResult_Model>();
            res.Data = null;
            res.Message = "添加失败";

            model.Available = true;
            model.CreatorID = this.UserID;
            model.CreateTime = DateTime.Now.ToLocalTime();
            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Service_M", "addService", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");
        }

        public ActionResult updateServiceDetail(ServiceDetailOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Data = false;
            res.Message = "更新失败";

            model.Available = true;
            model.UpdaterID = this.UserID;
            model.UpdateTime = DateTime.Now.ToLocalTime();
            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Service_M", "updateServiceDetail", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");
        }

        public ActionResult downloadService(UtilityOperation_Model model)
        {
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Data = "";
            res.Message = "下载失败";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Service_M", "downloadServiceList", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");

        }

        public ActionResult deteleMultiService(DelMultiCommodity_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Data = false;
            res.Message = "删除失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Service_M", "deteleMultiService", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");
        }

        public ActionResult getServicePrintList(DelMultiCommodity_Model model)
        {
            ObjectResult<List<Service_Model>> res = new ObjectResult<List<Service_Model>>();
            res.Data = null;
            res.Message = "删除失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Service_M", "getPrintList", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");
        }

        public ActionResult EditServiceSort()
        {
            int categoryID = StringUtils.GetDbInt(QueryString.IntSafeQ("c").ToString(), -1);
            UtilityOperation_Model model = new UtilityOperation_Model();
            //总公司可以查看各分店的商品 分公司的只能查看自己分店下的商品
            model.CategoryID = categoryID;
            model.ImageHeight = 500;
            model.ImageWidth = 500;
            model.Type = 0;
            model.Flag = 0;
            model.BranchID = -1;

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);

            string commodityData = "";
            bool comResult = this.GetPostResponseNoRedirect("Service_M", "GetServiceList", param, out commodityData, false);

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
            ObjectResult<List<Service_Model>> comObjResult = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<List<Service_Model>>>(commodityData);
            ObjectResult<List<CategoryList_Model>> calObjResult = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<List<CategoryList_Model>>>(calData);



            ViewBag.ServiceList = comObjResult.Data;
            ViewBag.CategoryList = calObjResult.Data;


            return View();
        }

        public ActionResult UpdateServiceSort(UtilityOperation_Model SortMode)
        {
            string postJson = JsonConvert.SerializeObject(SortMode);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Service_M", "UpdateServiceSort", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }


        public ActionResult OperationServiceBranch(ServiceDetailOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Data = false;
            res.Message = "更新失败";

            model.Available = true;
            model.UpdaterID = this.UserID;
            model.UpdateTime = DateTime.Now.ToLocalTime();
            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Service_M", "OperationServiceBranch", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");
        }

        public ActionResult getCountbyServiceName(ServiceDetailOperation_Model model)
        {
            ObjectResult<int> res = new ObjectResult<int>();
            res.Data = 0;
            res.Message = "服务名称检查失败。";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Service_M", "getCountbyServiceName", param, out data);

            if (!result)
                return Json(res);
            else
                return Content(data, "application/json; charset=utf-8");
        }
    }
}
