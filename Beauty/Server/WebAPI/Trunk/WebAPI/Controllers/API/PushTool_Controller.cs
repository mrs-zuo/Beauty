using HS.Framework.Common.Entity;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Web;
using System.Web.Http;
using WebAPI.BLL;

namespace WebAPI.Controllers.API
{
    public class PushTool_Controller : BaseController
    {
        [HttpPost]
        [ActionName("GetPushPoolList")]
        public HttpResponseMessage GetPushPoolList()
        {
            ObjectResult<List<GetPushPoolList_Model>> result = new ObjectResult<List<GetPushPoolList_Model>>();
            result.Code = "0";
            result.Message = "";
            result.Data = null;

            List<GetPushPoolList_Model> list = PushTool_BLL.Instance.getPushPoolList();
            result.Code = "1";
            result.Data = list;

            return toJson(result);
        }
    }
}