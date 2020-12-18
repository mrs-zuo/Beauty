using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebManager.Controllers.Base;

namespace WebManager.Controllers
{
    public class CategoryController : BaseController
    {
        //
        // GET: /Category/

        public ActionResult GetCategoryList()
        {
            int type = StringUtils.GetDbInt(QueryString.IntSafeQ("Type").ToString(), -1);
            int categoryId = StringUtils.GetDbInt(QueryString.IntSafeQ("p").ToString(), -1);

            ViewBag.Type = type;
            ViewBag.CategoryID = categoryId;

            UtilityOperation_Model model = new UtilityOperation_Model();

            model.BranchID = this.BranchID == 0 ? -1 : this.BranchID;
            model.ImageHeight = 500;
            model.ImageWidth = 500;
            model.Type = type;
            model.Flag = 0;
            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);

            string calData = "";
            bool calResult = this.GetPostResponseNoRedirect("Category_M", "getCategoryList", param, out calData, false);

            if (!calResult)
            {
                return RedirectUrl(calData, "", false);
            }

            ObjectResult<List<CategoryList_Model>> calObjResult = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<List<CategoryList_Model>>>(calData);

            ViewBag.isBranch = this.BranchID > 0;
            return View(calObjResult.Data);
        }
        
        public ActionResult EditCategory()
        {
            int categoryID = StringUtils.GetDbInt(QueryString.IntSafeQ("ID").ToString(), -1);
            int type = StringUtils.GetDbInt(QueryString.IntSafeQ("type").ToString(), -1);

            ViewBag.Type = type;
            ViewBag.CategoryID = categoryID;
            UtilityOperation_Model  model = new UtilityOperation_Model();


            //总公司可以查看各分店的商品 分公司的只能查看自己分店下的商品
            #region Param 赋值
            model.BranchID = this.BranchID == 0 ? -1 : this.BranchID;
            model.ImageHeight = 500;
            model.ImageWidth = 500;
            model.Type = type;
            model.Flag = 1;
            model.CategoryID = categoryID;

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


            if (categoryID > 0)
            {
                string catData = "";
                bool catResult = this.GetPostResponseNoRedirect("Category_M", "getCategoryDetail", param, out catData, false);

                if (!catResult)
                {
                    return RedirectUrl(catData, "", false);
                }

                ObjectResult<Category_Model> catObjResult = Newtonsoft.Json.JsonConvert.DeserializeObject < ObjectResult<Category_Model>>(catData);
                ViewBag.CategoryDetail = catObjResult.Data;
            }

            #endregion
            return View(calObjResult.Data);
        }

        public ActionResult addCategory(Category_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Data = false;
            res.Message = "操作失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Category_M", "addCategory", param, out data);

            if (!result)
            {
                return Json(res);
            }
            else
            { 
                return Content(data, "application/json; charset=utf-8");
            }
        }

        public ActionResult UpdateCategory(Category_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Data = false;
            res.Message = "操作失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Category_M", "updateCategory", param, out data);

            if (!result)
            {
                return Json(res);
            }
            else
            { 
                return Content(data, "application/json; charset=utf-8");
            }

        }

        public ActionResult DeleteCategory(UtilityOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Data = false;
            res.Message = "删除失败！";

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string data = "";

            bool result = this.GetPostResponseNoRedirect("Category_M", "deleteCategory", param, out data);

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
