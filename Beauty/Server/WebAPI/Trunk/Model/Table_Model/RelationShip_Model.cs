using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class RelationShip_Model
    {
        public int CompanyID { set; get; }
        public int ID { set; get; }
        public int AccountID { set; get; }
        public int CustomerID { set; get; }
        public int BranchID { set; get; }
        public bool Available { set; get; }
        public int CreatorID { set; get; }
        public DateTime CreateTime { set; get; }
        public int UpdaterID { set; get; }
        public DateTime UpdateTime { set; get; }
        public bool AccountStatus { set; get; }
        public string AccountName { set; get; }
        public string CustomerName { set; get; }
        public string SearchOut { set; get; }
        public int Type { set; get; }


        public List<int> listSubmitAccountID { set; get; }
        public List<int> listCustomerID { get; set; }
    }
}
