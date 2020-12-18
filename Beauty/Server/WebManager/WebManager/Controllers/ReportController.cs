using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebManager.Controllers.Base;
using WebManager.Models;

namespace WebManager.Controllers
{
    public class ReportController : BaseController
    {
        //
        // GET: /Report/

        public ActionResult ReportDownload()
        {
            return View();
        }



        public ActionResult Operation(ReportDownloadOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<string> res = new ObjectResult<string>();
            bool issuccess = false;
            switch (model.Type)
            {
                case 1:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetCustomerReport", postJson, out data);
                    break;
                case 2:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetCommodityStockReport", "", out data);
                    break;
                case 3:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetProductStockOperateLog", postJson, out data);
                    break;
                case 4:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetAccountPerformanceReport", postJson, out data);
                    break;
                case 5:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetBalanceDetailData", postJson, out data);
                    break;
                case 6:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetPeopleCount", postJson, out data);
                    break;
                case 7:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetBranchPerformance", postJson, out data);
                    break;
                case 8:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetNoCompleteTreatmentDetail", postJson, out data);
                    break;
                case 9:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetAccountStatementReport", postJson, out data);
                    break;
                case 11:
                    issuccess = GetPostResponseNoRedirect("Report_M", "CardInfo", postJson, out data);
                    break;
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

        public ActionResult ReportDownloadNew()
        {
            string cookieKey = this.CompanyID.ToString() + this.BranchID.ToString() + this.UserID.ToString();
            string strCookie = CookieUtil.GetCookieValue(cookieKey, true);
            ViewBag.BranchID = this.BranchID;
            if (strCookie == null || strCookie == "")
            {
                ReportCookie_ListModel mReport = new ReportCookie_ListModel();
                mReport.list = new List<ReportCookie_Model>();

                ReportCookie_Model CookieModel = new ReportCookie_Model();
                CookieModel.Type = 1;
                CookieModel.Status = 0;
                mReport.list.Add(CookieModel);

                CookieModel = new ReportCookie_Model();
                CookieModel.Type = 2;
                CookieModel.Status = 0;
                mReport.list.Add(CookieModel);

                CookieModel = new ReportCookie_Model();
                CookieModel.Type = 3;
                CookieModel.Status = 0;
                mReport.list.Add(CookieModel);

                CookieModel = new ReportCookie_Model();
                CookieModel.Type = 4;
                CookieModel.Status = 0;
                mReport.list.Add(CookieModel);

                CookieModel = new ReportCookie_Model();
                CookieModel.Type = 5;
                CookieModel.Status = 0;
                mReport.list.Add(CookieModel);

                CookieModel = new ReportCookie_Model();
                CookieModel.Type = 6;
                CookieModel.Status = 0;
                mReport.list.Add(CookieModel);

                CookieModel = new ReportCookie_Model();
                CookieModel.Type = 7;
                CookieModel.Status = 0;
                mReport.list.Add(CookieModel);

                CookieModel = new ReportCookie_Model();
                CookieModel.Type = 8;
                CookieModel.Status = 0;
                mReport.list.Add(CookieModel);

                CookieModel = new ReportCookie_Model();
                CookieModel.Type = 9;
                CookieModel.Status = 0;
                mReport.list.Add(CookieModel);

                CookieModel = new ReportCookie_Model();
                CookieModel.Type = 10;
                CookieModel.Status = 0;
                mReport.list.Add(CookieModel);

                CookieModel = new ReportCookie_Model();
                CookieModel.Type = 11;
                CookieModel.Status = 0;
                mReport.list.Add(CookieModel);

                CookieModel = new ReportCookie_Model();
                CookieModel.Type = 12;
                CookieModel.Status = 0;
                mReport.list.Add(CookieModel);

                CookieModel = new ReportCookie_Model();
                CookieModel.Type = 13;
                CookieModel.Status = 0;
                mReport.list.Add(CookieModel);

                CookieModel = new ReportCookie_Model();
                CookieModel.Type = 14;
                CookieModel.Status = 0;
                mReport.list.Add(CookieModel);

                CookieModel = new ReportCookie_Model();
                CookieModel.Type = 15;
                CookieModel.Status = 0;
                mReport.list.Add(CookieModel);

                CookieModel = new ReportCookie_Model();
                CookieModel.Type = 16;
                CookieModel.Status = 0;
                mReport.list.Add(CookieModel);

                string newCookie = JsonConvert.SerializeObject(mReport);
                CookieUtil.SetCookie(cookieKey, newCookie, 0, true);
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

        public ActionResult OperationNew(ReportDownloadOperation_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<List<ReportCookie_Model>> res = new ObjectResult<List<ReportCookie_Model>>();
            res.Code = "0";
            res.Data = null;
            bool issuccess = false;
            switch (model.Type)
            {
                case 1:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetCustomerReportNew", postJson, out data);
                    break;
                case 2:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetCommodityStockReportNew", "", out data);
                    break;
                case 3:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetProductStockOperateLogNew", postJson, out data);
                    break;
                case 4:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetAccountPerformanceReportNew", postJson, out data);
                    break;
                case 5:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetBalanceDetailDataNew", postJson, out data);
                    break;
                case 6:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetPeopleCountNew", postJson, out data);
                    break;
                case 7:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetBranchPerformanceNew", postJson, out data);
                    break;
                case 8:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetNoCompleteTreatmentDetailNew", postJson, out data);
                    break;
                case 9:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetAccountStatementReport", postJson, out data);
                    break;
                case 10:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetBranchStatementReport", postJson, out data);
                    break;
                case 11:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetCardInfo", postJson, out data);
                    break;
                case 12:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetAttendanceInfo", postJson, out data);
                    break;
                case 13:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetCommDetail", postJson, out data);
                    break;
                case 14:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetCustomerRelation", "", out data);
                    break;
                case 15:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetServiceRate", postJson, out data);
                    break;
                case 16:
                    issuccess = GetPostResponseNoRedirect("Report_M", "GetInputOrderReport", postJson, out data);
                    break;
            }

            string cookieKey = this.CompanyID.ToString() + this.BranchID.ToString() + this.UserID.ToString();
            string strCookie = CookieUtil.GetCookieValue(cookieKey, true);

            if (issuccess)
            {
                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<string> result = new ObjectResult<string>();
                    result = JsonConvert.DeserializeObject<ObjectResult<string>>(data);

                    if (result.Code == "1")
                    {
                        if (strCookie != "" && strCookie != null)
                        {
                            bool exist = false;
                            ReportCookie_ListModel mReport = JsonConvert.DeserializeObject<ReportCookie_ListModel>(strCookie);
                            if (mReport.list != null && mReport.list.Count > 0)
                            {
                                foreach (ReportCookie_Model item in mReport.list)
                                {
                                    if (item.Type == model.Type)
                                    {
                                        item.fileName = result.Data;
                                        item.Status = 1;
                                        item.DonwloadUrl = "";
                                        item.New = 0;
                                        exist = true;
                                    }
                                }

                                if (!exist)
                                {
                                    ReportCookie_Model CookieModel = new ReportCookie_Model();
                                    CookieModel.Type = model.Type;
                                    CookieModel.fileName = result.Data;
                                    CookieModel.Status = 1;
                                    CookieModel.New = 0;
                                    mReport.list.Add(CookieModel);
                                }
                                string newCookie = JsonConvert.SerializeObject(mReport);
                                CookieUtil.SetCookie(cookieKey, newCookie, 0, true);
                                res.Data = mReport.list;
                            }
                        }
                        else
                        {
                            ReportCookie_ListModel mReport = new ReportCookie_ListModel();
                            ReportCookie_Model CookieModel = new ReportCookie_Model();
                            CookieModel.Type = model.Type;
                            CookieModel.Status = 1;
                            CookieModel.fileName = result.Data;
                            CookieModel.New = 0;
                            mReport.list = new List<ReportCookie_Model>();
                            mReport.list.Add(CookieModel);
                            string newCookie = JsonConvert.SerializeObject(mReport);
                            CookieUtil.SetCookie(cookieKey, newCookie, 0, true);
                            res.Data = mReport.list;
                        }
                        res.Code = "1";
                    }
                    else
                    {
                        res.Message = result.Message;
                    }
                }
                string returnJson = JsonConvert.SerializeObject(res);
                return Content(returnJson, "application/json; charset=utf-8");
            }
            else
            {
                string returnJson = JsonConvert.SerializeObject(res);
                return Content(returnJson, "application/json; charset=utf-8");
            }
        }

        public ActionResult CheckDownloadOK()
        {
            string cookieKey = this.CompanyID.ToString() + this.BranchID.ToString() + this.UserID.ToString();
            string strCookie = CookieUtil.GetCookieValue(cookieKey, true);

            if (strCookie != "" && strCookie != null)
            {
                string data = string.Empty;
                bool issuccess = false;
                issuccess = GetPostResponseNoRedirect("Report_M", "CheckDownloadOK", strCookie, out data);

                ObjectResult<List<ReportCookie_Model>> res = new ObjectResult<List<ReportCookie_Model>>();
                if (issuccess)
                {
                    if (!string.IsNullOrEmpty(data))
                    {
                        ObjectResult<ReportCookie_ListModel> result = new ObjectResult<ReportCookie_ListModel>();
                        result = JsonConvert.DeserializeObject<ObjectResult<ReportCookie_ListModel>>(data);
                        strCookie = JsonConvert.SerializeObject(result.Data);
                        res.Data = result.Data.list;
                    }
                    CookieUtil.SetCookie(cookieKey, strCookie, 0, true);
                    res.Code = "1";
                    string returnJson = JsonConvert.SerializeObject(res);
                    return Content(returnJson, "application/json; charset=utf-8");
                }
                else
                {
                    res.Code = "0";
                    res.Data = null;
                    string returnJson = JsonConvert.SerializeObject(res);
                    return Content(returnJson, "application/json; charset=utf-8");
                }
            }
            else
            {
                ObjectResult<string> res = new ObjectResult<string>();
                res.Code = "2";
                res.Data = "";
                string returnJson = JsonConvert.SerializeObject(res);
                return Content(returnJson, "application/json; charset=utf-8");

            }
        }

        public ActionResult DownloadSuccess(int Type)
        {
            ObjectResult<string> res = new ObjectResult<string>();

            try
            {
                string cookieKey = this.CompanyID.ToString() + this.BranchID.ToString() + this.UserID.ToString();
                string strCookie = CookieUtil.GetCookieValue(cookieKey, true);
                
                if (strCookie != "" && strCookie != null)
                {
                    ReportCookie_ListModel mReport = JsonConvert.DeserializeObject<ReportCookie_ListModel>(strCookie);
                    ReportCookie_ListModel newModel = new ReportCookie_ListModel();
                    newModel.list = new List<ReportCookie_Model>();
                    foreach (ReportCookie_Model item in mReport.list)
                    {
                        if (item.Type == Type)
                        {
                            res.Data = item.DonwloadUrl;
                        }
                    }
                    res.Code = "1";
                }
                else
                {
                    res.Code = "-1";
                }
                string returnJson = JsonConvert.SerializeObject(res);
                return Content(returnJson, "application/json; charset=utf-8");
            }
            catch
            {
                res.Code = "-1";
                return Json(res);
            }
        }


    }
}
