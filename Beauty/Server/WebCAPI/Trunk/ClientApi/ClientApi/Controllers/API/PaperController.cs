using ClientApi.Authorize;
using ClientAPI.BLL;
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
using HS.Framework.Common.Util;

namespace ClientApi.Controllers.API
{
    public class PaperController : BaseController
    {

        [HttpPost]
        [ActionName("GetAnswerPaperList")]
        [HTTPBasicAuthorize]
        /// Aaron_Han
        /// {"FilterByTimeFlag":1,"StartTime":"2012-12-12","EndTime":"2012-12-12","PageIndex":1,"PageSize":10,"ResponsiblePersonID":[4,5,6],"CustomerID":1022}
        public HttpResponseMessage GetAnswerPaperList(JObject obj)
        {
            ObjectResult<GetAnswerPaperRes_Model> res = new ObjectResult<GetAnswerPaperRes_Model>();
            res.Code = "0";
            res.Data = null;
            res.Message = "";

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

            strSafeJson = strSafeJson.Replace("\"(null)\"", "");

            GetAnswerPaperListOperation_Model operationModel = new GetAnswerPaperListOperation_Model();
            operationModel = JsonConvert.DeserializeObject<GetAnswerPaperListOperation_Model>(strSafeJson);

            if (operationModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.CompanyID = this.CompanyID;
            operationModel.IsBusiness = this.IsBusiness;

            // Business端进入
            if (this.IsBusiness)
            {
                if (!operationModel.IsShowAll)
                {
                    if (operationModel.ResponsiblePersonIDs == null || operationModel.ResponsiblePersonIDs.Count <= 0)
                    {
                        operationModel.ResponsiblePersonIDs = new List<int>();
                        operationModel.ResponsiblePersonIDs.Add(this.UserID);
                    }
                }
            }
            else
            {
                operationModel.CustomerID = this.UserID;
            }

            if (operationModel.FilterByTimeFlag == 1)
            {
                if ((String.IsNullOrWhiteSpace(operationModel.StartTime) || String.IsNullOrWhiteSpace(operationModel.EndTime)))
                {
                    res.Message = "请选择日期!";
                    return toJson(res);
                }
                else
                {
                    DateTime dtStartTime = new DateTime();
                    DateTime dtEndTiime = new DateTime();
                    if (DateTime.TryParse(operationModel.StartTime, out dtStartTime) && DateTime.TryParse(operationModel.EndTime, out dtEndTiime))
                    {
                        operationModel.StartTime = dtStartTime.ToShortDateString();
                        operationModel.EndTime = dtEndTiime.ToShortDateString();
                    }
                    else
                    {
                        res.Message = "请输入正确的时间格式!";
                        return toJson(res);
                    }
                }
            }

            if (operationModel.PageIndex <= 0)
            {
                operationModel.PageIndex = 1;
            }

            if (operationModel.PageIndex > 1 && operationModel.UpdateTime == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.PageSize <= 0)
            {
                operationModel.PageSize = 10;
            }

            if (!this.IsBusiness)
            {
                operationModel.CustomerID = this.UserID;
            }

            GetAnswerPaperRes_Model model = new GetAnswerPaperRes_Model();
            List<AnswerPaper_Model> list = new List<AnswerPaper_Model>();
            int recordCount = 0;
            list = Paper_BLL.Instance.GetAnswerPaperList(operationModel, out recordCount);

            if (list == null)
            {
                model.RecordCount = 0;
                model.PageCount = 0;
                model.PageIndex = 1;
                res.Data = model;
                res.Code = "1";
            }
            else
            {
                model.RecordCount = recordCount;
                model.PageCount = Pagination.GetPageCount(recordCount, operationModel.PageSize);
                model.PaperList = list;
                model.PageIndex = operationModel.PageIndex;
                res.Data = model;
                res.Code = "1";
            }

            return toJson(res, "yyyy-MM-dd HH:mm:ss.ff");
        }

        [HttpPost]
        [ActionName("GetPaperDetail")]
        [HTTPBasicAuthorize]
        /// Aaron_Han
        /// {"PaperID":4,"GroupID":2}
        public HttpResponseMessage GetPaperDetail(JObject obj)
        {
            ObjectResult<List<PaperDetail>> res = new ObjectResult<List<PaperDetail>>();
            res.Code = "0";
            res.Data = null;
            res.Message = "";

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

            GetAnswerDetailOperation_Model operationModel = new GetAnswerDetailOperation_Model();
            operationModel = JsonConvert.DeserializeObject<GetAnswerDetailOperation_Model>(strSafeJson);

            if (operationModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.CompanyID = this.CompanyID;

            if (operationModel.GroupID == 0 && operationModel.PaperID == 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            List<PaperDetail> list = new List<PaperDetail>();
            list = Paper_BLL.Instance.GetPaperDetail(operationModel);
            res.Data = list;
            res.Code = "1";

            return toJson(res);
        }
    }
}
