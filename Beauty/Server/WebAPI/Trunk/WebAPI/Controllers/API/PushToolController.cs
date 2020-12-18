using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.View_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using WebAPI.BLL;

namespace WebAPI.Controllers.API
{
    public class PushToolController : BaseController
    {
        [HttpGet]
        [ActionName("GetPushPoolList")]
        public HttpResponseMessage GetPushPoolList()
        {
            PushTool_BLL.Instance.getPushPoolList();
            return toJson(true);
        }


    }
}