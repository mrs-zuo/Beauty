using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Model.Table_Model
{
    public class Journal_Account_New_Model
    {
        public int ID { get; set; }
        public string BranchName { get; set; }
        public int InOutType { get; set; }
        public string InOutTypeName { get; set; }
        public string ItemAName { get; set; }
        public string ItemBName { get; set; }
        public string ItemCName { get; set; }
        public string InOutDate { get; set; }
        public string Amount { get; set; }
        public string OperatorName { get; set; }

        public int CheckResult { get; set; }
        public string CheckResultName { get; set; }
        public string Remark { get; set; }
    }
    [Serializable]
    public class Journal_Account_Search_Model
    {
        public int ID { get; set; }
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int InOutType { get; set; }
        public string ItemName { get; set; }
        public string StartDate { get; set; }
        public string EndDate { get; set; }

    }
    [Serializable]
    public class Journal_Account_Amount_Total_Model
    {
        public string Amount { get; set; }
        public int InOutType { get; set; }

    }
    [Serializable]
    public class Journal_Account_Defult_Amount_Model
    {
        public int CompanyID { get; set; }
        public int BranchID { get; set; }
        public int ItemAID { get; set; }
        public int ItemBID { get; set; }
        public int ItemCID { get; set; }
        public int InOutType { get; set; }
        public string Amount { get; set; }
    }
}
