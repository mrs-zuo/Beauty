using HS.Framework.Common.Entity;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebManager.Controllers.Base;
using Model.Table_Model;
using HS.Framework.Common.Util;
using HS.Framework.Common.Safe;
using WebManager.Models;

namespace WebManager.Controllers
{
    public class PaperController : BaseController
    {

        public ActionResult GetPaperList()
        {
            List<PaperTable_Model> list = new List<PaperTable_Model>();
            string data = "";
            bool issuccess = GetPostResponseNoRedirect("Paper_M", "GetPaperList", "", out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<PaperTable_Model>> res = new ObjectResult<List<PaperTable_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<PaperTable_Model>>>(data);
                if (res.Code == "1")
                {
                    list = res.Data;
                }
            }

            string srtCookie = CookieUtil.GetCookieValue("HSManger", true);
            Cookie_Model cookieModel = new Cookie_Model();
            if (!string.IsNullOrWhiteSpace(srtCookie))
            {
                cookieModel = JsonConvert.DeserializeObject<Cookie_Model>(srtCookie);
            }

            ViewBag.IsAdd = false;
            if (cookieModel.Advanced.Contains("|1|"))
            {
                ViewBag.IsAdd = true;
            }
            else if (!cookieModel.Advanced.Contains("|1|") && list.Count == 0)
            {
                ViewBag.IsAdd = true;
            }


            return View(list);
        }


        public ActionResult EditPaper()
        {
            PaperTable_Model controlModel = new PaperTable_Model();
            controlModel.ID = StringUtils.GetDbInt(QueryString.IntSafeQ("PaperID").ToString(), -1);
            string postJson;
            string data = "";
            bool issuccess = false;
            if (controlModel.ID > 0)
            {
                postJson = JsonConvert.SerializeObject(controlModel);
                issuccess = GetPostResponseNoRedirect("Paper_M", "GetPaperDetail", postJson, out data);
                if (!issuccess)
                {
                    return RedirectUrl(data, "", false);
                }

                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<PaperTable_Model> res = new ObjectResult<PaperTable_Model>();
                    res = JsonConvert.DeserializeObject<ObjectResult<PaperTable_Model>>(data);
                    if (res.Code == "1")
                    {
                        ViewBag.PaperDetail = res.Data;
                    }
                }
            }
            return View();
        }

        public ActionResult GetQuestionList()
        {
            ObjectResult<List<Question_Model>> res = new ObjectResult<List<Question_Model>>();
            Question_Model mQues = new Question_Model();
            mQues.QuestionType = -1;
            string postJson = JsonConvert.SerializeObject(mQues);
            string data = "";
            bool issuccess = GetPostResponseNoRedirect("Queston_M", "GetQuestionList", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }

        }

        public ActionResult DeletePaper(int PaperId)
        {
            PaperTable_Model mPaper = new PaperTable_Model();
            mPaper.ID = PaperId;

            string postJson = JsonConvert.SerializeObject(mPaper);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            res.Message = "删除失败";
            issuccess = GetPostResponseNoRedirect("Paper_M", "DeletePaper", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult ControlPaper(PaperTable_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            if (model.ID > 0)
            {
                res.Message = "修改失败";
                issuccess = GetPostResponseNoRedirect("Paper_M", "UpdatePaper", postJson, out data);
            }
            else
            {
                res.Message = "新增失败";
                issuccess = GetPostResponseNoRedirect("Paper_M", "AddPaper", postJson, out data);

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

    }
}
