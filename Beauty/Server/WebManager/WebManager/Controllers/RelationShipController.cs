using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.Table_Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Script.Serialization;
using WebManager.Controllers.Base;

namespace WebManager.Controllers
{
    public class RelationShipController : BaseController
    {
        //
        // GET: /RelationShip/

        public ActionResult EditRelationShip()
        {

            bool issuccess = false;
            string data;
            UtilityOperation_Model model = new UtilityOperation_Model();
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

            //string postJson = JsonConvert.SerializeObject(model);

            //data = string.Empty;
            //issuccess = GetPostResponse("RelationShip_M", "GetCustomerList", postJson, out data);

            //if (issuccess)
            //{
            //    ObjectResult<List<Customer_Model>> CustomerList = new ObjectResult<List<Customer_Model>>();
            //    CustomerList = JsonConvert.DeserializeObject<ObjectResult<List<Customer_Model>>>(data);

            //    if (CustomerList.Code == "1") {
            //        ViewBag.CustomerList = CustomerList.Data;
            //    }
            //}

            //data = string.Empty;
            //issuccess = GetPostResponse("RelationShip_M", "GetAccountList", postJson, out data);

            //if (issuccess)
            //{
            //    ObjectResult<List<Account_Model>> AccountList = new ObjectResult<List<Account_Model>>();
            //    AccountList = JsonConvert.DeserializeObject<ObjectResult<List<Account_Model>>>(data);

            //    if (AccountList.Code == "1")
            //    {
            //        ViewBag.AccountList = AccountList.Data;
            //    }
            //}

            return View();
        }

        public ActionResult GetCustomerList(UtilityOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<List<Customer_Model>> res = new ObjectResult<List<Customer_Model>>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("RelationShip_M", "GetCustomerList", postJson, out data);

            if (issuccess)
            {
                //res = JsonConvert.DeserializeObject<ObjectResult<List<Customer_Model>>>(data);
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult GetAccountList(UtilityOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<List<RelationShip_Model>> res = new ObjectResult<List<RelationShip_Model>>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("RelationShip_M", "GetAccountList", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult GetCustomerListByAccountName(UtilityOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<List<Customer_Model>> res = new ObjectResult<List<Customer_Model>>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("RelationShip_M", "GetCustomerListByAccountName", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult GetRelationShipList(UtilityOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<List<RelationShip_Model>> res = new ObjectResult<List<RelationShip_Model>>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("RelationShip_M", "GetRelationShipList", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult ChangeRelationShip(RelationShip_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "更新失败";
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("RelationShip_M", "ChangeRelationShip", postJson, out data);

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
