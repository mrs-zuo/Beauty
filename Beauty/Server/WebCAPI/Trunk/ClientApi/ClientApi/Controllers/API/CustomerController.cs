using ClientApi.Authorize;
using ClientAPI.BLL;
using HS.Framework.Common.Entity;
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
using WebAPI.Common;

namespace ClientApi.Controllers.API
{
    public class CustomerController : BaseController
    {
        [HttpPost]
        [ActionName("GetCustomerInfo")]
        [HTTPBasicAuthorize]
        // {"CustomerID":2569}
        public HttpResponseMessage GetCustomerInfo(JObject obj)
        {
            ObjectResult<CustomerInfo_Model> res = new ObjectResult<CustomerInfo_Model>();
            res.Code = "0";
            res.Data = null;

            UtilityOperation_Model operationModel = new UtilityOperation_Model();

            operationModel.CompanyID = this.CompanyID;
            operationModel.CustomerID = this.UserID;

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 100;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 100;
            }

            CustomerInfo_Model model = Customer_BLL.Instance.getCustomerInfo(operationModel.CompanyID, operationModel.CustomerID, operationModel.ImageWidth, operationModel.ImageHeight);

            res.Code = "1";
            res.Data = model;
            return toJson(res);

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

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (operationModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.CompanyID = this.CompanyID;
            operationModel.CustomerID = this.UserID;

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 100;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 100;
            }

            CustomerBasic_Model model = Customer_BLL.Instance.getCustomerBasic(operationModel.CompanyID, operationModel.CustomerID, operationModel.ImageWidth, operationModel.ImageHeight);

            res.Code = "1";
            res.Data = model;
            return toJson(res);

        }

        [HttpPost]
        [ActionName("updateCustomerBasic")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage updateCustomerBasic(JObject obj)
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

                string fileName = string.Format("{0:yyyyMMddHHmmssffff}", dt) + randomNumber + "." + model.ImageType;
                model.HeadImageFile = fileName;
            }
            model.CompanyID = this.CompanyID;
            model.PasswordFlag = 0;
            model.UpdateTime = DateTime.Now.ToLocalTime();
            model.CustomerID = this.UserID;

            bool result = Customer_BLL.Instance.customerUpdateBasic(model);
            if (result)
            {
                res.Code = "1";
                if (model.HeadFlag == 1)
                {
                    string folder = WebAPI.Common.CommonUtility.updateUrlSpell(model.CompanyID, 0, model.CustomerID);
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

                    res.Message = Resources.sysMsg.sucCustomerBasicUpdate;

                }
                else
                {
                    res.Message = Resources.sysMsg.sucCustomerBasicUpdate;
                }
            }
            else
            {
                res.Message = Resources.sysMsg.errCustomerBasicUpdate;
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
        [ActionName("GetCustomerBranch")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCustomerBranch()
        {
            ObjectResult<List<GetBranchList_Model>> res = new ObjectResult<List<GetBranchList_Model>>();
            res.Code = "0";
            res.Data = null;

            UtilityOperation_Model operationModel = new UtilityOperation_Model();

            operationModel.CompanyID = this.CompanyID;
            operationModel.CustomerID = this.UserID;
            List<GetBranchList_Model> branchlist = Branch_BLL.Instance.GetCustomerBranch(operationModel.CompanyID, operationModel.CustomerID);
            res.Code = "1";
            res.Data = branchlist;
            return toJson(res);

        }

        [HttpPost]
        [ActionName("GetFavorteList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getFavorteList(JObject obj)
        {
            ObjectResult<List<FavoriteList_Model>> res = new ObjectResult<List<FavoriteList_Model>>();
            res.Code = "0";
            res.Data = null;

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (utilityModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CustomerID = this.UserID;

            if (utilityModel.ImageHeight <= 0)
            {
                utilityModel.ImageHeight = 100;
            }

            if (utilityModel.ImageWidth <= 0)
            {
                utilityModel.ImageWidth = 100;
            }
            List<FavoriteList_Model> list = new List<FavoriteList_Model>();
            list = Customer_BLL.Instance.getFavorteList(utilityModel.CompanyID, utilityModel.CustomerID, utilityModel.ProductType, utilityModel.ImageWidth, utilityModel.ImageHeight);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("AddFavorite")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage AddFavorite(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            CustomerFavorite_Model utilityModel = new CustomerFavorite_Model();
            utilityModel = JsonConvert.DeserializeObject<CustomerFavorite_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.ProductCode <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CustomerID = this.UserID;
            utilityModel.CreateTime = DateTime.Now.ToLocalTime();

            int addRes = Customer_BLL.Instance.addFavorite(utilityModel);

            if (addRes == 1)
            {
                res.Code = "1";
                res.Data = true;
                res.Message = "收藏成功!";
            }
            else if (addRes == 2)
            {
                res.Code = "2";
                res.Data = false;
                res.Message = "已经收藏过了!";
            }
            else
            {
                res.Code = "0";
                res.Data = false;
                res.Message = "收藏失败!";
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("DelFavorite")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage DelFavorite(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            CustomerFavorite_Model utilityModel = new CustomerFavorite_Model();
            utilityModel = JsonConvert.DeserializeObject<CustomerFavorite_Model>(strSafeJson);

            if (utilityModel == null || string.IsNullOrWhiteSpace(utilityModel.UserFavoriteID))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CustomerID = this.UserID;

            bool delRes = Customer_BLL.Instance.delFavorite(utilityModel);

            if (delRes)
            {
                res.Code = "1";
                res.Data = true;
                res.Message = "取消收藏成功!";
            }
            else
            {
                res.Code = "0";
                res.Data = false;
                res.Message = "取消收藏失败!";
            }

            return toJson(res);
        }

    }
}
