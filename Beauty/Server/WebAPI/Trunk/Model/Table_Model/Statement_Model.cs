using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Statement_Model
    {
        public int ID { set; get; }
        public int CategoryID { set; get; }
        public int ProductType { set; get; }
        public long ProductCode{ set; get; }
        public int CompanyID { set; get; }
        public int CreatorID { set; get; }
        public int CreateTime { set; get; }
        public int UpdaterID { set; get; }
        public int UpdateTime { set; get; }

        public string ProductName { set; get; }
    }
}
