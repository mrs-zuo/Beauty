using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.Table_Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebManager.Controllers.Base;

namespace WebManager.Controllers
{
    public class NewsController : BaseController
    {
        public ActionResult GetNewsList()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.Flag = -1;// -1: 全部 0:已经结束 1:进行中 2:未开始
            utilityModel.Type = 1;// 0:Notice 1:News
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            List<Notice_Model> list = new List<Notice_Model>();
            bool issuccess = GetPostResponseNoRedirect("Notice_M", "GetNoticeList", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                PageResult<Notice_Model> res = new PageResult<Notice_Model>();
                res = JsonConvert.DeserializeObject<PageResult<Notice_Model>>(data);

                if (res.Code == "1")
                {
                    list = res.Data;
                }
            }

            return View(list);
        }

        public ActionResult EditNews()
        {
            int noticeID = HS.Framework.Common.Safe.QueryString.IntSafeQ("ID", 0);
            bool isAdd = true;

            if (noticeID > 0)
            {
                isAdd = false;
                UtilityOperation_Model utilityModel = new UtilityOperation_Model();
                utilityModel.CompanyID = this.CompanyID;
                utilityModel.ID = noticeID;
                string postJson = JsonConvert.SerializeObject(utilityModel);

                string data = "";
                ViewBag.noticeModel = null;
                bool issuccess = GetPostResponseNoRedirect("Notice_M", "GetNoticeDetail", postJson, out data, false);
                if (!issuccess)
                {
                    return RedirectUrl(data, "", false);
                }

                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<Notice_Model> res = new ObjectResult<Notice_Model>();
                    res = JsonConvert.DeserializeObject<ObjectResult<Notice_Model>>(data);

                    if (res.Code == "1")
                    {
                        ViewBag.noticeModel = res.Data;
                    }
                }
            }
            ViewBag.IsAdd = isAdd;
            return View();
        }

        public ActionResult GetNoticeList()
        {
            int flag = QueryString.IntSafeQ("flag", -1);
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.Flag = flag;// -1: 全部 0:已经结束 1:进行中 2:未开始
            utilityModel.Type = 0;// 0:Notice 1:News
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            List<Notice_Model> list = new List<Notice_Model>();
            ViewBag.Flag = flag;
            bool issuccess = GetPostResponseNoRedirect("Notice_M", "GetNoticeList", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                PageResult<Notice_Model> res = new PageResult<Notice_Model>();
                res = JsonConvert.DeserializeObject<PageResult<Notice_Model>>(data);

                if (res.Code == "1")
                {
                    list = res.Data;
                }
            }

            return View(list);
        }

        public ActionResult EditNotice()
        {
            int noticeID = HS.Framework.Common.Safe.QueryString.IntSafeQ("ID", 0);
            bool isAdd = true;

            if (noticeID > 0)
            {
                isAdd = false;
            }
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.ID = noticeID;
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            ViewBag.noticeModel = null;
            bool issuccess = GetPostResponseNoRedirect("Notice_M", "GetNoticeDetail", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<Notice_Model> res = new ObjectResult<Notice_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<Notice_Model>>(data);

                if (res.Code == "1")
                {
                    ViewBag.noticeModel = res.Data;
                }
            }

            ViewBag.IsAdd = isAdd;
            return View();
        }

        public string DeleteNews(int NoticeID)
        {
            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel.ID = NoticeID;

            string postJson = JsonConvert.SerializeObject(operationModel);

            string data = "";
            ViewBag.List = null;
            bool issuccess = GetPostResponseNoRedirect("Notice_M", "DeleteNotice", postJson, out data);

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

        public string InsertNews(string NoticeTitle, string NoticeContent, int TYPE, string StartDate = "", string EndDate = "")
        {
            Notice_Model operationModel = new Notice_Model();
            operationModel.StartDate = StringUtils.GetDateTime(StartDate);
            operationModel.EndDate = StringUtils.GetDateTime(EndDate);
            operationModel.NoticeContent = NoticeContent;
            operationModel.NoticeTitle = NoticeTitle;
            operationModel.TYPE = TYPE;

            string postJson = JsonConvert.SerializeObject(operationModel);

            string data = "";
            ViewBag.List = null;
            bool issuccess = GetPostResponseNoRedirect("Notice_M", "AddNotice", postJson, out data);

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

        public string UpdateNews(string NoticeTitle, string NoticeContent, int NoticeID, int TYPE, string StartDate = "", string EndDate = "")
        {
            Notice_Model operationModel = new Notice_Model();
            operationModel.StartDate = StringUtils.GetDateTime(StartDate);
            operationModel.EndDate = StringUtils.GetDateTime(EndDate);
            operationModel.NoticeContent = NoticeContent;
            operationModel.NoticeTitle = NoticeTitle;
            operationModel.ID = NoticeID;
            operationModel.TYPE = TYPE;

            string postJson = JsonConvert.SerializeObject(operationModel);

            string data = "";
            ViewBag.List = null;
            bool issuccess = GetPostResponseNoRedirect("Notice_M", "UpdateNotice", postJson, out data);

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
    }
}
