using BLToolkit.Data;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL.Customer
{
    public class Category_CDAL
    {
        #region 构造类实例
        public static Category_CDAL Instance
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
            internal static readonly Category_CDAL instance = new Category_CDAL();
        }
        #endregion

        /// <summary>
        /// 获取第一层目录列表列表
        ///<param name="companyId"></param>
        /// <returns></returns>
        /// </summary>
        public List<CategoryList_Model> getCategoryListByCompanyId(int companyId, int type, int branchId)
        {
            using (DbManager db = new DbManager())
            {
                StringBuilder strSql = new StringBuilder();
                strSql.Append(" SELECT ID CategoryID, CategoryName");
                strSql.Append(" FROM CATEGORY ");
                strSql.Append(" WHERE CompanyID = @CompanyID and Available = 1 and Type = @Type and ParentID is null ");

                //if (branchId > 0)
                //{
                //    strSql.Append(" AND BranchID=@BranchID ");
                //}

                List<CategoryList_Model> list = db.SetCommand(strSql.ToString(), db.Parameter("@CompanyID", companyId, DbType.Int32)
                    , db.Parameter("@Type", type, DbType.Int32)
                    , db.Parameter("@BranchID", branchId, DbType.Int32)).ExecuteList<CategoryList_Model>();

                return list;
            }
        }

        /// <summary>
        /// 获取子目录信息
        ///<param name="companyId"></param>
        /// <returns></returns>
        /// </summary>
        public List<CategoryList_Model> getCategoryListByParentCategoryId(int parentCategoryId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql =
                @" SELECT  ID CategoryID,ParentID, CategoryName
                    FROM CATEGORY 
                     WHERE ParentID = @ParentID and Available = 1  ";

                List<CategoryList_Model> list = db.SetCommand(strSql, db.Parameter("@ParentID", parentCategoryId, DbType.Int32)).ExecuteList<CategoryList_Model>();

                return list;
            }
        }
    }
}
