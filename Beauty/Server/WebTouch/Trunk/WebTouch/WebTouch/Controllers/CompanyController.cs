using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebTouch.Controllers.Base;

namespace WebTouch.Controllers
{
    public class CompanyController : BaseController
    {
        //
        // GET: /Company/

        public ActionResult CompanyDetail()
        {
            string data = "";
            GetCompanyDetail_Model model = new GetCompanyDetail_Model();
            UtilityOperation_Model OperatModel = new UtilityOperation_Model();
            OperatModel.ImageHeight = 600;
            OperatModel.ImageWidth = 800;

            string postJson = JsonConvert.SerializeObject(OperatModel);
            bool issuccess = GetPostResponseNoRedirect("Company", "GetCompanyDetail", postJson, out data, false, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            else
            {
                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<GetCompanyDetail_Model> res = new ObjectResult<GetCompanyDetail_Model>();
                    res = JsonConvert.DeserializeObject<ObjectResult<GetCompanyDetail_Model>>(data);

                    if (res.Code == "1")
                    {
                        model = res.Data;
                    }
                }
            }
            data = "";

            issuccess = GetPostResponseNoRedirect("Company", "GetBusinessImage", postJson, out data, false, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            else
            {
                ObjectResult<List<string>> res = new ObjectResult<List<string>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<string>>>(data);


                if (res.Code == "1")
                {
                    ViewBag.ImgList = res.Data;

                }
            }

            return View(model);
        }


        public ActionResult NoticeList()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.BranchID = 0;
            //utilityModel.ImageWidth = 100;
            //utilityModel.ImageHeight = 100;


            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            List<Notice_Model> list = null;
            bool issuccess = GetPostResponseNoRedirect("Notice", "GetNoticeList", "", out data, false, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            ObjectResult<List<Notice_Model>> res = new ObjectResult<List<Notice_Model>>();
            res = JsonConvert.DeserializeObject<ObjectResult<List<Notice_Model>>>(data);

            if (res.Code == "1")
            {
                list = new List<Notice_Model>();
                list = res.Data;

            }

            return View(list);
        }

        public ActionResult NoticeDetail()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.ID = HS.Framework.Common.Safe.QueryString.IntSafeQ("n");
            utilityModel.BranchID = 0;
            utilityModel.ImageWidth = 800;
            utilityModel.ImageHeight = 600;


            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            Notice_Model model = null;
            bool issuccess = GetPostResponseNoRedirect("Notice", "GetNoticeDetail", postJson, out data, false, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            ObjectResult<Notice_Model> res = new ObjectResult<Notice_Model>();
            res = JsonConvert.DeserializeObject<ObjectResult<Notice_Model>>(data);

            if (res.Code == "1")
            {
                model = new Notice_Model();
                model = res.Data;

            }

            return View(model);
        }

        public ActionResult BranchList()
        {
            return View();
            //UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            //utilityModel.BranchID = 0;
            ////utilityModel.ImageWidth = 100;
            ////utilityModel.ImageHeight = 100;


            //string postJson = JsonConvert.SerializeObject(utilityModel);

            //string data = "";
            //List<GetBranchList_Model> list = null;
            //bool issuccess = GetPostResponse("Company", "GetBranchList", "", out data, false,false);
            //if (issuccess)
            //{
            //    ObjectResult<List<GetBranchList_Model>> res = new ObjectResult<List<GetBranchList_Model>>();
            //    res = JsonConvert.DeserializeObject<ObjectResult<List<GetBranchList_Model>>>(data);

            //    if (res.Code == "1")
            //    {
            //        list = new List<GetBranchList_Model>();
            //        list = res.Data;
            //    }
            //}

            //return View(list);
        }

        public ActionResult BranchDetail()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.BranchID = HS.Framework.Common.Safe.QueryString.IntSafeQ("b");
            utilityModel.ImageWidth = 800;
            utilityModel.ImageHeight = 600;


            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            GetBusinessDetail_Model model = null;
            bool issuccess = GetPostResponseNoRedirect("Company", "GetBusinessDetail", postJson, out data, false, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            else
            {

                ObjectResult<GetBusinessDetail_Model> res = new ObjectResult<GetBusinessDetail_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<GetBusinessDetail_Model>>(data);

                if (res.Code == "1")
                {
                    model = new GetBusinessDetail_Model();
                    model = res.Data;

                }
            }

            data = "";

            issuccess = GetPostResponseNoRedirect("Company", "GetBusinessImage", postJson, out data, false, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            else
            {
                ObjectResult<List<string>> res = new ObjectResult<List<string>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<string>>>(data);

                if (res.Code == "1")
                {
                    ViewBag.ImgList = res.Data;

                }
            }

            return View(model);
        }

        public ActionResult ConsultantList()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.BranchID = HS.Framework.Common.Safe.QueryString.IntSafeQ("b");
            utilityModel.Flag = 2;
            utilityModel.ImageWidth = 98;
            utilityModel.ImageHeight = 98;


            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            List<AccountList_Model> list = null;
            bool issuccess = GetPostResponseNoRedirect("Account", "GetAccountListByBranchID", postJson, out data, false, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            ObjectResult<List<AccountList_Model>> res = new ObjectResult<List<AccountList_Model>>();
            res = JsonConvert.DeserializeObject<ObjectResult<List<AccountList_Model>>>(data);

            if (res.Code == "1")
            {
                list = new List<AccountList_Model>();
                list = res.Data;

            }



            return View(list);
        }

        public ActionResult ConsultantDetail()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.AccountID = HS.Framework.Common.Safe.QueryString.IntSafeQ("a");
            //   utilityModel.BranchID = HS.Framework.Common.Safe.QueryString.IntSafeQ("b");
            utilityModel.ImageWidth = 100;
            utilityModel.ImageHeight = 100;


            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            AccountDetail_Model model = null;
            bool issuccess = GetPostResponseNoRedirect("Account", "getAccountDetail", postJson, out data, false, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            ObjectResult<AccountDetail_Model> res = new ObjectResult<AccountDetail_Model>();
            res = JsonConvert.DeserializeObject<ObjectResult<AccountDetail_Model>>(data);

            if (res.Code == "1")
            {
                model = new AccountDetail_Model();
                model = res.Data;

            }

            return View(model);
        }

        public ActionResult BranchPromotion()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.BranchID = HS.Framework.Common.Safe.QueryString.IntSafeQ("b");
            utilityModel.ImageHeight = 120;
            utilityModel.ImageWidth = 160;


            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            List<PromotionList_Model> list = null;
            bool issuccess = GetPostResponseNoRedirect("Promotion", "GetPromotionList", postJson, out data, false, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            ObjectResult<List<PromotionList_Model>> res = new ObjectResult<List<PromotionList_Model>>();
            res = JsonConvert.DeserializeObject<ObjectResult<List<PromotionList_Model>>>(data);

            if (res.Code == "1")
            {
                list = new List<PromotionList_Model>();
                list = res.Data;

            }


            return View(list);
        }


        public ActionResult GetBranchList(GetBranchList_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);

            ObjectResult<List<GetBranchList_Model>> res = new ObjectResult<List<GetBranchList_Model>>();
            string data = "";
            bool issuccess = GetPostResponseNoRedirect("Company", "GetBranchList", postJson, out data, false, false);
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
