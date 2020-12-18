using BLToolkit.Data;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ClientAPI.DAL
{
    public class Category_DAL
    {
        #region 构造类实例
        public static Category_DAL Instance
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
            internal static readonly Category_DAL instance = new Category_DAL();
        }
        #endregion

        public List<CategoryList_Model> getCategoryList(int companyId, int type, int parentCategoryId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  ID CategoryID ,CategoryName
                                    FROM    CATEGORY
                                    WHERE   CompanyID = @CompanyID
                                            AND Available = 1";

                if (parentCategoryId > 0)
                {
                    strSql += " AND ParentID = @ParentID ";
                }
                else
                {
                    strSql += " AND Type = @Type AND ISNULL(ParentID, 0) = 0 ";
                }


                List<CategoryList_Model> list = db.SetCommand(strSql
                                              , db.Parameter("@CompanyID", companyId, DbType.Int32)
                                              , db.Parameter("@Type", type, DbType.Int32)
                                              , db.Parameter("@ParentID", parentCategoryId, DbType.Int32)).ExecuteList<CategoryList_Model>();

                return list;
            }
        }

        public CategoryInfo_Model getCategoryInfoByID(int companyID, int categoryId)
        {
            using (DbManager db = new DbManager())
            {
                CategoryInfo_Model model = new CategoryInfo_Model();
                string strSql = @" SELECT  ID AS CategoryID ,
                                            CategoryName
                                    FROM    [CATEGORY]
                                    WHERE   CompanyID = @CompanyID
                                            AND ID = @CategoryID  ";

                model = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@CategoryID", categoryId, DbType.Int32)).ExecuteObject<CategoryInfo_Model>();

                return model;
            }
        }

//        public List<CategoryList_Model> getCategoryListByParentCategoryId(int companyID, int parentCategoryId)
//        {
//            using (DbManager db = new DbManager())
//            {
//                string strSql = @" SELECT  ID CategoryID,ParentID, CategoryName
//                                    FROM CATEGORY 
//                                     WHERE ParentID = @ParentID and Available = 1 AND CompanyID = @CompanyID  ";

//                List<CategoryList_Model> list = db.SetCommand(strSql
//                    , db.Parameter("@CompanyID", companyID, DbType.Int32)
//                    , db.Parameter("@ParentID", parentCategoryId, DbType.Int32)).ExecuteList<CategoryList_Model>();

//                return list;
//            }
//        }
    }
}
