using HS.Framework.Common;
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
    public class NotepadController : BaseController
    {
        //[HttpPost]
        //[ActionName("getNotepadList")]
        //[HTTPBasicAuthorize]
        //public HttpResponseMessage getNotepadList(JObject obj)
        //{
        //    ObjectResult<object> result = new ObjectResult<object>();
        //    result.Code = "0";
        //    result.Message = "";
        //    result.Data = null;
        //    if (obj == null)
        //    {
        //        result.Message = "不合法参数";
        //        return toJson(result);
        //    }

        //    string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
        //    if (string.IsNullOrEmpty(strSafeJson))
        //    {
        //        result.Message = "不合法参数";
        //        return toJson(result);
        //    }

        //    NotepadListOperation_Model model = new NotepadListOperation_Model();
        //    model = Newtonsoft.Json.JsonConvert.DeserializeObject<NotepadListOperation_Model>(strSafeJson);
        //    model.CompanyID = this.CompanyID;
        //    model.BranchID = this.BranchID;

        //    if (model == null || model.CompanyID <= 0 || model.BranchID <= 0)
        //    {
        //        result.Message = "不合法参数";
        //        return toJson(result);
        //    }

        //    ObjectResult<object> objResult = Notepad_BLL.Instance.getNotepadList(model);
        //    if (objResult.Code == "1")
        //    {
        //        result.Code = "1";
        //        result.Data = objResult.Data;
        //    }

        //    return toJson(result);

        //}

        [HttpPost]
        [ActionName("GetNotepadList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetNotepadList(JObject obj)
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

            NotepadListOperation_Model utilityModel = new NotepadListOperation_Model();
            utilityModel = Newtonsoft.Json.JsonConvert.DeserializeObject<NotepadListOperation_Model>(strSafeJson);

            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;
            if (utilityModel.AccountID <= 0 || utilityModel.CompanyID <= 0 || (utilityModel.BranchID == 0 && utilityModel.CustomerID == 0))
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

            if (this.IsBusiness)
            {
                if (!utilityModel.IsShowAll)
                {
                    if (utilityModel.ResponsiblePersonIDs == null || utilityModel.ResponsiblePersonIDs.Count <= 0)
                    {
                        utilityModel.ResponsiblePersonIDs = new List<int>();
                        utilityModel.ResponsiblePersonIDs.Add(this.UserID);
                    }
                }
            }
            else
            {
                utilityModel.CustomerID = this.UserID;
            }

            int recordCount = 0;
            GetNotepadListByAccount_Model model = new GetNotepadListByAccount_Model();
            List<NotepadList_Model> list = new List<NotepadList_Model>();
            list = Notepad_BLL.Instance.getNotepadListByAccountID(utilityModel, utilityModel.PageSize, utilityModel.PageIndex, out recordCount);
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
                model.NotepadList = list;
                result.Data = model;
                result.Code = "1";
            }
            return toJson(result);
        }

        [HttpPost]
        [ActionName("addNotepad")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage addNotepad(JObject obj)
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

            Notepad_Model model = new Notepad_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<Notepad_Model>(strSafeJson);
            model.CreateTime = DateTime.Now.ToLocalTime();
            model.CompanyID = this.CompanyID;
            model.BranchID = this.BranchID;

            if (model == null || model.CompanyID <= 0 || model.BranchID <= 0)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            if (model.TagIDs.Split('|').Length <= 5)
            {
                bool blResult = Notepad_BLL.Instance.addNotepad(model);
                if (blResult)
                {
                    result.Code = "1";
                    result.Message = "添加记事本成功！";
                }
            }
            else
            {
                result.Message = "标签个数不能超过三个！";
            }
            return toJson(result);

        }

        [HttpPost]
        [ActionName("updateNotepad")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage updateNotepad(JObject obj)
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

            Notepad_Model model = new Notepad_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<Notepad_Model>(strSafeJson);
            model.UpdateTime = DateTime.Now.ToLocalTime();

            if (model.TagIDs.Split('|').Length <= 5)
            {
                bool blResult = Notepad_BLL.Instance.updateNotepad(model);
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
        [ActionName("deleteNotepad")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage deleteNotepad(JObject obj)
        {
            ObjectResult<bool> result = new ObjectResult<bool>();
            result.Code = "0";
            result.Message = "删除记事本失败！";
            result.Data = false;

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

            NotepadDeleteOperation_Model model = new NotepadDeleteOperation_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<NotepadDeleteOperation_Model>(strSafeJson);
            model.UpdateTime = DateTime.Now.ToLocalTime();
            model.UpdaterID = this.UserID;
            model.CompanyID = this.CompanyID;
            if (model.ID != 0)
            {
                bool blResult = Notepad_BLL.Instance.deleteNotepad(model);
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
