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
    public class RoleController : BaseController
    {
        public ActionResult GetRoleList()
        {
            List<Role_Model> list = new List<Role_Model>();
            string data = "";
            bool issuccess = GetPostResponseNoRedirect("Role_M", "GetRoleList", "", out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<Role_Model>> res = new ObjectResult<List<Role_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<Role_Model>>>(data);

                if (res.Code == "1")
                {
                    list = res.Data;
                }
            }
            return View(list);
        }

        public ActionResult EditRole()
        {
            int roleID = QueryString.IntSafeQ("ID", 0);
            bool isAdd = false;

            if (roleID <= 0)
            {
                isAdd = true;
            }

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.Advanced = this.Advanced;
            utilityModel.ID = roleID;
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            ViewBag.noticeModel = null;
            bool issuccess = GetPostResponseNoRedirect("Role_M", "GetRoleDetail", postJson, out data, false);
            List<Jurisdiction_Model> list = new List<Jurisdiction_Model>();
            Role_Model model = new Role_Model();
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);  
            }
            
            if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<Role_Model> res = new ObjectResult<Role_Model>();
                    res = JsonConvert.DeserializeObject<ObjectResult<Role_Model>>(data);

                    if (res.Code == "1")
                    {
                        model = res.Data;
                    }
                }
            ViewBag.IsAdd = isAdd;
            ViewBag.RoleID = roleID;
            return View(model);
        }

        public ActionResult AddRole(Role_Model RoleModel)
        {
            string postJson = JsonConvert.SerializeObject(RoleModel);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "新增失败";
            bool issuccess = GetPostResponseNoRedirect("Role_M", "AddRole", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult UpdateRole(Role_Model RoleModel)
        {
            string postJson = JsonConvert.SerializeObject(RoleModel);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Role_M", "EditRole", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult DeleteRole(UtilityOperation_Model RoleModel)
        {
            string postJson = JsonConvert.SerializeObject(RoleModel);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Role_M", "DeleteRole", postJson, out data);
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
