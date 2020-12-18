using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL.Customer;

namespace WebAPI.BLL.Customer
{
    public class Payment_CBLL
    {
        #region 构造类实例
        public static Payment_CBLL Instance
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
            internal static readonly Payment_CBLL instance = new Payment_CBLL();
        }
        #endregion

        public List<Profit_Model> getProfitListByMasterID(int masterID, int type)
        {
            List<Profit_Model> list = Payment_CDAL.Instance.getProfitListByMasterID(masterID, type);
            return list;
        }
    }
}
