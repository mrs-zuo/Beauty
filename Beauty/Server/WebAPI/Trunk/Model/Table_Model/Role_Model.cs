using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Role_Model
    {
        public int ID { get; set; }
        public string RoleName { get; set; }
        public string Jurisdictions { get; set; }
        public int OperatorID { get; set; }
        public DateTime? OperatorTime { get; set; }
        public int CompanyID { get; set; }
        public List<Jurisdiction_Model> JurisdictionList { get; set; }
    }
}
