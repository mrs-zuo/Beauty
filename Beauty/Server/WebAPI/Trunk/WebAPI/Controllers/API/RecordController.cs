using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
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
    public class RecordController : BaseController
    {
        [HttpPost]
        [ActionName("getRecordListByCustomerID")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getRecordListByCustomerID(JObject obj)
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "0";
            result.Message = "";
            result.Data = null;

            if (obj == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            UtilityOperation_Model model = new UtilityOperation_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.BranchID = this.BranchID;

            if (model == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            List<RecordListByCustomerID_Model> list = Record_BLL.Instance.getRecordListByCustomerID(model.CustomerID, this.IsBusiness, model.TagIDs);
            result.Code = "1";
            result.Data = list;


            return toJson(result);

        }

        [HttpPost]
        [ActionName("getRecordListByAccountID")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getRecordListByAccountID(JObject obj)
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "0";
            result.Message = "";
            result.Data = null;

            if (obj == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;
            utilityModel.AccountID = this.UserID;
            if (utilityModel == null||(utilityModel.BranchID == 0 && utilityModel.CustomerID == 0))
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            if (StringUtils.GetDbInt(utilityModel.PageIndex) <= 0)
            {
                utilityModel.PageIndex = 1;
            }

            if (StringUtils.GetDbInt(utilityModel.PageSize) <= 0)
            {
                utilityModel.PageSize = 10;
            }

            if (utilityModel.FilterByTimeFlag == 1)
            {
                if ((String.IsNullOrWhiteSpace(utilityModel.StartTime) || String.IsNullOrWhiteSpace(utilityModel.EndTime)))
                {
                    result.Message = "请选择日期!";
                    return toJson(result);
                }
                else
                {
                    DateTime dtStartTime = new DateTime();
                    DateTime dtEndTiime = new DateTime();
                    if (DateTime.TryParse(utilityModel.StartTime, out dtStartTime) && DateTime.TryParse(utilityModel.EndTime, out dtEndTiime))
                    {
                        utilityModel.StartTime = dtStartTime.ToShortDateString();
                        utilityModel.EndTime = dtEndTiime.ToShortDateString();
                    }
                    else
                    {
                        result.Message = "请输入正确的时间格式!";
                        return toJson(result);
                    }
                }
            }

            RecordListByAccountID_Model model = new RecordListByAccountID_Model();

            int recordCount = 0;
            List<RecordList> list = Record_BLL.Instance.getRecordListByAccountID(utilityModel, utilityModel.PageSize, utilityModel.PageIndex, out recordCount);

            if (list == null || list.Count <= 0 || recordCount <= 0)
            {
                model.RecordCount = 0;
                model.PageCount = 0;
                result.Data = model;
                result.Code = "1";
            }
            else
            {
                model.RecordCount = recordCount;
                model.PageCount = Pagination.GetPageCount(recordCount, utilityModel.PageSize);
                model.RecordList = list;
                result.Data = model;
                result.Code = "1";
            }
            return toJson(result);

        }

        [HttpPost]
        [ActionName("addRecord")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage addRecord(JObject obj)
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "0";
            result.Message = "添加失败！";
            result.Data = null;

            if (obj == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            Record_Model model = new Record_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<Record_Model>(strSafeJson);
            model.CreateTime = DateTime.Now.ToLocalTime();
            model.CompanyID = this.CompanyID;
            model.BranchID = this.BranchID;
            model.CreatorID = this.UserID;

            if (model == null || model.CompanyID <= 0 || model.BranchID <= 0)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            if (model.TagIDs.Split('|').Length <= 5)
            {
                bool blResult = Record_BLL.Instance.addRecord(model);
                if (blResult)
                {
                    result.Code = "1";
                    result.Message = "添加咨询记录成功！";
                }
            }
            else
            {
                result.Message = "标签个数不能超过三个！";
            }

            return toJson(result);
        }

        [HttpPost]
        [ActionName("updateRecord")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage updateRecord(JObject obj)
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "0";
            result.Message = "添加失败！";
            result.Data = null;

            if (obj == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            Record_Model model = new Record_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<Record_Model>(strSafeJson);
            model.UpdateTime = DateTime.Now.ToLocalTime();
            model.UpdaterID = this.UserID;
            model.CompanyID = this.CompanyID;

            if (model.TagIDs.Split('|').Length <= 5)
            {
                bool blResult = Record_BLL.Instance.updateRecord(model);
                if (blResult)
                {
                    result.Code = "1";
                    result.Message = "更新记事本成功！";
                }
            }
            else
            {
                result.Message = "标签个数不能超过三个！";
            }

            return toJson(result);

        }

        [HttpPost]
        [ActionName("deleteRecord")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage deleteRecord(JObject obj)
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "0";
            result.Message = "添加失败！";
            result.Data = null;
            if (obj == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            UtilityOperation_Model model = new UtilityOperation_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            if (model.ID != 0)
            {
                bool blResult = Record_BLL.Instance.deleteRecord(model.RecordID, this.UserID,this.CompanyID);
                if (blResult)
                {
                    result.Code = "1";
                    result.Message = "删除记事本成功！";
                }
            }

            return toJson(result);

        }
    }
}
