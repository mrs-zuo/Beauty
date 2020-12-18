using HS.Framework.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Http.Filters;

namespace WebAPI.Filter
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
                LogUtil.Error(exception, content);
            }
        }
    }
}
