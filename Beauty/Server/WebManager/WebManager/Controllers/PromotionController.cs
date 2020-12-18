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
using WebManager.Models;

namespace WebManager.Controllers
{
    public class PromotionController : BaseController
    {
        public ActionResult GetPromotionList()
        {
            int viewType = QueryString.IntSafeQ("viewtype", 0);
            int flag = QueryString.IntSafeQ("flag", 0);
            int branchID = QueryString.IntSafeQ("branchID", this.BranchID);
            ViewBag.viewType = viewType;
            ViewBag.LoginBranchID = this.BranchID;
            bool issuccess = false;
            string data = "";

            #region 获取公司下门店列表
            if (this.BranchID == 0)
            {
                issuccess = GetPostResponseNoRedirect("Branch_M", "GetBranchListForWeb", "", out data, false);
                if (!issuccess)
                {
                    return RedirectUrl(data, "", false);
                }

                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<List<Branch_Model>> res = new ObjectResult<List<Branch_Model>>();
                    res = JsonConvert.DeserializeObject<ObjectResult<List<Branch_Model>>>(data);

                    if (res.Code == "1")
                    {
                        if (res.Data != null && res.Data.Count > 0)
                        {
                            res.Data.Insert(0, new Branch_Model { BranchName = "全部", ID = 0 });
                        }

                        if (this.BranchID != 0)
                        {
                            res.Data = res.Data.Where(c => c.ID == this.BranchID).ToList();
                        }

                        ViewBag.BranchList = res.Data;
                    }
                }
            }
            else
            {
                List<Branch_Model> branchlist = new List<Branch_Model>();
                branchlist.Add(new Branch_Model { BranchName = this.BranchName, ID = this.BranchID });
                ViewBag.BranchList = branchlist;
            }

            #endregion

            List<Promotion_Model> list = new List<Promotion_Model>();
            #region 获取PromotionList
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.Flag = flag;
            if (this.BranchID == 0)
            {
                utilityModel.BranchID = branchID;
            }
            else
            {
                utilityModel.BranchID = this.BranchID;
            }

            string postJson = JsonConvert.SerializeObject(utilityModel);
            issuccess = GetPostResponseNoRedirect("Promotion_M", "GetPromotionList", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<Promotion_Model>> res = new ObjectResult<List<Promotion_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<Promotion_Model>>>(data);

                if (res.Code == "1")
                {
                    list = res.Data;
                }
            }
            #endregion

            if (list != null && list.Count > 0)
            {
                List<Promotion_Model> imgList = new List<Promotion_Model>();
                imgList = list.Where(c => c.Type == 0).ToList();

                List<Promotion_Model> textList = new List<Promotion_Model>();
                textList = list.Where(c => c.Type == 1).ToList();

                ViewBag.ImgList = imgList;
                ViewBag.TextList = textList;
            }

            return View();
        }

        public ActionResult EditPromotion()
        {
            int promotionID = QueryString.IntSafeQ("ID", 0);
            int viewType = QueryString.IntSafeQ("viewtype", 0);
            int active = QueryString.IntSafeQ("active", 0);
            bool isAdd = true;
            ViewBag.BranchID = this.BranchID;
            ViewBag.viewType = viewType;
            ViewBag.active = active;
            if (promotionID > 0)
            {
                isAdd = false;
            }

            Promotion_Model model = new Promotion_Model();
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.ID = promotionID;
            string data;
            string postJson = JsonConvert.SerializeObject(utilityModel);
            bool issuccess = GetPostResponseNoRedirect("Promotion_M", "GetPromotionDetail", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<Promotion_Model> res = new ObjectResult<Promotion_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<Promotion_Model>>(data);
                if (res.Code == "1")
                {
                    model = res.Data;
                    ViewBag.BranchSelection = model.BranchList;
                    if (this.BranchID != 0)
                    {
                        List<BranchSelection_Model> branchlist = new List<BranchSelection_Model>();
                        branchlist = res.Data.BranchList.Where(c => c.BranchID == this.BranchID).ToList();
                        ViewBag.BranchSelection = branchlist;
                    }

                    Model.Table_Model.ImageCommon_Model thumbImage = new Model.Table_Model.ImageCommon_Model();
                    thumbImage.FileUrl = model.PromotionImgUrl;
                    ViewBag.thumbImage = thumbImage;
                }
            }
            ViewBag.IsAdd = isAdd;

            return View(model);
        }

