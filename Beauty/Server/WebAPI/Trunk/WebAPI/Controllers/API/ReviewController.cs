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
using WebAPI.Authorize;
using WebAPI.BLL;

namespace WebAPI.Controllers.API
{
    public class ReviewController : BaseController
    {
        ///// <summary>
        ///// 陈伟林
        ///// </summary>
        ///// <param name="obj">{"TreatmentID":20}</param>
        ///// <returns></returns>
        //[HttpPost]
        //[ActionName("GetReviewDetail")]
        //[HTTPBasicAuthorize]
        //public HttpResponseMessage GetReviewDetail(JObject obj)
        //{
        //    ObjectResult<Review_Model> res = new ObjectResult<Review_Model>();
        //    res.Code = "0";
        //    res.Message = "";
        //    res.Data = null;

        //    if (obj == null)
        //    {
        //        res.Message = "不合法参数";
        //        return toJson(res);
        //    }

        //    string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
        //    if (string.IsNullOrEmpty(strSafeJson))
        //    {
        //        res.Message = "不合法参数";
        //        return toJson(res);
        //    }

        //    Review_Model operationModel = new Review_Model();
        //    operationModel = JsonConvert.DeserializeObject<Review_Model>(strSafeJson);

        //    if (operationModel == null || operationModel.TreatmentID <= 0)
        //    {
        //        res.Message = "不合法参数";
        //        return toJson(res);
        //    }

        //    Review_Model model = Review_BLL.Instance.getReviewDetail(operationModel.TreatmentID);
        //    res.Code = "1";
        //    res.Data = model;

        //    return toJson(res);
        //}


        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"TreatmentID":20,"Satisfaction":1,"Comment":"坑爹"}</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("AddReview")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage AddReview(JObject obj)
        {
            ObjectResult<int> res = new ObjectResult<int>();
            res.Code = "0";
            res.Message = "";
            res.Data = 0;

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

            Review_Model operationModel = new Review_Model();
            operationModel = JsonConvert.DeserializeObject<Review_Model>(strSafeJson);

            if (operationModel == null || operationModel.TreatmentID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.Satisfaction < 0 || operationModel.Satisfaction > 5)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            operationModel.CompanyID = this.CompanyID;
            operationModel.CreatorID = this.UserID;
            operationModel.CreateTime = DateTime.Now.ToLocalTime();

            int result = Review_BLL.Instance.addReview(operationModel);
            if (result > 0)
            {
                res.Code = "1";
                res.Message = Resources.sysMsg.sucReviewAdd;
            }
            else
            {
                res.Message = Resources.sysMsg.errReviewAdd;
            }
            res.Data = result;

            return toJson(res);
        }


        /// <summary>
        /// 陈伟林
        /// </summary>
        /// <param name="obj">{"ReviewID":18,"Satisfaction":1,"Comment":"你大爷"}</param>
        /// <returns></returns>
        [HttpPost]
        [ActionName("UpdateReview")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage UpdateReview(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
            res.Data = false;

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

            Review_Model operationModel = new Review_Model();
            operationModel = JsonConvert.DeserializeObject<Review_Model>(strSafeJson);

            if (operationModel == null || operationModel.ReviewID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.Satisfaction < 0 || operationModel.Satisfaction > 5)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            operationModel.UpdaterID = this.UserID;
            operationModel.UpdateTime = DateTime.Now.ToLocalTime();

            bool result = Review_BLL.Instance.updateReview(operationModel);
            if (result)
            {
                res.Code = "1";
                res.Message = Resources.sysMsg.sucReviewUpdate;
            }
            else
            {
                res.Message = Resources.sysMsg.errReviewUpdate;
            }
            res.Data = result;

            return toJson(res);
        }

        ////////////////////////////////////////////////////////////////////

        [HttpPost]
        [ActionName("GetReviewDetail")]
        public HttpResponseMessage GetReviewDetail(JObject obj)
        {
            ObjectResult<GetReviewDetail_Model> res = new ObjectResult<GetReviewDetail_Model>();
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
            if (operationModel.GroupNo <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.CompanyID = this.CompanyID;
            GetReviewDetail_Model model = new GetReviewDetail_Model();
            model = Review_BLL.Instance.getReviewDetail(operationModel.CompanyID, operationModel.GroupNo);

            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetReviewDetailForTM")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetReviewDetailForTM(JObject obj)
        {
            ObjectResult<Review_Model> res = new ObjectResult<Review_Model>();
            res.Code = "0";
            res.Message = "";
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

            Review_Model operationModel = new Review_Model();
            operationModel = JsonConvert.DeserializeObject<Review_Model>(strSafeJson);

            if (operationModel == null || operationModel.TreatmentID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            Review_Model model = Review_BLL.Instance.GetReviewDetailForTM(operationModel.TreatmentID);
            res.Code = "1";
            res.Data = model;

            return toJson(res);
        }
    }
}
