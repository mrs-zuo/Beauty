using Model.Operation_Model;
using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class Journal_BLL
    {
        #region 构造类实例
        public static Journal_BLL Instance
        {
            get
            {
                return Nested.instance;
            }
        }

        class Nested
        {
            static Nested()
            {
            }
            internal static readonly Journal_BLL instance = new Journal_BLL();
        }
        #endregion

        public List<Journal_Item_Model> GetItemList() {
            return Journal_DAL.Instance.GetItemList();
        }


        public List<Journal_Account_New_Model> GetJournalList(Journal_Account_Search_Model model) {
            return Journal_DAL.Instance.GetJournalList(model);
        }

        public JournalAccountOperation_Model GetJournalDetail(Journal_Account_Search_Model model) {
            return Journal_DAL.Instance.GetJournalDetail(model);
        }

        public Journal_Account_Defult_Amount_Model GetDefaultAMount(Journal_Account_Defult_Amount_Model model) {
            return Journal_DAL.Instance.GetDefaultAMount(model);
        }
        public List<Account_Model> GetOperatorList(Journal_Account_Search_Model model) {
            return Journal_DAL.Instance.GetOperatorList(model);
        }

        public List<Branch_Model> GetBranchList(int CompanyID, int BranchID) {
            return Journal_DAL.Instance.GetBranchList(CompanyID, BranchID);
        }

        public bool AddJournal(JournalAccountOperation_Model model) {
            return Journal_DAL.Instance.AddJournal(model);
        }



        public bool UpdateJournal(JournalAccountOperation_Model model) {
            return Journal_DAL.Instance.UpdateJournal(model);
        }


        public bool DeleteJournal(JournalAccountOperation_Model model) {
            return Journal_DAL.Instance.DeleteJournal(model);
        }
    }
}
