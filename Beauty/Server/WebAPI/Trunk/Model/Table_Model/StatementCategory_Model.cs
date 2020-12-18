using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class StatementCategory_Model
    {
        public int ID { set; get; }
        public string CategoryName { set; get; }
        public string Describe { set; get; }
        public int CompanyID { set; get; }
        public int CreatorID { set; get; }
        public DateTime CreateTime { set; get; }
        public int UpdaterID { set; get; }
        public DateTime UpdateTime { set; get; }

        public List<Statement_Model> ListStatement { set; get; }
    }
}
