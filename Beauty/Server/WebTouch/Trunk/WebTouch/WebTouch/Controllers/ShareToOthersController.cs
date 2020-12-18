using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
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
using WebAPI.Common;

namespace WebTouch.Controllers
{
    public class ShareToOthersController : BaseController
    {
        //
        // GET: /ShareToOthers/

        public ActionResult BeautyRecord()
        {
            PwdOperation_Model operationModel = new PwdOperation_Model();
            operationModel.PwdCompanyID = QueryString.SafeQ("co");
            operationModel.PwdCustomerID = QueryString.SafeQ("cd");
            operationModel.PwdGroupNo = QueryString.SafeQ("gn");
            operationModel.ImageHeight = 500;
            operationModel.ImageWidth = 500;

            string postJson = JsonConvert.SerializeObject(operationModel);

            string data = "";
            CustomerTGPic model = null;
            bool issuccess = GetPostResponseNoRedirect("ShareToOther", "getCustomerTGPic", postJson, out data, false, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
                ObjectResult<CustomerTGPic> res = new ObjectResult<CustomerTGPic>();
                res = JsonConvert.DeserializeObject<ObjectResult<CustomerTGPic>>(data);

                if (res.Code == "1")
                {
                    model = new CustomerTGPic();
                    model = res.Data;

                }

            int CompanyID = StringUtils.GetDbInt(CryptDES.DESDecrypt(operationModel.PwdCompanyID,"share123"));
            ViewBag.CompanyID = CompanyID;
            return View(model);
        }

    }
}
