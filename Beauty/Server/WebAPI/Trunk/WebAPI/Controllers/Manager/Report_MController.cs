using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using WebAPI.Authorize;
using WebAPI.BLL;
using WebAPI.Controllers.API;
using System.Configuration;
using System.IO;
using System.Diagnostics;
using HS.Framework.Common;
using WebAPI.Common;
using System.Threading.Tasks;
using System.Runtime.InteropServices;

namespace WebAPI.Controllers.Manager
{
    public class Report_MController : BaseController
    {
        [HttpPost]
        [ActionName("GetCustomerReport")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCustomerReport(JObject obj)
        {
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            ReportDownloadOperation_Model utilityModel = new ReportDownloadOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<ReportDownloadOperation_Model>(strSafeJson);

            string templatePath = AppDomain.CurrentDomain.BaseDirectory.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = "";

            file = templatePath + "顾客信息.xlt";
            if (!File.Exists(file))
            {
                res.Code = "0";
                res.Message = "模板不存在";
            }
            else
            {
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getCustomerReport(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);

                if (dt != null)
                {
                    ds.Tables.Add(dt);

                    string url = ReportDownload_BLL.Instance.ExportReport(ds, "Customer", file);

                    res.Code = "1";
                    res.Data = url;
                }
                else
                {
                    res.Code = "0";
                    res.Message = "没有数据";
                }
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetCommodityStockReport")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCommodityStockReport()
        {
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            string templatePath = HttpRuntime.AppDomainAppPath.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = "";

            file = templatePath + "库存信息.xlt";
            if (!File.Exists(file))
            {
                res.Code = "0";
                res.Message = "模板不存在";
            }
            else
            {
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getCommodityStockReport(this.CompanyID, this.BranchID);

                if (dt != null)
                {
                    ds.Tables.Add(dt);
                    //string url = ReportDownload_BLL.Instance.ExportReport(ds, "CommodityStock", file);
                    string url = ReportDownload_BLL.Instance.ExportReport(ds, "库存信息", file);

                    res.Code = "1";
                    res.Data = url;
                }
                else
                {
                    res.Code = "0";
                    res.Message = "没有数据";
                }
            }

            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetProductStockOperateLog")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetProductStockOperateLog(JObject obj)
        {
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            ReportDownloadOperation_Model utilityModel = new ReportDownloadOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<ReportDownloadOperation_Model>(strSafeJson);


            string templatePath = HttpRuntime.AppDomainAppPath.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = "";

            file = templatePath + "库存变动信息.xlt";
            if (!File.Exists(file))
            {
                res.Code = "0";
                res.Message = "模板不存在";
            }
            else
            {
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getProductStockOperateLog(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                    string url = ReportDownload_BLL.Instance.ExportReport(ds, "ProductStockOperateLog", file);

                    res.Code = "1";
                    res.Data = url;
                }
                else
                {
                    res.Code = "0";
                    res.Message = "没有数据";
                }
            }
            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetAccountPerformanceReport")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetAccountPerformanceReport(JObject obj)
        {
            Stopwatch watch = new Stopwatch();
            watch.Start();
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            ReportDownloadOperation_Model utilityModel = new ReportDownloadOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<ReportDownloadOperation_Model>(strSafeJson);


            string templatePath = HttpRuntime.AppDomainAppPath.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = "";



            file = templatePath + "员工业绩报表.xlt";
            if (!File.Exists(file))
            {
                res.Code = "0";
                res.Message = "模板不存在";
            }
            else
            {
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getServicePayDetail(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                LogUtil.Log("GetAccountPerformanceReport", watch.ElapsedMilliseconds.ToString());
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }
                dt = new DataTable();

                dt = ReportDownload_BLL.Instance.getTreatmentDetail(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                LogUtil.Log("GetAccountPerformanceReport", watch.ElapsedMilliseconds.ToString());
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }
                dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getCommodityDeatilReport(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                LogUtil.Log("GetAccountPerformanceReport", watch.ElapsedMilliseconds.ToString());
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }
                dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getReChargeDeatilReport(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                LogUtil.Log("GetAccountPerformanceReport", watch.ElapsedMilliseconds.ToString());
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }
                dt = new DataTable();

                dt = ReportDownload_BLL.Instance.getIsDesignatedDetail(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                LogUtil.Log("GetAccountPerformanceReport", watch.ElapsedMilliseconds.ToString());
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }
                //string url = ReportDownload_BLL.Instance.ExportReport(ds, "AccountPerformance", file);
                string url = ReportDownload_BLL.Instance.ExportReport(ds, "员工业绩报表", file);

                res.Code = "1";
                res.Data = url;
            }
            watch.Stop();
            LogUtil.Log("GetAccountPerformanceReport", watch.ElapsedMilliseconds.ToString());
            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetBalanceDetailData")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetBalanceDetailData(JObject obj)
        {

            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            ReportDownloadOperation_Model utilityModel = new ReportDownloadOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<ReportDownloadOperation_Model>(strSafeJson);


            string templatePath = HttpRuntime.AppDomainAppPath.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = "";

            DataSet ds = new DataSet();
            DataTable dt = new DataTable();
            dt = ReportDownload_BLL.Instance.getBalanceDetailData(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
            if (dt != null)
            {
                ds.Tables.Add(dt);
                file = templatePath + "余额变动信息.xlt";
                if (!File.Exists(file))
                {
                    res.Code = "0";
                    res.Message = "模板不存在";
                }
                else
                {
                    string url = ReportDownload_BLL.Instance.ExportReport(ds, "余额变动信息", file);

                    res.Code = "1";
                    res.Data = url;
                }
            }
            else
            {
                res.Code = "0";
                res.Message = "没有数据";
            }

            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetPeopleCount")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetPeopleCount(JObject obj)
        {

            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            ReportDownloadOperation_Model utilityModel = new ReportDownloadOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<ReportDownloadOperation_Model>(strSafeJson);


            string templatePath = HttpRuntime.AppDomainAppPath.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = "";

            file = templatePath + "人次统计.xlt";
            if (!File.Exists(file))
            {
                res.Code = "0";
                res.Message = "模板不存在";
            }
            else
            {
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getPeopleCount(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                    string url = ReportDownload_BLL.Instance.ExportReport(ds, "人次统计", file);

                    res.Code = "1";
                    res.Data = url;
                }
                else
                {
                    res.Code = "0";
                    res.Message = "没有数据";
                }
            }
            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetBranchPerformance")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetBranchPerformance(JObject obj)
        {

            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            ReportDownloadOperation_Model utilityModel = new ReportDownloadOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<ReportDownloadOperation_Model>(strSafeJson);


            string templatePath = HttpRuntime.AppDomainAppPath.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = "";


            file = templatePath + "门店业绩报表.xlt";
            if (!File.Exists(file))
            {
                res.Code = "0";
                res.Message = "模板不存在";
            }
            else
            {
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getBranchPerformance(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }

                dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getBranchServicePayDetail(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }


                dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getBranchCommodityDeatilReport(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }


                dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getBranchReChargeDeatilReport(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }

                string url = ReportDownload_BLL.Instance.ExportBranchPerformanceReport(ds, file);

                res.Code = "1";
                res.Data = url;
            }

            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetNoCompleteTreatmentDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetNoCompleteTreatmentDetail()
        {
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            string templatePath = AppDomain.CurrentDomain.BaseDirectory.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = "";

            file = templatePath + "待完成订单信息.xlt";
            if (!File.Exists(file))
            {
                res.Code = "0";
                res.Message = "模板不存在";
            }
            else
            {
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getNoCompleteTreatmentDetail(this.CompanyID, this.BranchID);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }
                dt = ReportDownload_BLL.Instance.getNoDeliveryCommodity(this.CompanyID, this.BranchID);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }



                string url = ReportDownload_BLL.Instance.ExportReport(ds, "NoCompleteTreatment", file);

                res.Code = "1";
                res.Data = url;


            }
            return toJson(res);
        }


        [DllImport("kernel32.dll")]
        public static extern IntPtr _lopen(string lpPathName, int iReadWrite);

        [DllImport("kernel32.dll")]
        public static extern bool CloseHandle(IntPtr hObject);

        public const int OF_READWRITE = 2;
        public const int OF_SHARE_DENY_NONE = 0x40;
        public readonly IntPtr HFILE_ERROR = new IntPtr(-1);


        [HttpPost]
        [ActionName("CheckDownloadOK")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage CheckDownloadOK(JObject obj)
        {

            ObjectResult<ReportCookie_ListModel> res = new ObjectResult<ReportCookie_ListModel>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            ReportCookie_ListModel list = new ReportCookie_ListModel();
            list = JsonConvert.DeserializeObject<ReportCookie_ListModel>(strSafeJson);

            foreach (ReportCookie_Model item in list.list)
            {
                if (item.fileName != "" && item.fileName != null)
                {
                    string path = Const.uploadServer + "/" + Const.strImage + "temp/report/" + item.fileName; 
                    if (!Directory.Exists(path))
                    {
                        IntPtr vHandle = _lopen(path, OF_READWRITE | OF_SHARE_DENY_NONE);

                        if (vHandle != HFILE_ERROR)
                        {
                            item.Status = 2;
                            //item.DonwloadUrl = Const.strFileHttp + Const.server + "/getFile.aspx?fn=temp/report/" + item.fileName;
                            item.DonwloadUrl = Const.strFileHttp + Const.server + "/report/" + item.fileName;
                            item.fileName = "";
                            item.New = 1;
                        }

                        CloseHandle(vHandle);
                    }
                }
                else if (item.New == 1)
                {
                    item.New = 2;
                }
            }

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        #region 表报新方法
        [HttpPost]
        [ActionName("GetCustomerReportNew")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCustomerReportNew(JObject obj)
        {
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            ReportDownloadOperation_Model utilityModel = new ReportDownloadOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<ReportDownloadOperation_Model>(strSafeJson);
            string templatePath = AppDomain.CurrentDomain.BaseDirectory.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = "";

            file = templatePath + "顾客信息.xlt";
            if (!File.Exists(file))
            {
                res.Code = "0";
                res.Message = "模板不存在";
            }


            string path = Const.uploadServer + "/" + Const.strImage + "temp/report/";
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            //string fileName = "Customer" + this.CompanyID.ToString() + this.BranchID.ToString() + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";
            string fileName = "顾客信息_" + DateTime.Now.ToString("yyyyMMdd") + "_" + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";

            Task.Factory.StartNew(() =>
            {

                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getCustomerReport(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }

                ReportDownload_BLL.Instance.ExportReportCustomer(ds, file, path + fileName, this.BranchID);

            });

            res.Code = "1";
            res.Data = fileName;
            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetCommodityStockReportNew")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCommodityStockReportNew()
        {
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            string templatePath = HttpRuntime.AppDomainAppPath.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = "";

            file = templatePath + "库存及批次信息.xlt";
            if (!File.Exists(file))
            {
                res.Code = "0";
                res.Message = "模板不存在";
            }


            string path = Const.uploadServer + "/" + Const.strImage + "temp/report/";
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            //string fileName = "CommodityStock" + this.CompanyID.ToString() + this.BranchID.ToString() + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";
            string fileName = "库存及批次信息_" + DateTime.Now.ToString("yyyyMMdd") + "_" + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";

            Task.Factory.StartNew(() =>
            {

                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getCommodityStockReport(this.CompanyID, this.BranchID);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }

                dt = ReportDownload_BLL.Instance.getCommoditybatch(this.CompanyID, this.BranchID);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }

                ReportDownload_BLL.Instance.ExportReportNew(ds, file, path + fileName);


            });

            res.Code = "1";
            res.Data = fileName;
            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetProductStockOperateLogNew")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetProductStockOperateLogNew(JObject obj)
        {
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            ReportDownloadOperation_Model utilityModel = new ReportDownloadOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<ReportDownloadOperation_Model>(strSafeJson);


            string templatePath = HttpRuntime.AppDomainAppPath.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = "";

            file = templatePath + "库存变动信息.xlt";
            if (!File.Exists(file))
            {
                res.Code = "0";
                res.Message = "模板不存在";
            }


            string path = Const.uploadServer + "/" + Const.strImage + "temp/report/";
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            //string fileName = "ProductStockOperateLog" + this.CompanyID.ToString() + this.BranchID.ToString() + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";
            string fileName = "库存变动信息_" + DateTime.Now.ToString("yyyyMMdd") + "_" + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";

            Task.Factory.StartNew(() =>
            {

                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getProductStockOperateLog(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }

                ReportDownload_BLL.Instance.ExportReportNew(ds, file, path + fileName);

            });

            res.Code = "1";
            res.Data = fileName;
            return toJson(res);

        }


        [HttpPost]
        [ActionName("GetAccountPerformanceReportNew")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetAccountPerformanceReportNew(JObject obj)
        {
            Stopwatch watch = new Stopwatch();
            watch.Start();
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            ReportDownloadOperation_Model utilityModel = new ReportDownloadOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<ReportDownloadOperation_Model>(strSafeJson);


            string templatePath = HttpRuntime.AppDomainAppPath.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = "";



            file = templatePath + "员工业绩报表.xlt";
            if (!File.Exists(file))
            {
                res.Code = "0";
                res.Message = "模板不存在";
            }

            string path = Const.uploadServer + "/" + Const.strImage + "temp/report/";
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            //string fileName = "AccountPerformance" + this.CompanyID.ToString() + this.BranchID.ToString() + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";
            string fileName = "员工业绩_" + DateTime.Now.ToString("yyyyMMdd") + "_" + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";

            Task.Factory.StartNew(() =>
            {

                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getServicePayDetail(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }
                dt = new DataTable();

                dt = ReportDownload_BLL.Instance.getTreatmentDetail(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }
                dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getCommodityDeatilReport(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }
                dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getReChargeDeatilReport(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }
                dt = new DataTable();

                dt = ReportDownload_BLL.Instance.getIsDesignatedDetail(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }

                ReportDownload_BLL.Instance.ExportAccountPerformanceReportNew(ds, file, path + fileName);

            });

            res.Code = "1";
            res.Data = fileName;
            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetBalanceDetailDataNew")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetBalanceDetailDataNew(JObject obj)
        {

            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            ReportDownloadOperation_Model utilityModel = new ReportDownloadOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<ReportDownloadOperation_Model>(strSafeJson);


            string templatePath = HttpRuntime.AppDomainAppPath.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = templatePath + "余额变动信息.xlt";

            if (!File.Exists(file))
            {
                res.Code = "0";
                res.Message = "模板不存在";
            }

            string path = Const.uploadServer + "/" + Const.strImage + "temp/report/";
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            //string fileName = "BalanceDetailData" + this.CompanyID.ToString() + this.BranchID.ToString() + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";
            string fileName = "储值卡变动数据_" + DateTime.Now.ToString("yyyyMMdd") + "_" + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";

            Task.Factory.StartNew(() =>
            {
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getBalanceDetailData(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }


                ReportDownload_BLL.Instance.ExportReportNew(ds, file, path + fileName);

            });

            res.Code = "1";
            res.Data = fileName;
            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetBranchPerformanceNew")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetBranchPerformanceNew(JObject obj)
        {

            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            ReportDownloadOperation_Model utilityModel = new ReportDownloadOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<ReportDownloadOperation_Model>(strSafeJson);


            string templatePath = HttpRuntime.AppDomainAppPath.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = "";


            file = templatePath + "门店业绩报表.xlt";
            if (!File.Exists(file))
            {
                res.Code = "0";
                res.Message = "模板不存在";
            }

            string path = Const.uploadServer + "/" + Const.strImage + "temp/report/";
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            //string fileName = "BranchPerformance" + this.CompanyID.ToString() + this.BranchID.ToString() + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";
            string fileName = "门店业绩_" + DateTime.Now.ToString("yyyyMMdd") + "_" + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";

            Task.Factory.StartNew(() =>
            {
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getBranchPerformance(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }

                dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getBranchServicePayDetail(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }


                dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getBranchCommodityDeatilReport(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }


                dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getBranchReChargeDeatilReport(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }

                ReportDownload_BLL.Instance.ExportBranchPerformanceReport(ds, file, path + fileName);

            });

            res.Code = "1";
            res.Data = fileName;
            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetNoCompleteTreatmentDetailNew")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetNoCompleteTreatmentDetailNew()
        {
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            string templatePath = AppDomain.CurrentDomain.BaseDirectory.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = "";

            file = templatePath + "待完成订单信息.xlt";
            if (!File.Exists(file))
            {
                res.Code = "0";
                res.Message = "模板不存在";
            }

            string path = Const.uploadServer + "/" + Const.strImage + "temp/report/";
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            //string fileName = "NoCompleteTreatment" + this.CompanyID.ToString() + this.BranchID.ToString() + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";
            string fileName = "待完成订单信息_" + DateTime.Now.ToString("yyyyMMdd") + "_" + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";

            Task.Factory.StartNew(() =>
            {

                DataSet ds = new DataSet();
                DataTable dt = new DataTable();

                dt = ReportDownload_BLL.Instance.getNoCompleteTreatmentDetail(this.CompanyID, this.BranchID);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }


                dt = ReportDownload_BLL.Instance.getNoDeliveryCommodity(this.CompanyID, this.BranchID);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }

                ReportDownload_BLL.Instance.ExportReportNew(ds, file, path + fileName);

            });

            res.Code = "1";
            res.Data = fileName;
            return toJson(res);

        }



        [HttpPost]
        [ActionName("GetAccountStatementReport")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetAccountStatementReport(JObject obj)
        {
            Stopwatch watch = new Stopwatch();
            watch.Start();
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            ReportDownloadOperation_Model utilityModel = new ReportDownloadOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<ReportDownloadOperation_Model>(strSafeJson);


            string templatePath = HttpRuntime.AppDomainAppPath.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = "";



            file = templatePath + "员工分类业绩报表.xlt";
            if (!File.Exists(file))
            {
                res.Code = "0";
                res.Message = "模板不存在";
            }

            string path = Const.uploadServer + "/" + Const.strImage + "temp/report/";
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            //string fileName = "AccountStatement" + this.CompanyID.ToString() + this.BranchID.ToString() + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";
            string fileName = "员工分类业绩_" + DateTime.Now.ToString("yyyyMMdd") + "_" + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";

            Task.Factory.StartNew(() =>
            {
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getStatementServicePayDetail(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }
                dt = new DataTable();

                dt = ReportDownload_BLL.Instance.getStatementTreatmentDetail(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }
                dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getStatementCommodityDetail(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }

                ReportDownload_BLL.Instance.ExportReportNew(ds, file, path + fileName);

            });

            res.Code = "1";
            res.Data = fileName;
            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetBranchStatementReport")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetBranchStatementReport(JObject obj)
        {
            Stopwatch watch = new Stopwatch();
            watch.Start();
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            ReportDownloadOperation_Model utilityModel = new ReportDownloadOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<ReportDownloadOperation_Model>(strSafeJson);


            string templatePath = HttpRuntime.AppDomainAppPath.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = "";



            file = templatePath + "门店分类业绩报表.xlt";
            if (!File.Exists(file))
            {
                res.Code = "0";
                res.Message = "模板不存在";
            }

            string path = Const.uploadServer + "/" + Const.strImage + "temp/report/";
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            //string fileName = "BranchStatement" + this.CompanyID.ToString() + this.BranchID.ToString() + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";
            string fileName = "门店分类业绩_" + DateTime.Now.ToString("yyyyMMdd") + "_" + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";

            Task.Factory.StartNew(() =>
            {

                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getBranchStatementServicePayDetail(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }
                dt = new DataTable();

                dt = ReportDownload_BLL.Instance.getBranchStatementCommodityDetail(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }

                ReportDownload_BLL.Instance.ExportReportNew(ds, file, path + fileName);

            });

            res.Code = "1";
            res.Data = fileName;
            return toJson(res);
        }





        [HttpPost]
        [ActionName("GetCardInfo")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCardInfo()
        {
            Stopwatch watch = new Stopwatch();
            watch.Start();
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;


            string templatePath = AppDomain.CurrentDomain.BaseDirectory.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = "";



            file = templatePath + "储值卡信息.xlt";
            if (!File.Exists(file))
            {
                res.Code = "0";
                res.Message = "模板不存在";
            }

            string path = Const.uploadServer + "/" + Const.strImage + "temp/report/";
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            //string fileName = "CardInfo" + this.CompanyID.ToString() + this.BranchID.ToString() + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";
            string fileName = "储值卡信息_" + DateTime.Now.ToString("yyyyMMdd") + "_" + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";

            Task.Factory.StartNew(() =>
            {
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getCardInfo(this.CompanyID, this.BranchID);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }
                dt = ReportDownload_BLL.Instance.getCardInfoDetail(this.CompanyID, this.BranchID);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }

                ReportDownload_BLL.Instance.ExportReportNew(ds, file, path + fileName);

            });

            res.Code = "1";
            res.Data = fileName;
            return toJson(res);
        }







        [HttpPost]
        [ActionName("GetAttendanceInfo")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetAttendanceInfo(JObject obj)
        {
            Stopwatch watch = new Stopwatch();
            watch.Start();
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;



            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            ReportDownloadOperation_Model utilityModel = new ReportDownloadOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<ReportDownloadOperation_Model>(strSafeJson);
            string templatePath = AppDomain.CurrentDomain.BaseDirectory.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = "";



            file = templatePath + "员工考勤.xlt";
            if (!File.Exists(file))
            {
                res.Code = "0";
                res.Message = "模板不存在";
            }

            string path = Const.uploadServer + "/" + Const.strImage + "temp/report/";
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            //string fileName = "AccountAttendance" + this.CompanyID.ToString() + this.BranchID.ToString() + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";
            string fileName = "员工考勤_" + DateTime.Now.ToString("yyyyMMdd") + "_" + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";

            Task.Factory.StartNew(() =>
            {

                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getAttendanceInfo(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }


                ReportDownload_BLL.Instance.ExportReportNew(ds, file, path + fileName);

            });

            res.Code = "1";
            res.Data = fileName;
            return toJson(res);
        }



        [HttpPost]
        [ActionName("GetCommDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCommDetail(JObject obj)
        {
            Stopwatch watch = new Stopwatch();
            watch.Start();
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            ReportDownloadOperation_Model utilityModel = new ReportDownloadOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<ReportDownloadOperation_Model>(strSafeJson);


            string templatePath = HttpRuntime.AppDomainAppPath.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = "";



            file = templatePath + "员工业绩提成.xlt";
            if (!File.Exists(file))
            {
                res.Code = "0";
                res.Message = "模板不存在";
            }

            string path = Const.uploadServer + "/" + Const.strImage + "temp/report/";
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            //string fileName = "CommDetail" + this.CompanyID.ToString() + this.BranchID.ToString() + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";
            string fileName = "业绩提成_" + DateTime.Now.ToString("yyyyMMdd") + "_" + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";

            Task.Factory.StartNew(() =>
            {

                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getSalaryInfo(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }
                dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getCommissionSales(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }
                dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getCommissionOpt(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }
                dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getCommissionRecharge(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }

                string title = "员工工资( " + utilityModel.BeginDay.ToString("yyyy-MM-dd") + " 到 " + utilityModel.EndDay.ToString("yyyy-MM-dd") + " )";
                ReportDownload_BLL.Instance.ExportReportComm(ds, file, path + fileName, title);

            });

            res.Code = "1";
            res.Data = fileName;
            return toJson(res);
        }



        [HttpPost]
        [ActionName("GetCustomerRelation")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCustomerRelation()
        {
            Stopwatch watch = new Stopwatch();
            watch.Start();
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;


            string templatePath = AppDomain.CurrentDomain.BaseDirectory.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = "";



            file = templatePath + "顾客顾问信息表.xlt";
            if (!File.Exists(file))
            {
                res.Code = "0";
                res.Message = "模板不存在";
            }

            string path = Const.uploadServer + "/" + Const.strImage + "temp/report/";
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            //string fileName = "CustomerRelation" + this.CompanyID.ToString() + this.BranchID.ToString() + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";
            string fileName = "顾客顾问信息_" + DateTime.Now.ToString("yyyyMMdd") + "_" + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";

            Task.Factory.StartNew(() =>
            {
                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                dt = ReportDownload_BLL.Instance.getCustomerRelation(this.CompanyID, this.BranchID);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }

                ReportDownload_BLL.Instance.ExportReportNew(ds, file, path + fileName);

            });

            res.Code = "1";
            res.Data = fileName;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetServiceRate")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetServiceRate(JObject obj)
        {
            Stopwatch watch = new Stopwatch();
            watch.Start();
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            ReportDownloadOperation_Model utilityModel = new ReportDownloadOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<ReportDownloadOperation_Model>(strSafeJson);
            string templatePath = AppDomain.CurrentDomain.BaseDirectory.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = "";



            file = templatePath + "顾客评价.xlt";
            if (!File.Exists(file))
            {
                res.Code = "0";
                res.Message = "模板不存在";
            }

            string path = Const.uploadServer + "/" + Const.strImage + "temp/report/";
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            //string fileName = "ServiceRate" + this.CompanyID.ToString() + this.BranchID.ToString() + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";
            string fileName = "顾客评价_" + DateTime.Now.ToString("yyyyMMdd") + "_" + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";

            Task.Factory.StartNew(() =>
            {

                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                dt = ReportDownload_BLL.Instance.GetServiceRate(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }


                ReportDownload_BLL.Instance.ExportReportNew(ds, file, path + fileName);

            });

            res.Code = "1";
            res.Data = fileName;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetInputOrderReport")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetInputOrderReport(JObject obj)
        {
            Stopwatch watch = new Stopwatch();
            watch.Start();
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            ReportDownloadOperation_Model utilityModel = new ReportDownloadOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<ReportDownloadOperation_Model>(strSafeJson);
            string templatePath = AppDomain.CurrentDomain.BaseDirectory.ToString() + ConfigurationManager.AppSettings["DownloadTemplatePath"];
            string file = "";



            file = templatePath + "录入订单.xlt";
            if (!File.Exists(file))
            {
                res.Code = "0";
                res.Message = "模板不存在";
            }

            string path = Const.uploadServer + "/" + Const.strImage + "temp/report/";
            if (!Directory.Exists(path))
            {
                Directory.CreateDirectory(path);
            }
            //string fileName = "InputOrder" + this.CompanyID.ToString() + this.BranchID.ToString() + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";
            string fileName = "录入订单_" + DateTime.Now.ToString("yyyyMMdd") + "_" + this.UserID.ToString() + DateTime.Now.Ticks + ".xls";

            Task.Factory.StartNew(() =>
            {

                DataSet ds = new DataSet();
                DataTable dt = new DataTable();
                // 订单录入
                dt = ReportDownload_BLL.Instance.GetInputOrderReport(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }

                //储值卡充值
                dt = ReportDownload_BLL.Instance.GetRechargeReport(this.CompanyID, this.BranchID, utilityModel.BeginDay, utilityModel.EndDay);
                if (dt != null)
                {
                    ds.Tables.Add(dt);
                }
                else
                {
                    ds.Tables.Add(new DataTable());
                }

                ReportDownload_BLL.Instance.ExportReportNew(ds, file, path + fileName);

            });

            res.Code = "1";
            res.Data = fileName;
            return toJson(res);
        }
        #endregion

    }
}
