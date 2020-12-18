using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Jurisdiction_Model
    {
        public int ID { get; set; }
        public string JurisdictionName { get; set; }
        public string Type { get; set; }
        public int ParentID { get; set; }
        public string Advanced { get; set; }
        public bool IsExist { get; set; }
        public int Level { get; set; }
    }
}
