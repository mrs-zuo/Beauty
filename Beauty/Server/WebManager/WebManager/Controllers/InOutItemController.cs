using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.Table_Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebManager.Controllers.Base;

namespace WebManager.Controllers
{
    public class InOutItemController : BaseController
    {
        public ActionResult GetInOutItemList() {
            return View();
        }
        /// <summary>
        /// 获取公司下面所有大项目
        /// </summary>
        /// <param name="CompanyID">公司ID</param>
        /// <returns></returns>
        public ActionResult GetInOutItemAList(InOutItemA_Model model)
        {
            //string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<List<InOutItemA_Model>> res = new ObjectResult<List<InOutItemA_Model>>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("InOutItem_M", "GetInOutItemAList", null, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }
        /// <summary>
        /// 获取大项目下面所有中项目
        /// </summary>
        /// <param name="ItemAID">大项目ID</param>
        /// <returns></returns>
        public ActionResult GetInOutItemBList(InOutItemB_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<List<InOutItemB_Model>> res = new ObjectResult<List<InOutItemB_Model>>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("InOutItem_M", "GetInOutItemBList", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }
        /// <summary>
        /// 获取中项目下面所有小项目
        /// </summary>
        /// <param name="ItemBID">中项目ID</param>
        /// <returns></returns>
        public ActionResult GetInOutItemCList(InOutItemC_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<List<InOutItemC_Model>> res = new ObjectResult<List<InOutItemC_Model>>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("InOutItem_M", "GetInOutItemCList", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }
        /// <summary>
        /// 添加大项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public ActionResult AddInOutItemA(InOutItemAOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "添加失败";
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            bool issuccess = GetPostResponseNoRedirect("InOutItem_M", "AddInOutItemA", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }
        /// <summary>
        /// 更新大项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public ActionResult UpdateInOutItemA(InOutItemAOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            bool issuccess = GetPostResponseNoRedirect("InOutItem_M", "UpdateInOutItemA", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }
        /// <summary>
        /// 添加中项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public ActionResult AddInOutItemB(InOutItemBOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "添加失败";
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            bool issuccess = GetPostResponseNoRedirect("InOutItem_M", "AddInOutItemB", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }
        /// <summary>
        /// 更新中项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public ActionResult UpdateInOutItemB(InOutItemBOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            bool issuccess = GetPostResponseNoRedirect("InOutItem_M", "UpdateInOutItemB", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }
        /// <summary>
        /// 添加小项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public ActionResult AddInOutItemC(InOutItemCOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "添加失败";
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            bool issuccess = GetPostResponseNoRedirect("InOutItem_M", "AddInOutItemC", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }
        /// <summary>
        /// 更新小项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public ActionResult UpdateInOutItemC(InOutItemCOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            bool issuccess = GetPostResponseNoRedirect("InOutItem_M", "UpdateInOutItemC", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }
        /// <summary>
        /// 删除大项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public ActionResult DeleteInOutItemA(InOutItemAOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "删除失败";
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            bool issuccess = GetPostResponseNoRedirect("InOutItem_M", "DeleteInOutItemA", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }
        /// <summary>
        /// 删除中项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public ActionResult DeleteInOutItemB(InOutItemBOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "删除失败";
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            bool issuccess = GetPostResponseNoRedirect("InOutItem_M", "DeleteInOutItemB", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }
        /// <summary>
        /// 删除小项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public ActionResult DeleteInOutItemC(InOutItemCOperation_Model model)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "删除失败";
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            bool issuccess = GetPostResponseNoRedirect("InOutItem_M", "DeleteInOutItemC", postJson, out data);
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