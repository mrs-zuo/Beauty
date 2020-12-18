using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetOrderCount_Model
    {
        public int Total { get; set; }
        public int Unpaid { get; set; }
        public int UncompletedService { get; set; }
        public int UndeliveredCommodity { get; set; }
    }
}
