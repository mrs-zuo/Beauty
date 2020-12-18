using HS.Framework.Common.Util;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace WebTouch.Filter
{
    public class CheckActionFilter : ActionFilterAttribute
    {
        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            string actionName = filterContext.ActionDescriptor.ActionName;
            List<string> notNeedCheck = new List<string>() { "GETPROMOTIONLIST" };
            //HttpResponse
            if (notNeedCheck.Contains(actionName.ToUpper()))
            {
                #region 不要验证的,取URL里的CompanyID
                int companyID = HS.Framework.Common.Safe.QueryString.IntSafeQ("co");
                if (companyID > 0)
                {
                    CookieUtil.ClearCookie("CompanyInfo");
                }
                #endregion
            }
            
        }
    }
}