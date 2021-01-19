using HS.Framework.Common;
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
using System.Text;
using System.Web.Http;
using WebAPI.Authorize;
using WebAPI.BLL;
using WebAPI.Common;

namespace WebAPI.Controllers.API
{
    public class CustomerController : BaseController
    {
        [HttpPost]
        [ActionName("getCustomerList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getCustomerList(JObject obj)
        {
            ObjectResultSup<List<CustomerList_Model>> resSup = new ObjectResultSup<List<CustomerList_Model>>();
            resSup.DataCnt = 0;
            resSup.Code = "0";
            resSup.Data = null;
            if (obj == null)
            {
                resSup.Message = "不合法参数";
                return toJson(resSup);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                resSup.Message = "不合法参数";
                return toJson(resSup);
            }

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;
            operationModel.BranchID = this.BranchID;
            operationModel.AccountID = this.UserID;

            if (operationModel.AccountIDList == null || operationModel.AccountIDList.Count <= 0)
            {
                operationModel.AccountIDList = new List<int>();
                operationModel.AccountIDList.Add(this.UserID);
            }

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }
            Common.WriteLOG.WriteLog("CustomerController.cs CALL Customer_BLL.Instance.GetCustomerList");
            ObjectResultSup<List<CustomerList_Model>> objResult = Customer_BLL.Instance.GetCustomerList(
                operationModel.CompanyID, operationModel.BranchID, operationModel.AccountID, 
                operationModel.ImageWidth, operationModel.ImageHeight, 
                operationModel.ObjectType, operationModel.CardCode, operationModel.SourceType, 
                operationModel.AccountIDList, operationModel.RegistFrom, operationModel.FirstVisitType, 
                operationModel.FirstVisitDateTime, operationModel.EffectiveCustomerType,
                operationModel.PageFlg, operationModel.PageIndex, operationModel.PageSize,
                operationModel.CustomerName, operationModel.CustomerTel,
                operationModel.SearchDateTime
                );
            //if (objResult.Code == "1")
            //{
            //    if (operationModel.Type == 0)
            //    {
            //        res.Data = objResult.Data;
            //    }
            //    else if (operationModel.Type == 1)
            //    {
            //        List<int> RandomList = new List<int>();
            //        int seed = Guid.NewGuid().GetHashCode();
            //        Random random = new Random(seed);

            //        while (RandomList.Count < 4)
            //        {
            //            int intRandom = random.Next(objResult.Data.Count);
            //            if (!RandomList.Contains(intRandom))
            //            {
            //                RandomList.Add(intRandom);
            //            }
            //        }

            //        List<CustomerList_Model> IndexList = new List<CustomerList_Model>();
            //        foreach (int item in RandomList)
            //        {
            //            IndexList.Add(objResult.Data[item]);
            //        }

            //        res.Data = IndexList;
            //    }
            //}

            resSup.Code = "1";
            resSup.Data = objResult.Data;
            resSup.DataCnt = objResult.DataCnt;
            return toJson(resSup);

        }

        [HttpPost]
        [ActionName("getCustomerBasic")]
        [HTTPBasicAuthorize]
        // {"CustomerID":2569}
        public HttpResponseMessage getCustomerBasic(JObject obj)
        {
            ObjectResult<CustomerBasic_Model> res = new ObjectResult<CustomerBasic_Model>();
            res.Code = "0";
            res.Data = null;
            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;
            operationModel.BranchID = this.BranchID;

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }

            CustomerBasic_Model model = Customer_BLL.Instance.getCustomerBasic(operationModel.CustomerID, operationModel.CompanyID, operationModel.BranchID, operationModel.ImageWidth, operationModel.ImageHeight);

            res.Code = "1";
            res.Data = model;
            return toJson(res);

        }

        [HttpPost]
        [ActionName("GetCustomerInfo")]
        [HTTPBasicAuthorize]
        // {"CustomerID":2569}
        public HttpResponseMessage GetCustomerInfo(JObject obj)
        {
            ObjectResult<CustomerInfo_Model> res = new ObjectResult<CustomerInfo_Model>();
            res.Code = "0";
            res.Data = null;
            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;
            operationModel.BranchID = this.BranchID;

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }

