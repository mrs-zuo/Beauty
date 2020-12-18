using ClientApi.Authorize;
using ClientAPI.BLL;
using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.View_Model;
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
    public class ECardController : BaseController
    {
        [HttpPost]
        [ActionName("GetCustomerCardList")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        public HttpResponseMessage GetCustomerCardList(JObject obj)
        {
            ObjectResult<List<GetECardList_Model>> res = new ObjectResult<List<GetECardList_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();

            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CustomerID = this.UserID;

            List<GetECardList_Model> list = new List<GetECardList_Model>();
            List<GetECardList_Model> Cardlist = ECard_BLL.Instance.GetCustomerCardList(utilityModel.CompanyID, utilityModel.BranchID, utilityModel.CustomerID);
            List<GetECardList_Model> PointCouponlist = ECard_BLL.Instance.GetCustomerPointCouponList(utilityModel.CompanyID, utilityModel.BranchID, utilityModel.CustomerID);
            list.AddRange(Cardlist);
            list.AddRange(PointCouponlist);

            if (list != null && list.Count > 0)
            {
                list = list.OrderBy(c => c.CardTypeID).ToList();
            }

            res.Code = "1";
            res.Message = "success";
            res.Data = list;

            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetCardInfo")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"UserCardNo":"333"}
        public HttpResponseMessage GetCardInfo(JObject obj)
        {
            ObjectResult<GetCardInfo_Model> res = new ObjectResult<GetCardInfo_Model>();
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

            if (utilityModel == null || string.IsNullOrWhiteSpace(utilityModel.UserCardNo))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CustomerID = this.UserID;

            GetCardInfo_Model model = new GetCardInfo_Model();
            model = ECard_BLL.Instance.GetCardInfo(utilityModel.CompanyID, utilityModel.CustomerID, utilityModel.UserCardNo);

            if (model != null)
            {
                model.DiscountList = new List<CardDiscountList_Model>();
                model.DiscountList = ECard_BLL.Instance.GetCardDisCountListByCardID(utilityModel.CompanyID, model.CardID);
                res.Code = "1";
                res.Message = "success";
                model.Balance = Math.Round(model.Balance, 2);
                res.Data = model;
            }
            else
            {
                res.Code = "0";
                res.Message = "";
                res.Data = null;
            }
            return toJson(res, "yyyy-MM-dd");
        }

        [HttpPost]
        [ActionName("GetCardBalanceByUserCardNo")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"UserCardNo":"12313","CardType":1}
        public HttpResponseMessage GetCardBalanceByUserCardNo(JObject obj)
        {
            ObjectResult<List<GetCardBalanceList_Model>> res = new ObjectResult<List<GetCardBalanceList_Model>>();
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

            if (utilityModel == null || string.IsNullOrWhiteSpace(utilityModel.UserCardNo) || utilityModel.CardType <= 0 || utilityModel.CardType > 3)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CustomerID = this.UserID;

            List<GetCardBalanceList_Model> list = new List<GetCardBalanceList_Model>();
            list = ECard_BLL.Instance.GetCardBalanceByUserCardNo(utilityModel.CompanyID, utilityModel.BranchID, utilityModel.CustomerID, utilityModel.UserCardNo, utilityModel.CardType);

            res.Code = "1";
            res.Message = "success";
            res.Data = list;

            return toJson(res, "yyyy-MM-dd HH:mm");
        }

        [HttpPost]
        [ActionName("GetBalanceListByCustomerID")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"CustomerID":123}
        public HttpResponseMessage GetBalanceListByCustomerID(JObject obj)
        {
            ObjectResult<List<GetCustomerBalanceList_Model>> res = new ObjectResult<List<GetCustomerBalanceList_Model>>();
            res.Code = "0";
            res.Message = "";
            res.Data = null;

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();

            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CustomerID = this.UserID;

            List<GetCustomerBalanceList_Model> list = new List<GetCustomerBalanceList_Model>();
            list = ECard_BLL.Instance.GetBalanceListByCustomerID(utilityModel.CompanyID, utilityModel.BranchID, utilityModel.CustomerID);

            res.Code = "1";
            res.Message = "success";
            res.Data = list;

            return toJson(res, "yyyy-MM-dd HH:mm");
        }

        [HttpPost]
        [ActionName("GetBalanceDetailInfo")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"ID":123,"CardType":12313,"ChangeType":1}
        public HttpResponseMessage GetBalanceDetailInfo(JObject obj)
        {
            ObjectResult<GetBalanceDetail_Model> res = new ObjectResult<GetBalanceDetail_Model>();
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

            if (utilityModel == null || utilityModel.ID <= 0 || utilityModel.ChangeType <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            GetBalanceDetail_Model model = new GetBalanceDetail_Model();
            model = ECard_BLL.Instance.GetBalanceDetail(utilityModel.CompanyID, utilityModel.ID, utilityModel.ChangeType);

            if (model != null)
            {
                DateTime dt = Convert.ToDateTime(model.CreateTime);
                model.BalanceNumber = dt.Month.ToString().PadLeft(2, '0') + dt.Day.ToString().PadLeft(2, '0') + model.BalanceID.ToString().PadLeft(6, '0') + dt.Year.ToString().Substring(dt.Year.ToString().Length - 2, 2);

                if (model.PaymentID > 0)
                {
                    List<BalanceOrderList_Model> orderlist = new List<BalanceOrderList_Model>();
                    orderlist = ECard_BLL.Instance.GetBalanceOrderListByPaymentID(utilityModel.CompanyID, model.PaymentID);

                    if (orderlist != null && orderlist.Count > 0)
                    {
                        foreach (BalanceOrderList_Model item in orderlist)
                        {
                            item.OrderNumber = dt.Month.ToString().PadLeft(2, '0') + dt.Day.ToString().PadLeft(2, '0') + item.OrderID.ToString().PadLeft(6, '0') + dt.Year.ToString().Substring(dt.Year.ToString().Length - 2, 2);
                        }
                        model.OrderList = new List<BalanceOrderList_Model>();
                        model.OrderList = orderlist;
                    }
                }

                res.Code = "1";
                res.Message = "success";
                res.Data = model;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("UpdateCustomerDefaultCard")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"UserCardNo":"333"}
        public HttpResponseMessage UpdateCustomerDefaultCard(JObject obj)
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

            if (utilityModel == null || string.IsNullOrWhiteSpace(utilityModel.UserCardNo))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.AccountID = this.UserID;
            utilityModel.CustomerID = this.UserID;


            int result = ECard_BLL.Instance.UpdateCustomerDefaultCard(utilityModel.CompanyID, utilityModel.AccountID, utilityModel.CustomerID, utilityModel.UserCardNo);

            switch (result)
            {
                case 0:
                    res.Code = "0";
                    res.Message = "操作失败!";
                    break;
                case 1:
                    res.Code = "1";
                    res.Message = "操作成功!";
                    res.Data = true;
                    break;
                case 2:
                    res.Code = "0";
                    res.Message = "此卡不能设置成默认卡!";
                    break;
                default:
                    res.Code = "0";
                    res.Message = "操作失败!";
                    break;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetCardDiscountList")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"ProductCode":1231321321,"ProductType":0,"BranchID":99}
        public HttpResponseMessage GetCardDiscountList(JObject obj)
        {
            ObjectResult<List<CustomerEcardDiscount_Model>> res = new ObjectResult<List<CustomerEcardDiscount_Model>>();
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

            if (utilityModel == null || utilityModel.ProductCode <= 0 || utilityModel.BranchID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CustomerID = this.UserID;

            List<CustomerEcardDiscount_Model> list = new List<CustomerEcardDiscount_Model>();
            list = ECard_BLL.Instance.GetCardDiscountList(utilityModel.CompanyID, utilityModel.BranchID, utilityModel.CustomerID, utilityModel.ProductCode, utilityModel.ProductType);

            res.Code = "1";
            res.Message = "success";
            res.Data = list;

            return toJson(res);
        }




        [HttpPost]
        [ActionName("GetCustomerBenefitList")]
        [HTTPBasicAuthorize]
        //{"Type":1}
        public HttpResponseMessage GetCustomerBenefitList(JObject obj)
        {
            ObjectResult<List<CustomerBenefitList_Model>> res = new ObjectResult<List<CustomerBenefitList_Model>>();
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

            if (operationModel.Type <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            List<CustomerBenefitList_Model> list = ECard_BLL.Instance.getCustomerBenefitList(this.CompanyID, this.UserID, this.BranchID, operationModel.Type);
            res.Code = "1";
            res.Data = list;
            res.Message = "";
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetCustomerBenefitDetail")]
        [HTTPBasicAuthorize]
        //{"BenefitID":1}
        public HttpResponseMessage GetCustomerBenefitDetail(JObject obj)
        {
            ObjectResult<CustomerBenefitDetail_Model> res = new ObjectResult<CustomerBenefitDetail_Model>();
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

            if (string.IsNullOrEmpty(operationModel.BenefitID))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            CustomerBenefitDetail_Model model = ECard_BLL.Instance.getCustomerBenefitDetail(this.CompanyID, this.UserID, operationModel.BenefitID);
            res.Code = "1";
            res.Data = model;
            res.Message = "";
            return toJson(res);
        }

    }
}
