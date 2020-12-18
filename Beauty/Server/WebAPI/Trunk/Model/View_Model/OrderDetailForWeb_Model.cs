using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class OrderDetailForWeb_Model
    {
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public string OrderCode { get; set; }
        public int Quantity { get; set; }
        public decimal TotalCalcPrice { get; set; }
        public decimal TotalSalePrice { get; set; }
        public string CustomerName { get; set; }
        public bool IsPast { get; set; }
        public int PaymentStatus { get; set; }
        public string BranchName { get; set; }
        public string ProductName { get; set; }
        public string ResponsiblePersonName { get; set; }
        public string CreatorName { get; set; }
        public DateTime? OrderTime { get; set; }
        public string SalesName { get; set; }
        public int ProductType { get; set; }
        public int OrderStatus { get; set; }
        public DateTime? Expirationtime { get; set; }
        public int ResponsiblePersonID { get; set; }
        public decimal TotalOrigPrice { get; set; }
        public string PolicyName { get; set; }
        //public List<CourseList> CourseList { get; set; }       
        public List<AccountList_Model> accountList { get; set; }
        public List<Payment_ForOrder> PaymentList { get; set; }
    }

    //[Serializable]
    //public class CourseList
    //{
    //    public int CourseID { get; set; }
    //    public string ServiceName { get; set; }
    //    public List<TreatmentDetailForWeb_Model> treatmentList { get; set; }
    //}

    [Serializable]
    public class Payment_ForOrder
    {
        public int ID { get; set; }
        public string PaymentCode { get; set; }
        public DateTime PaymentTime { get; set; }
    }

    
}
