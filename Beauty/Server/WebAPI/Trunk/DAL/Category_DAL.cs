using System;
using System.Collections.Generic;
using System.Text;
using BLToolkit.Data;
using Model.View_Model;
using System.Data;
using Model.Table_Model;
using HS.Framework.Common;

namespace WebAPI.DAL
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


        /// <summary>
        /// 获取分类中某一个分店的总数量
        /// </summary>
        /// <param name="companyId"></param>
        /// <param name="branchId"></param>
        /// <param name="name"></param>
        /// <returns></returns>
        public List<CategoryList_Model> getCategoryListTotalByBranchID(int companyId, int branchId, int type)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT T1.ID, ISNULL(T1.ParentID,0) ParentID, T1.CategoryName ,ISNULL(T3.Total,0) ProductCount 
                                    FROM CATEGORY T1 
                                    LEFT JOIN (  
                                    select T2.CategoryID,COUNT(T2.ID) Total  from ( 
                                    SELECT T4.CategoryID,T4.ID  FROM ";
                if (type == 0)
                {
                    strSql += "SERVICE";
                }
                else if (type == 1)
                {
                    strSql += "COMMODITY";
                }
                strSql += @" T4 
                               where T4.Code IN( 
                               select Code from  [TBL_MARKET_RELATIONSHIP] 
                               where CompanyID =@CompanyID
                               AND BranchID =@BranchID 
                               AND Available =1
                               AND TYPE =@TYPE
                               group by Code) 
                               and T4.Available =1) T2
                               group by T2.CategoryID) T3 
                               on T1.ID = T3.CategoryID
                               WHERE T1.Available = 1   
                               AND TYPE =@TYPE
                               AND CompanyID =@CompanyID";
                List<CategoryList_Model> list = db.SetCommand(strSql,
                             db.Parameter("@CompanyID", companyId, DbType.Int32),
                             db.Parameter("@BranchID", branchId, DbType.Int32),
                             db.Parameter("@TYPE", type, DbType.Int32)).ExecuteList<CategoryList_Model>();
                return list;
            }
        }


        public List<CategoryList_Model> getCategoryListByCompanyIDForWeb(int companyId, int type, int branchID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"WITH    SubQuery ( CategoryID, ParentID, level )
                                         AS ( ( SELECT ID CategoryID ,
                                                       ParentID ,
                                                       0 level
                                                FROM   dbo.CATEGORY
                                                WHERE  ParentID IS NULL
                                              )
                                              UNION ALL
                                              ( SELECT A.ID CategoryID ,
                                                       A.ParentID ,
                                                       B.level + 1 level
                                                FROM   dbo.CATEGORY A ,
                                                       SubQuery B
                                                WHERE  a.ParentID = B.CategoryID
                                              )
                                            )
                                   SELECT  REPLICATE('...', T1.level) + T2.CategoryName CategoryName,T1.CategoryID,T1.ParentID, T2.CategoryName CategoryNameForEdit 
                                   FROM    SubQuery T1
                                           INNER JOIN dbo.CATEGORY T2 ON T1.CategoryID = T2.ID
                                           WHERE T2.CompanyID= @CompanyID and T2.Available= 1 and T2.Type = @Type Order BY T2.ID";

                List<CategoryList_Model> list = db.SetCommand(strSql.ToString(), db.Parameter("@CompanyID", companyId, DbType.Int32), db.Parameter("@Type", type, DbType.Int32)).ExecuteList<CategoryList_Model>();

                return list;
            }
        }

        public int getCategoryIdByName(int companyId, string name, int type)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"select ID FROM CATEGORY WHERE CompanyID=@CompanyID AND CategoryName=@CategoryName AND Type = @Type AND Available = 1";

                int categoryID = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                     , db.Parameter("@CategoryName", name, DbType.String)
                     , db.Parameter("@Type", type, DbType.Int32)).ExecuteScalar<int>();

                return categoryID;
            }
        }

        public bool existCategoryId(int companyId, int categoryID, int type)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"select count(0) FROM CATEGORY WHERE CompanyID=@CompanyID AND ID=@CategoryID AND Type = @Type AND Available = 1";

                int count = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)
                     , db.Parameter("@CategoryID", categoryID, DbType.Int32)
                     , db.Parameter("@Type", type, DbType.Int32)).ExecuteScalar<int>();

                return count>0;
            }
        }

        public bool deleteCategory(int accountID, int categoryID, int companyID)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                try
                {
                    string strSql = @"INSERT INTO dbo.HISTORY_CATEGORY 
                                    SELECT * FROM dbo.CATEGORY WHERE ID =@CategoryID and CompanyID =@CompanyID";

                    int rows = db.SetCommand(strSql, db.Parameter("@CategoryID", categoryID, DbType.Int32)
                        , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteNonQuery();

                    if (rows <= 0)
                        return false;


                    strSql = @" update CATEGORY set 
                    Available=@Available,
                    UpdaterID=@UpdaterID,
                    UpdateTime=@UpdateTime
                    where ID=@ID and CompanyID =@CompanyID";

                    rows = db.SetCommand(strSql, db.Parameter("@Available", false, DbType.Boolean)
                        , db.Parameter("@UpdaterID", accountID, DbType.Int32)
                        , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                        , db.Parameter("@ID", categoryID, DbType.Int32)
                        , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteNonQuery();

                    if (rows <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                    else
                    {
                        db.CommitTransaction();
                        return true;
                    }
                }
                catch(Exception ex)
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }

        /// <summary>
        /// 更新一条数据
        /// </summary>
        public bool updateCategory(Category_Model model)
        {

            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                try
                {
                    string strSql = @"INSERT INTO dbo.HISTORY_CATEGORY 
                                    SELECT * FROM dbo.CATEGORY WHERE ID =@CategoryID and CompanyID =@CompanyID";

                    int rows = db.SetCommand(strSql, db.Parameter("@CategoryID", model.ID, DbType.Int32)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (rows <= 0)
                        return false;


                    strSql = @" update CATEGORY set 
                                ParentID=@ParentID,
                                CategoryName=@CategoryName,
                                Describe=@Describe,
                                UpdaterID=@UpdaterID,
                                UpdateTime=@UpdateTime
                                where ID=@ID ";

                    rows = db.SetCommand(strSql, db.Parameter("@ParentID", model.ParentID == 0 ? (object)DBNull.Value : model.ParentID, DbType.Int32)
                        , db.Parameter("@CategoryName", model.CategoryName, DbType.String)
                        , db.Parameter("@Describe", DateTime.Now.ToLocalTime(), DbType.String)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                        , db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery();

                    if (rows <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                    else
                    {
                        db.CommitTransaction();
                        return true;
                    }
                }
                catch(Exception ex)
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }

        /// <summary>
        /// 增加一条数据
        /// </summary>
        public int addCategory(Category_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"INSERT  INTO CATEGORY
        ( CompanyID ,
          BranchID ,
          Type ,
          ParentID ,
          CategoryName ,
          Describe ,
          Available ,
          CreatorID ,
          CreateTime
        )
VALUES  ( @CompanyID ,
          @BranchID ,
          @Type ,
          @ParentID ,
          @CategoryName ,
          @Describe ,
          @Available ,
          @CreatorID ,
          @CreateTime
        );
SELECT  @@IDENTITY";


                int categoryID = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                     , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                     , db.Parameter("@Type", model.Type, DbType.Int32)
                     , db.Parameter("@ParentID", model.ParentID==0?(object)DBNull.Value:model.ParentID, DbType.Int32)
                     , db.Parameter("@Describe", model.Describe, DbType.String)
                     , db.Parameter("@CategoryName", model.CategoryName, DbType.String)
                     , db.Parameter("@Available", model.Available, DbType.Int32)
                     , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                     , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                     ).ExecuteScalar<int>(); ;
                if (categoryID <= 0)
                {
                    return 0;
                }
                else
                {
                    return categoryID;
                }
            }
        }

        public Category_Model getCategoryDetail(int categoryId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  ParentID ,
                        CategoryName
                FROM    dbo.CATEGORY
                WHERE   ID = @CategoryID";

                return db.SetCommand(strSql, db.Parameter("@CategoryID", categoryId, DbType.Int32)).ExecuteObject<Category_Model>();
            }
        }

        public bool HaveProduct(int categoryID,int companyID,int type){
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT COUNT(0) FROM  {0}  
                                  WHERE CategoryID = @CategoryID
                                  AND CompanyID =@CompanyID
                                    AND Available = 1";

                strSql = string.Format(strSql, type == 1 ? "Commodity" : "Service");

                int rows = db.SetCommand(strSql, db.Parameter("@CategoryID", categoryID, DbType.Int32)
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalar<int>();

                return rows > 0;
            }
        }

        public bool HaveChild(int categoryID, int companyID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT COUNT(0) FROM  dbo.CATEGORY  
                                  WHERE ParentID = @CategoryID
                                  AND CompanyID =@CompanyID
                                    AND Available = 1";

                int rows = db.SetCommand(strSql, db.Parameter("@CategoryID", categoryID, DbType.Int32)
                    , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteScalar<int>();

                return rows > 0;
            }




        }

    }
}
