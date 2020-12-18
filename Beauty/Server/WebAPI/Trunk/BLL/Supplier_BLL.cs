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
    public class Supplier_BLL
    {
        #region 构造类实例
        public static Supplier_BLL Instance
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
            internal static readonly Supplier_BLL instance = new Supplier_BLL();
        }
        #endregion

        /// <summary>
        /// 获取供应商列表
        /// </summary>
        /// <param name="branchId"></param>
        /// <param name="companyId"></param>
        /// <returns></returns>
        public List<SupplierList_Model> GetSupplierList(SupplierList_Model model)
        {
            return Supplier_DAL.Instance.GetSupplierList(model);
        }

        public Supplier_Commodity_RELATION_Model GetSupplierDetail(Supplier_Commodity_RELATION_Model model)
        {
            return Supplier_DAL.Instance.GetSupplierDetail(model);
        }
        public SupplierList_Model GetSubServiceDetail(SupplierList_Model model)
        {
            return Supplier_DAL.Instance.GetSubServiceDetail(model);
        }
        public bool IsExsitSupplierName(SupplierList_Model model)
        {
            return Supplier_DAL.Instance.IsExsitSupplierName(model);
        }
        public bool UpdateSupplier(SupplierList_Model model)
        {
            return Supplier_DAL.Instance.UpdateSupplier(model);
        }

        public bool AddSupplier(SupplierList_Model model)
        {
            return Supplier_DAL.Instance.AddSupplier(model);
        }

        public bool DeleteSupplier(SupplierList_Model model)
        {
            return Supplier_DAL.Instance.DeleteSupplier(model);
        }

        public List<Supplier_Model> GetSupplierListForWeb(Supplier_Model model)
        {
            return Supplier_DAL.Instance.GetSupplierListForWeb(model);
        }
    }
}
