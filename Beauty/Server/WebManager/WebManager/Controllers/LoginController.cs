using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebManager.Controllers.Base;
using HS.Framework.Common.Safe;
using Newtonsoft.Json.Converters;
using Model.View_Model;
using HS.Framework.Common.Entity;
using WebManager.Models;
using HS.Framework.Common.Util;
using Newtonsoft.Json;
using System.Drawing;
using System.IO;
using System.Drawing.Imaging;

namespace WebManager.Controllers
{
    public class LoginController : BaseController
    {
        //
        // GET: /Login/
        public ActionResult login()
        {
            //判断已经登录过的
            string strCompanyInfo = CookieUtil.GetCookieValue("CompanyInfo", true);
            string strCookie = CookieUtil.GetCookieValue("HSManger", true);

            if (!string.IsNullOrEmpty(strCompanyInfo) && !string.IsNullOrEmpty(strCookie))
            {
                Cookie_Model cookieModel = JsonConvert.DeserializeObject<Cookie_Model>(strCookie);
                updateLogin(cookieModel.CO, cookieModel.BR, cookieModel.US, cookieModel.LoginMobile, cookieModel.Password, cookieModel.Advanced,cookieModel.CompanyName,cookieModel.BranchName);
                return Redirect("/Home/index");
            }

            ViewBag.LoginPageStatus = QueryString.IntSafeQ("err", 0);

            return View();
        }

        public ActionResult select()
        {
            //string strCookie = CookieUtil.GetCookieValue("CompanyList", true);
            string strCookie = Session["CompanyList"] == null ? "": Session["CompanyList"].ToString();
            if (string.IsNullOrEmpty(strCookie))
                return Redirect("/");
            strCookie = CryptDES.DESDecrypt(strCookie, "S#FQ2st&");
            ViewBag.CompanyList = JsonConvert.DeserializeObject<List<CompanyListForAccountLogin_Model>>(strCookie);
            return View();
        }

        //切换门店
        public ActionResult changeBranch()
        {
            string srtCookie = CookieUtil.GetCookieValue("HSManger", true);

            Cookie_Model cookieModel = new Cookie_Model();
            if (!string.IsNullOrWhiteSpace(srtCookie))
            {
                cookieModel = JsonConvert.DeserializeObject<Cookie_Model>(srtCookie);
            }

            if (cookieModel == null)
                return View("/");

            string strResult = getCompanyList(cookieModel.LoginMobile, cookieModel.Password, null,false);

            if (strResult != "2")
                return View("/");

            return Redirect("/Login/select");
        }


        public string getCompanyList(string loginMobile, string password, string validateCode, bool needRSAEncrypt)
        {
            Login_Model model = new Login_Model();
            if (needRSAEncrypt)
            {
                model.LoginMobile = CryptRSA.RSAEncrypt(loginMobile);
                model.Password = CryptRSA.RSAEncrypt(password);
            }
            else
            {
                model.LoginMobile = loginMobile;
                model.Password = password;
            }
            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);
            string res ="0";

            //验证码校验
            if (Session["LoginError"] != null)
            {
                if (Session["ValidateCode"] == null)
                {
                    res = "-2";
                    return res;
                }

                if (validateCode.ToUpper() != Session["ValidateCode"].ToString().ToUpper())
                {
                    res = "-2";
                    return res;
                }
            }

            string data = "";
            bool result = this.GetPostResponseNoRedirect("Login_M", "getCompanyList", param, out data);

            if (!result)
            {
               
                res = "-1";
                return res;
            }

            ObjectResult<List<CompanyListForAccountLogin_Model>> resultList = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<List<CompanyListForAccountLogin_Model>>>(data);

            if (resultList.Code != "1")
            {
                Session["LoginError"] = "Error";
                res = "0";

                return res;
            }
            else
            {
                Session["LoginError"] = null;
                if (resultList.Data.Count == 1 && resultList.Data[0].BranchList.Count==1)
                {
                    SetCompanyInfoCookie(resultList.Data, 0, 0, false);
                    bool updateResult = updateLogin(resultList.Data[0].CompanyID, resultList.Data[0].BranchList[0].BranchID, resultList.Data[0].AccountID, model.LoginMobile, model.Password, resultList.Data[0].Advanced, resultList.Data[0].CompanyName, resultList.Data[0].BranchList[0].BranchName);
                    if (updateResult)
                    {
                        res = "1";
                        return res;
                    }
                    else
                        return res;
                }
                else
                {
                    //CookieUtil.SetCookie("CompanyList", Newtonsoft.Json.JsonConvert.SerializeObject(resultList.Data), 0, true);
                    string CompanyListValue = Newtonsoft.Json.JsonConvert.SerializeObject(resultList.Data);
                    CompanyListValue = CryptDES.DESEncrypt(CompanyListValue, "S#FQ2st&");
                    Session["CompanyList"] = CompanyListValue;
                    CookieUtil.SetCookie("param", Newtonsoft.Json.JsonConvert.SerializeObject(model), 0, true);

                    res = "2";
                    return res;
                }
            }
        }

