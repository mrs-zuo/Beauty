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
    public class Category_BLL
    {
        #region 构造类实例
        public static Category_BLL Instance
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
            internal static readonly Category_BLL instance = new Category_BLL();
        }
        #endregion

        public CategoryInfo_Model getCategoryList(UtilityOperation_Model model)
        {
            CategoryInfo_Model categorymodel = new CategoryInfo_Model();
            if (model.CategoryID <= 0)
            {
                categorymodel.CategoryName = model.Type == 1 ? "全部商品" : "全部服务";
                categorymodel.CategoryID = 0;
            }
            else
            {
                categorymodel = Category_DAL.Instance.getCategoryInfoByID(model.CompanyID, model.CategoryID);
            }

            if (model != null)
            {
                List<CategoryList_Model> list = Category_DAL.Instance.getCategoryList(model.CompanyID, model.Type, model.CategoryID);

                if (list != null && list.Count > 0)
                {
                    for (int i = 0; i < list.Count; i++)
                    {
                        list[i].NextCategoryCount = Category_DAL.Instance.getCategoryList(model.CompanyID, model.Type, list[i].CategoryID).Count;
                    }
                    categorymodel.CategoryList = new List<CategoryList_Model>();
                    categorymodel.CategoryList = list;
                }
            }
            return categorymodel;
        }
    }
}
