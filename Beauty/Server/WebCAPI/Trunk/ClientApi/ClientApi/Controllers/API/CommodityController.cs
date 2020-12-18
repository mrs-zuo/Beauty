using ClientApi.Authorize;
using ClientAPI.BLL;
using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
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
    public class CommodityController : BaseController
    {
        [HttpPost]
        [ActionName("GetCommodityListByCompanyID")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetCommodityListByCompanyID(JObject obj)
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
            model = Commodity_BLL.Instance.GetCommodityListByCompanyId(operationModel.CompanyID, operationModel.CustomerID, operationModel.ImageHeight, operationModel.ImageWidth);
            res.Data = model;
            res.Code = "1";
            return toJson(res);

        }

        [HttpPost]
        [ActionName("GetCommodityListByCategoryID")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCommodityListByCategoryID(JObject obj)
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

            ProductListInfo_Model model = Commodity_BLL.Instance.getCommodityListByCategoryID(operationModel.CompanyID, operationModel.CategoryID, operationModel.CustomerID, operationModel.isShowAll, operationModel.ImageHeight, operationModel.ImageWidth);
            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }

        /// <summary>
        /// 欧小兵
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("getCommodityDetailByCommodityCode")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getCommodityDetailByCommodityCode(JObject obj)
        {
            ObjectResult<CommodityDetail_Model> res = new ObjectResult<CommodityDetail_Model>();
            res.Code = "0";
            res.Data = null;
            string strSafeJson = StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            UtilityOperation_Model model = new UtilityOperation_Model();
            model = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            model.CompanyID = this.CompanyID;
            model.BranchID = this.BranchID;
            model.AccountID = this.UserID;
            model.IsBusiness = this.IsBusiness;

            if (model.ImageHeight <= 0)
            {
                model.ImageHeight = 500;
            }

            if (model.ImageWidth <= 0)
            {
                model.ImageWidth = 500;
            }

            ObjectResult<CommodityDetail_Model> objResult = Commodity_BLL.Instance.getCommodityDetailByCommodityCode(model);
            if (objResult.Code == "1" && objResult.Data != null)
            {
                res.Code = "1";
                res.Data = objResult.Data;

                #region 服务图片
                List<ImageCommon_Model> imgList = Image_BLL.Instance.getCommodityImage_2_2(res.Data.CommodityID, 1, model.ImageWidth, model.ImageHeight);
                if (imgList != null && imgList.Count > 0)
                {
                    res.Data.ImageCount = imgList.Count;
                    List<string> strImgList = new List<string>();
                    foreach (ImageCommon_Model item in imgList)
                    {
                        strImgList.Add(item.FileUrl);
                    }
                    res.Data.CommodityImage = strImgList;
                }
                #endregion

                #region 是否收藏,返回收藏ID

                string userFavoriteID = "";
                bool isexsit = Customer_BLL.Instance.IsExistFavorite(model.CompanyID, this.UserID, model.ProductCode, 1, out userFavoriteID);
                if (isexsit)
                {
                    res.Data.FavoriteID = userFavoriteID;
                }

                #endregion

                #region 是否是顾客所关系的分店

                if (model.IsBusiness) return toJson(res);
                List<CommodityEnalbeInfoDetail> list = (List<CommodityEnalbeInfoDetail>)Commodity_BLL.Instance.getCommodityEnalbleForCustomer(model.CustomerID, model.ProductCode);
                if (list != null)
                {
                    res.Data.ProductEnalbeInfo = list;
                }

                #endregion

            }
            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetPromotionCommodityDetailByID")]
        [HTTPBasicAuthorize]
        //{"PromotionID":"PRM15121700000001","ID":1836}
        public HttpResponseMessage GetPromotionCommodityDetailByID(JObject obj)
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

            PromotionProductDetail_Model produtcModel = Commodity_BLL.Instance.GetPromotionCommodityDetailByID(operationModel.CompanyID, operationModel.PromotionID, operationModel.ID,this.UserID);
            if (produtcModel != null)
            {
                List<ImageCommon_Model> imgList = Image_BLL.Instance.getCommodityImage_2_2(operationModel.ID, 1, operationModel.ImageWidth, operationModel.ImageHeight);
                if (imgList != null && imgList.Count > 0)
                {
                    produtcModel.ImageCount = imgList.Count;
                    List<string> strImgList = new List<string>();
                    foreach (ImageCommon_Model item in imgList)
                    {
                        strImgList.Add(item.FileUrl);
                    }
                    produtcModel.ProductImage = strImgList;
                }
            }
            res.Code = "1";
            res.Data = produtcModel;
            return toJson(res);
        }


        [HttpPost]
        [ActionName("getProductInfoList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getProductInfoList(JObject obj)
        {
            ObjectResult<List<ProductInfoList_Model>> res = new ObjectResult<List<ProductInfoList_Model>>();
            res.Code = "0";
            res.Data = null;

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            CartOperation_Model utilityModel = new CartOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<CartOperation_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.CartIDList == null || utilityModel.CartIDList.Count <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CustomerID = this.UserID;
            utilityModel.CreatorID = this.UserID;
            utilityModel.UpdaterID = this.UserID;
            utilityModel.CreateTime = DateTime.Now.ToLocalTime();
            utilityModel.UpdateTime = DateTime.Now.ToLocalTime();

            List<ProductInfoList_Model> list = Commodity_BLL.Instance.getProductInfoList(utilityModel);
            res.Code = "1";
            res.Data = list;

            return toJson(res);
        }



        [HttpPost]
        [ActionName("getProductInfoListForWeb")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getProductInfoListForWeb(JObject obj)
        {
            ObjectResult<List<ProductInfoList_Model>> res = new ObjectResult<List<ProductInfoList_Model>>();
            res.Code = "0";
            res.Data = null;

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            CartOperation_Model utilityModel = new CartOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<CartOperation_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.CartIDList == null || utilityModel.CartIDList.Count <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CustomerID = this.UserID;
            utilityModel.CreatorID = this.UserID;
            utilityModel.UpdaterID = this.UserID;
            utilityModel.CreateTime = DateTime.Now.ToLocalTime();
            utilityModel.UpdateTime = DateTime.Now.ToLocalTime();

            List<ProductInfoList_Model> list = Commodity_BLL.Instance.getProductInfoListForWeb(utilityModel);
            res.Code = "1";
            res.Data = list;

            return toJson(res);
        }


        [HttpPost]
        [ActionName("getRecommendedProductList")]
        public HttpResponseMessage getRecommendedProductList(JObject obj)
        {
            ObjectResult<List<ProductList_Model>> res = new ObjectResult<List<ProductList_Model>>();
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

            if ( this.CompanyID <= 0)
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
            List<ProductList_Model> ServiceList = Service_BLL.Instance.getRecommendedServiceList(this.CompanyID, operationModel.ImageHeight, operationModel.ImageWidth);
            if (ServiceList != null && ServiceList.Count > 0)
            {
                list.AddRange(ServiceList);
            }

            List<ProductList_Model> CommodityList = Commodity_BLL.Instance.getRecommendedCommodityList(this.CompanyID, operationModel.ImageHeight, operationModel.ImageWidth);
            if (CommodityList != null && CommodityList.Count > 0)
            {
                list.AddRange(CommodityList);
            }

            res.Code = "1";
            res.Data = list;

            return toJson(res);
        }
    }
}
