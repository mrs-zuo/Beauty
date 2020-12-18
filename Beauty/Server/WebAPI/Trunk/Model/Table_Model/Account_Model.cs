using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    [Serializable]
    public class Account_Model
    {
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int UserID { get; set; }
        public string Code { get; set; }
        public int RoleID { get; set; }
        public string Question { get; set; }
        public string Answer { get; set; }
        public string Name { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string Department { get; set; }
        public string Title { get; set; }
        public string Expert { get; set; }
        public string Introduction { get; set; }
        public string Mobile { get; set; }
        public string Email { get; set; }
        public string Zip { get; set; }
        public string Address { get; set; }
        public string HeadImageFile { get; set; }
        public int Available { get; set; }
        public int CreatorID { get; set; }
        public DateTime CreateTime { get; set; }
        public int UpdaterID { get; set; }
        public DateTime UpdateTime { get; set; }
        public bool IsRecommend { get; set; }

        public List<BranchSelection_Model> BranchList { get; set; }
        public List<Role_Model> RoleList { get; set; }
        public string Password { get; set; }
        public string SearchOut { get; set; }
        public List<AccountTag_Model> TagsList { get; set; }
        public int SortID { get; set; }
        public decimal CommissionRate { get; set; }
        public DateTime? IssuedDate { get; set; }
    }



    [Serializable]
    public class BranchList_Model
    {
        public int BranchID { get; set; }
        public string BranchName { get; set; }
        public bool IsExist { get; set; }
    }

    [Serializable]
    public class AccountTag_Model 
    {
        public int TagID { get; set; }
        public string TagName { get; set; }
        public bool IsExist { get; set; }
    }




    [Serializable]
    public class AccountSort_Model
    {
        public int UserID { get; set; }
        public int SortID { get; set; }
    }
}
