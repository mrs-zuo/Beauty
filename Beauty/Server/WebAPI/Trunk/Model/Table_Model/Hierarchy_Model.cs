using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Hierarchy_Model
    {
        public int CompanyID { get; set; }
        public int ID { get; set; }
        public int SuperiorID { get; set; }
        public int SubordinateID { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public string SuperiorName { get; set; }
        public string SubordinateName { get; set; }
        public int Level { get; set; }
    }
}
