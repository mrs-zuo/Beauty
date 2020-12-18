using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class GetCompanyDetail_Model
    {
        public string CompanyName { get; set; }
        public string Abbreviation { get; set; }
        public string Summary { get; set; }
        public string Contact { get; set; }
        public string Phone { get; set; }
        public string Fax { get; set; }
        public string Web { get; set; }
        public List<string> ImgList { get; set; }
        public string Style { get; set; }
        public int BranchCount { get; set; }
    }
}
