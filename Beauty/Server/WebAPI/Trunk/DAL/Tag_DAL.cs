using BLToolkit.Data;
using HS.Framework.Common;
using Model.Operation_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace WebAPI.DAL
{
    public class Tag_DAL
    {
        #region 构造类实例
        public static Tag_DAL Instance
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
            internal static readonly Tag_DAL instance = new Tag_DAL();
        }
        #endregion

        public int addTag(TagOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                model.Name = Regex.Replace(model.Name, " ", "", RegexOptions.IgnoreCase);
                string strSqlCheck = @"SELECT ID FROM dbo.TBL_TAG WHERE Name = @Name and CompanyID =@CompanyID AND Type=1 ";
                int tagId = 0;
                tagId = db.SetCommand(strSqlCheck, db.Parameter("@Name", model.Name, DbType.String), db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();

                if (tagId > 0)
                {
                    return -1;
                }
                else
                {
                    string strSqlCommand = @"INSERT INTO [TBL_TAG](
                                            [CompanyID],
                                            [Name],
                                            [CreateTime],
                                            [Available],
                                            [CreatorID],
                                            [Type])
                                        VALUES(@CompanyID
                                            ,@Name
                                            ,@CreateTime
                                            ,@Available
                                            ,@CreatorID
                                            ,@Type)";

                    int row = db.SetCommand(strSqlCommand, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                                          db.Parameter("@Name", model.Name, DbType.String),
                                                          db.Parameter("@Available", true, DbType.Boolean),
                                                          db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                                          db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2),
                                                          db.Parameter("@Type", model.Type, DbType.Int32)).ExecuteNonQuery();
                    return 1;
                }
            }
        }

        public List<TagList_Model> getTagList(int companyId, int type, int branchID, bool isShowHave = false)
        {
            List<TagList_Model> list = new List<TagList_Model>();
            
            using (DbManager db = new DbManager())
            {
                string strSqlCommand = @"getTagList";

                list = db.SetSpCommand(strSqlCommand, db.Parameter("@CompanyID", companyId, DbType.Int32)
                , db.Parameter("@Type", type, DbType.Int32)).ExecuteList<TagList_Model>();

                return list;
            }
        }

        /// <summary>
        /// 获取标签详细
        /// </summary>
        /// <param name="companyId">公司ID</param>
        /// <param name="tagID">标签ID</param>
        /// <param name="type">1:记事本,咨询记录 2:用户分组</param>
        /// <returns></returns>
        public TagDetailForWeb_Model getTagDetailForWeb(int companyId, int tagID, int type = 2)
        {
            TagDetailForWeb_Model model = new TagDetailForWeb_Model();
            string strSqlCommand = "";
            using (DbManager db = new DbManager())
            {
                strSqlCommand = @"SELECT  T1.ID,T1.Name
                                  FROM    TBL_TAG T1 WITH(NOLOCK)
                                  WHERE   T1.CompanyID = @CompanyID
                                            AND T1.[Type] = @Type
                                            AND T1.Available = 1 
                                            AND T1.ID=@TagID ";

                model = db.SetCommand(strSqlCommand, db.Parameter("@CompanyID", companyId, DbType.Int32)
                                                  , db.Parameter("@Type", type, DbType.Int32)
                                                  , db.Parameter("@TagID", tagID, DbType.Int32)).ExecuteObject<TagDetailForWeb_Model>();

                return model;
            }
        }

        public bool deleteTag(TagOperation_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                #region 修改Tag表
                string strUpdateSql = "UPDATE [TBL_TAG] SET UpdaterID=@UpdaterID,UpdateTime=@UpdateTime WHERE ID=@ID AND CompanyID=@CompanyID";
                int updateRes = db.SetCommand(strUpdateSql, db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                                                  , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime2)
                                                  , db.Parameter("@ID", model.ID, DbType.Int32)
                                                  , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                #endregion

                if (updateRes <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                #region 插入Tag历史表
                string strAddHisSql = "INSERT INTO [TBL_HISTORY_TAG] select * from [TBL_TAG] WHERE ID=@ID AND CompanyID=@CompanyID ";
                int addHisRes = db.SetCommand(strAddHisSql, db.Parameter("@ID", model.ID, DbType.Int32)
                                         , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                #endregion

                if (addHisRes <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                #region 删除数据
                string strDelSql = "DELETE FROM [TBL_TAG] WHERE ID=@ID AND CompanyID=@CompanyID";
                int delRes = db.SetCommand(strDelSql, db.Parameter("@ID", model.ID, DbType.Int32)
                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                #endregion

                if (delRes <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                if (model.Type == 2)//用户标签
                {
                    #region 查询原有标签数量
                    string strSelCountSql = "select COUNT(0) from [TBL_USER_TAGS] WHERE TagID=@TagID AND CompanyID=@CompanyID";
                    int selCount = db.SetCommand(strSelCountSql, db.Parameter("@TagID", model.ID, DbType.Int32)
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();
                    #endregion

                    if (selCount > 0)
                    {
                        #region 修改原数据的修改人及修改时间
                        string strUpdateUserTagSql = @"UPDATE [TBL_USER_TAGS] SET UpdaterID=@UpdaterID,UpdateTime=@UpdateTime,Available=0  
                                                WHERE TagID=@TagID AND CompanyID=@CompanyID";
                        int updateUserTagRes = db.SetCommand(strUpdateUserTagSql, db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                               , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime2)
                               , db.Parameter("@TagID", model.ID, DbType.Int32)
                               , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                        #endregion

                        if (updateUserTagRes <= 0)
                        {
                            db.RollbackTransaction();
                            return false;
                        }

                        #region 插入历史表
                        string strAddHisUserTagSql = "INSERT INTO [TBL_HISTORY_USER_TAGS] select * from [TBL_USER_TAGS]WHERE TagID=@TagID AND CompanyID=@CompanyID ";
                        int addHisUserTagRes = db.SetCommand(strAddHisUserTagSql, db.Parameter("@TagID", model.ID, DbType.Int32)
                                                 , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                        #endregion

                        if (addHisUserTagRes <= 0)
                        {
                            db.RollbackTransaction();
                            return false;
                        }

                        #region 删除所有数据
                        string strDelUserTagSql = "DELETE FROM TBL_USER_TAGS WHERE TagID=@TagID AND CompanyID=@CompanyID";
                        int delUserTagRes = db.SetCommand(strDelUserTagSql, db.Parameter("@TagID", model.ID, DbType.Int32)
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                        #endregion

                        if (delUserTagRes <= 0)
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

        public int addTagForWeb(TagDetailForWeb_Model model)
        {
            using (DbManager db = new DbManager())
            {
                model.Name = Regex.Replace(model.Name, " ", "", RegexOptions.IgnoreCase);
                string strSqlCheck = @"SELECT ID FROM dbo.TBL_TAG WHERE Name = @Name and CompanyID =@CompanyID AND Type=2";
                int tagId = 0;
                tagId = db.SetCommand(strSqlCheck, db.Parameter("@Name", model.Name, DbType.String), db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();

                if (tagId > 0)
                {
                    return -1;
                }
                else
                {
                    db.BeginTransaction();
                    string strSqlCommand = @"INSERT INTO [TBL_TAG](
                                            [CompanyID],
                                            [Name],
                                            [CreateTime],
                                            [Available],
                                            [CreatorID],
                                            [Type])
                                        VALUES(@CompanyID
                                            ,@Name
                                            ,@CreateTime
                                            ,@Available
                                            ,@CreatorID
                                            ,@Type);select @@IDENTITY";

                    int tagID = db.SetCommand(strSqlCommand, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                                          db.Parameter("@Name", model.Name, DbType.String),
                                                          db.Parameter("@Available", true, DbType.Boolean),
                                                          db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                                          db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2),
                                                          db.Parameter("@Type", model.Type, DbType.Int32)).ExecuteScalar<int>();
                    if (tagID <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    if (model.Type == 2)
                    {
                        if (model.UserList != null && model.UserList.Count > 0)
                        {
                            #region 循环插入数据
                            foreach (GetAccountListByGroupFroWeb_Model item in model.UserList)
                            {
                                string addTagsSql = @"INSERT [TBL_USER_TAGS] (CompanyID,BranchID,UserType,UserID,TagID,Available,CreatorID,CreateTime )
                                              VALUES ( @CompanyID,@BranchID,@UserType,@UserID,@TagID,@Available,@CreatorID,@CreateTime )";

                                int addRes = db.SetCommand(addTagsSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                   , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                   , db.Parameter("@UserType", 1, DbType.Int32)//0:customer 1:business
                                   , db.Parameter("@UserID", item.AccountID, DbType.Int32)
                                   , db.Parameter("@TagID", tagID, DbType.Int32)
                                   , db.Parameter("@Available", true, DbType.Boolean)
                                   , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                   , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                                if (addRes == 0)
                                {
                                    db.RollbackTransaction();
                                    return 0;
                                }
                            }
                            #endregion
                        }
                    }

                    db.CommitTransaction();
                    return 1;
                }
            }
        }

        public int editTagForWeb(TagDetailForWeb_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                int newTagID = 0;
                if (!string.IsNullOrWhiteSpace(model.Name))
                {
                    model.Name = Regex.Replace(model.Name, " ", "", RegexOptions.IgnoreCase);
                    string strSqlCheck = @"SELECT ID FROM dbo.TBL_TAG WHERE Name = @Name and CompanyID =@CompanyID AND Type=2 ";
                    int tagId = 0;
                    tagId = db.SetCommand(strSqlCheck, db.Parameter("@Name", model.Name, DbType.String), db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();

                    if (tagId > 0)
                    {
                        return -1;
                    }

                    #region 修改原数据
                    string strUpdateTagSql = "UPDATE [TBL_TAG] SET Name=@Name,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime WHERE CompanyID=@CompanyID AND ID=@TagID";
                    int updateRes = db.SetCommand(strUpdateTagSql, db.Parameter("@Name", model.Name, DbType.String)
                                                                , db.Parameter("@TagID", model.ID, DbType.Int32)
                                                                , db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                                                                , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime2)
                                                                , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                    #endregion

                    if (updateRes <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    #region 插入历史数据
                    string strInsertTagHisSql = @"INSERT  INTO dbo.TBL_HISTORY_TAG
                                                        SELECT  *
                                                        FROM    [TBL_TAG]
                                                        WHERE   ID = @TagID
                                                                AND CompanyID = @CompanyID";

                    int insertHisRes = db.SetCommand(strInsertTagHisSql, db.Parameter("@TagID", model.ID, DbType.Int32)
                                                                       , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                    #endregion

                    if (insertHisRes <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    #region 删除数据
                    string strDelSql = "DELETE FROM [TBL_TAG] WHERE ID=@ID AND CompanyID=@CompanyID";
                    int delRes = db.SetCommand(strDelSql, db.Parameter("@ID", model.ID, DbType.Int32)
                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                    #endregion

                    if (delRes <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }

                    #region 插入新数据
                    string strSqlCommand = @"INSERT INTO [TBL_TAG](
                                            [CompanyID],
                                            [Name],
                                            [CreateTime],
                                            [Available],
                                            [CreatorID],
                                            [Type])
                                        VALUES(@CompanyID
                                            ,@Name
                                            ,@CreateTime
                                            ,@Available
                                            ,@CreatorID
                                            ,@Type);select @@IDENTITY";

                    newTagID = db.SetCommand(strSqlCommand, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                                                          db.Parameter("@Name", model.Name, DbType.String),
                                                          db.Parameter("@Available", true, DbType.Boolean),
                                                          db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                                                          db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2),
                                                          db.Parameter("@Type", model.Type, DbType.Int32)).ExecuteScalar<int>();
                    if (newTagID <= 0)
                    {
                        db.RollbackTransaction();
                        return 0;
                    }
                    #endregion
                }

                if (model.Type == 2)
                {
                    #region 查询原有标签数量
                    string strSelCountSql = "select COUNT(0) from [TBL_USER_TAGS] WHERE TagID=@TagID AND CompanyID=@CompanyID";
                    int selCount = db.SetCommand(strSelCountSql, db.Parameter("@TagID", model.ID, DbType.Int32)
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();
                    #endregion

                    if (selCount > 0)
                    {
                        #region 修改原数据的修改人及修改时间
                        string strUpdateUserTagSql = @"UPDATE [TBL_USER_TAGS] SET UpdaterID=@UpdaterID,UpdateTime=@UpdateTime,Available=0  
                                                WHERE TagID=@TagID AND CompanyID=@CompanyID";
                        int updateUserTagRes = db.SetCommand(strUpdateUserTagSql, db.Parameter("@UpdaterID", model.CreatorID, DbType.Int32)
                               , db.Parameter("@UpdateTime", model.CreateTime, DbType.DateTime2)
                               , db.Parameter("@TagID", model.ID, DbType.Int32)
                               , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                        #endregion

                        if (updateUserTagRes <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        #region 插入历史表
                        string strAddHisUserTagSql = "INSERT INTO [TBL_HISTORY_USER_TAGS] select * from [TBL_USER_TAGS]WHERE TagID=@TagID AND CompanyID=@CompanyID ";
                        int addHisUserTagRes = db.SetCommand(strAddHisUserTagSql, db.Parameter("@TagID", model.ID, DbType.Int32)
                                                 , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                        #endregion

                        if (addHisUserTagRes <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }

                        #region 删除所有数据
                        string strDelUserTagSql = "DELETE FROM TBL_USER_TAGS WHERE TagID=@TagID AND CompanyID=@CompanyID";
                        int delUserTagRes = db.SetCommand(strDelUserTagSql, db.Parameter("@TagID", model.ID, DbType.Int32)
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();
                        #endregion

                        if (delUserTagRes <= 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                    }

                    if (model.UserList != null && model.UserList.Count > 0)
                    {
                        if (newTagID > 0)
                        {
                            model.ID = newTagID;
                        }

                        #region 循环插入数据
                        object UpdaterID = DBNull.Value;
                        object UpdateTime = DBNull.Value;
                        if (selCount > 0)
                        {
                            UpdaterID = model.CreatorID;
                            UpdateTime = model.CreateTime;
                        }
                        foreach (GetAccountListByGroupFroWeb_Model item in model.UserList)
                        {
                            string addTagsSql = @"INSERT [TBL_USER_TAGS] (CompanyID,BranchID,UserType,UserID,TagID,Available,CreatorID,CreateTime,UpdaterID,UpdateTime )
                                              VALUES ( @CompanyID,@BranchID,@UserType,@UserID,@TagID,@Available,@CreatorID,@CreateTime,@UpdaterID,@UpdateTime )";

                            int addRes = db.SetCommand(addTagsSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                               , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                               , db.Parameter("@UserType", 1, DbType.Int32)//0:customer 1:business
                               , db.Parameter("@UserID", item.AccountID, DbType.Int32)
                               , db.Parameter("@TagID", model.ID, DbType.Int32)
                               , db.Parameter("@Available", true, DbType.Boolean)
                               , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                               , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)
                               , db.Parameter("@UpdaterID", UpdaterID, DbType.Int32)
                               , db.Parameter("@UpdateTime", UpdateTime, DbType.DateTime2)).ExecuteNonQuery();

                            if (addRes <= 0)
                            {
                                db.RollbackTransaction();
                                return 0;
                            }
                        }
                        #endregion
                    }
                }

                db.CommitTransaction();
                return 1;

            }
        }
    }
}
