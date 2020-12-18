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
using System.Xml;

namespace ClientApi.Controllers.API
{
    public class OrderController : BaseController
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

            operationModel.CustomerID = this.UserID;
            operationModel.CompanyID = this.CompanyID;

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
            list = Order_BLL.Instance.getOrderList(operationModel, operationModel.PageSize, operationModel.PageIndex, out recordCount);

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
                model.PageCount = HS.Framework.Common.Util.Pagination.GetPageCount(recordCount, operationModel.PageSize);
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
            model = Order_BLL.Instance.getOrderDetail(operationModel.OrderObjectID, operationModel.ProductType, operationModel.CompanyID);

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
                groupList = Order_BLL.Instance.getGroupNoList(operationModel.OrderObjectID, operationModel.ProductType, 0);
                if (operationModel.ProductType == 0)
                {
                    if (groupList != null)
                    {
                        foreach (Group item in groupList)
                        {
                            List<Treatment> treatmentList = new List<Treatment>();
                            // 获取处理列表
                            treatmentList = Order_BLL.Instance.getTreatmentListByGroupNO(item.GroupNo, this.CompanyID);
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
                scdlList = Task_BLL.Instance.GetScheduleListByOrderID(operationModel.CompanyID, model.OrderID, operationModel.OrderObjectID);
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
        [ActionName("GetUnconfirmTreatGroup")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetUnconfirmTreatGroup(JObject obj)
        {
            ObjectResult<List<TGList_Model>> res = new ObjectResult<List<TGList_Model>>();
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

            if (operationModel == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            operationModel.CustomerID = this.UserID;
            operationModel.CompanyID = this.CompanyID;
            List<TGList_Model> list = new List<TGList_Model>();
            list = Order_BLL.Instance.GetUnconfirmTreatGroup(operationModel.CompanyID, operationModel.CustomerID, operationModel.Type);

            if (list != null && list.Count > 0)
            {
                list = list.OrderByDescending(c => c.TGStartTime).ToList();
            }

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
            utilityModel.UpdateTime = DateTime.Now.ToLocalTime();
            utilityModel.CustomerID = this.UserID;


            int code = Order_BLL.Instance.ConfirmTreatGroup(utilityModel);

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

        [HttpPost]
        [ActionName("GetOrderCount")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"CustomerID": 0}
        public HttpResponseMessage GetOrderCount(JObject obj)
        {
            ObjectResult<GetOrderCount_Model> res = new ObjectResult<GetOrderCount_Model>();
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

            OrderCountOperation_Model orderCountModel = new OrderCountOperation_Model();
            orderCountModel = JsonConvert.DeserializeObject<OrderCountOperation_Model>(strSafeJson);

            if (orderCountModel == null || orderCountModel.CustomerID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            orderCountModel.CompanyID = this.CompanyID;
            orderCountModel.BranchID = this.BranchID;
            GetOrderCount_Model model = new GetOrderCount_Model();
            model = Order_BLL.Instance.getOrderCount(orderCountModel);
            if (model != null)
            {
                res.Code = "1";
                res.Data = model;
            }

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
            groupList = Order_BLL.Instance.getGroupNoList(operationModel.OrderObjectID, operationModel.ProductType, operationModel.Status);
            if (operationModel.ProductType == 0)
            {
                if (groupList != null)
                {
                    foreach (Group item in groupList)
                    {
                        List<Treatment> treatmentList = new List<Treatment>();
                        // 获取处理列表
                        treatmentList = Order_BLL.Instance.getTreatmentListByGroupNO(item.GroupNo, this.CompanyID);
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
        [ActionName("GetTGDetail")]
        [HTTPBasicAuthorize]
        /// chen
        /// {"GroupNo": 1507090000000007,"OrderID":2471}
        public HttpResponseMessage GetTGDetail(JObject obj)
        {
            ObjectResult<GetTGDetail_Model> res = new ObjectResult<GetTGDetail_Model>();
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

            if (utilityModel == null || utilityModel.GroupNo <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;
            utilityModel.AccountID = this.UserID;




            GetTGDetail_Model model = Order_BLL.Instance.getTGDetail(utilityModel.GroupNo, this.CompanyID);


            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }


        [HttpPost]
        [ActionName("GetTreatmentDetail")]
        [HTTPBasicAuthorize]
        /// jimmy.wu
        /// {"TreatmentID": 0}
        public HttpResponseMessage GetTreatmentDetail(JObject obj)
        {
            ObjectResult<GetTreatmentDetail_Model> res = new ObjectResult<GetTreatmentDetail_Model>();
            res.Code = "0";
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (utilityModel.TreatmentID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;
            utilityModel.AccountID = this.UserID;



            GetTreatmentDetail_Model model = Order_BLL.Instance.GetTreatmentDetail(utilityModel);
            #region 根据创建时间和定点编号 生成操作编号
            if (model != null && model.StartTime != null)
            {
                DateTime dt = model.StartTime;
                model.ID = dt.Month.ToString().PadLeft(2, '0') + dt.Day.ToString().PadLeft(2, '0') + model.ID.PadLeft(6, '0') + dt.Year.ToString().Substring(dt.Year.ToString().Length - 2, 2);
            }
            #endregion
            if (model == null)
            {
                res.Message = "Treatment获取失败";
                return toJson(res);
            }
            else
            {
                res.Code = "1";
                res.Data = model;
                return toJson(res);
            }
        }


        [HttpPost]
        [ActionName("GetUnfinishOrder")]
        [HTTPBasicAuthorize]
        public HttpResponseMessage GetUnfinishOrder(JObject obj)
        {
            ObjectResult<List<GetUnfinishOrder_Model>> res = new ObjectResult<List<GetUnfinishOrder_Model>>();
            res.Code = "0";
            res.Data = null;

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();

            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            if (string.IsNullOrEmpty(strSafeJson))
            {
                res.Message = "不合法参数";
                return toJson(res);
            }
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            List<GetUnfinishOrder_Model> list = Order_BLL.Instance.getUnfinishOrder(this.CompanyID, this.UserID, utilityModel.ProductType);

            if (utilityModel.BranchID > 0)
            {
                list = list.Where(x => x.BranchID == utilityModel.BranchID && (x.TGTotalCount > x.TGExecutingCount + x.TGFinishedCount || x.TGTotalCount == 0)).ToList<GetUnfinishOrder_Model>();
            }

            res.Code = "1";
            res.Data = list;
            return toJson(res);

        }

        [HttpPost]
        [ActionName("AddNewOrder")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"CustomerID":"2497","OldOrderIDs":[2,3,4],"OrderList":[{"CardID":1,"TGPastCount":0,"ProductID":1458,"ProductCode":1164,"BranchID":38,"Quantity":2,"IsPast":1,"TotalOrigPrice":120.00,"TotalCalcPrice":120.00,"TotalSalePrice":-1,"ProductType":0,"ResponsiblePersonID":2339,"SalesID":0,"OpportunityID":0,"ExpirationTime":"2015-01-15","Remark":""}]}
        public HttpResponseMessage AddNewOrder(JObject obj)
        {
            ObjectResult<List<int>> res = new ObjectResult<List<int>>();
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

            OrderOperation_Model orderinfo = new OrderOperation_Model();
            orderinfo = JsonConvert.DeserializeObject<OrderOperation_Model>(strSafeJson);

            if (orderinfo == null || orderinfo.OrderList == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            orderinfo.Status = 0;
            orderinfo.CustomerID = this.UserID;
            orderinfo.OrderTime = DateTime.Now.ToLocalTime();
            orderinfo.CreateTime = DateTime.Now.ToLocalTime();
            orderinfo.UpdateTime = DateTime.Now.ToLocalTime();
            orderinfo.CreatorID = this.UserID;
            orderinfo.UpdaterID = orderinfo.CreatorID;
            orderinfo.CompanyID = this.CompanyID;
            orderinfo.IsBusiness = false;

            res = Order_BLL.Instance.addNewOrder(orderinfo);

            switch (res.Code)
            {
                case "1":
                    if (res.Data != null)
                    {
                        res.Message = "订单添加成功!";
                    }
                    break;
                case "2":
                    res.Message = "订单添加失败!";
                    break;
                case "3":
                    res.Message = res.Message.TrimEnd(',');
                    break;
                case "4":
                    res.Message = "有需求已转为订单";
                    break;
                case "5":
                    res.Message = "有购物车已转为订单";
                    break;
                case "6":
                    res.Message = res.Message;
                    break;
                case "-2":
                    res.Message = "价格已变化！";
                    break;
                default:
                    res.Message = "订单添加失败!";
                    break;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("AddRushOrder")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"BranchID": 1,"PromotionID": "prm123135465","ProductID": 85,"ProductType": 0,"Qty": 1,"Remark": "ceshi"}
        public HttpResponseMessage AddRushOrder(JObject obj)
        {
            ObjectResult<int> res = new ObjectResult<int>();
            res.Code = "0";
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

            AddRushOrderOperation_Model orderinfo = new AddRushOrderOperation_Model();
            orderinfo = JsonConvert.DeserializeObject<AddRushOrderOperation_Model>(strSafeJson);

            if (orderinfo == null || orderinfo.BranchID <= 0 || string.IsNullOrWhiteSpace(orderinfo.PromotionID) || orderinfo.ProductID <= 0 || orderinfo.Qty <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            orderinfo.CompanyID = this.CompanyID;
            orderinfo.CustomerID = this.UserID;
            orderinfo.Time = DateTime.Now.ToLocalTime();
            orderinfo.LimitedPaymentTime = orderinfo.Time.AddMinutes(15);
            orderinfo.ReleaseTime = orderinfo.Time.AddMinutes(21);

            string msg = "";
            int rushOrderID = Order_BLL.Instance.AddRushOrder(orderinfo, out msg);
            if (rushOrderID <= 0)
            {
                res.Code = "0";
                res.Message = msg;
                res.Data = 0;
            }
            else
            {
                res.Code = "1";
                res.Message = msg;
                res.Data = rushOrderID;
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetRushOrderDetail")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"OrderID": 1,"WeChatOpenID":"123123123"}
        public HttpResponseMessage GetRushOrderDetail(JObject obj)
        {
            ObjectResult<GetRushOrderDetail_Model> res = new ObjectResult<GetRushOrderDetail_Model>();
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

            if (utilityModel == null || utilityModel.OrderID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CustomerID = this.UserID;

            GetRushOrderDetail_Model model = Order_BLL.Instance.GetRushOrderDetail(utilityModel.CompanyID, utilityModel.CustomerID, utilityModel.OrderID);
            if (model != null)
            {
                #region 根据创建时间和定点编号 生成订单编号
                if (!string.IsNullOrEmpty(model.CreateTime))
                {
                    DateTime dt = Convert.ToDateTime(model.CreateTime);
                    model.OrderCode = dt.Month.ToString().PadLeft(2, '0') + dt.Day.ToString().PadLeft(2, '0') + model.RushOrderID.ToString().PadLeft(6, '0') + dt.Year.ToString().Substring(dt.Year.ToString().Length - 2, 2);
                }
                #endregion

                if (model.PaymentStatus == 1 && !string.IsNullOrEmpty(utilityModel.WeChatOpenID))
                {
                    #region 未支付
                    string WeChatPayNotify_Url = System.Configuration.ConfigurationManager.AppSettings["WeChatPayNotify_Url"];
                    string Spdill_Create_IP = System.Configuration.ConfigurationManager.AppSettings["Spdill_Create_IP"];
                    string total_fee = ((int)(Math.Round(model.TotalRushPrice, 2) * 100)).ToString();

                    HS.Framework.Common.WeChat.WeChatPay wechatPay = new HS.Framework.Common.WeChat.WeChatPay();
                    string XMLres = wechatPay.UnifiedOrder(model.NetTradeNo, utilityModel.CompanyID, utilityModel.WeChatOpenID, "attach", model.ProductName, WeChatPayNotify_Url, Spdill_Create_IP, total_fee);

                    if (string.IsNullOrEmpty(XMLres))
                    {
                        return toJson(res);
                    }

                    XmlDocument doc = new XmlDocument();
                    doc.LoadXml(XMLres);
                    XmlNode root = doc.FirstChild;
                    string return_code = root["return_code"].InnerText;
                    if (return_code == "FAIL")
                    {
                        res.Message = root["return_msg"].InnerText;
                        return toJson(res);
                    }

                    string result_code = root["result_code"].InnerText;
                    if (result_code == "FAIL")
                    {
                        res.Message = root["err_code_des"].InnerText;
                        return toJson(res);
                    }

                    string prepay_id = root["prepay_id"].InnerText;
                    if (string.IsNullOrWhiteSpace(prepay_id))
                    {
                        return toJson(res);
                    }

                    model.JsParam = wechatPay.GetJsApiParameters(utilityModel.CompanyID, doc);
                    #endregion
                }

                res.Code = "1";
                res.Data = model;
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetRushOrderList")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        public HttpResponseMessage GetRushOrderList()
        {
            ObjectResult<List<GetRushOrderList_Model>> res = new ObjectResult<List<GetRushOrderList_Model>>();
            res.Code = "0";
            res.Data = null;
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.CustomerID = this.UserID;
            List<GetRushOrderList_Model> list = Order_BLL.Instance.GetRushOrderList(utilityModel.CompanyID, utilityModel.CustomerID);
            res.Code = "1";
            res.Data = list;

            return toJson(res);
        }
    }
}
