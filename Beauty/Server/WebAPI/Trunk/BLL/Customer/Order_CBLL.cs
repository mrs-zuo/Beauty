using HS.Framework.Common.Entity;
using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL.Customer;

namespace WebAPI.BLL.Customer
{
    public class Order_CBLL
    {
        #region 构造类实例
        public static Order_CBLL Instance
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
            internal static readonly Order_CBLL instance = new Order_CBLL();
        }
        #endregion

        public List<GetOrderList_Model> getOrderList(GetOrderListOperation_Model operationModel, int pageSize, int pageIndex, out int recordCount)
        {
            List<GetOrderList_Model> list = Order_CDAL.Instance.getOrderList(operationModel, pageSize, pageIndex, out recordCount);
            return list;
        }

        public GetOrderDetail_Model getOrderDetail(int orderObjectID, int productType, int CompanyID)
        {
            GetOrderDetail_Model model = Order_CDAL.Instance.getOrderDetail(orderObjectID, productType, CompanyID);
            return model;
        }

        public List<Group> getGroupNoList(int orderObjectID, int productType, int status = 0)
        {
            List<Group> list = Order_CDAL.Instance.getGroupNoList(orderObjectID, productType, status);
            return list;
        }

        public List<Treatment> getTreatmentListByGroupNO(long groupNO, int CompanyID)
        {
            List<Treatment> list = Order_CDAL.Instance.getTreatmentListByGroupNO(groupNO, CompanyID);
            return list;
        }

        public List<ExecutingOrder_Model> GetExecutingOrderList(UtilityOperation_Model model)
        {
            List<ExecutingOrder_Model> list = Order_CDAL.Instance.GetExecutingOrderList(model);
            return list;
        }

        public List<UnfinishTG_Model> GetUnfinishTGList(UtilityOperation_Model model)
        {
            List<UnfinishTG_Model> list = Order_CDAL.Instance.GetUnfinishTGList(model);
            return list;
        }

        public int ConfirmTreatGroup(CompleteTGOperation_Model model)
        {
            int res = Order_CDAL.Instance.ConfirmTreatGroup(model);
            return res;
        }
    }
}
