using HS.Framework.Common.Entity;
using HS.Framework.Common.Safe;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.View_Model;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Web.Http;
using WebAPI.Authorize;
using WebAPI.BLL;
using System.Linq;

namespace WebAPI.Controllers.API
{
    public class OrderController : BaseController
    {

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
        [ActionName("GetUnconfirmedOrderList")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"CustomerID": 0}
        public HttpResponseMessage GetUnconfirmedOrderList(JObject obj)
        {
            ObjectResult<List<GetUnconfirmedOrderList_Model>> res = new ObjectResult<List<GetUnconfirmedOrderList_Model>>();
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

            List<GetUnconfirmedOrderList_Model> list = new List<GetUnconfirmedOrderList_Model>();
            list = Order_BLL.Instance.getUnconfirmedOrderList(utilityModel.CustomerID);
            res.Code = "1";
            if (list != null)
            {
                foreach (GetUnconfirmedOrderList_Model item in list)
                {
                    if (item.ProductType == 0)
                    {
                        GetCourseAndTreatmentNumber_Model numberModel = new GetCourseAndTreatmentNumber_Model();
                        numberModel = Order_BLL.Instance.getCourseAndTreatmentNumber(item.TreatmentID);
                        if (numberModel != null)
                        {
                            item.Remark = "课程" + numberModel.CourseNumber + "第" + numberModel.TreatmentNumber + "次";
                            item.IsLastFlag = numberModel.IsLast;
                        }
                    }
                }
                res.Data = list;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("ConfirmOrder")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"CustomerID": 0,"Password":"123123","OrderList":[{"ProductType":0,"ID":1,"TreatmentID":123},{"ProductType":0,"ID":1,"TreatmentID":123}]}
        public HttpResponseMessage ConfirmOrder(JObject obj)
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

            ConfirmOrderOperation_Model utilityModel = new ConfirmOrderOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<ConfirmOrderOperation_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.CustomerID <= 0 || utilityModel.OrderList == null || utilityModel.OrderList.Count <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            if (string.IsNullOrWhiteSpace(utilityModel.Password))
            {
                res.Message = "请输入正确的密码";
                return toJson(res);
            }

            utilityModel.Password = CryptRSA.RSADecrypt(utilityModel.Password);

            if (Order_BLL.Instance.checkOrderListStatus(utilityModel.OrderList))
            {
                int result = Order_BLL.Instance.confirmOrder(utilityModel);
                switch (result)
                {
                    case 0:
                        res.Code = "0";
                        res.Message = "确认失败";
                        break;
                    case 1:
                        res.Code = "1";
                        res.Message = "确认成功";
                        break;
                    case 2:
                        res.Code = "0";
                        res.Message = "密码错误";
                        break;
                }
            }
            else
            {
                res.Code = "2";
                res.Message = "此订单状态已无法更新!";
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("AddTreatment")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"OrderID": 0,"CourseID":100,"CustomerID":0,"IsDesignated":0,"SubServiceIDs":"|1|2|3|4|5|"}
        public HttpResponseMessage AddTreatment(JObject obj)
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

            TreatmentAddOperation_Model addmodel = new TreatmentAddOperation_Model();
            addmodel = JsonConvert.DeserializeObject<TreatmentAddOperation_Model>(strSafeJson);

            if (addmodel == null || addmodel.OrderID <= 0 || addmodel.CourseID <= 0 || addmodel.CustomerID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            addmodel.CompanyID = this.CompanyID;
            addmodel.BranchID = this.BranchID;
            addmodel.CreatorID = this.UserID;

            #region 检查权限
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.AccountID = addmodel.CreatorID;
            utilityModel.BranchID = addmodel.BranchID;
            utilityModel.OrderID = addmodel.OrderID;
            //检查操作人的权限
            if (!RoleCheck_BLL.Instance.checkOrderUpdaterRole(utilityModel))
            {
                res.Message = "操作失败！请确认权限！";
                return toJson(res);
            }
            #endregion

            addmodel.CreateTime = DateTime.Now.ToLocalTime();
            addmodel.Reminded = false;
            addmodel.Status = 0;

            bool isSuccess = Order_BLL.Instance.addTreatment(addmodel);
            res.Data = isSuccess;


            if (isSuccess)
            {
                res.Code = "1";
                res.Message = "添加成功!";
            }
            else
            {
                res.Code = "0";
                res.Message = "添加失败!";
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("DeleteTreatment")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"CustomerID": 1022,"Group": {"GroupNo": 2012548,"TreatmentList": [{"TreatmentID": 123456,"ScheduleID": 12346},{"TreatmentID": 123456, "ScheduleID": 12346}]}}
        public HttpResponseMessage DeleteTreatment(JObject obj)
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

            TreatmentDelOperation_Model delmodel = new TreatmentDelOperation_Model();
            delmodel = JsonConvert.DeserializeObject<TreatmentDelOperation_Model>(strSafeJson);

            if (delmodel == null || delmodel.Group == null || delmodel.Group.GroupNo <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            delmodel.UpdaterID = this.UserID;
            delmodel.BranchID = this.BranchID;

            #region 检查美容师权限
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.AccountID = delmodel.UpdaterID;
            utilityModel.BranchID = delmodel.BranchID;
            utilityModel.OrderID = delmodel.OrderID;
            //检查操作人的权限
            if (!RoleCheck_BLL.Instance.checkOrderUpdaterRole(utilityModel))
            {
                res.Message = "操作失败！请确认权限！";
                return toJson(res);
            }
            #endregion

            delmodel.UpdateTime = DateTime.Now.ToLocalTime();

            int isSuccess = 0;// = Order_BLL.Instance.deleteTreatment(delmodel);

            res.Code = isSuccess.ToString();
            res.Message = "";
            res.Data = true;
            if (isSuccess == 0)
            {
                res.Data = false;
            }

            return toJson(res);
        }


        [HttpPost]
        [ActionName("UpdateTreatmentDetail")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"TreatmentID": 0,"ScheduleID":100,"ScheduleTime":"2015-01-01","ExecutorID":1,"CustomerID":0,"IsDesignated":0}
        public HttpResponseMessage UpdateTreatmentDetail(JObject obj)
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

            if (utilityModel == null || utilityModel.TreatmentID <= 0 || utilityModel.ScheduleID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.AccountID = this.UserID;
            utilityModel.UpdaterID = this.UserID;
            utilityModel.BranchID = this.BranchID;
            utilityModel.Time = DateTime.Now.ToLocalTime();

            if (!RoleCheck_BLL.Instance.checkOrderUpdaterRole(utilityModel))
            {
                res.Message = "操作失败！请确认权限！";
                return toJson(res);
            }

            if (Order_BLL.Instance.selectScheduleStatus(utilityModel.ScheduleID) != 1)
            {
                res.Message = "此服务已无法更新！";
                return toJson(res);
            }

            bool result = Order_BLL.Instance.updateTreatmentDetail(utilityModel);
            if (!result)
            {
                res.Message = "此服务已无法更新！";
                return toJson(res);
            }

            res.Code = "1";
            res.Message = "";
            res.Data = true;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("UpdateOrderIsAddUp")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"OrderID": 0,"IsAddUp":0}
        public HttpResponseMessage UpdateOrderIsAddUp(JObject obj)
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

            if (utilityModel == null || utilityModel.OrderID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.UpdaterID = this.UserID;
            utilityModel.AccountID = utilityModel.UpdaterID;
            utilityModel.Time = DateTime.Now.ToLocalTime();

            res = Order_BLL.Instance.UpdateOrderIsAddUp(utilityModel.OrderID, utilityModel.IsAddUp, utilityModel.UpdaterID);

            switch (res.Code)
            {
                case "1":
                    res.Message = "修改成功!";
                    res.Data = true;
                    break;
                case "3":
                    res.Message = res.Message;
                    res.Data = false;
                    break;
                case "2":
                    res.Message = res.Message;
                    res.Data = false;
                    break;
                default:
                    res.Message = "修改失败!";
                    res.Data = false;
                    break;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("CompleteTrearmentsByCourseID")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"CustomerID":307,"CourseID":738}
        public HttpResponseMessage CompleteTrearmentsByCourseID(JObject obj)
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

            CompleteTrearmentsByCourseIDOperation_Model utilityModel = new CompleteTrearmentsByCourseIDOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<CompleteTrearmentsByCourseIDOperation_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.CustomerID <= 0 || utilityModel.CourseID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.UpdaterID = this.UserID;
            utilityModel.BranchID = this.BranchID;

            bool isSuccess = Order_BLL.Instance.completeTrearmentsByCourseID(utilityModel);
            if (!isSuccess)
            {
                res.Message = "操作失败!";
                return toJson(res);
            }

            res.Code = "1";
            res.Message = "操作成功!";
            return toJson(res);
        }

        [HttpPost]
        [ActionName("completeBeforeTreatmentsByGroupNO")]
        [HTTPBasicAuthorize]
        /// Jimmy.wu
        /// {"CustomerID":307,"OrderID":2119,"Group": {"GroupNo": 2012548,"TreatmentList": [{"TreatmentID": 123456,"ScheduleID": 12346},{"TreatmentID": 123456,"ScheduleID": 12346}]}}
        public HttpResponseMessage CompleteBeforeTreatmentsByGroupNO(JObject obj)
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

            CompleteTrearmentsByCourseIDOperation_Model model = new CompleteTrearmentsByCourseIDOperation_Model();
            model = JsonConvert.DeserializeObject<CompleteTrearmentsByCourseIDOperation_Model>(strSafeJson);

            if (model == null || model.OrderID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            model.BranchID = this.BranchID;
            model.UpdaterID = this.UserID;
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.AccountID = this.UserID;
            utilityModel.UpdaterID = this.UserID;
            utilityModel.BranchID = model.BranchID;
            utilityModel.OrderID = model.OrderID;

            //检查操作人的权限
            if (!RoleCheck_BLL.Instance.checkOrderUpdaterRole(utilityModel))
            {
                res.Message = "操作失败！请确认权限！";
                return toJson(res);
            }

            utilityModel.UpdaterID = this.UserID;
            utilityModel.BranchID = this.BranchID;

            int result = 0;// Order_BLL.Instance.completeBeforeTreatmentByGroupNO(model);
            if (result == 1)
            {
                res.Code = "1";
                res.Message = "操作成功!";
            }
            else if (result == -2)
            {
                res.Code = "-2";
                res.Message = "订单内容已变动,请重新提交!";
            }
            else
            {
                res.Message = "操作失败!";
            }

            return toJson(res);
        }



        [HttpPost]
        [ActionName("CompleteTreatmentsByGroupNO")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"CustomerID":307,"OrderID":2119,"Group": {"GroupNo": 2012548,"TreatmentList": [{"TreatmentID": 123456,"ScheduleID": 12346},{"TreatmentID": 123456,"ScheduleID": 12346}]}}
        public HttpResponseMessage CompleteTreatmentsByGroupNO(JObject obj)
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

            CompleteTrearmentsByCourseIDOperation_Model model = new CompleteTrearmentsByCourseIDOperation_Model();
            model = JsonConvert.DeserializeObject<CompleteTrearmentsByCourseIDOperation_Model>(strSafeJson);

            if (model == null || model.OrderID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            model.BranchID = this.BranchID;
            model.UpdaterID = this.UserID;
            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel.AccountID = this.UserID;
            utilityModel.UpdaterID = this.UserID;
            utilityModel.BranchID = model.BranchID;
            utilityModel.OrderID = model.OrderID;

            //检查操作人的权限
            if (!RoleCheck_BLL.Instance.checkOrderUpdaterRole(utilityModel))
            {
                res.Message = "操作失败！请确认权限！";
                return toJson(res);
            }

            utilityModel.UpdaterID = this.UserID;
            utilityModel.BranchID = this.BranchID;

            int result = 0;// Order_BLL.Instance.completeTreatmentByGroupNO(model);
            if (result == 1)
            {
                res.Code = "1";
                res.Message = "操作成功!";
            }
            else if (result == -2)
            {
                res.Code = "-2";
                res.Message = "订单内容已变动,请重新提交!";
            }
            else
            {
                res.Message = "操作失败!";
            }

            return toJson(res);
        }





        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




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

            operationModel.CompanyID = this.CompanyID;

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

            if (!string.IsNullOrEmpty(operationModel.SerchField))
            {
                System.Text.RegularExpressions.Regex reg = new System.Text.RegularExpressions.Regex(@"^\d{12}$");
                bool isOrderCode = reg.IsMatch(operationModel.SerchField);
                if (isOrderCode)
                {
                    operationModel.OrderID = StringUtils.GetDbInt(operationModel.SerchField.Substring(4, 6));
                }
                else
                {
                    operationModel.ProductName = operationModel.SerchField;
                }
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

            if (operationModel.PageIndex < 0)
            {
                operationModel.PageIndex = 1;
            }

            if (operationModel.PageSize < 0)
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
            model = Order_BLL.Instance.getOrderDetail(operationModel.OrderObjectID, operationModel.ProductType, operationModel.CompanyID);

            if (model != null)
            {
                if (this.BranchID == model.BranchID)
                {
                    #region 权限判断
                    UserRole_Model userRole = Account_BLL.Instance.getUserRole_2_2(this.UserID);
                    if (userRole != null)
                    {
                        //超级用户可以更改订单权限
                        if (userRole.RoleID == -1)
                        {
                            model.Flag = true;
                        }
                        else if (userRole.Jurisdictions.Contains(Common.Const.ROLE_ALLORDER_WRITE))
                        {
                            model.Flag = true;
                        }
                        else if (userRole.Jurisdictions.Contains(Common.Const.ROLE_MYORDER_WRITE))
                        {
                            //当前UserID有更改订单权限
                            if (model.CreatorID == this.UserID)
                            {
                                //订单的CreatorID = AccountID 时
                                model.Flag = true;
                            }
                            else if (model.ResponsiblePersonID != 0 && model.ResponsiblePersonID == this.UserID)
                            {
                                //订单的责任人ID = AccountID 时
                                model.Flag = true;
                            }
                            else
                            {
                                //是登陆ACCOUNT的同店下级时
                                List<SubQuery_Model> hierarchy = Account_BLL.Instance.GetHierarchySubQuery_2_2(this.UserID, this.BranchID);
                                if (hierarchy != null && hierarchy.Count > 0)
                                {
                                    foreach (SubQuery_Model item in hierarchy)
                                    {
                                        if (item.SubordinateID == model.ResponsiblePersonID)
                                        {
                                            model.Flag = true;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                    #endregion
                }

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
                groupList = Order_BLL.Instance.getGroupNoList(operationModel.OrderObjectID, operationModel.ProductType);
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
            if (orderinfo.CustomerID == 0)
            {
                res.Message = "请选择顾客";
                return toJson(res);
            }

            orderinfo.Status = 0;
            orderinfo.OrderTime = DateTime.Now.ToLocalTime();
            orderinfo.CreateTime = DateTime.Now.ToLocalTime();
            orderinfo.UpdateTime = DateTime.Now.ToLocalTime();
            orderinfo.CreatorID = this.UserID;
            orderinfo.UpdaterID = orderinfo.CreatorID;
            orderinfo.CompanyID = this.CompanyID;
            orderinfo.IsBusiness = this.IsBusiness;

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
                case "7":
                    res.Message = res.Message;
                    break;
                case "-2":
                    res.Message = "您所购买的产品价格有变动，请确认后重新开单！";
                    break;
                default:
                    res.Message = "订单添加失败!";
                    break;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetOrderInfoList")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"listOrderID":[3,5,4]}
        public HttpResponseMessage GetOrderInfoList(JObject obj)
        {
            ObjectResult<List<OrderInfo_Model>> res = new ObjectResult<List<OrderInfo_Model>>();
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

            UtilityOperation_Model utilityOperationModel = new UtilityOperation_Model();
            utilityOperationModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (utilityOperationModel == null || utilityOperationModel.listOrderID == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityOperationModel.CompanyID = this.CompanyID;

            List<OrderInfo_Model> list = new List<OrderInfo_Model>();
            list = Order_BLL.Instance.getOrderInfoList(utilityOperationModel.CompanyID, utilityOperationModel.listOrderID);

            res.Code = "1";
            res.Message = "success";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("AddTreatGroup")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// 
        public HttpResponseMessage AddTreatGroup(JObject obj)
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

            AddTGOperation_Model addTGModel = new AddTGOperation_Model();
            addTGModel = JsonConvert.DeserializeObject<AddTGOperation_Model>(strSafeJson);

            if (addTGModel == null || addTGModel.TGDetailList == null || addTGModel.TGDetailList.Count <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            addTGModel.CreateTime = DateTime.Now.ToLocalTime();
            addTGModel.CreatorID = this.UserID;
            addTGModel.CompanyID = this.CompanyID;
            addTGModel.BranchID = this.BranchID;

            int code = Order_BLL.Instance.addTG(addTGModel);

            res.Code = code.ToString();
            switch (code)
            {
                case 1:
                    res.Message = "开单成功!";
                    res.Data = true;
                    break;
                case 2:
                    res.Message = "订单状态已变化，请刷新后查看!";
                    res.Data = false;
                    break;
                case 3:
                    res.Message = "请选择服务顾问!";
                    res.Data = false;
                    break;
                case 5:
                    res.Message = "签名失败!";
                    res.Data = false;
                    break;
                case 4:
                    res.Message = "签名图片为空!";
                    res.Data = false;
                    break;
                default:
                    res.Message = "开单失败!";
                    res.Data = false;
                    break;
            }

            return toJson(res);
        }


        [HttpPost]
        [ActionName("UpdateServiceTGTotalCount")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"OrderID":111,"OrderObjectID":111,"Type":0}  0:加一个 1:减一个
        public HttpResponseMessage UpdateServiceTGTotalCount(JObject obj)
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.OrderID <= 0 || utilityModel.OrderObjectID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.UpdaterID = this.UserID;
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;

            int code = Order_BLL.Instance.updateServiceTGTotalCount(utilityModel.CompanyID, utilityModel.OrderID, utilityModel.OrderObjectID, utilityModel.Type, utilityModel.UpdaterID);

            res.Code = code.ToString();
            switch (code)
            {
                case 1:
                    res.Message = "成功!";
                    res.Data = true;
                    break;
                case 2:
                    res.Message = "已有完成的项目,不能更改!";
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

            List<ExecutingOrder_Model> list = Order_BLL.Instance.GetExecutingOrderList(utilityModel);
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

            if (!utilityModel.IsBusiness)
            {
                utilityModel.CustomerID = this.UserID;
            }

            if (utilityModel.ImageWidth <= 0)
            {
                utilityModel.ImageWidth = 160;
            }

            if (utilityModel.ImageHeight <= 0)
            {
                utilityModel.ImageHeight = 160;
            }

            List<UnfinishTG_Model> list = Order_BLL.Instance.GetUnfinishTGList(utilityModel);
            list = list.OrderByDescending(x => x.TGStartTime).ToList<UnfinishTG_Model>();
            res.Code = "1";
            res.Data = list;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetTMListByGroupNo")]
        [HTTPBasicAuthorize]
        ///{"GroupNo":1}
        public HttpResponseMessage GetTMListByGroupNo(JObject obj)
        {
            ObjectResult<List<Treatment>> res = new ObjectResult<List<Treatment>>();
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
            if (utilityModel == null || utilityModel.GroupNo <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.CompanyID = this.CompanyID;

            List<Treatment> treatmentList = new List<Treatment>();
            treatmentList = Order_BLL.Instance.getTreatmentListByGroupNO(utilityModel.GroupNo, utilityModel.CompanyID);
            res.Code = "1";
            res.Data = treatmentList;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("GetMyTodayDoTGList")]
        [HTTPBasicAuthorize]
        //{"ServicePIC":12163,"ProductType": -1,"Status": 0,"FilterByTimeFlag":0,"StartTime":"2012-12-12","EndTime":"2012-12-12","PageIndex":1,"PageSize":10,"CustomerID":0}
        public HttpResponseMessage GetMyTodayDoTGList(JObject obj)
        {
            ObjectResult<GetMyTodayDoTGListRes_Model> res = new ObjectResult<GetMyTodayDoTGListRes_Model>();
            res.Code = "0";
            res.Data = null;
            //if (obj == null)
            //{
            //    res.Message = "不合法参数";
            //    return toJson(res);
            //}
            string strSafeJson = HS.Framework.Common.Util.StringUtils.GetDbString(obj);
            //if (string.IsNullOrEmpty(strSafeJson))
            //{
            //    res.Message = "不合法参数";
            //    return toJson(res);
            //}

            TodayTGOperation_Model operationModel = new TodayTGOperation_Model();
            operationModel = JsonConvert.DeserializeObject<TodayTGOperation_Model>(strSafeJson);
            //if (utilityModel == null)
            //{
            //    res.Message = "不合法参数";
            //    return toJson(res);
            //}

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

            if (operationModel.ServicePIC <= 0)
            {
                operationModel.ServicePIC = this.UserID;
            }
            operationModel.CompanyID = this.CompanyID;
            operationModel.BranchID = this.BranchID;
            int recordCount = 0;


            GetMyTodayDoTGListRes_Model model = new GetMyTodayDoTGListRes_Model();

            List<GetMyTodayDoTGList_Model> list = Order_BLL.Instance.GetMyTodayDoTGList(operationModel, out recordCount);

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
                model.TGList = list;
                res.Data = model;
                res.Code = "1";
            }

            return toJson(res, "yyyy-MM-dd HH:mm:ss.ff");
        }

        [HttpPost]
        [ActionName("CompleteOrder")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"OrderID":123 ,"OrderObjectID""123}  
        public HttpResponseMessage CompleteOrder(JObject obj)
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.OrderID <= 0 || utilityModel.OrderObjectID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.UpdaterID = this.UserID;
            utilityModel.Time = DateTime.Now.ToLocalTime();
            utilityModel.CompanyID = this.CompanyID;

            if (!this.IsBusiness)
            {
                utilityModel.CustomerID = this.UserID;
            }

            int code = Order_BLL.Instance.CompleteOrderObject(utilityModel);

            res.Code = code.ToString();
            switch (code)
            {
                case 1:
                    res.Message = "成功!";
                    res.Data = true;
                    break;
                case 2:
                    res.Message = "订单不能被完成!";
                    res.Data = false;
                    break;
                case 3:
                    res.Message = "订单状态已变化，请刷新后查看!";
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
        [ActionName("CompleteTreatGroup")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"SignImg":"图片流","ImageFormat":".jpg","CustomerID":123 ,"TGDetailList":[{"OrderType":0,"OrderID":123,"OrderObjectID":123,"GroupNo":123456789}]}  
        public HttpResponseMessage CompleteTreatGroup(JObject obj)
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

            if (utilityModel == null || utilityModel.TGDetailList == null || utilityModel.TGDetailList.Count <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.UpdaterID = this.UserID;
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;
            utilityModel.UpdateTime = DateTime.Now.ToLocalTime();
            if (!this.IsBusiness)
            {
                utilityModel.CustomerID = this.UserID;
            }

            int code = Order_BLL.Instance.CompleteTreatGroup(utilityModel);

            res.Code = code.ToString();
            switch (code)
            {
                case 1:
                    res.Message = "成功!";
                    res.Data = true;
                    break;
                case 2:
                    res.Message = "订单状态已变化，请刷新后查看!";
                    res.Data = false;
                    break;
                case 3:
                    res.Message = "签名失败!";
                    res.Data = false;
                    break;
                case 4:
                    res.Message = "签名图片为空!";
                    res.Data = false;
                    break;
                case -2:
                    res.Message = "不合法参数";
                    res.Data = false;
                    break;
                default:
                    res.Message = "订单状态已变化，请刷新后查看!";
                    res.Data = false;
                    break;
            }

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
        [ActionName("CompleteTreatment")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"TreatmentID":123,"CustomerID":123}  
        public HttpResponseMessage CompleteTreatment(JObject obj)
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

            UtilityOperation_Model utilityModel = new UtilityOperation_Model();
            utilityModel = JsonConvert.DeserializeObject<UtilityOperation_Model>(strSafeJson);

            if (utilityModel == null || utilityModel.TreatmentID <= 0 || utilityModel.CustomerID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.UpdaterID = this.UserID;
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.Time = DateTime.Now.ToLocalTime();

            int code = Order_BLL.Instance.CompleteTreatment(utilityModel);

            res.Code = code.ToString(); //状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
            switch (code)
            {
                case 1:
                    res.Message = "成功!";
                    res.Data = true;
                    break;
                case 2:
                    res.Message = "已经完成的服务不能再次完成!";
                    res.Data = false;
                    break;
                case 3:
                    res.Message = "已取消的服务不能完成!";
                    res.Data = false;
                    break;
                case 4:
                    res.Message = "已终止的服务不能完成!";
                    res.Data = false;
                    break;
                case 5:
                    res.Message = "完成待确认的服务不能完成!";
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
        [ActionName("CancelTreatment")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"TreatmentID":123,"OrderObjectID":123,"GroupNo":12346}  
        public HttpResponseMessage CancelTreatment(JObject obj)
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

            if (utilityModel == null || utilityModel.TreatmentID <= 0 || utilityModel.OrderObjectID <= 0 || utilityModel.GroupNo <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.CompanyID = this.CompanyID;
            utilityModel.UpdaterID = this.UserID;
            utilityModel.Time = DateTime.Now.ToLocalTime();

            //if (!RoleCheck_BLL.Instance.checkOrderUpdaterRole(utilityModel))
            //{
            //    res.Message = "操作失败！请确认权限！";
            //    return toJson(res);
            //}

            int code = Order_BLL.Instance.CancelTreatment(utilityModel);

            res.Code = code.ToString(); //状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
            switch (code)
            {
                case 1:
                    res.Message = "成功!";
                    res.Data = true;
                    break;
                case 2:
                    res.Message = "完成的服务不能取消!";
                    res.Data = false;
                    break;
                case 3:
                    res.Message = "已取消的服务不能再取消!";
                    res.Data = false;
                    break;
                case 4:
                    res.Message = "已终止的服务不能取消!";
                    res.Data = false;
                    break;
                case 5:
                    res.Message = "完成待确认的服务不能取消!";
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
        [ActionName("UpdateTMDesignated")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"TreatmentID":123,"OrderObjectID":123,"GroupNo":12346,"IsDesignated":true}  
        public HttpResponseMessage UpdateTMDesignated(JObject obj)
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

            if (utilityModel == null || utilityModel.TreatmentID <= 0 || utilityModel.OrderObjectID <= 0 || utilityModel.GroupNo <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.CompanyID = this.CompanyID;
            utilityModel.UpdaterID = this.UserID;
            utilityModel.Time = DateTime.Now.ToLocalTime();

            int code = Order_BLL.Instance.UpdateTMDesignated(utilityModel);

            res.Code = code.ToString(); //状态：1：进行中 2：已完成 3：已取消 4:已终止 5完成待确认
            switch (code)
            {
                case 1:
                    res.Message = "修改指定成功!";
                    res.Data = true;
                    break;
                case 0:
                    res.Message = "失败!";
                    res.Data = false;
                    break;
                default:
                    res.Message = "当前状态不能修改指定!";
                    res.Data = false;
                    break;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("CancelTreatGroup")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"TGDetailList":[{"OrderType":0,"OrderID":123,"OrderObjectID":123,"GroupNo":123456789}]}  
        public HttpResponseMessage CancelTreatGroup(JObject obj)
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

            if (utilityModel == null || utilityModel.TGDetailList == null || utilityModel.TGDetailList.Count <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.UpdaterID = this.UserID;
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.BranchID = this.BranchID;
            utilityModel.UpdateTime = DateTime.Now.ToLocalTime(); ;

            int code = Order_BLL.Instance.CancelTreatGroup(utilityModel);

            res.Code = code.ToString();
            switch (code)
            {
                case 1:
                    res.Message = "成功!";
                    res.Data = true;
                    break;
                case 2:
                    res.Message = "有已经完成的服务,不能取消!";
                    res.Data = false;
                    break;
                case -2:
                    res.Message = "不合法参数";
                    res.Data = false;
                    break;
                default:
                    res.Message = "订单状态已变化，请刷新后查看!";
                    res.Data = false;
                    break;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("UpdateOrderRemark")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"OrderObjectID": 0,"ProductType":0,"Remark":"123123","OrderID":123}
        public HttpResponseMessage UpdateOrderRemark(JObject obj)
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

            if (utilityModel == null || utilityModel.OrderID <= 0 || utilityModel.OrderObjectID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.UpdaterID = this.UserID;
            utilityModel.Time = DateTime.Now.ToLocalTime();
            utilityModel.CompanyID = this.CompanyID;

            bool result = Order_BLL.Instance.updateOrderRemark(utilityModel);
            if (!result)
            {
                res.Message = "订单状态更新失败！";
                return toJson(res);
            }

            res.Code = "1";
            res.Message = "更新订单状态成功！";
            res.Data = true;
            return toJson(res);
        }

        [HttpPost]
        [ActionName("UpdateExpirationTime")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"OrderObjectID": 123,"ExpirationTime":"2014-12-08"}
        public HttpResponseMessage UpdateExpirationTime(JObject obj)
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

            if (utilityModel == null || utilityModel.OrderObjectID <= 0 || utilityModel.ExpirationTime == null)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.AccountID = this.UserID;
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.UpdaterID = this.UserID;
            utilityModel.BranchID = this.BranchID;
            utilityModel.Time = DateTime.Now.ToLocalTime();

            //if (!RoleCheck_BLL.Instance.checkOrderUpdaterRole(utilityModel))
            //{
            //    res.Message = "操作失败！请确认权限！";
            //    return toJson(res);
            //}

            int code = Order_BLL.Instance.UpdateExpirationTime(utilityModel);
            res.Code = code.ToString();
            switch (code)
            {
                case 1:
                    res.Message = "修改有效期成功!";
                    res.Data = true;
                    break;
                case 0:
                    res.Message = "失败!";
                    res.Data = false;
                    break;
                default:
                    res.Message = "当前状态不能修改有效期!";
                    res.Data = false;
                    break;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("UpdateTGDesignated")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"OrderObjectID": 123,"IsDesignated":true,"GroupNo":123123123}
        public HttpResponseMessage UpdateTGDesignated(JObject obj)
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

            if (utilityModel == null || utilityModel.GroupNo <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.AccountID = this.UserID;
            utilityModel.CompanyID = this.CompanyID;
            utilityModel.UpdaterID = this.UserID;
            utilityModel.BranchID = this.BranchID;
            utilityModel.Time = DateTime.Now.ToLocalTime();

            //if (!RoleCheck_BLL.Instance.checkOrderUpdaterRole(utilityModel))
            //{
            //    res.Message = "操作失败！请确认权限！";
            //    return toJson(res);
            //}

            int code = Order_BLL.Instance.UpdateTGDesignated(utilityModel);
            res.Code = code.ToString();
            switch (code)
            {
                case 1:
                    res.Message = "修改指定成功!";
                    res.Data = true;
                    break;
                case 0:
                    res.Message = "失败!";
                    res.Data = false;
                    break;
                default:
                    res.Message = "当前状态不能修改指定!";
                    res.Data = false;
                    break;
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("UpdateResponsiblePerson")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"OrderObjectID": 0,"ProductType":0,"ResponsiblePersonID":123,"OrderID":123}
        public HttpResponseMessage UpdateResponsiblePerson(JObject obj)
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

            if (utilityModel == null || utilityModel.OrderID <= 0 || utilityModel.OrderObjectID <= 0 || utilityModel.ResponsiblePersonID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.UpdaterID = this.UserID;
            utilityModel.Time = DateTime.Now.ToLocalTime();
            utilityModel.CompanyID = this.CompanyID;

            int code = Order_BLL.Instance.updateResponsiblePerson(utilityModel);
            res.Code = code.ToString();
            switch (code)
            {
                case 1:
                    res.Message = "修改成功!";
                    res.Data = true;
                    break;
                case 0:
                    res.Message = "失败!";
                    res.Data = false;
                    break;
                default:
                    res.Message = "当前状态不能修改!";
                    res.Data = false;
                    break;
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("DeleteOrder")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"OrderID": 0}
        public HttpResponseMessage DeleteOrder(JObject obj)
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

            if (utilityModel == null || utilityModel.OrderID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.IsBusiness = this.IsBusiness;
            utilityModel.AccountID = this.UserID;
            utilityModel.UpdaterID = utilityModel.AccountID;
            utilityModel.BranchID = this.BranchID;
            utilityModel.CompanyID = this.CompanyID;
            if (this.IsBusiness)
            {
                #region 检查美容师权限
                //检查操作人的权限
                if (!RoleCheck_BLL.Instance.checkOrderUpdaterRole(utilityModel))
                {
                    res.Message = "操作失败!请确认权限!";
                    return toJson(res);
                }
                #endregion
            }
            else
            {
                #region 检查是否是顾客订单
                if (!RoleCheck_BLL.Instance.checkIsCustomerOrder(utilityModel.UpdaterID, utilityModel.OrderID))
                {
                    res.Message = "操作失败!请确认权限!";
                    return toJson(res);
                }
                #endregion
            }

            DateTime dt = DateTime.Now.ToLocalTime();

            res = Order_BLL.Instance.deleteOrder(utilityModel.CompanyID, utilityModel.OrderID, utilityModel.OrderObjectID, utilityModel.ProductType, utilityModel.DeleteType, utilityModel.UpdaterID);

            //switch (res.Code)
            //{
            //    case "1":
            //        res.Message = "订单取消成功!";
            //        res.Data = true;
            //        break;
            //    case "3":
            //        res.Message = "订单下已有完成的服务，不能取消！";
            //        res.Data = false;
            //        break;
            //    case "2":
            //        res.Message = res.Message;
            //        res.Data = false;
            //        break;
            //    default:
            //        res.Message = "订单取消失败!";
            //        res.Data = false;
            //        break;
            //}

            return toJson(res);
        }


        [HttpPost]
        [ActionName("UpdateTotalSalePrice")]
        [HTTPBasicAuthorize]
        /// chen
        ///{"OrderID,":2479,"totalSalePrice":0,"OrderObjectID":80,"UserCardNo":"1507080000000003"}
        public HttpResponseMessage UpdateTotalSalePrice(JObject obj)
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

            if (utilityModel == null || utilityModel.OrderID <= 0 || utilityModel.TotalSalePrice < 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.AccountID = this.UserID;
            utilityModel.UpdaterID = utilityModel.AccountID;
            utilityModel.BranchID = this.BranchID;

            if (this.IsBusiness)
            {
                #region 检查美容师权限
                //检查操作人的权限
                if (!RoleCheck_BLL.Instance.checkOrderUpdaterRole(utilityModel))
                {
                    res.Message = "操作失败!请确认权限!";
                    return toJson(res);
                }
                #endregion
            }

            DateTime dt = DateTime.Now.ToLocalTime();

            res = Order_BLL.Instance.UpdateTotalSalePrice(utilityModel.UpdaterID, utilityModel.OrderID, utilityModel.TotalSalePrice, dt, utilityModel.OrderObjectID, utilityModel.UserCardNo, this.CompanyID, utilityModel.ProductType, this.BranchID);

            switch (res.Code)
            {
                case "1":
                    res.Message = "修改订单价格成功!";
                    res.Data = true;
                    break;
                case "2":
                    res.Message = res.Message;
                    res.Data = false;
                    break;
                default:
                    res.Message = "修改订单价格失败!";
                    res.Data = false;
                    break;
            }

            return toJson(res);
        }

        [HttpPost]
        [ActionName("UpdateTreatmentExecutorID")]
        [HTTPBasicAuthorize]
        /// chen
        /// {"TreatmentID": 12284,"ExecutorID":11720,"OrderID":2471}
        public HttpResponseMessage UpdateTreatmentExecutorID(JObject obj)
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

            if (utilityModel == null || utilityModel.TreatmentID <= 0 || utilityModel.ExecutorID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.CompanyID = this.CompanyID;
            utilityModel.UpdaterID = this.UserID;
            utilityModel.BranchID = this.BranchID;
            utilityModel.Time = DateTime.Now.ToLocalTime();
            utilityModel.AccountID = this.UserID;

            if (!RoleCheck_BLL.Instance.checkOrderUpdaterRole(utilityModel))
            {
                res.Message = "操作失败！请确认权限！";
                return toJson(res);
            }


            res = Order_BLL.Instance.updateTreatmentExecutorID(utilityModel);


            switch (res.Code)
            {
                case "1":
                    res.Message = "修改操作人成功!";
                    res.Data = true;
                    break;
                case "2":
                    res.Message = res.Message;
                    res.Data = false;
                    break;
                default:
                    res.Message = "修改操作人失败!";
                    res.Data = false;
                    break;
            }
            return toJson(res);
        }



        [HttpPost]
        [ActionName("UpdateTGServicePIC")]
        [HTTPBasicAuthorize]
        /// chen
        ///  {"GroupNo": 1507100000000007,"ServicePIC":11720,"OrderID":2471}
        public HttpResponseMessage UpdateTGServicePIC(JObject obj)
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

            if (utilityModel == null || utilityModel.GroupNo <= 0 || utilityModel.ServicePIC <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.CompanyID = this.CompanyID;
            utilityModel.UpdaterID = this.UserID;
            utilityModel.BranchID = this.BranchID;
            utilityModel.Time = DateTime.Now.ToLocalTime();
            utilityModel.AccountID = this.UserID;

            if (!RoleCheck_BLL.Instance.checkOrderUpdaterRole(utilityModel))
            {
                res.Message = "操作失败！请确认权限！";
                return toJson(res);
            }


            res = Order_BLL.Instance.updateTGServicePIC(utilityModel);


            switch (res.Code)
            {
                case "1":
                    res.Message = "修改服务顾问成功!";
                    res.Data = true;
                    break;
                case "2":
                    res.Message = res.Message;
                    res.Data = false;
                    break;
                default:
                    res.Message = "修改服务顾问失败!";
                    res.Data = false;
                    break;
            }
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

            if (!RoleCheck_BLL.Instance.checkOrderUpdaterRole(utilityModel))
            {
                res.Message = "操作失败！请确认权限！";
                return toJson(res);
            }


            GetTGDetail_Model model = Order_BLL.Instance.getTGDetail(utilityModel.GroupNo, this.CompanyID, utilityModel.ImageWidth, utilityModel.ImageHeight);


            res.Code = "1";
            res.Data = model;
            return toJson(res);
        }



        [HttpPost]
        [ActionName("UpdateTGRemark")]
        [HTTPBasicAuthorize]
        /// chen
        /// {"GroupNo": 1507100000000007,"Remark":"11720","OrderID":2471}
        public HttpResponseMessage UpdateTGRemark(JObject obj)
        {
            ObjectResult<bool> res = new ObjectResult<bool>();
            res.Code = "0";
            res.Message = "修改备注失败";
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

            if (utilityModel == null || utilityModel.GroupNo <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }


            utilityModel.CompanyID = this.CompanyID;
            utilityModel.UpdaterID = this.UserID;
            utilityModel.BranchID = this.BranchID;
            utilityModel.Time = DateTime.Now.ToLocalTime();
            utilityModel.AccountID = this.UserID;

            if (!RoleCheck_BLL.Instance.checkOrderUpdaterRole(utilityModel))
            {
                res.Message = "操作失败！请确认权限！";
                return toJson(res);
            }

            bool result = Order_BLL.Instance.updateTGRemark(utilityModel);

            if (result)
            {

                res.Code = "1";
                res.Data = true;
                res.Message = "修改成功!";
            }
            return toJson(res);
        }

        [HttpPost]
        [ActionName("UpdateTreatmentRemark")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"TreatmentID": 0,"Remark":"fssdfsfd"}
        public HttpResponseMessage UpdateTreatmentRemark(JObject obj)
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

            if (utilityModel == null || utilityModel.TreatmentID <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            utilityModel.CompanyID = this.CompanyID;
            utilityModel.UpdaterID = this.UserID;
            utilityModel.Time = DateTime.Now.ToLocalTime();

            bool result = Order_BLL.Instance.updateTreatmentRemark(utilityModel);
            if (!result)
            {
                res.Message = "服务备注更新失败！";
                return toJson(res);
            }

            res.Code = "1";
            res.Message = "";
            res.Data = true;
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

            if (!RoleCheck_BLL.Instance.checkOrderUpdaterRole(utilityModel))
            {
                res.Message = "操作失败！请确认权限！";
                return toJson(res);
            }

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
        [ActionName("UpdateOrderCustomerID")]
        [HTTPBasicAuthorize]
        /// Aaron.Han
        /// {"List":[{"OrderID":2655,"OrderObjectID":185,"ProductType":0,"CustomerID":11722}]}
        public HttpResponseMessage UpdateOrderCustomerID(JObject obj)
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

            OrderUpdateCustomerIDListOperation_Model utilityList = new OrderUpdateCustomerIDListOperation_Model();
            utilityList = JsonConvert.DeserializeObject<OrderUpdateCustomerIDListOperation_Model>(strSafeJson);

            if (utilityList == null || utilityList.List == null || utilityList.List.Count <= 0)
            {
                res.Message = "不合法参数";
                return toJson(res);
            }

            int code = Order_BLL.Instance.updateOrderCustomerID(this.CompanyID, this.BranchID, this.UserID, utilityList.List);
            res.Code = code.ToString();
            switch (code)
            {
                case 1:
                    res.Message = "修改成功!";
                    res.Data = true;
                    break;
                case 2:
                    res.Message = "已支付的订单不能更改顾客!";
                    res.Data = true;
                    break;
                case 0:
                    res.Message = "失败!";
                    res.Data = false;
                    break;
                default:
                    res.Message = "当前状态不能修改!";
                    res.Data = false;
                    break;
            }
            return toJson(res);
        }
    }
}
