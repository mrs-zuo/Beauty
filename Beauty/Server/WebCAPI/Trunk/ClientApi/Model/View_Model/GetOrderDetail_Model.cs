using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetOrderDetail_Model
    {
        public int OrderID { get; set; }
        public int OrderObjectID { get; set; }
        public string OrderNumber { get; set; }
        public string OrderTime { get; set; }
        public int ProductType { get; set; }
        public long ProductCode { get; set; }
        public string ProductName { get; set; }
        public int Status { get; set; }
        public int BranchID { get; set; }
        public string BranchName { get; set; }
        /// <summary>
        /// 0:未支付 1:部分支付 2:完全支付
        /// </summary>
        public int PaymentStatus { get; set; }
        public string SubServiceIDs { get; set; }
        public decimal TotalOrigPrice { get; set; }
        public decimal TotalSalePrice { get; set; }
        public decimal TotalCalcPrice { get; set; }
        public decimal UnPaidPrice { get; set; }
        public decimal RefundSumAmount { get; set; }
        public int ResponsiblePersonID { get; set; }
        public int SalesPersonID { get; set; }
        public string ResponsiblePersonName { get; set; }
        public string SalesName { get; set; }
        public int CustomerID { get; set; }
        public string CustomerName { get; set; }
        public int CreatorID { get; set; }
        public string CreatorName { get; set; }
        public string CreateTime { get; set; }
        public string Remark { get; set; }
        public DateTime ExpirationTime { get; set; }
        public bool IsPast { get; set; }
        public List<Group> GroupList { get; set; }
        public bool Flag { get; set; }
        public int FinishedCount { get; set; }
        public int TotalCount { get; set; }
        public int SurplusCount { get; set; }
        public int PastCount { get; set; }
        public int Quantity { get; set; }
        public int ScdlCount { get; set; }
        public List<TaskSimpleList_Model> ScdlList { get; set; }
        public List<Sales_Model> SalesList { get; set; }
    }

    [Serializable]
    public class PaymentDetail
    {
        public int PaymentMode { get; set; }
        //public decimal PaymentAmount { get; set; }
    }

    [Serializable]
    public class Group
    {
        public long GroupNo { get; set; }
        public int ServicePicID { get; set; }
        public int Status { get; set; }
        public string ServicePicName { get; set; }
        public bool IsDesignated { get; set; }
        public DateTime StartTime { get; set; }
        public int Quantity { get; set; }
        public List<Treatment> TreatmentList { get; set; }
    }

    [Serializable]
    public class Treatment
    {
        public int SubServiceID { get; set; }
        public string SubServiceName { get; set; }
        public int ExecutorID { get; set; }
        public string ExecutorName { get; set; }
        public int TreatmentID { get; set; }
        public string StartTime { get; set; }
        public int Status { get; set; }
        public bool IsDesignated { get; set; }
    }

    [Serializable]
    public class SimpleOrder_Model
    {
        public int CustomerID { get; set; }
        public int ProductID { get; set; }
    }

    [Serializable]
    public class Sales_Model
    {
        public int SalesPersonID { get; set; }
        public string SalesName { get; set; }
    }
}
