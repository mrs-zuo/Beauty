using HS.Framework.Common.Entity;
using Model.Table_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Mvc;
using WebManager.Controllers.Base;

namespace WebManager.Controllers
{
    public class QuestionController : BaseController
    {
        //
        // GET: /Question/

        public ActionResult GetQuestionList()
        {
            Question_Model model = new Question_Model();
            model.QuestionType = HS.Framework.Common.Safe.QueryString.IntSafeQ("QuestionType", -1);
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            bool issuccess = GetPostResponseNoRedirect("Queston_M", "GetQuestionList", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            ObjectResult<List<Question_Model>> res = new ObjectResult<List<Question_Model>>();
            res = JsonConvert.DeserializeObject<ObjectResult<List<Question_Model>>>(data);
            if (res.Code.Equals("1"))
            {
                return View(res.Data);
            }

            return View();
        }

        public ActionResult EditQuestion()
        {
            Question_Model model = new Question_Model();
            model.ID = HS.Framework.Common.Safe.QueryString.IntSafeQ("ID", -1);
            if (model.ID > 0)
            {
                string postJson = JsonConvert.SerializeObject(model);
                string data = string.Empty;
                bool issuccess = GetPostResponseNoRedirect("Queston_M", "GetQuestionDetail", postJson, out data, false);
                if (!issuccess)
                {
                    return RedirectUrl(data, "", false);
                }

                ObjectResult<Question_Model> res = new ObjectResult<Question_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<Question_Model>>(data);
                if (res.Code.Equals("1"))
                {
                    res.Data.QuestionContent = res.Data.QuestionContent.Replace("|", "\r\n");
                    return View(res.Data);
                }
            }
            return View();
        }

        public ActionResult AddQuestion(Question_Model model)
        {
            model.QuestionContent = string.IsNullOrEmpty(model.QuestionContent) ? "" : model.QuestionContent.Replace("\n", "|").Replace("\r", "|").Replace("\r\n", "|").Replace("||", "|");
            model.QuestionContent = string.IsNullOrEmpty(model.QuestionContent) ? "" : string.Join("|", model.QuestionContent.Split(new string[] { "|" }, StringSplitOptions.RemoveEmptyEntries));
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "新增失败";
            bool issuccess = GetPostResponseNoRedirect("Queston_M", "AddQuerstion", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult UpdateQuestion(Question_Model model)
        {
            model.QuestionContent = string.IsNullOrEmpty(model.QuestionContent) ? "" : model.QuestionContent.Replace("\n", "|").Replace("\r", "|").Replace("\r\n", "|");
            model.QuestionContent = string.IsNullOrEmpty(model.QuestionContent) ? "" : string.Join("|", model.QuestionContent.Split(new string[] { "|" }, StringSplitOptions.RemoveEmptyEntries));
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            if (model.ID > 0)
            {
                bool issuccess = GetPostResponseNoRedirect("Queston_M", "UpdateQuestion", postJson, out data);
                if (issuccess)
                {
                    return Content(data, "application/json; charset=utf-8");
                }
                else
                {
                    return Json(res);
                }
            }
            else
            {
                return Json(res);
            }

        }

        public ActionResult DelQuestion(int ID)
        {
            Question_Model model = new Question_Model();
            model.ID = ID;
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "删除失败";
            bool issuccess = GetPostResponseNoRedirect("Queston_M", "DelQuestion", postJson, out data);
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
