using HS.Framework.Common.Entity;
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
    public class Paper_MController : BaseController
    {
        [HttpPost]
        [ActionName("GetPaperList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetPaperList()
        {
            ObjectResult<List<PaperTable_Model>> res = new ObjectResult<List<PaperTable_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;


            List<PaperTable_Model> list = new List<PaperTable_Model>();
            list = Paper_BLL.Instance.getPaperListForWeb(this.CompanyID);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }


        [HttpPost]
        [ActionName("DeletePaper")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage DeletePaper(JObject obj)
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

            PaperTable_Model mPaper = new PaperTable_Model();
            mPaper = JsonConvert.DeserializeObject<PaperTable_Model>(strSafeJson);
            mPaper.UpdaterID = this.UserID;
            mPaper.UpdateTime = DateTime.Now.ToLocalTime();

            bool result = Paper_BLL.Instance.deletePaper(mPaper);

            if (result)
            {
                res.Code = "1";
                res.Message = "删除成功!";
                res.Data = true;
            }
            else
            {
                res.Code = "1";
                res.Message = "删除失败!";
                res.Data = false;
            }

            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetPaperDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetPaperDetail(JObject obj)
        {
            ObjectResult<PaperTable_Model> res = new ObjectResult<PaperTable_Model>();
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

            PaperTable_Model mPaper = new PaperTable_Model();
            mPaper = JsonConvert.DeserializeObject<PaperTable_Model>(strSafeJson);

            PaperTable_Model model = Paper_BLL.Instance.getPaperDetail(mPaper.ID);

            res.Code = "1";
            res.Data = model;

            return toJson(res);
        }



        [HttpPost]
        [ActionName("AddPaper")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage AddPaper(JObject obj)
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

            PaperTable_Model mPaper = new PaperTable_Model();
            mPaper = JsonConvert.DeserializeObject<PaperTable_Model>(strSafeJson);
            mPaper.CompanyID = this.CompanyID;
            mPaper.CreatorID = this.UserID;
            mPaper.CreateTime = DateTime.Now.ToLocalTime();

            int result = Paper_BLL.Instance.addPaper(mPaper);

            if (result == 1)
            {
                res.Code = "1";
                res.Message = "添加成功!";
                res.Data = true;
            }
            else if(result == 0)
            {
                res.Message = "添加失败!";
                res.Data = false;
            }
            else if (result == -1) {

                res.Message = "该公司不能再添加卷子!";
                res.Data = false;
            }

            return toJson(res);
        }






        [HttpPost]
        [ActionName("UpdatePaper")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage UpdatePaper(JObject obj)
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

            PaperTable_Model mPaper = new PaperTable_Model();
            mPaper = JsonConvert.DeserializeObject<PaperTable_Model>(strSafeJson);
            mPaper.CompanyID = this.CompanyID;
            mPaper.CreatorID = this.UserID;
            mPaper.CreateTime = DateTime.Now.ToLocalTime();
            mPaper.UpdaterID = this.UserID;
            mPaper.UpdateTime = DateTime.Now.ToLocalTime();

            bool result = Paper_BLL.Instance.updatePaper(mPaper);

            if (result)
            {
                res.Code = "1";
                res.Message = "更新成功!";
                res.Data = true;
            }
            else
            {
                res.Code = "1";
                res.Message = "更新失败!";
                res.Data = false;
            }

            return toJson(res);
        }
    }
}
