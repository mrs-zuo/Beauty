using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class CustomerLocation_Model
    {
        public int ID { set; get; }
        public int CustomerID { set; get; }
        public int DeviceType { set; get; }
        public decimal Longitude { set; get; }
        public decimal Latitude { set; get; }
        public DateTime LocationTime { set; get; }
        public int CompanyID { set; get; }
        public int CreatorID { set; get; }
        public DateTime CreateTime { set; get; }
        public int UpdaterID { set; get; }
        public DateTime UpdateTime { set; get; }
        public int RecordType { set; get; }
    }
}
