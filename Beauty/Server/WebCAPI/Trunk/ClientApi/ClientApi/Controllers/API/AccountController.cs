using ClientApi.Authorize;
using ClientAPI.BLL;
using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.View_Model;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace ClientApi.Controllers.API
{
    public class AccountController : BaseController
    {
        [HttpPost]
        [ActionName("getAccountListForCustomer")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getAccountListForCustomer(JObject obj)
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

            UtilityOperation_Model model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            if (model.ImageHeight <= 0)
            {
                model.ImageHeight = 160;
            }

            if (model.ImageWidth <= 0)
            {
                model.ImageWidth = 160;
            }
            List<AccountList_Model> list = Account_BLL.Instance.getAccountListForCustomer(this.CompanyID, model.BranchID, this.UserID, model.Flag, model.ImageWidth, model.ImageHeight);

            result.Code = "1";
            result.Data = list;

            return toJson(result);
        }

        [HttpPost]
        [ActionName("getAccountSchedule")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getAccountSchedule(JObject obj)
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

            UtilityOperation_Model utilityModel = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            if (utilityModel.ImageHeight <= 0)
            {
                utilityModel.ImageHeight = 160;
            }

            if (utilityModel.ImageWidth <= 0)
            {
                utilityModel.ImageWidth = 160;
            }
            List<AccountList_Model> list = Account_BLL.Instance.getAccountListByCompanyID(this.CompanyID, this.BranchID, utilityModel.TagIDs, utilityModel.ImageWidth, utilityModel.ImageHeight);

            List<AccountSchedule_Model> modelList = new List<AccountSchedule_Model>();
            List<ScheduleInAccount> scheduleList = new List<ScheduleInAccount>();
            if (list != null && list.Count > 0)
            {
                foreach (AccountList_Model item in list)
                {
                    AccountSchedule_Model model = new AccountSchedule_Model();
                    model.AccountCode = item.AccountCode;
                    model.AccountID = item.AccountID;
                    model.AccountName = item.AccountName;
                    //model.Department = item.Department;
                    model.PinYin = WebAPI.Common.CommonUtility.getWholeSpell(item.AccountName);
                    model.PinYinFirst = WebAPI.Common.CommonUtility.getFirstSpell(item.AccountName);
                    model.ScheduleList = Account_BLL.Instance.getScheduleListByAccount(item.AccountID, this.BranchID, utilityModel.Date, this.CompanyID);
                    modelList.Add(model);
                }
            }
            result.Code = "1";
            result.Data = modelList;

            return toJson(result);
        }

        [HttpPost]
        [ActionName("getAccountDetail")]
        public HttpResponseMessage getAccountDetail(JObject obj)
        {
            ObjectResult<AccountDetail_Model> result = new ObjectResult<AccountDetail_Model>();
            result.Code = "0";
            result.Message = "";
            result.Data = null;
            if (obj == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);

            UtilityOperation_Model model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (model == null || model.AccountID <= 0)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            if (model.ImageHeight <= 0)
            {
                model.ImageHeight = 160;
            }

            if (model.ImageWidth <= 0)
            {
                model.ImageWidth = 160;
            }
            AccountDetail_Model res = Account_BLL.Instance.getAccountDetail(model.AccountID, model.ImageWidth, model.ImageHeight);

            result.Code = "1";
            result.Data = res;

            return toJson(result);
        }


        [HttpPost]
        [ActionName("getAccountList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getAccountList(JObject obj)
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

            UtilityOperation_Model model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            if (model.ImageHeight <= 0)
            {
                model.ImageHeight = 160;
            }

            if (model.ImageWidth <= 0)
            {
                model.ImageWidth = 160;
            }
            List<AccountList_Model> list = Account_BLL.Instance.getAccountList_new(this.CompanyID, model.AccountID, this.BranchID, model.TagIDs, model.ImageWidth, model.ImageHeight);

            if (list != null && list.Count > 0)
            {
                int responsiblePersonID = Account_BLL.Instance.GetRelationshipByCustomerID(this.CompanyID, this.BranchID, model.CustomerID, 1);
                int salesID = Account_BLL.Instance.GetRelationshipByCustomerID(this.CompanyID, this.BranchID, model.CustomerID, 2);

                list.ForEach(x => { x.AccountType = 2; if (x.AccountID == responsiblePersonID) { x.AccountType = 0; } if (x.AccountID == salesID) { x.AccountType = 1; } });
                var objList = from u in list orderby u.AccountType ascending, u.AccountCode ascending, u.AccountName ascending select u;
                list = objList.ToList<AccountList_Model>();
            }

            result.Code = "1";
            result.Data = list;

            return toJson(result);
        }




        [HttpPost]
        [ActionName("GetAccountListByBranchID")]
        public HttpResponseMessage GetAccountListByBranchID(JObject obj)
        {
            ObjectResult<List<AccountList_Model>> result = new ObjectResult<List<AccountList_Model>>();
            result.Code = "0";
            result.Message = "";
            result.Data = null;

            if (obj == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);

            UtilityOperation_Model model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            if (model.BranchID < 1) {
                result.Message = "不合法参数";
                return toJson(result);
            }

            List<AccountList_Model> list = Account_BLL.Instance.getAccountListByBranchID(this.CompanyID,model.BranchID);

            result.Code = "1";
            result.Data = list;

            return toJson(result);
        }

    }
}