        public ActionResult selectCompany(string CompanyIndex, string BranchIndex)
        {
            int companyIndex = StringUtils.GetDbInt(CompanyIndex);
            int branchIndex = StringUtils.GetDbInt(BranchIndex);
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Message = "选择公司失败！请重试！";
            res.Data = false;

            //string cookie=CookieUtil.GetCookieValue("CompanyList", true);
            string cookie = Session["CompanyList"] == null ? "" : Session["CompanyList"].ToString();
            if (string.IsNullOrEmpty(cookie))
               return Json(res);
            cookie = CryptDES.DESDecrypt(cookie, "S#FQ2st&");
            List<CompanyListForAccountLogin_Model> list = JsonConvert.DeserializeObject<List<CompanyListForAccountLogin_Model>>(cookie);            
            
            if (companyIndex < 0 || list.Count < (companyIndex + 1) || branchIndex < 0 || list[companyIndex].BranchList.Count < (branchIndex + 1))
            {
                res.Data = false;
                return Json(res);
            }
            else
            {
                Login_Model model = JsonConvert.DeserializeObject<Login_Model>(CookieUtil.GetCookieValue("param", true));

                bool updateResult = updateLogin(list[companyIndex].CompanyID, list[companyIndex].BranchList[branchIndex].BranchID, list[companyIndex].AccountID, model.LoginMobile, model.Password, list[companyIndex].Advanced, list[companyIndex].CompanyName, list[companyIndex].BranchList[branchIndex].BranchName);

                if (updateResult)
                {
                    res.Data = updateResult;
                    res.Message = "";
                    res.Code = "1";
                    SetCompanyInfoCookie(list, companyIndex, branchIndex,true);
                    CookieUtil.ClearCookie("CompanyList");
                }
                return Json(res);
            }
        }

        public bool updateLogin(int CompanyID, int BranchID, int UserID, string LoginMobile, string Password, string Advanced,string CompanyName,string BranchName)
        {
            //Cookie_Model cookieModel = new Cookie_Model();
            //cookieModel.CO = CompanyID;
            //cookieModel.BR = BranchID;
            //cookieModel.US = UserID;

            //if (CookieUtil.GetCookieValue("HSManger", true) == null)
                //CookieUtil.SetCookie("HSManger", Newtonsoft.Json.JsonConvert.SerializeObject(cookieModel), 0, true);

            Login_Model model = new Login_Model();
            model.CompanyID = CompanyID;
            model.BranchID = BranchID;
            model.UserID = UserID;
            model.LoginMobile = LoginMobile;
            model.Password = Password;
            model.ClientType = 3;
            model.DeviceType = 3;
            model.AppVersion = "1.0";
            model.IPAddress = HS.Framework.Common.Util.Misc.FullIPAddress;
            string param = Newtonsoft.Json.JsonConvert.SerializeObject(model);

            string data = "";
            bool result = this.GetPostResponseNoRedirect("Login_M", "updateLoginInfo", param, out data);

            if (!result)
                return false;

            ObjectResult<RoleForLogin_Model> loginResult = Newtonsoft.Json.JsonConvert.DeserializeObject<ObjectResult<RoleForLogin_Model>>(data);

            if (loginResult.Code != "1")
                return false;
            else
            {
                Cookie_Model cookieModel = new Cookie_Model();
                cookieModel.CO = CompanyID;
                cookieModel.BR = BranchID;
                cookieModel.US = UserID;
                cookieModel.GU = loginResult.Data.GUID;
                cookieModel.Role = loginResult.Data.Role;
                cookieModel.LoginMobile = model.LoginMobile;
                cookieModel.Password = model.Password;
                cookieModel.Advanced = Advanced;
                cookieModel.BranchName = BranchName;
                cookieModel.CompanyName = CompanyName;
                cookieModel.RoleID = loginResult.Data.RoleID;
                cookieModel.ComissionCalc = loginResult.Data.ComissionCalc;

                CookieUtil.SetCookie("HSManger", Newtonsoft.Json.JsonConvert.SerializeObject(cookieModel), 0, true);
                CookieUtil.ClearCookie("param");
                Session["LoginError"] = null;

                return true;
            }
        }

