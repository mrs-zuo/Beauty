using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL;

namespace WebAPI.BLL
{
    public class CommoditySupplier_BLL
    {
        #region 构造类实例
        public static CommoditySupplier_BLL Instance
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
            internal static readonly CommoditySupplier_BLL instance = new CommoditySupplier_BLL();
        }
        #endregion

        /// <summary>
        /// 获取商品列表
        /// </summary>
        /// <param name="Commodity_Model"></param>
        /// <returns></returns>
        public List<Commodity_Model> GetCommodityList(Commodity_Model model)
        {
            return Commodity_DAL.Instance.GetCommodityList(model);//
        }
        /// <summary>
        /// 获取供应商列表
        /// </summary>
        /// <param name=Supplier_Model"></param>
        /// <returns></returns>
        public List<Supplier_Model> GetSupplierList(Supplier_Model model)
        {
            return Supplier_DAL.Instance.GetSupplierListForWeb(model);
        }
        /// <summary>
        /// 获取商品供应商列表
        /// </summary>
        /// <param name=SupplierCommodity_Model"></param>
        /// <returns></returns>
        public List<SupplierCommodity_Model> GetCommoditySupplierList(SupplierCommodity_Model model)
        {
            return CommoditySupplier_DAL.Instance.GetCommoditySupplierList(model);
        }
        /// <summary>
        ///更新商品供应商
        /// </summary>
        /// <param name=SupplierCommodity_Model"></param>
        /// <returns></returns>
        public bool ChangeCommoditySupplier(SupplierCommodity_Model model)
        {
            return CommoditySupplier_DAL.Instance.ChangeCommoditySupplier(model);
        }
    }
}
