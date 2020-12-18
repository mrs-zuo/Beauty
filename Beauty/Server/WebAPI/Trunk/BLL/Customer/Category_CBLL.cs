using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.DAL.Customer;

namespace WebAPI.BLL.Customer
{
    public class Category_CBLL
    {
        #region 构造类实例
        public static Category_CBLL Instance
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
            internal static readonly Category_CBLL instance = new Category_CBLL();
        }
        #endregion

        public List<CategoryList_Model> getCategoryListByCompanyId(UtilityOperation_Model model)
        {
            List<CategoryList_Model> list = Category_CDAL.Instance.getCategoryListByCompanyId(model.CompanyID, model.Type, model.BranchID);

            if (list != null && list.Count > 0)
            {
                for (int i = 0; i < list.Count; i++)
                {
                    list[i].NextCategoryCount = Category_CDAL.Instance.getCategoryListByParentCategoryId(list[i].CategoryID).Count;
                }
            }
            return list;

        }

        public List<CategoryList_Model> getCategoryListByParentCategoryId(UtilityOperation_Model model)
        {
            //CategoryListTotal_Model resModel = new CategoryListTotal_Model();
            List<CategoryList_Model> list = Category_CDAL.Instance.getCategoryListByParentCategoryId(model.CategoryID);

            if (list != null && list.Count > 0)
            {
                for (int i = 0; i < list.Count; i++)
                {
                    list[i].NextCategoryCount = Category_CDAL.Instance.getCategoryListByParentCategoryId(list[i].CategoryID).Count;
                }
            }
            return list;
        }
    }
}
