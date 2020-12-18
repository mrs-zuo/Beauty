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
    public class Supplier_DAL
    {
        #region 构造类实例
        public static Supplier_DAL Instance
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
            internal static readonly Supplier_DAL instance = new Supplier_DAL();
        }
        #endregion
        /// <summary>
        /// 获取供应商列表
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public List<SupplierList_Model> GetSupplierList(SupplierList_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT T1.SupplierID,
                                          T1.SupplierName,
                                          T1.SupplierAddr,
                                          T1.SupplierTel,
                                          T1.SupplierContactName,
                                          T1.SupplierContactTel  
                                          FROM SUPPLIER T1 WHERE T1.CompanyID =@CompanyID  
                                          AND Available = @Available ";
                if (model.BranchID > 0)
                {
                    strSql += "  AND T1.BranchID =@BranchID ";
                }
                if (model.InputSearch !="")
                {
                    strSql += " AND  ISNULL(T1.SupplierName,'')  LIKE '%" + model.InputSearch + "%'";
                }
                strSql += "  order by SupplierID desc ";
                List<SupplierList_Model> list = new List<SupplierList_Model>();
                list = db.SetCommand(strSql
                     , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                     , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                     , db.Parameter("@Available", true, DbType.Boolean)
                     ).ExecuteList<SupplierList_Model>();
                return list;
            }
        }

        /// <summary>
        /// 获取供应商详情
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public SupplierList_Model GetSubServiceDetail(SupplierList_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT T1.SupplierID,
                                          T1.SupplierName,
                                          T1.SupplierAddr,
                                          T1.SupplierTel,
                                          T1.SupplierContactName,
                                          T1.SupplierContactTel  
                                          FROM SUPPLIER T1 WHERE T1.CompanyID =@CompanyID 
                                          AND SupplierID=@SupplierID";
                if (model.BranchID > 0)
                {
                    strSql += "  AND T1.BranchID =@BranchID ";
                }
                SupplierList_Model detaillist = new SupplierList_Model();
                detaillist = db.SetCommand(strSql, db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                           , db.Parameter("@SupplierID", model.SupplierID, DbType.Int32)
                           , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteObject<SupplierList_Model>();
                return detaillist;
            }
        }
        public Supplier_Commodity_RELATION_Model GetSupplierDetail(Supplier_Commodity_RELATION_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select a.SupplierID, a.SupplierName
                                        from
                                            SUPPLIER a
                                            inner join SUPPLIER_COMMODITY_RELATIONSHIP b on b.SupplierID = a.SupplierID
                                            inner join COMMODITY c on c.Available = 1 and c.ID = b.CommodityID
                                        where a.Available = 1 
                                          AND a.SupplierName=@SupplierName 
                                          AND c.Code = @CommodityCode 
                                          AND a.CompanyID = @CompanyID ";

                Supplier_Commodity_RELATION_Model detaillist = null;
                detaillist = db.SetCommand(strSql,db.Parameter("@SupplierName", model.SupplierName, DbType.String)
                           , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                           , db.Parameter("@CommodityCode", model.CommodityCode, DbType.Int64)).ExecuteObject<Supplier_Commodity_RELATION_Model>();
                return detaillist;
            }
        }
        /// <summary>
        /// 供应商已存在
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool IsExsitSupplierName(SupplierList_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = " SELECT SupplierID FROM [SUPPLIER]  WHERE CompanyID=@CompanyID AND SupplierName=@SupplierName AND SupplierID<>@SupplierID ";

                int supplierID = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                               , db.Parameter("@SupplierName", model.SupplierName, DbType.String)
                               , db.Parameter("@SupplierID", model.SupplierID, DbType.Int32)).ExecuteScalar<int>();

                if (supplierID > 0)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }


        /// <summary>
        /// 修改供应商
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool UpdateSupplier(SupplierList_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                bool rs = false;
                string strSql = @"update SUPPLIER set 
                                 SupplierName = @SupplierName,
                                 SupplierAddr = @SupplierAddr,
                                 SupplierTel = @SupplierTel,
                                 SupplierContactName = @SupplierContactName,
                                 SupplierContactTel = @SupplierContactTel,
                                 UpdaterID=@UpdaterID,
                                 UpdateTime=@UpdateTime 
                                 where SupplierID=@SupplierID";

                rs = db.SetCommand(strSql
                   , db.Parameter("@SupplierName", model.SupplierName, DbType.String)
                   , db.Parameter("@SupplierAddr", model.SupplierAddr, DbType.String)
                   , db.Parameter("@SupplierTel", model.SupplierTel, DbType.String)
                   , db.Parameter("@SupplierContactName", model.SupplierContactName, DbType.String)
                   , db.Parameter("@SupplierContactTel", model.SupplierContactTel, DbType.String)
                   , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                   , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                   , db.Parameter("@SupplierID", model.SupplierID, DbType.Int32)).ExecuteNonQuery() > 0;

                if (!rs)
                {
                    db.RollbackTransaction();
                    return rs;
                }
                else
                {
                    db.CommitTransaction();
                    return rs;
                }
            }
        }

        /// <summary>
        /// 新增供应商
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool AddSupplier(SupplierList_Model model)
        {

            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                bool rs = false;             
                    string strSql = @"INSERT INTO [SUPPLIER]
                                    (CompanyID,BranchID,SupplierName,SupplierAddr,SupplierTel,SupplierContactName,SupplierContactTel,CreatorID,CreateTime,UpdaterID,UpdateTime,Available)
                                    VALUES
                                    (@CompanyID,@BranchID,@SupplierName,@SupplierAddr,@SupplierTel,@SupplierContactName,@SupplierContactTel,@CreatorID,@CreateTime,@UpdaterID,@UpdateTime,@Available)";
                    rs = db.SetCommand(strSql
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                        , db.Parameter("@SupplierName", model.SupplierName, DbType.String)
                        , db.Parameter("@SupplierAddr", model.SupplierAddr, DbType.String)
                        , db.Parameter("@SupplierTel", model.SupplierTel, DbType.String)
                        , db.Parameter("@SupplierContactName", model.SupplierContactName, DbType.String)
                        , db.Parameter("@SupplierContactTel", model.SupplierContactTel, DbType.String)
                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                        , db.Parameter("@CreateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                        , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                        , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                        , db.Parameter("@Available", true, DbType.Boolean)
                        ).ExecuteNonQuery() > 0;
                    if (!rs)
                    {
                        db.RollbackTransaction();
                        return rs;
                    }
                    else
                    {
                        db.CommitTransaction();
                        return rs;
                    }           
            }
        }

        /// <summary>
        /// 删除供应商
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool DeleteSupplier(SupplierList_Model model)
        {

            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                try
                {
                    string delSqlSupplier = @"DELETE SUPPLIER_COMMODITY_RELATIONSHIP WHERE SupplierID=@SupplierID";
                    bool rows = db.SetCommand(delSqlSupplier, db.Parameter("@SupplierID", model.SupplierID, DbType.Int32)).ExecuteNonQuery() > 0;

                    bool rs = false;
                    string delSql = @"update SUPPLIER set 
                                      Available = @Available,
                                      UpdaterID=@UpdaterID,
                                      UpdateTime=@UpdateTime 
                                      where SupplierID=@SupplierID ";
                    rs = db.SetCommand(delSql, db.Parameter("@Available", false, DbType.Boolean)
                       , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                       , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                       , db.Parameter("@SupplierID", model.SupplierID, DbType.Int32)
                        ).ExecuteNonQuery() > 0;
                    if (!rs)
                    {
                        db.RollbackTransaction();
                        return rs;
                    }
                    else
                    {
                        db.CommitTransaction();
                        return rs;
                    }
                }
                catch (Exception ex)
                {
                    db.RollbackTransaction();
                    return false;
                }
            }
        }

        /// <summary>
        /// 获取供应商列表
        /// </summary>
        /// <param name="Supplier_Model"></param>
        /// <returns></returns>
        public List<Supplier_Model> GetSupplierListForWeb(Supplier_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT T1.CompanyID,
                                          T1.BranchID,
                                          T1.SupplierID,
                                          T1.SupplierName,
                                          '|' + ISNULL(T1.SupplierName,'') 
                                          + '|' + ISNULL(T1.SupplierAddr,'') 
                                          + '|' + ISNULL(T1.SupplierContactName,'') 
                                          + '|' + ISNULL(T1.SupplierContactTel,'') 
                                          + '|' + ISNULL(T1.SupplierTel,'') AS SearchOut 
                                          FROM SUPPLIER T1 WHERE T1.Available = 1 AND T1.CompanyID =@CompanyID  ORDER BY T1.SupplierName ";
                List<Supplier_Model> list = new List<Supplier_Model>();
                list = db.SetCommand(strSql, db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteList<Supplier_Model>();

                return list;
            }
        }
    }
}
