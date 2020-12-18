using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class LevelOperation_Model
    {
        public int Flag { set; get; }
        public int CustomerID { set; get; }
        public int LevelID { set; get; }
    }
}
