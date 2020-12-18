using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class OpportunityPageList_Model
    {
        public int RecordCount { get; set; }
        public int PageCount { get; set; }
        public List<OpportunityList_Model> OpportunityList { get; set; }
    }

    [Serializable]
    public class OpportunityList_Model
    {
        public string CustomerName { get; set; }
        public int CustomerID { get; set; }
        public int OpportunityID { get; set; }
        public int ResponsiblePersonID { get; set; }
        public string ProductName { get; set; }
        public int ProductID { get; set; }
        public long ProductCode { get; set; }
        public int ProductType { get; set; }
        public string ProgressRate { get; set; }
        public string ExpirationTime { get; set; }
        public DateTime CreateTime { get; set; }
        public string ResponsiblePersonName { get; set; }
        public bool Available { get; set; }
    }

    [Serializable]
    public class GetStepList_Model
    {
        public int StepID { get; set; }
        public string StepName { get; set; }
    }
}
