using HS.Framework.Common;
using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
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

namespace WebAPI.Controllers.API
{
    public class ECardController : BaseController
    {
        [HttpPost]
        [ActionName("GetEcardInfo")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage GetEcardInfo(JObject obj)
        {
            ObjectResult<GetEcardInfo_Model> res = new ObjectResult<GetEcardInfo_Model>();
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

            GetEcardInfo_Model model = new GetEcardInfo_Model();
            model = Order_BLL.Instance.getEcardInfo(utilityModel.CustomerID);

            if (model != null)
            {
                res.Code = "1";
                res.Message = "success";

                if (string.IsNullOrEmpty(model.LevelName))
                {
                    model.LevelName = "无";
                }
                if (model.Discount <= 0)
                {
                    model.Discount = Math.Round((decimal)1, 2);
                }
                model.Balance = Math.Round(model.Balance, 2);

                res.Data = model;
            }
            else
            {
                res.Code = "-1";
                res.Message = "";
                res.Data = null;
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetBalanceHistory")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage GetBalanceHistory(JObject obj)
        {
            ObjectResult<List<GetBalanceList_Model>> res = new ObjectResult<List<GetBalanceList_Model>>();
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

            List<GetBalanceList_Model> list = new List<GetBalanceList_Model>();
            list = Payment_BLL.Instance.getBalanceList(utilityModel.CustomerID);
            if (list != null)
            {
                foreach (GetBalanceList_Model item in list)
                {
                    int type = item.Type;
                    // 方式。0:现金、1:银行卡、2:赠送、3:转入、4:消费、5:转出、6:退款。
                    int Mode = item.Mode;
                    string strRecharge = "";

                    switch (Mode)
                    {
                        case 0:
                            strRecharge = "充值-现金";
                            break;
                        case 1:
                            strRecharge = "充值-银行卡";
                            break;
                        case 2:
                            strRecharge = "充值-赠送";
                            break;
                        case 3:
                            strRecharge = "充值-转入";
                            break;
                        case 4:
                            strRecharge = "消费-" + item.ProductName;
                            break;
                        case 5:
                            strRecharge = "转出";
                            break;
                        case 6:
                            strRecharge = "退款";
                            break;
                        default:
                            break;
                    }
                    item.RechargeText = strRecharge;
                }
            }

            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("Recharge")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"Mode":5,"Amount":"88","CustomerID":2482}
        public HttpResponseMessage Recharge(JObject obj)
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

            RechargeOperation_Model operationmodel = new RechargeOperation_Model();
            operationmodel = JsonConvert.DeserializeObject<RechargeOperation_Model>(strSafeJson);

            if (operationmodel == null || operationmodel.CustomerID <= 0 || operationmodel.Amount < 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationmodel.CreatorID = this.UserID;
            operationmodel.CompanyID = this.CompanyID;
            operationmodel.CreateTime = DateTime.Now.ToLocalTime();
            operationmodel.BranchID = this.BranchID;
            // 方式。0:现金、1:银行卡、2:赠送、3:转入、4:消费、5:转出、6:退款
            // 变化类型。0:充值、1:消费。
            switch (operationmodel.Mode)
            {
                case 0:
                    operationmodel.Type = 0;
                    break;
                case 1:
                    operationmodel.Type = 0;
                    break;
                case 2:
                    operationmodel.Type = 0;
                    break;
                case 3:
                    operationmodel.Type = 0;
                    break;
                case 4:
                    operationmodel.Type = 1;
                    break;
                case 5:
                    operationmodel.Type = 1;
                    break;
                case 6:
                    operationmodel.Type = 1;
                    break;
                default:
                    operationmodel.Type = 0;
                    break;
            }

            if (operationmodel.Type == 1)
            {
                operationmodel.Amount = Math.Abs(operationmodel.Amount) * -1;
            }

            if (operationmodel.GiveAmount <= 0)
            {
                operationmodel.GiveAmount = 0;
            }

            bool result = Payment_BLL.Instance.rechargeBanlance(operationmodel);
            if (result)
            {
                res.Code = "1";
                res.Message = Resources.sysMsg.rechargeBalanceSuccess;
                res.Data = true;
            }
            else
            {
                res.Message = Resources.sysMsg.rechargeBalanceError;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetBalanceDetail")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage GetBalanceDetail(JObject obj)
        {
            ObjectResult<BalanceDetailInfo_Model> res = new ObjectResult<BalanceDetailInfo_Model>();
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

            if (utilityModel == null || utilityModel.ID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            BalanceDetailInfo_Model model = new BalanceDetailInfo_Model();
            model = Payment_BLL.Instance.getBalanceDetail(utilityModel.ID);

            if (model != null)
            {
                List<Profit_Model> list = Payment_BLL.Instance.getProfitListByMasterID(utilityModel.ID, 1);
                model.ProfitList = list;
                res.Code = "1";
                res.Data = model;
            }

            return toJson(res);
        }

        //////////////////////////////////////////////////////////////////////////////////

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
            List<GetECardList_Model> Cardlist = ECard_BLL.Instance.GetCustomerCardList(utilityModel.CompanyID, utilityModel.BranchID, utilityModel.CustomerID);
            List<GetECardList_Model> PointCouponlist = ECard_BLL.Instance.GetCustomerPointCouponList(utilityModel.CompanyID, utilityModel.BranchID, utilityModel.CustomerID);
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
        [ActionName("UpdateCustomerDefaultCard")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"CustomerID":123,"UserCardNo":"333"}
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

            if (utilityModel == null || utilityModel.CustomerID <= 0 || string.IsNullOrWhiteSpace(utilityModel.UserCardNo))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.AccountID = this.UserID;


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
        [ActionName("UpdateExpirationDate")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"CustomerID":123,"UserCardNo":"333"}
        public HttpResponseMessage UpdateExpirationDate(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "操作失败";
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

            UpdateCustomerCardExpiredDateOperation_Model updateModel = new UpdateCustomerCardExpiredDateOperation_Model();
            updateModel = JsonConvert.DeserializeObject<UpdateCustomerCardExpiredDateOperation_Model>(strSafeJson);

            if (updateModel == null || updateModel.CardExpiredDate == null || string.IsNullOrWhiteSpace(updateModel.UserCardNo))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            updateModel.CompanyID = this.CompanyID;

            bool result = ECard_BLL.Instance.UpdateExpirationDate(updateModel.CompanyID, updateModel.UserCardNo, updateModel.CardExpiredDate);

            if (result)
            {
                res.Code = "1";
                res.Message = "操作成功";
                res.Data = true;
            }
            return toJson(res);
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
            list = ECard_BLL.Instance.GetBranchCardList(utilityModel.CompanyID, utilityModel.BranchID, utilityModel.isShowAll, utilityModel.isOnlyMoneyCard);

            if (list != null && list.Count > 0)
            {
                foreach (GetCompanyCardList_Model item in list)
                {
                    if (item.CardTypeID == 1)
                    {
                        item.DiscountList = new List<CardDiscountList_Model>();
                        item.DiscountList = ECard_BLL.Instance.GetCardDisCountListByCardID(utilityModel.CompanyID, item.CardID);
                    }
                }
            }

            res.Code = "1";
            res.Message = "";
            res.Data = list;

            return toJson(res, "yyyy-MM-dd");
        }

        [HttpPost]
        [ActionName("AddCustomerCard")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"CardID":2,"IsDefault":true,"CustomerID":11722,"Currency":"¥","CardCreatedDate":"2015-05-05","CardExpiredDate":"2016-05-04"} 
        public HttpResponseMessage AddCustomerCard(JObject obj)
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

            AddCustomerCardOperation_Model addModel = new AddCustomerCardOperation_Model();
            addModel = JsonConvert.DeserializeObject<AddCustomerCardOperation_Model>(strSafeJson);

            if (addModel == null || addModel.CustomerID <= 0 || addModel.CardID <= 0 || addModel.CardCreatedDate == null || addModel.CardExpiredDate == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            addModel.CompanyID = this.CompanyID;
            addModel.BranchID = this.BranchID;
            addModel.LocalTime = DateTime.Now.ToLocalTime();
            addModel.AccountID = this.UserID;
            addModel.CardCreatedDate = DateTime.Now.ToLocalTime();

            int result = ECard_BLL.Instance.AddCustomerCard(addModel);

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
                    res.Message = "用户已拥有此卡";
                    break;
                default:
                    res.Code = "0";
                    res.Message = "操作失败!";
                    break;
            }

            return toJson(res);
        }


        [HttpPost]
        [ActionName("CardRecharge")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"ChangeType":3,"CardType":1,"DepositMode":1,"UserCardNo":"11758745","CustomerID":0,"ResponsiblePersonID":26,"Amount":20.0,"Remark":null,"SlaveID":[3,36],"GiveList":[{"CardType":1,"UserCardNo":"123456","Amount":30.0},{"CardType":2,"UserCardNo":"654123","Amount":30.0}]}
        public HttpResponseMessage CardRecharge(JObject obj)
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

            CardRechargeOperation_Model addModel = new CardRechargeOperation_Model();
            addModel = JsonConvert.DeserializeObject<CardRechargeOperation_Model>(strSafeJson);

            if (!this.IsBusiness)
            {
                addModel.CustomerID = this.UserID;
            }

            if (addModel == null || addModel.CustomerID <= 0 || addModel.CardType <= 0 || string.IsNullOrWhiteSpace(addModel.UserCardNo) || addModel.Amount == 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (addModel.CardType == 1 && (addModel.ChangeType != 3 && addModel.ChangeType != 5 && addModel.ChangeType != 9))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (addModel.CardType != 1 && (addModel.ChangeType != 3 && addModel.ChangeType != 5))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            addModel.CompanyID = this.CompanyID;
            addModel.BranchID = this.BranchID;
            addModel.CreatorID = this.UserID;
            addModel.CreateTime = DateTime.Now.ToLocalTime();

            #region 权限判断
            if (this.IsBusiness)
            {
                bool roleRes = RoleCheck_BLL.Instance.IsAccountHasTheRole(addModel.CompanyID, addModel.CreatorID, "|9|");
                if (!roleRes)
                {
                    res.Message = "没有该权限!";
                    return toJson(res);
                }
            }
            #endregion

            int result = ECard_BLL.Instance.CardRecharge(addModel);

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
                    res.Message = "充值类型不对";
                    break;
                case 3:
                    res.Code = "0";
                    res.Message = "卡内金额不够";
                    break;
                default:
                    res.Code = "0";
                    res.Message = "操作失败!";
                    break;
            }

            return toJson(res);
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
            list = ECard_BLL.Instance.GetBalanceListByCustomerID(utilityModel.CompanyID, utilityModel.BranchID, utilityModel.CustomerID);

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
            list = ECard_BLL.Instance.GetCardBalanceByUserCardNo(utilityModel.CompanyID, utilityModel.BranchID, utilityModel.CustomerID, utilityModel.UserCardNo, utilityModel.CardType);

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
                List<Profit_Model> list = new List<Profit_Model>();
                if (model.PaymentID > 0)
                {
                    list = Payment_BLL.Instance.getProfitListByMasterID(model.PaymentID, 2);
                }
                else
                {
                    list = Payment_BLL.Instance.getProfitListByMasterID(utilityModel.ID, 1);
                }
                model.ProfitList = list;

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
            list = ECard_BLL.Instance.GetCardDiscountList(utilityModel.CompanyID, utilityModel.BranchID, utilityModel.CustomerID, utilityModel.ProductCode, utilityModel.ProductType);

            res.Code = "1";
            res.Message = "success";
            res.Data = list;

            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetCustomerBenefitList")]
        [HTTPBasicAuthorize]
        //{"Type":1,"CustomerID":2569}
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

            if (operationModel.CustomerID <= 0 || operationModel.Type <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            List<CustomerBenefitList_Model> list = ECard_BLL.Instance.getCustomerBenefitList(this.CompanyID, operationModel.CustomerID, this.BranchID, operationModel.Type);
            res.Code = "1";
            res.Data = list;
            res.Message = "";
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetCustomerBenefitDetail")]
        [HTTPBasicAuthorize]
        //{"BenefitID":1,"CustomerID":2569}
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

            if (operationModel.CustomerID <= 0 || string.IsNullOrWhiteSpace(operationModel.BenefitID))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            CustomerBenefitDetail_Model model = ECard_BLL.Instance.getCustomerBenefitDetail(this.CompanyID, operationModel.CustomerID, operationModel.BenefitID);
            res.Code = "1";
            res.Data = model;
            res.Message = "";
            return toJson(res);
        }

        [HttpPost]
        [ActionName("CardOutAndIn")]
        [HTTPBasicAuthorize]
        //{"OutCardNo":"asdasdasdasd","InCardNo":"asdasdasdasd","CustomerID":1234,"Remark":"adasdasd"}
        public HttpResponseMessage CardOutAndIn(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
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

            CardOutAndInOperation_Model operationModel = new CardOutAndInOperation_Model();
            operationModel = JsonConvert.DeserializeObject<CardOutAndInOperation_Model>(strSafeJson);

            if (operationModel.CustomerID <= 0 || operationModel.CardID < 0 || string.IsNullOrWhiteSpace(operationModel.OutCardNo))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.CompanyID = this.CompanyID;
            operationModel.BranchID = this.BranchID;
            operationModel.OperaterID = this.UserID;
            operationModel.Time = DateTime.Now.ToLocalTime();

            int operateRes = ECard_BLL.Instance.CardOutAndIn(operationModel);

            switch (operateRes)
            {
                case 1:
                    res.Code = "1";
                    res.Data = true;
                    res.Message = "转账成功";
                    break;
                case -1:
                    res.Code = "0";
                    res.Data = false;
                    res.Message = "不能将钱转给同一张卡";
                    break;
                case -2:
                    res.Code = "0";
                    res.Data = false;
                    res.Message = "转出卡内余额为0，请直接开新卡";
                    break;
                default:
                    res.Code = "0";
                    res.Data = false;
                    res.Message = "转账失败";
                    break;
            }

            
            return toJson(res);
        }


    }
}
