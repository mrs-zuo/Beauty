using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using System.Web.Mvc;

namespace WeChat.Controllers
{
    public class PaymentController : Controller
    {        
        public string GetWeChatPayInfo()
        {

            System.IO.Stream s = System.Web.HttpContext.Current.Request.InputStream;

            System.IO.StreamReader sr = new System.IO.StreamReader(s);
            string asdfasdf = sr.ReadToEnd();
            return asdfasdf;

        }
    }
}
