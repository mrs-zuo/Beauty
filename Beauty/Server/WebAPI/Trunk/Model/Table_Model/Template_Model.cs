using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Template_Model
    {
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int TemplateID { get; set; }
        public string Subject { get; set; }
        public string TemplateContent { get; set; }
        public int TemplateType { get; set; }
        public int CreatorID { get; set; }
        public DateTime OperateTime { get; set; }
        public int UpdaterID { get; set; }

        public string CreatorName { get; set; }
        public string UpdaterName { get; set; }
    }
}
