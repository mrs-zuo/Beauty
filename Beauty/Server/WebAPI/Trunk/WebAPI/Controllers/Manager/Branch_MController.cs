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
    public class Branch_MController : BaseController
    {
        [HttpPost]
        [ActionName("GetBranchListForWeb")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetBranchListForWeb()
        {
            ObjectResult<List<Branch_Model>> res = new ObjectResult<List<Branch_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;


            List<Branch_Model> list = new List<Branch_Model>();
            list = Branch_BLL.Instance.getBranchListForWeb(this.CompanyID);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }

        [HttpPost]
        [ActionName("DeleteBranch")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage DeleteBranch(JObject obj)
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            bool available = false;
            if (utilityModel.Available == 1) {
                available = true;
            }

            int issuccess = Branch_BLL.Instance.deleteBranch(utilityModel.ID, this.UserID, available,this.CompanyID);

            if (issuccess == 1)
            {
                res.Code = "1";
                res.Message = "操作成功";
                res.Data = true;
            }
            else if (issuccess == -1)
            {
                res.Message = "门店数量已经到达允许最大数";
            }

            return toJson(res);
        }



        [HttpPost]
        [ActionName("GetBranchDetail")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetBranchDetail(JObject obj)
        {
            ObjectResult<Branch_Model> res = new ObjectResult<Branch_Model>();
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

            Branch_Model model = Branch_BLL.Instance.getBranchDetailForWeb(utilityModel.BranchID);

            res.Code = "1";
            res.Message = "";
            res.Data = model;

            return toJson(res);
        }

        [HttpPost]
        [ActionName("AddBranch")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage AddBranch(JObject obj)
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

            Branch_Model model = Newtonsoft.Json.JsonConvert.DeserializeObject<Branch_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.CreatorID = this.UserID;
            model.CreateTime = DateTime.Now.ToLocalTime();

            bool isCan = Branch_BLL.Instance.isCanAddBranch(this.CompanyID);
            if (!isCan)
            {
                res.Code = "0";
                res.Message = "门店数量已经达到最大允许门店数量!";
                res.Data = false;
                return toJson(res);
            }

            int branchId = Branch_BLL.Instance.addBranch(model);


            if (branchId > 0)
            {
                if (model.BigImageUrl != null && model.BigImageUrl.Count > 0)
                {
                    BusinessImageOperation_Model mBusiness = new BusinessImageOperation_Model();
                    mBusiness.CompanyID = model.CompanyID;
                    mBusiness.BranchID = branchId;
                    mBusiness.UserID = this.UserID;
                    mBusiness.OperationTime = model.CreateTime;
                    mBusiness.AddImage = model.BigImageUrl;
                    mBusiness.DeleteImage = null;
                    bool result = Image_BLL.Instance.updateBusinessImage(mBusiness);
                }
                res.Code = "1";
                res.Message = "门店添加成功!";
                res.Data = true;
            }
            else
            {
                res.Code = "0";
                res.Message = "门店添加失败!";
                res.Data = false;

            }

            return toJson(res);
        }


        [HttpPost]
        [ActionName("UpdateBranch")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage UpdateBranch(JObject obj)
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

            Branch_Model model = Newtonsoft.Json.JsonConvert.DeserializeObject<Branch_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.UpdaterID = this.UserID;
            model.UpdateTime = DateTime.Now.ToLocalTime();

            bool result = Branch_BLL.Instance.updateBranch(model);


            if (result)
            {
                if ((model.BigImageUrl != null && model.BigImageUrl.Count > 0) || (model.DeleteImageUrl != null && model.DeleteImageUrl.Count > 0))
                {
                    BusinessImageOperation_Model mBusiness = new BusinessImageOperation_Model();
                    mBusiness.CompanyID = model.CompanyID;
                    mBusiness.BranchID = model.ID;
                    mBusiness.UserID = this.UserID;
                    mBusiness.OperationTime = model.UpdateTime;
                    mBusiness.AddImage = model.BigImageUrl;
                    mBusiness.DeleteImage = model.DeleteImageUrl;
                    result = Image_BLL.Instance.updateBusinessImage(mBusiness);
                }
                res.Code = "1";
                res.Message = "门店信息更新成功!";
                res.Data = true;
            }
            else
            {
                res.Code = "0";
                res.Message = "门店信息更新失败!";
                res.Data = false;

            }

            return toJson(res);
        }


        [HttpPost]
        [ActionName("IsCanAddBranch")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage IsCanAddBranch()
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "";
            res.Data = false;



            bool result = Branch_BLL.Instance.isCanAddBranch(this.CompanyID);


            if (result)
            {

                res.Code = "1";
                res.Data = true;
            }
            else
            {
                res.Code = "1";
                res.Message = "门店数量已经达到最大允许门店数量!";
                res.Data = false;

            }

            return toJson(res);
        }




        [HttpPost]
        [ActionName("EditMarketRelationShipForBranch")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage EditMarketRelationShipForBranch(JObject obj)
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


            EditMarketRelationShipForBranchOperation_Model model = new EditMarketRelationShipForBranchOperation_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<EditMarketRelationShipForBranchOperation_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            model.OperatorID = this.UserID;
            model.OperatorTime = DateTime.Now.ToLocalTime();

            bool result = false;
            switch (model.MarketType)
            {
                case 1:
                    result = Branch_BLL.Instance.OperateCommodityBranch(model);
                    break;
                case 2:
                    result = Branch_BLL.Instance.OperateServiceBranch(model);
                    break;

            }

            if (result)
            {
                res.Data = true;
                res.Code = "1";
                res.Message = "更新成功！";
            }

            return toJson(res);
        }



        [HttpPost]
        [ActionName("GetMarketRelationShipForBranch")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetMarketRelationShipForBranch(JObject obj)
        {
            ObjectResult<List<GetBranchMarketRelationShip_Model>> res = new ObjectResult<List<GetBranchMarketRelationShip_Model>>();
            res.Code = "0";
            res.Data = null;
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


            EditMarketRelationShipForBranchOperation_Model model = new EditMarketRelationShipForBranchOperation_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<EditMarketRelationShipForBranchOperation_Model>(strSafeJson);


            List<GetBranchMarketRelationShip_Model> list = new List<GetBranchMarketRelationShip_Model>();

            switch (model.MarketType) {
                case 1:
                    list = Branch_BLL.Instance.getCommodityList(model.BranchID, this.CompanyID);
                    break;
                case 2:
                    list = Branch_BLL.Instance.getServiceList(model.BranchID, this.CompanyID);
                    break;

            }

            res.Data = list;
            res.Code = "1";
            return toJson(res);
        }



        [HttpPost]
        [ActionName("GetStockCalcTypeList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetStockCalcTypeList()
        {
            ObjectResult<List<StockCalcType_Model>> res = new ObjectResult<List<StockCalcType_Model>>();
            res.Code = "0";
            res.Data = null;
            res.Message = "更新失败！";

            List<StockCalcType_Model> list = Branch_BLL.Instance.getStockCalcTypeList();

            res.Data = list;
            res.Code = "1";
            return toJson(res);
        }



        [HttpPost]
        [ActionName("GetPriceRange")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetPriceRange(JObject obj)
        {
            ObjectResult<PriceRange_Model> res = new ObjectResult<PriceRange_Model>();
            res.Code = "0";
            res.Data = null;
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


            UtilityOperation_Model model = new UtilityOperation_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);


            PriceRange_Model resModel = new PriceRange_Model();

            resModel = Branch_BLL.Instance.getPriceRange(model.BranchID, this.CompanyID);

            res.Data = resModel;
            res.Code = "1";
            return toJson(res);
        }


        [HttpPost]
        [ActionName("EditPriceRange")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage EditPriceRange(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "操作失败！";


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


            PriceRange_Model model = new PriceRange_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<PriceRange_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;
            
            model.CreatorID = this.UserID;
            model.UpdaterID = this.UserID;
            DateTime dt = DateTime.Now.ToLocalTime();
            model.CreateTime = dt;
            model.UpdateTime = dt;


            bool result = Branch_BLL.Instance.EditPriceRange(model);

            res.Data = result;
            res.Code = "1";
            if (result)
            {
                res.Message = "操作成功！";
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("EditAccountSort")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage EditAccountSort(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Data = false;
            res.Message = "操作失败！";


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


            Branch_Model model = new Branch_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<Branch_Model>(strSafeJson);
            model.CompanyID = this.CompanyID;

            model.CreatorID = this.UserID;
            model.UpdaterID = this.UserID;
            DateTime dt = DateTime.Now.ToLocalTime();
            model.CreateTime = dt;
            model.UpdateTime = dt;


            bool result = Account_BLL.Instance.EditAccountSort(model);

            res.Data = result;
            res.Code = "1";
            if (result)
            {
                res.Message = "操作成功！";
            }
            return toJson(res);
        }




        [HttpPost]
        [ActionName("GetAccountListForBranchEdit")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetAccountListForBranchEdit(JObject obj)
        {
            ObjectResult<List<Account_Model>> res = new ObjectResult<List<Account_Model>>();
            res.Code = "0";
            res.Data = null;
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


            UtilityOperation_Model model = new UtilityOperation_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);


           List<Account_Model> list = new List<Account_Model>();

           list = Branch_BLL.Instance.getAccountListForBranchEdit(model.BranchID, this.CompanyID);

            res.Data = list;
            res.Code = "1";
            return toJson(res);
        }






        [HttpPost]
        [ActionName("GetAccountListForDefaultConsultant")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetAccountListForDefaultConsultant(JObject obj)
        {
            ObjectResult<List<Account_Model>> res = new ObjectResult<List<Account_Model>>();
            res.Code = "0";
            res.Data = null;
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


            UtilityOperation_Model model = new UtilityOperation_Model();
            model = Newtonsoft.Json.JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);


            List<Account_Model> list = new List<Account_Model>();

            list = Branch_BLL.Instance.getAccountListForDefaultConsultant(model.BranchID, this.CompanyID);

            res.Data = list;
            res.Code = "1";
            return toJson(res);
        }

        [HttpPost]
        [ActionName("getBranchAvailableList")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage getBranchAvailableList()
        {
            ObjectResult<List<Branch_Model>> res = new ObjectResult<List<Branch_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;


            List<Branch_Model> list = new List<Branch_Model>();
            list = Branch_BLL.Instance.getBranchAvailableList(this.CompanyID);

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res);
        }

    }
}
