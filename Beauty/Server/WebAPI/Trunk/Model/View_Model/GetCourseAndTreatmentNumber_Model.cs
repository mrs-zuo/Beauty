using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetCourseAndTreatmentNumber_Model
    {
        public int CourseNumber { get; set; }
        public int TreatmentNumber { get; set; }
        public int IsLast { get; set; }
    }
}
