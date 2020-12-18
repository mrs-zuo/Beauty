using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class InOutItemA_Model
    {
        public int CompanyID { get; set; }
        public int ItemAID { get; set; }
        public string ItemAName { get; set; }
    }

    [Serializable]
    public class InOutItemB_Model
    {
        public int ItemAID { get; set; }
        public int ItemBID { get; set; }
        public string ItemBName { get; set; }
    }
    [Serializable]
    public class InOutItemC_Model
    {
        public int ItemBID { get; set; }
        public int ItemCID { get; set; }
        public string ItemCName { get; set; }
    }
}
