using HS.Framework.Common.Net;
using HS.Framework.Common.Util;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using WebManager.Controllers.Base;
using System.Web;
using System.Web.Mvc;
using Model.Operation_Model;
using HS.Framework.Common.Entity;
using Model.Table_Model;
using System.Drawing;
using WebAPI.Common;
using HS.Framework.Common.Safe;
using WebManager.Models;
using Model.View_Model;

namespace WebManager.Controllers
{
    public class BranchController : BaseController
    {
        //
        // GET: /Branch/

        public ActionResult GetBranchList()
        {
            string data = "";
            ViewBag.List = null;
            bool issuccess = GetPostResponseNoRedirect("Company_M", "GetCompanyDetail", "", out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<Company_Model> res = new ObjectResult<Company_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<Company_Model>>(data);

                if (res.Code == "1")
                {
                    ViewBag.Company = res.Data;
                }
            }

            data = "";
            issuccess = GetPostResponseNoRedirect("Branch_M", "GetBranchListForWeb", "", out data);
            if (!issuccess)
            {
                return RedirectUrl(data, "");
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



            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.BranchID = 0;
            string postJson = JsonConvert.SerializeObject(utilityModel);
            data = "";
            issuccess = GetPostResponseNoRedirect("Image_M", "GetBusinessImage", postJson, out data);
            if (!issuccess)
            {
                return RedirectUrl(data, "");
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<ImageCommon_Model>> res = new ObjectResult<List<ImageCommon_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<ImageCommon_Model>>>(data);

                if (res.Code == "1")
                {
                    ViewBag.CompanyImageList = res.Data;
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

        public ActionResult EditBranch()
        {
            string data = "";
            ViewBag.List = null;
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.BranchID = StringUtils.GetDbInt(QueryString.IntSafeQ("BranchID").ToString(), -1);
            if (utilityModel.BranchID == -1)
            {
                Branch_Model model = new Branch_Model();
                model.ID = -1;
                ViewBag.Branch = model;
            }
            else
            {
                string postJson = JsonConvert.SerializeObject(utilityModel);
                bool issuccess = GetPostResponseNoRedirect("Branch_M", "GetBranchDetail", postJson, out data, false);
                if (!issuccess)
                {
                    return RedirectUrl(data, "", false);
                }

                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<Branch_Model> res = new ObjectResult<Branch_Model>();
                    res = JsonConvert.DeserializeObject<ObjectResult<Branch_Model>>(data);

                    if (res.Code == "1")
                    {
                        ViewBag.Branch = res.Data;
                    }
                }

                data = "";
                issuccess = GetPostResponseNoRedirect("Image_M", "GetBusinessImage", postJson, out data);
                if (!issuccess)
                {
                    return RedirectUrl(data, "");
                }

                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<List<ImageCommon_Model>> res = new ObjectResult<List<ImageCommon_Model>>();
                    res = JsonConvert.DeserializeObject<ObjectResult<List<ImageCommon_Model>>>(data);

                    if (res.Code == "1")
                    {
                        ViewBag.BigImageList = res.Data;
                    }
                }



                EditMarketRelationShipForBranchOperation_Model eModel = new EditMarketRelationShipForBranchOperation_Model();
                eModel.BranchID = utilityModel.BranchID;
                eModel.MarketType = 1;
                postJson = JsonConvert.SerializeObject(eModel);
                data = "";
                issuccess = GetPostResponseNoRedirect("Branch_M", "GetMarketRelationShipForBranch", postJson, out data);
                if (!issuccess)
                {
                    return RedirectUrl(data, "");
                }

                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<List<GetBranchMarketRelationShip_Model>> res = new ObjectResult<List<GetBranchMarketRelationShip_Model>>();
                    res = JsonConvert.DeserializeObject<ObjectResult<List<GetBranchMarketRelationShip_Model>>>(data);

                    if (res.Code == "1")
                    {
                        ViewBag.CommodityList = res.Data;
                    }
                }

                data = "";
                issuccess = GetPostResponseNoRedirect("Branch_M", "GetStockCalcTypeList", postJson, out data);
                if (!issuccess)
                {
                    return RedirectUrl(data, "");
                }

                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<List<StockCalcType_Model>> res = new ObjectResult<List<StockCalcType_Model>>();
                    res = JsonConvert.DeserializeObject<ObjectResult<List<StockCalcType_Model>>>(data);

                    if (res.Code == "1")
                    {
                        ViewBag.StockCalcTypeList = res.Data;
                    }
                }

                eModel.MarketType = 2;
                postJson = JsonConvert.SerializeObject(eModel);
                data = "";
                issuccess = GetPostResponseNoRedirect("Branch_M", "GetMarketRelationShipForBranch", postJson, out data);
                if (!issuccess)
                {
                    return RedirectUrl(data, "");
                }

                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<List<GetBranchMarketRelationShip_Model>> res = new ObjectResult<List<GetBranchMarketRelationShip_Model>>();
                    res = JsonConvert.DeserializeObject<ObjectResult<List<GetBranchMarketRelationShip_Model>>>(data);

                    if (res.Code == "1")
                    {
                        ViewBag.ServiceList = res.Data;
                    }
                }

                data = "";
                issuccess = GetPostResponseNoRedirect("Branch_M", "GetPriceRange", postJson, out data);
                if (!issuccess)
                {
                    return RedirectUrl(data, "");
                }

                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<PriceRange_Model> res = new ObjectResult<PriceRange_Model>();
                    res = JsonConvert.DeserializeObject<ObjectResult<PriceRange_Model>>(data);

                    if (res.Code == "1")
                    {
                        ViewBag.PriceRange = res.Data;
                    }
                }


