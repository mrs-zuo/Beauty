using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class OrderOperation_Model
    {

        public int CompanyID { get; set; }
        public int CustomerID { get; set; }
        public DateTime OrderTime { get; set; }
        public int Status { get; set; }
        public int CreatorID { get; set; }
        public DateTime? CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public bool IsBusiness { get; set; }

        public List<OrderDetailOperation_Model> OrderList { get; set; }
        public List<int> OldOrderIDs { get; set; }
    }

    [Serializable]
    public class OrderDetailOperation_Model
    {
        public long ProductCode { get; set; }
        public int BranchID { get; set; }
        public int Quantity { get; set; }
        public int CartId { get; set; }
        public int OpportunityId { get; set; }
        public long TaskID { get; set; }
        public DateTime Expirationtime { get; set; }
        public int ResponsiblePersonID { get; set; }
        //public string strSalesIDs { get; set; }
        public string Remark { get; set; }
        public decimal? TotalSalePrice { get; set; }
        public int CardID { get; set; }
        public string BenefitID { get; set; }
        public decimal PRValue2 { get; set; }

        public string ProductName { get; set; }
        public int ProductType { get; set; }
        public decimal TotalCalcPrice { get; set; }
        public decimal TotalOrigPrice { get; set; }
        public int ProductID { get; set; }

        public bool IsDesignated { get; set; }
        public bool IsPast { get; set; }
        public int TGPastCount { get; set; }
        public int TGTotalCount { get; set; }
        public decimal PaidPrice { get; set; }
    }

    [Serializable]
    public class OrderCountOperation_Model
    {
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int CustomerID { get; set; }
        public bool IsBusiness { get; set; }
    }

    [Serializable]
    public class OrderUpdateCustomerIDListOperation_Model
    {
        public List<OrderUpdateCustomerIDOperation_Model> List { get; set; }
    }

    [Serializable]
    public class OrderUpdateCustomerIDOperation_Model
    {
        public int OrderID { get; set; }
        public int OrderObjectID { get; set; }
        public int ProductType { get; set; }
        public int CustomerID { get; set; }
    }
}
