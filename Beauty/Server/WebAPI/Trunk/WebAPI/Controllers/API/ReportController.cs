using HS.Framework.Common;
using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using WebAPI.Authorize;
using WebAPI.BLL;

namespace WebAPI.Controllers.API
{
    public class ReportController : BaseController
    {
        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"AccountID": 27,"CycleType": 4,"StartTime": "2014-01-01",EndTime": "2014-12-31"}</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetReportList_1_7_2")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetReportList_1_7_2(JObject obj)
        {
            ObjectResult<List<GetReportList_Model>> res = new ObjectResult<List<GetReportList_Model>>();
            res.Code = "0";
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

            ReportOperation_Model operationModel = new ReportOperation_Model();
            operationModel = JsonConvert.DeserializeObject<ReportOperation_Model>(strSafeJson);

            if (operationModel.AccountID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ObjectType < 0 || operationModel.ObjectType > 3)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }


            if (operationModel.CycleType < 0 || operationModel.CycleType > 4)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }



            string startTime = "";
            string endtime = "";
            if (operationModel.CycleType == 4)
            {
                if ((String.IsNullOrWhiteSpace(operationModel.StartTime) || String.IsNullOrWhiteSpace(operationModel.EndTime)))
                {
                    res.Message = "请选择日期";
                    return toJson(res);
                }
                else
                {
                    DateTime dtStartTime = new DateTime();
                    DateTime dtEndTiime = new DateTime();
                    if (DateTime.TryParse(operationModel.StartTime, out dtStartTime) && DateTime.TryParse(operationModel.EndTime, out dtEndTiime))
                    {
                        startTime = dtStartTime.ToShortDateString();
                        endtime = dtEndTiime.ToShortDateString();
                    }
                    else
                    {
                        res.Message = "请输入正确的时间格式";
                        return toJson(res);
                    }
                }
            }

            List<GetReportList_Model> list = new List<GetReportList_Model>();
            if (operationModel.ObjectType == 0)
            {
                list = Report_BLL.Instance.getAccountReportList(operationModel.AccountID, operationModel.CycleType, startTime, endtime, this.BranchID);
            }
            else if (operationModel.ObjectType == 3)
            {
                List<TagList_Model> tagList = new List<TagList_Model>();
                tagList = Tag_BLL.Instance.getTagList(this.CompanyID, 2, this.BranchID, false);

                if (tagList != null)
                {
                    foreach (TagList_Model item in tagList)
                    {
                        GetReportList_Model model = new GetReportList_Model();

                        model.ObjectID = item.ID;
                        model.ObjectName = item.Name;
                        list.Add(model);
                    }

                }
            }


            res.Data = list;
            res.Code = "1";
            return toJson(res);
        }


        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"AccountID": 27,"CycleType": 4,"StartTime": "2014-01-01","EndTime": "2014-12-31","ObjectType":1}</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetReportBasic_2_1")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetReportBasic_2_1(JObject obj)
        {
            ObjectResult<GetReportBasic_Model> res = new ObjectResult<GetReportBasic_Model>();
            res.Code = "0";
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

            ReportOperation_Model operationModel = new ReportOperation_Model();
            operationModel = JsonConvert.DeserializeObject<ReportOperation_Model>(strSafeJson);

            if (operationModel.AccountID < 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }


            if (operationModel.CycleType < 0 || operationModel.CycleType > 4)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }


            if (operationModel.ObjectType < 0 || operationModel.ObjectType > 3)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string startTime = "";
            string endtime = "";
            if (operationModel.CycleType == 4)
            {
                if ((String.IsNullOrWhiteSpace(operationModel.StartTime) || String.IsNullOrWhiteSpace(operationModel.EndTime)))
                {
                    res.Message = "请选择日期";
                    return toJson(res);
                }
                else
                {
                    DateTime dtStartTime = new DateTime();
                    DateTime dtEndTiime = new DateTime();
                    if (DateTime.TryParse(operationModel.StartTime, out dtStartTime) && DateTime.TryParse(operationModel.EndTime, out dtEndTiime))
                    {
                        startTime = dtStartTime.ToShortDateString();
                        endtime = dtEndTiime.ToShortDateString();
                    }
                    else
                    {
                        res.Message = "请输入正确的时间格式";
                        return toJson(res);
                    }
                }
            }

            GetReportBasic_Model model = new GetReportBasic_Model();
            if (operationModel.ExtractItemType == 1)
            {
                model = Report_BLL.Instance.getReportBasic(operationModel.AccountID, this.BranchID, operationModel.ObjectType, operationModel.CycleType, startTime, endtime, this.CompanyID,operationModel.StatementCategoryID);
            }
            else if (operationModel.ExtractItemType == 2) {
                model = Report_BLL.Instance.getEcardBasic(operationModel.AccountID, this.BranchID, operationModel.ObjectType, operationModel.CycleType, startTime, endtime, this.CompanyID);
            }
            else if (operationModel.ExtractItemType == 3) {
                model = Report_BLL.Instance.getCustomerBasic(operationModel.AccountID, this.BranchID, operationModel.ObjectType, operationModel.CycleType, startTime, endtime, this.CompanyID);
            }


            res.Data = model;
            res.Code = "1";
            return toJson(res);

        }

        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"AccountID": 1304,"ObjectType":0,"CycleType": 4,"StartTime": "2014-03-01","EndTime": "2015-12-31","OrderType":1,"ProductType":1,"ExtractItemType":3,"SortType":1}</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetReportDetail_1_7_2")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetReportDetail_1_7_2(JObject obj)
        {
            ObjectResult<GetReportDetail_Model> res = new ObjectResult<GetReportDetail_Model>();
            res.Code = "0";
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

            ReportOperation_Model operationModel = new ReportOperation_Model();
            operationModel = JsonConvert.DeserializeObject<ReportOperation_Model>(strSafeJson);

            if (operationModel.AccountID < 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.CycleType < 0 || operationModel.CycleType > 4)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }


            if (operationModel.ObjectType < 0 || operationModel.ObjectType > 3)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            if (operationModel.OrderType < 0 || operationModel.OrderType > 1)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            if (operationModel.ProductType < 0 || operationModel.ProductType > 1)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            if (operationModel.ExtractItemType < 0 || operationModel.ExtractItemType > 5)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.SortType < 1 || operationModel.SortType > 2)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string startTime = "";
            string endtime = "";
            if (operationModel.CycleType == 4)
            {
                if ((String.IsNullOrWhiteSpace(operationModel.StartTime) || String.IsNullOrWhiteSpace(operationModel.EndTime)))
                {
                    res.Message = "请选择日期";
                    return toJson(res);
                }
                else
                {
                    DateTime dtStartTime = new DateTime();
                    DateTime dtEndTiime = new DateTime();
                    if (DateTime.TryParse(operationModel.StartTime, out dtStartTime) && DateTime.TryParse(operationModel.EndTime, out dtEndTiime))
                    {
                        startTime = dtStartTime.ToShortDateString();
                        endtime = dtEndTiime.ToShortDateString();
                    }
                    else
                    {
                        res.Message = "请输入正确的时间格式";
                        return toJson(res);
                    }
                }
            }

            GetReportDetail_Model model = new GetReportDetail_Model();

            if (operationModel.ExtractItemType == 2)
            {

                #region 抽取服务次数的详细
                //按服务名取
                model = Report_BLL.Instance.getServiceCountDeatail(operationModel.AccountID, this.BranchID, operationModel.ObjectType, operationModel.CycleType, startTime, endtime, this.CompanyID, operationModel.StatementCategoryID);

                #endregion
            }
            else if (operationModel.ExtractItemType == 1 || operationModel.ExtractItemType == 0)
            {
                if (operationModel.OrderType == 0)
                {
                    model = Report_BLL.Instance.getCustomerReportDetail(operationModel.AccountID, this.BranchID, operationModel.CycleType, startTime, endtime, operationModel.ProductType, operationModel.ObjectType, operationModel.SortType, this.CompanyID,operationModel.StatementCategoryID);

                }
                else if (operationModel.OrderType == 1)
                {
                    model = Report_BLL.Instance.getOrderReportDetail(operationModel.AccountID, this.BranchID, this.CompanyID, operationModel.CycleType, startTime, endtime, operationModel.ProductType, operationModel.ExtractItemType, operationModel.ObjectType, operationModel.SortType, operationModel.StatementCategoryID);
                }
            }
            else if (operationModel.ExtractItemType == 3)
            {
                model = Report_BLL.Instance.getBalanceReportDetail(operationModel.AccountID, operationModel.CycleType, startTime, endtime, this.BranchID, operationModel.ObjectType);
            }
            else if (operationModel.ExtractItemType == 4)
            {
                model = Report_BLL.Instance.getServiceExecuteDetail(operationModel.AccountID, operationModel.CycleType, startTime, endtime, this.BranchID, operationModel.ObjectType, operationModel.SortType, this.CompanyID, operationModel.StatementCategoryID);
            }
            else if (operationModel.ExtractItemType == 5)
            {
                model = Report_BLL.Instance.getCustomerTreatmentDetail(operationModel.AccountID, operationModel.CycleType, startTime, endtime, this.BranchID, operationModel.ObjectType, this.CompanyID, operationModel.StatementCategoryID);
            }

            res.Code = "1";
            res.Data = model;
            return toJson(res);

        }

        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [ActionName("getTotalCountReport")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage getTotalCountReport()
        {
            ObjectResult<ReportBranchCount_Model> res = new ObjectResult<ReportBranchCount_Model>();
            res.Code = "0";
            res.Data = null;

            ReportBranchCount_Model model = new ReportBranchCount_Model();

            model = Report_BLL.Instance.getTotalCountReport(this.CompanyID, this.BranchID);

            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }

            /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"CycleType": 4,"StartTime": "2015-07-01","EndTime": "2015-12-31"}</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetBranchBusinessDetail")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetBranchBusinessDetail(JObject obj)
        {
            ObjectResult<GetBranchBusinessDetail_Model> res = new ObjectResult<GetBranchBusinessDetail_Model>();
            res.Code = "0";
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

            ReportOperation_Model operationModel = new ReportOperation_Model();
            operationModel = JsonConvert.DeserializeObject<ReportOperation_Model>(strSafeJson);


            if (operationModel.CycleType < 0 || operationModel.CycleType > 4)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string startTime = "";
            string endtime = "";
            if (operationModel.CycleType == 4)
            {
                if ((String.IsNullOrWhiteSpace(operationModel.StartTime) || String.IsNullOrWhiteSpace(operationModel.EndTime)))
                {
                    res.Message = "请选择日期";
                    return toJson(res);
                }
                else
                {
                    DateTime dtStartTime = new DateTime();
                    DateTime dtEndTiime = new DateTime();
                    if (DateTime.TryParse(operationModel.StartTime, out dtStartTime) && DateTime.TryParse(operationModel.EndTime, out dtEndTiime))
                    {
                        startTime = dtStartTime.ToShortDateString();
                        endtime = dtEndTiime.ToShortDateString();
                    }
                    else
                    {
                        res.Message = "请输入正确的时间格式";
                        return toJson(res);
                    }
                }
            }

            GetBranchBusinessDetail_Model model = new GetBranchBusinessDetail_Model();
            model = Report_BLL.Instance.getBranchBusinessDetail(operationModel.CycleType, startTime, endtime, this.BranchID, this.CompanyID);


            res.Data = model;
            res.Code = "1";
            return toJson(res);
        }



        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetStatementCategory")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetStatementCategory()
        {
            ObjectResult<List<StatementCategory_Model>> res = new ObjectResult<List<StatementCategory_Model>>();
            res.Code = "0";
            res.Data = null;

            List<StatementCategory_Model> list = new List<StatementCategory_Model>();
            list = Statement_BLL.Instance.getStatementCategoryList(this.CompanyID);

            res.Data = list;
            res.Code = "1";
            return toJson(res);
        }





        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetCardInfo")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetCardInfo()
        {
            ObjectResult<List<CardInfo_Model>> res = new ObjectResult<List<CardInfo_Model>>();
            res.Code = "0";
            res.Data = null;

            List<CardInfo_Model> list = new List<CardInfo_Model>();
            list = Report_BLL.Instance.getCardInfo(this.CompanyID,this.BranchID);

            res.Data = list;
            res.Code = "1";
            return toJson(res);
        }

        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetAccountCommProfit")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetAccountCommProfit(JObject obj)
        {
            ObjectResult<GetCommissionProfit_Model> res = new ObjectResult<GetCommissionProfit_Model>();
            res.Code = "0";
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

            ReportOperation_Model operationModel = new ReportOperation_Model();
            operationModel = JsonConvert.DeserializeObject<ReportOperation_Model>(strSafeJson);


            GetCommissionProfit_Model model = new GetCommissionProfit_Model();
            model = Report_BLL.Instance.GetAccountCommProfit(this.CompanyID,this.UserID,operationModel.StartTime,operationModel.EndTime,this.BranchID);


            res.Data = model;
            res.Code = "1";
            return toJson(res);
        }

        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetJournalInfo")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetJournalInfo(JObject obj)
        {
            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            ObjectResult<JournalInfo_Model> res = new ObjectResult<JournalInfo_Model>();
            res.Code = "0";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }


            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            ReportOperation_Model operationModel = new ReportOperation_Model();
            operationModel = JsonConvert.DeserializeObject<ReportOperation_Model>(strSafeJson);
            //照顾安卓端的财务数据总览画面没有更新
            int CycleType = strSafeJson.IndexOf("CycleType");
            if (CycleType == -1)
            {
                operationModel.CycleType = 4;
            }
            JournalInfo_Model model = new JournalInfo_Model();
            model = Report_BLL.Instance.GetJournalInfo(this.CompanyID, operationModel.StartTime, operationModel.EndTime, this.BranchID, operationModel.CycleType);
            res.Data = model;
            res.Code = "1";
            return toJson(res);
        }

    }
}
