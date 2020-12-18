using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class UnPaidList_Model
    {
        public int CustomerID { get; set; }
        public DateTime LastTime { get; set; }
        public string CustomerName { get; set; }
        public string LoginMobileShow { get; set; }
        public string LoginMobileSearch { get; set; }
        public int OrderCount { get; set; }
    }

    [Serializable]
    public class UnPaidListByCustomerID_Model
    {
        public int OrderID { get; set; }
        public int ProductType { get; set; }
        public decimal TotalSalePrice { get; set; }
        public decimal UnPaidPrice { get; set; }
        public int PaymentStatus { get; set; }
        public DateTime OrderTime { get; set; }
        public string ResponsiblePersonName { get; set; }
        public string ProductName { get; set; }
        public int Quantity { get; set; }
        public int OrderObjectID { get; set; }
        public int CardID { get; set; }
        public string CardName { get; set; }
        public int BranchID { get; set; }
        public string BranchName { get; set; }

        public List<UnPaidListTG_Model> TGList { get; set; }
    }

    [Serializable]
    public class UnPaidListTG_Model
    {
        public string ServicePICName { get; set; }
        public int Status { get; set; }
        public DateTime StartTime { get; set; }
    }
}
