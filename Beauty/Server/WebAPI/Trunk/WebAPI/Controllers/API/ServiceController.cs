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
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using WebAPI.Authorize;
using WebAPI.BLL;

namespace WebAPI.Controllers.API
{
    public class ServiceController : BaseController
    {
        #region 手机端方法

        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"CustomerID":2497,"ProductCode":856,"BranchID":38,"ImageWidth":160,"ImageHeight":160}</param>
        /// <returns></returns>
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
            if (this.IsBusiness)
            {
                int isexsit = Account_BLL.Instance.isFavoriteExist(operationModel.CompanyID, operationModel.BranchID, operationModel.UserID, operationModel.ProductCode, 0);
                if (isexsit > 0)
                {
                    model.FavoriteID = isexsit;
                }
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



        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"BranchID": 0,"CustomerID":33,"ImageHeight": 200,"ImageWidth": 290}</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetServiceListByCompanyID")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetServiceListByCompanyID(JObject obj)
        {
            ObjectResult<List<GetSeriviceList_Model>> res = new ObjectResult<List<GetSeriviceList_Model>>();
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

            List<GetSeriviceList_Model> list = new List<GetSeriviceList_Model>();
            list = Service_BLL.Instance.getServiceListByCompanyId(this.CompanyID, this.IsBusiness, this.BranchID, this.UserID, operationModel.CustomerID, operationModel.ImageHeight, operationModel.ImageWidth);

            res.Data = list;
            res.Code = "1";
            return toJson(res);

        }


        /// <summary>
        /// 
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("getServiceListByCategoryID")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getServiceListByCategoryID(JObject obj)
        {
            ObjectResult<List<GetSeriviceList_Model>> res = new ObjectResult<List<GetSeriviceList_Model>>();
            res.Code = "0";
            res.Data = null;

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            UtilityOperation_Model model = new UtilityOperation_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
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


            List<GetSeriviceList_Model> list = Service_BLL.Instance.getServiceListByCategoryId(model);
            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }
        #endregion
    }
}
