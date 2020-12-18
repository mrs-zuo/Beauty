using System.Collections.Generic;
using System.Net.Http;
using System.Web.Http;
using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using WebAPI.Authorize;
using WebAPI.BLL;

namespace WebAPI.Controllers.API
{
    public class CommodityController : BaseController
    {
        /// <summary>
        /// 欧小兵
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("getCommodityListByCompanyID")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getCommodityListByCompanyID(JObject obj)
        {
            ObjectResult<List<CommodityList_Model>> res = new ObjectResult<List<CommodityList_Model>>();
            res.Code = "0";
            res.Data = null;
            if (obj == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            string strSafeJson = StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            operationModel.CompanyID = this.CompanyID;
            operationModel.BranchID = this.BranchID;
            operationModel.AccountID = this.UserID;

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 500;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 500;
            }

            List<CommodityList_Model> list = new List<CommodityList_Model>();
            list = Commodity_BLL.Instance.getCommodityListByCompanyId(this.CompanyID, this.IsBusiness , this.BranchID, operationModel.AccountID, operationModel.CustomerID);

            if (list == null) return toJson(res);
            foreach (CommodityList_Model item in list)
            {
                List<ImageCommon_Model> imgList = Image_BLL.Instance.getCommodityImage_2_2(item.CommodityID, 0, operationModel.ImageWidth, operationModel.ImageHeight);
                if (imgList != null && imgList.Count > 0)
                {
                    item.ThumbnailURL = imgList[0].FileUrl;
                }
            }
            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        /// <summary>
        /// 欧小兵
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("getProductInfoList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getProductInfoList(JObject obj)
        {
            ObjectResult<List<ProductInfoList_Model>> res = new ObjectResult<List<ProductInfoList_Model>>();
            res.Code = "0";
            res.Data = null;
            string strSafeJson = StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            ProductInfoListOperation_Model model = new ProductInfoListOperation_Model();
            model = JsonConvert.DeserializeObject<ProductInfoListOperation_Model>(strSafeJson);
            model.BranchID = this.BranchID;
            ObjectResult<List<ProductInfoList_Model>> objResult = Commodity_BLL.Instance.getProductInfoList(model);
            if (objResult.Code != "1") return toJson(res);
            res.Code = "1";
            res.Data = objResult.Data;
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
            if (objResult.Code == "1" && objResult.Data!=null)
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
                if (model.IsBusiness)
                {
                    int isexsit = Account_BLL.Instance.isFavoriteExist(model.CompanyID, model.BranchID, this.UserID, model.ProductCode, 1);
                    if (isexsit > 0)
                    {
                        res.Data.FavoriteID = isexsit;
                    }
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

        /// <summary>
        /// 
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("getCommodityListByCategoryID")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getCommodityListByCategoryID(JObject obj)
        {
            ObjectResult<List<CommodityList_Model>> res = new ObjectResult<List<CommodityList_Model>>();
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
            model.IsBusiness = this.IsBusiness;
            model.AccountID = this.UserID;

            if (model.ImageHeight <= 0)
            {
                model.ImageHeight = 160;
            }

            if (model.ImageWidth <= 0)
            {
                model.ImageWidth = 160;
            }

            List<CommodityList_Model> list = Commodity_BLL.Instance.getCommodityListByCategoryID(model);
            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("deleteCommodity")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage deleteCommodity(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            string strSafeJson = StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            UtilityOperation_Model model = new UtilityOperation_Model();
            model = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            bool result = Commodity_BLL.Instance.deleteCommodity(this.UserID,model.CommodityID,this.CompanyID);
            if (!result) return toJson(res);
            res.Code = "1";
            res.Data = true;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("getPrintList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getPrintList(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            string strSafeJson = StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            UtilityOperation_Model model = new UtilityOperation_Model();
            model = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            bool result = Commodity_BLL.Instance.deleteCommodity(this.UserID, model.CommodityID, this.CompanyID);
            if (!result) return toJson(res);
            res.Code = "1";
            res.Data = true;
            return toJson(res);
        }


    }
}