using HS.Framework.Common.Entity;
using Model.Operation_Model;
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
    public class StatisticsController : BaseController
    {
        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"CustomerID": 11722,"ObjectType":0,"StartTime": "","EndTime": "","MonthCount": 0,"ExtractItemType":1}</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetDataStatisticsList")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetDataStatisticsList(JObject obj)
        {
            ObjectResult<List<Statistics_Model>> res = new ObjectResult<List<Statistics_Model>>();
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

            StatisticsOperation_Model operationModel = new StatisticsOperation_Model();
            operationModel = JsonConvert.DeserializeObject<StatisticsOperation_Model>(strSafeJson);

            if (operationModel.CustomerID < 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.CompanyID = this.CompanyID;
            operationModel.BranchID = this.BranchID;

            List<Statistics_Model> list = new List<Statistics_Model>();

            switch (operationModel.ExtractItemType)
            {
                case 1:
                    list = Statistics_BLL.Instance.getConsumeStatisticsByObejctName(operationModel);
                    break;
                case 2:
                    list = Statistics_BLL.Instance.getConsumeStatisticsByPrice(operationModel);
                    break;
                case 3:
                    if (operationModel.MonthCount < 6)
                    {
                        operationModel.MonthCount = 6;
                    }
                    if (string.IsNullOrEmpty(operationModel.EndTime))
                    {
                        operationModel.EndTime = DateTime.Now.ToLocalTime().ToShortDateString();
                    }
                    list = Statistics_BLL.Instance.getConsumeStatisticsByMonth(operationModel);
                    break;
                case 4:
                    if (operationModel.MonthCount < 3)
                    {
                        operationModel.MonthCount = 3;
                    }
                    if (string.IsNullOrEmpty(operationModel.EndTime))
                    {
                        operationModel.EndTime = DateTime.Now.ToLocalTime().ToShortDateString();
                    }
                    list = Statistics_BLL.Instance.getConsumeStatisticsByMonth(operationModel);
                    break;

            }

            res.Code = "1";
            res.Data = list;
            return toJson(res);

        }


        [HttpPost]
        [ActionName("GetBranchDataStatisticsList")]
        /// <param name="obj">{"ObjectType":0,"StartTime": "","EndTime": "","MonthCount": 0,"ExtractItemType":1}</param>
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetBranchDataStatisticsList(JObject obj)
        {
            ObjectResult<List<Statistics_Model>> res = new ObjectResult<List<Statistics_Model>>();
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

            StatisticsOperation_Model operationModel = new StatisticsOperation_Model();
            operationModel = JsonConvert.DeserializeObject<StatisticsOperation_Model>(strSafeJson);

            if (operationModel.CustomerID < 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.CompanyID = this.CompanyID;
            operationModel.BranchID = this.BranchID;

            string startTime = "";
            string endTime = "";
            //画面筛选的时间条件StartTime EndTime处理
            if ((String.IsNullOrWhiteSpace(operationModel.StartTime) || String.IsNullOrWhiteSpace(operationModel.EndTime)))
            {
                res.Message = "请选择日期";
                return toJson(res);
            }
            else
            {
                DateTime dtStartTime = new DateTime();
                DateTime dtEndTime = new DateTime();
                if (DateTime.TryParse(operationModel.StartTime, out dtStartTime) && DateTime.TryParse(operationModel.EndTime, out dtEndTime))
                {
                    startTime = dtStartTime.ToShortDateString();
                    endTime = dtEndTime.ToShortDateString();
                    startTime += " 0:00:00";
                    endTime += " 23:59:59";
                }
                else
                {
                    res.Message = "请输入正确的时间格式";
                    return toJson(res);
                }
            }
            
            List<Statistics_Model> list = new List<Statistics_Model>();

            switch (operationModel.ExtractItemType)
            {
                case 1:
                    list = Statistics_BLL.Instance.getBranchBusinessStatistics(operationModel, endTime);
                    break;
                case 2:
                    switch (operationModel.ObjectType)
                    {
                        case 1:
                            if (operationModel.AccountID == 0)
                            {
                                list = Statistics_BLL.Instance.getBranchBusinessStatisticsTMCount(operationModel, startTime, endTime);
                            }
                            else
                            {
                                list = Statistics_BLL.Instance.getBranchBusinessStatisticsTMCountMonth(operationModel, startTime, endTime);
                            }
                            break;
                        case 2:
                            if (operationModel.AccountID == 0)
                            {
                                list = Statistics_BLL.Instance.getBranchBusinessStatisticsConsume(operationModel, startTime, endTime);
                            }
                            else
                            {
                                list = Statistics_BLL.Instance.getBranchBusinessStatisticsConsumeMonth(operationModel, startTime, endTime);
                            }
                            break;
                        case 3:
                            if (operationModel.AccountID == 0)
                            {
                                list = Statistics_BLL.Instance.getBranchBusinessStatisticsRecharge(operationModel, startTime, endTime);
                            }
                            else
                            {
                                list = Statistics_BLL.Instance.getBranchBusinessStatisticsRechargeMonth(operationModel, startTime, endTime);
                            }
                            break;
                    }
                    break;
                case 3:
                    list = Statistics_BLL.Instance.getBranchBusinessStatisticsProduct(operationModel, startTime, endTime);
                    break;

            }

            res.Code = "1";
            res.Data = list;
            return toJson(res);

        }


    }
}
