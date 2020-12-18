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
    public class Promotion_MController : BaseController
    {
        [HttpPost]
        [ActionName("GetPromotionList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetPromotionList(JObject obj)
        {
            ObjectResult<List<Promotion_Model>> res = new ObjectResult<List<Promotion_Model>>();
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            utilityModel.CompanyID = this.CompanyID;

            List<Promotion_Model> list = new List<Promotion_Model>();
            list = Promotion_BLL.Instance.getPromotionForManager(utilityModel);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetPromotionDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetPromotionDetail(JObject obj)
        {
            ObjectResult<Promotion_Model> res = new ObjectResult<Promotion_Model>();
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            utilityModel.CompanyID = this.CompanyID;
            if (utilityModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            Promotion_Model model = Promotion_BLL.Instance.getPromotionDetailForManager(utilityModel);
            if (model == null)
            {
                model = new Promotion_Model();
                model.StartDate = DateTime.Now.ToLocalTime();
                model.EndDate = DateTime.Now.ToLocalTime();
            }
            List<BranchSelection_Model> branchList = new List<BranchSelection_Model>();
            branchList = Promotion_BLL.Instance.getBranchIDListByPromotionIDForManager(this.CompanyID, utilityModel.ID);
            model.BranchList = branchList;
            res.Code = "1";
            res.Message = "";
            res.Data = model;


            return toJson(res);
        }

        [HttpPost]
        [ActionName("AddPromotion")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage AddPromotion(JObject obj)
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

            Promotion_Model addModel = new Promotion_Model();
            addModel = JsonConvert.DeserializeObject<Promotion_Model>(strSafeJson);
            addModel.CompanyID = this.CompanyID;
            addModel.OperatorID = this.UserID;
            addModel.OperatorTime = DateTime.Now.ToLocalTime();

            int promoID = Promotion_BLL.Instance.addPromotionForManager(addModel, this.BranchID);

            if (promoID > 0)
            {
                res.Code = "1";
                res.Message = "操作成功!";
            }
            else
            {
                res.Code = "0";
                res.Message = "操作失败!";
            }
            res.Data = promoID;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("EditPromotion")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage EditPromotion(JObject obj)
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

            Promotion_Model addModel = new Promotion_Model();
            addModel = JsonConvert.DeserializeObject<Promotion_Model>(strSafeJson);

            if (addModel == null || addModel.ID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            addModel.CompanyID = this.CompanyID;
            addModel.OperatorID = this.UserID;
            addModel.OperatorTime = DateTime.Now.ToLocalTime();

            bool isSuccess = Promotion_BLL.Instance.updatePromotionForManager(addModel);

            if (isSuccess)
            {
                res.Message = "操作成功!";
            }
            else
            {
                res.Message = "操作失败!";
            }
            res.Code = "1";
            res.Data = isSuccess;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("DeletePromotion")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage DeletePromotion(JObject obj)
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

            Promotion_Model addModel = new Promotion_Model();
            addModel = JsonConvert.DeserializeObject<Promotion_Model>(strSafeJson);

            if (addModel == null || addModel.ID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            addModel.CompanyID = this.CompanyID;
            addModel.OperatorID = this.UserID;
            addModel.OperatorTime = DateTime.Now.ToLocalTime();

            bool isSuccess = Promotion_BLL.Instance.deletePromotionForManager(addModel);

            if (isSuccess)
            {
                res.Message = "操作成功!";
            }
            else
            {
                res.Message = "操作失败!";
            }
            res.Code = "1";
            res.Data = isSuccess;
            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetPromotionList_NEW")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getPromotionList_new(JObject obj)
        {
            ObjectResult<List<New_Promotion_Model>> res = new ObjectResult<List<New_Promotion_Model>>();
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            utilityModel.CompanyID = this.CompanyID;

            List<New_Promotion_Model> list = new List<New_Promotion_Model>();
            list = Promotion_BLL.Instance.getPromotionForManager_new(utilityModel);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetPromotionDetail_NEW")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetPromotionDetail_NEW(JObject obj)
        {
            ObjectResult<New_Promotion_Model> res = new ObjectResult<New_Promotion_Model>();
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            utilityModel.CompanyID = this.CompanyID;
            if (utilityModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            New_Promotion_Model model = Promotion_BLL.Instance.getPromotionDetailForManager_New(utilityModel);
            if (model == null)
            {
                model = new New_Promotion_Model();
                model.StartDate = DateTime.Now.ToLocalTime();
                model.EndDate = DateTime.Now.ToLocalTime();
            }

            List<PromotionRule_Model> ruleList = new List<PromotionRule_Model>();
            ruleList = Promotion_BLL.Instance.getPromotionRuleList();
            model.listPromotionRule = ruleList;

            List<BranchSelection_Model> branchList = new List<BranchSelection_Model>();
            branchList = Promotion_BLL.Instance.getBranchIDListByPromotionIDForManager_New(this.CompanyID, utilityModel.PromotionCode);
            model.BranchList = branchList;
            res.Code = "1";
            res.Message = "";
            res.Data = model;


            return toJson(res,"yyyy-MM-dd HH:mm:ss");
        }

        [HttpPost]
        [ActionName("AddPromotion_New")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage AddPromotion_New(JObject obj)
        {
            ObjectResult<string> res = new ObjectResult<string>();
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

            New_Promotion_Model addModel = new New_Promotion_Model();
            addModel = JsonConvert.DeserializeObject<New_Promotion_Model>(strSafeJson);
            addModel.CompanyID = this.CompanyID;
            addModel.CreatorID = this.UserID;
            addModel.CreateTime = DateTime.Now.ToLocalTime();

            string PromotionCode = Promotion_BLL.Instance.addPromotionForManager_New(addModel, this.BranchID);

            if (PromotionCode != "" && PromotionCode != null)
            {
                res.Code = "1";
                res.Message = "操作成功!";
            }
            else
            {
                res.Code = "0";
                res.Message = "操作失败!";
            }
            res.Data = PromotionCode;
            return toJson(res);
        }



        [HttpPost]
        [ActionName("EditPromotion_New")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage EditPromotion_New(JObject obj)
        {
            ObjectResult<string> res = new ObjectResult<string>();
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

            New_Promotion_Model addModel = new New_Promotion_Model();
            addModel = JsonConvert.DeserializeObject<New_Promotion_Model>(strSafeJson);

            if (addModel == null || addModel.PromotionCode == null || addModel.PromotionCode == "")
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            addModel.CompanyID = this.CompanyID;
            addModel.UpdaterID = this.UserID;
            addModel.UpdateTime = DateTime.Now.ToLocalTime();

            bool isSuccess = Promotion_BLL.Instance.updatePromotionForManager_New(addModel);

            if (isSuccess)
            {
                res.Code = "1";
                res.Data = addModel.PromotionCode;
                res.Message = "操作成功!";
            }
            else
            {
                res.Code = "0";
                res.Data = null;
                res.Message = "操作失败!";
            }
            return toJson(res);
        }


        [HttpPost]
        [ActionName("DeletePromotion_New")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage DeletePromotion_New(JObject obj)
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

            New_Promotion_Model addModel = new New_Promotion_Model();
            addModel = JsonConvert.DeserializeObject<New_Promotion_Model>(strSafeJson);

            if (addModel == null || addModel.PromotionCode == null || addModel.PromotionCode == "")
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            addModel.CompanyID = this.CompanyID;
            addModel.UpdaterID = this.UserID;
            addModel.UpdateTime = DateTime.Now.ToLocalTime();

            bool isSuccess = Promotion_BLL.Instance.deletePromotionForManager_New(addModel);

            if (isSuccess)
            {
                res.Message = "操作成功!";
            }
            else
            {
                res.Message = "操作失败!";
            }
            res.Code = "1";
            res.Data = isSuccess;
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
            int  result = Promotion_BLL.Instance.OperateBranch_New(model);
            if (result == 1)
            {
                res.Code = "1";
                res.Data = true;
                res.Message = "操作成功!";
            }
            else if(result == -1)
            {
                res.Message = "已经开始的服务不能编辑!";

            }

            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetPromotionProductSelect")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetPromotionProductSelect(JObject obj)
        {
            ObjectResult<List<PromotoinProduct_Model>> res = new ObjectResult<List<PromotoinProduct_Model>>();
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            if (utilityModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            List<PromotoinProduct_Model> list = Promotion_BLL.Instance.getPromotionProductSelect(this.CompanyID,utilityModel.PromotionCode,utilityModel.ProductType);
         

            res.Code = "1";
            res.Message = "";
            res.Data = list;


            return toJson(res);
        }




        [HttpPost]
        [ActionName("GetPromotionProductList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetPromotionProductList(JObject obj)
        {
            ObjectResult<List<PromotoinProduct_Model>> res = new ObjectResult<List<PromotoinProduct_Model>>();
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            if (utilityModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            List<PromotoinProduct_Model> list = Promotion_BLL.Instance.getPromotionProductList(utilityModel.PromotionCode, this.CompanyID);

            if (utilityModel.Flag == 1) {
                list = list.Where(s => s.ProductType == 0).ToList<PromotoinProduct_Model>();
            }
            else if (utilityModel.Flag == 2) {
                list = list.Where(s => s.ProductType == 1).ToList<PromotoinProduct_Model>();
            }


            res.Code = "1";
            res.Message = "";
            res.Data = list;


            return toJson(res);
        }


        [HttpPost]
        [ActionName("addPromotionProduct")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage addPromotionProduct(JObject obj)
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

            PromotoinProduct_Model utilityModel = new PromotoinProduct_Model();
            utilityModel = JsonConvert.DeserializeObject<PromotoinProduct_Model>(strSafeJson);
            if (utilityModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CreatorID = this.UserID;
            utilityModel.CreateTime = DateTime.Now.ToLocalTime();

            int result = Promotion_BLL.Instance.addPromotionProduct(utilityModel);


            if (result == 1)
            {
                res.Code = "1";
                res.Message = "添加成功";
                res.Data = true;
            }
            else if (result == -1) {
                res.Message = "该促销正在进行中不能更改";
            }

            return toJson(res);
        }


        [HttpPost]
        [ActionName("UpdatePromotionProduct")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage updatePromotionProduct(JObject obj)
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

            PromotoinProduct_Model utilityModel = new PromotoinProduct_Model();
            utilityModel = JsonConvert.DeserializeObject<PromotoinProduct_Model>(strSafeJson);
            if (utilityModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CreatorID = this.UserID;
            utilityModel.CreateTime = DateTime.Now.ToLocalTime();
            utilityModel.UpdaterID = this.UserID;
            utilityModel.UpdateTime = utilityModel.CreateTime;

            int result = Promotion_BLL.Instance.updatePromotionProduct(utilityModel);


            if (result == 1)
            {
                res.Code = "1";
                res.Message = "更新成功";
                res.Data = true;
            }
            else if(result == -1){
                res.Message = "该促销正在进行中不能更改";
            }

            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetPromotionProductDetailAdd")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getPromotionProductDetailAdd(JObject obj)
        {
            ObjectResult<PromotoinProduct_Model> res = new ObjectResult<PromotoinProduct_Model>();
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            if (utilityModel == null || utilityModel.PromotionCode == "" || utilityModel.ProductCode == 0 )
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            PromotoinProduct_Model model = Promotion_BLL.Instance.getPromotionProductDetailAdd(utilityModel.PromotionCode,utilityModel.ProductCode,utilityModel.ProductType, this.CompanyID);
            res.Code = "1";
            res.Message = "";
            res.Data = model;
            return toJson(res);
        }




        [HttpPost]
        [ActionName("GetPromotionProductDetailEdit")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getPromotionProductDetailEdit(JObject obj)
        {
            ObjectResult<PromotoinProduct_Model> res = new ObjectResult<PromotoinProduct_Model>();
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            if (utilityModel == null || utilityModel.PromotionCode == "" || utilityModel.ID == 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            PromotoinProduct_Model model = Promotion_BLL.Instance.getPromotionProductDetailEdit(utilityModel.PromotionCode, utilityModel.ID, utilityModel.ProductType, this.CompanyID);
            res.Code = "1";
            res.Message = "";
            res.Data = model;
            return toJson(res);
        }




        [HttpPost]
        [ActionName("GetPromotionSaleDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetPromotionSaleDetail(JObject obj)
        {
            ObjectResult<List<PromotionSale_Model>> res = new ObjectResult<List<PromotionSale_Model>>();
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            if (utilityModel == null || utilityModel.PromotionCode == "")
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            List<PromotionSale_Model> list = Promotion_BLL.Instance.getPromotionSaleDetail(this.CompanyID, utilityModel.PromotionCode);
            res.Code = "1";
            res.Message = "";
            res.Data = list;
            return toJson(res);
        }


        [HttpPost]
        [ActionName("DeletePromotionProduct")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage DeletePromotionProduct(JObject obj)
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

            PromotoinProduct_Model utilityModel = new PromotoinProduct_Model();
            utilityModel = JsonConvert.DeserializeObject<PromotoinProduct_Model>(strSafeJson);
            if (utilityModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CreatorID = this.UserID;
            utilityModel.CreateTime = DateTime.Now.ToLocalTime();
            utilityModel.UpdaterID = this.UserID;
            utilityModel.UpdateTime = utilityModel.CreateTime;

            int result = Promotion_BLL.Instance.deletePromotionProduct(utilityModel);


            if (result == 1)
            {
                res.Code = "1";
                res.Message = "删除成功";
                res.Data = true;
            }
            else if (result == -1)
            {
                res.Message = "该促销正在进行中不能更改";
            }

            return toJson(res);
        }

    }
}
