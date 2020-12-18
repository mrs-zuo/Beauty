using ClientAPI.DAL;
using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.BLL
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

        public List<Notice_Model> getNoticeList(int companyId, int flag, int type, int pageIndex, int pageSize, out int recordCount)
        {
            return Notice_DAL.Instance.getNoticeList(companyId, flag, type, pageIndex, pageSize, out recordCount);
        }

        public Notice_Model getNoticeDetail(int companyId, int noticeID)
        {
            Notice_Model model = Notice_DAL.Instance.getNoticeDetail(companyId, noticeID);
            return model;
        }
    }
}
