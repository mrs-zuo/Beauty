using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebManager.Controllers.Base;

namespace WebManager.Controllers
{
    public class MarketMessageController : BaseController
    {
        public ActionResult GetMarketMessageList()
        {
            int accountID = QueryString.IntSafeQ("a", this.UserID);
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.Available = 1;
            utilityModel.BranchID = -1;
            utilityModel.PageIndex = 1;
            utilityModel.PageSize = 9999;
            utilityModel.AccountID = accountID;

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(utilityModel);

            string messageData = "";
            bool messageResult = this.GetPostResponseNoRedirect("Message_M", "GetMessageForMarket", param, out messageData, false);
            if (!messageResult)
            {
                return RedirectUrl(messageData, "", false);
            }

            string accountData = "";
            bool accountResult = this.GetPostResponseNoRedirect("Account_M", "GetAccountList", param, out accountData, false);
            if (!accountResult)
            {
                return RedirectUrl(accountData, "", false);
            }

            ViewBag.AccountID = accountID;
            PageResult<GetMessageList_Model> messageObjResult = JsonConvert.DeserializeObject<PageResult<GetMessageList_Model>>(messageData);
            ObjectResult<List<AccountListForWeb_Model>> accountObjResult = JsonConvert.DeserializeObject<ObjectResult<List<AccountListForWeb_Model>>>(accountData);

            ViewBag.MessageList = messageObjResult;
            ViewBag.AccountList = accountObjResult.Data;

            return View();
        }

        public ActionResult EditMarketMessage()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            if (this.BranchID > 0)
            {
                // 分店内与我相关的顾客
                utilityModel.Type = 2;
            }
            else
            {
                //总部查看公司所有顾客
                utilityModel.Type = 1;
            }

            string param = Newtonsoft.Json.JsonConvert.SerializeObject(utilityModel);
            string customerData = "";
            bool customerResult = this.GetPostResponseNoRedirect("Account_M", "GetCustomerListByAccountID", param, out customerData, false);
            List<CustomerList_Model> list = new List<CustomerList_Model>();
            if (!customerResult)
            {
                return RedirectUrl(customerData, "", false); 
            }

            ObjectResult<List<CustomerList_Model>> customerObjResult = JsonConvert.DeserializeObject<ObjectResult<List<CustomerList_Model>>>(customerData);
            list = customerObjResult.Data;
            ViewBag.AccountName = this.AccountName;
            return View(list);
        }

        public ActionResult AddMarketMessage(Message_Model messageModel)
        {
            string postJson = JsonConvert.SerializeObject(messageModel);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "新增失败";
            bool issuccess = GetPostResponseNoRedirect("Message_M", "AddMarketMessage", postJson, out data);
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
