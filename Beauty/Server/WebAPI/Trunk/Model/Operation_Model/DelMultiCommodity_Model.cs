using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class DelMultiCommodity_Model
    {
        public List<long> CodeList { set;get; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }

    }
}
