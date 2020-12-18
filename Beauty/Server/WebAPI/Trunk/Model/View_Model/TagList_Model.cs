using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class TagList_Model
    {
        public int ID { set; get; }
        public string Name { set; get; }
    }

    [Serializable]
    public class TagDetailForWeb_Model
    {
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int ID { get; set; }
        public string Name { get; set; }
        public bool Available { get; set; }
        public int? CreatorID { get; set; }
        public DateTime? CreateTime { get; set; }
        public int Type { get; set; }
        public List<GetAccountListByGroupFroWeb_Model> UserList { get; set; }
    } 
}
