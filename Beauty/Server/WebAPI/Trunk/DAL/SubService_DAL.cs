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
    public class SubService_DAL
    {
        #region 构造类实例
        public static SubService_DAL Instance
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
            internal static readonly SubService_DAL instance = new SubService_DAL();
        }
        #endregion

        /// <summary>
        /// 获取子服务列表
        /// </summary>
        /// <param name="CompanyID"></param>
        /// <returns></returns>
        public List<SubService_Model> GetSubServiceList(int CompanyID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  [TBL_SUBSERVICE].SubServiceCode ,
                                [TBL_SUBSERVICE].CompanyID ,
                                [TBL_SUBSERVICE].ID ,
                                [TBL_SUBSERVICE].SubServiceName ,
                                [TBL_SUBSERVICE].VisitTime ,
                                [TBL_SUBSERVICE].NeedVisit ,
                                [TBL_SUBSERVICE].SpendTime
                        FROM    [TBL_SUBSERVICE] WITH ( NOLOCK )
                        WHERE   [TBL_SUBSERVICE].ID IN ( SELECT MAX(ID)
                                                         FROM   [TBL_SUBSERVICE]
                                                         WHERE  CompanyID=@CompanyID and Available = 1
                                                         GROUP BY [TBL_SUBSERVICE].SubServiceCode )
                                AND [TBL_SUBSERVICE].CompanyID = @CompanyID AND Available=1";
                return db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteList<SubService_Model>();
            }
        }

        /// <summary>
        /// 获取子服务详情
        /// </summary>
        /// <param name="CompanyID"></param>
        /// <param name="SubServiceCode"></param>
        /// <returns></returns>
        public SubService_Model GetSubServiceDetail(int CompanyID, long SubServiceCode)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  [TBL_SUBSERVICE].SubServiceCode ,
                                            [TBL_SUBSERVICE].CompanyID ,
                                            [TBL_SUBSERVICE].ID ,
                                            [TBL_SUBSERVICE].SubServiceName ,
                                            [TBL_SUBSERVICE].VisitTime ,
                                            [TBL_SUBSERVICE].NeedVisit ,
                                            [TBL_SUBSERVICE].SpendTime
                                    FROM    [TBL_SUBSERVICE] WITH ( NOLOCK )
                                    WHERE   CompanyID=@CompanyID and SubServiceCode=@SubServiceCode AND Available=1";
                SubService_Model mode = db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int64),
                    db.Parameter("@SubServiceCode", SubServiceCode, DbType.Int64)).ExecuteObject<SubService_Model>();
                return mode;
            }
        }

        /// <summary>
        /// 修改子服务
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool UpdateSubService(SubService_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                int maxID = db.SetCommand("SELECT MAX(id) ID FROM dbo.TBL_SUBSERVICE WHERE CompanyID=@CompanyID AND SubServiceCode=@SubServiceCode AND Available=1"
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@SubServiceCode", model.SubServiceCode, DbType.Int64)).ExecuteScalar<int>();
                string strSqlTreatment = @"select COUNT(ID) from SCHEDULE where SubServiceID =@SubServiceID ";
                int rows = db.SetCommand(strSqlTreatment, db.Parameter("@SubServiceID", maxID, DbType.Int32)).ExecuteScalar<int>();
                bool rs = false;
                if (rows == 0)
                {
                    string strSqlInsertHistory = @"INSERT INTO TBL_HISTORY_SubService SELECT * FROM TBL_SubService WHERE ID =@ID";
                    rs = db.SetCommand(strSqlInsertHistory, db.Parameter("@ID", maxID)).ExecuteNonQuery() > 0;
                    if (!rs)
                    {
                        db.RollbackTransaction();
                        return rs;
                    }

                    string strSqlUpdate = @"Update [TBL_SubService]
                                    set SubServiceName=@SubServiceName
                                    ,VisitTime=@VisitTime
                                    ,NeedVisit=@NeedVisit
                                    ,SpendTime=@SpendTime
                                    ,UpdaterID=@UpdaterID
                                    ,UpdateTime=@UpdateTime
                                    where ID =@ID AND CompanyID=@CompanyID";
                    rs = db.SetCommand(strSqlUpdate
                        , db.Parameter("@SubServiceName", model.SubServiceName, DbType.String)
                        , db.Parameter("@VisitTime", model.VisitTime == -1 ? (object)DBNull.Value : model.VisitTime, DbType.Int32)
                        , db.Parameter("@NeedVisit", model.NeedVisit, DbType.Boolean)
                        , db.Parameter("@SpendTime", model.SpendTime, DbType.Int32)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                        , db.Parameter("@ID", maxID, DbType.Int32)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery() > 0;
                    if (!rs)
                    {
                        db.RollbackTransaction();
                        return rs;
                    }
                    db.CommitTransaction();
                    return rs;
                }
                else
                {
                    string strSqlDelete = @"Update [TBL_SubService]
                                    set Available=@Available
                                    ,UpdaterID=@UpdaterID
                                    ,UpdateTime=@UpdateTime
                                    where ID =@ID AND CompanyID=@CompanyID";
                    rs = db.SetCommand(strSqlDelete
                        , db.Parameter("@Available", false, DbType.Boolean)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)
                        , db.Parameter("@ID", maxID, DbType.Int32)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery() > 0;
                    if (!rs)
                    {
                        db.RollbackTransaction();
                        return rs;
                    }

                    string strSqlCreatInfo = @" select CreatorID,CreateTime from [TBL_SUBSERVICE] where ID =@ID AND CompanyID=@CompanyID ";
                    SubService_Model temp = db.SetCommand(strSqlCreatInfo
                        , db.Parameter("@ID", maxID, DbType.Int32)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteObject<SubService_Model>();

                    if (temp == null) {
                        db.RollbackTransaction();
                        return rs;
                    }

                    model.CreatorID = temp.CreatorID;
                    model.CreateTime = temp.CreateTime;

                    string strSqlInsert = @"INSERT INTO [TBL_SubService]
                                    (CompanyID,SubServiceCode,SubServiceName,VisitTime,NeedVisit,SpendTime,Available,CreatorID,CreateTime,UpdaterID,UpdateTime)
                                    VALUES
                                    (@CompanyID,@SubServiceCode,@SubServiceName,@VisitTime,@NeedVisit,@SpendTime,@Available,@CreatorID,@CreateTime,@UpdaterID,@UpdateTime)
                                    ";
                    rs = db.SetCommand(strSqlInsert
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@SubServiceCode", model.SubServiceCode, DbType.Int64)
                        , db.Parameter("@SubServiceName", model.SubServiceName, DbType.String)
                        , db.Parameter("@VisitTime", model.VisitTime == -1 ? (object)DBNull.Value : model.VisitTime, DbType.Int32)
                        , db.Parameter("@NeedVisit", model.NeedVisit, DbType.Boolean)
                        , db.Parameter("@SpendTime", model.SpendTime, DbType.Int32)
                        , db.Parameter("@Available", true, DbType.Boolean)
                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                        , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                        , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)).ExecuteNonQuery() > 0;
                    if (!rs)
                    {
                        db.RollbackTransaction();
                        return rs;
                    }
                    db.CommitTransaction();
                    return rs;
                }
            }

        }

        /// <summary>
        /// 新增子服务
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool AddSubService(SubService_Model model)
        {

            using (DbManager db = new DbManager())
            {
                bool rs = false;
                db.BeginTransaction();
                long SubServiceCode = db.SetSpCommand("GetSerialNo", db.Parameter("@TableName", "SubServiceCode", DbType.String), db.OutputParameter("@Result", DbType.String)).ExecuteScalar<long>();
                if (SubServiceCode == 0)
                {
                    db.RollbackTransaction();
                    return rs;
                }
                string strSql = @"INSERT INTO [TBL_SubService]
                                    (CompanyID,SubServiceCode,SubServiceName,VisitTime,NeedVisit,SpendTime,Available,CreatorID,CreateTime)
                                    VALUES
                                    (@CompanyID,@SubServiceCode,@SubServiceName,@VisitTime,@NeedVisit,@SpendTime,@Available,@CreatorID,@CreateTime)
                                    ";
                rs = db.SetCommand(strSql
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@SubServiceCode", SubServiceCode, DbType.Int64)
                    , db.Parameter("@SubServiceName", model.SubServiceName, DbType.String)
                    , db.Parameter("@VisitTime", model.VisitTime == -1 ? (object)DBNull.Value : model.VisitTime, DbType.Int32)
                    , db.Parameter("@NeedVisit", model.NeedVisit, DbType.Boolean)
                    , db.Parameter("@SpendTime", model.SpendTime, DbType.Int32)
                    , db.Parameter("@Available", true, DbType.Boolean)
                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                    , db.Parameter("@CreateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)).ExecuteNonQuery() > 0;
                if (!rs)
                {
                    db.RollbackTransaction();
                    return rs;
                }
                else {
                    db.CommitTransaction();
                    return rs;
                }                
            }

        }
    }
}
