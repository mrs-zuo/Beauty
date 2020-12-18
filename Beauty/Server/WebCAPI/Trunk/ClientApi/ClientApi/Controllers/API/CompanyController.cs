﻿using ClientApi.Authorize;
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
using HS.Framework.Common.Util;

namespace ClientApi.Controllers.API
{
    public class CompanyController : BaseController
    {
        [HttpPost]
        [ActionName("GetCompanyDetail")]
        public HttpResponseMessage GetCompanyDetail(JObject obj)
        {
            ObjectResult<GetCompanyDetail_Model> res = new ObjectResult<GetCompanyDetail_Model>();
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
            if (operationModel.CompanyID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 200;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 290;
            }

            GetCompanyDetail_Model model = new GetCompanyDetail_Model();
            model = Company_BLL.Instance.getCompanyDetail(operationModel.CompanyID);
            if (model != null)
            {
                model.ImgList = Company_BLL.Instance.getCompanyImgList(operationModel.CompanyID, operationModel.ImageHeight, operationModel.ImageWidth, operationModel.PageSize);
                res.Code = "1";
                res.Data = model;
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetCompanySimpleDetail")]
        public HttpResponseMessage GetCompanySimpleDetail()
        {
            ObjectResult<GetCompanyDetail_Model> res = new ObjectResult<GetCompanyDetail_Model>();
            res.Code = "0";
            res.Data = null;

            GetCompanyDetail_Model model = new GetCompanyDetail_Model();
            model = Company_BLL.Instance.getCompanyDetail(this.CompanyID, false);

            res.Code = "1";
            res.Data = model;

            return toJson(res);
        }

        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetBranchList")]
        public HttpResponseMessage GetBranchList(JObject obj)
        {
            ObjectResult<List<GetBranchList_Model>> res = new ObjectResult<List<GetBranchList_Model>>();
            res.Code = "0";
            res.Data = null;
            GetBranchList_Model operationModel = new GetBranchList_Model();
            if (obj == null)
            {
                operationModel.Longitude = 0;
                operationModel.Latitude = 0;
            }
            else
            {
                string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
                if (string.IsNullOrEmpty(strSafeJson))
                {
                    res.Message = "不合法参数";
                    return toJson(res);
                }
                operationModel = JsonConvert.DeserializeObject<GetBranchList_Model>(strSafeJson);
            }
            List<GetBranchList_Model> list = new List<GetBranchList_Model>();

            list = Company_BLL.Instance.getBranchByCompanyId(this.CompanyID);


            foreach (GetBranchList_Model item in list)
            {
                if (operationModel.Longitude != 0 && operationModel.Latitude != 0)
                {
                    if (item.Longitude != 0 && item.Latitude != 0)
                    {
                        item.Distance = Tools.Calculates(operationModel.Longitude, operationModel.Latitude, item.Longitude, item.Latitude);
                    }
                }
                else
                {
                    item.Distance = -1;
                }
            }

            if (operationModel.Longitude != 0 && operationModel.Latitude != 0)
            {
                list = list.OrderBy(c => c.Distance).ToList<GetBranchList_Model>();
            }
            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }


        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"BranchID": 0,"ImageHeight": 200,"ImageWidth": 290}</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetBusinessDetail")]
        public HttpResponseMessage GetBusinessDetail(JObject obj)
        {
            ObjectResult<GetBusinessDetail_Model> res = new ObjectResult<GetBusinessDetail_Model>();
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

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 200;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 290;
            }

            GetBusinessDetail_Model model = new GetBusinessDetail_Model();
            if (operationModel.BranchID == 0)
            {
                ///BranchID为0,获取公司信息
                model = Company_BLL.Instance.getCompanyDetailForMobile(this.CompanyID);
            }
            else
            {
                ///BranchID为0,获取门店信息
                model = Company_BLL.Instance.getBranchDetail(operationModel.BranchID);
            }

            if (model != null)
            {
                List<ImageCommon_Model> list = new List<ImageCommon_Model>();
                list = Image_BLL.Instance.getBusinessImage(this.CompanyID, operationModel.BranchID, operationModel.ImageHeight, operationModel.ImageWidth);

                model.ImageCount = list.Count;
                List<string> strList = new List<string>();
                foreach (ImageCommon_Model item in list)
                {
                    strList.Add(item.FileUrl);
                }
                model.ImageURL = strList;
            }

            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }


        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"BranchID": 0,"ImageHeight": 200,"ImageWidth": 290}</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("GetBusinessImage")]
        public HttpResponseMessage GetBusinessImage(JObject obj)
        {
            ObjectResult<List<string>> res = new ObjectResult<List<string>>();
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

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 200;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 290;
            }

            List<ImageCommon_Model> list = new List<ImageCommon_Model>();
            //if (operationModel.BranchID == 0)
            //{
            //    res.Message = "不合法参数";
            //    return toJson(res);
            //}

            list = Image_BLL.Instance.getBusinessImage(this.CompanyID, operationModel.BranchID, operationModel.ImageHeight, operationModel.ImageWidth);


            List<string> strList = new List<string>();
            foreach (ImageCommon_Model item in list)
            {
                strList.Add(item.FileUrl);
            }

            res.Code = "1";
            res.Data = strList;
            return toJson(res);
        }

    }
}
