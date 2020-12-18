using BLToolkit.Data;
using HS.Framework.Common;
using HS.Framework.Common.Entity;
using HS.Framework.Common.Util;
using Model.Operation_Model;
using Model.Table_Model;
using Model.View_Model;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using WebAPI.Common;

namespace WebAPI.DAL
{
    public class Paper_DAL
    {
        #region 构造类实例
        public static Paper_DAL Instance
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
            internal static readonly Paper_DAL instance = new Paper_DAL();
        }
        #endregion



        #region 后台方法
        public List<PaperTable_Model> getPaperListForWeb(int companyId)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @" select ID,Title,CanEditAnswer,IsVisible,CreateTime from [TBL_PAPER] with (nolock) where CompanyID = @CompanyID AND Available = 1 ";
                List<PaperTable_Model> list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyId, DbType.Int32)).ExecuteList<PaperTable_Model>();
                return list;
            }
        }

        public bool deletePaper(PaperTable_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strSqlHistory = @" INSERT INTO [TBL_HISTORY_PAPER] SELECT * FROM [TBL_PAPER] WHERE ID = @ID ";

                int rows = db.SetCommand(strSqlHistory, db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery();

                if (rows == 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                string strSqlDelete = @" update [TBL_PAPER] set
                                        Available =@Available,
                                        UpdaterID =@UpdaterID,
                                        UpdateTime =@UpdateTime
                                        where ID=@ID ";

                rows = db.SetCommand(strSqlDelete
                    , db.Parameter("@Available", 0, DbType.Int32)
                    , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                    , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                    , db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery();
                if (rows == 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                db.CommitTransaction();
                return true;

            }
        }

        public PaperTable_Model getPaperDetail(int paperId)
        {
            using (DbManager db = new DbManager())
            {
                string strSqlPaper = @" select ID,Title,IsVisible,CanEditAnswer from [TBL_PAPER] where ID=@ID AND Available = 1 ";

                PaperTable_Model model = db.SetCommand(strSqlPaper, db.Parameter("@ID", paperId, DbType.Int32)).ExecuteObject<PaperTable_Model>();

                if (model == null)
                {
                    return null;
                }


                model.listRelation = new List<PaperRelationShip_Model>();
                string strSqlRelation = @" select T1.QuestionID,T1.SortID,CASE T2.QuestionType WHEN 0 THEN T2.QuestionName + ' (文本) ' WHEN 1 THEN T2.QuestionName  + ' (单选) ' WHEN 2 THEN T2.QuestionName  + ' (多选) ' ELSE T2.QuestionName END QuestionName  from [TBL_PAPER_QUESTION_RELATIONSHIP] T1 LEFT JOIN [QUESTION] T2 ON T1.QuestionID = T2.ID where T1.PaperID=@ID and T1.Available = 1 ";
                model.listRelation = db.SetCommand(strSqlRelation, db.Parameter("@ID", paperId, DbType.Int32)).ExecuteList<PaperRelationShip_Model>();
                return model;
            }
        }

        public int addPaper(PaperTable_Model model)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();

                string strSqlAdvanced = " select Advanced from [COMPANY] where id =@ID ";

                string str = db.SetCommand(strSqlAdvanced, db.Parameter("@ID", model.CompanyID, DbType.Int32)).ExecuteScalar<string>();
                if (!str.Contains("|1|")) {
                    string strSqlCount = " select Count(*) from [TBL_PAPER] where Available = 1 and CompanyID=@CompanyID ";

                    int cnt = db.SetCommand(strSqlCount, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();

                    if (cnt >= 1)
                    {
                        return -1;
                    }
                }



                string strSqlAdd = @" INSERT INTO [TBL_PAPER]  
                                    (CompanyID,Title,IsVisible,Available,CanEditAnswer,CreatorID,CreateTime)
                                    VALUES
                                    (@CompanyID,@Title,@IsVisible,@Available,@CanEditAnswer,@CreatorID,@CreateTime) 
                                    ;select @@IDENTITY";

                int paperId = db.SetCommand(strSqlAdd, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@Title", model.Title, DbType.String)
                    , db.Parameter("@IsVisible", model.IsVisible, DbType.Boolean)
                    , db.Parameter("@Available", true, DbType.Boolean)
                    , db.Parameter("@CanEditAnswer", model.CanEditAnswer, DbType.Boolean)
                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteScalar<int>();

                if (paperId <= 0)
                {
                    db.RollbackTransaction();
                    return 0;
                }


                if (model.listRelation != null && model.listRelation.Count > 0)
                {
                    foreach (PaperRelationShip_Model item in model.listRelation)
                    {
                        string strSqlAddRelationShip = @" INSERT INTO [TBL_PAPER_QUESTION_RELATIONSHIP]  
                                                (CompanyID,PaperID,QuestionID,SortID,Available,CreatorID,CreateTime)
                                                VALUES
                                                (@CompanyID,@PaperID,@QuestionID,@SortID,@Available,@CreatorID,@CreateTime) ";

                        int rows = db.SetCommand(strSqlAddRelationShip, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                    , db.Parameter("@PaperID", paperId, DbType.Int32)
                                                    , db.Parameter("@QuestionID", item.QuestionID, DbType.Int32)
                                                    , db.Parameter("@SortID", item.SortID, DbType.Int32)
                                                    , db.Parameter("@Available", true, DbType.Boolean)
                                                    , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                    , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                            return 0;
                        }
                    }
                }
                db.CommitTransaction();
                return 1;

            }
        }




        public bool updatePaper(PaperTable_Model model)
        {
            using (DbManager db = new DbManager())
            {

                db.BeginTransaction();

                string strSqlCheck = @" select COUNT(ID) FROM [TBL_PAPER_GROUP] WHERE PaperID = @PaperID AND CompanyID=@CompanyID  AND Available = 1 ";

                int checkRows = db.SetCommand(strSqlCheck, db.Parameter("@PaperID", model.ID, DbType.Int32)
                            , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteScalar<int>();


                if (checkRows == 0)
                {

                    string strSqlHistoryPaper = @" INSERT INTO [TBL_HISTORY_PAPER] SELECT * FROM [TBL_PAPER] WHERE ID = @ID  AND CompanyID=@CompanyID  ";

                    int rows = db.SetCommand(strSqlHistoryPaper
                                                    , db.Parameter("@ID", model.ID, DbType.Int32)
                                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    string strSqlUpdatePaper = @" Update [TBL_PAPER] 
                                                SET Title=@Title,
                                                IsVisible=@IsVisible,
                                                CanEditAnswer=@CanEditAnswer,
                                                UpdaterID=@UpdaterID,
                                                UpdateTime=@UpdateTime
                                                WHERE ID = @ID  AND CompanyID=@CompanyID  ";

                    rows = db.SetCommand(strSqlUpdatePaper
                                                    , db.Parameter("@Title", model.Title, DbType.String)
                                                    , db.Parameter("@IsVisible", model.IsVisible, DbType.Boolean)
                                                    , db.Parameter("@CanEditAnswer", model.CanEditAnswer, DbType.Boolean)
                                                    , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                                    , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                                                    , db.Parameter("@ID", model.ID, DbType.Int32)
                                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }


                    if (model.PaperControl > -1)
                    {
                        string strSqlUpdate = @" update [TBL_PAPER_QUESTION_RELATIONSHIP] set UpdaterID =@UpdaterID, UpdateTime=@UpdateTime where PaperID =@PaperID AND CompanyID=@CompanyID  ";

                        rows = db.SetCommand(strSqlUpdate, db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                                        , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                                                        , db.Parameter("@PaperID", model.ID, DbType.Int32)
                                                        , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                        if (rows == 0)
                        {
                            db.RollbackTransaction();
                            return false;
                        }

                        string strSqlHistory = @" INSERT INTO [TBL_HISTORY_PAPER_QUESTION_RELATIONSHIP] SELECT * FROM [TBL_PAPER_QUESTION_RELATIONSHIP] WHERE PaperID=@PaperID AND CompanyID=@CompanyID ";

                        int secondRows = db.SetCommand(strSqlHistory
                                    , db.Parameter("@PaperID", model.ID, DbType.Int32)
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                        if (rows != secondRows)
                        {
                            db.RollbackTransaction();
                            return false;
                        }


                        string strSqlDelete = @" delete [TBL_PAPER_QUESTION_RELATIONSHIP] where PaperID=@PaperID AND CompanyID=@CompanyID ";

                        secondRows = db.SetCommand(strSqlDelete
                                    , db.Parameter("@PaperID", model.ID, DbType.Int32)
                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                        if (rows != secondRows)
                        {
                            db.RollbackTransaction();
                            return false;
                        }

                        if (model.listRelation != null && model.listRelation.Count > 0)
                        {
                            string strSqlInsert = @" INSERT INTO [TBL_PAPER_QUESTION_RELATIONSHIP]  
                                                (CompanyID,PaperID,QuestionID,SortID,Available,CreatorID,CreateTime)
                                                VALUES
                                                (@CompanyID,@PaperID,@QuestionID,@SortID,@Available,@CreatorID,@CreateTime)  ";

                            foreach (PaperRelationShip_Model item in model.listRelation)
                            {
                                rows = db.SetCommand(strSqlInsert, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                , db.Parameter("@PaperID", model.ID, DbType.Int32)
                                , db.Parameter("@QuestionID", item.QuestionID, DbType.Int32)
                                , db.Parameter("@SortID", item.SortID, DbType.Int32)
                                , db.Parameter("@Available", true, DbType.Boolean)
                                , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                                if (rows == 0)
                                {
                                    db.RollbackTransaction();
                                    return false;
                                }

                            }
                        }
                    }

                }
                else
                {
                    string strSqlUpdatePaper = @" INSERT INTO [TBL_HISTORY_PAPER] SELECT * FROM [TBL_PAPER] WHERE ID = @ID  AND CompanyID=@CompanyID  ";

                    int rows = db.SetCommand(strSqlUpdatePaper
                                                    , db.Parameter("@ID", model.ID, DbType.Int32)
                                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (rows == 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    string strSqlDelete = @" Update [TBL_PAPER] set Available = @Available,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime WHERE ID = @ID and CompanyID=@CompanyID ";


                    int secondRows = db.SetCommand(strSqlDelete
                                                    , db.Parameter("@Available", false, DbType.Boolean)
                                                    , db.Parameter("@UpdaterID", model.UpdaterID, DbType.Int32)
                                                    , db.Parameter("@UpdateTime", model.UpdateTime, DbType.DateTime2)
                                                    , db.Parameter("@ID", model.ID, DbType.Int32)
                                                    , db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)).ExecuteNonQuery();

                    if (rows != secondRows)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    string strSqlAdd = @" INSERT INTO [TBL_PAPER]  
                                    (CompanyID,Title,IsVisible,Available,CanEditAnswer,CreatorID,CreateTime)
                                    VALUES
                                    (@CompanyID,@Title,@IsVisible,@Available,@CanEditAnswer,@CreatorID,@CreateTime) 
                                    ;select @@IDENTITY";

                    int paperId = db.SetCommand(strSqlAdd, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                        , db.Parameter("@Title", model.Title, DbType.String)
                        , db.Parameter("@IsVisible", model.IsVisible, DbType.Boolean)
                        , db.Parameter("@Available", true, DbType.Boolean)
                        , db.Parameter("@CanEditAnswer", model.CanEditAnswer, DbType.Boolean)
                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteScalar<int>();

                    if (paperId <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }


                    if (model.listRelation != null && model.listRelation.Count > 0)
                    {
                        foreach (PaperRelationShip_Model item in model.listRelation)
                        {
                            string strSqlAddRelationShip = @" INSERT INTO [TBL_PAPER_QUESTION_RELATIONSHIP]  
                                                (CompanyID,PaperID,QuestionID,SortID,Available,CreatorID,CreateTime)
                                                VALUES
                                                (@CompanyID,@PaperID,@QuestionID,@SortID,@Available,@CreatorID,@CreateTime) ";

                            rows = db.SetCommand(strSqlAddRelationShip, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                        , db.Parameter("@PaperID", paperId, DbType.Int32)
                                                        , db.Parameter("@QuestionID", item.QuestionID, DbType.Int32)
                                                        , db.Parameter("@SortID", item.SortID, DbType.Int32)
                                                        , db.Parameter("@Available", true, DbType.Boolean)
                                                        , db.Parameter("@CreatorID", model.CreatorID, DbType.Int32)
                                                        , db.Parameter("@CreateTime", model.CreateTime, DbType.DateTime2)).ExecuteNonQuery();

                            if (rows == 0)
                            {
                                db.RollbackTransaction();
                                return false;
                            }
                        }
                    }
                }

                db.CommitTransaction();
                return true;

            }
        }

        #endregion
			
		public List<Paper_Model> GetPaperList(int companyID)
        {
            List<Paper_Model> list = new List<Paper_Model>();
            using (DbManager db = new DbManager())
            {
                string strSql = @" SELECT ID AS PaperID,Title,IsVisible,CanEditAnswer,CreateTime FROM [TBL_PAPER] WITH(NOLOCK) WHERE Available=1 AND CompanyID=@CompanyID ORDER BY  CreateTime DESC";
                list = db.SetCommand(strSql, db.Parameter("@CompanyID", companyID, DbType.Int32)).ExecuteList<Paper_Model>();
                return list;
            }
        }

        public List<AnswerPaper_Model> GetAnswerPaperList(GetAnswerPaperListOperation_Model operationModel, out int recordCount)
        {
            List<AnswerPaper_Model> list = new List<AnswerPaper_Model>();
            using (DbManager db = new DbManager())
            {
                string fileds = @" ROW_NUMBER() OVER ( ORDER BY T1.UpdateTime DESC, T1.ID DESC ) AS rowNum ,
                                                T1.ID AS GroupID ,T1.PaperID ,T2.Title ,T3.Name AS CustomerName ,T2.CanEditAnswer, 
                                                ISNULL(T4.Name,'')  AS ResponsiblePersonName ,T1.IsVisible ,T1.UpdateTime";


                string strSql = @" SELECT {0}
                                FROM    TBL_PAPER_GROUP T1 WITH(NOLOCK)
                                        INNER JOIN [TBL_PAPER] T2 WITH(NOLOCK) ON T1.PaperID = T2.ID
                                        INNER JOIN [CUSTOMER] T3 WITH(NOLOCK) ON T1.CustomerID = T3.UserID
                                        LEFT JOIN [ACCOUNT] T4 WITH(NOLOCK) ON T1.CreatorID = T4.UserID
                                WHERE   T1.CompanyID = @CompanyID AND T1.Available=1 ";

                if (operationModel.PageIndex > 1)
                {
                    strSql += " AND T1.UpdateTime <= @UpdateTime";
                }

                if (operationModel.ResponsiblePersonIDs != null && operationModel.ResponsiblePersonIDs.Count > 0)
                {
                    strSql += " AND T1.CreatorID in ( ";
                    for (int i = 0; i < operationModel.ResponsiblePersonIDs.Count; i++)
                    {
                        if (i == 0)
                        {
                            strSql += operationModel.ResponsiblePersonIDs[i].ToString();
                        }
                        else
                        {
                            strSql += "," + operationModel.ResponsiblePersonIDs[i].ToString();
                        }
                    }
                    strSql += " )";
                }

                if (operationModel.FilterByTimeFlag == 1)
                {

                    strSql += Common.APICommon.getSqlWhereData_1_7_2(4, operationModel.StartTime, operationModel.EndTime, " T1.UpdateTime");
                }

                if (operationModel.CustomerID > 0)
                {
                    strSql += " AND T1.CustomerID = @CustomerID";
                }

                // Customer端只能查看可见的试卷答案
                if (!operationModel.IsBusiness)
                {
                    strSql += " AND T1.IsVisible = 1";
                }

                string strCountSql = string.Format(strSql, " count(0) ");

                string strgetListSql = "select * from( " + string.Format(strSql, fileds) + " ) a where  rowNum between  " + ((operationModel.PageIndex - 1) * operationModel.PageSize + 1) + " and " + operationModel.PageIndex * operationModel.PageSize;

                recordCount = db.SetCommand(strCountSql, db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)
                                                        , db.Parameter("@UpdateTime", operationModel.UpdateTime, DbType.DateTime)
                                                        , db.Parameter("@CustomerID", operationModel.CustomerID, DbType.Int32)).ExecuteScalar<int>();

                if (recordCount < 0)
                {
                    return null;
                }

                list = db.SetCommand(strgetListSql, db.Parameter("@CompanyID", operationModel.CompanyID, DbType.Int32)
                                                  , db.Parameter("@UpdateTime", operationModel.UpdateTime, DbType.DateTime)
                                                  , db.Parameter("@CustomerID", operationModel.CustomerID, DbType.Int32)).ExecuteList<AnswerPaper_Model>();
                return list;
            }
        }

        public List<PaperDetail> GetPaperDetail(GetAnswerDetailOperation_Model model)
        {
            List<PaperDetail> list = new List<PaperDetail>();
            using (DbManager db = new DbManager())
            {
                string strSql = "";
                if (model.GroupID > 0)
                {
                    strSql = @" SELECT  
                                        T2.ID AS QuestionID ,
                                        T2.QuestionName ,
                                        T2.QuestionType ,
                                        T2.QuestionContent ,
                                        ISNULL(T5.AnswerContent, '') AS AnswerContent ,
                                        ISNULL(T5.ID, 0) AS AnswerID ,
                                        ISNULL(T2.QuestionDescription, '') AS QuestionDescription
                                FROM    [TBL_PAPER_QUESTION_RELATIONSHIP] T1 WITH ( NOLOCK )
                                        INNER JOIN [QUESTION] T2 WITH ( NOLOCK ) ON T1.QuestionID = T2.ID
                                                                                    AND T1.CompanyID = @CompanyID
                                        LEFT JOIN [TBL_PAPER_GROUP] T3 ON T3.PaperID = @PaperID
                                                                          AND T1.ID = @GroupID
                                        LEFT JOIN [ANSWER] T5 ON T5.QuestionID = T2.ID
                                                                 AND T5.GroupID = @GroupID
                                WHERE   T1.CompanyID = @CompanyID
                                        AND T1.PaperID = @PaperID
                                ORDER BY T1.SortID";
                }
                else
                {
                    strSql = @" SELECT      T2.ID AS QuestionID ,
                                            T2.QuestionName ,
                                            T2.QuestionType ,
                                            T2.QuestionContent ,
                                            ISNULL(T2.QuestionDescription, '') AS QuestionDescription,
                                            0 AS AnswerID ,
                                            '' AS AnswerContent
                                    FROM    [TBL_PAPER_QUESTION_RELATIONSHIP] T1 WITH ( NOLOCK )
                                            INNER JOIN [QUESTION] T2 WITH ( NOLOCK ) ON T1.QuestionID = T2.ID
                                                                                        AND T1.CompanyID = @CompanyID
                                    WHERE   T1.CompanyID = @CompanyID
                                            AND T1.PaperID = @PaperID
                                            AND T1.Available=1
                                    ORDER BY T1.SortID";
                }

                list = db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                    , db.Parameter("@PaperID", model.PaperID, DbType.Int32)
                    , db.Parameter("@GroupID", model.GroupID, DbType.Int32)).ExecuteList<PaperDetail>();
                return list;
            }
        }

        public bool AddAnswer(AddAnswerOperation_Model model)
        {
            bool isSuccess = false;
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string strAddGroup = @"INSERT INTO dbo.TBL_PAPER_GROUP( CompanyID ,BranchID ,PaperID ,CustomerID ,IsVisible ,Available ,CreatorID ,CreateTime  ,UpdateTime)
                                                VALUES (@CompanyID ,@BranchID ,@PaperID ,@CustomerID ,@IsVisible ,@Available ,@CreatorID ,@CreateTime  ,@UpdateTime);select @@IDENTITY";

                int groupID = db.SetCommand(strAddGroup, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                        , db.Parameter("@BranchID", model.BranchID, DbType.Int32)
                                                        , db.Parameter("@PaperID", model.PaperID, DbType.Int32)
                                                        , db.Parameter("@CustomerID", model.CustomerID, DbType.Int32)
                                                        , db.Parameter("@IsVisible", model.IsVisible, DbType.Boolean)
                                                        , db.Parameter("@Available", model.Available, DbType.Boolean)
                                                        , db.Parameter("@CreatorID", model.AccountID, DbType.Int32)
                                                        , db.Parameter("@CreateTime", model.OperateTime, DbType.DateTime)
                                                        , db.Parameter("@UpdateTime", model.OperateTime, DbType.DateTime)).ExecuteScalar<int>();
                if (groupID <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                if (model.AnswerList != null && model.AnswerList.Count > 0)
                {
                    foreach (AnswerRes_Model item in model.AnswerList)
                    {
                        string strInsertAnswerSql = @" INSERT INTO dbo.ANSWER( CompanyID ,QuestionID  ,AnswerContent ,CreatorID ,CreateTime ,GroupID)
                                                   VALUES (@CompanyID ,@QuestionID  ,@AnswerContent ,@CreatorID ,@CreateTime ,@GroupID) ";

                        int addrows = db.SetCommand(strInsertAnswerSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                                     , db.Parameter("@QuestionID", item.QuestionID, DbType.Int32)
                                                                                     , db.Parameter("@AnswerContent", item.AnswerContent, DbType.String)
                                                                                     , db.Parameter("@CreatorID", model.AccountID, DbType.Int32)
                                                                                     , db.Parameter("@CreateTime", model.OperateTime, DbType.DateTime)
                                                                                     , db.Parameter("@GroupID", groupID, DbType.Int32)).ExecuteNonQuery();
                        if (addrows <= 0)
                        {
                            db.RollbackTransaction();
                            return false;
                        }
                    }

                }
                else
                {
                    db.RollbackTransaction();
                    return false;
                }

                db.CommitTransaction();
                isSuccess = true;
                return isSuccess;
            }
        }

        public bool UpdateAnswer(EditAnswerOperation_Model model)
        {
            bool isSuccess = false;
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                if (model.AnswerID <= 0)
                {
                    string strInsertAnswerSql = @" INSERT INTO dbo.ANSWER( CompanyID ,QuestionID  ,AnswerContent ,CreatorID ,CreateTime ,GroupID)
                                                   VALUES (@CompanyID ,@QuestionID  ,@AnswerContent ,@CreatorID ,@CreateTime ,@GroupID) ";

                    int addrows = db.SetCommand(strInsertAnswerSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32)
                                                                                 , db.Parameter("@QuestionID", model.QuestionID, DbType.Int32)
                                                                                 , db.Parameter("@AnswerContent", model.AnswerContent, DbType.String)
                                                                                 , db.Parameter("@CreatorID", model.AccountID, DbType.Int32)
                                                                                 , db.Parameter("@CreateTime", model.OperateTime, DbType.DateTime)
                                                                                 , db.Parameter("@GroupID", model.GroupID, DbType.Int32)).ExecuteNonQuery();
                    if (addrows <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                }
                else
                {
                    string strAddHisSql = @"Insert into [HISTORY_ANSWER] select * from [ANSWER] where ID=@ID;";
                    int addHisRes = db.SetCommand(strAddHisSql, db.Parameter("@ID", model.AnswerID, DbType.Int32)).ExecuteNonQuery();
                    if (addHisRes <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }

                    string strUpdateAnswerSql = @" UPDATE [ANSWER] SET AnswerContent=@AnswerContent,UpdaterID=@UpdaterID,UpdateTime=@UpdateTime WHERE ID=@ID ";
                    int updateAnswerRes = db.SetCommand(strUpdateAnswerSql, db.Parameter("@AnswerContent", model.AnswerContent, DbType.String)
                                                                    , db.Parameter("@UpdaterID", model.AccountID, DbType.Int32)
                                                                    , db.Parameter("@UpdateTime", model.OperateTime, DbType.DateTime)
                                                                    , db.Parameter("@ID", model.AnswerID, DbType.Int32)).ExecuteNonQuery();

                    if (updateAnswerRes <= 0)
                    {
                        db.RollbackTransaction();
                        return false;
                    }
                }

                string strUpdateGroupSql = @" UPDATE [TBL_PAPER_GROUP] SET UpdaterID=@UpdaterID,UpdateTime=@UpdateTime WHERE ID=@GroupID ";
                int updateGroupRes = db.SetCommand(strUpdateGroupSql, db.Parameter("@UpdaterID", model.AccountID, DbType.Int32)
                                                                    , db.Parameter("@UpdateTime", model.OperateTime, DbType.DateTime)
                                                                    , db.Parameter("@GroupID", model.GroupID, DbType.Int32)).ExecuteNonQuery();

                if (updateGroupRes <= 0)
                {
                    db.RollbackTransaction();
                    return false;
                }

                db.CommitTransaction();
                isSuccess = true;
                return isSuccess;
            }
        }

        // 专业删除
        public bool DelAnswer(DelAnswerOperation_Model model)
        {
            bool isSuccess = false;
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                string delSqlstr = @"DELETE TBL_PAPER_GROUP WHERE ID=@ID";
                int rs = db.SetCommand(delSqlstr
                       , db.Parameter("@ID", model.GroupID, DbType.Int32)).ExecuteNonQuery();
                if (rs > 0)
                {
                    db.CommitTransaction();
                    isSuccess = true;
                    return isSuccess;
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
