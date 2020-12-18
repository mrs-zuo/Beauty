using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class Order_BLL
    {
        #region 构造类实例
        public static Order_BLL Instance
        {
            get
            {
                return Nested.instance;
            }
        }

        class Nested
        {
            static Nested()
            {
            }
            internal static readonly Order_BLL instance = new Order_BLL();
        }
        #endregion

        public GetOrderCount_Model getOrderCount(OrderCountOperation_Model model)
        {
            GetOrderCount_Model res = Order_DAL.Instance.getOrderCount(model);
            return res;
        }

        public List<GetUnconfirmedOrderList_Model> getUnconfirmedOrderList(int customerId)
        {
            List<GetUnconfirmedOrderList_Model> list = Order_DAL.Instance.getUnconfirmedOrderList(customerId);
            return list;
        }

        public GetCourseAndTreatmentNumber_Model getCourseAndTreatmentNumber(int treatmentId)
        {
            GetCourseAndTreatmentNumber_Model model = Order_DAL.Instance.getCourseAndTreatmentNumber(treatmentId);
            return model;
        }

        public int selectOrderStatus(int orderId)
        {
            int res = Order_DAL.Instance.selectOrderStatus(orderId);
            return res;
        }

        public bool checkOrderListStatus(List<ConfirmOrderList> list)
        {
            foreach (ConfirmOrderList item in list)
            {
                int res = Order_DAL.Instance.selectOrderStatus(item.ID);
                if (res != 1)
                {
                    return false;
                }

                int res2 = Order_DAL.Instance.selectTreatmentStatusForConfirm(item.TreatmentID);
                if (res != 1)
                {
                    return false;
                }

            }
            return true;
        }

        public int confirmOrder(ConfirmOrderOperation_Model model)
        {
            int res = Order_DAL.Instance.confirmOrder(model);
            return res;
        }

        public bool addTreatment(TreatmentAddOperation_Model model)
        {
            bool res = Order_DAL.Instance.addTreatment(model);
            return res;
        }

        //public int deleteTreatment(TreatmentDelOperation_Model model)
        //{
        //    int res = Order_DAL.Instance.deleteTreatment(model);
        //    return res;
        //}

        public int selectScheduleStatus(int scheduleId)
        {
            int res = Order_DAL.Instance.selectScheduleStatus(scheduleId);
            return res;
        }

        public int CanCancelScheduleStatus(int scheduleId)
        {
            int res = Order_DAL.Instance.CanCancelScheduleStatus(scheduleId);
            return res;
        }

        public bool updateTreatmentDetail(UtilityOperation_Model model)
        {
            bool res = Order_DAL.Instance.updateTreatmentDetail(model);
            return res;
        }

        public bool completeOrder(UtilityOperation_Model model)
        {
            bool res = Order_DAL.Instance.completeOrder(model);
            return res;
        }

        public ObjectResult<bool> UpdateOrderIsAddUp(int orderID, bool isAddUp, int updaterID)
        {
            ObjectResult<bool> res = Order_DAL.Instance.UpdateOrderIsAddUp(orderID, isAddUp, updaterID);
            return res;
        }

        public bool completeTrearmentsByCourseID(CompleteTrearmentsByCourseIDOperation_Model model)
        {
            bool res = Order_DAL.Instance.completeTrearmentsByCourseID(model);
            return res;
        }

        //public int completeBeforeTreatmentByGroupNO(CompleteTrearmentsByCourseIDOperation_Model model)
        //{
        //    return Order_DAL.Instance.completeBeforeTreatmentByGroupNO(model);
        //}

        //public int completeTreatmentByGroupNO(CompleteTrearmentsByCourseIDOperation_Model model)
        //{
        //    int res = Order_DAL.Instance.completeTreatmentByGroupNO(model);
        //    return res;
        //}


        public GetEcardInfo_Model getEcardInfo(int customerId)
        {
            GetEcardInfo_Model model = Order_DAL.Instance.getEcardInfo(customerId);
            return model;
        }


        //////////////////////////////////////////////////////////////////////////////////////////////////////


        public List<GetOrderList_Model> getOrderList(GetOrderListOperation_Model operationModel, int pageSize, int pageIndex, out int recordCount)
        {
            List<GetOrderList_Model> list = Order_DAL.Instance.getOrderList(operationModel, pageSize, pageIndex, out recordCount);
            return list;
        }

        public GetOrderDetail_Model getOrderDetail(int orderObjectID, int productType, int CompanyID)
        {
            GetOrderDetail_Model model = Order_DAL.Instance.getOrderDetail(orderObjectID, productType, CompanyID);
            return model;
        }

        public List<Group> getGroupNoList(int orderObjectID, int productType, int status = 0)
        {
            List<Group> list = Order_DAL.Instance.getGroupNoList(orderObjectID, productType, status);
            return list;
        }

        public List<Treatment> getTreatmentListByGroupNO(long groupNO, int CompanyID)
        {
            List<Treatment> list = Order_DAL.Instance.getTreatmentListByGroupNO(groupNO, CompanyID);
            return list;
        }

        public ObjectResult<List<int>> addNewOrder(OrderOperation_Model model)
        {
            ObjectResult<List<int>> res = Order_DAL.Instance.addNewOrder(model);
            return res;
        }

        public List<OrderInfo_Model> getOrderInfoList(int companyID, List<int> orderIDList)
        {
            List<OrderInfo_Model> list = Order_DAL.Instance.getOrderInfoList(companyID, orderIDList);
            return list;
        }

        public int addTG(AddTGOperation_Model model)
        {
            int res = Order_DAL.Instance.addTG(model);
            return res;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="copmanyID"></param>
        /// <param name="orderID"></param>
        /// <param name="courseID"></param>
        /// <param name="type">0:加一个 1:减一个</param>
        /// <param name="updaterID"></param>
        /// <returns></returns>
        public int updateServiceTGTotalCount(int copmanyID, int orderID, int orderObjectID, int type, int updaterID)
        {
            int res = Order_DAL.Instance.updateServiceTGTotalCount(copmanyID, orderID, orderObjectID, type, updaterID);
            return res;
        }

        public List<ExecutingOrder_Model> GetExecutingOrderList(UtilityOperation_Model model)
        {
            List<ExecutingOrder_Model> list = Order_DAL.Instance.GetExecutingOrderList(model);
            return list;
        }

        public List<UnfinishTG_Model> GetUnfinishTGList(UtilityOperation_Model model)
        {
            List<UnfinishTG_Model> list = Order_DAL.Instance.GetUnfinishTGList(model);
            return list;
        }

        public List<GetMyTodayDoTGList_Model> GetMyTodayDoTGList(TodayTGOperation_Model model, out int recordCount)
        {
            List<GetMyTodayDoTGList_Model> list = Order_DAL.Instance.GetMyTodayDoTGList(model, out recordCount);
            //if (list != null && list.Count > 0)
            //{
            //    list = list.OrderByDescending(c => c.TGStartTime).ToList();
            //}
            return list;
        }

        public int CompleteOrderObject(UtilityOperation_Model model)
        {
            int res = Order_DAL.Instance.CompleteOrderObject(model);
            return res;
        }

        public int CompleteTreatGroup(CompleteTGOperation_Model model)
        {
            int res = Order_DAL.Instance.CompleteTreatGroup(model);
            return res;
        }

        public int ConfirmTreatGroup(CompleteTGOperation_Model model)
        {
            int res = Order_DAL.Instance.ConfirmTreatGroup(model);
            return res;
        }

        public int CompleteTreatment(UtilityOperation_Model model)
        {
            int res = Order_DAL.Instance.CompleteTreatment(model);
            return res;
        }

        public int CancelTreatment(UtilityOperation_Model model)
        {
            int res = Order_DAL.Instance.CancelTreatment(model);
            return res;
        }

        public int UpdateTMDesignated(UtilityOperation_Model model)
        {
            int res = Order_DAL.Instance.UpdateTMDesignated(model);
            return res;
        }

        public int CancelTreatGroup(CompleteTGOperation_Model model)
        {
            int res = Order_DAL.Instance.CancelTreatGroup(model);
            return res;
        }

        public bool updateOrderRemark(UtilityOperation_Model orderModel)
        {
            bool res = Order_DAL.Instance.updateOrderRemark(orderModel);
            return res;
        }

        public int UpdateExpirationTime(UtilityOperation_Model model)
        {
            int res = Order_DAL.Instance.UpdateExpirationTime(model);
            return res;
        }

        public int UpdateTGDesignated(UtilityOperation_Model model)
        {
            int res = Order_DAL.Instance.UpdateTGDesignated(model);
            return res;
        }

        public int updateResponsiblePerson(UtilityOperation_Model orderModel)
        {
            int res = Order_DAL.Instance.updateResponsiblePerson(orderModel);
            return res;
        }

        public ObjectResult<bool> deleteOrder(int CompanyID, int OrderID, int ObjectID, int ProductType, int DeleteType, int updaterId)
        {
            ObjectResult<bool> res = Order_DAL.Instance.deleteOrder(CompanyID, OrderID, ObjectID, ProductType, DeleteType, updaterId);
            return res;
        }

        public ObjectResult<bool> UpdateTotalSalePrice(int updaterId, int orderId, decimal totalSalePrice, DateTime dt, int OrderObjectID, string UserCardNo, int CompanyID, int ProductType, int BranchID)
        {
            ObjectResult<bool> res = Order_DAL.Instance.UpdateTotalSalePrice(updaterId, orderId, totalSalePrice, dt, OrderObjectID, UserCardNo, CompanyID, ProductType, BranchID);
            return res;
        }


        public ObjectResult<bool> updateTreatmentExecutorID(UtilityOperation_Model model)
        {
            ObjectResult<bool> res = Order_DAL.Instance.updateTreatmentExecutorID(model);
            return res;

        }


        public ObjectResult<bool> updateTGServicePIC(UtilityOperation_Model model)
        {
            ObjectResult<bool> res = Order_DAL.Instance.updateTGServicePIC(model);
            return res;
        }

        public GetTGDetail_Model getTGDetail(long GroupNo, int companyId, int imageWidth, int imageHeight)
        {
            return Order_DAL.Instance.getTGDetail(GroupNo, companyId,  imageWidth,  imageHeight);
        }


        public bool updateTGRemark(UtilityOperation_Model model)
        {
            return Order_DAL.Instance.updateTGRemark(model);
        }

        public bool updateTreatmentRemark(UtilityOperation_Model model)
        {
            bool res = Order_DAL.Instance.updateTreatmentRemark(model);
            return res;
        }

        public GetTreatmentDetail_Model GetTreatmentDetail(UtilityOperation_Model model)
        {
            return Order_DAL.Instance.GetTreatmentDetail(model);
        }

        public int updateOrderCustomerID(int companyID, int branchID, int updaterID, List<OrderUpdateCustomerIDOperation_Model> list)
        {
            int res = Order_DAL.Instance.updateOrderCustomerID(companyID, branchID, updaterID, list);
            return res;
        }

        #region WEB方法
        public OrderDetailForWeb_Model getOrderDetailForWeb(string OrderCode, int CompanyID, int BranchID)
        {
            if (OrderCode.Length != 12)
                return null;

            int OrderID = StringUtils.GetDbInt(OrderCode.Substring(4, 6));
            OrderDetailForWeb_Model model = null;
            if (OrderID > 0)
                model = Order_DAL.Instance.getOrderDetailForWeb(OrderID, CompanyID, BranchID);

            if (model != null)
            {
                model.accountList = Account_DAL.Instance.getAccountListForOrderEdit(OrderID);
                model.OrderCode = OrderCode;

                //if (selectTreatment)
                //{
                //    model.CourseList = Order_DAL.Instance.getCourseListForWeb(OrderID);
                //}
                return model;
            }
            else
                return null;
        }

        public int updateOrder(OrderDetailOperationForWeb_Model model, out string message)
        {
            if (model.OrderCode.Length != 12)
            {
                message = "请输入正确的12位订单号";
                return -1;
            }

            model.OrderID = StringUtils.GetDbInt(model.OrderCode.Substring(4, 6));
            return Order_DAL.Instance.updateOrder(model, out message);
        }

        public ObjectResult<bool> cancelOrder(string OrderCode, int UpdaterID, int CompanyID, int BranchID)
        {
            ObjectResult<bool> result = new ObjectResult<bool>();
            result.Code = "0";
            result.Data = false;
            result.Message = "操作失败";

            if (OrderCode.Length != 12)
                return result;
            int OrderID = StringUtils.GetDbInt(OrderCode.Substring(4, 6));

            if (OrderID > 0)
                return Order_DAL.Instance.cancelOrder(OrderID, UpdaterID, CompanyID, BranchID);
            else
                return result;
        }

        public TreatmentDetailForWeb_Model getTreatmentDetailForWeb(string TreatmentCode)
        {
            if (TreatmentCode.Length != 14)
                return null;

            int TreatmentID = StringUtils.GetDbInt(TreatmentCode.Substring(4, 8));
            TreatmentDetailForWeb_Model model = null;
            if (TreatmentID > 0)
                model = Order_DAL.Instance.getTreatmentDetailForWeb(TreatmentID);
            if (model != null)
            {
                model.TreatmentCode = TreatmentCode;
                return model;
            }
            else
                return null;
        }

        public bool cancelCompletedSchedule(string TreatmentCode, int UpdaterID)
        {
            if (TreatmentCode.Length != 14)
                return false;
            int TreatmentID = StringUtils.GetDbInt(TreatmentCode.Substring(4, 8));

            if (TreatmentID > 0)
                return Order_DAL.Instance.cancelCompletedSchedule(TreatmentID, UpdaterID);
            else
                return false;
        }

        public List<Payment_ForOrder> GetPaymentListByOrderID(string OrderCode)
        {
            if (string.IsNullOrEmpty(OrderCode) || OrderCode.Length != 12)
                return null;
            int OrderID = StringUtils.GetDbInt(OrderCode.Substring(4, 6));
            if (OrderID <= 0)
                return null;
            return Order_DAL.Instance.GetPaymentListByOrderID(OrderID);
        }

        public GetGroupInfoForWeb_Model GetGroupInfoForWeb(long groupNO, int CompanyID,int branchID)
        {
            string GroupNo = groupNO.ToString();
            if (string.IsNullOrEmpty(GroupNo) || GroupNo.Length != 16)
                return null;
            if (groupNO <= 0)
                return null;
            GetGroupInfoForWeb_Model model = Order_DAL.Instance.GetGroupInfoForWeb(groupNO, CompanyID, branchID);
            if (model != null)
            {
                model.AccountList = Account_DAL.Instance.getAccountListForOrderEdit(model.OrderID);
            }
            return model;
        }

        public GetCommodityDelivery_Model GetCommodityDeliveryInfoForWeb(string DeliveryCode, int CompanyID,int BranchID)
        {
            long DeliveryID = StringUtils.GetDbLong(DeliveryCode);
            if (DeliveryID <= 0)
            {
                return null;
            }
            GetCommodityDelivery_Model model = Order_DAL.Instance.GetCommodityDeliveryInfoForWeb(DeliveryID, CompanyID,BranchID);
            if (model != null)
            {
                model.DeliveryCode = DeliveryCode;
                model.AccountList = Account_DAL.Instance.getAccountListForOrderEdit(model.OrderID);
            }
            return model;
        }

        public int EditDelivery(CommodityDeliveryOperation_Model model)
        {
            long DeliveryID = StringUtils.GetDbLong(model.DeliveryCode);
            if (DeliveryID <= 0)
            {
                return -2;
            }
            model.DeliveryID = DeliveryID;
            int result = Order_DAL.Instance.EditDelivery(model);

            return result;
        }
        public int CancelDelivey(CommodityDeliveryOperation_Model model)
        {
            long DeliveryID = StringUtils.GetDbLong(model.DeliveryCode);
            if (DeliveryID <= 0)
            {
                return -2;
            }

            model.DeliveryID = DeliveryID;
            int result = Order_DAL.Instance.CancelDelivey(model);

            return result;
        }

        public int CancelTGForWeb(EditTGForWebOperation_Model model)
        {
            string GroupNo = model.GroupNo.ToString();
            if (string.IsNullOrEmpty(GroupNo) || GroupNo.Length != 16)
                return -2;
            if (model.GroupNo <= 0)
                return -2;

            int result = Order_DAL.Instance.CancelTGForWeb(model);

            return result;
        }

        public int EditTGForWeb(EditTGForWebOperation_Model model)
        {
            string GroupNo = model.GroupNo.ToString();
            if (string.IsNullOrEmpty(GroupNo) || GroupNo.Length != 16)
                return -2;
            if (model.GroupNo <= 0)
                return -2;

            int result = Order_DAL.Instance.EditTGForWeb(model);

            return result;
        }


        #endregion
    }
}
