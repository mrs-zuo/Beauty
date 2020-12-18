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
    public class BenefitController : BaseController
    {
        //
        // GET: /Benefit/

        public ActionResult GetBenefitList()
        {

            string data = "";
            bool issuccess = false;
            int branchID = QueryString.IntSafeQ("bId", this.BranchID);

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
            data = "";
            issuccess = false;
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            if (this.BranchID == 0)
            {
                utilityModel.BranchID = branchID;
            }
            else
            {
                utilityModel.BranchID = this.BranchID;
            }
            List<BenefitPolicy_Model> list = new List<BenefitPolicy_Model>();
            string postJson = JsonConvert.SerializeObject(utilityModel);
            issuccess = GetPostResponseNoRedirect("Benefit_M", "GetBenefitList", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<BenefitPolicy_Model>> res = new ObjectResult<List<BenefitPolicy_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<BenefitPolicy_Model>>>(data);

                if (res.Code == "1")
                {
                    list = res.Data;
                }
            }
            ViewBag.LoginBranchID = this.BranchID;
            return View(list);
        }


        public ActionResult EditBenefit()
        {
            string data = "";
            bool issuccess = false;
            BenefitPolicy_Model utilityModel = new BenefitPolicy_Model();
            utilityModel.PolicyID = QueryString.SafeQ("pd");
            BenefitPolicy_Model model = new BenefitPolicy_Model();
            string postJson = JsonConvert.SerializeObject(utilityModel);
            issuccess = GetPostResponseNoRedirect("Benefit_M", "GetBenefitDetail", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<BenefitPolicy_Model> res = new ObjectResult<BenefitPolicy_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<BenefitPolicy_Model>>(data);

                if (res.Code == "1")
                {
                    model = res.Data;
                }
            }

            int flag = QueryString.IntSafeQ("f",0);
            if (flag == 0)
            {
                ViewBag.EditFlag = false;
            }
            else {
                ViewBag.EditFlag = true;
            }

            ViewBag.active = QueryString.IntSafeQ("active", 0);
            return View(model);
        }



        public ActionResult SubmitBenefit(BenefitPolicy_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "处理失败";

            bool issuccess = false;
            if (string.IsNullOrEmpty(model.PolicyID ))
            {
                issuccess = GetPostResponseNoRedirect("Benefit_M", "AddBenefitPolicy", postJson, out data);
            }
            else
            {
                issuccess = GetPostResponseNoRedirect("Benefit_M", "UpdateBenefitPolicy", postJson, out data);
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


        public ActionResult OperationBranchSelect(BranchSelectOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            res.Message = "操作失败";
            issuccess = GetPostResponseNoRedirect("Benefit_M", "BranchSelect", postJson, out data);


            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult DeteleBenefitPolicy(BenefitPolicy_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            res.Message = "操作失败";
            issuccess = GetPostResponseNoRedirect("Benefit_M", "DeteleBenefitPolicy", postJson, out data);


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
