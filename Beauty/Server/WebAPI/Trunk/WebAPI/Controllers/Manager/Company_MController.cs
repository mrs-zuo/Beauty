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
    public class Company_MController : BaseController
    {
        [HttpPost]
        [ActionName("GetCompanyDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCompanyDetail()
        {
            ObjectResult<Company_Model> res = new ObjectResult<Company_Model>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            Company_Model model = new Company_Model();
            model = Company_BLL.Instance.getCompanyDetailForWeb(this.CompanyID);

            res.Code = "1";
            res.Message = "";
            res.Data = model;

            return toJson(res);
        }

        [HttpPost]
        [ActionName("UpdateCompany")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage UpdateCompany(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
            res.Data = false;

            if (obj == null)
            {
                res.Message = "不合法参数！";
                return toJson(res);
            }

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数！";
                return toJson(res);
            }

            Company_Model model = Newtonsoft.Json.JsonConvert.DeserializeObject<Company_Model>(strSafeJson);
            model.ID = this.CompanyID;
            model.UpdaterID = this.UserID;
            model.UpdateTime = DateTime.Now.ToLocalTime();

            bool result = Company_BLL.Instance.UpdateCompany(model);

            if (result)
            {
                if ((model.deleteImageUrl != null && model.deleteImageUrl.Count > 0) || (model.BigImageUrl != null && model.BigImageUrl.Count > 0))
                {
                    BusinessImageOperation_Model mBusiness = new BusinessImageOperation_Model();
                    mBusiness.CompanyID = model.ID;
                    mBusiness.BranchID = 0;
                    mBusiness.UserID = this.UserID;
                    mBusiness.OperationTime = model.UpdateTime;
                    mBusiness.AddImage = model.BigImageUrl;
                    mBusiness.DeleteImage = model.deleteImageUrl;
                    result = Image_BLL.Instance.updateBusinessImage(mBusiness);
                }
                res.Code = "1";
                res.Message = "公司信息更新成功!";
                res.Data = true;
            }
            else
            {
                res.Code = "0";
                res.Message = "公司信息更新失败!";
                res.Data = false;
            
            }

            return toJson(res);
        }
    }
}
