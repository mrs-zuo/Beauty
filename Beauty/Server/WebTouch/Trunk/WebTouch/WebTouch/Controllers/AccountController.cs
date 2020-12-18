using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebTouch.Controllers.Base;

namespace WebTouch.Controllers
{
    public class AccountController : BaseController
    {
        public ActionResult MyHome()
        {
            string data = "";
            CustomerInfo_Model model = new CustomerInfo_Model();
            bool issuccess = GetPostResponseNoRedirect("Customer", "GetCustomerInfo", "", out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }

            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<CustomerInfo_Model> res = new ObjectResult<CustomerInfo_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<CustomerInfo_Model>>(data);

                if (res.Code == "1")
                {
                    model = res.Data;
                }
            }

            if (model != null)
            {
                QRInfoOperation_Model qrCodeOperatModel = new QRInfoOperation_Model();
                qrCodeOperatModel.Type = 0;
                qrCodeOperatModel.Code = this.UserID;
                qrCodeOperatModel.CompanyCode = model.CompanyCode;
                qrCodeOperatModel.QRCodeSize = 12;

                string postJson = JsonConvert.SerializeObject(qrCodeOperatModel);
                issuccess = GetPostResponseNoRedirect("WebUtility", "GetQRCode", postJson, out data, true);
                if (!issuccess)
                {
                    return RedirectUrl(data, "", false);
                }
                if (!string.IsNullOrEmpty(data))
                {
                    ObjectResult<string> res = new ObjectResult<string>();
                    res = JsonConvert.DeserializeObject<ObjectResult<string>>(data);

                    if (res.Code == "1")
                    {
                        ViewBag.QRCode = res.Data;
                    }
                }
            }

            return View(model);
        }

        public ActionResult MyAccount()
        {
            string data = "";
            List<GetECardList_Model> cardList = new List<GetECardList_Model>();
            bool issuccess = GetPostResponseNoRedirect("ECard", "GetCustomerCardList", "", out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<GetECardList_Model>> res = new ObjectResult<List<GetECardList_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<GetECardList_Model>>>(data);

                if (res.Code == "1")
                {
                    cardList = res.Data;
                }
            }
            return View(cardList);
        }

        public ActionResult AccountDetail()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.UserCardNo = HS.Framework.Common.Safe.QueryString.SafeQ("cd");
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            GetCardInfo_Model cardDetailModel = new GetCardInfo_Model();
            bool issuccess = GetPostResponseNoRedirect("ECard", "GetCardInfo", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<GetCardInfo_Model> res = new ObjectResult<GetCardInfo_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<GetCardInfo_Model>>(data);

                if (res.Code == "1")
                {
                    cardDetailModel = res.Data;
                }
            }
            return View(cardDetailModel);
        }

        public ActionResult TransactionList()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.UserCardNo = HS.Framework.Common.Safe.QueryString.SafeQ("cn");
            utilityModel.CardType = HS.Framework.Common.Safe.QueryString.IntSafeQ("t");

            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            List<GetCardBalanceList_Model> balanceList = new List<GetCardBalanceList_Model>();
            bool issuccess = GetPostResponseNoRedirect("ECard", "GetCardBalanceByUserCardNo", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<GetCardBalanceList_Model>> res = new ObjectResult<List<GetCardBalanceList_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<GetCardBalanceList_Model>>>(data);

                if (res.Code == "1")
                {
                    balanceList = res.Data;
                }
            }

            return View(balanceList);
        }

        public ActionResult SetDefaultCard(UtilityOperation_Model SetModel)
        {
            string postJson = JsonConvert.SerializeObject(SetModel);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("ECard", "UpdateCustomerDefaultCard", postJson, out data);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult TransactionRecord()
        {
            string data = "";
            List<GetCustomerBalanceList_Model> balanceList = new List<GetCustomerBalanceList_Model>();
            bool issuccess = GetPostResponseNoRedirect("ECard", "GetBalanceListByCustomerID", "", out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<GetCustomerBalanceList_Model>> res = new ObjectResult<List<GetCustomerBalanceList_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<GetCustomerBalanceList_Model>>>(data);

                if (res.Code == "1")
                {
                    balanceList = res.Data;
                }

            }
            return View(balanceList);
        }

        public ActionResult TransactionDetail()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.ID = HS.Framework.Common.Safe.QueryString.IntSafeQ("id");
            utilityModel.ChangeType = HS.Framework.Common.Safe.QueryString.IntSafeQ("t");

            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            GetBalanceDetail_Model balanceDetailModel = new GetBalanceDetail_Model();
            bool issuccess = GetPostResponseNoRedirect("ECard", "GetBalanceDetailInfo", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<GetBalanceDetail_Model> res = new ObjectResult<GetBalanceDetail_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<GetBalanceDetail_Model>>(data);

                if (res.Code == "1")
                {
                    balanceDetailModel = res.Data;
                }
            }

            return View(balanceDetailModel);
        }


        public ActionResult CustomerLocation(CustomerLocation_Model SetModel)
        {
            string postJson = JsonConvert.SerializeObject(SetModel);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            bool issuccess = GetPostResponseNoRedirect("WebUtility", "CustomerLocation", postJson, out data);
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
