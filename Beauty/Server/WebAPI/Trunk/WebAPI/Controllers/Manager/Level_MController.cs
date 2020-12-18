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
using WebAPI.Controllers.API;

namespace WebAPI.Controllers.Manager
{
    public class Level_MController : BaseController
    {
        [HttpPost]
        [ActionName("GetLevelList")]
        [HTTPBasicAuthorizeAttribute]
        public HttpResponseMessage GetLevelList(JObject obj)
        {
            ObjectResult<List<GetLevelList_Model>> res = new ObjectResult<List<GetLevelList_Model>>();
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

            if (operationModel.Flag < 0 || operationModel.Flag > 1)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.CompanyID = this.CompanyID;
            List<GetLevelList_Model> list = new List<GetLevelList_Model>();
            list = Level_BLL.Instance.getLevelList(operationModel.CompanyID, operationModel.Flag);

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetLevelDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetLevelDetail(JObject obj)
        {
            ObjectResult<GetLevelDetail_Model> res = new ObjectResult<GetLevelDetail_Model>();
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

            GetLevelDetail_Model model = new GetLevelDetail_Model();
            model = Level_BLL.Instance.getLevelDetailForManager(utilityModel.CompanyID, utilityModel.ID);
            if (model != null)
            {
                List<GetDiscountInfo_Model> list = Level_BLL.Instance.getDiscountListByLevelID(utilityModel.CompanyID, utilityModel.ID);
                model.DiscountlList = list;
            }
            res.Code = "1";
            res.Message = "";
            res.Data = model;


            return toJson(res);
        }

        [HttpPost]
        [ActionName("AddLevel")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage AddLevel(JObject obj)
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

            AddLevel_Model operationModel = new AddLevel_Model();
            operationModel = JsonConvert.DeserializeObject<AddLevel_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;
            operationModel.CreatorID = this.UserID;
            operationModel.CreateTime = DateTime.Now.ToLocalTime();

            //bool isExist = Level_BLL.Instance.isExistDiscountName(operationModel.CompanyID, operationModel.DiscountName);
            //if (isExist)
            //{
            //    res.Code = "1";
            //    res.Message = "";
            //    res.Data = -2;
            //    return toJson(res);
            //}

            bool isCuccess = Level_BLL.Instance.addLevel(operationModel);
            if (isCuccess)
            {
                res.Code = "1";
                res.Message = "";
                res.Data = 1;
            }
            else
            {
                res.Code = "1";
                res.Message = "";
                res.Data = 0;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("EditLevel")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage EditLevel(JObject obj)
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

            AddLevel_Model operationModel = new AddLevel_Model();
            operationModel = JsonConvert.DeserializeObject<AddLevel_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;
            operationModel.CreatorID = this.UserID;
            operationModel.CreateTime = DateTime.Now.ToLocalTime();
            operationModel.UpdaterID = this.UserID;
            operationModel.UpdateTime = DateTime.Now.ToLocalTime();

            //if (!string.IsNullOrEmpty(operationModel.DiscountName) || operationModel.DiscountName != "")
            //{
            //    bool isExist = Level_BLL.Instance.isExistDiscountName(operationModel.CompanyID, operationModel.DiscountName);
            //    if (isExist)
            //    {
            //        res.Code = "1";
            //        res.Message = "";
            //        res.Data = -2;
            //        return toJson(res);
            //    }
            //}

            bool isCuccess = Level_BLL.Instance.editDiscount(operationModel);

            res.Code = "1";
            res.Message = "";
            res.Data = 1;

            return toJson(res);
        }

        [HttpPost]
        [ActionName("DeleteLevel")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage DeleteLevel(JObject obj)
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

            AddLevel_Model operationModel = new AddLevel_Model();
            operationModel = JsonConvert.DeserializeObject<AddLevel_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;
            operationModel.CreatorID = this.UserID;
            operationModel.UpdaterID = this.UserID;
            operationModel.UpdateTime = DateTime.Now.ToLocalTime();

            bool isCuccess = Level_BLL.Instance.deleteLevel(operationModel);

            res.Code = "1";
            res.Message = "";
            res.Data = isCuccess;

            return toJson(res);
        }

        [HttpPost]
        [ActionName("ChangDefaultLevel")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage ChangDefaultLevel(JObject obj)
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

            UtilityOperation_Model operationModel = new UtilityOperation_Model();
            operationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;
            operationModel.CreatorID = this.UserID;
            operationModel.UpdaterID = this.UserID;
            operationModel.Time = DateTime.Now.ToLocalTime();

            bool isCuccess = Level_BLL.Instance.updateDefaultLevelID(operationModel);

            res.Code = "1";
            res.Message = "";
            res.Data = isCuccess;

            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetDiscountList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetDiscountList(JObject obj)
        {
            PageResult<GetDiscountListForManager_Model> res = new PageResult<GetDiscountListForManager_Model>();
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

            if (utilityModel.PageIndex <= 0)
            {
                utilityModel.PageIndex = 1;
            }

            if (utilityModel.PageSize <= 0)
            {
                utilityModel.PageSize = 999999;
            }

            int recordCount = 0;
            List<GetDiscountListForManager_Model> list = new List<GetDiscountListForManager_Model>();
            list = Level_BLL.Instance.getDiscountListForManager(utilityModel.CompanyID,utilityModel.Flag, utilityModel.PageIndex, utilityModel.PageSize, out  recordCount);

            res.Code = "1";
            res.Message = "";
            res.Data = list;
            res.RecordCount = recordCount;
            res.PageIndex = utilityModel.PageIndex;
            res.PageSize = utilityModel.PageSize;

            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetDiscountDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetDiscountDetail(JObject obj)
        {
            ObjectResult<GetDiscountDetail_Model> res = new ObjectResult<GetDiscountDetail_Model>();
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

            GetDiscountDetail_Model model = new GetDiscountDetail_Model();
            model = Level_BLL.Instance.getDiscountDetailForManager(utilityModel.CompanyID, utilityModel.ID);
            if (model != null)
            {
                List<GetLevelInfo_Model> list = Level_BLL.Instance.getLevelListByDiscountID(utilityModel.CompanyID, utilityModel.ID);
                model.LevelList = list;
            }
            res.Code = "1";
            res.Message = "";
            res.Data = model;


            return toJson(res);
        }

        [HttpPost]
        [ActionName("IsExistDiscountName")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage IsExistDiscountName(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
            res.Data = true;

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

            GetDiscountDetail_Model model = new GetDiscountDetail_Model();
            bool isExist = Level_BLL.Instance.isExistDiscountName(utilityModel.CompanyID, utilityModel.DiscountName);

            res.Code = "1";
            res.Message = "";
            res.Data = isExist;


            return toJson(res);
        }

        [HttpPost]
        [ActionName("DeleteDiscount")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage DeleteDiscount(JObject obj)
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

            Discount_Model operationModel = new Discount_Model();
            operationModel = JsonConvert.DeserializeObject<Discount_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;
            operationModel.CreatorID = this.UserID;
            operationModel.UpdaterID = this.UserID;
            operationModel.UpdateTime = DateTime.Now.ToLocalTime();

            bool isCuccess = Level_BLL.Instance.deleteDiscount(operationModel);

            res.Code = "1";
            res.Message = "";
            res.Data = isCuccess;

            return toJson(res);
        }

        [HttpPost]
        [ActionName("AddDiscount")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage AddDiscount(JObject obj)
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

            AddDiscount_Model operationModel = new AddDiscount_Model();
            operationModel = JsonConvert.DeserializeObject<AddDiscount_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;
            operationModel.CreatorID = this.UserID;
            operationModel.CreateTime = DateTime.Now.ToLocalTime();

            bool isExist = Level_BLL.Instance.isExistDiscountName(operationModel.CompanyID, operationModel.DiscountName);
            if (isExist)
            {
                res.Code = "1";
                res.Message = "";
                res.Data = -2;
                return toJson(res);
            }

            bool isCuccess = Level_BLL.Instance.addDiscount(operationModel);
            if (isCuccess)
            {
                res.Code = "1";
                res.Message = "";
                res.Data = 1;
            }
            else
            {
                res.Code = "1";
                res.Message = "";
                res.Data = 0;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("EditDiscount")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage EditDiscount(JObject obj)
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

            AddDiscount_Model operationModel = new AddDiscount_Model();
            operationModel = JsonConvert.DeserializeObject<AddDiscount_Model>(strSafeJson);
            operationModel.CompanyID = this.CompanyID;
            operationModel.CreatorID = this.UserID;
            operationModel.CreateTime = DateTime.Now.ToLocalTime();
            operationModel.UpdaterID = this.UserID;
            operationModel.UpdateTime = DateTime.Now.ToLocalTime();

            if (!string.IsNullOrEmpty(operationModel.DiscountName) || operationModel.DiscountName != "")
            {
                bool isExist = Level_BLL.Instance.isExistDiscountName(operationModel.CompanyID, operationModel.DiscountName);
                if (isExist)
                {
                    res.Code = "1";
                    res.Message = "";
                    res.Data = -2;
                    return toJson(res);
                }
            }

            bool isCuccess = Level_BLL.Instance.editDiscount(operationModel);

            res.Code = "1";
            res.Message = "";
            res.Data = 1;

            return toJson(res);
        }


        [HttpPost]
        [ActionName("getDiscountIDByName")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getDiscountIDByName(JObject obj)
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            utilityModel.CompanyID = this.CompanyID;

            int levelID = Level_BLL.Instance.getDiscountIDByName(utilityModel.CompanyID, utilityModel.DiscountName);

            if (levelID > 0)
            {
                res.Code = "1";
                res.Message = "";
                res.Data = levelID;
            }

            return toJson(res);
        }



        [HttpPost]
        [ActionName("isExistDiscountID")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage isExistDiscountID(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
            res.Data = true;

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

            GetDiscountDetail_Model model = new GetDiscountDetail_Model();
            bool isExist = Level_BLL.Instance.isExistDiscountID(utilityModel.CompanyID, utilityModel.DiscountID);

            res.Code = "1";
            res.Message = "";
            res.Data = isExist;


            return toJson(res);
        }


    }
}
