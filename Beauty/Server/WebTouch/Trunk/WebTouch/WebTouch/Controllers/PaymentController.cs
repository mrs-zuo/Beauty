using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
using Model.Operation_Model;
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
    public class PaymentController : BaseController
    {
        //
        // GET: /Payment/

        public ActionResult PaymentDetail()
        {
            string data = "";
            List<PaymentDetailByOrderID_Model> List = null;
            UtilityOperation_Model OperatModel = new UtilityOperation_Model();
            OperatModel.PaymentID = 0;
            OperatModel.OrderID = StringUtils.GetDbInt(HS.Framework.Common.Safe.QueryString.SafeQ("oId"));

            string postJson = JsonConvert.SerializeObject(OperatModel);
            bool issuccess = GetPostResponseNoRedirect("Payment", "GetPaymentDetailByOrderID", postJson, out data, false);

            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }


            ObjectResult<List<PaymentDetailByOrderID_Model>> res = new ObjectResult<List<PaymentDetailByOrderID_Model>>();
            res = JsonConvert.DeserializeObject<ObjectResult<List<PaymentDetailByOrderID_Model>>>(data);

            if (res.Code == "1")
            {
                List = new List<PaymentDetailByOrderID_Model>();
                List = res.Data;
            }


            return View(List);
        }

    }
}
