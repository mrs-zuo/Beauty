using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class Cart_BLL
    {
        #region 构造类实例
        public static Cart_BLL Instance
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
            internal static readonly Cart_BLL instance = new Cart_BLL();
        }
        #endregion

        public int addCart(CartOperation_Model model)
        {
            return Cart_DAL.Instance.addCart(model);
        }

        public int updateCart(CartOperation_Model model)
        {
            return Cart_DAL.Instance.updateCart(model);
        }


        public bool deleteCart(List<CartIDList_Model> cartId, int customerId)
        {
            return Cart_DAL.Instance.deleteCart(cartId, customerId);
        }
        public List<GetCartList_Model> getCartList(int customerId, int companyId, int imageWidth, int imageHeight)
        {
            return Cart_DAL.Instance.getCartList(customerId, companyId, imageWidth, imageHeight);
        }

        public int getCartCount(int customerId)
        {
            return Cart_DAL.Instance.getCartCount(customerId);
        }

    }
}
