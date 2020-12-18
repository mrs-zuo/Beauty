using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.Table_Model;
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
using WebAPI.Controllers.API;

namespace WebAPI.Controllers.Manager
{
    public class Benefit_MController : BaseController
    {

        [HttpPost]
        [ActionName("GetBenefitList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetBenefitList(JObject obj)
        {
            ObjectResult<List<BenefitPolicy_Model>> res = new ObjectResult<List<BenefitPolicy_Model>>();
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

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            List<BenefitPolicy_Model> list = new List<BenefitPolicy_Model>();
            list = Benefit_BLL.Instance.getBenefitList(this.CompanyID, operationModel.BranchID);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }



        [HttpPost]
        [ActionName("GetBenefitDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetBenefitDetail(JObject obj)
        {
            ObjectResult<BenefitPolicy_Model> res = new ObjectResult<BenefitPolicy_Model>();
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

            BenefitPolicy_Model operationModel = new BenefitPolicy_Model();
            operationModel = JsonConvert.DeserializeObject<BenefitPolicy_Model>(strSafeJson);
            BenefitPolicy_Model model = new BenefitPolicy_Model();
            model = Benefit_BLL.Instance.getBenefitDetail(this.CompanyID,operationModel.PolicyID);

            if (model == null) {
                model = new BenefitPolicy_Model();
                model.StartDate = DateTime.Now.ToLocalTime();
            }
            model.listRule = new List<PromotionRule_Model>();
            model.listRule = Benefit_BLL.Instance.getBenfitRule();

            res.Code = "1";
            res.Message = "";
            res.Data = model;

            return toJson(res);
        }



        [HttpPost]
        [ActionName("AddBenefitPolicy")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage AddBenefitPolicy(JObject obj)
        {
            ObjectResult<string> res = new ObjectResult<string>();
            res.Code = "0";
            res.Message = "添加失败!";
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

            BenefitPolicy_Model operationModel = new BenefitPolicy_Model();
            operationModel = JsonConvert.DeserializeObject<BenefitPolicy_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;
            operationModel.CreatorID = this.UserID;
            operationModel.CreateTime = DateTime.Now.ToLocalTime();
            string policyId = Benefit_BLL.Instance.AddBenefitPolicy(operationModel);

            if (!string.IsNullOrEmpty(policyId)) {

                res.Code = "1";
                res.Message = "添加成功!";
                res.Data = policyId;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("UpdateBenefitPolicy")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage UpdateBenefitPolicy(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "修改失败";
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

            BenefitPolicy_Model operationModel = new BenefitPolicy_Model();
            operationModel = JsonConvert.DeserializeObject<BenefitPolicy_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;
            operationModel.UpdaterID = this.UserID;
            operationModel.UpdateTime = DateTime.Now.ToLocalTime();
            bool result = Benefit_BLL.Instance.UpdateBenefitPolicy(operationModel);

            if (result)
            {

                res.Code = "1";
                res.Message = "修改成功";
                res.Data = result;
            }

            return toJson(res);
        }



        [HttpPost]
        [ActionName("DeteleBenefitPolicy")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage DeteleBenefitPolicy(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "删除失败";
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

            BenefitPolicy_Model operationModel = new BenefitPolicy_Model();
            operationModel = JsonConvert.DeserializeObject<BenefitPolicy_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;
            operationModel.UpdaterID = this.UserID;
            operationModel.UpdateTime = DateTime.Now.ToLocalTime();
            bool result = Benefit_BLL.Instance.DeteleBenefitPolicy(operationModel);

            if (result)
            {

                res.Code = "1";
                res.Message = "删除成功";
                res.Data = result;
            }

            return toJson(res);
        }




        [HttpPost]
        [ActionName("BranchSelect")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage BranchSelect(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "更新失败！";

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

            if (this.BranchID > 0)
            {
                res.Message = "必须总部操作";
                return toJson(res);
            }


            BranchSelectOperation_Model model = new BranchSelectOperation_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<BranchSelectOperation_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.OperatorID = this.UserID;
            model.OperatorTime = DateTime.Now.ToLocalTime();
            int result = Benefit_BLL.Instance.OperateBranch(model);
            if (result == 1)
            {
                res.Code = "1";
                res.Data = true;
                res.Message = "操作成功!";
            }
            else if (result == -1)
            {
                res.Message = "已经开始发放的优惠劵不能编辑!";

            }

            return toJson(res);
        }

    }
}