        public ActionResult AddPromotion(Promotion_Model AddPromotion)
        {
            string postJson = JsonConvert.SerializeObject(AddPromotion);
            string data = string.Empty;
            ObjectResult<int> res = new ObjectResult<int>();
            res.Message = "新增失败";
            bool issuccess = GetPostResponseNoRedirect("Promotion_M", "AddPromotion", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult UpdatePromotion(Promotion_Model AddPromotion)
        {
            string postJson = JsonConvert.SerializeObject(AddPromotion);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Promotion_M", "EditPromotion", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult DeletePromotion(Promotion_Model AddPromotion)
        {
            string postJson = JsonConvert.SerializeObject(AddPromotion);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Promotion_M", "DeletePromotion", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }


        #region 新版本
        public ActionResult GetPromotionListNew()
        {
            int viewType = QueryString.IntSafeQ("viewtype", 0);
            int flag = QueryString.IntSafeQ("flag", 0);
            int branchID = QueryString.IntSafeQ("branchID", this.BranchID);
            ViewBag.viewType = viewType;
            ViewBag.LoginBranchID = this.BranchID;
            bool issuccess = false;
            string data = "";

            #region 获取公司下门店列表
            if (this.BranchID == 0)
            {
                issuccess = GetPostResponseNoRedirect("Branch_M", "GetBranchListForWeb", "", out data, false);
                if (!issuccess)
                {
                    return RedirectUrl(data, "", false);
                }

                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<List<Branch_Model>> res = new ObjectResult<List<Branch_Model>>();
                    res = JsonConvert.DeserializeObject<ObjectResult<List<Branch_Model>>>(data);

                    if (res.Code == "1")
                    {
                        if (res.Data != null && res.Data.Count > 0)
                        {
                            res.Data.Insert(0, new Branch_Model { BranchName = "全部", ID = 0 });
                        }

                        if (this.BranchID != 0)
                        {
                            res.Data = res.Data.Where(c => c.ID == this.BranchID).ToList();
                        }

                        ViewBag.BranchList = res.Data;
                    }
                }
            }
            else
            {
                List<Branch_Model> branchlist = new List<Branch_Model>();
                branchlist.Add(new Branch_Model { BranchName = this.BranchName, ID = this.BranchID });
                ViewBag.BranchList = branchlist;
            }

            #endregion

            List<New_Promotion_Model> list = new List<New_Promotion_Model>();
            #region 获取PromotionList
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.Flag = flag;
            if (this.BranchID == 0)
            {
                utilityModel.BranchID = branchID;
            }
            else
            {
                utilityModel.BranchID = this.BranchID;
            }

            string postJson = JsonConvert.SerializeObject(utilityModel);
            issuccess = GetPostResponseNoRedirect("Promotion_M", "GetPromotionList_NEW", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<New_Promotion_Model>> res = new ObjectResult<List<New_Promotion_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<New_Promotion_Model>>>(data);

                if (res.Code == "1")
                {
                    list = res.Data;
                }
            }

            #endregion

            ViewBag.PromotionList = list;


            return View();
        }

        public ActionResult EditPromotionNew()
        {
            string promotionCode = QueryString.SafeQ("cd");


            int active = QueryString.IntSafeQ("active", 0);
            ViewBag.active = active;
            bool isAdd = true;
            ViewBag.BranchID = this.BranchID;
            if (promotionCode != "" && promotionCode != null)
            {
                isAdd = false;
            }

            New_Promotion_Model model = new New_Promotion_Model();
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.PromotionCode = promotionCode;
            string data;
            string postJson = JsonConvert.SerializeObject(utilityModel);
            bool issuccess = GetPostResponseNoRedirect("Promotion_M", "GetPromotionDetail_NEW", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<New_Promotion_Model> res = new ObjectResult<New_Promotion_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<New_Promotion_Model>>(data);
                if (res.Code == "1")
                {
                    model = res.Data;
                    if (!string.IsNullOrEmpty(model.Description))
                    {
                        model.Description = model.Description.Replace("</br>", "\n");
                    }
                    ViewBag.BranchSelection = model.BranchList;
                    if (this.BranchID != 0)
                    {
                        List<BranchSelection_Model> branchlist = new List<BranchSelection_Model>();
                        branchlist = res.Data.BranchList.Where(c => c.BranchID == this.BranchID).ToList();
                        ViewBag.BranchSelection = branchlist;
                    }

                    Model.Table_Model.ImageCommon_Model thumbImage = new Model.Table_Model.ImageCommon_Model();
                    thumbImage.FileUrl = model.PromotionImgUrl;
                    ViewBag.thumbImage = thumbImage;
                }
            }

            ViewBag.IsAdd = isAdd;

            return View(model);
        }

        public ActionResult UpdatePromotion_New(New_Promotion_Model model)
        {
            if (!string.IsNullOrEmpty(model.Description))
            {
                model.Description = model.Description.Replace("\n", "</br>").Replace("\r\n", "</br>");
            }
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<string> res = new ObjectResult<string>();
            res.Message = "新增失败";
            bool issuccess;
            if (model.PromotionCode == "" || model.PromotionCode == null)
            {
                issuccess = GetPostResponseNoRedirect("Promotion_M", "AddPromotion_New", postJson, out data);
            }
            else
            {
                issuccess = GetPostResponseNoRedirect("Promotion_M", "EditPromotion_New", postJson, out data);
            }

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult DeletePromotion_NEW(Promotion_Model AddPromotion)
        {
            string postJson = JsonConvert.SerializeObject(AddPromotion);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Promotion_M", "DeletePromotion", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        #endregion



        public ActionResult OperationBranchSelect(BranchSelectOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            res.Message = "操作失败";
            issuccess = GetPostResponseNoRedirect("Promotion_M", "BranchSelect", postJson, out data);


            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }


        public ActionResult GetPromotionProductList()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.PromotionCode = QueryString.SafeQ("pc");
            utilityModel.Flag = QueryString.IntSafeQ("f");
            ViewBag.PromotionCode = utilityModel.PromotionCode;
            string postJson = JsonConvert.SerializeObject(utilityModel);
            string data = string.Empty;
            List<PromotoinProduct_Model> list = new List<PromotoinProduct_Model>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("Promotion_M", "GetPromotionProductList", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            ObjectResult<List<PromotoinProduct_Model>> res = new ObjectResult<List<PromotoinProduct_Model>>();
            res = JsonConvert.DeserializeObject<ObjectResult<List<PromotoinProduct_Model>>>(data);
            if (res.Code == "1")
            {
                list = res.Data;
            }

            return View(list);
        }

        public ActionResult SelectPromotionProduct()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.PromotionCode = QueryString.SafeQ("pc");
            utilityModel.ProductType = QueryString.IntSafeQ("pt");
            ViewBag.PromotionCode = utilityModel.PromotionCode;
            ViewBag.ProductType = utilityModel.ProductType;
            string postJson = JsonConvert.SerializeObject(utilityModel);
            string data = string.Empty;
            List<PromotoinProduct_Model> list = new List<PromotoinProduct_Model>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("Promotion_M", "GetPromotionProductSelect", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            ObjectResult<List<PromotoinProduct_Model>> res = new ObjectResult<List<PromotoinProduct_Model>>();
            res = JsonConvert.DeserializeObject<ObjectResult<List<PromotoinProduct_Model>>>(data);
            if (res.Code == "1")
            {
                list = res.Data;
            }

            return View(list);
        }

        public ActionResult EditPromotionProduct()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.PromotionCode = QueryString.SafeQ("pc");
            utilityModel.ProductType = QueryString.IntSafeQ("pt");
            PromotoinProduct_Model model = null;
            string data = string.Empty;
            int isAdd = QueryString.IntSafeQ("a");
            bool issuccess = false;
            if (isAdd == 1)
            {
                utilityModel.ProductCode = StringUtils.GetDbLong(QueryString.SafeQ("pcd"));
                string postJson = JsonConvert.SerializeObject(utilityModel);
                issuccess = GetPostResponseNoRedirect("Promotion_M", "GetPromotionProductDetailAdd", postJson, out data, false);
            }
            else
            {
                utilityModel.ID = QueryString.IntSafeQ("pi");
                string postJson = JsonConvert.SerializeObject(utilityModel);
                issuccess = GetPostResponseNoRedirect("Promotion_M", "GetPromotionProductDetailEdit", postJson, out data, false);
            }


            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            ObjectResult<PromotoinProduct_Model> res = new ObjectResult<PromotoinProduct_Model>();
            res = JsonConvert.DeserializeObject<ObjectResult<PromotoinProduct_Model>>(data);
            if (res.Code == "1")
            {
                model = new PromotoinProduct_Model();
                model = res.Data;
            }

            ViewBag.PromotionCode = utilityModel.PromotionCode;
            ViewBag.IsAdd = isAdd;
            return View(model);
        }

        public ActionResult SubmitPromotionProduct(PromotoinProduct_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "处理失败";

            bool issuccess = false;
            if (model.IsAdd == 1)
            {
                issuccess = GetPostResponseNoRedirect("Promotion_M", "addPromotionProduct", postJson, out data);
            }
            else
            {
                issuccess = GetPostResponseNoRedirect("Promotion_M", "UpdatePromotionProduct", postJson, out data);
            }
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }



        public ActionResult PromotionSaleDetail()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.PromotionCode = QueryString.SafeQ("pc");
            List<PromotionSale_Model> list = null;
            string data = string.Empty;
            string postJson = JsonConvert.SerializeObject(utilityModel);
            bool issuccess = GetPostResponseNoRedirect("Promotion_M", "GetPromotionSaleDetail", postJson, out data);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            ObjectResult<List<PromotionSale_Model>> res = new ObjectResult<List<PromotionSale_Model>>();
            res = JsonConvert.DeserializeObject<ObjectResult<List<PromotionSale_Model>>>(data);
            if (res.Code == "1")
            {
                list = new List<PromotionSale_Model>();
                list = res.Data;
            }

            return View(list);
        }

        public ActionResult DeletePromotionProduct(PromotoinProduct_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "处理失败";

            bool issuccess = GetPostResponseNoRedirect("Promotion_M", "DeletePromotionProduct", postJson, out data);

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
