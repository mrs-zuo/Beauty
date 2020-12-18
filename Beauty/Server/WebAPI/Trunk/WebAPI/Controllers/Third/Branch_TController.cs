using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using HS.Framework.Common.Entity;
using HS.Framework.Common;
using Model.View_Model;
using Model.Operation_Model;
using WebAPI.BLL;

namespace WebAPI.Controllers.API
{
    public class Branch_TController : BaseController
    {
        [HttpPost]
        [ActionName("GeBranchList")]
        public HttpResponseMessage GeBranchList(JObject obj)
        {
            PageResult<GetBranchList_Model> res = new PageResult<GetBranchList_Model>();
            res.Code = "0";
            res.Data = null;
            try
            {
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

                int recordCount = 0;
                List<GetBranchList_Model> list = new List<GetBranchList_Model>();
                list = Branch_BLL.Instance.getBranchList(operationModel.CompanyID, operationModel.PageIndex, operationModel.PageSize, out recordCount);
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
            catch (Exception ex)
            {
                res.Code = "-1";
                res.PageSize = 0;
                res.PageIndex = 0;
                res.Data = null;
                LogUtil.Error(ex);
                return toJson(res);
            }
        }

        [HttpPost]
        [ActionName("GeBranchDetail")]
        public HttpResponseMessage GeBranchDetail(JObject obj)
        {
            ObjectResult<GetBranchDetail_Model> res = new ObjectResult<GetBranchDetail_Model>();
            res.Code = "0";
            res.Data = null;
            try
            {
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
                    operationModel.ImageHeight = 200;
                }

                if (operationModel.ImageWidth <= 0)
                {
                    operationModel.ImageWidth = 290;
                }

                GetBranchDetail_Model model = new GetBranchDetail_Model();
                model = Branch_BLL.Instance.getBranchDetail(operationModel.CompanyID, operationModel.BranchID);
                if (model != null)
                {
                    model.ImgList = Branch_BLL.Instance.getBranchImgList(operationModel.CompanyID, operationModel.BranchID, operationModel.ImageHeight, operationModel.ImageWidth, operationModel.PageSize);
                    res.Code = "1";
                    res.Data = model;
                }
                return toJson(res);
            }
            catch (Exception ex)
            {
                res.Code = "-1";
                res.Data = null;
                LogUtil.Error(ex);
                return toJson(res);
            }
        }
    }
}
