using HS.Framework.Common.Entity;
using Model.View_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using WebAPI.Authorize;
using WebAPI.BLL;
using WebAPI.Controllers.API;

namespace WebAPI.Controllers.Manager
{
    public class SMS_MController : BaseController
    {
        [HttpPost]
        [ActionName("getSMSNum")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage getSMSNum(JObject obj)
        {
            ObjectResult<GetSMSNum_Model> res = new ObjectResult<GetSMSNum_Model>();
            res.Code = "0";
            res.Data = null;

            int CompanyID = this.CompanyID;
            int BranchID = this.BranchID;
            GetSMSNum_Model data = new GetSMSNum_Model();
            data = SMSINFO_BLL.Instance.getSMSNum(CompanyID, BranchID);

            res.Code = "1";
            res.Data = data;
            return toJson(res);
        }

    }
}
