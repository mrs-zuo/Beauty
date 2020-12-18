using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
using HS.Framework.Common.Util;
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
    public class SMSController : BaseController
    {
        public ActionResult getSMSNum()
        {
            string data = string.Empty;
            ObjectResult<GetSMSNum_Model> res = new ObjectResult<GetSMSNum_Model>();
            bool issuccess = false;
            issuccess = GetPostResponseNoRedirect("SMS_M", "getSMSNum", null, out data);
            if (issuccess)
            {
                res = JsonConvert.DeserializeObject<ObjectResult<GetSMSNum_Model>>(data);
                return View(res.Data);
            }
            else
            {
                return RedirectUrl(data, "", false);
            }
        }

    }
}
