using ClientAPI.BLL;
using HS.Framework.Common.Entity;
using Model.Operation_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace ClientApi.Controllers.API
{
    public class VersionController : BaseController
    {
        [HttpPost]
        [ActionName("getServerVersion")]
        public HttpResponseMessage getServerVersion()
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "0";
            result.Message = "";
            result.Data = null;

            VersionCheck_Model model = Version_BLL.Instance.getServerVersion(this.DeviceType, this.ClientType, this.APPVersion);
            if (model != null)
            {
                result.Code = "1";
                result.Data = model;
            }

            return toJson(result);
        }
    }
}
