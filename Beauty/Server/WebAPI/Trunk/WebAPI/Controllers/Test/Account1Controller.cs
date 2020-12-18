using Model.Operation_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace WebAPI.Controllers.Test
{
    public class Account1Controller : BaseController
    {
        [HttpGet]
        [ActionName("Test")]
        public HttpResponseMessage Test()
        {
            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel.GUID = "Test111";
            return toJson(operationModel);
        }
    }
}
