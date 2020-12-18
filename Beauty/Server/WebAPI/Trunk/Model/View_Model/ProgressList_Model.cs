using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class ProgressList_Model
    {
        public int ProgressHistoryID { get; set; }
        public int Progress { get; set; }
        public string StepContent { get; set; }
        public string Description { get; set; }
        public string CreateTime { get; set; }
    }
}
