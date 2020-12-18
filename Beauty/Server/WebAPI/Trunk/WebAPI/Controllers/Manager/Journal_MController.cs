using HS.Framework.Common.Entity;
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
using WebAPI.Controllers.API;

namespace WebAPI.Controllers.Manager
{
    public class Journal_MController : BaseController
    {
        [HttpPost]
        [ActionName("GetJournalList")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetJournalList(JObject obj)
        {
            ObjectResult<List<Journal_Account_New_Model>> res = new ObjectResult<List<Journal_Account_New_Model>>();
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

            Journal_Account_Search_Model operationModel = new Journal_Account_Search_Model();
            operationModel = JsonConvert.DeserializeObject<Journal_Account_Search_Model>(strSafeJson);

            operationModel.CompanyID = this.CompanyID;
            List<Journal_Account_New_Model> list = new List<Journal_Account_New_Model>();
            list = Journal_BLL.Instance.GetJournalList(operationModel);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetItemList")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetItemList()
        {
            ObjectResult<List<Journal_Item_Model>> res = new ObjectResult<List<Journal_Item_Model>>();
            res.Code = "0";
            res.Data = null;

            List<Journal_Item_Model> list = new List<Journal_Item_Model>();
            list = Journal_BLL.Instance.GetItemList();

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetJournalDetail")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetJournalDetail(JObject obj)
        {
            ObjectResult<JournalAccountOperation_Model> res = new ObjectResult<JournalAccountOperation_Model>();
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

            Journal_Account_Search_Model operationModel = new Journal_Account_Search_Model();
            operationModel = JsonConvert.DeserializeObject<Journal_Account_Search_Model>(strSafeJson);

            operationModel.CompanyID = this.CompanyID;
            JournalAccountOperation_Model model = new JournalAccountOperation_Model();
            model = Journal_BLL.Instance.GetJournalDetail(operationModel);

            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetDefaultAMount")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetDefaultAMount(JObject obj)
        {
            ObjectResult<Journal_Account_Defult_Amount_Model> res = new ObjectResult<Journal_Account_Defult_Amount_Model>();
            res.Code = "1";
            res.Data = null;

            if (obj == null)
            {
                Journal_Account_Defult_Amount_Model md = new Journal_Account_Defult_Amount_Model();
                md.Amount = "0.00";
                res.Message = "";
                res.Data = md;
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                Journal_Account_Defult_Amount_Model md = new Journal_Account_Defult_Amount_Model();
                md.Amount = "0.00";
                res.Message = "";
                res.Data = md;
                return toJson(res);
            }

            Journal_Account_Defult_Amount_Model operationModel = new Journal_Account_Defult_Amount_Model();
            operationModel = JsonConvert.DeserializeObject<Journal_Account_Defult_Amount_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;
            Journal_Account_Defult_Amount_Model model = new Journal_Account_Defult_Amount_Model();
            model = Journal_BLL.Instance.GetDefaultAMount(operationModel);

            res.Data = model;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetOperatorList")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetOperatorList(JObject obj)
        {
            ObjectResult<List<Account_Model>> res = new ObjectResult<List<Account_Model>>();
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

            Journal_Account_Search_Model operationModel = new Journal_Account_Search_Model();
            operationModel = JsonConvert.DeserializeObject<Journal_Account_Search_Model>(strSafeJson);

            operationModel.CompanyID = this.CompanyID;
            List<Account_Model> list = new List<Account_Model>();
            list = Journal_BLL.Instance.GetOperatorList(operationModel);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetBranchList")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetBranchList()
        {
            ObjectResult<List<Branch_Model>> res = new ObjectResult<List<Branch_Model>>();
            res.Code = "0";
            res.Data = null;

            List<Branch_Model> list = new List<Branch_Model>();
            list = Journal_BLL.Instance.GetBranchList(this.CompanyID, this.BranchID);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }






        [HttpPost]
        [ActionName("AddJournal")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage AddJournal(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "添加失败";
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

            JournalAccountOperation_Model operationModel = new JournalAccountOperation_Model();
            operationModel = JsonConvert.DeserializeObject<JournalAccountOperation_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;
            operationModel.CreatorID = this.UserID;
            operationModel.CreateTime = DateTime.Now.ToLocalTime();

            bool result  = Journal_BLL.Instance.AddJournal(operationModel);

            if (result)
            {
                res.Code = "1";
                res.Data = true; 
                res.Message = "添加成功!";
            }
            return toJson(res);
        }


        [HttpPost]
        [ActionName("UpdateJournal")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage UpdateJournal(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "更新失败";
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
            


            JournalAccountOperation_Model operationModel = new JournalAccountOperation_Model();
            operationModel = JsonConvert.DeserializeObject<JournalAccountOperation_Model>(strSafeJson);

            //判断是否已经审核成功  审核成功的不能修改
            JournalAccountOperation_Model isCheckSuccessModel = new JournalAccountOperation_Model();
            Journal_Account_Search_Model searchModel = new Journal_Account_Search_Model();
            searchModel.ID = operationModel.ID;
            isCheckSuccessModel = Journal_BLL.Instance.GetJournalDetail(searchModel);
            if (isCheckSuccessModel.CheckResult == 1) {
                res.Message = "已经审核成功的数据记录不能修改!";
                return toJson(res);
            }

            operationModel.CompanyID = this.CompanyID;
            operationModel.UpdaterID = this.UserID;
            operationModel.UpdateTime = DateTime.Now.ToLocalTime();

            bool result = Journal_BLL.Instance.UpdateJournal(operationModel);

            if (result)
            {
                res.Code = "1";
                res.Data = true;
                res.Message = "更新成功!";
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("DeleteJournal")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage DeleteJournal(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "删除失败";
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

            JournalAccountOperation_Model operationModel = new JournalAccountOperation_Model();
            operationModel = JsonConvert.DeserializeObject<JournalAccountOperation_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;

            //判断是否已经审核成功  审核成功的不能删除
            JournalAccountOperation_Model isCheckSuccessModel = new JournalAccountOperation_Model();
            Journal_Account_Search_Model searchModel = new Journal_Account_Search_Model();
            searchModel.ID = operationModel.ID;
            searchModel.CompanyID = this.CompanyID;
            isCheckSuccessModel = Journal_BLL.Instance.GetJournalDetail(searchModel);
            if (isCheckSuccessModel.CheckResult == 1)
            {
                res.Message = "已经审核成功的数据记录不能删除!";
                return toJson(res);
            }

            bool result = Journal_BLL.Instance.DeleteJournal(operationModel);

            if (result)
            {
                res.Code = "1";
                res.Data = true;
                res.Message = "删除成功!";
            }
            return toJson(res);
        }

    }
}
