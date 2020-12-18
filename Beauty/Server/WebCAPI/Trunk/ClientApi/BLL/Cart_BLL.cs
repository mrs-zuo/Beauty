using ClientAPI.DAL;
using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.BLL
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

        public bool deleteCart(CartOperation_Model model)
        {
            return Cart_DAL.Instance.deleteCart(model);
        }

        public List<GetCartList_Model> getCartList(int customerId, int companyId, int imageWidth, int imageHeight)
        {
            List<GetCartList_Model> list = new List<GetCartList_Model>();

            List<GetCartList_Model> branchList = Cart_DAL.Instance.getCartList(customerId, companyId);
            if (branchList != null && branchList.Count > 0)
            {
                foreach (GetCartList_Model item in branchList)
                {
                    List<CartDetail_Model> cartDetailList = Cart_DAL.Instance.getCartDetailByBranchID(companyId, customerId, item.BranchID, -1, imageWidth, imageHeight);
                    if (cartDetailList != null && cartDetailList.Count > 0)
                    {
                        item.CartDetailList = cartDetailList.OrderByDescending(c => c.CreateTime).ToList();
                        list.Add(item);
                    }
                }
            }

            if (list != null && list.Count > 0)
            {
                list = list.OrderByDescending(x => x.CreateTime).ToList();
                return list;
            }
            else
            {
                return null;
            }
        }

        public int getCartCount(int companyID, int customerId)
        {
            return Cart_DAL.Instance.getCartCount(companyID, customerId);
        }
    }
}
