using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
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
using WebAPI.Authorize;
using WebAPI.BLL.Customer;
using WebAPI.Controllers.API;

namespace WebAPI.Controllers.Customer
{
    public class Order_CController : Base_CController
    {
        [HttpPost]
        [ActionName("GetOrderList")]
        [HTTPBasicAuthorize]
        /// Aaron_Han
        /// {"BranchID":1,"ProductType": -1,"Status": -1,"PaymentStatus": 1,"OrderID":0,"ViewType":0,"FilterByTimeFlag":1,"StartTime":"2012-12-12","EndTime":"2012-12-12","PageIndex":1,"PageSize":10,"ResponsiblePersonIDs":[3,4,5],"CustomerID":1022}
        public HttpResponseMessage GetOrderList(JObject obj)
        {
            ObjectResult<GetOrderListRes_Model> res = new ObjectResult<GetOrderListRes_Model>();
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

            GetOrderListOperation_Model operationModel = new GetOrderListOperation_Model();
            operationModel = JsonConvert.DeserializeObject<GetOrderListOperation_Model>(strSafeJson);

            if (operationModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (this.IsBusiness)
            {
                if (!operationModel.IsShowAll)
                {
                    if (operationModel.ResponsiblePersonIDs == null || operationModel.ResponsiblePersonIDs.Count <= 0)
                    {
                        operationModel.ResponsiblePersonIDs = new List<int>();
                        operationModel.ResponsiblePersonIDs.Add(this.UserID);
                    }
                }
                //operationModel.AccountID = this.UserID;
            }
            else
            {
                operationModel.CustomerID = this.UserID;
                operationModel.IsShowAll = true;
            }

            if (operationModel.BranchID == 0 && operationModel.CustomerID == 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (operationModel.FilterByTimeFlag == 1)
            {
                if ((String.IsNullOrWhiteSpace(operationModel.StartTime) || String.IsNullOrWhiteSpace(operationModel.EndTime)))
                {
                    res.Message = "请选择日期!";
                    return toJson(res);
                }
                else
                {
                    DateTime dtStartTime = new DateTime();
                    DateTime dtEndTiime = new DateTime();
                    if (DateTime.TryParse(operationModel.StartTime, out dtStartTime) && DateTime.TryParse(operationModel.EndTime, out dtEndTiime))
                    {
                        operationModel.StartTime = dtStartTime.ToShortDateString();
                        operationModel.EndTime = dtEndTiime.ToShortDateString();
                    }
                    else
                    {
                        res.Message = "请输入正确的时间格式!";
                        return toJson(res);
                    }
                }
            }

            if (operationModel.PageIndex <= 0)
            {
                operationModel.PageIndex = 1;
            }

            if (operationModel.PageSize <= 0)
            {
                operationModel.PageSize = 10;
            }

            GetOrderListRes_Model model = new GetOrderListRes_Model();
            List<GetOrderList_Model> list = new List<GetOrderList_Model>();
            int recordCount = 0;
            list = Order_CBLL.Instance.getOrderList(operationModel, operationModel.PageSize, operationModel.PageIndex, out recordCount);

            if (list == null)
            {
                model.RecordCount = 0;
                model.PageCount = 0;
                res.Data = model;
                res.Code = "1";
            }
            else
            {
                model.RecordCount = recordCount;
                model.PageCount = Pagination.GetPageCount(recordCount, operationModel.PageSize);
                model.OrderList = list;
                res.Data = model;
                res.Code = "1";
            }

            return toJson(res, "yyyy-MM-dd HH:mm:ss.ff");
        }


        [HttpPost]
        [ActionName("GetOrderDetail")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"OrderID": 7,"ProductType": 0}
        public HttpResponseMessage GetOrderDetail(JObject obj)
        {
            ObjectResult<GetOrderDetail_Model> res = new ObjectResult<GetOrderDetail_Model>();
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
            operationModel.CompanyID = this.CompanyID;
            if (operationModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }


            GetOrderDetail_Model model = new GetOrderDetail_Model();
            model = Order_CBLL.Instance.getOrderDetail(operationModel.OrderObjectID, operationModel.ProductType, operationModel.CompanyID);

            if (model != null)
            {
                #region 根据创建时间和定点编号 生成订单编号
                if (!string.IsNullOrEmpty(model.CreateTime))
                {
                    DateTime dt = Convert.ToDateTime(model.CreateTime);
                    model.OrderNumber = dt.Month.ToString().PadLeft(2, '0') + dt.Day.ToString().PadLeft(2, '0') + model.OrderID.ToString().PadLeft(6, '0') + dt.Year.ToString().Substring(dt.Year.ToString().Length - 2, 2);
                }
                #endregion

                //#region 根据订单编号获取PaymentDetail
                //List<PaymentDetail> paymentDetailList = Payment_BLL.Instance.GetPaymentDetailByOrderID(operationModel.OrderID);
                //model.PaymentList = paymentDetailList;
                //#endregion

                // productType = 0: 服务、 1：商品


                #region 获取TREATGROUP
                List<Group> groupList = new List<Group>();
                groupList = Order_CBLL.Instance.getGroupNoList(operationModel.OrderObjectID, operationModel.ProductType);
                if (operationModel.ProductType == 0)
                {
                    if (groupList != null)
                    {
                        foreach (Group item in groupList)
                        {
                            List<Treatment> treatmentList = new List<Treatment>();
                            // 获取处理列表
                            treatmentList = Order_CBLL.Instance.getTreatmentListByGroupNO(item.GroupNo, this.CompanyID);
                            if (treatmentList != null && treatmentList.Count > 0)
                            {
                                item.TreatmentList = treatmentList;

                            }

                        }
                        model.GroupList = groupList;
                    }
                }
                else
                {
                    model.GroupList = groupList;
                }

                #endregion

                #region 获取预约
                List<TaskSimpleList_Model> scdlList = new List<TaskSimpleList_Model>();
                scdlList = Task_CBLL.Instance.GetScheduleListByOrderID(operationModel.CompanyID, model.OrderID, operationModel.OrderObjectID);
                if (scdlList != null)
                {
                    model.ScdlList = scdlList;
                    model.ScdlCount = scdlList.Count;
                }
                #endregion

            }

            res.Data = model;
            res.Code = "1";

            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetTreatGroupByOrderObjectID")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"OrderObjectID": 7,"ProductType": 0,"Status":-1}
        public HttpResponseMessage GetTreatGroupByOrderObjectID(JObject obj)
        {
            ObjectResult<List<Group>> res = new ObjectResult<List<Group>>();
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
            operationModel.CompanyID = this.CompanyID;
            if (operationModel == null || operationModel.OrderObjectID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            List<Group> groupList = new List<Group>();
            groupList = Order_CBLL.Instance.getGroupNoList(operationModel.OrderObjectID, operationModel.ProductType, operationModel.Status);
            if (operationModel.ProductType == 0)
            {
                if (groupList != null)
                {
                    foreach (Group item in groupList)
                    {
                        List<Treatment> treatmentList = new List<Treatment>();
                        // 获取处理列表
                        treatmentList = Order_CBLL.Instance.getTreatmentListByGroupNO(item.GroupNo, this.CompanyID);
                        if (treatmentList != null && treatmentList.Count > 0)
                        {
                            item.TreatmentList = treatmentList;

                        }
                    }
                }
            }

            res.Data = groupList;
            res.Code = "1";

            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetExecutingOrderList")]
        [HTTPBasicAuthorize]
        ///{"CustomerID":1}
        public HttpResponseMessage GetExecutingOrderList(JObject obj)
        {
            ObjectResult<List<ExecutingOrder_Model>> res = new ObjectResult<List<ExecutingOrder_Model>>();
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            if (utilityModel == null || utilityModel.CustomerID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.CompanyID = this.CompanyID;

            List<ExecutingOrder_Model> list = Order_CBLL.Instance.GetExecutingOrderList(utilityModel);
            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetUnfinishTGList")]
        [HTTPBasicAuthorize]
        ///{"CustomerID":1,"IsToday":true,"ProductType":1}
        public HttpResponseMessage GetUnfinishTGList(JObject obj)
        {

            ObjectResult<List<UnfinishTG_Model>> res = new ObjectResult<List<UnfinishTG_Model>>();
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);
            if (utilityModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.IsBusiness = this.IsBusiness;
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;

            if (utilityModel.ImageWidth <= 0)
            {
                utilityModel.ImageWidth = 160;
            }

            if (utilityModel.ImageHeight <= 0)
            {
                utilityModel.ImageHeight = 160;
            }

            List<UnfinishTG_Model> list = Order_CBLL.Instance.GetUnfinishTGList(utilityModel);
            list = list.OrderByDescending(x => x.TGStartTime).ToList<UnfinishTG_Model>();
            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("ConfirmTreatGroup")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"CustomerID":123 ,"TGDetailList":[{"OrderType":0,"OrderID":123,"OrderObjectID":123,"GroupNo":123456789}]}  
        public HttpResponseMessage ConfirmTreatGroup(JObject obj)
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

            CompleteTGOperation_Model utilityModel = new CompleteTGOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<CompleteTGOperation_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.TGDetailList == null || utilityModel.TGDetailList.Count <= 0 || this.IsBusiness)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.UpdaterID = this.UserID;
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;
            utilityModel.UpdateTime = DateTime.Now.ToLocalTime();
            utilityModel.CustomerID = this.UserID;


            int code = Order_CBLL.Instance.ConfirmTreatGroup(utilityModel);

            res.Code = code.ToString();
            switch (code)
            {
                case 1:
                    res.Message = "成功!";
                    res.Data = true;
                    break;
                case -2:
                    res.Message = "不合法参数";
                    res.Data = false;
                    break;
                default:
                    res.Message = "失败!";
                    res.Data = false;
                    break;
            }

            return toJson(res);
        }
    }
}
