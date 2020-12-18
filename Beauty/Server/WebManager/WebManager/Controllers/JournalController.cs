using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
using HS.Framework.Common.Util;
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
    public class JournalController : BaseController
    {
        public ActionResult JournalList(Journal_Account_Search_Model model)
        {
            bool issuccess = false;
            string data;
            string hiddenItemName = Server.UrlDecode(Request.QueryString["hname"]);
            int hiddenBranchID = StringUtils.GetDbInt(QueryString.IntSafeQ("hbid").ToString(), -1);
            string hiddenStartDate = QueryString.SafeQ("hsd").ToString();
            string hiddenEndDate = QueryString.SafeQ("hed").ToString();
            int hiddenInOutType = StringUtils.GetDbInt(QueryString.IntSafeQ("htp").ToString(), 0);
            Journal_Account_Search_Model utilityModel = new Journal_Account_Search_Model();
            utilityModel.BranchID = hiddenBranchID;
            utilityModel.StartDate = hiddenStartDate;
            utilityModel.EndDate = hiddenEndDate;
            utilityModel.ItemName = hiddenItemName;
            utilityModel.InOutType = hiddenInOutType;
            ViewBag.SearchAccountModel = utilityModel;

            #region 获取公司下门店列表
            if (this.BranchID == 0)
            {
                issuccess = GetPostResponseNoRedirect("Branch_M", "getBranchAvailableList", "", out data);
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
                            //res.Data.Insert(0, new Branch_Model { BranchName = "总部", ID = 0 });
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

            return View();
        }

        public ActionResult GetSearchAccountList(Journal_Account_Search_Model model) {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<List<Journal_Account_New_Model>> res = new ObjectResult<List<Journal_Account_New_Model>>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("Journal_M", "GetJournalList", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }
        public ActionResult EditJournal()
        {
            bool issuccess = false;
            Journal_Account_Search_Model utilityModel = new Journal_Account_Search_Model();
            utilityModel.ID = StringUtils.GetDbInt(QueryString.IntSafeQ("jd").ToString(), -1);
            int EditFlag = StringUtils.GetDbInt(QueryString.IntSafeQ("e").ToString(), 0);
            int InOutType = StringUtils.GetDbInt(QueryString.IntSafeQ("InOutType").ToString(), 0);
            string hiddenItemName = Server.UrlDecode(Request.QueryString["hname"]);
            int hiddenBranchID = StringUtils.GetDbInt(QueryString.IntSafeQ("hbid").ToString(), -1);
            string hiddenStartDate = QueryString.SafeQ("hsd").ToString();
            string hiddenEndDate = QueryString.SafeQ("hed").ToString();
            int hiddenInOutType = StringUtils.GetDbInt(QueryString.IntSafeQ("htp").ToString(), 0);
            ViewBag.EditFlag = EditFlag;
            ViewBag.InOutType = InOutType;

            utilityModel.BranchID = hiddenBranchID;
            utilityModel.StartDate = hiddenStartDate;
            utilityModel.EndDate = hiddenEndDate;
            utilityModel.ItemName = hiddenItemName;
            utilityModel.InOutType = hiddenInOutType;

            ViewBag.SearchAccountModel = utilityModel;

            string data;
            string postJson = JsonConvert.SerializeObject(utilityModel);
            issuccess = GetPostResponseNoRedirect("Journal_M", "GetJournalDetail", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<JournalAccountOperation_Model> res = new ObjectResult<JournalAccountOperation_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<JournalAccountOperation_Model>>(data);

                ViewBag.Journal = res.Data;
            }


            #region 获取公司下门店列表
            data = "";
            issuccess = false;
            if (this.BranchID == 0)
            {
                issuccess = GetPostResponseNoRedirect("Branch_M", "getBranchAvailableList", "", out data);
                if (!issuccess)
                {
                    return RedirectUrl(data, "", false);
                }

                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<List<Branch_Model>> res = new ObjectResult<List<Branch_Model>>();
                    res = JsonConvert.DeserializeObject<ObjectResult<List<Branch_Model>>>(data);

                    ViewBag.BranchList = res.Data;
                }
            }
            else
            {
                List<Branch_Model> branchlist = new List<Branch_Model>();
                branchlist.Add(new Branch_Model { BranchName = this.BranchName, ID = this.BranchID });
                ViewBag.BranchList = branchlist;
            }

            #endregion

            return View();
        }

        public ActionResult DeleteJournal(int ID)
        {
            JournalAccountOperation_Model model = new JournalAccountOperation_Model();
            model.ID = ID;
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "删除失败";

            bool issuccess = GetPostResponseNoRedirect("Journal_M", "DeleteJournal", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult GetOperatorList(Journal_Account_Search_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "获取操作人列表失败";

            bool issuccess = GetPostResponseNoRedirect("Journal_M", "GetOperatorList", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        //获取金额默认值
        public ActionResult GetDefaultAMount(Journal_Account_Defult_Amount_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "";

            bool issuccess = GetPostResponseNoRedirect("Journal_M", "GetDefaultAMount", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult OperateJournal(JournalAccountOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "操作失败";

            
            bool issuccess = false;

            if (model.ID == 0)
            {
                res.Message = "添加失败";
                issuccess = GetPostResponseNoRedirect("Journal_M", "AddJournal", postJson, out data);
            }
            else {
                res.Message = "更新失败";
                issuccess = GetPostResponseNoRedirect("Journal_M", "UpdateJournal", postJson, out data);
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

    }
}
