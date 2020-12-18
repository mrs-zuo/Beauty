using HS.Framework.Common;
using HS.Framework.Common.Entity;
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

namespace WebAPI.Controllers
{
    public class NewsController : BaseController
    {
        [HttpPost]
        [ActionName("GetNewsListByCompanyID")]
        //CompanyID Type PageIndex PageSize
        public HttpResponseMessage GetNewsListByCompanyID(JObject obj)
        {
            PageResult<GetNewsList_Model> res = new PageResult<GetNewsList_Model>();
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
                List<GetNewsList_Model> list = News_BLL.Instance.getNewsList(operationModel.CompanyID, operationModel.PageIndex, operationModel.PageSize, operationModel.Type, out recordCount);
                res.Code = "1";
                res.PageSize = operationModel.PageSize;
                res.PageIndex = operationModel.PageIndex;
                res.RecordCount = recordCount;
                res.Data = list;
                return toJson(res,"MM-dd");
            }
            catch (Exception ex)
            {
                res.Code = "-1";
                res.PageSize = 0;
                res.PageIndex = 0;
                res.Data = null;
                LogUtil.Log(ex);
                return toJson(res);
            }
        }

        [HttpPost]
        [ActionName("GetNoticeDetail")]
        //CompanyID ID
        public HttpResponseMessage GetNoticeDetail(JObject obj)
        {
            ObjectResult<GetNewsDetail_Model> res = new ObjectResult<GetNewsDetail_Model>();
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

                if (operationModel.CompanyID <= 0 || operationModel.ID <= 0)
                {
                    res.Message = "不合法参数";
                    return toJson(res);
                }

                GetNewsDetail_Model model = News_BLL.Instance.getNewsDetail(operationModel.CompanyID, operationModel.ID);

                res.Code = "1";
                res.Data = model;
                return toJson(res);
            }
            catch (Exception ex)
            {
                res.Code = "-1";
                res.Data = null;
                LogUtil.Log(ex);
                return toJson(res);
            }
        }
    }
}
