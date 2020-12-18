using ClientApi.Authorize;
using ClientAPI.BLL;
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

namespace ClientApi.Controllers.API
{
    public class NoticeController : BaseController
    {
        [HttpPost]
        [ActionName("GetNoticeList")]
        public HttpResponseMessage GetNoticeList()
        {
            ObjectResult<List<Notice_Model>> res = new ObjectResult<List<Notice_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            List<Notice_Model> list = new List<Notice_Model>();
            int recordCount = 0;
            list = Notice_BLL.Instance.getNoticeList(this.CompanyID, 1, 0, 1, 999999999, out recordCount);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res, "yyyy-MM-dd");
        }

        [HttpPost]
        [ActionName("GetNoticeDetail")]
        public HttpResponseMessage GetNoticeDetail(JObject obj)
        {
            ObjectResult<Notice_Model> res = new ObjectResult<Notice_Model>();
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

            if (operationModel == null || operationModel.ID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            Notice_Model model = new Notice_Model();
            model = Notice_BLL.Instance.getNoticeDetail(this.CompanyID, operationModel.ID);

            res.Code = "1";
            res.Message = "";
            res.Data = model;

            return toJson(res, "yyyy-MM-dd");
        }
    }
}
