using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
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
    public class WebUtility_MController : BaseController
    {
        [HttpPost]
        [ActionName("batchImport")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage batchImport(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "添加失败！";

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

            UtilityOperation_Model model = new UtilityOperation_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            WebUtilty_BLL.Instance.batchImport(model.FileName,model.Type,this.BranchID,this.UserID,this.CompanyID);

            return toJson(res);
        }
        [HttpPost]
        [ActionName("batchImportCommodityBatch")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage batchImportCommodityBatch(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "添加失败！";

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
            try {
                UtilityOperation_Model model = new UtilityOperation_Model();
                model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
                WebUtilty_BLL.Instance.batchImportCommodityBatch(model.FileName, model.Type, model.BranchID, this.UserID, this.CompanyID);
                res.Code = "1";
                res.Data = true;
                res.Message = "添加成功！";
                return toJson(res);
            } catch {
                return toJson(res);
            }
            
        }
        [HttpPost]
        [ActionName("BranchSelect")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage BranchSelect(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "添加失败！";

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

            if (this.BranchID > 0) {
                res.Message = "必须总部操作";
                return toJson(res);
            }


            BranchSelectOperation_Model model = new BranchSelectOperation_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<BranchSelectOperation_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.OperatorID = this.UserID;
            model.OperatorTime = DateTime.Now.ToLocalTime();
            bool result = false;
             if (model.ObjectType == 2) {
                result = Promotion_BLL.Instance.OperateBranch(model);
            }

            res.Code = "1";
            res.Data = result;
            if (result)
            {
                res.Message = "操作成功!";
            }
            else
            {
                res.Message = "操作失败!";
            
            }

            return toJson(res);
        }
    }
}
