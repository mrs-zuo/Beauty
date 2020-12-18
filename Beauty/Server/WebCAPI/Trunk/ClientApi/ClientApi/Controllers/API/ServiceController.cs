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
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace ClientApi.Controllers.API
{
    public class ServiceController : BaseController
    {
        [HttpPost]
        [ActionName("GetServiceListByCompanyID")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetServiceListByCompanyID(JObject obj)
        {
            ObjectResult<ProductListInfo_Model> res = new ObjectResult<ProductListInfo_Model>();
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
            operationModel.CustomerID = this.UserID;
            operationModel.CompanyID = this.CompanyID;

            if (operationModel.CustomerID < 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }

            ProductListInfo_Model model = new ProductListInfo_Model();
            model = Service_BLL.Instance.GetServiceListByCompanyId(operationModel.CompanyID, operationModel.CustomerID, operationModel.ImageHeight, operationModel.ImageWidth);
            res.Data = model;
            res.Code = "1";
            return toJson(res);

        }

        [HttpPost]
        [ActionName("GetServiceListByCategoryID")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getServiceListByCategoryID(JObject obj)
        {
            ObjectResult<ProductListInfo_Model> res = new ObjectResult<ProductListInfo_Model>();
            res.Code = "0";
            res.Data = null;

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;
            operationModel.CustomerID = this.UserID;

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }

            ProductListInfo_Model model = Service_BLL.Instance.getServiceListByCategoryId(operationModel.CompanyID, operationModel.CategoryID, operationModel.CustomerID, operationModel.isShowAll, operationModel.ImageHeight, operationModel.ImageWidth);
            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetServiceDetailByServiceCode_2_1")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetServiceDetailByServiceCode_2_1(JObject obj)
        {
            ObjectResult<ServiceDetail_Model> res = new ObjectResult<ServiceDetail_Model>();
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
            operationModel.UserID = this.UserID;

            if (operationModel.BranchID < 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ProductCode < 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            if (operationModel.AccountID < 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            if (operationModel.CustomerID < 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }

            operationModel.CompanyID = this.CompanyID;

            ServiceDetail_Model model = new ServiceDetail_Model();
            model = Service_BLL.Instance.getServiceDetailByServiceCode(operationModel);

            if (model == null)
            {
                res.Message = Resources.sysMsg.errNoService;
                res.Code = "0";
                return toJson(res);
            }

            model.HasSubServices = false;
            #region 子服务

            if (!string.IsNullOrEmpty(model.SubServiceCodes))
            {
                model.HasSubServices = true;
                List<SubServiceInServiceDetail_Model> subServiceList = new List<SubServiceInServiceDetail_Model>();
                subServiceList = Service_BLL.Instance.getSubServiceByCodes(model.SubServiceCodes);
                model.SubServices = subServiceList;
            }
            #endregion

            #region 服务图片
            List<string> imgList = Image_BLL.Instance.getServiceImage(model.ServiceID, 1, operationModel.ImageWidth, operationModel.ImageHeight);
            if (imgList != null && imgList.Count > 0)
            {
                model.ImageCount = imgList.Count;
                model.ServiceImage = imgList;
            }
            #endregion

            #region 是否收藏,返回收藏ID

            string userFavoriteID = "";
            bool isexsit = Customer_BLL.Instance.IsExistFavorite(operationModel.CompanyID, this.UserID, operationModel.ProductCode, 0, out userFavoriteID);
            if (isexsit)
            {
                model.FavoriteID = userFavoriteID;
            }

            #endregion

            #region 是否是顾客所关系的分店
            if (operationModel.CustomerID > 0)
            {
                List<ServiceEnalbeInfoDetail_Model> list = (List<ServiceEnalbeInfoDetail_Model>)Service_BLL.Instance.getServiceEnalbleForCustomer(operationModel.CustomerID, operationModel.ProductCode);
                if (list != null)
                {
                    model.ProductEnalbeInfo = list;
                }
            }
            #endregion
            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetPromotionServiceDetailByID")]
        [HTTPBasicAuthorize]
        //{"PromotionID":"PRM15121700000001","ID":1836}
        public HttpResponseMessage GetPromotionServiceDetailByID(JObject obj)
        {
            ObjectResult<PromotionProductDetail_Model> res = new ObjectResult<PromotionProductDetail_Model>();
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

            if (operationModel == null || string.IsNullOrWhiteSpace(operationModel.PromotionID) || operationModel.ID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.CompanyID = this.CompanyID;
            operationModel.BranchID = this.BranchID;
            operationModel.AccountID = this.UserID;
            operationModel.IsBusiness = this.IsBusiness;

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 500;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 500;
            }

            PromotionProductDetail_Model produtcModel = Service_BLL.Instance.GetPromotionServiceDetailByID(operationModel.CompanyID, operationModel.PromotionID, operationModel.ID,this.UserID);
            if (produtcModel != null)
            {
                List<string> imgList = Image_BLL.Instance.getServiceImage(operationModel.ID, 0, operationModel.ImageWidth, operationModel.ImageHeight);
                if (imgList != null && imgList.Count > 0)
                {
                    produtcModel.ImageCount = imgList.Count;
                    produtcModel.ProductImage = imgList;
                }
            }
            res.Code = "1";
            res.Data = produtcModel;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetRecommendedServiceListByBranchID")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage getRecommendedServiceListByBranchID(JObject obj)
        {
            ObjectResult<List<ProductList_Model>> res = new ObjectResult<List<ProductList_Model>>();
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
            operationModel.CustomerID = this.UserID;
            operationModel.CompanyID = this.CompanyID;

            if (operationModel.BranchID < 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }

            List<ProductList_Model> list = new List<ProductList_Model>();
            list = Service_BLL.Instance.getRecommendedServiceListByBranchID(operationModel.CompanyID, operationModel.ImageHeight, operationModel.ImageWidth, operationModel.BranchID);
            res.Data = list;
            res.Code = "1";
            return toJson(res);

        }

        [HttpPost]
        [ActionName("GetBoughtServiceList")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetBoughtServiceList(JObject obj)
        {
            ObjectResult<List<ProductList_Model>> res = new ObjectResult<List<ProductList_Model>>();
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
            operationModel.CustomerID = this.UserID;
            operationModel.CompanyID = this.CompanyID;

            if (operationModel.BranchID < 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 160;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 160;
            }

            List<ProductList_Model> list = new List<ProductList_Model>();
            list = Service_BLL.Instance.getBoughtServiceList(operationModel.CompanyID, operationModel.BranchID, operationModel.CustomerID, operationModel.ImageHeight, operationModel.ImageWidth);
            res.Data = list;
            res.Code = "1";
            return toJson(res);

        }

    }
}
