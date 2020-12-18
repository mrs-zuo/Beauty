using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class CommoditySort_Model
    {
        public int Companyid { set; get; }
        public long CommodityCode { set; get; }
        public int Sortid { set; get; }
    }
}
