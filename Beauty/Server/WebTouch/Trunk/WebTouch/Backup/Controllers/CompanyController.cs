using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebTouch.Controllers.Base;

namespace WebTouch.Controllers
{
    public class CompanyController : BaseController
    {
        //
        // GET: /Company/

        public ActionResult CompanyDetail()
        {
            return View();
        }

    }
}
