using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class OrderAddRes_Model
    {
        public int OrderID { get; set; }
        public decimal TotalSalePrice { get; set; }
        public decimal TotalOrigPrice { get; set; }
    }

    [Serializable]
    public class OrderInfo_Model
    {
        public int OrderID { get; set; }
        public int OrderObjectID { get; set; }
        public string ProductName { get; set; }
        public int ProductType { get; set; }
        public string SubServiceIDs { get; set; }
        public string Remark { get; set; }

        public int ExecutingCount { get; set; }
        public int FinishedCount { get; set; }
        public int TotalCount { get; set; }
        public int SurplusCount { get; set; }
        public string AccountName { get; set; }
        public int AccountID { get; set; }
        public int IsConfirmed { get; set; }

        public List<SubServiceList_Model> SubServiceList { get; set; }
        
    }


    [Serializable]
    public class SubServiceList_Model
    {
        public int SubServiceID { get; set; }
        public string SubServiceName { get; set; }
    }
}
