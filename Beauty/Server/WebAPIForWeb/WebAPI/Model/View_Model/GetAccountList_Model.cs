using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    public class GetAccountList_Model
    {
        public int AccountID { get; set; }
        public string AccountName { get; set; }
        public string Department { get; set; }
        public string Title { get; set; }
        public string Expert { get; set; }
        public string Introduction { get; set; }
        public string HeadImageURL { get; set; }
        public DateTime UpdateTime { get; set; }
    }
}
