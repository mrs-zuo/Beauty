using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Operation_Model
{
    [Serializable]
    public class TagOperation_Model
    {
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int ID { get; set; }
        public string Name { get; set; }
        public bool Available { get; set; }
        public int? CreatorID { get; set; }
        public DateTime? CreateTime { get; set; }
        /// <summary>
        /// 1:记事本 咨询记录标签 2:Account标签
        /// </summary>
        public int Type { get; set; }
    }
}
