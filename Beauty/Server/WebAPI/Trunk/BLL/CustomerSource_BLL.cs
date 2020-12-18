using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class CustomerSource_BLL
    {
        #region 构造类实例
        public static CustomerSource_BLL Instance
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
            internal static readonly CustomerSource_BLL instance = new CustomerSource_BLL();
        }
        #endregion

        public List<CustomerSource_Model> getCustomerSourceList(int CompanyID)
        {
            return CustomerSource_DAL.Instance.getCustomerSourceList(CompanyID);
        }

        public bool deleteCustomerSource(CustomerSource_Model model)
        {
            return CustomerSource_DAL.Instance.deleteCustomerSource(model);
        }

        public CustomerSource_Model getCustomerSourceDetail(int CompanyID, int ID)
        {
            return CustomerSource_DAL.Instance.getCustomerSourceDetail(CompanyID, ID);
        }

        public bool addCustomerSource(CustomerSource_Model model)
        {
            return CustomerSource_DAL.Instance.addCustomerSource(model);
        }

        public bool updateCustomerSource(CustomerSource_Model model)
        {
            return CustomerSource_DAL.Instance.updateCustomerSource(model);
        }

    }
}
