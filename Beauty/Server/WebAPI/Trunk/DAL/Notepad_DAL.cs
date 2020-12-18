using BLToolkit.Data;
using HS.Framework.Common;
using HS.Framework.Common.Entity;
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
    public class Notepad_DAL
    {
        #region 构造类实例
        public static Notepad_DAL Instance
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
            internal static readonly Notepad_DAL instance = new Notepad_DAL();
        }
        #endregion

        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <param name="pageSize"></param>
        /// <param name="pageIndex"></param>
        /// <param name="recordCount"></param>
        /// <returns></returns>
        public List<NotepadList_Model> getNotepadListByAccountID(NotepadListOperation_Model model, int pageSize, int pageIndex, out int recordCount)
        {
            recordCount = 0;
            List<NotepadList_Model> list = new List<NotepadList_Model>();
            using (DbManager db = new DbManager())
            {

                string fileds = @" ROW_NUMBER() OVER ( ORDER BY T3.CreateTime DESC ) AS rowNum ,
                                                  T3.*,T5.Name CreatorName ,LEFT(T4.TagName,LEN(T4.TagName)-1) as TagName,T6.Name CustomerName ";

                string strSql = @"SELECT {0} FROM TBL_NOTEPAD T3
                                             Left join  ( SELECT  T2.TagIDs ,
                                                        ( SELECT    T1.Name + '|'
                                                          FROM      dbo.TBL_TAG T1
                                                          WHERE     CHARINDEX('|' + CONVERT(VARCHAR, T1.ID) + '|', T2.TagIDs) > 0
                                                                    AND Available = 1
                                                        FOR
                                                          XML PATH('')
                                                        ) AS TagName
                                                FROM    dbo.TBL_NOTEPAD T2 
                                                WHERE   T2.Available = 1 
                                                GROUP BY T2.TagIDs ) T4 On T3.TagIDs = T4.TagIDs 
                                            LEFT JOIN ACCOUNT T5 ON T3.CreatorID = T5.UserID 
                                            LEFT JOIN CUSTOMER T6 ON T3.CustomerID = T6.UserID 
                                            WHERE T3.CompanyID = @CompanyID  
                                             AND T3.Available = 1  ";

                if (model.BranchID > 0)
                {
                    strSql += " AND T3.BranchID = " + model.BranchID;
                }

                if (model.ID > 0 && model.PageIndex > 1)
                {
                    strSql += " AND T3.ID <= " + model.ID;
                }

                if (model.FilterByTimeFlag == 1)
                {

                    strSql += Common.SqlCommon.getSqlWhereData_1_7_2(4, model.StartTime, model.EndTime, " T3.CreateTime ");
                }
                //筛选 当前责任人的的记事本
                if (model.ResponsiblePersonIDs != null && model.ResponsiblePersonIDs.Count > 0)
                {
                    strSql += " AND T3.CreatorID in ( ";
                    for (int i = 0; i < model.ResponsiblePersonIDs.Count; i++)
                    {
                        if (i == 0)
                        {
                            strSql += model.ResponsiblePersonIDs[i].ToString();
                        }
                        else
                        {
                            strSql += "," + model.ResponsiblePersonIDs[i].ToString();
                        }
                    }
                    strSql += " )";
                }


                //左边菜单 CustomerID = 0 筛选与先关的记事本
                //右边菜单 CustomerID > 0 筛选与顾客相关的记事本
                if (model.CustomerID > 0)
                {
                    strSql += " AND T3.CustomerID = @CustomerID";
                }
//                else
//                {
//                    strSql += @" AND (T3.CreatorID = @AccountID  Or T3.CreatorID IN (
//                                                                                           SELECT
//                                                                                                fn_CustomerNamesInRegion.SubordinateID
//                                                                                           FROM fn_CustomerNamesInRegion(@AccountID,
//                                                                                                @BranchID) )) ";
//                }

                if (!string.IsNullOrEmpty(model.TagIDs))
                {
                    string[] str = model.TagIDs.Split('|');
                    string strSqlPart = "";
                    if (model.TagIDs == "|0|")
                    {
                        strSqlPart = " and IsNull(T3.TagIDs,'')='' ";
                    }
                    else
                    {
                        for (int i = 0; i < str.Length; i++)
                        {
                            if (!string.IsNullOrEmpty(str[i]))
                            {
                                strSqlPart += " AND CHARINDEX( '" + "|" + str[i] + "|'" + ",T3.TagIDs)>0 ";
                            }
                        }
                    }
                    strSql += strSqlPart;
                }

                string strCountSql = string.Format(strSql, " count(0) ");

                string strgetListSql = "select * from( " + string.Format(strSql, fileds) + " ) a where  rowNum between  " + ((pageIndex - 1) * pageSize + 1) + " and " + pageIndex * pageSize;

                recordCount = db.SetCommand(strCountSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                       , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                                       , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteScalar<int>();

                if (recordCount < 0)
                {
                    return null;
                }

                list = db.SetCommand(strgetListSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                  , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                                  , db.Parameter("@BranchID", model.BranchID, DbType.Int32)).ExecuteList<NotepadList_Model>();

                return list;
            }

        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public ObjectResult<object> getNotepadList(NotepadListOperation_Model model)
        {
            ObjectResult<object> result = new ObjectResult<object>();
            result.Code = "0";
            result.Data = null;
            List<NotepadList_Model> list = new List<NotepadList_Model>();
            using (DbManager db = new DbManager())
            {
                string strSqlCommand = @"SELECT T3.*,ISNULL(T5.Name,T6.Name) CreatorName ,LEFT(T4.TagName,LEN(T4.TagName)-1) as TagName ,T6.Name CustomerName FROM TBL_NOTEPAD T3
                                             Left join  ( SELECT  T2.TagIDs ,
                                                        ( SELECT    T1.Name + '|'
                                                          FROM      dbo.TBL_TAG T1
                                                          WHERE     CHARINDEX('|' + CONVERT(VARCHAR, T1.ID) + '|', T2.TagIDs) > 0
                                                                    AND Available = 1
                                                        FOR
                                                          XML PATH('')
                                                        ) AS TagName
                                                FROM    dbo.TBL_NOTEPAD T2 
                                                WHERE   T2.Available = 1 
                                                GROUP BY T2.TagIDs ) T4 On T3.TagIDs = T4.TagIDs 
                                            LEFT JOIN ACCOUNT T5 ON T3.CreatorID = T5.UserID 
                                            LEFT JOIN CUSTOMER T6 ON T3.CustomerID = T6.UserID 
                                            WHERE T3.CompanyID = @CompanyID 
                                            and T3.BranchID = @BranchID 
                                             {0} 
                                            and T3.Available = 1 
                                            and T3.CustomerID =@CustomerID ";

                if (!string.IsNullOrEmpty(model.TagIDs))
                {
                    string[] str = model.TagIDs.Split('|');
                    string strSqlPart = "";
                    if (model.TagIDs == "|0|")
                    {
                        strSqlPart = " and IsNull(T3.TagIDs,'')='' ";
                    }
                    else
                    {
                        for (int i = 0; i < str.Length; i++)
                        {
                            if (!string.IsNullOrEmpty(str[i]))
                            {
                                strSqlPart += " AND CHARINDEX( '" + "|" + str[i] + "|'" + ",T3.TagIDs)>0 ";
                            }
                        }
                    }
                    strSqlCommand = string.Format(strSqlCommand, strSqlPart);
                }
                else
                {
                    strSqlCommand = string.Format(strSqlCommand, "");
                }
                if (model.ID > 0 && model.ViewType == 1)
                {
                    strSqlCommand = "SELECT  * FROM (" + strSqlCommand + ") AS a WHERE a.ID > @ID ";
                }
                else if (model.ID > 0 && model.ViewType == 0)
                {
                    // 取出之前10条订单
                    strSqlCommand = "SELECT TOP 10 * FROM (" + strSqlCommand + ") AS a WHERE a.ID < @ID ";
                }
                else
                {
                    //取出该Account下前十条订单
                    strSqlCommand = "SELECT TOP 10 * FROM (" + strSqlCommand + ") AS a ";
                }
                strSqlCommand += " order by CreateTime DESC ;";


                list = db.SetCommand(strSqlCommand, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                                    db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                                    db.Parameter("@TagIDs", model.TagIDs, DbType.String),
                                                    db.Parameter("@CustomerID", model.CustomerID, DbType.Int32),
                                                    db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteList<NotepadList_Model>();
                result.Code = "1";
                result.Data = list;

            }
            return result;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool addNotepad(Notepad_Model model)
        {
            bool result = false;
            using (DbManager db = new DbManager())
            {
                string strSqlCommand = @"INSERT INTO [TBL_NOTEPAD]
                                        ([CompanyID]
                                        ,[BranchID]
                                        ,[CustomerID]
                                        ,[TagIDs]
                                        ,[Content]
                                        ,[Available]
                                        ,[CreatorID]
                                        ,[CreateTime])
                                        VALUES(@CompanyID
                                        ,@BranchID
                                        ,@CustomerID
                                        ,@TagIDs
                                        ,@Content
                                        ,@Available
                                        ,@CreatorID
                                        ,@CreateTime)";

                int row = db.SetCommand(strSqlCommand, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                                      db.Parameter("@BranchID", model.BranchID, DbType.Int32),
                                                      db.Parameter("@CustomerID", model.CustomerID, DbType.Int32),
                                                      db.Parameter("@TagIDs", model.TagIDs, DbType.String),
                                                      db.Parameter("@Content", model.Content, DbType.String),
                                                      db.Parameter("@Available", true, DbType.Boolean),
                                                      db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                                      db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();
                if (row == 1)
                {
                    result = true;
                }
            }
            return result;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="ID"></param>
        /// <returns></returns>
        public bool deleteNotepad(NotepadDeleteOperation_Model model)
        {
            bool result = false;

            using (DbManager db = new DbManager())
            {
                try
                {
                    db.BeginTransaction();

                    string strSqlCommand =
                                          @"INSERT INTO [TBL_HISTORY_NOTEPAD]
                                          select * from [TBL_NOTEPAD] where ID = @ID and CompanyID=@CompanyID ";

                    int row = db.SetCommand(strSqlCommand, db.Parameter("@ID", model.ID, DbType.Int32),
                        db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (row == 1)
                    {
                        strSqlCommand = @"Update [TBL_NOTEPAD]
                                         set Available =0,
                                         UpdaterID = @UpdaterID,
                                         UpdateTime = @UpdateTime 
                                         where ID = @ID AND CompanyID=@CompanyID";

                        row = db.SetCommand(strSqlCommand, db.Parameter("@ID", model.ID, DbType.Int32),
                                                           db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32),
                                                           db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2),
                                                           db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                        if (row == 1)
                        {
                            result = true;
                            db.CommitTransaction();
                        }
                        else
                        {
                            db.RollbackTransaction();
                        }
                    }
                }
                catch
                {
                    db.RollbackTransaction();
                    throw;
                }
            }

            return result;
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool updateNotepad(Notepad_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                string strSqlHistoryUser = " INSERT INTO [TBL_HISTORY_NOTEPAD] SELECT * FROM [TBL_NOTEPAD] WHERE ID = @ID ";
                int hisRows = db.SetCommand(strSqlHistoryUser, db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery();

                if (hisRows == 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                string strSqlCommand = @"UPDATE [TBL_NOTEPAD]
                                         SET [TagIDs] = @TagIDs
                                        ,[Content] = @Content
                                        ,[UpdaterID] = @UpdaterID
                                        ,[UpdateTime] = @UpdateTime
                                        WHERE ID = @ID";

                int row = db.SetCommand(strSqlCommand, db.Parameter("@TagIDs", model.TagIDs, DbType.String),
                                                       db.Parameter("@Content", model.Content, DbType.String),
                                                       db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32),
                                                       db.Parameter("@ID", model.ID, DbType.Int32),
                                                       db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)).ExecuteNonQuery();
                if (row <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                db.CommitTransaction();
                return true;

            }
           
        }

    }
}
