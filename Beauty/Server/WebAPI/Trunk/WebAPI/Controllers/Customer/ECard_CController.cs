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
using WebAPI.BLL.Customer;

namespace WebAPI.Controllers.Customer
{
    public class ECard_CController : Base_CController
    {
        [HttpPost]
        [ActionName("GetCustomerCardList")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"CustomerID":123}
        public HttpResponseMessage GetCustomerCardList(JObject obj)
        {
            ObjectResult<List<GetECardList_Model>> res = new ObjectResult<List<GetECardList_Model>>();
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

            if (utilityModel == null || utilityModel.CustomerID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;

            List<GetECardList_Model> list = new List<GetECardList_Model>();
            List<GetECardList_Model> Cardlist = ECard_CBLL.Instance.GetCustomerCardList(utilityModel.CompanyID, utilityModel.BranchID, utilityModel.CustomerID);
            List<GetECardList_Model> PointCouponlist = ECard_CBLL.Instance.GetCustomerPointCouponList(utilityModel.CompanyID, utilityModel.BranchID, utilityModel.CustomerID);
            list.AddRange(Cardlist);
            list.AddRange(PointCouponlist);

            res.Code = "1";
            res.Message = "success";
            res.Data = list;

            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetCardInfo")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"CustomerID":123,"UserCardNo":"333"}
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

            if (utilityModel == null || utilityModel.CustomerID <= 0 || string.IsNullOrWhiteSpace(utilityModel.UserCardNo))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;

            GetCardInfo_Model model = new GetCardInfo_Model();
            model = ECard_CBLL.Instance.GetCardInfo(utilityModel.CompanyID, utilityModel.CustomerID, utilityModel.UserCardNo);

            if (model != null)
            {
                model.DiscountList = new List<CardDiscountList_Model>();
                model.DiscountList = ECard_CBLL.Instance.GetCardDisCountListByCardID(utilityModel.CompanyID, model.CardID);
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
        [ActionName("GetBranchCardList")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"isOnlyMoneyCard":true}
        public HttpResponseMessage GetBranchCardList(JObject obj)
        {
            ObjectResult<List<GetCompanyCardList_Model>> res = new ObjectResult<List<GetCompanyCardList_Model>>();
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
            utilityModel.CompanyID = this.CompanyID;
            //utilityModel.BranchID = this.BranchID;

            List<GetCompanyCardList_Model> list = new List<GetCompanyCardList_Model>();
            list = ECard_CBLL.Instance.GetBranchCardList(utilityModel.CompanyID, utilityModel.BranchID, utilityModel.isShowAll, utilityModel.isOnlyMoneyCard);

            if (list != null && list.Count > 0)
            {
                foreach (GetCompanyCardList_Model item in list)
                {
                    if (item.CardTypeID == 1)
                    {
                        item.DiscountList = new List<CardDiscountList_Model>();
                        item.DiscountList = ECard_CBLL.Instance.GetCardDisCountListByCardID(utilityModel.CompanyID, item.CardID);
                    }
                }
            }

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res, "yyyy-MM-dd");
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

            if (utilityModel == null || utilityModel.CustomerID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;

            List<GetCustomerBalanceList_Model> list = new List<GetCustomerBalanceList_Model>();
            list = ECard_CBLL.Instance.GetBalanceListByCustomerID(utilityModel.CompanyID, utilityModel.BranchID, utilityModel.CustomerID);

            res.Code = "1";
            res.Message = "success";
            res.Data = list;

            return toJson(res, "yyyy-MM-dd HH:mm");
        }

        [HttpPost]
        [ActionName("GetCardBalanceByUserCardNo")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"CustomerID":123,"UserCardNo":"12313","CardType":1}
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

            if (utilityModel == null || utilityModel.CustomerID <= 0 || string.IsNullOrWhiteSpace(utilityModel.UserCardNo) || utilityModel.CardType <= 0 || utilityModel.CardType > 3)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;

            List<GetCardBalanceList_Model> list = new List<GetCardBalanceList_Model>();
            list = ECard_CBLL.Instance.GetCardBalanceByUserCardNo(utilityModel.CompanyID, utilityModel.BranchID, utilityModel.CustomerID, utilityModel.UserCardNo, utilityModel.CardType);

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
            model = ECard_CBLL.Instance.GetBalanceDetail(utilityModel.CompanyID, utilityModel.ID, utilityModel.ChangeType);

            if (model != null)
            {
                DateTime dt = Convert.ToDateTime(model.CreateTime);
                model.BalanceNumber = dt.Month.ToString().PadLeft(2, '0') + dt.Day.ToString().PadLeft(2, '0') + model.BalanceID.ToString().PadLeft(6, '0') + dt.Year.ToString().Substring(dt.Year.ToString().Length - 2, 2);
                List<Profit_Model> list = new List<Profit_Model>();
                if (model.PaymentID > 0)
                {
                    list = Payment_CBLL.Instance.getProfitListByMasterID(model.PaymentID, 2);
                }
                else
                {
                    list = Payment_CBLL.Instance.getProfitListByMasterID(utilityModel.ID, 1);
                }
                model.ProfitList = list;

                if (model.PaymentID > 0)
                {
                    List<BalanceOrderList_Model> orderlist = new List<BalanceOrderList_Model>();
                    orderlist = ECard_CBLL.Instance.GetBalanceOrderListByPaymentID(utilityModel.CompanyID, model.PaymentID);

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
        [ActionName("GetCardDiscountList")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"CustomerID":123,"ProductCode":1231321321,"ProductType":0}
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

            if (utilityModel == null || utilityModel.CustomerID <= 0 || utilityModel.ProductCode <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;

            List<CustomerEcardDiscount_Model> list = new List<CustomerEcardDiscount_Model>();
            list = ECard_CBLL.Instance.GetCardDiscountList(utilityModel.CompanyID, utilityModel.BranchID, utilityModel.CustomerID, utilityModel.ProductCode, utilityModel.ProductType);

            res.Code = "1";
            res.Message = "success";
            res.Data = list;

            return toJson(res);
        }
    }
}
