using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetBranchList_Model
    {
        public int BranchID { get; set; }
        public string BranchName { get; set; }
        public string Phone { get; set; }
        public string Fax { get; set; }
        public string Address { get; set; }
        public bool Visible { get; set; }
        public double Longitude { get; set; }
        public double Latitude { get; set; }
        public double Distance { get; set; }
    }
}
