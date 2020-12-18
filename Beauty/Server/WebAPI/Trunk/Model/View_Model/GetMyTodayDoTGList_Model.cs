using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{

    [Serializable]
    public class GetMyTodayDoTGListRes_Model
    {
        public int RecordCount { get; set; }
        public int PageCount { get; set; }
        public List<GetMyTodayDoTGList_Model> TGList { get; set; }
    }

    [Serializable]
    public class GetMyTodayDoTGList_Model
    {
        public string ProductName { get; set; }
        public DateTime TGStartTime { get; set; }
        public int PaymentStatus { get; set; }
        public int TotalCount { get; set; }
        public int FinishedCount { get; set; }
        public long GroupNo { get; set; }
        public int OrderID { get; set; }
        public int OrderObjectID { get; set; }
        public int ProductType { get; set; }
        public int Status { get; set; }
        public string CustomerName { get; set; }
        public int CustomerID { get; set; }
    }
}
