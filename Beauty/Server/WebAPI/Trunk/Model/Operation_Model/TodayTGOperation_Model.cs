using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class TodayTGOperation_Model
    {
        public TodayTGOperation_Model()
        {
            this.PageIndex = 1;
            this.PageSize = 10;
        }

        public int Status { get; set; }
        public int ServicePIC { get; set; }
        public int ProductType { get; set; }
        public int CustomerID { get; set; }
        public int PageIndex { get; set; }
        public int PageSize { get; set; }
        public int FilterByTimeFlag { get; set; }
        public string StartTime { get; set; }
        public string EndTime { get; set; }

        public int BranchID { get; set; }
        public int CompanyID { get; set; }
        public DateTime? TGStartTime { get; set; }
    }
}
