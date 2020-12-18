using BLToolkit.Data;
using HS.Framework.Common;
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
    public class RoleCheck_DAL
    {
        #region 构造类实例
        public static RoleCheck_DAL Instance
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
            internal static readonly RoleCheck_DAL instance = new RoleCheck_DAL();
        }
        #endregion

        public bool checkIsCustomerOrder(int CustomerID, int OrderID)
        {

            using (DbManager db = new DbManager())
            {
                string strSqlCommand = @"
                                        select count(0) from [Order] 
                                        where CustomerID=@CustomerID 
                                        and ID=@OrderID";

                int rows = db.SetCommand(strSqlCommand, db.Parameter("@CustomerID", CustomerID, DbType.Int32)
                                          , db.Parameter("@OrderID", OrderID, DbType.Int32)).ExecuteScalar<int>();

                if (rows == 1)
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
        /// 获取订单的 责任人 开单人
        /// </summary>
        /// <param name="orderId"></param>
        /// <returns></returns>
        public GetOrderDetail_Model getOrderBasic(int orderId)
        {
            GetOrderDetail_Model model = new GetOrderDetail_Model();
            using (DbManager db = new DbManager())
            {

                string strSql = @"   SELECT    BranchID ,ResponsiblePersonID ,CreatorID
                                         FROM      dbo.[ORDER]
                                         WHERE     ID = @OrderID ";

                model = db.SetCommand(strSql, db.Parameter("@OrderID", orderId, DbType.Int32)).ExecuteObject<GetOrderDetail_Model>();

                return model;

            }
        }

        public List<Role_Model> getRoleList(int companyId)
        {
            List<Role_Model> list = new List<Role_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = @" select ID,RoleName,Jurisdictions from [TBL_ROLE] where CompanyID=@CompanyID and Available=1 ";
                list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteList<Role_Model>();
                return list;
            }
        }

        public Role_Model getRoleDetail(int companyID, int ID)
        {
            Role_Model model = new Role_Model();
            using (DbManager db = new DbManager())
            {
                string strSql = @" select ID,RoleName,Jurisdictions from [TBL_ROLE] where CompanyID=@CompanyID and Available=1 AND ID=@ID ";
                model = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)
                    , db.Parameter("@ID", ID, DbType.Int32)).ExecuteObject<Role_Model>();
                return model;
            }
        }

        public List<Jurisdiction_Model> getJurisdictionList(int companyID, string advanced, int roleID)
        {
            List<Jurisdiction_Model> list = new List<Jurisdiction_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = @" WITH    subQuery ( ID, Level )
                                      AS ( SELECT   ID ,
                                                    1 AS Level
                                           FROM     dbo.SYS_JURISDICTION
                                           WHERE    ParentID = 0
                                                    AND Available = 1
                                           UNION ALL
                                           SELECT   T1.ID ,
                                                    T2.Level + 1 AS Level
                                           FROM     SYS_JURISDICTION T1 ,
                                                    subQuery T2
                                           WHERE    T1.ParentID = T2.ID
                                         )
                                SELECT  T1.ID,T1.JurisdictionName,T1.Type,T1.ParentID,T1.Advanced
                                        , CASE when ( CHARINDEX('|'+CONVERT(VARCHAR,T1.ID)+'|',(SELECT Jurisdictions FROM TBL_ROLE T3 WHERE ID=@RoleID AND CompanyID=@CompanyID) ) > 0) THEN 1 ELSE 0 END AS IsExist 
                                        ,T2.Level
                                FROM    dbo.SYS_JURISDICTION T1
                                        INNER JOIN subQuery T2 ON T1.ID = T2.ID
                                WHERE   T1.Available = 1
                                        AND ( ISNULL(T1.Advanced, '') = ''
                                              OR CHARINDEX(Advanced, @Advanced) > 0
                                            )
                                ORDER BY T1.[Group],
                                         T1.ID ,
                                         T1.ParentID   ";
                list = db.SetCommand(strSql
                                    , db.Parameter("@Advanced", advanced, DbType.String)
                                    , db.Parameter("@RoleID", roleID, DbType.Int32)
                                    , db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<Jurisdiction_Model>();
                return list;
            }
        }

        public bool addRole(Role_Model model)
        {
            bool result = false;
            try
            {
                using (DbManager db = new DbManager())
                {
                    string strSqlCommand = @"INSERT INTO [TBL_ROLE]
                                           ([CompanyID]
                                           ,[RoleName]
                                           ,[Available]
                                           ,[Jurisdictions]
                                           ,[CreatorID]
                                           ,[CreateTime])
                                     VALUES
                                           (@CompanyID 
                                           ,@RoleName 
                                           ,@Available 
                                           ,@Jurisdictions 
                                           ,@CreatorID 
                                           ,@CreateTime) ";
                    int rows = db.SetCommand(strSqlCommand, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                          , db.Parameter("@RoleName", model.RoleName, DbType.String)
                                                          , db.Parameter("@Available", true, DbType.Boolean)
                                                          , db.Parameter("@Jurisdictions", model.Jurisdictions, DbType.String)
                                                          , db.Parameter("@CreatorID", model.OperatorID, DbType.Int32)
                                                          , db.Parameter("@CreateTime", model.OperatorTime, DbType.DateTime2)).ExecuteNonQuery();

                    if (rows == 1)
                    {
                        result = true;
                    }
                }
            }
            catch (Exception ex)
            {
                LogUtil.Error(ex);
            }
            return result;
        }

        public bool updateRole(Role_Model model)
        {
            bool result = false;

            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();
                    string strCommand = @" INSERT INTO [TBL_HISTORY_ROLE]
                                        select * from [TBL_ROLE] with(nolock)   
                                        where [TBL_ROLE].ID=@ID";

                    int rows = db.SetCommand(strCommand, db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 1)
                    {
                        string strSqlCommand = @"UPDATE [TBL_ROLE]
                                            SET [RoleName] = @RoleName
                                              ,[Jurisdictions] = @Jurisdictions
                                              ,[UpdaterID] = @UpdaterID
                                              ,[UpdateTime] = @UpdateTime
                                            WHERE ID =@ID ";
                        rows = db.SetCommand(strSqlCommand, db.Parameter("@RoleName", model.RoleName, DbType.String),
                                                                db.Parameter("@Jurisdictions", model.Jurisdictions, DbType.String),
                                                                db.Parameter("@UpdaterID", model.OperatorID, DbType.Int32),
                                                                db.Parameter("@UpdateTime", model.OperatorTime, DbType.DateTime2),
                                                                db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery();
                        if (rows == 1)
                        {
                            db.CommitTransaction();
                            result = true;
                        }
                        else
                        {
                            db.RollbackTransaction();
                        }
                    }
                }
                catch (Exception ex)
                {
                    db.RollbackTransaction();
                    LogUtil.Error(ex);
                }
            }

            return result;
        }

        public bool deleteRole(int roleId, int accountId)
        {
            bool result = false;
            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();
                    string strCommand = @" INSERT INTO [TBL_HISTORY_ROLE]
                                        select * from [TBL_ROLE] with(nolock)   
                                        where [TBL_ROLE].ID=@ID";

                    int rows = db.SetCommand(strCommand, db.Parameter("@ID", roleId, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 1)
                    {
                        strCommand = @"update TBL_ROLE 
                                       set Available = 0 ,
                                       UpdaterID=@UpdaterID,
                                       UpdateTime=@UpdateTime
                                       where ID=@ID";
                        rows = db.SetCommand(strCommand,
                            db.Parameter("@ID", roleId, DbType.Int32),
                            db.Parameter("@UpdaterID", accountId, DbType.Int32),
                            db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2)).ExecuteNonQuery();

                        if (rows == 1)
                        {
                            db.CommitTransaction();
                            result = true;
                        }
                        else
                        {
                            db.RollbackTransaction();
                        }
                    }
                    else
                    {
                        db.RollbackTransaction();
                    }
                }
                catch (Exception ex)
                {
                    db.RollbackTransaction();
                    LogUtil.Log(ex);
                }
            }
            return result;
        }

        public bool IsAccountHasTheRole(int companyID, int accountID, string strRole)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"SELECT  CASE T1.RoleID WHEN -1 THEN '-1' ELSE T2.Jurisdictions END AS Jurisdictions
                                    FROM    [ACCOUNT] T1
                                            LEFT JOIN [TBL_ROLE] T2 ON T1.RoleID = T2.ID
                                    WHERE   T1.CompanyID = @CompanyID
                                            AND T1.UserID = @AccountID";
                string jurisdictions = db.SetCommand(strSql
                                     , db.Parameter("@CompanyID", companyID, DbType.Int32)
                                     , db.Parameter("@AccountID", accountID, DbType.Int32)).ExecuteScalar<string>();

                if (string.IsNullOrWhiteSpace(jurisdictions))
                {
                    return false;
                }

                if (jurisdictions == "-1")
                {
                    return true;
                }

                if (jurisdictions.Contains(strRole))
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
        }
    }
}
