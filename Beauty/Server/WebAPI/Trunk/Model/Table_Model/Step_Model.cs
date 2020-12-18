using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Step_Model
    {
        public int CompanyID { get; set; }
        public DateTime? CreateTime { get; set; }
        public int? CrteatorID { get; set; }
        public int ID { get; set; }
        public string StepContent { get; set; }
        public int StepNumber { get; set; }
        public string StepName { get; set; }
        public long StepCode { get; set; }
    }
}
