using ClientAPI.DAL;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.BLL
{
    public class ShareToOther_BLL
    {
        #region 构造类实例
        public static ShareToOther_BLL Instance
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
            internal static readonly ShareToOther_BLL instance = new ShareToOther_BLL();
        }
        #endregion

        public bool AddTGShareStatics(int companyID, int userID, long groupNo, string url)
        {
            bool res = ShareToOther_DAL.Instance.AddTGShareStatics(companyID, userID, groupNo, url);
            return res;
        }

        public bool UpdateTGShareCount(int companyID, long groupNo)
        {
            bool res = ShareToOther_DAL.Instance.UpdateTGShareCount(companyID, groupNo);
            return res;
        }
    }
}
