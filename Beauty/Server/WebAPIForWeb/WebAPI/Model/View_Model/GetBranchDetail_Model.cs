using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    public class GetBranchDetail_Model
    {
        public int BranchID { get; set; }
        public string BranchName { get; set; }
        public string Contact { get; set; }
        public string Phone { get; set; }
        public string Fax { get; set; }
        public string Address { get; set; }
        public string Zip { get; set; }
        public string Web { get; set; }
        public string BusinessHours { get; set; }
        public string Remark { get; set; }
        public decimal Longitude { get; set; }
        public decimal Latitude { get; set; }

        public List<string> ImgList { get; set; }
    }
}
