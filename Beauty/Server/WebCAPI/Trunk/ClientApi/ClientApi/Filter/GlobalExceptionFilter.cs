using HS.Framework.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http.Filters;

namespace ClientApi.Filter
{
    public class GlobalExceptionFilter : ExceptionFilterAttribute
    {
        public override void OnException(HttpActionExecutedContext actionExecutedContext)
        {
            var exception = actionExecutedContext.Exception;
            var request = actionExecutedContext.Request;
            var content = request.Content.ReadAsStringAsync().Result;
            if (exception != null)
            {
                LogUtil.Log(exception, content);
            }
        }
    }
}