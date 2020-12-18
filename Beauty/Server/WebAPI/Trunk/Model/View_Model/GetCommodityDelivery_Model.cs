using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetCommodityDelivery_Model
    {
        public long DeliveryID { get; set; }
        public string DeliveryCode { get; set; }
        public string CommodityName { get; set; }
        public int OrderID { get; set; }
        public int ServicePIC { get; set; }
        public string ServicePicName { get; set; }
        public int Status { get; set; }
        public DateTime CDStartTime { get; set; }
        public DateTime? CDEndTime { get; set; }
        public List<AccountList_Model> AccountList { get; set; }
    }
}
