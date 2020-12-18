using Model.Operation_Model;
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

        public List<CategoryList_Model> getCategoryListByCompanyId(UtilityOperation_Model model)
        {
            List<CategoryList_Model> list = Category_DAL.Instance.getCategoryListByCompanyId(model.CompanyID, model.Type, model.BranchID);

            if (list != null && list.Count > 0)
            {
                for (int i = 0; i < list.Count; i++)
                {
                    list[i].NextCategoryCount = Category_DAL.Instance.getCategoryListByParentCategoryId(list[i].CategoryID).Count;
                }
            }
            return list;

        }

        public List<CategoryList_Model> getCategoryListByParentCategoryId(UtilityOperation_Model model)
        {
            //CategoryListTotal_Model resModel = new CategoryListTotal_Model();
            List<CategoryList_Model> list = Category_DAL.Instance.getCategoryListByParentCategoryId(model.CategoryID);

            if (list != null && list.Count > 0)
            {
                for (int i = 0; i < list.Count; i++)
                {
                    list[i].NextCategoryCount = Category_DAL.Instance.getCategoryListByParentCategoryId(list[i].CategoryID).Count;
                }
            }
            return list;
        }

        public List<CategoryList_Model> getCategoryListForWeb(int companyID, int type, int branchID,int flag,int supplier)
        {
            List<CategoryList_Model> resultList = new List<CategoryList_Model>();
            List<CategoryList_Model> list = Category_DAL.Instance.getCategoryListByCompanyIDForWeb(companyID, type, branchID);

            //列表页 显示全部一项
            //详细页 不显示全部一项
            if (flag == 0)
            {
                #region 全部
                CategoryList_Model totalModel = new CategoryList_Model();
                totalModel.CategoryName = "全部";
                totalModel.CategoryID = -1;

                if (type == 0)
                {
                    totalModel.ProductCount = Service_DAL.Instance.getServiceListForWeb(companyID, -1, 0, 0, branchID).Count;
                }
                else
                {
                    totalModel.ProductCount = Commodity_DAL.Instance.getCommodityListForWeb(companyID, -1, 0, 0, branchID, supplier).Count;
                }
                #endregion
                resultList.Add(totalModel);
            }

            #region 无所属
            CategoryList_Model noCatModel = new CategoryList_Model();
            noCatModel.CategoryName = "无所属";
            noCatModel.CategoryID = 0;
            if (type == 0)
            {
                noCatModel.ProductCount = Service_DAL.Instance.getServiceListForWeb(companyID, 0, 0, 0, branchID).Count;
            }
            else
            {
                noCatModel.ProductCount = Commodity_DAL.Instance.getCommodityListForWeb(companyID, 0, 0, 0, branchID, supplier).Count;
            }
            resultList.Add(noCatModel);
            #endregion

            #region 其他

            List<CategoryList_Model> listCatNull = list.Where(c => c.ParentID == 0).OrderByDescending(c => c.CategoryID).ToList();
            List<CategoryList_Model> listTemp = new List<CategoryList_Model>();
            
            for (int i = 0; i < listCatNull.Count; i++)
            {
                //递归得出 层级
                listTemp = query(list, listCatNull[i].CategoryID, listTemp);
            }

            if (listTemp != null && listTemp.Count > 0)
            {
                for (int i = listTemp.Count - 1; i >= 0; i--)
                {
                    if(type==0)
                        listTemp[i].ProductCount = Service_DAL.Instance.getServiceListForWeb(companyID,listTemp[i].CategoryID, 0, 0, branchID).Count;
                    else
                        listTemp[i].ProductCount = Commodity_DAL.Instance.getCommodityListForWeb(companyID,listTemp[i].CategoryID, 0,0, branchID, supplier).Count;

                    resultList.Add(listTemp[i]);
                }
            }
            return resultList;
            #endregion

        }

        private List<CategoryList_Model> query(List<CategoryList_Model> list, int categoryID, List<CategoryList_Model> result)
        {
            List<CategoryList_Model> listNext = list.Where(c => c.ParentID == categoryID).OrderByDescending(c => c.CategoryID).ToList();
            if (listNext.Count > 0)
            {
                for (int i = 0; i < listNext.Count; i++)
                {
                   query(list, listNext[i].CategoryID,result);
                }
            }
             result.AddRange(list.Where(c => c.CategoryID == categoryID).ToList());
             return result;
        }

        public int getCategoryIdByName(int companyId, string name, int type)
        {
            return Category_DAL.Instance.getCategoryIdByName(companyId,name,type);
        }

        public int deleteCategory(int accountID, int categoryID, int companyID, int type)
        {
            bool haveProduct = Category_DAL.Instance.HaveProduct(categoryID, companyID, type);

            if (haveProduct)
                return -1;

            bool haveChild = Category_DAL.Instance.HaveChild(categoryID, companyID);

            if (haveChild)
                return -2;

            bool result = Category_DAL.Instance.deleteCategory(accountID, categoryID, companyID);

            if (result)
                return 1;

            return 0;
        }

        public bool addCategory(Category_Model model)
        {
            return Category_DAL.Instance.addCategory(model)>0;
        }

        public bool updateCategory(Category_Model model)
        {
            return Category_DAL.Instance.updateCategory(model);
        }

        public Category_Model getCategoryDetail(int categoryId)
        {
            return Category_DAL.Instance.getCategoryDetail(categoryId);
        }

        public bool existCategoryId(int companyId, int categoryID, int type)
        {
            return Category_DAL.Instance.existCategoryId(companyId, categoryID, type);
        }


    }
}
