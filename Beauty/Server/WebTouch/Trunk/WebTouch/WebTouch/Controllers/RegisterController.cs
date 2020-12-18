using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
using Model.Operation_Model;
using Model.View_Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Web;
using System.Web.Mvc;
using WebTouch.Controllers.Base;

namespace WebTouch.Controllers
{
    public class RegisterController : BaseController
    {
        //
        // GET: /Register/

        private RSACrypto rsa = new RSACrypto();
        private RSAParameters rsaParam;
        public ActionResult Register()
        {
            int CompanyID = this.CompanyID;
            int BranchID = QueryString.IntSafeQ("bd");
            if (CompanyID == 0) {
                return Redirect("/Login/Login");
            }
            ViewBag.CompanyID = CompanyID;
            ViewBag.BranchID = BranchID;

            string strPublicKey = HS.Framework.Common.Safe.CryptRSA.GetPublicKeyStringForWeb();

            rsa.InitCrypto(strPublicKey);
            rsaParam = rsa.ExportParameters(false);
            ViewBag.RSA_E = RSAStringHelper.BytesToHexString(rsaParam.Exponent);
            ViewBag.RSA_M = RSAStringHelper.BytesToHexString(rsaParam.Modulus);
            return View();
        }

        public ActionResult GetAuthenticationCode(string LoginMobile,int CompanyID)
        {
            UtilityOperation_Model model = new UtilityOperation_Model();

            model.CompanyID =CompanyID;
            model.LoginMobile = LoginMobile;
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Register", "getAuthenticationCode", postJson, out data, true, false);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult checkAuthenticationCode(RegisterOperation_Model model)
        {
            //model.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSAEncrypt(model.LoginMobile);
            //model.AuthenticationCode = HS.Framework.Common.Safe.CryptRSA.RSAEncrypt(model.AuthenticationCode);
            //model.Password = HS.Framework.Common.Safe.CryptRSA.RSAEncrypt(model.Password);

            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Register", "checkAuthenticationCode", postJson, out data, true, false);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }



    }
}
