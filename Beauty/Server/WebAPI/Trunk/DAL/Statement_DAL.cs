using BLToolkit.Data;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL
{
    public class Statement_DAL
    {
        #region 构造类实例
        public static Statement_DAL Instance
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
            internal static readonly Statement_DAL instance = new Statement_DAL();
        }
        #endregion



        public List<StatementCategory_Model> getStatementCategoryList(int CompanyID)
        {
            using (DbManager db = new DbManager())
            {
                List<StatementCategory_Model> list = new List<StatementCategory_Model>();
                string strSql = @"select ID,CategoryName,Describe from [TBL_STATEMENT_CATEGORY] with (nolock) where CompanyID = @CompanyID ";
                list = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteList<StatementCategory_Model>();
                return list;
            }
        }

        public StatementCategory_Model getStatementCategoryDetail(int CompanyID, int CategoryID)
        {
            using (DbManager db = new DbManager())
            {
                StatementCategory_Model model = new StatementCategory_Model();
                string strSql = @"select ID,CategoryName,Describe from [TBL_STATEMENT_CATEGORY] with (nolock) where CompanyID = @CompanyID and ID=@CategoryID ";
                model = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@CategoryID", CategoryID, DbType.Int32)).ExecuteObject<StatementCategory_Model>();

                if (model != null)
                {
                    model.ListStatement = new List<Statement_Model>();
                    string strSqlList = @" select T1.ID,T1.ProductType,T1.ProductCode,ISNULL(T2.ServiceName,T5.CommodityName) ProductName from [TBL_STATEMENT] T1 with (nolock) 
                                            LEFT JOIN (SELECT T3.Code,T3.ServiceName FROM [SERVICE] T3 with (nolock) WHERE T3.ID in (SELECT MAX(T4.ID) FROM [SERVICE] T4 with (nolock) WHERE T4.CompanyID =@CompanyID GROUP BY T4.Code )) T2 
                                            ON T1.ProductType = 0 AND T1.ProductCode = T2.Code
                                            LEFT JOIN (SELECT T6.Code,T6.CommodityName FROM [COMMODITY] T6 with (nolock) WHERE T6.ID in (SELECT MAX(T7.ID) FROM [COMMODITY] T7 with (nolock) WHERE T7.CompanyID =@CompanyID GROUP BY T7.Code )) T5 
                                            ON T1.ProductType = 1 AND T1.ProductCode = T5.Code
                                            where T1.CompanyID=@CompanyID and T1.CategoryID =@CategoryID ";

                    model.ListStatement = db.SetCommand(strSqlList, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@CategoryID", CategoryID, DbType.Int32)).ExecuteList<Statement_Model>();
                }
                return model;
            }

        }

        public List<GetProductList_Model> getProductList(int ProductType, int CategoryID, int CompanyID)
        {
            using (DbManager db = new DbManager())
            {
                List<GetProductList_Model> list = new List<GetProductList_Model>();
                string strSql = "";
                if (ProductType == 0)
                {
                    strSql = " select Code ProductCode,ServiceName ProductName from [SERVICE] WITH (NOLOCK) where CompanyID=@CompanyID and Available = 1  {0} ";
                }
                else
                {
                    strSql = " select Code ProductCode,CommodityName ProductName from [COMMODITY] WITH (NOLOCK) where CompanyID=@CompanyID  and Available = 1 {0} ";
                }
                string strWhere = "";
                if (CategoryID == 0)
                {
                    strWhere = " and CategoryID is null ";
                }
                else if (CategoryID > 0)
                {
                    strWhere = " and CategoryID=@CategoryID ";
                }

                string strSqlfinal = string.Format(strSql, strWhere);
                list = db.SetCommand(strSqlfinal, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                    , db.Parameter("@CategoryID", CategoryID, DbType.Int32)).ExecuteList<GetProductList_Model>();


                return list;
            }
        }

        public bool EditStatement(StatementCategory_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                int id = 0;
                if (model.ID == 0)
                {
                    string strSql = @" INSERT INTO [TBL_STATEMENT_CATEGORY]
                                (CompanyID,CategoryName,Describe,CreatorID,CreateTime,RecordType)
                                 VALUES
                                (@CompanyID,@CategoryName,@Describe,@CreatorID,@CreateTime,1)
                                ;select @@IDENTITY ";
                    id = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@CategoryName", model.CategoryName, DbType.String)
                                        , db.Parameter("@Describe", model.Describe, DbType.String)
                                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteScalar<int>();

                    if (id < 1)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                }
                else
                {
                    string strSql = @" update [TBL_STATEMENT_CATEGORY] set
                                        CategoryName =@CategoryName,
                                        Describe =@Describe,
                                        UpdaterID =@UpdaterID,
                                        UpdateTime =@UpdateTime
                                        where CompanyID=@CompanyID and ID=@ID ";
                    int rows = db.SetCommand(strSql
                                        , db.Parameter("@CategoryName", model.CategoryName, DbType.String)
                                        , db.Parameter("@Describe", model.Describe, DbType.String)
                                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                        , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    string strSqlDelete = " delete [TBL_STATEMENT] where CompanyID =@CompanyId and CategoryID = @CategoryID ";
                    rows = db.SetCommand(strSqlDelete
                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                        , db.Parameter("@CategoryID", model.ID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    id = model.ID;
                }

                if (model.ListStatement != null && model.ListStatement.Count > 0)
                {
                    string strSqlAddStatement = @" INSERT INTO [TBL_STATEMENT]
                                        (CompanyID,CategoryID,ProductType,ProductCode,CreatorID,CreateTime,RecordType)
                                          VALUES
                                        (@CompanyID,@CategoryID,@ProductType,@ProductCode,@CreatorID,@CreateTime,1) ";
                    foreach (Statement_Model item in model.ListStatement)
                    {
                        int rows = db.SetCommand(strSqlAddStatement
                                       , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                       , db.Parameter("@CategoryID", id, DbType.Int32)
                                       , db.Parameter("@ProductType", item.ProductType, DbType.Int32)
                                       , db.Parameter("@ProductCode", item.ProductCode, DbType.Int64)
                                       , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                       , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                            return false;
                        }

                    }
                }
                db.CommitTransaction();
                return true;
            }
        }


        public bool DeleteStatement(int CategoryId, int CompanyID)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                string strSqlCategory = @" DELETE [TBL_STATEMENT_CATEGORY] WHERE CompanyID =@CompanyID and ID =@ID  ";
                int rows = db.SetCommand(strSqlCategory, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                                    , db.Parameter("@ID", CategoryId, DbType.Int32)).ExecuteNonQuery();

                if (rows == 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                string strSqlStatement = @" DELETE [TBL_STATEMENT] WHERE CompanyID =@CompanyID and CategoryID =@CategoryID ";
                rows = db.SetCommand(strSqlStatement, db.Parameter("@CompanyID", CompanyID, DbType.Int32)
                               , db.Parameter("@CategoryID", CategoryId, DbType.Int32)).ExecuteNonQuery();

                db.CommitTransaction();
                return true;
            }
        }
    }
}
