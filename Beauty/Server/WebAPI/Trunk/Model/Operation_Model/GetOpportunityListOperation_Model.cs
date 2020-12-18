using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class GetOpportunityListOperation_Model
    {
        public int CompanyID { get; set; }
        public int AccountID { get; set; }
        public int ProductType { get; set; }
        public DateTime? CreateTime { get; set; }
        public int FilterByTimeFlag { get; set; }
        public string StartTime { get; set; }
        public string EndTime { get; set; }
        public int BranchID { get; set; }
        public int PageIndex { get; set; }
        public int PageSize { get; set; }

        public List<int> ResponsiblePersonIDs { get; set; }
        public int CustomerID { get; set; }
    }
}
