using HS.Framework.Common;
using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
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
    public class OpportunityController : BaseController
    {
        [HttpPost]
        [ActionName("GetStepList")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage GetStepList(JObject obj)
        {
            ObjectResult<List<GetStepList_Model>> res = new ObjectResult<List<GetStepList_Model>>();

            List<GetStepList_Model> list = new List<GetStepList_Model>();
            list = Opportunity_BLL.Instance.GetStepListByCompanyID(this.CompanyID);

            if (list != null)
            {
                res.Code = "1";
                res.Message = "success";
                res.Data = list;
            }
            else
            {
                res.Code = "0";
                res.Message = "No Data!";
                res.Data = null;
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetOpportunityList")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"ProductType": -1,"FilterByTimeFlag":1,"StartTime":"2012-12-12","EndTime":"2012-12-12","PageIndex":1,"PageSize":10,"ResponsiblePersonIDs":[1,2,3,4],"CustomerID":1022}
        public HttpResponseMessage GetOpportunityList(JObject obj)
        {
            ObjectResult<OpportunityPageList_Model> res = new ObjectResult<OpportunityPageList_Model>();
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

            GetOpportunityListOperation_Model operationModel = new GetOpportunityListOperation_Model();
            operationModel = JsonConvert.DeserializeObject<GetOpportunityListOperation_Model>(strSafeJson);

            if (operationModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.PageIndex > 1 && operationModel.CreateTime == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.BranchID = this.BranchID;
            operationModel.CompanyID = this.CompanyID;
            operationModel.AccountID = this.UserID;

            if (operationModel.ResponsiblePersonIDs == null || operationModel.ResponsiblePersonIDs.Count <= 0)
            {
                operationModel.ResponsiblePersonIDs = new List<int>();
                operationModel.ResponsiblePersonIDs.Add(this.UserID);
            }

            if (operationModel.FilterByTimeFlag == 1)
            {
                if ((String.IsNullOrWhiteSpace(operationModel.StartTime) || String.IsNullOrWhiteSpace(operationModel.EndTime)))
                {
                    res.Message = "请选择日期!";
                    return toJson(res);
                }
                else
                {
                    DateTime dtStartTime = new DateTime();
                    DateTime dtEndTiime = new DateTime();
                    if (DateTime.TryParse(operationModel.StartTime, out dtStartTime) && DateTime.TryParse(operationModel.EndTime, out dtEndTiime))
                    {
                        operationModel.StartTime = dtStartTime.ToShortDateString();
                        operationModel.EndTime = dtEndTiime.ToShortDateString();
                    }
                    else
                    {
                        res.Message = "请输入正确的时间格式!";
                        return toJson(res);
                    }
                }
            }

            if (operationModel.PageIndex <= 0)
            {
                operationModel.PageIndex = 1;
            }

            if (operationModel.PageSize <= 0)
            {
                operationModel.PageSize = 10;
            }

            int recordCount = 0;

            OpportunityPageList_Model model = new OpportunityPageList_Model();
            List<OpportunityList_Model> list = new List<OpportunityList_Model>();
            list = Opportunity_BLL.Instance.getOpportunityList(operationModel, operationModel.PageSize, operationModel.PageIndex, out recordCount);

            if (list == null)
            {
                model.RecordCount = 0;
                model.PageCount = 0;
                res.Data = model;
                res.Code = "1";
            }
            else
            {
                model.RecordCount = recordCount;
                model.PageCount = Pagination.GetPageCount(recordCount, operationModel.PageSize);
                model.OpportunityList = list;
                res.Data = model;
                res.Code = "1";
            }
            return toJson(res, "yyyy-MM-dd HH:mm:ss");
        }

        [HttpPost]
        [ActionName("GetOpportunityDetail")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage GetOpportunityDetail(JObject obj)
        {
            ObjectResult<OpportunityDetail_Model> res = new ObjectResult<OpportunityDetail_Model>();
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.OpportunityID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            OpportunityDetail_Model model = new OpportunityDetail_Model();
            model = Opportunity_BLL.Instance.getOpportunityDetail(utilityModel.OpportunityID, utilityModel.ProductType);

            if (model != null)
            {
                res.Code = "1";
                res.Message = "success";
                res.Data = model;
            }
            else
            {
                res.Code = "-1";
                res.Message = "";
                res.Data = null;
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("AddOpportunity")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage AddOpportunity(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
            res.Data = false;

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

            OpportunityAddOperation_Model addmodel = new OpportunityAddOperation_Model();
            addmodel = JsonConvert.DeserializeObject<OpportunityAddOperation_Model>(strSafeJson);

            if (addmodel == null || addmodel.ProductList == null || addmodel.ProductList.Count <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (addmodel.ProductList.Where(c => c.ResponsiblePersonID == 0).ToList().Count > 0)
            {
                res.Message = "添加需求失败!";
                return toJson(res);
            }

            addmodel.CompanyID = this.CompanyID;
            addmodel.BranchID = this.BranchID;
            addmodel.AccountID = this.UserID;

            //int stepId = 0;
            //stepId = Opportunity_BLL.Instance.GetMaxStepId(addmodel.CompanyID);
            //if (stepId == 0)
            //{
            //    res.Code = "0";
            //    res.Message = "请添加商机步骤后暂存!";
            //    res.Data = false;
            //    return toJson(res);
            //}

            addmodel.CreateTime = DateTime.Now.ToLocalTime();
            //addmodel.StepID = stepId;
            addmodel.Progress = 1;
            addmodel.Available = 1;
            addmodel.Status = 0;

            bool addres = Opportunity_BLL.Instance.addOpportunity(addmodel);

            if (addres)
            {
                res.Code = "1";
                res.Message = "添加需求成功!";
                res.Data = true;
            }
            else
            {
                res.Code = "0";
                res.Message = "添加需求失败!";
                res.Data = false;
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("DeleteOpportunity")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage DeleteOpportunity(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
            res.Data = false;

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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.OpportunityID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.AccountID = this.UserID;

            bool delres = Opportunity_BLL.Instance.deleteOpportunity(utilityModel.AccountID, utilityModel.OpportunityID);

            if (delres)
            {
                res.Code = "1";
                res.Message = "删除需求成功!";
                res.Data = true;
            }
            else
            {
                res.Code = "0";
                res.Message = "删除需求失败!";
                res.Data = false;
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetProgressHistory")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage GetProgressHistory(JObject obj)
        {
            ObjectResult<List<ProgressList_Model>> res = new ObjectResult<List<ProgressList_Model>>();
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.OpportunityID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.BranchID = this.BranchID;
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.AccountID = this.UserID;


            List<ProgressList_Model> list = new List<ProgressList_Model>();
            list = Opportunity_BLL.Instance.getProgressHistory(utilityModel.OpportunityID);

            if (list != null)
            {
                res.Code = "1";
                res.Message = "success";
                res.Data = list;
            }
            else
            {
                res.Code = "0";
                res.Message = "No Data!";
                res.Data = null;
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetProgressDetail")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage GetProgressDetail(JObject obj)
        {
            ObjectResult<ProgressDetail_Model> res = new ObjectResult<ProgressDetail_Model>();
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.ProgressID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            ProgressDetail_Model model = new ProgressDetail_Model();
            model = Opportunity_BLL.Instance.getProgressDetail(utilityModel.ProgressID, utilityModel.ProductType);

            if (model != null)
            {
                res.Code = "1";
                res.Message = "success";
                res.Data = model;
            }
            else
            {
                res.Code = "-1";
                res.Message = "No data";
                res.Data = null;
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("AddProgress")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage AddProgress(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
            res.Data = false;

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

            ProgressOperation_Model addmodel = new ProgressOperation_Model();
            addmodel = JsonConvert.DeserializeObject<ProgressOperation_Model>(strSafeJson);

            if (addmodel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            addmodel.CompanyID = this.CompanyID;
            addmodel.BranchID = this.BranchID;
            addmodel.UpdaterID = this.UserID;
            addmodel.CreateTime = DateTime.Now.ToLocalTime();

            int stepNumber = Opportunity_BLL.Instance.getStepNumber(addmodel.OpportunityID);
            if (stepNumber == 0)
            {
                res.Message = "数据处理出现异常";
                return toJson(res);
            }

            if (addmodel.Progress <= stepNumber)
            {
                bool addres = Opportunity_BLL.Instance.addProgress(addmodel);

                if (addres)
                {
                    res.Code = "1";
                    res.Message = "添加需求成功!";
                    res.Data = true;
                }
                else
                {
                    res.Code = "0";
                    res.Message = "添加需求失败!";
                    res.Data = false;
                }
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("UpdateProgress")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage UpdateProgress(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
            res.Data = false;

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

            ProgressOperation_Model addmodel = new ProgressOperation_Model();
            addmodel = JsonConvert.DeserializeObject<ProgressOperation_Model>(strSafeJson);

            if (addmodel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            addmodel.Updatetime = DateTime.Now.ToLocalTime();
            addmodel.UpdaterID = this.UserID;
            addmodel.BranchID = this.BranchID;
            addmodel.CompanyID = this.CompanyID;
            addmodel.CreateTime = DateTime.Now.ToLocalTime();

            bool addres = Opportunity_BLL.Instance.updateProgress(addmodel);

            if (addres)
            {
                res.Code = "1";
                res.Message = "进度变更成功!";
                res.Data = true;
            }
            else
            {
                res.Code = "0";
                res.Message = "进度变更成功!";
                res.Data = false;
            }
            return toJson(res);
        }
    }
}
