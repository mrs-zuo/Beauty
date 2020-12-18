using ClientAPI.DAL;
using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.BLL
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

        public List<TGList_Model> GetUnconfirmTreatGroup(int companyID, int customerID, int type = -1)
        {
            List<TGList_Model> list = Order_DAL.Instance.GetUnconfirmTreatGroup(companyID, customerID, type);
            return list;
        }

        public int ConfirmTreatGroup(CompleteTGOperation_Model model)
        {
            int res = Order_DAL.Instance.ConfirmTreatGroup(model);
            return res;
        }

        public GetOrderCount_Model getOrderCount(OrderCountOperation_Model model)
        {
            GetOrderCount_Model res = Order_DAL.Instance.getOrderCount(model);
            return res;
        }

        public GetTGDetail_Model getTGDetail(long GroupNo, int companyId)
        {
            return Order_DAL.Instance.getTGDetail(GroupNo, companyId);
        }

        public GetTreatmentDetail_Model GetTreatmentDetail(UtilityOperation_Model model)
        {
            return Order_DAL.Instance.GetTreatmentDetail(model);
        }

        public List<GetUnfinishOrder_Model> getUnfinishOrder(int companyId, int customerId, int productType)
        {
            List<GetUnfinishOrder_Model> list = Order_DAL.Instance.getUnfinishOrder(companyId, customerId, productType);
            if (list != null && list.Count > 0)
            {
                list = list.OrderByDescending(c => c.OrderTime).ToList();
            }
            return list;
        }

        public ObjectResult<List<int>> addNewOrder(OrderOperation_Model model)
        {
            ObjectResult<List<int>> res = Order_DAL.Instance.addNewOrder(model);
            return res;
        }

        public int AddRushOrder(AddRushOrderOperation_Model addModel,out string msg)
        {
            int res = Order_DAL.Instance.AddRushOrder(addModel,out msg);
            return res;
        }

        public GetRushOrderDetail_Model GetRushOrderDetail(int companyID, int customerID, int rushOrderID)
        {
            GetRushOrderDetail_Model model = Order_DAL.Instance.GetRushOrderDetail(companyID, customerID, rushOrderID);
            return model;
        }

        public List<GetRushOrderList_Model> GetRushOrderList(int companyID, int customerID)
        {
            List<GetRushOrderList_Model> list = Order_DAL.Instance.GetRushOrderList(companyID, customerID);
            return list;
        }
    }
}