            CustomerInfo_Model model = Customer_BLL.Instance.getCustomerInfo(operationModel.CustomerID, operationModel.CompanyID, operationModel.BranchID, operationModel.ImageWidth, operationModel.ImageHeight);

            res.Code = "1";
            res.Data = model;
            return toJson(res);

        }

        [HttpPost]
        [ActionName("getCustomerDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getCustomerDetail(JObject obj)
        {
            ObjectResult<CustomerDetail_Model> res = new ObjectResult<CustomerDetail_Model>();
            res.Code = "0";
            res.Data = null;
            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson) || strSafeJson == "0")
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            CustomerDetail_Model model = Customer_BLL.Instance.getCustomerDetail(operationModel.CustomerID);

            res.Code = "1";
            res.Data = model;
            return toJson(res, "yyyy-MM-dd");

        }


        [HttpPost]
        [ActionName("updateExpirationDate")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage updateExpirationDate(JObject obj)
        {
            ObjectResult<List<CustomerList_Model>> res = new ObjectResult<List<CustomerList_Model>>();
            res.Code = "0";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;
            operationModel.BranchID = this.BranchID;
            operationModel.UpdaterID = this.UserID;


            bool result = Customer_BLL.Instance.UpdateExpirationDateByCustomer(this.CompanyID, operationModel.UpdaterID, operationModel.CustomerID, operationModel.ExpirationTime);

            if (result)
            {
                res.Code = "1";
                return toJson(res);
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("addResponsiblePersonID")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage addResponsiblePersonID(JObject obj)
        {
            ObjectResult<object> res = new ObjectResult<object>();
            res.Code = "0";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;
            operationModel.BranchID = this.BranchID;
            operationModel.CreatorID = this.UserID;

            bool isexist = Customer_BLL.Instance.IsExistResponsiblePersonID(operationModel.CustomerID, operationModel.CompanyID, operationModel.BranchID);

            if (isexist)
            {
                res.Code = "-2";
                res.Message = "已存在美丽顾问";
                return toJson(res);
            }
            else
            {
                bool result = Customer_BLL.Instance.AddResponsiblePersonID(operationModel.AccountID, operationModel.CustomerID, operationModel.CompanyID, operationModel.BranchID, operationModel.CreatorID);

                if (!result)
                {
                    res.Message = Resources.sysMsg.errSystemHandle;
                    return toJson(res);
                }
                res.Code = "1";
                res.Message = "添加成功！";
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("addCustomer")]
        [HTTPBasicAuthorize]
        // {"HeadFlag":"0","ImageString":"","ImageType":"","IsCheck":1,"LoginMobile":"","LevelID":"7","PhoneList":[],"CustomerName":"ceshidaoru13","Title":"sss","IsPast":true,"ResponsiblePersonID":"2339","SalesPersonIDList":[123,456]}
        public HttpResponseMessage addCustomer(JObject obj)
        {
            System.Diagnostics.StackTrace st = new System.Diagnostics.StackTrace(1, true);
            string strPgm;  //当前的程序名称及行号等监察信息

            ObjectResult<CustomerAdd_Model> res = new ObjectResult<CustomerAdd_Model>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = StringUtils.GetDbString(obj);

            if (string.IsNullOrWhiteSpace(strSafeJson))
            {
                res.Message = Resources.sysMsg.errSystemHandle;
                return toJson(res);
            }

            CustomerAddOperation_Model addModel = new CustomerAddOperation_Model();
            addModel = JsonConvert.DeserializeObject<CustomerAddOperation_Model>(strSafeJson);
            addModel.CompanyID = this.CompanyID;
            addModel.BranchID = this.BranchID;
            addModel.CreatorID = this.UserID;

            if (addModel == null || string.IsNullOrWhiteSpace(addModel.CustomerName.Trim()))
            {
                res.Message = Resources.sysMsg.errSystemHandle;
                return toJson(res);
            }

            if (addModel.ResponsiblePersonID == 0)
            {
                res.Code = "-2";
                res.Message = Resources.sysMsg.errNOAccountID;
                return toJson(res);
            }

            if (!string.IsNullOrWhiteSpace(addModel.LoginMobile))
            {
                if (!CommonUtility.IsMobile(addModel.LoginMobile))
                {
                    res.Code = "-3";
                    res.Message = Resources.sysMsg.errLoginMobileError;
                    return toJson(res);
                }
                addModel.isLoginMobileFlag = true;
                addModel.PasswordFlag = true;
            }

            #region 判断LoginMobile是否有相同
            List<UserListWithMobile_Model> list = Customer_BLL.Instance.userListWithMobile(addModel.LoginMobile, 0, addModel.CompanyID, 0);

            if (list != null && list.Count > 0)
            {
                res.Code = "-3";
                res.Message = Resources.sysMsg.existMobileError;
                return toJson(res);
            }
            #endregion

            if (addModel.IsCheck)
            {
                #region 判断名字与手机是否有相同
                bool isexsitname = Customer_BLL.Instance.IsExistCustomerName(addModel.CompanyID, addModel.CustomerName.Trim());
                bool isexsitPhone = false;

                if (addModel.PhoneList != null)
                {
                    foreach (var item in addModel.PhoneList)
                    {
                        if (!string.IsNullOrWhiteSpace(Customer_BLL.Instance.IsExistCustomerPhone(addModel.CompanyID, item.PhoneContent)))
                        {
                            isexsitPhone = true;
                            break;
                        }
                    }
                }

                if (isexsitname && isexsitPhone)
                {
                    res.Message = Resources.sysMsg.existCustomerNameAndPhone;
                    return toJson(res);
                }

                if (isexsitname)
                {
                    res.Message = Resources.sysMsg.existCustomerName;
                    return toJson(res);
                }

                if (isexsitPhone)
                {
                    res.Message = Resources.sysMsg.existCustomerPhone;
                    return toJson(res);
                }
                #endregion
            }

            if (addModel.ImageHeight <= 0)
            {
                addModel.ImageHeight = 160;
            }

            if (addModel.ImageWidth <= 0)
            {
                addModel.ImageWidth = 160;
            }

            //ImageCommon_Model mImage = new ImageCommon_Model();
            string fileName = "";
            if (addModel.HeadFlag == 1)
            {
                #region 头像实体类赋值
                Random random = new Random();
                string randomNumber = "";

                for (int i = 0; i < 5; i++)
                {
                    randomNumber += random.Next(10).ToString();
                }

                //mImage.ObjectType = 0;
                //mImage.Category = 0;
                DateTime dt = DateTime.Now;
                fileName = string.Format("{0:yyyyMMddHHmmssffff}", dt) + randomNumber + addModel.ImageType;
                //mImage.FileName = fileName;
                addModel.FileName = fileName;
                //mImage.Available = true;
                //mImage.CreatorID = addModel.CreatorID;
                //mImage.CreateTime = DateTime.Now.ToLocalTime();
                //mImage.UpdaterID = addModel.CreatorID;
                //mImage.UpdateTime = DateTime.Now.ToLocalTime();
                #endregion
            }

            addModel.CustomerName = addModel.CustomerName.Trim();
            addModel.CreateTime = DateTime.Now.ToLocalTime();

            bool pushFlag = false;
            #region 手机号码不为空且分店设置为自定义密码时pushFlag=false不推送,采用Branch表的密码,如果手机号码不为空且分店设置为推送随机密码时 PushFlag = true 生成随机密码
            if (!string.IsNullOrEmpty(addModel.LoginMobile.Trim()))
            {
                string password = Company_BLL.Instance.getDefaultPassword(addModel.BranchID);

                if (!string.IsNullOrEmpty(password))
                {
                    addModel.Password = password;
                }
                else
                {
                    pushFlag = true;
                    Random rd = new Random();
                    addModel.Password = rd.Next(1000000).ToString("d6");
                }
            }
            #endregion

            CustomerAdd_Model model = Customer_BLL.Instance.customerAdd(addModel);

            if (model == null)
            {
                res.Code = "-1";
                res.Message = Resources.sysMsg.errCustomerAdd;
                return toJson(res);
            }

            StringBuilder sbMobile = new StringBuilder();
            if (model.LoginMobile.Length > 4 && !model.IsMyCustomer)
            {
                for (int j = 0; j < model.LoginMobile.Length - 4; j++)
                {
                    sbMobile.Append("*");
                }
                model.LoginMobile = (object)sbMobile.ToString() + model.LoginMobile.Substring(model.LoginMobile.Length - 4, 4);
            }
            //#endregion

            res.Data = model;
            strPgm = st.GetFrame(0).GetMethod().Name + "(" + st.GetFrame(0).GetFileLineNumber().ToString() + ")";
            int result = SMSINFO_BLL.Instance.getSMSInfo(addModel.CompanyID, addModel.LoginMobile, strPgm, addModel.CreatorID);

            #region 发送push  可发送短信件数大于已发送短信件数
            if (pushFlag && result == 0)
            {
                string companySmsheading = Company_BLL.Instance.getCompanySmsheading(addModel.CompanyID);
                Common.SendShortMessage.sendShortMessage(addModel.LoginMobile, addModel.Password, companySmsheading, 1);
                //保存短信发送履历信息
                string msg = string.Format(Const.MESSAGE_PASSWORD, companySmsheading, addModel.Password);
                strPgm = st.GetFrame(0).GetMethod().Name + "(" + st.GetFrame(0).GetFileLineNumber().ToString() + ")";
                SMSINFO_BLL.Instance.addSMSHis(addModel.CompanyID, addModel.BranchID, addModel.LoginMobile, msg, strPgm, addModel.CreatorID);
            }
            #endregion

            #region 有头像的处理
            if (addModel.HeadFlag == 1)
            {
                //string folder = AppDomain.CurrentDomain.BaseDirectory + Const.strImage + addModel.CompanyID + "/" + Const.strImageObjectType0 + model.CustomerID + "/";
                //string url = AppDomain.CurrentDomain.BaseDirectory + Const.strImage + addModel.CompanyID + "/" + Const.strImageObjectType0 + model.CustomerID + "/" + fileName;
                string folder = CommonUtility.updateUrlSpell(addModel.CompanyID, 0, model.CustomerID);
                string url = folder + addModel.FileName;


                if (!Directory.Exists(folder))
                {
                    Directory.CreateDirectory(folder);
                }
                Byte[] imageByte = Convert.FromBase64String(addModel.ImageString);
                MemoryStream ms = new MemoryStream(imageByte);
                FileStream fs = new FileStream(url, FileMode.Create);

                ms.WriteTo(fs);
                ms.Close();
                fs.Close();
                ms = null;
                fs = null;

                bool check = Image_BLL.Instance.uploadChk(addModel.ImageString, url);
                if (!check)
                {
                    res.Code = "0";
                    res.Message = Resources.sysMsg.errCustomerImageAdd;
                    return toJson(res);
                }

            }
            #endregion

            res.Code = "1";
            res.Message = Resources.sysMsg.sucCustomerAdd;
            return toJson(res);

        }

        [HttpPost]
        [ActionName("updateCustomerBasic")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage updateCustomerBasic(JObject obj)
        {
            System.Diagnostics.StackTrace st = new System.Diagnostics.StackTrace(1, true);
            string strPgm;  //当前的程序名称及行号等监察信息

            ObjectResult<object> res = new ObjectResult<object>();
            res.Code = "0";
            res.Message = "更新失败！";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            CustomerBasicUpdateOperation_Model model = new CustomerBasicUpdateOperation_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<CustomerBasicUpdateOperation_Model>(strSafeJson);
            DateTime dt = DateTime.Now.ToLocalTime();

            if (model.HeadFlag == 1)
            {
                Random random = new Random();
                string randomNumber = "";

                for (int i = 0; i < 5; i++)
                {
                    randomNumber += random.Next(10).ToString();
                }

                //mImage.ObjectType = 0;
                //mImage.ObjectID = customerId;
                //mImage.Category = 0;
                string fileName = string.Format("{0:yyyyMMddHHmmssffff}", dt) + randomNumber + model.ImageType;
                model.HeadImageFile = fileName;
                //mImage.Available = true;
                //mImage.CreatorID = accountId;
                //mImage.CreateTime = dt;
                //mImage.UpdaterID = accountId;
                //mImage.UpdateTime = mImage.CreateTime;
            }
            model.CompanyID = this.CompanyID;
            model.BranchID = this.BranchID;
            model.PasswordFlag = 0;
            model.UpdateTime = DateTime.Now.ToLocalTime();
            model.AccountID = this.UserID;
            int pushFlag = 0;


            List<UserListWithMobile_Model> list = Customer_BLL.Instance.userListWithMobile(model.LoginMobile, model.CustomerID, model.CompanyID, 0);

            if (list == null || list.Count == 0)
            {
                res.Message = Resources.sysMsg.errCustomerNotExist;
                return toJson(res);
            }
            else if (list.Count != 1)
            {
                res.Message = Resources.sysMsg.existMobileError;
                return toJson(res);
            }
            else
            {
                //判断用户的密码是否存在 不存在则随机生成一个6位的数字作为密码
                //用户手机 从有到无时 密码清空
                //用户手机 从无到有是 生成密码
                //用户手机 更改时 生成新密码
                //mCust.PasswordFlag 2:手机从有到无时 1:手机更改时 
                if ((String.IsNullOrEmpty(model.LoginMobile) || String.IsNullOrWhiteSpace(model.LoginMobile)) && !Object.Equals(list[0].LoginMobile, DBNull.Value))
                {
                    //手机号从有修改成无
                    model.LoginMobile = "";
                    model.PasswordFlag = 2;
                }
                else if (model.LoginMobile != "" && (Object.Equals(list[0].LoginMobile, DBNull.Value) || list[0].LoginMobile != model.LoginMobile))
                {
                    //手机号发生更改
                    //获取公司默认密码 有则用默认密码 没有则新生成
                    model.PasswordFlag = 1;
                    object obDefaultPassword = Company_BLL.Instance.getDefaultPassword(model.BranchID);
                    //如果有默认密码 则用默认密码 不发生推送
                    if (obDefaultPassword != null && !object.Equals(obDefaultPassword, string.Empty))
                    {
                        pushFlag = 0;
                        model.Password = obDefaultPassword.ToString();
                    }
                    else
                    {
                        //如果有默认密码 则用随机生成密码 并推送
                        pushFlag = 1;
                        Random rd = new Random();
                        model.Password = rd.Next(1000000).ToString("d6");
                    }
                }
            }

            bool result = Customer_BLL.Instance.customerUpdateBasic(model);
            if (result)
            {
                res.Code = "1";
                if (model.HeadFlag == 1)
                {
                    string folder = CommonUtility.updateUrlSpell(model.CompanyID, 0, model.CustomerID);
                    string url = folder + model.HeadImageFile;

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

                    //bool check = Image_BLL.Instance.uploadChk(model.ImageString, url);

                    res.Message = Resources.sysMsg.sucCustomerBasicUpdate;

                }
                else
                {
                    res.Message = Resources.sysMsg.sucCustomerBasicUpdate;
                }

                strPgm = st.GetFrame(0).GetMethod().Name + "(" + st.GetFrame(0).GetFileLineNumber().ToString() + ")";
                int sendflag = SMSINFO_BLL.Instance.getSMSInfo(model.CompanyID, model.LoginMobile, strPgm, model.AccountID);

                #region 可发送短信件数大于已发送短信件数
                if (pushFlag == 1 && sendflag == 0)
                {
                    string companySmsheading = Company_BLL.Instance.getCompanySmsheading(model.CompanyID);
                    SendShortMessage.sendShortMessage(model.LoginMobile, model.Password, companySmsheading, 1);
                    //保存短信发送履历信息
                    string msg = string.Format(Const.MESSAGE_PASSWORD, companySmsheading, model.Password);
                    strPgm = st.GetFrame(0).GetMethod().Name + "(" + st.GetFrame(0).GetFileLineNumber().ToString() + ")";
                    SMSINFO_BLL.Instance.addSMSHis(model.CompanyID, model.BranchID, model.LoginMobile, msg, strPgm, model.AccountID);
                }
                #endregion
            }
            else
            {
                res.Message = Resources.sysMsg.errCustomerBasicUpdate;
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("updateCustomerDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage updateCustomerDetail(JObject obj)
        {
            ObjectResult<object> res = new ObjectResult<object>();
            res.Code = "0";
            res.Message = "更新失败！";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            Customer_Model model = new Customer_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<Customer_Model>(strSafeJson);
            model.UpdateTime = DateTime.Now.ToLocalTime();
            model.UpdaterID = this.UserID;
            model.CompanyID = this.CompanyID;

            bool result = Customer_BLL.Instance.customerUpdateDetail(model);
            if (result)
            {
                res.Code = "1";
                res.Message = Resources.sysMsg.sucCustomerDetailUpdate;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("deleteCustomer")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage deleteCustomer(JObject obj)
        {
            ObjectResult<object> res = new ObjectResult<object>();
            res.Code = "0";
            res.Message = "该用户已存在订单或有充值记录或不是本店创建,无法删除！";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (Customer_BLL.Instance.CustomerExistOrderOrRechargeHistory(operationModel.CustomerID, this.BranchID))
                return toJson(res);

            bool result = Customer_BLL.Instance.deleteCustomer(this.UserID, operationModel.CustomerID, this.CompanyID);

            if (result)
            {
                res.Code = "1";
                res.Message = Resources.sysMsg.sucCustomerDelete;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("getQuestionAnswer")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getQuestionAnswer(JObject obj)
        {
            ObjectResult<List<QuestionAnswer_Model>> res = new ObjectResult<List<QuestionAnswer_Model>>();
            res.Code = "0";
            res.Message = "更新失败！";
            res.Data = null;
            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            List<QuestionAnswer_Model> resModel = Customer_BLL.Instance.getQuestionAnswer(operationModel.CustomerID, this.CompanyID);
            res.Code = "1";
            res.Data = resModel;
            res.Message = Resources.sysMsg.sucCustomerDetailUpdate;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("updateAnswer")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage updateAnswer(JObject obj)
        {
            ObjectResult<object> res = new ObjectResult<object>();
            res.Code = "0";
            res.Message = "更新失败！";
            res.Data = null;
            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            UpdateAnswerOperation_Model model = Newtonsoft.Json.JsonConvert.DeserializeObject<UpdateAnswerOperation_Model>(strSafeJson);
            model.AccountID = this.UserID;
            model.CompanyID = this.CompanyID;

            bool result = Customer_BLL.Instance.updateAnswer(model);

            if (result)
            {
                res.Code = "1";
                res.Message = Resources.sysMsg.sucAnswerUpdate;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("getCartAndNewMessageCount")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getCartAndNewMessageCount(JObject obj)
        {
            ObjectResult<CartAndNewMessageCount_Model> res = new ObjectResult<CartAndNewMessageCount_Model>();
            res.Code = "0";
            res.Data = null;

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel.CompanyID = this.CompanyID;
            operationModel.BranchID = this.BranchID;
            operationModel.CustomerID = this.UserID;
            CartAndNewMessageCount_Model model = Customer_BLL.Instance.getCartAndNewMessageCount(operationModel);

            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }


        [HttpPost]
        [ActionName("updateSalesPersonID")]
        [HTTPBasicAuthorize]
        // {"AccountIDList":[2754,2589],"CustomerID":2569}
        public HttpResponseMessage updateSalesPersonID(JObject obj)
        {
            ObjectResult<object> res = new ObjectResult<object>();
            res.Code = "0";
            res.Data = null;

            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string advanced = Company_BLL.Instance.getAdvancedByCompanyID(this.CompanyID);
            if (!advanced.Contains("|4|"))
            {
                res.Message = "当前公司没有销售顾问功能!";
                return toJson(res);
            }

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (operationModel.AccountIDList == null || operationModel.AccountIDList.Count <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.CompanyID = this.CompanyID;
            operationModel.BranchID = this.BranchID;
            operationModel.CreatorID = this.UserID;

            bool result = Customer_BLL.Instance.updateSalesPersonID(operationModel.CompanyID, operationModel.BranchID, operationModel.AccountIDList, operationModel.CustomerID, operationModel.CreatorID);

            if (!result)
            {
                res.Message = Resources.sysMsg.errSystemHandle;
                return toJson(res);
            }
            res.Code = "1";
            res.Message = "修改成功！";

            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetCustomerSourceType")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCustomerSourceType(JObject obj)
        {
            ObjectResult<List<CustomerSourceType_Model>> res = new ObjectResult<List<CustomerSourceType_Model>>();
            res.Code = "0";
            res.Data = null;

            List<CustomerSourceType_Model> list = Customer_BLL.Instance.GetCustomerSourceTypeList(this.CompanyID);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

    }
}
