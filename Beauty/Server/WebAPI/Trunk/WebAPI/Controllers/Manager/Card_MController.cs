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
    public class Card_MController : BaseController
    {
        [HttpPost]
        [ActionName("GetCardList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCardList()
        {
            ObjectResult<List<Card_Model>> res = new ObjectResult<List<Card_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            List<Card_Model> list = new List<Card_Model>();
            list = Card_BLL.Instance.getCardList(this.CompanyID);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }


        [HttpPost]
        [ActionName("DeleteCard")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage DeleteCard(JObject obj)
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


            Card_Model model = new Card_Model();
            model = JsonConvert.DeserializeObject<Card_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.UpdaterID = this.UserID;
            model.UpdateTime = DateTime.Now.ToLocalTime();
            bool result = Card_BLL.Instance.deleteCard(model);

            if (result)
            {
                res.Code = "1";
                res.Message = "删除成功!";
                res.Data = true;
            }

            return toJson(res);
        }



        [HttpPost]
        [ActionName("GetCardDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetCardDetail(JObject obj)
        {
            ObjectResult<Card_Model> res = new ObjectResult<Card_Model>();
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

            Card_Model operatorModel = new Card_Model();
            operatorModel = JsonConvert.DeserializeObject<Card_Model>(strSafeJson);
            Card_Model resultModel = new Card_Model();

            resultModel = Card_BLL.Instance.getCardDetail(operatorModel.CardCode,this.CompanyID);

            res.Code = "1";
            res.Message = "";
            res.Data = resultModel;

            return toJson(res);
        }






        [HttpPost]
        [ActionName("AddCard")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage AddCard(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "添加失败";
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

            Card_Model operatorModel = new Card_Model();
            operatorModel = JsonConvert.DeserializeObject<Card_Model>(strSafeJson);
            operatorModel.CompanyID = this.CompanyID;
            operatorModel.Available = true;
            operatorModel.CreatorID = this.UserID;
            operatorModel.CreateTime = DateTime.Now.ToLocalTime();
            int  result = Card_BLL.Instance.addCard(operatorModel);

            if (result == 1)
            {
                res.Code = "1";
                res.Message = "添加成功!";
                res.Data = true;
            }
            else if(result == -1) {
                res.Message = "该卡名已经存在!";
            }

            return toJson(res);
        }




        [HttpPost]
        [ActionName("UpdateCard")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage UpdateCard(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "更新失败";
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

            Card_Model operatorModel = new Card_Model();
            operatorModel = JsonConvert.DeserializeObject<Card_Model>(strSafeJson);
            operatorModel.CompanyID = this.CompanyID;
            operatorModel.UpdaterID = this.UserID;
            operatorModel.UpdateTime = DateTime.Now.ToLocalTime();
            int result = Card_BLL.Instance.updateCard(operatorModel);

            if (result == 1)
            {
                res.Code = "1";
                res.Message = "更新成功!";
                res.Data = true;
            }
            else if (result == -1) {

                res.Message = "该卡已经被其他账户更新成功!";
            }
            else if (result == -2)
            {
                res.Message = "该卡名已经存在!";
            }

            return toJson(res);
        }


        [HttpPost]
        [ActionName("SetDefaultCard")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage SetDefaultCard(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "设置失败";
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

            Card_Model operationModel = new Card_Model();
            operationModel = JsonConvert.DeserializeObject<Card_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;
            operationModel.CreatorID = this.UserID;
            operationModel.UpdaterID = this.UserID;
            operationModel.UpdateTime = DateTime.Now.ToLocalTime();

            bool isSuccess = Card_BLL.Instance.updateDefaultCardID(operationModel);

            if (isSuccess)
            {
                res.Code = "1";
                res.Message = "设置成功";
                res.Data = isSuccess;
            }

            return toJson(res);
        }


    }
}
