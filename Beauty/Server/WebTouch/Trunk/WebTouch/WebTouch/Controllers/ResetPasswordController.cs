using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.Mvc;
using WebTouch.Controllers.Base;

namespace WebTouch.Controllers
{
    public class ResetPasswordController : BaseController
    {
        //
        // GET: /ResetPassword/

        private RSACrypto rsa = new RSACrypto();
        private RSAParameters rsaParam;
        public ActionResult ResetPassword()
        {
            string strPublicKey = HS.Framework.Common.Safe.CryptRSA.GetPublicKeyStringForWeb();

            rsa.InitCrypto(strPublicKey);
            rsaParam = rsa.ExportParameters(false);
            ViewBag.RSA_E = RSAStringHelper.BytesToHexString(rsaParam.Exponent);
            ViewBag.RSA_M = RSAStringHelper.BytesToHexString(rsaParam.Modulus);
            return View();
        }


        public ActionResult SelectCompany()
        {
            string strJson = Request.Form["txtData"];
            List<CompanyListByLoginMobile_Model> listBranch = JsonConvert.DeserializeObject<List<CompanyListByLoginMobile_Model>>(strJson);
            ViewBag.Mobile = Request.Form["txtMobile"];
            return View(listBranch);
        }

        public ActionResult GetAuthenticationCode(string LoginMobile)
        {
            UtilityOperation_Model model = new UtilityOperation_Model();
            string srtCookie = HS.Framework.Common.Util.CookieUtil.GetCookieValue("HSTouchCOD", true);
            
            if (!string.IsNullOrWhiteSpace(srtCookie))
            {
                model.CompanyID = HS.Framework.Common.Util.StringUtils.GetDbInt(srtCookie);
            }
            model.LoginMobile = LoginMobile;
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Login", "getAuthenticationCode", postJson, out data, true, false);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }

        public ActionResult checkAuthenticationCode(CheckAuthenticationCode_Model model)
        {
           // model.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSAEncrypt(model.LoginMobile);
         //   model.AuthenticationCode = HS.Framework.Common.Safe.CryptRSA.RSAEncrypt(model.AuthenticationCode);
            string srtCookie = HS.Framework.Common.Util.CookieUtil.GetCookieValue("HSTouchCOD", true);
            WebTouch.Models.Cookie_Model cookieModel = new WebTouch.Models.Cookie_Model();
            if (!string.IsNullOrWhiteSpace(srtCookie))
            {
                model.CompanyID = HS.Framework.Common.Util.StringUtils.GetDbInt(srtCookie); 
            }
            
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<List<CompanyListByLoginMobile_Model>> res = new ObjectResult<List<CompanyListByLoginMobile_Model>>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Login", "checkAuthenticationCode", postJson, out data, true, false);
            if (issuccess)
            {
                return Content(data, "application/json; charset=utf-8");
            }
            else
            {
                return Json(res);
            }
        }


        public ActionResult ChangePassword()
        {
            ViewBag.CustomerId = Request.Form["txtData"];
            ViewBag.Mobile = Request.Form["txtMobile"];
            string strPublicKey = HS.Framework.Common.Safe.CryptRSA.GetPublicKeyStringForWeb();

            rsa.InitCrypto(strPublicKey);
            rsaParam = rsa.ExportParameters(false);
            ViewBag.RSA_E = RSAStringHelper.BytesToHexString(rsaParam.Exponent);
            ViewBag.RSA_M = RSAStringHelper.BytesToHexString(rsaParam.Modulus);
            return View();
        }



        public ActionResult UpdatePassWord(Login_Model model)
        {
            //model.LoginMobile = HS.Framework.Common.Safe.CryptRSA.RSAEncrypt(model.LoginMobile);
            //model.Password = HS.Framework.Common.Safe.CryptRSA.RSAEncrypt(model.Password);
            string postJson = JsonConvert.SerializeObject(model);
            string data = string.Empty;
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "修改失败";
            bool issuccess = GetPostResponseNoRedirect("Login", "updateCustomerPassword", postJson, out data, true, false);
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
