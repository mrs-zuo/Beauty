using ClientAPI.DAL;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.BLL
{
    public class Branch_BLL
    {
        #region 构造类实例
        public static Branch_BLL Instance
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
            internal static readonly Branch_BLL instance = new Branch_BLL();
        }
        #endregion

        public List<GetBranchList_Model> GetCustomerBranch(int companyId, int customerID)
        {
            List<GetBranchList_Model> list = Branch_DAL.Instance.GetCustomerBranch(companyId, customerID);
            return list;
        }
    }
}
