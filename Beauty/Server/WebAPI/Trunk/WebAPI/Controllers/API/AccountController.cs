using HS.Framework.Common;
using HS.Framework.Common.Caching;
using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using WebAPI.Authorize;
using WebAPI.BLL;

namespace WebAPI.Controllers.API
{
    public class AccountController : BaseController
    {
        [HttpPost]
        [ActionName("getAccountList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getAccountList(JObject obj)
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "0";
            result.Message = "";
            result.Data = null;

            if (obj == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);

            UtilityOperation_Model model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            if (model.ImageHeight <= 0)
            {
                model.ImageHeight = 160;
            }

            if (model.ImageWidth <= 0)
            {
                model.ImageWidth = 160;
            }
            List<AccountList_Model> list = Account_BLL.Instance.getAccountList_new(this.CompanyID, model.AccountID, this.BranchID, model.TagIDs, model.ImageWidth, model.ImageHeight);

            if (list != null && list.Count > 0)
            {
                List<int> responsiblePersonID = Account_BLL.Instance.GetRelationshipByCustomerID(this.CompanyID, this.BranchID, model.CustomerID, 1);
                List<int> salesID = Account_BLL.Instance.GetRelationshipByCustomerID(this.CompanyID, this.BranchID, model.CustomerID, 2);

                list.ForEach(x => { x.AccountType = 2; if (responsiblePersonID.Contains(x.AccountID)) { x.AccountType = 0; } if (salesID.Contains(x.AccountID)) { x.AccountType = 1; } });
                var objList = from u in list orderby u.AccountType ascending, u.AccountCode ascending, u.AccountName ascending select u;
                list = objList.ToList<AccountList_Model>();
            }

            result.Code = "1";
            result.Data = list;

            return toJson(result);
        }

        [HttpPost]
        [ActionName("getAccountListForCustomer")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getAccountListForCustomer(JObject obj)
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "0";
            result.Message = "";
            result.Data = null;

            if (obj == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);

            UtilityOperation_Model model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            if (model.ImageHeight <= 0)
            {
                model.ImageHeight = 160;
            }

            if (model.ImageWidth <= 0)
            {
                model.ImageWidth = 160;
            }
            List<AccountList_Model> list = Account_BLL.Instance.getAccountListForCustomer(this.CompanyID, model.BranchID, this.UserID, model.Flag, model.ImageWidth, model.ImageHeight, model.TagIDs);

            result.Code = "1";
            result.Data = list;

            return toJson(result);
        }

        [HttpPost]
        [ActionName("getAccountSchedule")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getAccountSchedule(JObject obj)
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "0";
            result.Message = "";
            result.Data = null;
            if (obj == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);

            UtilityOperation_Model utilityModel = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            if (utilityModel.ImageHeight <= 0)
            {
                utilityModel.ImageHeight = 160;
            }

            if (utilityModel.ImageWidth <= 0)
            {
                utilityModel.ImageWidth = 160;
            }
            List<AccountList_Model> list = Account_BLL.Instance.getAccountListByCompanyID(this.CompanyID, this.BranchID, utilityModel.TagIDs, utilityModel.ImageWidth, utilityModel.ImageHeight);

            List<AccountSchedule_Model> modelList = new List<AccountSchedule_Model>();
            List<ScheduleInAccount> scheduleList = new List<ScheduleInAccount>();
            if (list != null && list.Count > 0)
            {
                foreach (AccountList_Model item in list)
                {
                    AccountSchedule_Model model = new AccountSchedule_Model();
                    model.AccountCode = item.AccountCode;
                    model.AccountID = item.AccountID;
                    model.AccountName = item.AccountName;
                    //model.Department = item.Department;
                    model.PinYin = Common.CommonUtility.getWholeSpell(item.AccountName);
                    model.PinYinFirst = Common.CommonUtility.getFirstSpell(item.AccountName);
                    model.ScheduleList = Account_BLL.Instance.getScheduleListByAccount(item.AccountID, this.BranchID, utilityModel.Date, this.CompanyID);
                    modelList.Add(model);
                }
            }
            result.Code = "1";
            result.Data = modelList;

            return toJson(result);
        }

        [HttpPost]
        [ActionName("getAccountDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getAccountDetail(JObject obj)
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "0";
            result.Message = "";
            result.Data = null;
            if (obj == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);

            UtilityOperation_Model model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (model.ImageHeight <= 0)
            {
                model.ImageHeight = 160;
            }

            if (model.ImageWidth <= 0)
            {
                model.ImageWidth = 160;
            }
            AccountDetail_Model res = Account_BLL.Instance.getAccountDetail(model.AccountID, model.ImageWidth, model.ImageHeight);

            result.Code = "1";
            result.Data = res;

            return toJson(result);
        }

        [HttpPost]
        [ActionName("getFavoriteList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getFavoriteList(JObject obj)
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "0";
            result.Message = "";
            result.Data = null;
            if (obj == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);

            UtilityOperation_Model model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            if (model.ImageHeight <= 0)
            {
                model.ImageHeight = 160;
            }

            if (model.ImageWidth <= 0)
            {
                model.ImageWidth = 160;
            }
            List<FavoriteList_Model> list = Account_BLL.Instance.getFavoriteByAccountID(this.CompanyID, this.UserID, this.BranchID, model.ProductType, model.ImageWidth, model.ImageHeight, model.CustomerID);

            result.Code = "1";
            result.Data = list;

            return toJson(result);
        }

        [HttpPost]
        [ActionName("addFavorite")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage addFavorite(JObject obj)
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "0";
            result.Message = "收藏失败！";
            result.Data = null;
            if (obj == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);

            Favorite_Model model = Newtonsoft.Json.JsonConvert.DeserializeObject<Favorite_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.BranchID = this.BranchID;
            model.AccountID = this.UserID;
            model.CreateTime = DateTime.Now.ToLocalTime();

            int intResult = Account_BLL.Instance.addFavorite(model);

            if (intResult > 0)
            {
                AddFavorite_Model resModel = new AddFavorite_Model();

                resModel.FavoriteID = intResult;
                result.Code = "1";
                result.Message = "收藏成功！";
                result.Data = resModel;
            }
            return toJson(result);
        }

        [HttpPost]
        [ActionName("delFavorite")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage delFavorite(JObject obj)
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "0";
            result.Message = "删除失败";
            result.Data = null;
            if (obj == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);

            if (string.IsNullOrEmpty(strSafeJson))
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            UtilityOperation_Model model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            int intResult = Account_BLL.Instance.deleteFavorite(model.FavoriteID);

            if (intResult == 1)
            {
                result.Code = "1";
                result.Message = "删除成功!";
            }
            return toJson(result);
        }

        [HttpPost]
        [ActionName("updateAccountDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage updateAccountDetail(JObject obj)
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "0";
            result.Message = "";
            result.Data = null;

            if (obj == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);

            if (string.IsNullOrEmpty(strSafeJson))
            {
                result.Message = "不合法参数";
                return toJson(result);
            }
            int ID = StringUtils.GetDbInt(strSafeJson);
            UpdateAccountDetailOperation_Model model = Newtonsoft.Json.JsonConvert.DeserializeObject<UpdateAccountDetailOperation_Model>(strSafeJson);

            string fileName = "";
            if (model.LoginMobile != "")
            {
                List<UserListWithMobile_Model> list = Customer_BLL.Instance.userListWithMobile(model.LoginMobile, model.AccountID, this.CompanyID, 1);
                if (list == null || list.Count != 1)
                {
                    result.Message = Resources.sysMsg.errAccUpdate;
                    return toJson(result);
                }
                else
                {
                    if (model.HeadFlag == 1)
                    {
                        DateTime dt = DateTime.Now;
                        Random random = new Random();
                        string randomNumber = "";

                        for (int i = 0; i < 5; i++)
                        {
                            randomNumber += random.Next(10).ToString();
                        }
                        fileName = string.Format("{0:yyyyMMddHHmmssffff}", dt) + randomNumber + model.ImageType;
                        string folder = Common.CommonUtility.updateUrlSpell(this.CompanyID, 1, model.AccountID);
                        string url = folder + fileName;

                        if (!Directory.Exists(folder))
                        {
                            Directory.CreateDirectory(folder);
                        }
                        Byte[] imageByte = Convert.FromBase64String(model.ImageString);
                        MemoryStream ms = new MemoryStream(imageByte);
                        FileStream fs = new FileStream(url, FileMode.Create);

                        ms.WriteTo(fs);
                        ms.Close();
                        fs.Close();
                        ms = null;
                        fs = null;

                        bool check = Image_BLL.Instance.uploadChk(model.ImageString, url);
                        if (!check)
                        {
                            result.Message = Resources.sysMsg.errAccUpdate;
                            return toJson(result);
                        }
                        else
                        {
                            bool blResult = Account_BLL.Instance.updateAccDetail(model);
                            if (blResult)
                            {
                                result.Code = "1";
                                result.Message = Resources.sysMsg.sucAccUpdate;
                                int imageWidth, imageHeight;

                                imageWidth = StringUtils.GetDbInt(model.ImageWidth.ToString(), 160);
                                imageHeight = StringUtils.GetDbInt(model.ImageHeight.ToString(), 160);

                                string strCotent = Common.Const.strHttp + Common.Const.server + Common.Const.strMothod + CompanyID.ToString() + "/" + Common.Const.strImageObjectType1 + model.AccountID + "/" + fileName + "'&th='" + imageHeight.ToString() + "'&tw='" + imageWidth.ToString() + "'&bg=FFFFFF'";
                                strCotent = strCotent.Replace("&", "&amp;").Replace("'", "");

                                result.Data = strCotent;
                            }
                            else
                            {
                                result.Message = Resources.sysMsg.errAccUpdate;
                                return toJson(result);
                            }
                        }
                    }
                    else
                    {
                        bool blResult = Account_BLL.Instance.updateAccDetail(model);
                        if (blResult)
                        {
                            result.Code = "1";
                            result.Message = Resources.sysMsg.sucAccUpdate;
                        }
                        else
                        {
                            result.Message = Resources.sysMsg.errAccUpdate;
                            return toJson(result);
                        }
                    }
                }
            }

            if (Account_BLL.Instance.updateAccDetail(model))
            {
                result.Code = "1";
            }

            return toJson(result);
        }

        [HttpPost]
        [ActionName("updateAccountStatus")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage updateAccountStatus(JObject obj)
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "0";
            result.Message = "";
            result.Data = null;
            if (obj == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);

            if (string.IsNullOrEmpty(strSafeJson))
            {
                result.Message = "不合法参数";
                return toJson(result);
            }
            int ID = StringUtils.GetDbInt(strSafeJson);
            UtilityOperation_Model model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            bool blResult = Account_BLL.Instance.changeAccState(this.CompanyID, model.AccountID, model.Available);

            if (blResult)
            {
                result.Code = "1";
            }
            return toJson(result);
        }

        [HttpPost]
        [ActionName("GetAccountListByTagID")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetAccountListByTagID(JObject obj)
        {
            ObjectResult<List<AccountList_Model>> result = new ObjectResult<List<AccountList_Model>>();
            result.Code = "0";
            result.Message = "";
            result.Data = null;
            if (obj == null)
            {
                result.Message = "不合法参数";
                return toJson(result);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);

            UtilityOperation_Model utilityModel = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            if (utilityModel.ImageHeight <= 0)
            {
                utilityModel.ImageHeight = 160;
            }

            if (utilityModel.ImageWidth <= 0)
            {
                utilityModel.ImageWidth = 160;
            }
            List<AccountList_Model> list = Account_BLL.Instance.getAccountListByTagID(this.CompanyID, this.BranchID, utilityModel.ID, utilityModel.ImageHeight, utilityModel.ImageWidth);

            result.Code = "1";
            result.Data = list;

            return toJson(result);
        }

        [HttpPost]
        [ActionName("GetAttendanceQRCode")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetAttendanceQRCode(JObject obj)
        {
            ObjectResult<string> result = new ObjectResult<string>();
            result.Code = "0";
            result.Message = "";
            result.Data = null;

            DateTime time = DateTime.Now;
            string strTime = time.ToString("yyyy-MM-dd HH:mm:ss.ff");
            string strKey = time.ToString("yyyyMMddHHmmssff") + "_" + this.UserID.ToString() + "_" + this.CompanyID.ToString() + "_" + this.BranchID.ToString();

            string strJson = "{\"Time\":\"" + strTime + "\",\"AccountID\":" + this.UserID.ToString() + ",\"CompanyID\":" + this.CompanyID.ToString() + ",\"BranchID\":" + this.BranchID.ToString() + "}";
            string Prama = HS.Framework.Common.Safe.CryptDES.DESEncrypt(strJson, "dakakada");
            MemcachedNew.Set("Attendance", strKey, Prama);
            string qrCode = "http://data.beauty.glamise.com/GetQRcode.aspx?size=10&content=" + System.Web.HttpUtility.UrlEncode(Prama);

            result.Code = "1";
            result.Data = qrCode;
            return toJson(result);
        }

        [HttpPost]
        [ActionName("AttendanceByAccount")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage AttendanceByAccount(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
            res.Data = false;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);

            UtilityOperation_Model utilityModel = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (utilityModel == null || string.IsNullOrWhiteSpace(utilityModel.Prama))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string DESPrama = HS.Framework.Common.Safe.CryptDES.DESDecrypt(utilityModel.Prama, "dakakada");
            if (string.IsNullOrWhiteSpace(DESPrama))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model operatortionModel = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(DESPrama);
            DateTime creatTime = operatortionModel.Time;
            DateTime nowTime = DateTime.Now;

            string strKey = operatortionModel.Time.ToString("yyyyMMddHHmmssff") + "_" + operatortionModel.AccountID.ToString() + "_" + operatortionModel.CompanyID.ToString() + "_" + operatortionModel.BranchID.ToString();

            var data = MemcachedNew.Get("Attendance", strKey);
            if (data == null)
            {
                res.Code = "0";
                res.Message = "二维码已经失效!";
                res.Data = false;
                return toJson(res);
            }

            if (creatTime.AddMinutes(1) < nowTime)
            {
                res.Code = "0";
                res.Message = "二维码已经过期!";
                res.Data = false;
                return toJson(res);
            }
            if(this.CompanyID!=operatortionModel.CompanyID||this.BranchID!=operatortionModel.BranchID)
            {
                res.Code = "0";
                res.Message = "该员工非本门店员工!";
                res.Data = false;
                return toJson(res);
            }

            int addAttendanceRes = Account_BLL.Instance.AttendanceByAccount(this.CompanyID, this.BranchID, this.UserID, nowTime, operatortionModel.AccountID);
            if (addAttendanceRes == 1)
            {
                MemcachedNew.Remove("Attendance", strKey);
                res.Code = "1";
                res.Message = "打卡成功!";
                res.Data = true;
                return toJson(res);
            }

            res.Message = "打卡失败!";
            res.Data = false;
            return toJson(res);
        }
    }
}

