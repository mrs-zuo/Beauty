using System;
using System.Collections.Generic;
using System.Linq;
using System.Transactions;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using WebMatrix.WebData;
using WebManager.Models;
using WebManager.Controllers.Base;
using Model.Table_Model;
using HS.Framework.Common.Entity;
using Newtonsoft.Json;
using Model.Operation_Model;
using Model.View_Model;
using HS.Framework.Common.Safe;
using HS.Framework.Common.Util;

namespace WebManager.Controllers
{
    public class AccountController : BaseController
    {
        public ActionResult GetAccountList()
        {
            bool issuccess = false;
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.BranchID = StringUtils.GetDbInt(QueryString.IntSafeQ("BranchID").ToString(), -1);
            utilityModel.Available = StringUtils.GetDbInt(QueryString.SafeQ("Available"), -1);
            utilityModel.InputSearch = Server.UrlDecode(Request.QueryString["InputSearch"]);
            string data;
            string postJson = JsonConvert.SerializeObject(utilityModel);
            issuccess = GetPostResponseNoRedirect("Account_M", "GetAccountList", postJson, out data, false);

            ViewBag.loginId = this.UserID;


            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<AccountListForWeb_Model>> res = new ObjectResult<List<AccountListForWeb_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<AccountListForWeb_Model>>>(data);

                if (res.Code == "1")
                {
                    ViewBag.AccountList = res.Data;
                }
            }

            data = "";
            issuccess = false;
            issuccess = GetPostResponseNoRedirect("Account_M", "GetAccountCountInfo", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<AccountInfo_Model> res = new ObjectResult<AccountInfo_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<AccountInfo_Model>>(data);

                if (res.Code == "1")
                {
                    ViewBag.AccountCountInfo = res.Data;
                }
            }


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
                            res.Data.Insert(0, new Branch_Model { BranchName = "总部", ID = 0 });
                            res.Data.Insert(0, new Branch_Model { BranchName = "全部", ID = -1 });
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


            string srtCookie = CookieUtil.GetCookieValue("HSManger", true);
            Cookie_Model cookieModel = new Cookie_Model();
            if (!string.IsNullOrWhiteSpace(srtCookie))
            {
                cookieModel = JsonConvert.DeserializeObject<Cookie_Model>(srtCookie);
            }
            ViewBag.RoleId = cookieModel.RoleID;
            return View();
        }

        public ActionResult EditAccount()
        {

            bool issuccess = false;
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.ID = StringUtils.GetDbInt(QueryString.IntSafeQ("UserID").ToString(), -1);
            ViewBag.BranchFlag = StringUtils.GetDbInt(QueryString.IntSafeQ("BranchSelect").ToString(), 0);
            string data;
            string postJson = JsonConvert.SerializeObject(utilityModel);
            issuccess = GetPostResponseNoRedirect("Account_M", "GetAccountDetail", postJson, out data, false);


            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<Account_Model> res = new ObjectResult<Account_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<Account_Model>>(data);

                if (res.Code == "1")
                {
                    ViewBag.Account = res.Data;
                    ImageCommon_Model model = new ImageCommon_Model();
                    model.FileUrl = res.Data.HeadImageFile;
                    ViewBag.thumbImage = model;
                    ViewBag.BranchSelection = res.Data.BranchList;
                    ViewBag.TabsList = res.Data.TagsList;
                }
            }
            string srtCookie = CookieUtil.GetCookieValue("HSManger", true);
            Cookie_Model cookieModel = new Cookie_Model();
            if (!string.IsNullOrWhiteSpace(srtCookie))
            {
                cookieModel = JsonConvert.DeserializeObject<Cookie_Model>(srtCookie);
            }
            ViewBag.Cookie = cookieModel;

