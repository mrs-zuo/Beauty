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
    public class Question_DAL
    {
        #region 构造类实例
        public static Question_DAL Instance
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
            internal static readonly Question_DAL instance = new Question_DAL();
        }
        #endregion

        /// <summary>
        /// 获取问题列表
        /// </summary>
        /// <param name="CompanyID"></param>
        /// <param name="QuestionType"></param>
        /// <returns></returns>
        public List<Question_Model> GetQuestionList(int CompanyID, int QuestionType)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"select ID, QuestionName, QuestionType, QuestionContent,QuestionDescription from QUESTION 
                                  where CompanyID = @CompanyID {0}";
                if (QuestionType >= 0)
                    strSql = string.Format(strSql, @" and QuestionType = @QuestionType");
                else
                    strSql = string.Format(strSql, string.Empty);
                return db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32),
                    db.Parameter("@QuestionType", QuestionType, DbType.Int32)).ExecuteList<Question_Model>();
            }
        }

        /// <summary>
        /// 新增问题
        /// </summary>
        /// <param name="modle"></param>
        /// <returns></returns>
        public bool AddQuerstion(Question_Model model)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"insert into QUESTION(CompanyID,QuestionName,QuestionType,QuestionContent,CreatorID,CreateTime,QuestionDescription)
                           values (@CompanyID,@QuestionName,@QuestionType,@QuestionContent,@CreatorID,@CreateTime,@QuestionDescription);";
                return db.SetCommand(strSql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                     db.Parameter("@QuestionName", model.QuestionName, DbType.String,200),
                     db.Parameter("@QuestionType", model.QuestionType, DbType.Int32),
                     db.Parameter("@QuestionContent", model.QuestionContent==null? "":model.QuestionContent , DbType.String,300),
                     db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                     db.Parameter("@CreateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2),
                     db.Parameter("@QuestionDescription", model.QuestionDescription == null ? "" : model.QuestionDescription, DbType.String, 500)).ExecuteNonQuery() > 0;
            }
        }

        /// <summary>
        /// 更新问题
        /// </summary>
        /// <param name="model"></param>
        /// <returns></returns>
        public bool UpdateQuestion(Question_Model model)
        {
            //先将以前的问题答案删除，再添加新的问题

            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                bool rs = false;
                string strsql = string.Empty;
                if (!CheckQuestionHaveANSWER(model.CompanyID, model.ID))
                {
                    strsql = @"INSERT INTO HISTORY_QUESTION select * from QUESTION where CompanyID=@CompanyID AND ID=@ID";
                    rs = db.SetCommand(strsql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                        db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery() > 0;
                    if (!rs)
                    {
                        db.RollbackTransaction();
                        return rs;
                    }
                    strsql = @"UPDATE dbo.QUESTION SET QuestionName=@QuestionName,QuestionType=@QuestionType,QuestionContent=@QuestionContent,QuestionDescription=@QuestionDescription,
                            CreatorID=@CreatorID,CreateTime=@CreateTime WHERE CompanyID=@CompanyID AND ID=@ID";
                    rs = db.SetCommand(strsql, db.Parameter("@CompanyID", model.CompanyID, DbType.Int32),
                     db.Parameter("@QuestionName", model.QuestionName, DbType.String,200),
                     db.Parameter("@QuestionType", model.QuestionType, DbType.Int32),
                     db.Parameter("@QuestionContent", model.QuestionContent == null ? "" : model.QuestionContent, DbType.String, 300),
                     db.Parameter("@QuestionDescription", model.QuestionDescription == null ? "" : model.QuestionDescription, DbType.String, 500),
                     db.Parameter("@CreatorID", model.CreatorID, DbType.Int32),
                     db.Parameter("@CreateTime", DateTime.Now.ToLocalTime(), DbType.DateTime2),
                     db.Parameter("@ID", model.ID, DbType.Int32)).ExecuteNonQuery() > 0;
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
                else
                {
                    db.RollbackTransaction();
                    return rs;

                }
            }

        }

        /// <summary>
        /// 获取问题详情
        /// </summary>
        /// <param name="CompanyID"></param>
        /// <param name="ID"></param>
        /// <returns></returns>
        public Question_Model GetQuestionDetail(int CompanyID, int ID)
        {
            using (DbManager db = new DbManager())
            {
                string strSql = @"select ID, QuestionName, QuestionType, QuestionContent,QuestionDescription from QUESTION 
                                  where CompanyID = @CompanyID and ID=@ID";
                return db.SetCommand(strSql, db.Parameter("@CompanyID", CompanyID, DbType.Int32),
                    db.Parameter("@ID", ID, DbType.Int32)).ExecuteObject<Question_Model>();
            }
        }

        /// <summary>
        /// 检查问题是否有答案
        /// </summary>
        /// <param name="CompanyID"></param>
        /// <param name="ID"></param>
        /// <returns></returns>
        public bool CheckQuestionHaveANSWER(int CompanyID, int ID)
        {
            using (DbManager db = new DbManager())
            {
                string strsql = @"SELECT COUNT(0) FROM dbo.ANSWER a INNER JOIN dbo.QUESTION b
                        ON a.CompanyID=b.CompanyID AND a.QuestionID=b.ID WHERE b.CompanyID=@CompanyID AND b.ID=@ID";
                object obj = db.SetCommand(strsql, db.Parameter("@CompanyID", CompanyID, DbType.Int32),
                    db.Parameter("@ID", ID, DbType.Int32)).ExecuteScalar();
                if ((Object.Equals(obj, null)) || (Object.Equals(obj, System.DBNull.Value)) || (int)obj == 0)
                    return false;
                return true;

            }
        }

        /// <summary>
        /// 删除问题
        /// </summary>
        /// <param name="CompanyID"></param>
        /// <param name="ID"></param>
        /// <returns></returns>
        public int DelQuestion(int CompanyID, int ID)
        {
            using (DbManager db = new DbManager())
            {
                db.BeginTransaction();
                bool rs = false;
                string strsql = string.Empty;

                string strSqlCount = " select count(*) from [TBL_PAPER_QUESTION_RELATIONSHIP] T1 INNER JOIN [TBL_PAPER] T2 ON T1.PaperID = T2.ID AND T2.Available = 1 where T1.CompanyID=@CompanyID and T1.QuestionID=@QuestionID and T1.Available = 1 ";
                int cnt = db.SetCommand(strSqlCount, db.Parameter("@CompanyID", CompanyID, DbType.Int32),
                       db.Parameter("@QuestionID", ID, DbType.Int32)).ExecuteScalar<int>();

                if (cnt > 0) {
                    return -2;
                }

                if (CheckQuestionHaveANSWER(CompanyID, ID))
                {
                    strsql = @"INSERT INTO dbo.HISTORY_ANSWER
                               SELECT * FROM dbo.ANSWER WHERE CompanyID=@CompanyID AND QuestionID=@QuestionID";
                    rs = db.SetCommand(strsql, db.Parameter("@CompanyID", CompanyID, DbType.Int32),
                       db.Parameter("@QuestionID", ID, DbType.Int32)).ExecuteNonQuery() > 0;
                    if (!rs)
                    {
                        db.RollbackTransaction();
                        return -1;
                    }
                    strsql = @"DELETE  dbo.ANSWER
                                FROM    dbo.QUESTION a
                                        INNER JOIN dbo.ANSWER b ON a.CompanyID = b.CompanyID
                                                                   AND a.ID = b.QuestionID
                                WHERE   a.CompanyID = @CompanyID
                                        AND a.ID = @ID
                                ";
                    rs = db.SetCommand(strsql, db.Parameter("@CompanyID", CompanyID, DbType.Int32),
                       db.Parameter("@ID", ID, DbType.Int32)).ExecuteNonQuery() > 0;
                    if (!rs)
                    {
                        db.RollbackTransaction();
                        return -1;
                    }
                    strsql = @"INSERT INTO HISTORY_QUESTION select * from QUESTION where CompanyID=@CompanyID AND ID=@ID";
                    rs = db.SetCommand(strsql, db.Parameter("@CompanyID", CompanyID, DbType.Int32),
                            db.Parameter("@ID", ID, DbType.Int32)).ExecuteNonQuery() > 0;
                    if (!rs)
                    {
                        db.RollbackTransaction();
                        return -1;
                    }
                    strsql = @"DELETE dbo.QUESTION WHERE CompanyID=@CompanyID AND ID=@ID";
                    rs = db.SetCommand(strsql, db.Parameter("@CompanyID", CompanyID, DbType.Int32),
                            db.Parameter("@ID", ID, DbType.Int32)).ExecuteNonQuery() > 0;
                    if (!rs)
                    {
                        db.RollbackTransaction();
                        return -1;
                    }
                    db.CommitTransaction();
                    return 1;
                }
                else
                {
                    strsql = @"INSERT INTO HISTORY_QUESTION select * from QUESTION where CompanyID=@CompanyID AND ID=@ID";
                    rs = db.SetCommand(strsql, db.Parameter("@CompanyID", CompanyID, DbType.Int32),
                            db.Parameter("@ID", ID, DbType.Int32)).ExecuteNonQuery() > 0;
                    if (!rs)
                    {
                        db.RollbackTransaction();
                        return -1;
                    }
                    strsql = @"DELETE dbo.QUESTION WHERE CompanyID=@CompanyID AND ID=@ID";
                    rs = db.SetCommand(strsql, db.Parameter("@CompanyID", CompanyID, DbType.Int32),
                            db.Parameter("@ID", ID, DbType.Int32)).ExecuteNonQuery() > 0;
                    if (!rs)
                    {
                        db.RollbackTransaction();
                        return -1;
                    }
                    db.CommitTransaction();
                    return 1;
                }
            }
        }
    }
}
