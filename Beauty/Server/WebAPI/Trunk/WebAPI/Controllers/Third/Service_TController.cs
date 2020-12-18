﻿using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.View_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using WebAPI.BLL;
using WebAPI.Controllers.API;

namespace WebAPI.Controllers.Third
{
    public class Service_TController : BaseController
    {
        [HttpPost]
        [ActionName("GetServiceList")]
        public HttpResponseMessage GetServiceList(JObject obj)
        {
            PageResult<GetProductList_Model> res = new PageResult<GetProductList_Model>();
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

            if (operationModel.CompanyID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.PageIndex <= 0)
            {
                operationModel.PageIndex = 1;
            }

            if (operationModel.PageSize <= 0)
            {
                operationModel.PageSize = 10;
            }


            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 500;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 500;
            }

            int recordCount = 0;
            List<GetProductList_Model> list = new List<GetProductList_Model>();
            list = Service_BLL.Instance.getServiceList(operationModel.CompanyID, operationModel.PageIndex, operationModel.PageSize, out recordCount, operationModel.ImageHeight, operationModel.ImageWidth, operationModel.strSearch);
            if (list != null)
            {
                res.Code = "1";
                res.PageSize = operationModel.PageSize;
                res.PageIndex = operationModel.PageIndex;
                res.RecordCount = recordCount;
                res.Data = list;
            }
            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetServiceDetail")]
        public HttpResponseMessage GetServiceDetail(JObject obj)
        {
            ObjectResult<GetServiceDetail_Model> res = new ObjectResult<GetServiceDetail_Model>();
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

            if (operationModel.CompanyID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.ImageHeight <= 0)
            {
                operationModel.ImageHeight = 500;
            }

            if (operationModel.ImageWidth <= 0)
            {
                operationModel.ImageWidth = 500;
            }

            GetServiceDetail_Model model = new GetServiceDetail_Model();
            model = Service_BLL.Instance.getServiceDetail(operationModel.CompanyID, operationModel.ServiceCode, operationModel.ImageHeight, operationModel.ImageWidth);
            if (model != null)
            {
                model.ImgList = Service_BLL.Instance.getServiceImgList(operationModel.CompanyID, model.ServiceID, operationModel.ImageHeight, operationModel.ImageWidth, operationModel.PageSize);
                model.SubServiceNameList = Service_BLL.Instance.getSubServiceName(operationModel.CompanyID, model.ServiceID);
                if (operationModel.BrowseHistoryCodes != null && operationModel.BrowseHistoryCodes != "")
                {
                    List<BrowseHistoryOperation_Model> listBrowse = new List<BrowseHistoryOperation_Model>();
                    listBrowse = JsonConvert.DeserializeObject<List<BrowseHistoryOperation_Model>>(operationModel.BrowseHistoryCodes);

                    if (listBrowse != null && listBrowse.Count > 0)
                    {
                        string strServiceCodes = "";
                        foreach (BrowseHistoryOperation_Model item in listBrowse)
                        {
                            if (strServiceCodes != "")
                            {
                                strServiceCodes += " , "; 
                            }
                            strServiceCodes += item.ServiceCode.ToString();
                        }
                        if (strServiceCodes != "")
                        {
                            List<GetProductList_Model> ListHistory = Service_BLL.Instance.getServiceBrowseHistoryList(operationModel.CompanyID, strServiceCodes, operationModel.ImageHeight, operationModel.ImageWidth);
                            model.BrowseHistoryList = JsonConvert.SerializeObject(ListHistory);
                        }
                    }
                }

                res.Code = "1";
                res.Data = model;
            }
            return toJson(res);
        }
    }
}
