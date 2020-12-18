using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
using Model.Operation_Model;
using Model.View_Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebTouch.Controllers.Base;

namespace WebTouch.Controllers
{
    public class CustomerBenefitController : BaseController
    {
        //
        // GET: /CustomerBenefit/

        public ActionResult CustomerBenefitList()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.Type = QueryString.IntSafeQ("t");
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            List<CustomerBenefitList_Model> list = new List<CustomerBenefitList_Model>();
            bool issuccess = GetPostResponseNoRedirect("ECard", "GetCustomerBenefitList", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<List<CustomerBenefitList_Model>> res = new ObjectResult<List<CustomerBenefitList_Model>>();
                res = JsonConvert.DeserializeObject<ObjectResult<List<CustomerBenefitList_Model>>>(data);

                if (res.Code == "1")
                {
                    list = res.Data;
                }
            }
            ViewBag.Type = utilityModel.Type;
            return View(list);
        }



        public ActionResult CustomerBenefitDetail()
        {
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.BenefitID = QueryString.SafeQ("b");
            string postJson = JsonConvert.SerializeObject(utilityModel);

            string data = "";
            CustomerBenefitDetail_Model model = new CustomerBenefitDetail_Model();
            bool issuccess = GetPostResponseNoRedirect("ECard", "GetCustomerBenefitDetail", postJson, out data, false);
            if (!issuccess)
            {
                return RedirectUrl(data, "", false);
            }
            if (!string.IsNullOrEmpty(data))
            {
                ObjectResult<CustomerBenefitDetail_Model> res = new ObjectResult<CustomerBenefitDetail_Model>();
                res = JsonConvert.DeserializeObject<ObjectResult<CustomerBenefitDetail_Model>>(data);

                if (res.Code == "1")
                {
                    model = res.Data;
                }
            }
            return View(model);
        }

    }
}