        public ActionResult logOut()
        {
            CookieUtil.ClearCookie("CompanyInfo");
            CookieUtil.ClearCookie("CompanyList");
            CookieUtil.ClearCookie("HSManger");

            return Redirect("/");
        }

        public void SetCompanyInfoCookie(List<CompanyListForAccountLogin_Model> companyList, int companyIndex, int branchIndex,bool canChangeBranch)
        {
            companyList[companyIndex].BranchID = companyList[companyIndex].BranchList[branchIndex].BranchID;
            companyList[companyIndex].BranchName = companyList[companyIndex].BranchID==0?"总部":companyList[companyIndex].BranchList[branchIndex].BranchName;
            companyList[companyIndex].canChangeBranch = canChangeBranch;
            CookieUtil.SetCookie("CompanyInfo", Newtonsoft.Json.JsonConvert.SerializeObject(companyList[companyIndex]), 0, true);
        }

        #region 验证码

        public FileResult ValidateCode()
        {
            string RandomCode = getValidateCode();
            Session["ValidateCode"] = RandomCode;

            System.Drawing.Bitmap bitMap = new System.Drawing.Bitmap(Convert.ToInt32(RandomCode.Length * 14), 20);
            Graphics g = Graphics.FromImage(bitMap);
            try
            {
                Bitmap image = DrawBitMap(RandomCode, bitMap, g);

                MemoryStream ms = new MemoryStream();
                image.Save(ms, ImageFormat.Jpeg);
                ms.Seek(0, SeekOrigin.Begin);
                return new FileStreamResult(ms, "image/jpeg");
            }
            finally
            {
                bitMap.Dispose();
                g.Dispose();
            }
        }

        private string getValidateCode()
        {
            string allChar = "0,1,2,3,4,5,6,7,8,9,A,B,C,D,E,F,G,H,i,J,K,M,N,P,Q,R,S,T,U,W,X,Y,Z";
            string[] allCharArray = allChar.Split(',');
            string RandomCode = "";
            int temp = -1;

            Random rand = new Random();
            for (int i = 0; i < 4; i++)
            {
                if (temp != -1)
                {
                    rand = new Random(temp * i * ((int)DateTime.Now.Ticks));
                }

                int t = rand.Next(33);

                while (temp == t)
                {
                    t = rand.Next(33);
                }

                temp = t;
                RandomCode += allCharArray[t];
            }

            return RandomCode;
        }

        private Bitmap DrawBitMap(string RandomCode, Bitmap image, Graphics g)
        {
            Font f = new System.Drawing.Font("Tahoma", 12);
            Brush b = new System.Drawing.SolidBrush(Color.Black);
            Brush r = new System.Drawing.SolidBrush(Color.FromArgb(166, 8, 8));
            Brush w = new System.Drawing.SolidBrush(Color.White);

            //g.Clear(System.Drawing.ColorTranslator.FromHtml("#eef1f8"));//背景色
            g.Clear(System.Drawing.ColorTranslator.FromHtml("#5fbafc"));//背景色

            char[] ch = RandomCode.ToCharArray();
            for (int i = 0; i < ch.Length; i++)
            {
                g.DrawString(ch[i].ToString(), f, w, 3 + (i * 12), 0);
            }

            //for循环用来生成一些线
            //Pen blackPen = new Pen(Color.FromArgb(50,50,50,50), 0);
            Pen blackPen = new Pen(Color.FromArgb(80, 255, 255, 255), 0);
            Random randL = new Random();
            for (int i = 0; i < 16; i++)
            {
                int x1 = randL.Next(image.Width);
                int x2 = randL.Next(image.Width);
                int y1 = randL.Next(image.Height);
                int y2 = randL.Next(image.Height);
                g.DrawLine(blackPen, x1, x2, y1, y2);
            }

            //画图片的前景噪音点 
            for (int i = 0; i < 64; i++)
            {
                int x = randL.Next(image.Width);
                int y = randL.Next(image.Height);

                image.SetPixel(x, y, Color.FromArgb(randL.Next()));
            }

            return image;
        }

        #endregion
    }
}
