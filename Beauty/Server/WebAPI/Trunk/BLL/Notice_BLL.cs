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
    public class Notice_BLL
    {
        #region 构造类实例
        public static Notice_BLL Instance
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
            internal static readonly Notice_BLL instance = new Notice_BLL();
        }
        #endregion

        public int getRemindNumberByCustomer(int userId)
        {
            return Notice_DAL.Instance.getRemindNumberByCustomer(userId);
        }

        public List<RemindList_Model> getRemindListByAccountID(int accountId, int branchID)
        {
            List<RemindList_Model> list = Notice_DAL.Instance.getRemindListByAccountID(accountId, branchID);
            return list;
        }

        public int getRemindCountByAccountID(int accountId, int branchID)
        {
            int res = Notice_DAL.Instance.getRemindCountByAccountID(accountId, branchID);
            return res;
        }

        public List<BirthdayList_Model> getBirthdayListByAccountID(int accountId, int branchID)
        {
            List<BirthdayList_Model> list = Notice_DAL.Instance.getBirthdayListByAccountID(accountId, branchID);
            return list;
        }

        public int getBirthdayCountByAccountID(int accountId, int branchID)
        {
            int res = Notice_DAL.Instance.getBirthdayCountByAccountID(accountId, branchID);
            return res;
        }

        public List<VistList_Model> getVisitListByAccountID(int accountId, int branchID)
        {
            List<VistList_Model> list = Notice_DAL.Instance.getVisitListByAccountID(accountId, branchID);
            return list;
        }

        public int getVisitCountByAccountID(int accountId, int branchID)
        {
            int res = Notice_DAL.Instance.getVisitCountByAccountID(accountId, branchID);
            return res;
        }

        public List<GetRemindListByCustomerID_Model> getRemindListByCustomerID(int CustomerID, int imageWidth, int imageHeight)
        {
            List<GetRemindListByCustomerID_Model> list = Notice_DAL.Instance.getRemindListByCustomerID(CustomerID, imageWidth, imageHeight);
            return list;
        }


        public List<Notice_Model> getNoticeList(int companyId, int flag, int type, int pageIndex, int pageSize, out int recordCount) 
        {
            return Notice_DAL.Instance.getNoticeList(companyId, flag, type, pageIndex, pageSize, out recordCount);
        }

        public int getNoticeNumber(int companyId) {
            return Notice_DAL.Instance.getNoticeNumber(companyId);
        }

        public bool deleteNotice(int companyId, int noticeId)
        {
            bool res = Notice_DAL.Instance.deleteNotice(companyId, noticeId);
            return res;
        }

        public bool insertNotice(Notice_Model model)
        {
            bool res = Notice_DAL.Instance.insertNotice(model);
            return res;
        }

        public bool updateNotice(Notice_Model model)
        {
            bool res = Notice_DAL.Instance.updateNotice(model);
            return res;
        }

        public Notice_Model getNoticeDetail(int companyId, int noticeId)
        {
            Notice_Model model = Notice_DAL.Instance.getNoticeDetail(companyId, noticeId);
            return model;
        }
    }
}
