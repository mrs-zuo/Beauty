using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.View_Model
{
    [Serializable]
    public class AccountList_Model
    {
       public int  AccountID{get;set;}
       public string AccountName { get; set; }
       public string AccountCode { get; set; }
       public string Title { get; set; }
       public string Expert { get; set; }
       public string  HeadImageURL{get;set;}
       public bool isChecked { get; set; }
       public int AccountType { get; set; }
    }

    [Serializable]
    public class AccountListForWeb_Model {
        public int UserID { get; set; }
        public string Code { get; set; }
        public string Name { get; set; }
        public int RoleID { get; set; }
        public string Department { get; set; }
        public string Title { get; set; }
        public string Expert { get; set; }
        public string Introduction { get; set; }
        public string Mobile { get; set; }
        public string HeadImageFile { get; set; }
        public bool Available { get; set; }
        public bool IsRecommend { get; set; }
        public string roleName { get; set; }
        public int BranchCount { get; set; }
    
    }
}
