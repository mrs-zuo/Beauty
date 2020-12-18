using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using Model.Table_Model;
using BLToolkit.Data;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using HS.Framework.Common.Entity;
using HS.Framework.Common;
using Model.View_Model;
using Model.Operation_Model;
using WebAPI.BLL;

namespace WebAPI.Controllers
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
