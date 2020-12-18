using BLToolkit.Data;
using HS.Framework.Common;
using Model.Operation_Model;
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
    public class Record_DAL
    {

        #region 构造类实例
        public static Record_DAL Instance
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
            internal static readonly Record_DAL instance = new Record_DAL();
        }
        #endregion



        /// <summary>
        /// 
        /// </summary>
        /// <param name="CustomerID"></param>
        /// <param name="userType"></param>
        /// <param name="tagIDs"></param>
        /// <returns></returns>
        public List<RecordListByCustomerID_Model> getRecordListByCustomerID(int CustomerID, bool IsBusiness, string tagIDs)
        {
            List<RecordListByCustomerID_Model> list = new List<RecordListByCustomerID_Model>();

            using (DbManager db = new DbManager())
            {
                StringBuilder strSql = new StringBuilder();
                strSql.Append(" select T2.Name CreatorName, T1.CreatorID,T1.ID RecordID, LEFT(T1.RecordTime,10) RecordTime,T1.Problem,T1.Suggestion,LEFT(T6.TagName,LEN(T6.TagName)-1) as TagName ");
                if (IsBusiness)
                {
                    strSql.Append(" ,T1.IsVisible ");
                }
                strSql.Append(" FROM RECORD T1 ");
                strSql.Append(" LEFT JOIN ACCOUNT T2 ON ");
                strSql.Append(" T2.UserID = T1.CreatorID ");
                strSql.Append(@" LEFT JOIN  ( SELECT  T4.TagIDs ,
                                                         ( SELECT    T5.Name + '|'
                                                           FROM      dbo.TBL_TAG T5
                                                           WHERE     CHARINDEX('|' + CONVERT(VARCHAR, T5.ID) + '|', T4.TagIDs) > 0
                                                                     AND Available = 1
                                                         FOR
                                                           XML PATH('')
                                                         ) AS TagName
                                                 FROM    dbo.RECORD T4
                                                 WHERE   T4.Available = 1
                                                 GROUP BY T4.TagIDs ) T6 On T1.TagIDs = T6.TagIDs ");
                strSql.Append(" Where T1.CustomerID = @CustomerID ");
                strSql.Append(" AND T1.Available = 1 ");

                if (!IsBusiness)
                {
                    strSql.Append(" AND T1.IsVisible = 1 ");
                }

                if (!string.IsNullOrEmpty(tagIDs))
                {
                    string[] str = tagIDs.Split('|');
                    string strSqlPart = "";
                    //TagIDs ="|0|" 取没有标签的记录
                    if (tagIDs == "|0|")
                    {
                        strSqlPart = " and IsNull(T1.TagIDs,'')='' ";
                    }
                    else
                    {
                        for (int i = 0; i < str.Length; i++)
                        {
                            if (!string.IsNullOrEmpty(str[i]))
                            {
                                strSqlPart += " AND CHARINDEX( '" + "|" + str[i] + "|'" + ",T1.TagIDs)>0 ";
                            }
                        }
                    }
                    strSql.Append(strSqlPart);
                }

                strSql.Append(" ORDER BY RecordTime DESC,T1.CreateTime desc ");

                list = db.SetCommand(strSql.ToString(), db.Parameter("@CustomerID", CustomerID, DbType.Int32)
                                                      , db.Parameter("@TagIDs", tagIDs, DbType.String)).ExecuteList<RecordListByCustomerID_Model>();
                return list;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="operationModel"></param>
        /// <param name="pageSize"></param>
        /// <param name="pageIndex"></param>
        /// <param name="recordCount"></param>
        /// <returns></returns>
        public List<RecordList> getRecordListByAccountID(UtilityOperation_Model operationModel, int pageSize, int pageIndex, out int recordCount)
        {
            recordCount = 0;
            List<RecordList> list = new List<RecordList>();

            using (DbManager db = new DbManager())
            {
                string fileds = @" ROW_NUMBER() OVER ( ORDER BY T1.RecordTime DESC, T1.CreateTime DESC ) AS rowNum ,
                                                  T2.UserID AS CustomerID ,T2.Name AS CustomerName ,T1.ID AS RecordID , CONVERT(VARCHAR(10), T1.RecordTime) AS RecordTime ,T1.Problem ,T1.Suggestion ,T1.IsVisible,T3.Name AS ResponsiblePersonName,LEFT(T6.TagName,LEN(T6.TagName)-1) as TagName ";

                if (operationModel.BranchID > 0)
                {
                    fileds += " ,( CASE WHEN T1.BranchID=" + operationModel.BranchID + " THEN 1 ELSE 0 END ) AS IsThisBranch ";
                }
                else
                {
                    fileds += " ,0 AS IsThisBranch ";
                }

                string strSQL = @"SELECT  {0}  FROM    RECORD T1
                                    LEFT JOIN [CUSTOMER] T2 ON T2.UserID = T1.CustomerID
                                    LEFT JOIN [ACCOUNT] T3 WITH(NOLOCK) ON T1.ResponsiblePersonID=T3.UserID                                    
                                    LEFT JOIN  ( SELECT  T4.TagIDs ,
                                                        ( SELECT    T5.Name + '|'
                                                          FROM      dbo.TBL_TAG T5
                                                          WHERE     CHARINDEX('|' + CONVERT(VARCHAR, T5.ID) + '|', T4.TagIDs) > 0
                                                                    AND Available = 1
                                                        FOR
                                                          XML PATH('')
                                                        ) AS TagName
                                                FROM    dbo.RECORD T4
                                                WHERE   T4.Available = 1
                                                GROUP BY T4.TagIDs ) T6 On T1.TagIDs = T6.TagIDs
                            WHERE   T1.CompanyID = @CompanyID
                                    AND T1.Available = 1";

                if (operationModel.BranchID > 0)
                {
                    strSQL += " AND T1.BranchID = " + operationModel.BranchID;
                }

                if (operationModel.RecordID > 0 && operationModel.PageIndex > 1)
                {
                    strSQL += " AND T1.ID <= " + operationModel.RecordID;
                }

                if (operationModel.FilterByTimeFlag == 1)
                {

                    strSQL += Common.SqlCommon.getSqlWhereData_1_7_2(4, operationModel.StartTime, operationModel.EndTime, " T1.RecordTime");
                }

                //筛选 当前责任人的咨询记录
                if (operationModel.ResponsiblePersonID > 0)
                {
                    strSQL += " AND T1.ResponsiblePersonID = " + operationModel.ResponsiblePersonID;
                }

                //左边菜单 CustomerID = 0 筛选与相关的咨询记录 
                //右边菜单 CustomerID > 0 筛选与顾客相关的咨询记录 
                if (operationModel.CustomerID > 0)
                {
                    strSQL += " AND T1.CustomerID = " + operationModel.CustomerID;
                }
                else
                {
                    strSQL += @" AND ( T1.ResponsiblePersonID =@AccountID Or T1.ResponsiblePersonID IN (
                                                                                           SELECT
                                                                                                fn_CustomerNamesInRegion.SubordinateID
                                                                                           FROM fn_CustomerNamesInRegion(@AccountID,
                                                                                                @BranchID) )) ";
                }

                if (!string.IsNullOrEmpty(operationModel.TagIDs))
                {
                    string[] str = operationModel.TagIDs.Split('|');
                    string strSqlPart = "";

                    if (operationModel.TagIDs == "|0|")
                    {
                        strSqlPart = " and IsNull(T1.TagIDs,'')='' ";
                    }
                    else
                    {
                        for (int i = 0; i < str.Length; i++)
                        {
                            if (!string.IsNullOrEmpty(str[i]))
                            {
                                strSqlPart += " AND CHARINDEX( '" + "|" + str[i] + "|'" + ",T1.TagIDs)>0 ";
                            }
                        }
                    }

                    strSQL += strSqlPart;
                }

                string strCountSql = string.Format(strSQL, " count(0) ");

                string strgetListSql = "select * from( " + string.Format(strSQL, fileds) + " ) a where  rowNum between  " + ((pageIndex - 1) * pageSize + 1) + " and " + pageIndex * pageSize;

                recordCount = db.SetCommand(strCountSql, db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)
                    , db.Parameter("@AccountID", operationModel.AccountID, DbType.Int32)
                    , db.Parameter("@BranchID", operationModel.BranchID, DbType.Int32)).ExecuteScalar<int>();

                if (recordCount < 0)
                {
                    return null;
                }

                list = db.SetCommand(strgetListSql, db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)
                                                  , db.Parameter("@AccountID", operationModel.AccountID, DbType.Int32)
                                                  , db.Parameter("@BranchID", operationModel.BranchID, DbType.Int32)).ExecuteList<RecordList>();

                return list;

            }
        }

        /// <summary>
        /// 增加一条Record数据
        /// </summary>
        public bool addRecord(Record_Model model)
        {

            using (DbManager db = new DbManager())
            {
                string strSql =
                              @"insert into RECORD(
                           CompanyID,BranchID, CustomerID,RecordTime,Problem,Suggestion,Available,CreatorID,CreateTime,IsVisible,ResponsiblePersonID,TagIDs)
                            values (
                           @CompanyID,@BranchID, @CustomerID,@RecordTime,@Problem,@Suggestion,@Available,@CreatorID,@CreateTime,@IsVisible,@ResponsiblePersonID,@TagIDs)
                           ;select @@IDENTITY";

                int obj = db.SetCommand(strSql,
                    db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                , db.Parameter("@RecordTime", model.RecordTime, DbType.DateTime)
                , db.Parameter("@Problem", model.Problem, DbType.String)
                , db.Parameter("@Suggestion", model.Suggestion, DbType.String)
                , db.Parameter("@Available", true, DbType.Boolean)
                , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime)
                , db.Parameter("@IsVisible", model.IsVisible, DbType.Boolean)
                , db.Parameter("@ResponsiblePersonID", model.CreatorID, DbType.Int32)
                , db.Parameter("@TagIDs", model.TagIDs, DbType.String)).ExecuteNonQuery();
                if (obj != 1)
                {
                    return false;
                }
                else
                {
                    return true;
                }
            }
        }

        /// <summary>
        /// 更新一条数据
        /// </summary>
        public bool updateRecord(Record_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                string strSqlHistory = " INSERT INTO [HISTORY_RECORD] SELECT * FROM [RECORD] WHERE ID = @ID  and CompanyID =@CompanyID  ";

                int rows = db.SetCommand(strSqlHistory
                        , db.Parameter("@ID", model.ID, DbType.Int32)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                if (rows == 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                string strSql =
                @"update RECORD set 
                RecordTime=@RecordTime,
                Problem=@Problem,
                Suggestion=@Suggestion,
                UpdaterID=@UpdaterID,
                UpdateTime=@UpdateTime,
                IsVisible=@IsVisible
                 where ID=@ID";

                rows = db.SetCommand(strSql
                       , db.Parameter("@RecordTime", model.RecordTime, DbType.DateTime)
                       , db.Parameter("@Problem", model.Problem, DbType.String)
                       , db.Parameter("@Suggestion", model.Suggestion, DbType.String)
                       , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                       , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime)
                       , db.Parameter("@IsVisible", model.IsVisible, DbType.Boolean)
                       , db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery();
                if (rows > 0)
                {
                    db.CommitTransaction();
                    return true;
                }
                else
                {
                    db.RollbackTransaction();
                    return false;
                }
            }
        }

        /// <summary>
        /// 删除一条数据
        /// </summary>
        public bool deleteRecord(int RecordID, int AccountID,int CompanyID)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                string strSqlHistory = " INSERT INTO [HISTORY_RECORD] SELECT * FROM [RECORD] WHERE ID = @ID  and CompanyID =@CompanyID  ";

                int rows = db.SetCommand(strSqlHistory
                        , db.Parameter("@ID", RecordID, DbType.Int32)
                        , db.Parameter("@CompanyID", CompanyID, DbType.Int32)).ExecuteNonQuery();

                if (rows == 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                string strSql =
               @" update RECORD set 
                Available=@Available
                UpdaterID=@UpdaterID,
                UpdateTime=@UpdateTime
                where ID=@ID";

                rows = db.SetCommand(strSql
                            , db.Parameter("@Available", false, DbType.DateTime)
                            , db.Parameter("@UpdaterID", AccountID, DbType.String)
                            , db.Parameter("@UpdateTime", DateTime.Now.ToLocalTime(), DbType.String)
                            , db.Parameter("@ID", RecordID, DbType.Int32)
                            ).ExecuteNonQuery();
                if (rows > 0)
                {
                    db.CommitTransaction();
                    return true;
                }
                else
                {
                    db.RollbackTransaction();
                    return false;
                }
            }
        }
    }
}
