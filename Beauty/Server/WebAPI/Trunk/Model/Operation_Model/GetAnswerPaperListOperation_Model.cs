using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class GetAnswerPaperListOperation_Model
    {
        public int CompanyID { get; set; }
        public int FilterByTimeFlag { get; set; }
        public string StartTime { get; set; }
        public string EndTime { get; set; }
        public DateTime? UpdateTime { get; set; }
        public int PageIndex { get; set; }
        public int PageSize { get; set; }
        public List<int> ResponsiblePersonIDs { get; set; }
        public int CustomerID { get; set; }
        public bool IsBusiness { get; set; }
        public bool IsShowAll { get; set; }
    }

    [Serializable]
    public class GetAnswerDetailOperation_Model
    {
        public int CompanyID { get; set; }
        public int PaperID { get; set; }
        public int GroupID { get; set; }
    }
}
