using HS.Framework.Common;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Http;
using System.Web.Routing;

namespace ClientApi
{
    public class WebApiApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            LogUtil.StartLog4Net();
            GlobalConfiguration.Configure(WebApiConfig.Register);
        }
    }
}
