using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
using HS.Framework.Common.Util;
using Model.Table_Model;
using Model.View_Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebManager.Controllers.Base;

namespace WebManager.Controllers
{
    public class CardController : BaseController
    {
        //
        // GET: /Card/

        public ActionResult GetCardList()
        {
            bool issuccess = false;

            string data;
            issuccess = GetPostResponseNoRedirect("Card_M", "GetCardList", "", out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<Card_Model>> res = new ObjectResult<List<Card_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<Card_Model>>>(data);

                if (res.Code == "1")
                {
                    ViewBag.CardList = res.Data;
                }
            }

            return View();
        }



        public ActionResult EditCard()
        {
            bool issuccess = false;

            Card_Model mCard = new Card_Model();
            mCard.CardCode = StringUtils.GetDbLong(QueryString.SafeQ("CD").ToString());

            string data;
            string postJson = JsonConvert.SerializeObject(mCard);
            issuccess = GetPostResponseNoRedirect("Card_M", "GetCardDetail", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<Card_Model> res = new ObjectResult<Card_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<Card_Model>>(data);

                if (res.Code == "1")
                {
                    ViewBag.CardDetail = res.Data;
                }
            }

            return View();
        }


        public ActionResult deleteCard(int CardID)
        {
            Card_Model model = new Card_Model();
            model.ID = CardID;

            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            res.Message = "删除失败";
            issuccess = GetPostResponseNoRedirect("Card_M", "DeleteCard", postJson, out data);

            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }



        public ActionResult OperationCard(Card_Model model)
        {
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            res.Message = "";
            if (model.ID == 0)
            {
                issuccess = GetPostResponseNoRedirect("Card_M", "AddCard", postJson, out data);
            }
            else
            {
                issuccess = GetPostResponseNoRedirect("Card_M", "UpdateCard", postJson, out data);
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




        public ActionResult setDefaultCard(string CardCode)
        {
            Card_Model model = new Card_Model();
            model.CardCode = StringUtils.GetDbLong(CardCode);

            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = false;
            res.Message = "删除失败";
            issuccess = GetPostResponseNoRedirect("Card_M", "SetDefaultCard", postJson, out data);

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
