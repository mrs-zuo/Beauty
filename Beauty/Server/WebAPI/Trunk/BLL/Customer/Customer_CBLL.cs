using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL.Customer;

namespace WebAPI.BLL.Customer
{
    public class Customer_CBLL
    {
        #region 构造类实例
        public static Customer_CBLL Instance
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
            internal static readonly Customer_CBLL instance = new Customer_CBLL();
        }
        #endregion

        public CustomerBasic_Model GetCustomerBasic(int customerId, int companyID, int branchID, int imageWidth, int imageHeight)
        {
            return Customer_CDAL.Instance.GetCustomerBasic(customerId, companyID, branchID, imageWidth, imageHeight);
        }

        public CustomerInfo_Model GetCustomerInfo(int customerId, int companyID, int branchID, int imageWidth, int imageHeight)
        {
            return Customer_CDAL.Instance.GetCustomerInfo(customerId, companyID, branchID, imageWidth, imageHeight);
        }
    }
}
