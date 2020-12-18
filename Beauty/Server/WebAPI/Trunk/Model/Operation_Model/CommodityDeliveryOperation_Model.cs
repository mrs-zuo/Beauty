using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class CommodityDeliveryOperation_Model
    {
        public int CompanyID { get; set; }
        public long DeliveryID { get; set; }
        public string DeliveryCode { get; set; }
        public int ServicePIC { get; set; }
        public DateTime CDStartTime { get; set; }
        public DateTime? CDEndTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
    }
}
