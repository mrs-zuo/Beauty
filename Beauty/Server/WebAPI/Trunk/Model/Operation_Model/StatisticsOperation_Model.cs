using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class StatisticsOperation_Model 
    {
        public int CompanyID { get;set; }
        public int BranchID { get; set; }
        public int CustomerID { get; set; }
        public int ObjectType { get; set; }
        public string StartTime { get; set; }
        public string EndTime { get; set; }
        public int TimeChooseFlag { get; set; }
        public int MonthCount { get; set; }
        public int ExtractItemType { get; set; }
        public int AccountID { get; set; }
    }
}
