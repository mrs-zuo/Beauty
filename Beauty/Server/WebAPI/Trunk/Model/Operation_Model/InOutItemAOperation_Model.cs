using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class InOutItemAOperation_Model
    {
        public int ItemAID { get; set; }
        public string ItemAName { get; set; }
        public int COMPANYID { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdaterTime { get; set; }
    }

    [Serializable]
    public class InOutItemBOperation_Model
    {
        public int ItemAID { get; set; }
        public int ItemBID { get; set; }
        public string ItemBName { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdaterTime { get; set; }
    }
    [Serializable]
    public class InOutItemCOperation_Model
    {
        public int ItemBID { get; set; }
        public int ItemCID { get; set; }
        public string ItemCName { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdaterTime { get; set; }
    }
}
