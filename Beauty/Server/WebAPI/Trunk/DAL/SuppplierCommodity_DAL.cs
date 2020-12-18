using BLToolkit.Data;
using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL
{
    public class SuppplierCommodity_DAL
    {
        #region 构造类实例
        public static SuppplierCommodity_DAL Instance
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
            internal static readonly SuppplierCommodity_DAL instance = new SuppplierCommodity_DAL();
        }
        #endregion
        /// <summary>
        /// 获取供应商商品列表
        /// </summary>
        /// <param name="companyID"></param>
        /// <param name="companyId"></param>
        /// <returns></returns>
        public List<SupplierCommodity_Model> GetSupplierCommodityList(SupplierCommodity_Model model)
        {
            using (DbManager db = new DbManager())
            {
                //已经选择的
                string strSqlRelat = @" SELECT T2.ID CommodityID,T1.SupplierID,T2.CommodityName,
                                               CASE WHEN T1.CommodityID IS NULL THEN 0 ELSE 1 END AS isChecked,
                                               '|' + ISNULL(T2.CommodityName,'') 
                                              +'|' + ISNULL(convert(varchar(32),T2.Code),'') 
                                              +'|' + ISNULL(T2.Manufacturer,'') 
                                              +'|' + ISNULL(T2.ApprovalNumber,'') AS SearchOut
 
                                               FROM commodity T2
                                               LEFT JOIN SUPPLIER_COMMODITY_RELATIONSHIP T1 ON T1.CommodityID = T2.ID
                                               AND T1.SupplierID = @SupplierID
                                               WHERE T2.CompanyID = @CompanyID AND T2.Available = 1
                                               ORDER BY CASE WHEN T1.CommodityID IS NULL THEN 1 ELSE 0 END,T2.CommodityName";

                List<SupplierCommodity_Model> listRelat = new List<SupplierCommodity_Model>();
                listRelat = db.SetCommand(strSqlRelat, db.Parameter("@SupplierID", model.SupplierID, DbType.Int32)
                          , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteList<SupplierCommodity_Model>();

                return listRelat;
            }
        }

        /// <summary>
        ///更新供应商商品
        /// </summary>
        /// <param name=SupplierCommodity_Model"></param>
        /// <returns></returns>
        public bool ChangeSupplierCommodity(SupplierCommodity_Model model)
        {
            using (DbManager db = new DbManager())
            {
                try
                {
                    int rows = 0;
                    int checkCount = 0;
                    //删除某个供应商的所有供应商商品关系
                    string strSqldel = @" delete from  [SUPPLIER_COMMODITY_RELATIONSHIP] where SupplierID=@SupplierID  ";
                    //再添加某个供应商的所有供应商商品关系
                    string strSqlAdd = @"insert into SUPPLIER_COMMODITY_RELATIONSHIP(
                            CreatorID,CreateTime,UpdaterID,UpdateTime,SupplierID,CommodityID)
                             values (
                            @CreatorID,@CreateTime,@UpdaterID,@UpdateTime,@SupplierID,@CommodityID)";

                    if (model.ListSupplierID != null && model.ListSupplierID.Count > 0)
                    {
                        foreach (int SupplierID in model.ListSupplierID)
                        {
                            checkCount = db.SetCommand(strSqldel, db.Parameter("@SupplierID", SupplierID, DbType.Int32)).ExecuteScalar<int>();
                            if (model.ListCommodityID != null && model.ListCommodityID.Count > 0)
                            {
                                foreach (int CommodityID in model.ListCommodityID)
                                {
                                    rows = db.SetCommand(strSqlAdd, db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                         , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                                         , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                         , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                                         , db.Parameter("@SupplierID", SupplierID, DbType.Int32)
                                         , db.Parameter("@CommodityID", CommodityID, DbType.Int32)
                                         ).ExecuteNonQuery();

                                    if (rows == 0)
                                    {
                                        db.RollbackTransaction();
                                        return false;
                                    }

                                }

                            }
                        }
                    }
                    db.CommitTransaction();
                    return true;
                }
                catch (Exception ex)
                {
                    db.RollbackTransaction();
                    throw;
                }
            }
        }
    }
}