                data = "";
                issuccess = GetPostResponseNoRedirect("Branch_M", "GetAccountListForBranchEdit", postJson, out data);
                if (!issuccess)
                {
                    return RedirectUrl(data, "");
                }

                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<List<Account_Model>> res = new ObjectResult<List<Account_Model>>();
                    res = JsonConvert.DeserializeObject<ObjectResult<List<Account_Model>>>(data);

                    if (res.Code == "1")
                    {
                        ViewBag.AccountList = res.Data;
                    }
                }

                data = "";
                issuccess = GetPostResponseNoRedirect("Branch_M", "GetAccountListForDefaultConsultant", postJson, out data);
                if (!issuccess)
                {
                    return RedirectUrl(data, "");
                }

                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<List<Account_Model>> res = new ObjectResult<List<Account_Model>>();
                    res = JsonConvert.DeserializeObject<ObjectResult<List<Account_Model>>>(data);

                    if (res.Code == "1")
                    {
                        ViewBag.ConsultantList = res.Data;
                    }
                }
            }
            return View();
        }

        public string DeleteBranch(int BranchID, int Available)
        {
            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel.ID = BranchID;
            operationModel.Available = Available;

            string postJson = JsonConvert.SerializeObject(operationModel);

            string data = "";
            ViewBag.List = null;
            bool issuccess = GetPostResponseNoRedirect("Branch_M", "DeleteBranch", postJson, out data);

            if (issuccess)
            {
                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<bool> res = new ObjectResult<bool>();
                    res = JsonConvert.DeserializeObject<ObjectResult<bool>>(data);

                    if (res.Code == "1")
                    {
                        return "1";
                    }
                }
            }

            return "0";
        }

        public ActionResult OperationBranch(Branch_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "新增失败";
            bool issuccess = false;
            if (model.ID == -1)
            {
                issuccess = GetPostResponseNoRedirect("Branch_M", "AddBranch", postJson, out data);
            }
            else
            {
                issuccess = GetPostResponseNoRedirect("Branch_M", "UpdateBranch", postJson, out data);
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

        public ActionResult IsCanAddBranch()
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "操作失败";
            bool issuccess = false;

            string data = string.Empty;
            issuccess = GetPostResponseNoRedirect("Branch_M", "IsCanAddBranch", "", out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }


        public ActionResult EditMarketRelationShipForBranch(EditMarketRelationShipForBranchOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("Branch_M", "EditMarketRelationShipForBranch", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }


        public ActionResult EditPriceRange(PriceRange_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("Branch_M", "EditPriceRange", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult EditAccountSort(Branch_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("Branch_M", "EditAccountSort", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }


        public ActionResult test()
        {
            return View();
        }

    }
}