            return View();
        }



        public ActionResult UpdateAccount(Account_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            res.Message = "修改失败";
            issuccess = GetPostResponseNoRedirect("Account_M", "UpdateAccount", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult AddAccount(Account_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<int> res = new ObjectResult<int>();
            bool issuccess = false;
            res.Message = "新增失败";
            issuccess = GetPostResponseNoRedirect("Account_M", "AddAccount", postJson, out data);


            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }



        public ActionResult IsExsitAccountNameInCompany(Account_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("Account_M", "IsExsitAccountNameInCompany", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult IsExsitAccountMobileInCompany(Account_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("Account_M", "IsExsitAccountMobileInCompany", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult AccountHierarchy()
        {
            bool issuccess = false;
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.UserID = StringUtils.GetDbInt(QueryString.IntSafeQ("UserID").ToString(), -1);
            utilityModel.Type = StringUtils.GetDbInt(QueryString.IntSafeQ("Type").ToString(), 0);

            string data;
            string postJson = JsonConvert.SerializeObject(utilityModel);
            issuccess = GetPostResponseNoRedirect("Account_M", "GetHierarchyList", postJson, out data, false);


            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<Hierarchy_Model>> res = new ObjectResult<List<Hierarchy_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<Hierarchy_Model>>>(data);

                if (res.Code == "1")
                {
                    ViewBag.AccountList = res.Data;
                }
            }


            utilityModel.UserID = -1;
            postJson = JsonConvert.SerializeObject(utilityModel);
            issuccess = GetPostResponseNoRedirect("Account_M", "GetHierarchyList", postJson, out data);

            if (!issuccess)
            {
                return RedirectUrl(data, "");
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<Hierarchy_Model>> res = new ObjectResult<List<Hierarchy_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<Hierarchy_Model>>>(data);

                if (res.Code == "1")
                {
                    ViewBag.SelectList = res.Data;
                }
            }

            string srtCookie = CookieUtil.GetCookieValue("HSManger", true);
            Cookie_Model cookieModel = new Cookie_Model();
            if (!string.IsNullOrWhiteSpace(srtCookie))
            {
                cookieModel = JsonConvert.DeserializeObject<Cookie_Model>(srtCookie);
            }
            ViewBag.LoginID = cookieModel.US;
            return View();
        }



        public ActionResult EditAccountHierarchy()
        {
            bool issuccess = false;
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.ID = StringUtils.GetDbInt(QueryString.IntSafeQ("hID").ToString(), -1);
            utilityModel.UserID = -1;

            int SubId = -1;
            string data;
            string postJson = JsonConvert.SerializeObject(utilityModel);
            issuccess = GetPostResponseNoRedirect("Account_M", "GetHierarchyDetail", postJson, out data, false);


            if (!issuccess)
            {
                return RedirectUrl(data, "");
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<Hierarchy_Model> res = new ObjectResult<Hierarchy_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<Hierarchy_Model>>(data);

                if (res.Code == "1")
                {
                    SubId = res.Data.SubordinateID;
                    ViewBag.Hierarchy = res.Data;
                }
            }

            issuccess = GetPostResponseNoRedirect("Account_M", "GetHierarchyList", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<Hierarchy_Model>> res = new ObjectResult<List<Hierarchy_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<Hierarchy_Model>>>(data);

                if (res.Code == "1")
                {
                    List<Hierarchy_Model> list = new List<Hierarchy_Model>();
                    int tempLevel = -1;
                    foreach (Hierarchy_Model item in res.Data)
                    {
                        if (item.SubordinateID == SubId)
                        {
                            tempLevel = item.Level;
                            continue;
                        }

                        if (tempLevel == -1 || item.Level <= tempLevel)
                        {
                            tempLevel = -1;
                            list.Add(item);
                        }


                    }
                    ViewBag.SelectList = list;
                }
            }

            return View();
        }

        public ActionResult OperationHierarchy(Hierarchy_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("Account_M", "UpdateHierarchy", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }



        public ActionResult AccountPassword()
        {
            ViewBag.UserID = StringUtils.GetDbInt(QueryString.IntSafeQ("UserID").ToString(), -1);
            return View();
        }

        public ActionResult ResetPassword(Account_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("Account_M", "ResetPassword", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult GetAccountGroupList()
        {
            bool issuccess = false;
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.Type = 2;
            string data;
            string postJson = JsonConvert.SerializeObject(utilityModel);
            issuccess = GetPostResponseNoRedirect("Tag_M", "GetTagList", postJson, out data, false);

            ObjectResult<List<TagList_Model>> res = new ObjectResult<List<TagList_Model>>();

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                res = JsonConvert.DeserializeObject<ObjectResult<List<TagList_Model>>>(data);

                if (res.Code == "1")
                {
                    ViewBag.AccountList = res.Data;
                }
            }

            return View(res.Data);
        }

        public ActionResult EditAccountGroup()
        {
            int tagID = QueryString.IntSafeQ("ID", 0);
            if (tagID >= 0)
            {
                ViewBag.IsAdd = true;
            }
            else
            {

            }
            bool issuccess = false;
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.Type = 2;
            utilityModel.ID = tagID;
            string data;
            string postJson = JsonConvert.SerializeObject(utilityModel);
            issuccess = GetPostResponseNoRedirect("Tag_M", "GetTagDetail", postJson, out data, false);

            ObjectResult<TagDetailForWeb_Model> res = new ObjectResult<TagDetailForWeb_Model>();

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                res = JsonConvert.DeserializeObject<ObjectResult<TagDetailForWeb_Model>>(data);
            }
            return View(res.Data);
        }

        public ActionResult AddTag(TagDetailForWeb_Model addTag)
        {
            string postJson = JsonConvert.SerializeObject(addTag);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = GetPostResponseNoRedirect("Tag_M", "AddTag", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult UpdateTag(TagDetailForWeb_Model updateTag)
        {
            string postJson = JsonConvert.SerializeObject(updateTag);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = GetPostResponseNoRedirect("Tag_M", "EditTag", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult DeleteTag(TagOperation_Model TagModel)
        {
            string postJson = JsonConvert.SerializeObject(TagModel);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Tag_M", "DeleteTag", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult GetAccountListUsedByGroup()
        {
            string data = string.Empty;
            ObjectResult<List<GetAccountListByGroupFroWeb_Model>> res = new ObjectResult<List<GetAccountListByGroupFroWeb_Model>>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("Account_M", "GetAccountListUserByGroup", "", out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult IsCanAddAccount()
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "操作失败";
            bool issuccess = false;

            string data = string.Empty;
            issuccess = GetPostResponseNoRedirect("Account_M", "IsCanAddAccount", "", out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }



        public ActionResult CanDeleteAccount(int UserID)
        {
            Account_Model mAcc = new Account_Model();
            mAcc.UserID = UserID;
            string postJson = JsonConvert.SerializeObject(mAcc);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "操作失败";
            bool issuccess = false;

            issuccess = GetPostResponseNoRedirect("Account_M", "CanDeleteAccount", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }


        public ActionResult OperationBranchSelect(AccountBranchOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            res.Message = "操作失败";
            issuccess = GetPostResponseNoRedirect("Account_M", "BranchSelect", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult AccountBranchCheck(UtilityOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("Account_M", "CheckAccountBranchCancel", postJson, out data);


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
