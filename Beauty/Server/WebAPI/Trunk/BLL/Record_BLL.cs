using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class Record_BLL
    {
        #region 构造类实例
        public static Record_BLL Instance
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
            internal static readonly Record_BLL instance = new Record_BLL();
        }
        #endregion

        public List<RecordListByCustomerID_Model> getRecordListByCustomerID(int CustomerID, bool isBusiness, string tagIDs)
        {
            return Record_DAL.Instance.getRecordListByCustomerID(CustomerID, isBusiness, tagIDs);
        }

        public List<RecordList> getRecordListByAccountID(UtilityOperation_Model model, int pageSize, int pageIndex, out int recordCount)
        {
            return Record_DAL.Instance.getRecordListByAccountID(model, pageSize, pageIndex, out recordCount);
        }

        public bool addRecord(Record_Model model)
        {
            return Record_DAL.Instance.addRecord(model);
        }

        public bool updateRecord(Record_Model model)
        {
            return Record_DAL.Instance.updateRecord(model);
        }

        public bool deleteRecord(int RecordID, int AccountID,int CompanyID)
        {
            return Record_DAL.Instance.deleteRecord(RecordID, AccountID,CompanyID);
        }
    }
}
