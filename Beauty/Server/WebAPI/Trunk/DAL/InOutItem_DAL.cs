using BLToolkit.Data;
using Model.Operation_Model;
using Model.Table_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace WebAPI.DAL
{
    public class InOutItem_DAL
    {
        #region 构造类实例
        public static InOutItem_DAL Instance
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
            internal static readonly InOutItem_DAL instance = new InOutItem_DAL();
        }
        #endregion

        /// <summary>
        /// 获取公司下面所有大项目
        /// </summary>
        /// <param name="CompanyID">公司ID</param>
        /// <returns></returns>
        public List<InOutItemA_Model> GetInOutItemAList(int CompanyID)
        {
            List<InOutItemA_Model> list = new List<InOutItemA_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = " SELECT CompanyID,ItemAID,ItemAName FROM [InOutItemA] T1 WITH(NOLOCK) WHERE CompanyID=@CompanyID AND Available = '1'";
                list = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteList<InOutItemA_Model>();
                return list;
            }
        }

        /// <summary>
        /// 获取大项目下面所有中项目
        /// </summary>
        /// <param name="ItemAID">大项目ID</param>
        /// <returns></returns>
        public List<InOutItemB_Model> GetInOutItemBList(int ItemAID)
        {
            List<InOutItemB_Model> list = new List<InOutItemB_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = " SELECT ItemAID,ItemBID,ItemBName FROM [InOutItemB] T1 WITH(NOLOCK) WHERE ItemAID=@ItemAID AND Available = '1'";
                list = db.SetCommand(strSql, db.Parameter("@ItemAID", ItemAID, DbType.Int32)).ExecuteList<InOutItemB_Model>();
                return list;
            }
        }
        /// <summary>
        /// 获取中项目下面所有小项目
        /// </summary>
        /// <param name="ItemBID">中项目ID</param>
        /// <returns></returns>
        public List<InOutItemC_Model> GetInOutItemCList(int ItemBID)
        {
            List<InOutItemC_Model> list = new List<InOutItemC_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = " SELECT ItemBID,ItemCID,ItemCName FROM [InOutItemC] T1 WITH(NOLOCK) WHERE ItemBID=@ItemBID AND Available = '1'";
                list = db.SetCommand(strSql, db.Parameter("@ItemBID", ItemBID, DbType.Int32)).ExecuteList<InOutItemC_Model>();
                return list;
            }
        }

        /// <summary>
        /// 新增大项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool AddInOutItemA(InOutItemAOperation_Model model)
        {

            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                bool rs = false;
                DateTime dateNow = DateTime.Now.ToLocalTime();
                string strSqlAdd = @"INSERT INTO [InOutItemA]
                                    (COMPANYID,ItemAName,CreatorID,CreateTime,UpdaterID,UpdateTime,Available)
                                    VALUES
                                    (@COMPANYID,@ItemAName,@CreatorID,@CreateTime,@UpdaterID,@UpdateTime,@Available)";
                rs = db.SetCommand(strSqlAdd
                    , db.Parameter("@COMPANYID", model.COMPANYID, DbType.Int32)
                    , db.Parameter("@ItemAName", model.ItemAName, DbType.String)
                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                    , db.Parameter("@CreateTime", dateNow, DbType.DateTime2)
                    , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                    , db.Parameter("@UpdateTime", dateNow, DbType.DateTime2)
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
        /// 编辑大项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool UpdateInOutItemA(InOutItemAOperation_Model model)
        {

            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                bool rs = false;
                DateTime dateNow = DateTime.Now.ToLocalTime();
                String strSqlEdit = @"UPDATE InOutItemA SET ItemAName=@ItemAName,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime WHERE ItemAID=@ItemAID";
                rs = db.SetCommand(strSqlEdit
                    , db.Parameter("@ItemAID", model.ItemAID, DbType.Int32)
                    , db.Parameter("@ItemAName", model.ItemAName, DbType.String)
                    , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                    , db.Parameter("@UpdateTime", dateNow, DbType.DateTime2)
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
        /// 添加中项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool AddInOutItemB(InOutItemBOperation_Model model)
        {

            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                bool rs = false;
                DateTime dateNow = DateTime.Now.ToLocalTime();
                string strSqlAdd = @"INSERT INTO [InOutItemB]
                                    (ItemAID,ItemBName,CreatorID,CreateTime,UpdaterID,UpdateTime,Available)
                                    VALUES
                                    (@ItemAID,@ItemBName,@CreatorID,@CreateTime,@UpdaterID,@UpdateTime,@Available)";
                rs = db.SetCommand(strSqlAdd
                    , db.Parameter("@ItemAID", model.ItemAID, DbType.Int32)
                    , db.Parameter("@ItemBName", model.ItemBName, DbType.String)
                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                    , db.Parameter("@CreateTime", dateNow, DbType.DateTime2)
                    , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                    , db.Parameter("@UpdateTime", dateNow, DbType.DateTime2)
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
        /// 编辑中项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool UpdateInOutItemB(InOutItemBOperation_Model model)
        {

            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                bool rs = false;
                DateTime dateNow = DateTime.Now.ToLocalTime();
                String strSqlEdit = @"UPDATE InOutItemB SET ItemBName=@ItemBName,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime WHERE ItemBID=@ItemBID";
                rs = db.SetCommand(strSqlEdit
                   , db.Parameter("@ItemBID", model.ItemBID, DbType.Int32)
                   , db.Parameter("@ItemBName", model.ItemBName, DbType.String)
                   , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                   , db.Parameter("@UpdateTime", dateNow, DbType.DateTime2)
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
        /// 添加小项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool AddInOutItemC(InOutItemCOperation_Model model)
        {

            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                bool rs = false;
                DateTime dateNow = DateTime.Now.ToLocalTime();
                string strSqlAdd = @"INSERT INTO [InOutItemC]
                                    (ItemBID,ItemCName,CreatorID,CreateTime,UpdaterID,UpdateTime,Available)
                                    VALUES
                                    (@ItemBID,@ItemCName,@CreatorID,@CreateTime,@UpdaterID,@UpdateTime,@Available)";
                rs = db.SetCommand(strSqlAdd
                    , db.Parameter("@ItemBID", model.ItemBID, DbType.Int32)
                    , db.Parameter("@ItemCName", model.ItemCName, DbType.String)
                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                    , db.Parameter("@CreateTime", dateNow, DbType.DateTime2)
                    , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                    , db.Parameter("@UpdateTime", dateNow, DbType.DateTime2)
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
        /// 编辑小项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool UpdateInOutItemC(InOutItemCOperation_Model model)
        {

            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                bool rs = false;
                DateTime dateNow = DateTime.Now.ToLocalTime();
                String strSqlEdit = @"UPDATE InOutItemC SET ItemCName=@ItemCName,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime WHERE ItemCID=@ItemCID";
                rs = db.SetCommand(strSqlEdit
                    , db.Parameter("@ItemCID", model.ItemCID, DbType.Int32)
                    , db.Parameter("@ItemCName", model.ItemCName, DbType.String)
                    , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                    , db.Parameter("@UpdateTime", dateNow, DbType.DateTime2)
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
        /// 删除大项目
        /// </summary>
        /// <param name="ItemAID"></param>
        /// <returns></returns>
        public bool DeleteInOutItemA(int ItemAID)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                try
                {
                    //查询ItemAID下面所有ItemBID(获取大项目下面所有中项目)
                    List<InOutItemB_Model> inOutItemBList = GetInOutItemBList(ItemAID);
                    string delSqlInOutItemC = @"UPDATE InOutItemC SET Available = @Available WHERE ItemBID IN (";
                    string delSqlInOutItemB = @"UPDATE InOutItemB SET Available = @Available WHERE ItemAID=@ItemAID";
                    string delSqlInOutItemA = @"UPDATE InOutItemA SET Available = @Available WHERE ItemAID=@ItemAID";
                    if (inOutItemBList !=null && inOutItemBList.Count > 0) {
                        for (int i=0;i< inOutItemBList.Count;i++) {
                            if (i == inOutItemBList.Count - 1)
                            {
                                delSqlInOutItemC += "'" + inOutItemBList[i].ItemBID + "'";
                            }
                            else {
                                delSqlInOutItemC += "'" + inOutItemBList[i].ItemBID + "',";
                            }
                            
                        }
                        delSqlInOutItemC += ")";
                        //删除小项目
                        db.SetCommand(delSqlInOutItemC,db.Parameter("@Available", false, DbType.Boolean)).ExecuteNonQuery();
                    }
                    //删除中项目
                    db.SetCommand(delSqlInOutItemB
                        ,db.Parameter("@Available", false, DbType.Boolean)
                        ,db.Parameter("@ItemAID", ItemAID, DbType.Int32)).ExecuteNonQuery();
                    //删除大项目
                    bool rs = db.SetCommand(delSqlInOutItemA
                        , db.Parameter("@Available", false, DbType.Boolean)
                        , db.Parameter("@ItemAID", ItemAID, DbType.Int32)).ExecuteNonQuery() > 0;
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
        /// 删除中项目
        /// </summary>
        /// <param name="ItemBID"></param>
        /// <returns></returns>
        public bool DeleteInOutItemB(int ItemBID)
        {

            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                try
                {
                    string delSqlInOutItemC = @"UPDATE InOutItemC SET Available =@Available WHERE ItemBID=@ItemBID";
                    string delSqlInOutItemB = @"UPDATE InOutItemB SET Available =@Available WHERE ItemBID=@ItemBID";
                    db.SetCommand(delSqlInOutItemC
                        , db.Parameter("@Available", false, DbType.Boolean)
                        , db.Parameter("@ItemBID", ItemBID, DbType.Int32)).ExecuteNonQuery();
                    bool rs = db.SetCommand(delSqlInOutItemB
                        , db.Parameter("@Available", false, DbType.Boolean)
                        , db.Parameter("@ItemBID", ItemBID, DbType.Int32)).ExecuteNonQuery() > 0;
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
        /// 删除小项目
        /// </summary>
        /// <param name="ItemCID"></param>
        /// <returns></returns>
        public bool DeleteInOutItemC(int ItemCID)
        {

            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                try
                {
                    string delSqlInOutItemC = @"UPDATE InOutItemC SET Available = @Available WHERE ItemCID=@ItemCID";
                    bool rs = db.SetCommand(delSqlInOutItemC
                        , db.Parameter("@Available", false, DbType.Boolean)
                        , db.Parameter("@ItemCID", ItemCID, DbType.Int32)).ExecuteNonQuery() > 0;
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
        /// 判断是否存在同名的大类项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool FindInOutItemASameItemAName(InOutItemA_Model model) {
            using (DbManager db = new DbManager())
            {
                string SelectSqlInOutItemA = @"SELECT CompanyID,ItemAID,ItemAName FROM InOutItemA WHERE CompanyID = @CompanyID AND ItemAName = @ItemAName AND Available ='1' ";
                if (model.ItemAID > 0) {
                    SelectSqlInOutItemA += @" AND ItemAID !=@ItemAID ";
                }
                return db.SetCommand(SelectSqlInOutItemA
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@ItemAID", model.ItemAID, DbType.Int32)
                    , db.Parameter("@ItemAName", model.ItemAName, DbType.String)).ExecuteList<InOutItemA_Model>().Count >0;
            }
        }
        /// <summary>
        /// 判断是否存在同名的中类项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool FindInOutItemBSameItemBName(InOutItemB_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string SelectSqlInOutItemB = @"SELECT ItemAID,ItemBID,ItemBName FROM InOutItemB WHERE ItemAID =@ItemAID AND ItemBName = @ItemBName AND Available ='1' ";
                if (model.ItemBID > 0)
                {
                    SelectSqlInOutItemB += @" AND ItemBID !=@ItemBID ";
                }
                return db.SetCommand(SelectSqlInOutItemB
                    , db.Parameter("@ItemAID", model.ItemAID, DbType.Int32)
                    , db.Parameter("@ItemBID", model.ItemBID, DbType.Int32)
                    , db.Parameter("@ItemBName", model.ItemBName, DbType.String)).ExecuteList<InOutItemB_Model>().Count > 0;
            }
        }
        /// <summary>
        /// 判断是否存在同名的小类项目
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool FindInOutItemCSameItemCName(InOutItemC_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string SelectSqlInOutItemC = @"SELECT ItemBID,ItemCID,ItemCName FROM InOutItemC WHERE ItemBID =@ItemBID AND ItemCName = @ItemCName AND Available ='1' ";
                if (model.ItemCID > 0)
                {
                    SelectSqlInOutItemC += @" AND ItemCID !=@ItemCID ";
                }
                return db.SetCommand(SelectSqlInOutItemC
                    , db.Parameter("@ItemBID", model.ItemBID, DbType.Int32)
                    , db.Parameter("@ItemCID", model.ItemCID, DbType.Int32)
                    , db.Parameter("@ItemCName", model.ItemCName, DbType.String)).ExecuteList<InOutItemC_Model>().Count > 0;
            }
        }
    }
}
