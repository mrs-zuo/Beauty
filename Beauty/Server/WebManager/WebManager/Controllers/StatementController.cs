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
using WebManager.Controllers.Base;

namespace WebManager.Controllers
{
    public class StatementController : BaseController
    {


        public ActionResult GetStatementList()
        {
            string data;
            bool issuccess = GetPostResponseNoRedirect("Statement_M", "GetStatementCategoryList", "", out data, false);
            List<StatementCategory_Model> list = null;
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);  
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<StatementCategory_Model>> res = new ObjectResult<List<StatementCategory_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<StatementCategory_Model>>>(data);

                if (res.Code == "1")
                {
                    list = new List<StatementCategory_Model>();
                    list = res.Data;
                }
            }

            if (this.BranchID == 0)
            {
                ViewBag.isAdd = true;
            }
            else {
                ViewBag.isAdd = false;
            }
            return View(list);
        }

        public ActionResult EditStatement()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.CategoryID = StringUtils.GetDbInt(QueryString.IntSafeQ("sc").ToString(), -1);
            string postJson = JsonConvert.SerializeObject(utilityModel);
            string data;
            bool issuccess = GetPostResponseNoRedirect("Statement_M", "GetStatementCategoryDetail", postJson, out data, false);
            StatementCategory_Model model = null;
            if (utilityModel.CategoryID > 0)
            {
                if (!issuccess)
                {
                    return RedirectUrl(data, "", false);
                }
                if (!string.IsNullOrEmpty(data))
                    {
                        ObjectResult<StatementCategory_Model> res = new ObjectResult<StatementCategory_Model>();
                        res = JsonConvert.DeserializeObject<ObjectResult<StatementCategory_Model>>(data);

                        if (res.Code == "1")
                        {
                            model = new StatementCategory_Model();
                            model = res.Data;
                        }
                    }
            }
            else 
            {
                model = new StatementCategory_Model();
            }
            return View(model);
        }

        public ActionResult GetProductCategoryList(int ProductType)
        {
            ObjectResult<List<CategoryList_Model>> res = new ObjectResult<List<CategoryList_Model>>();
            UtilityOperation_Model model = new UtilityOperation_Model();
            model.Type = ProductType;
            string postJson = JsonConvert.SerializeObject(model);
            string data = "";
            bool issuccess = GetPostResponseNoRedirect("Category_M", "getCategoryList", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }

        }

        public ActionResult GetProductList(int ProductType ,int CategoryID)
        {
            ObjectResult<List<GetProductList_Model>> res = new ObjectResult<List<GetProductList_Model>>();
            UtilityOperation_Model model = new UtilityOperation_Model();
            model.ProductType = ProductType;
            model.CategoryID = CategoryID;
            string postJson = JsonConvert.SerializeObject(model);
            string data = "";
            bool issuccess ;
            issuccess = GetPostResponseNoRedirect("Statement_M", "GetProductList", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }


        public ActionResult ControlStatement(StatementCategory_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
          
            string postJson = JsonConvert.SerializeObject(model);
            string data = "";
            bool issuccess = GetPostResponseNoRedirect("Statement_M", "EditStatement", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }

        }
        public ActionResult DeleteStatement(int ID)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            UtilityOperation_Model model = new UtilityOperation_Model();
            model.ID = ID;
            string postJson = JsonConvert.SerializeObject(model);
            string data = "";
            bool issuccess = GetPostResponseNoRedirect("Statement_M", "DeleteStatement", postJson, out data);
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
